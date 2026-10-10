-- EcoKelajak: MVP ma'lumotlar bazasi.
-- Supabase SQL Editor'ga to'liq joylab ishga tushirish mumkin (yoki `supabase db push`).
--
-- Asosiy qoida: holat (status), ball va audit faqat shu fayldagi funksiyalar
-- orqali o'zgaradi. Ilova jadvallarga to'g'ridan-to'g'ri yozolmaydi (RLS).

create extension if not exists postgis with schema extensions;
create extension if not exists pg_cron;

-- ---------------------------------------------------------------------------
-- Turlar
-- ---------------------------------------------------------------------------

create type public.user_role as enum ('user', 'reviewer', 'admin');

create type public.tree_status as enum (
  'submitted',            -- yuborildi, moderator navbatida
  'under_review',         -- yuqori darajadagi tekshiruvga yuborildi
  'needs_more_evidence',  -- qo'shimcha dalil kerak
  'verified_planted',     -- ekish tasdiqlandi
  'monitoring_due',       -- kuzatuv vaqti keldi
  'alive_confirmed',      -- kuzatuvda tirikligi tasdiqlandi
  'dead_or_missing',      -- qurigan yoki topilmadi
  'rejected'              -- rad etildi
);

create type public.evidence_type as enum ('planting_photo', 'after_photo', 'monitoring_photo');

create type public.site_type as enum ('public_space', 'school', 'event_area', 'mahalla', 'other');

create type public.monitoring_kind as enum ('d30', 'd90');

create type public.monitoring_status as enum (
  'scheduled',     -- rejalashtirilgan
  'submitted',     -- foydalanuvchi foto yubordi, tekshiruv kutilmoqda
  'alive',         -- tirik
  'dead',          -- qurigan
  'not_found',     -- topilmadi
  'insufficient',  -- dalil yetarli emas, qayta yuborish mumkin
  'overdue'        -- muddati o'tdi, ma'lumot yo'q (o'lgan degani emas)
);

-- ---------------------------------------------------------------------------
-- Jadvallar
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 40),
  role public.user_role not null default 'user',
  created_at timestamptz not null default now()
);

create table public.species (
  id serial primary key,
  name_uz text not null unique
);

