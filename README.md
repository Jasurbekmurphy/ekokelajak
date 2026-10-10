# EcoKelajak

Daraxt ekishni foto dalil va GPS bilan qayd etish, moderator tekshiruvi, xaritada ko'rsatish va 30/90 kunlik monitoring platformasi.

Loyiha konsepsiyasi: [docs/konsepsiya.md](docs/konsepsiya.md)

## Tuzilma

```
app/              Flutter mobil ilova (Android, iOS)
admin/            Flutter Web moderator paneli
packages/core/    Umumiy kod: modellar, Supabase API, umumiy widgetlar
supabase/
  migrations/     Butun backend: jadvallar, RLS, funksiyalar, cron
  tests/          Migratsiyani lokal Postgres'da sinash
```

Alohida server yo'q. Backend — Supabase (Postgres + PostGIS + Auth + Storage + pg_cron).
Holat, ball va audit faqat bazadagi funksiyalar orqali o'zgaradi, ilova jadvallarga to'g'ridan-to'g'ri yozolmaydi.

## 1. Supabase'ni sozlash

1. [supabase.com](https://supabase.com) da bepul loyiha oching.
2. **SQL Editor** → `supabase/migrations/20261010000000_init.sql` faylini to'liq joylab, **Run** bosing.
3. **Authentication → Sign In / Providers → Email**: demo uchun "Confirm email" ni o'chirib qo'yish mumkin
   (aks holda foydalanuvchi emailini tasdiqlashi kerak bo'ladi).
4. **Project Settings → API**: `Project URL` va `publishable` (yoki `anon`) kalitini oling.
   `secret` / `service_role` kalitini hech qachon ilovaga qo'ymang.

## 2. Ilovani ishga tushirish

`app/env.json` va `admin/env.json` fayllarini yarating (namuna: `env.example.json`):

```json
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."
}
```

```bash
cd app   && flutter run --dart-define-from-file=env.json          # telefon ulangan bo'lsa
cd admin && flutter run -d chrome --dart-define-from-file=env.json
```

APK GitHub Actions'da avtomatik yig'iladi: **Actions → CI → oxirgi ishga tushish → Artifacts → ekokelajak-apk**.
APK haqiqiy bazaga ulanishi uchun `app/env.json` repoga qo'shilgan bo'lishi kerak
(publishable kalit ommaviy bo'lishi uchun mo'ljallangan, uni repoda saqlash xavfsiz).

## 3. Moderator tayinlash

Ilovada ro'yxatdan o'ting, keyin Supabase **SQL Editor**'da:

```sql
update public.profiles set role = 'admin'
where id = (select id from auth.users where email = 'sizning@email.uz');
```

Moderator o'z qaydini tekshira olmaydi, shuning uchun demo uchun kamida 2 ta akkaunt kerak.

## Qanday ishlaydi

1. Foydalanuvchi **Qo'shish** bo'limida GPS joyini aniqlaydi, joy turini tanlaydi, ilova kamerasida 2 ta surat oladi (ekish jarayoni va yakuniy holat).
2. Suratlar yopiq `evidence` bucket'ga yuklanadi, `submit_tree()` qaydni yaratadi va avtomatik belgilar qo'yadi:
   takroriy fayl (SHA-256), past GPS aniqligi, 3 m ichida boshqa qayd, soxta GPS ilovasi, ruxsat tasdiqlanmagan, eski surat.
   Belgilar faqat moderator uchun signal, avtomatik rad etmaydi.
3. Moderator panelida: tasdiqlash (+5 ball, 30/90 kunlik kuzatuv rejalashtiriladi), qo'shimcha dalil so'rash, sabab bilan rad etish yoki yuqoriga yuborish.
4. Har kuni `pg_cron` muddati kelgan daraxtlarni "Kuzatuv kutilmoqda" holatiga o'tkazadi. Foydalanuvchi yangi surat yuboradi, moderator baholaydi (tirik: +2 / +5 ball).
   Bajarilmagan kuzatuv "muddati o'tgan" bo'ladi, daraxt o'lgan deb belgilanmaydi.
5. Ommaviy xarita, reyting va statistika faqat tasdiqlangan ma'lumotdan, koordinata ~100 m gacha yaxlitlangan holda.
6. Rad etilgan qaror ustidan murojaat qilish mumkin, barcha qarorlar `reviews` jadvalida tarix sifatida saqlanadi.

## Sinovlar

```bash
# Baza: PostgreSQL 16 + PostGIS + pg_cron kerak (CI'da avtomatik)
sudo -u postgres bash supabase/tests/run.sh

cd packages/core && flutter test
```

## MVP'ga kirmagan (keyingi bosqichlar)

AI / sun'iy rasm detektori, pHash o'xshashligi, video va jonli topshiriq, tadbirlar va QR-kod,
push bildirishnomalar, offline rejim, parolni tiklash, ko'p til, CO₂ hisoblari.
Fayl xeshi hozircha telefonda hisoblanadi; keyingi bosqichda serverda (Edge Function) qayta tekshirish kerak.
