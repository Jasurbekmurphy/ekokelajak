-- To'liq oqim sinovi: ro'yxatdan o'tish → qayd → moderatsiya → ball → monitoring → murojaat.
-- Har bir foydalanuvchi "authenticated" roli va JWT sub bilan taqlid qilinadi.

\set alice '''11111111-1111-1111-1111-111111111111'''
\set bob   '''22222222-2222-2222-2222-222222222222'''
\set mod   '''33333333-3333-3333-3333-333333333333'''

insert into auth.users (id, email, raw_user_meta_data) values
  (:alice, 'alice@example.com', '{"display_name": "Alisher"}'),
  (:bob, 'bob@example.com', '{}'),
  (:mod, 'mod@example.com', '{"display_name": "Moderator"}');
update public.profiles set role = 'reviewer' where id = :mod;

create function pg_temp.act_as(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p)::text, false);
$$;

create function pg_temp.expect_error(p_sql text, p_like text) returns void language plpgsql as $$
begin
  execute p_sql;
  raise exception 'Xato kutilgan edi, lekin bo''lmadi: %', p_sql;
exception when others then
  if sqlerrm not like p_like then
    raise exception 'Kutilmagan xato: % (kutilgan: %)', sqlerrm, p_like;
  end if;
end;
$$;

create function pg_temp.assert(p_ok boolean, p_msg text) returns void language plpgsql as $$
begin
  if not coalesce(p_ok, false) then raise exception 'SINOV XATOSI: %', p_msg; end if;
end;
$$;

grant execute on all functions in schema pg_temp to authenticated;

-- Profil avtomatik yaratildi, ism bo'lmasa standart nom beriladi.
select pg_temp.assert((select display_name from profiles where id = :bob) like 'Ekolog-%', 'standart ism');

-- --- Alisher daraxt yuboradi -------------------------------------------------
select pg_temp.act_as(:alice);
set role authenticated;

-- To'g'ridan-to'g'ri yozish taqiqlangan.
select pg_temp.expect_error($$insert into trees (created_by, lat, lng, accuracy_m, location, public_lat, public_lng, site_type)
  values (auth.uid(), 41, 69, 5, 'POINT(69 41)', 41, 69, 'school')$$, '%permission denied%');
select pg_temp.expect_error($$update profiles set role = 'admin' where id = auth.uid()$$, '%permission denied%');

-- Faqat bitta surat — rad etiladi.
select pg_temp.expect_error($$select submit_tree(41.311, 69.279, 8, 'school', true, 2, null,
  '[{"type":"after_photo","storage_key":"11111111-1111-1111-1111-111111111111/a.jpg","captured_at":"2026-10-10T10:00:00Z","file_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}]')$$, '%suratlari kerak%');