create table public.trees (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles (id) on delete cascade,
  species_id int references public.species (id),
  planted_at timestamptz not null default now(),
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  accuracy_m real not null check (accuracy_m >= 0),
  location extensions.geography(Point, 4326) not null,
  -- Ommaviy xarita uchun ~100 m gacha yaxlitlangan koordinata.
  public_lat double precision not null,
  public_lng double precision not null,
  site_type public.site_type not null,
  permission_confirmed boolean not null default false,
  note text check (char_length(note) <= 500),
  status public.tree_status not null default 'submitted',
  flags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index trees_created_by_idx on public.trees (created_by);
create index trees_status_idx on public.trees (status);
create index trees_location_idx on public.trees using gist (location);

create table public.evidence (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees (id) on delete cascade,
  type public.evidence_type not null,
  storage_key text not null unique,
  captured_at timestamptz not null,
  server_received_at timestamptz not null default now(),
  file_hash text not null check (file_hash ~ '^[0-9a-f]{64}$'),
  lat double precision,
  lng double precision,
  accuracy_m real
);

create index evidence_tree_idx on public.evidence (tree_id);
create index evidence_hash_idx on public.evidence (file_hash);

create table public.monitoring_checks (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees (id) on delete cascade,
  kind public.monitoring_kind not null,
  scheduled_for timestamptz not null,
  status public.monitoring_status not null default 'scheduled',
  submitted_at timestamptz,
  evidence_id uuid references public.evidence (id),
  reviewed_by uuid references public.profiles (id),
  flags text[] not null default '{}',
  unique (tree_id, kind)
);

create index monitoring_due_idx on public.monitoring_checks (status, scheduled_for);

-- Barcha qarorlar tarixi (audit). reviewer_id null bo'lsa — tizim yozuvi.
create table public.reviews (
  id bigserial primary key,
  tree_id uuid not null references public.trees (id) on delete cascade,
  monitoring_check_id uuid references public.monitoring_checks (id) on delete cascade,
  reviewer_id uuid references public.profiles (id),
  decision text not null check (decision in (
    'submitted', 'system_flag', 'approve', 'request_evidence', 'reject', 'escalate',
    'evidence_added', 'monitoring_submitted', 'monitoring_reviewed',
    'appeal_opened', 'appeal_accepted', 'appeal_declined'
  )),
  reason_code text,
  comment text check (char_length(comment) <= 1000),
  from_status public.tree_status,
  to_status public.tree_status,
  created_at timestamptz not null default now()
);

create index reviews_tree_idx on public.reviews (tree_id, created_at);

-- Ballar faqat tarix sifatida saqlanadi; umumiy ball = yig'indi.
create table public.points_ledger (
  id bigserial primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  tree_id uuid references public.trees (id) on delete cascade,
  action_type text not null check (action_type in ('planting_verified', 'monitoring_d30', 'monitoring_d90')),
  points_delta int not null,
  created_at timestamptz not null default now(),
  unique (tree_id, action_type)
);

create index points_user_idx on public.points_ledger (user_id);

create table public.appeals (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  message text not null check (char_length(message) between 5 and 1000),
  status text not null default 'open' check (status in ('open', 'accepted', 'declined')),
  resolved_by uuid references public.profiles (id),
  resolution_comment text,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create unique index appeals_one_open_per_tree on public.appeals (tree_id) where status = 'open';

-- Moderator rad etish / qo'shimcha dalil so'rashda tanlaydigan standart sabablar.
create table public.reason_codes (
  code text primary key,
  label_uz text not null
);

insert into public.reason_codes (code, label_uz) values
  ('photo_unclear', 'Suratda daraxt yoki ekish jarayoni aniq ko''rinmaydi'),
  ('not_planting', 'Surat ekish jarayonini ko''rsatmaydi'),
  ('duplicate', 'Bu surat yoki daraxt avval yuborilgan'),
  ('location_mismatch', 'Joylashuv dalillarga mos kelmaydi'),
  ('low_gps_accuracy', 'GPS aniqligi juda past'),
  ('no_permission', 'Bu joyda ekishga ruxsat borligi ko''rinmaydi'),
  ('suspected_fake', 'Surat tahrirlangan yoki sun''iy bo''lishi mumkin'),
  ('other', 'Boshqa sabab (izohda)');

insert into public.species (name_uz) values
  ('Noma''lum'), ('Chinor'), ('Terak'), ('Qayrag''och'), ('Akatsiya'), ('Archa'),
  ('Qarag''ay'), ('Tol'), ('Jiyda'), ('Shumtol'), ('Zarang'), ('Yong''oq'),
  ('O''rik'), ('Olma'), ('Gilos'), ('Tut'), ('Pista'), ('Saksovul');

-- ---------------------------------------------------------------------------
-- Yordamchi funksiyalar
-- ---------------------------------------------------------------------------

create or replace function public.current_role_name()
returns public.user_role
language sql stable security definer set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

create or replace function public.is_reviewer()
returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce(public.current_role_name() in ('reviewer', 'admin'), false)
$$;

-- Yangi foydalanuvchi ro'yxatdan o'tganda profil yaratiladi.
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  v_name text := trim(new.raw_user_meta_data ->> 'display_name');
begin
  if char_length(coalesce(v_name, '')) < 2 then
    v_name := null;
  end if;
  insert into public.profiles (id, display_name)
  values (new.id, left(coalesce(v_name, 'Ekolog-' || substr(new.id::text, 1, 6)), 40));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger trees_touch before update on public.trees
  for each row execute function public.touch_updated_at();

-- Dalillar ro'yxatini (jsonb massiv) tekshirib, evidence jadvaliga yozadi.
-- Har bir element: {type, storage_key, captured_at, file_hash, lat?, lng?, accuracy_m?}
-- Qaytaradi: topilgan ogohlantirish belgilari (flags).
create or replace function public._insert_evidence(p_tree_id uuid, p_evidence jsonb, p_allowed public.evidence_type[])
returns text[]
language plpgsql security definer set search_path = public
as $$
declare
  v_item jsonb;
  v_flags text[] := '{}';
  v_key text;
  v_hash text;
  v_captured timestamptz;
begin
  if jsonb_typeof(p_evidence) <> 'array' or jsonb_array_length(p_evidence) = 0 then
    raise exception 'Kamida bitta dalil kerak' using errcode = '22023';
  end if;

  for v_item in select * from jsonb_array_elements(p_evidence) loop
    v_key := v_item ->> 'storage_key';
    v_hash := lower(v_item ->> 'file_hash');
    v_captured := (v_item ->> 'captured_at')::timestamptz;

    if not ((v_item ->> 'type')::public.evidence_type = any (p_allowed)) then
      raise exception 'Bu yerda % turidagi dalil qabul qilinmaydi', v_item ->> 'type' using errcode = '22023';
    end if;
    -- Fayl faqat foydalanuvchining o'z papkasida bo'lishi kerak: <uid>/...
    if v_key is null or split_part(v_key, '/', 1) <> auth.uid()::text then
      raise exception 'Noto''g''ri fayl manzili' using errcode = '42501';
    end if;
    if v_captured is null or v_captured > now() + interval '5 minutes' then
      raise exception 'Noto''g''ri suratga olish vaqti' using errcode = '22023';
    end if;

    if exists (select 1 from public.evidence where file_hash = v_hash) then
      v_flags := array_append(v_flags, 'duplicate_file');
    end if;
    if v_captured < now() - interval '24 hours' then
      v_flags := array_append(v_flags, 'old_capture');
    end if;
    -- Android "soxta joylashuv" (mock location) ilovasi aniqlangan.
    if coalesce((v_item ->> 'is_mocked')::boolean, false) then
      v_flags := array_append(v_flags, 'mock_location');
    end if;

    insert into public.evidence (tree_id, type, storage_key, captured_at, file_hash, lat, lng, accuracy_m)
    values (
      p_tree_id,
      (v_item ->> 'type')::public.evidence_type,
      v_key,
      v_captured,
      v_hash,
      (v_item ->> 'lat')::double precision,
      (v_item ->> 'lng')::double precision,
      (v_item ->> 'accuracy_m')::real
    );
  end loop;

  return (select coalesce(array_agg(distinct f), '{}') from unnest(v_flags) f);
end;
$$;

revoke all on function public._insert_evidence(uuid, jsonb, public.evidence_type[]) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Foydalanuvchi amallari (RPC)
-- ---------------------------------------------------------------------------

-- Daraxt qaydini yuborish. Fayllar avval Storage'ga (<uid>/<fayl>) yuklanadi.
create or replace function public.submit_tree(
  p_lat double precision,
  p_lng double precision,
  p_accuracy_m real,
  p_site_type public.site_type,
  p_permission_confirmed boolean,
  p_species_id int,
  p_note text,
  p_evidence jsonb
)
returns uuid
language plpgsql security definer set search_path = public, extensions
as $$
declare
  v_uid uuid := auth.uid();
  v_tree uuid;
  v_flags text[] := '{}';
  v_types text[];
begin
  if v_uid is null then
    raise exception 'Tizimga kiring' using errcode = '42501';
  end if;

  select array_agg(e ->> 'type') into v_types from jsonb_array_elements(p_evidence) e;
  if not (coalesce(v_types, '{}') @> array['planting_photo', 'after_photo']) then
    raise exception 'Ekish jarayoni va yakuniy holat suratlari kerak' using errcode = '22023';
  end if;

  insert into public.trees (
    created_by, species_id, lat, lng, accuracy_m, location, public_lat, public_lng,
    site_type, permission_confirmed, note
  ) values (
    v_uid, p_species_id, p_lat, p_lng, p_accuracy_m,
    st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
    round(p_lat::numeric, 3)::double precision,
    round(p_lng::numeric, 3)::double precision,
    p_site_type, coalesce(p_permission_confirmed, false), nullif(trim(p_note), '')
  ) returning id into v_tree;

  v_flags := public._insert_evidence(v_tree, p_evidence, array['planting_photo', 'after_photo']::public.evidence_type[]);

  if p_accuracy_m > 30 then
    v_flags := array_append(v_flags, 'low_gps_accuracy');
  end if;
  if not coalesce(p_permission_confirmed, false) then
    v_flags := array_append(v_flags, 'permission_not_confirmed');
  end if;
  -- 3 metr ichida boshqa faol qayd bo'lsa — bir daraxt ikki marta qayd etilgan bo'lishi mumkin.
  if exists (
    select 1 from public.trees t
    where t.id <> v_tree
      and t.status <> 'rejected'
      and st_dwithin(t.location, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography, 3)
  ) then
    v_flags := array_append(v_flags, 'nearby_tree');
  end if;
  -- Oxirgi 1 soatda 10 tadan ko'p qayd — g'ayritabiiy faollik.
  if (select count(*) from public.trees where created_by = v_uid and created_at > now() - interval '1 hour') > 10 then
    v_flags := array_append(v_flags, 'high_volume');
  end if;

  update public.trees set flags = v_flags where id = v_tree;

  insert into public.reviews (tree_id, reviewer_id, decision, to_status)
  values (v_tree, null, 'submitted', 'submitted');
  if cardinality(v_flags) > 0 then
    insert into public.reviews (tree_id, reviewer_id, decision, comment)
    values (v_tree, null, 'system_flag', array_to_string(v_flags, ', '));
  end if;

  return v_tree;
end;
$$;

-- "Qo'shimcha dalil kerak" holatidagi qaydga yangi surat qo'shish.
create or replace function public.add_evidence(p_tree_id uuid, p_evidence jsonb)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_tree public.trees;
  v_flags text[];
begin
  select * into v_tree from public.trees where id = p_tree_id for update;
  if v_tree.id is null or v_tree.created_by <> auth.uid() then
    raise exception 'Qayd topilmadi' using errcode = '42501';
  end if;
  if v_tree.status <> 'needs_more_evidence' then
    raise exception 'Bu qaydga hozir dalil qo''shib bo''lmaydi' using errcode = '22023';
  end if;

  v_flags := public._insert_evidence(p_tree_id, p_evidence, array['planting_photo', 'after_photo']::public.evidence_type[]);

  update public.trees
  set status = 'submitted',
      flags = (select coalesce(array_agg(distinct f), '{}') from unnest(v_tree.flags || v_flags) f)
  where id = p_tree_id;

  insert into public.reviews (tree_id, reviewer_id, decision, from_status, to_status, comment)
  values (p_tree_id, auth.uid(), 'evidence_added', v_tree.status, 'submitted', nullif(array_to_string(v_flags, ', '), ''));
end;
$$;

-- Monitoring fotosuratini yuborish (30 yoki 90 kunlik).
create or replace function public.submit_monitoring(
  p_check_id uuid,
  p_evidence jsonb,
  p_lat double precision,
  p_lng double precision,
  p_accuracy_m real
)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
declare
  v_check public.monitoring_checks;
  v_tree public.trees;
  v_flags text[];
  v_evidence uuid;
begin
  select * into v_check from public.monitoring_checks where id = p_check_id for update;
  select * into v_tree from public.trees where id = v_check.tree_id;
  if v_check.id is null or v_tree.created_by <> auth.uid() then
    raise exception 'Kuzatuv topilmadi' using errcode = '42501';
  end if;
  if v_check.status not in ('scheduled', 'overdue', 'insufficient') then
    raise exception 'Bu kuzatuv allaqachon yuborilgan' using errcode = '22023';
  end if;
  if v_check.scheduled_for > now() + interval '3 days' then
    raise exception 'Kuzatuv vaqti hali kelmadi' using errcode = '22023';
  end if;
  if jsonb_array_length(p_evidence) <> 1 then
    raise exception 'Bitta monitoring surati kerak' using errcode = '22023';
  end if;

  v_flags := public._insert_evidence(v_tree.id, p_evidence, array['monitoring_photo']::public.evidence_type[]);
  select id into v_evidence from public.evidence
  where storage_key = p_evidence -> 0 ->> 'storage_key';

  if p_accuracy_m > 30 then
    v_flags := array_append(v_flags, 'low_gps_accuracy');
  end if;
  if not st_dwithin(v_tree.location, st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography, 50) then
    v_flags := array_append(v_flags, 'far_from_tree');
  end if;

  update public.monitoring_checks
  set status = 'submitted', submitted_at = now(), evidence_id = v_evidence, flags = v_flags
  where id = p_check_id;

  insert into public.reviews (tree_id, monitoring_check_id, reviewer_id, decision, comment)
  values (v_tree.id, p_check_id, auth.uid(), 'monitoring_submitted', nullif(array_to_string(v_flags, ', '), ''));
end;
$$;

-- Rad etilgan yoki dalil so'ralgan qaror ustidan murojaat.
create or replace function public.open_appeal(p_tree_id uuid, p_message text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  v_tree public.trees;
  v_id uuid;
begin
  select * into v_tree from public.trees where id = p_tree_id;
  if v_tree.id is null or v_tree.created_by <> auth.uid() then
    raise exception 'Qayd topilmadi' using errcode = '42501';
  end if;
  if v_tree.status not in ('rejected', 'needs_more_evidence', 'dead_or_missing') then
    raise exception 'Bu qaror ustidan murojaat qilib bo''lmaydi' using errcode = '22023';
  end if;

  insert into public.appeals (tree_id, user_id, message)
  values (p_tree_id, auth.uid(), trim(p_message))
  returning id into v_id;

  insert into public.reviews (tree_id, reviewer_id, decision, comment)
  values (p_tree_id, auth.uid(), 'appeal_opened', trim(p_message));
  return v_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Moderator amallari (RPC)
-- ---------------------------------------------------------------------------

create or replace function public._require_reviewer()
returns void
language plpgsql stable security definer set search_path = public
as $$
begin
  if not public.is_reviewer() then
    raise exception 'Faqat moderatorlar uchun' using errcode = '42501';
  end if;
end;
$$;

revoke all on function public._require_reviewer() from public, anon, authenticated;

create or replace function public._award(p_user uuid, p_tree uuid, p_action text, p_points int)
returns void
language sql security definer set search_path = public
as $$
  insert into public.points_ledger (user_id, tree_id, action_type, points_delta)
  values (p_user, p_tree, p_action, p_points)
  on conflict (tree_id, action_type) do nothing
$$;

revoke all on function public._award(uuid, uuid, text, int) from public, anon, authenticated;

-- Ekish qaydi bo'yicha qaror: approve | request_evidence | reject | escalate
create or replace function public.review_tree(
  p_tree_id uuid,
  p_decision text,
  p_reason_code text default null,
  p_comment text default null
)
returns public.tree_status
language plpgsql security definer set search_path = public
as $$
declare
  v_tree public.trees;
  v_new public.tree_status;
begin
  perform public._require_reviewer();

  select * into v_tree from public.trees where id = p_tree_id for update;
  if v_tree.id is null then
    raise exception 'Qayd topilmadi' using errcode = 'P0002';
  end if;
  if v_tree.created_by = auth.uid() then
    raise exception 'O''z qaydingizni tekshira olmaysiz' using errcode = '42501';
  end if;
  if v_tree.status not in ('submitted', 'under_review', 'needs_more_evidence') then
    raise exception 'Bu qayd bo''yicha qaror allaqachon chiqarilgan' using errcode = '22023';
  end if;
  if p_decision in ('reject', 'request_evidence')
     and not exists (select 1 from public.reason_codes where code = p_reason_code) then
    raise exception 'Standart sababni tanlang' using errcode = '22023';
  end if;

  v_new := case p_decision
    when 'approve' then 'verified_planted'
    when 'request_evidence' then 'needs_more_evidence'
    when 'reject' then 'rejected'
    when 'escalate' then 'under_review'
  end;
  if v_new is null then
    raise exception 'Noma''lum qaror: %', p_decision using errcode = '22023';
  end if;

  update public.trees set status = v_new where id = p_tree_id;

  insert into public.reviews (tree_id, reviewer_id, decision, reason_code, comment, from_status, to_status)
  values (p_tree_id, auth.uid(), p_decision, p_reason_code, nullif(trim(p_comment), ''), v_tree.status, v_new);

  if v_new = 'verified_planted' then
    perform public._award(v_tree.created_by, p_tree_id, 'planting_verified', 5);
    insert into public.monitoring_checks (tree_id, kind, scheduled_for) values
      (p_tree_id, 'd30', v_tree.planted_at + interval '30 days'),
      (p_tree_id, 'd90', v_tree.planted_at + interval '90 days')
    on conflict (tree_id, kind) do nothing;
  end if;

  return v_new;
end;
$$;

-- Monitoring natijasi: alive | dead | not_found | insufficient
create or replace function public.review_monitoring(
  p_check_id uuid,
  p_result public.monitoring_status,
  p_comment text default null
)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_check public.monitoring_checks;
  v_tree public.trees;
  v_new public.tree_status;
begin
  perform public._require_reviewer();

  select * into v_check from public.monitoring_checks where id = p_check_id for update;
  if v_check.id is null or v_check.status <> 'submitted' then
    raise exception 'Tekshiriladigan kuzatuv topilmadi' using errcode = '22023';
  end if;
  if p_result not in ('alive', 'dead', 'not_found', 'insufficient') then
    raise exception 'Noto''g''ri natija' using errcode = '22023';
  end if;
  select * into v_tree from public.trees where id = v_check.tree_id for update;
  if v_tree.created_by = auth.uid() then
    raise exception 'O''z qaydingizni tekshira olmaysiz' using errcode = '42501';
  end if;

  update public.monitoring_checks
  set status = p_result, reviewed_by = auth.uid()
  where id = p_check_id;

  v_new := case p_result
    when 'alive' then 'alive_confirmed'
    when 'dead' then 'dead_or_missing'
    when 'not_found' then 'dead_or_missing'
    else v_tree.status
  end::public.tree_status;

  if v_new <> v_tree.status then
    update public.trees set status = v_new where id = v_tree.id;
  end if;

  insert into public.reviews (tree_id, monitoring_check_id, reviewer_id, decision, reason_code, comment, from_status, to_status)
  values (v_tree.id, p_check_id, auth.uid(), 'monitoring_reviewed', p_result::text, nullif(trim(p_comment), ''), v_tree.status, v_new);

  if p_result = 'alive' then
    if v_check.kind = 'd30' then
      perform public._award(v_tree.created_by, v_tree.id, 'monitoring_d30', 2);
    else
      perform public._award(v_tree.created_by, v_tree.id, 'monitoring_d90', 5);
    end if;
  end if;
end;
$$;

-- Murojaatni ko'rib chiqish. Qabul qilinsa, qayd qayta navbatga qaytadi.
create or replace function public.resolve_appeal(p_appeal_id uuid, p_accept boolean, p_comment text default null)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_appeal public.appeals;
  v_tree public.trees;
begin
  perform public._require_reviewer();

  select * into v_appeal from public.appeals where id = p_appeal_id for update;
  if v_appeal.id is null or v_appeal.status <> 'open' then
    raise exception 'Ochiq murojaat topilmadi' using errcode = '22023';
  end if;
  select * into v_tree from public.trees where id = v_appeal.tree_id for update;
  if v_tree.created_by = auth.uid() then
    raise exception 'O''z murojaatingizni ko''rib chiqa olmaysiz' using errcode = '42501';
  end if;

  update public.appeals
  set status = case when p_accept then 'accepted' else 'declined' end,
      resolved_by = auth.uid(), resolution_comment = nullif(trim(p_comment), ''), resolved_at = now()
  where id = p_appeal_id;

  if p_accept then
    update public.trees set status = 'under_review' where id = v_tree.id;
  end if;

  insert into public.reviews (tree_id, reviewer_id, decision, comment, from_status, to_status)
  values (
    v_tree.id, auth.uid(),
    case when p_accept then 'appeal_accepted' else 'appeal_declined' end,
    nullif(trim(p_comment), ''),
    v_tree.status,
    case when p_accept then 'under_review'::public.tree_status else v_tree.status end
  );
end;
$$;

-- Admin: foydalanuvchi rolini o'zgartirish.
create or replace function public.set_user_role(p_user_id uuid, p_role public.user_role)
returns void
language plpgsql security definer set search_path = public
as $$
begin
  if public.current_role_name() is distinct from 'admin' then
    raise exception 'Faqat administratorlar uchun' using errcode = '42501';
  end if;
  update public.profiles set role = p_role where id = p_user_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Rejalashtirilgan monitoring (pg_cron, har kuni)
-- ---------------------------------------------------------------------------

create or replace function public.run_monitoring_jobs()
returns void
language plpgsql security definer set search_path = public
as $$
begin
  -- Muddati kelgan kuzatuvlar: daraxt "kuzatuv kutilmoqda" holatiga o'tadi.
  update public.trees t
  set status = 'monitoring_due'
  where t.status in ('verified_planted', 'alive_confirmed')
    and exists (
      select 1 from public.monitoring_checks c
      where c.tree_id = t.id and c.status = 'scheduled' and c.scheduled_for <= now()
    );

  -- 30 kun ichida bajarilmagan kuzatuv "muddati o'tgan" bo'ladi.
  -- Daraxt o'lgan deb belgilanmaydi: ma'lumot yo'qligi nobud bo'lganiga teng emas.
  update public.monitoring_checks
  set status = 'overdue'
  where status = 'scheduled' and scheduled_for < now() - interval '30 days';
end;
$$;

revoke all on function public.run_monitoring_jobs() from public, anon, authenticated;

select cron.schedule('ekokelajak-monitoring', '0 3 * * *', 'select public.run_monitoring_jobs()');

-- ---------------------------------------------------------------------------
-- Ommaviy ko'rinishlar (faqat tasdiqlangan ma'lumot, shaxsiy ma'lumotsiz)
-- ---------------------------------------------------------------------------

create view public.public_trees as
select
  t.id,
  s.name_uz as species,
  t.status,
  t.public_lat as lat,
  t.public_lng as lng,
  t.planted_at::date as planted_on
from public.trees t
left join public.species s on s.id = t.species_id
where t.status in ('verified_planted', 'monitoring_due', 'alive_confirmed', 'dead_or_missing');

create view public.ranking as
select
  p.id as user_id,
  p.display_name,
  sum(l.points_delta)::int as points,
  count(*) filter (where l.action_type = 'planting_verified')::int as verified_trees,
  rank() over (order by sum(l.points_delta) desc) as position
from public.points_ledger l
join public.profiles p on p.id = l.user_id
group by p.id, p.display_name;

-- README 11-bo'lim formulalari bo'yicha umumiy statistika.
create view public.stats_summary as
with c as (
  select
    count(*) as submitted,
    count(*) filter (where status in ('verified_planted', 'monitoring_due', 'alive_confirmed', 'dead_or_missing')) as verified,
    count(*) filter (where status = 'rejected') as rejected,
    count(*) filter (where 'duplicate_file' = any (flags) or 'nearby_tree' = any (flags)) as duplicate_flagged
  from public.trees
), m as (
  select
    count(*) filter (where kind = 'd90' and status in ('alive', 'dead', 'not_found')) as d90_decided,
    count(*) filter (where kind = 'd90' and status = 'alive') as d90_alive,
    count(*) filter (where kind = 'd90' and status = 'overdue') as d90_overdue,
    count(*) filter (where status = 'alive') as alive_checks
  from public.monitoring_checks
)
select
  c.submitted,
  c.verified,
  c.rejected,
  case when c.verified + c.rejected > 0
    then round(100.0 * c.verified / (c.verified + c.rejected), 1) end as approval_rate_pct,
  m.d90_decided,
  m.d90_alive,
  m.d90_overdue,
  case when m.d90_decided > 0 then round(100.0 * m.d90_alive / m.d90_decided, 1) end as d90_survival_pct,
  case when c.submitted > 0 then round(100.0 * c.duplicate_flagged / c.submitted, 1) end as duplicate_rate_pct
from c, m;

-- ---------------------------------------------------------------------------
-- Ruxsatlar va Row Level Security
-- ---------------------------------------------------------------------------

revoke all on all tables in schema public from anon, authenticated;
revoke execute on all functions in schema public from public, anon, authenticated;

alter table public.profiles enable row level security;
alter table public.species enable row level security;
alter table public.trees enable row level security;
alter table public.evidence enable row level security;
alter table public.monitoring_checks enable row level security;
alter table public.reviews enable row level security;
alter table public.points_ledger enable row level security;
alter table public.appeals enable row level security;
alter table public.reason_codes enable row level security;

grant select on public.profiles, public.species, public.trees, public.evidence,
  public.monitoring_checks, public.reviews, public.points_ledger, public.appeals,
  public.reason_codes to authenticated;
grant update (display_name) on public.profiles to authenticated;

grant select on public.public_trees, public.ranking, public.stats_summary, public.species to anon, authenticated;

create policy profiles_read on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_reviewer());
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create policy species_read on public.species for select using (true);
create policy reason_codes_read on public.reason_codes for select to authenticated using (true);

create policy trees_read on public.trees for select to authenticated
  using (created_by = auth.uid() or public.is_reviewer());

create policy evidence_read on public.evidence for select to authenticated
  using (public.is_reviewer() or exists (
    select 1 from public.trees t where t.id = tree_id and t.created_by = auth.uid()));

create policy monitoring_read on public.monitoring_checks for select to authenticated
  using (public.is_reviewer() or exists (
    select 1 from public.trees t where t.id = tree_id and t.created_by = auth.uid()));

create policy reviews_read on public.reviews for select to authenticated
  using (public.is_reviewer() or exists (
    select 1 from public.trees t where t.id = tree_id and t.created_by = auth.uid()));

create policy points_read on public.points_ledger for select to authenticated
  using (user_id = auth.uid() or public.is_reviewer());

create policy appeals_read on public.appeals for select to authenticated
  using (user_id = auth.uid() or public.is_reviewer());

grant execute on function
  public.submit_tree(double precision, double precision, real, public.site_type, boolean, int, text, jsonb),
  public.add_evidence(uuid, jsonb),
  public.submit_monitoring(uuid, jsonb, double precision, double precision, real),
  public.open_appeal(uuid, text),
  public.review_tree(uuid, text, text, text),
  public.review_monitoring(uuid, public.monitoring_status, text),
  public.resolve_appeal(uuid, boolean, text),
  public.set_user_role(uuid, public.user_role),
  public.is_reviewer(),
  public.current_role_name()
to authenticated;

-- ---------------------------------------------------------------------------
-- Fayl saqlash: yopiq "evidence" bucket
-- Yo'l: <foydalanuvchi id>/<fayl nomi>. Fayllar faqat vaqtinchalik signed URL bilan ochiladi.
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('evidence', 'evidence', false, 10485760, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;

create policy evidence_upload_own on storage.objects for insert to authenticated
  with check (bucket_id = 'evidence' and (storage.foldername(name))[1] = auth.uid()::text);

create policy evidence_read_own_or_reviewer on storage.objects for select to authenticated
  using (bucket_id = 'evidence' and (
    (storage.foldername(name))[1] = auth.uid()::text or public.is_reviewer()));