-- Boshqa foydalanuvchining papkasidagi fayl — rad etiladi.
select pg_temp.expect_error($$select submit_tree(41.311, 69.279, 8, 'school', true, 2, null,
  '[{"type":"planting_photo","storage_key":"22222222-2222-2222-2222-222222222222/a.jpg","captured_at":"2026-10-10T10:00:00Z","file_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},
    {"type":"after_photo","storage_key":"22222222-2222-2222-2222-222222222222/b.jpg","captured_at":"2026-10-10T10:00:00Z","file_hash":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}]')$$, '%fayl manzili%');

select submit_tree(41.3111, 69.2797, 8, 'school', true, 2, 'Maktab hovlisi',
  jsonb_build_array(
    jsonb_build_object('type', 'planting_photo', 'storage_key', '11111111-1111-1111-1111-111111111111/p1.jpg',
      'captured_at', now() - interval '10 minutes', 'file_hash', repeat('a', 64)),
    jsonb_build_object('type', 'after_photo', 'storage_key', '11111111-1111-1111-1111-111111111111/p2.jpg',
      'captured_at', now() - interval '5 minutes', 'file_hash', repeat('b', 64)))) as tree1 \gset

select pg_temp.assert((select status from trees where id = :'tree1') = 'submitted', 'yangi qayd submitted');
select pg_temp.assert((select flags from trees where id = :'tree1') = '{}', 'toza qaydda belgi yo''q');
select pg_temp.assert((select public_lat from trees where id = :'tree1') = 41.311, 'ommaviy koordinata yaxlitlangan');
-- Tasdiqlanmagan qayd ommaviy xaritada yo'q.
select pg_temp.assert(not exists (select 1 from public_trees where id = :'tree1'), 'tasdiqlanmagan qayd xaritada yo''q');
-- Moderator funksiyasi oddiy foydalanuvchiga yopiq.
select pg_temp.expect_error(format($$select review_tree(%L, 'approve')$$, :'tree1'), '%moderatorlar%');

-- --- Bob shu suratni qayta yuboradi (dublikat) ---------------------------------
reset role;
select pg_temp.act_as(:bob);
set role authenticated;

select pg_temp.assert(not exists (select 1 from trees where id = :'tree1'), 'boshqa foydalanuvchi qaydi ko''rinmaydi');

select submit_tree(41.31111, 69.27971, 45, 'public_space', false, null, null,
  jsonb_build_array(
    jsonb_build_object('type', 'planting_photo', 'storage_key', '22222222-2222-2222-2222-222222222222/x.jpg',
      'captured_at', now(), 'file_hash', repeat('a', 64), 'is_mocked', true),
    jsonb_build_object('type', 'after_photo', 'storage_key', '22222222-2222-2222-2222-222222222222/y.jpg',
      'captured_at', now(), 'file_hash', repeat('c', 64)))) as tree2 \gset

select pg_temp.assert(
  (select flags from trees where id = :'tree2') @> array['duplicate_file', 'low_gps_accuracy', 'permission_not_confirmed', 'nearby_tree', 'mock_location'],
  'dublikat, past aniqlik, ruxsat, yaqin daraxt, soxta GPS belgilari');

-- --- Moderator --------------------------------------------------------------
reset role;
select pg_temp.act_as(:mod);
set role authenticated;

select pg_temp.assert((select count(*) from trees) = 2, 'moderator barcha qaydlarni ko''radi');
select pg_temp.expect_error(format($$select review_tree(%L, 'reject')$$, :'tree2'), '%Standart sababni%');
select review_tree(:'tree2', 'reject', 'duplicate', 'Surat avval yuborilgan');
select review_tree(:'tree1', 'approve');
select pg_temp.expect_error(format($$select review_tree(%L, 'reject', 'other')$$, :'tree1'), '%allaqachon%');

select pg_temp.assert((select status from trees where id = :'tree1') = 'verified_planted', 'tasdiqlandi');
select pg_temp.assert((select count(*) from monitoring_checks where tree_id = :'tree1') = 2, '30/90 kunlik kuzatuv rejalashtirildi');
select pg_temp.assert((select sum(points_delta) from points_ledger where user_id = :alice) = 5, '+5 ball');

-- --- Ommaviy ko'rinishlar (anon) --------------------------------------------
reset role;
set role anon;
select pg_temp.assert((select count(*) from public_trees) = 1, 'xaritada faqat tasdiqlangan qayd');
select pg_temp.assert((select points from ranking where display_name = 'Alisher') = 5, 'reyting');
select pg_temp.assert((select approval_rate_pct from stats_summary) = 50.0, 'tasdiqlash ulushi 50%');
select pg_temp.expect_error($$select * from trees$$, '%permission denied%');
select pg_temp.expect_error($$select * from profiles$$, '%permission denied%');

-- --- Monitoring: vaqtni oldinga surib sinaymiz -------------------------------
reset role;
update monitoring_checks set scheduled_for = now() - interval '1 day' where tree_id = :'tree1' and kind = 'd30';
select run_monitoring_jobs();
select pg_temp.assert((select status from trees where id = :'tree1') = 'monitoring_due', 'kuzatuv vaqti keldi');

select id as check30 from monitoring_checks where tree_id = :'tree1' and kind = 'd30' \gset

select pg_temp.act_as(:alice);
set role authenticated;
select submit_monitoring(:'check30',
  jsonb_build_array(jsonb_build_object('type', 'monitoring_photo',
    'storage_key', '11111111-1111-1111-1111-111111111111/m1.jpg', 'captured_at', now(), 'file_hash', repeat('d', 64))),
  41.3111, 69.2797, 6);
select pg_temp.expect_error(format($$select submit_monitoring(%L, '[]', 41.3, 69.2, 5)$$, :'check30'), '%allaqachon%');

reset role;
select pg_temp.act_as(:mod);
set role authenticated;
select review_monitoring(:'check30', 'alive', 'Tirik, barglari bor');
select pg_temp.assert((select status from trees where id = :'tree1') = 'alive_confirmed', 'tirikligi tasdiqlandi');
select pg_temp.assert((select sum(points_delta) from points_ledger where user_id = :alice) = 7, '+2 ball (30 kun)');

-- Muddati o'tgan kuzatuv daraxtni "o'lgan" qilmaydi.
reset role;
update monitoring_checks set scheduled_for = now() - interval '40 days' where tree_id = :'tree1' and kind = 'd90';
select run_monitoring_jobs();
select pg_temp.assert((select status from monitoring_checks where tree_id = :'tree1' and kind = 'd90') = 'overdue', 'muddati o''tdi');
select pg_temp.assert((select status from trees where id = :'tree1') = 'monitoring_due', 'daraxt o''lgan deb belgilanmadi');

-- --- Murojaat ---------------------------------------------------------------
select pg_temp.act_as(:bob);
set role authenticated;
select open_appeal(:'tree2', 'Bu mening o''z suratim, qayta ko''rib chiqing') as appeal \gset
select pg_temp.expect_error(format($$select open_appeal(%L, 'yana bir marta')$$, :'tree2'), '%duplicate key%');

reset role;
select pg_temp.act_as(:mod);
set role authenticated;
select resolve_appeal(:'appeal', true, 'Qayta ko''rib chiqamiz');
select pg_temp.assert((select status from trees where id = :'tree2') = 'under_review', 'murojaatdan keyin qayta navbatda');

-- Audit tarixi to'liq yozilgan.
select pg_temp.assert((select count(*) from reviews where tree_id = :'tree2') >= 5, 'audit tarixi');

-- Moderator o'z qaydini tekshira olmaydi.
reset role;
update profiles set role = 'reviewer' where id = :alice;
select pg_temp.act_as(:alice);
set role authenticated;
select pg_temp.expect_error(format($$select review_tree(%L, 'approve')$$, :'tree1'), '%O''z qaydingizni%');

reset role;
