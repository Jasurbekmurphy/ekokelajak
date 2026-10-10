# EcoKelajak — daraxt ekish va uning holatini kuzatish platformasi

> **Loyiha turi:** jamoatchilikka yo‘naltirilgan ekologik raqamli platforma  
> **Asosiy yo‘nalish:** daraxt ekishni ro‘yxatga olish, dalillar bilan tekshirish va ekilgan daraxtning keyingi holatini kuzatish  
> **Hujjat versiyasi:** 1.0  
> **Holat:** konsepsiya va ishlab chiqish rejasi. Hujjatda tilga olingan funksiyalar hali mahsulotda mavjud deb hisoblanmaydi.

---

## Mundarija

1. [Loyiha haqida](#1-loyiha-haqida)
2. [Muammo va taklif etilayotgan yechim](#2-muammo-va-taklif-etilayotgan-yechim)
3. [Maqsad va tamoyillar](#3-maqsad-va-tamoyillar)
4. [Foydalanuvchilar va rollar](#4-foydalanuvchilar-va-rollar)
5. [Ilova navigatsiyasi: 5 ta asosiy menyu](#5-ilova-navigatsiyasi-5-ta-asosiy-menyu)
6. [Daraxtni ro‘yxatga olish jarayoni](#6-daraxtni-ro‘yxatga-olish-jarayoni)
7. [Haqiqiylikni tekshirish va soxtalashtirishdan himoya](#7-haqiqiylikni-tekshirish-va-soxtalashtirishdan-himoya)
8. [Tekshiruv holatlari va xaritadagi ko‘rinish](#8-tekshiruv-holatlari-va-xaritadagi-ko‘rinish)
9. [Daraxtning keyingi holatini monitoring qilish](#9-daraxtning-keyingi-holatini-monitoring-qilish)
10. [Ball, yutuqlar va reyting](#10-ball-yutuqlar-va-reyting)
11. [Statistika va ekologik ta’sirni o‘lchash](#11-statistika-va-ekologik-tasirni-olchash)
12. [MVP: birinchi ishlaydigan versiya](#12-mvp-birinchi-ishlaydigan-versiya)
13. [Tavsiya etiladigan texnik arxitektura](#13-tavsiya-etiladigan-texnik-arxitektura)
14. [Ma’lumotlar tuzilmasi](#14-malumotlar-tuzilmasi)
15. [API uchun dastlabki reja](#15-api-uchun-dastlabki-reja)
16. [Maxfiylik va xavfsizlik](#16-maxfiylik-va-xavfsizlik)
17. [Boshqaruv va moderatsiya](#17-boshqaruv-va-moderatsiya)
18. [Amalga oshirish yo‘l xaritasi](#18-amalga-oshirish-yol-xaritasi)
19. [Natijalarni o‘lchash mezonlari](#19-natijalarni-olchash-mezonlari)
20. [Xatarlar va ularni kamaytirish](#20-xatarlar-va-ularni-kamaytirish)
21. [Foydalanuvchi ssenariysi](#21-foydalanuvchi-ssenariysi)
22. [Birinchi versiya uchun qabul mezonlari](#22-birinchi-versiya-uchun-qabul-mezonlari)
23. [Loyihaning qisqa ta’rifi](#23-loyihaning-qisqa-tarifi)
24. [Atamalar lug‘ati](#24-atamalar-lugati)

---

## 1. Loyiha haqida

**EcoKelajak** — fuqarolar, o‘quvchi-talabalar, volontyorlar, ta’lim muassasalari, mahallalar va ekologik tashkilotlarga daraxt ekish ishlarini tartibli qayd etish hamda keyinchalik ularning holatini kuzatishda yordam beradigan mobil platforma konsepsiyasi.

Ilovaning asosiy g‘oyasi shunchaki “nechta daraxt ekildi?” deb sanash emas. Muhim savollar quyidagilar:

- Daraxt haqiqatan ekilganmi?
- U qayerda ekilgan va bu joyda ekishga ruxsat bormi?
- Berilgan dalillar tekshiruvdan o‘tganmi?
- Daraxt bir necha hafta yoki oy o‘tgach ham yashayaptimi?
- Natijalar ishonchli ma’lumotlarga asoslanganmi?

EcoKelajak shu savollarga imkon qadar shaffof va izchil javob berishga intiladi. Har bir daraxt uchun foto/video dalillari, joylashuv, ekilgan sana, tekshiruv holati va keyingi kuzatuvlar saqlanadi.

### Loyiha nimani va’da qiladi?

EcoKelajak **soxtalashtirishni mutlaqo imkonsiz qilishni va’da qilmaydi**. Hech bir alohida texnologiya — GPS, telefon kamerasi yoki sun’iy intellekt detektori — daraxt ekilganini 100% kafolatlay olmaydi. Loyiha xavfni bir nechta mustaqil signal, avtomatik tekshiruv va zarur hollarda inson nazorati bilan kamaytirishni ko‘zlaydi.

### Loyiha hozirgi bosqichda nima?

Bu hujjat funksional talablar va ishlab chiqish rejasidir. Mobil ilova, server, tekshiruv algoritmlari va boshqaruv paneli alohida ishlab chiqilishi kerak. Taqdimotda maket yoki reja haqiqiy, ishga tushgan tizim sifatida ko‘rsatilmasligi lozim.

---

## 2. Muammo va taklif etilayotgan yechim

### 2.1. Muammo

Ekologik aksiyalar va daraxt ekish tadbirlarida quyidagi qiyinchiliklar uchrashi mumkin:

1. Ekilgan daraxtlar haqidagi ma’lumotlar turli chatlar, jadvallar va suratlarda tarqoq saqlanadi.
2. Bir daraxt turli ishtirokchilar tomonidan takroran hisobga olinishi mumkin.
3. Surat daraxtning aynan qayerda va qachon ekilganini doim ham isbotlamaydi.
4. Eski yoki sun’iy yaratilgan rasmni yangi ekilgan daraxt sifatida yuborish xavfi bor.
5. Tadbirdan keyin daraxtning yashab qolgan-qolmagani muntazam qayd etilmasligi mumkin.
6. “Nechta daraxt ekildi?” degan raqam bilan “nechtasi yashab qoldi?” degan natija aralashib ketishi mumkin.
7. Yoshlar ishtirokini uzoq muddat saqlab qoladigan tushunarli rag‘bat tizimi yetishmasligi mumkin.

Bular loyiha tekshirishi kerak bo‘lgan muammolardir. Dastlabki pilot bosqichida ularning qaysi biri tanlangan hududda qanchalik ko‘p uchrashi alohida o‘lchanadi.

### 2.2. Yechim

EcoKelajak quyidagi jarayonni bir platformada jamlaydi:

**Daraxt ekish → dalillarni yuborish → avtomatik tekshiruv → kerak bo‘lsa moderator tekshiruvi → xaritada qayd etish → keyingi holatni kuzatish → tasdiqlangan natijalarni statistikada aks ettirish.**

### 2.3. Loyiha qiymati

- **Foydalanuvchi uchun:** o‘z ekologik faoliyatini qayd etadi va natijasini kuzatadi.
- **Volontyorlar guruhi uchun:** birgalikdagi tadbirlar va natijalarni tartibli yuritadi.
- **Ta’lim muassasasi yoki mahalla uchun:** ekilgan daraxtlar ro‘yxati va keyingi holati bo‘yicha hisobot tayyorlashni osonlashtiradi.
- **Ekologik hamkor uchun:** qanday ish bajarilgani va natija qay darajada tekshirilganini ko‘rishga yordam beradi.
- **Jamiyat uchun:** tasdiqlangan ma’lumotlar xaritasi va shaffof statistika shakllanadi.

---

## 3. Maqsad va tamoyillar

### Asosiy maqsad

Daraxt ekish tashabbuslarini ishonchli qayd etish, ularning keyingi holatini kuzatish va yoshlarning ekologik faolligini oshirishga ko‘maklashuvchi qulay raqamli platforma yaratish.

### Vazifalar

1. Daraxtni ro‘yxatga olishning bir xil standartini yaratish.
2. Har bir qayd uchun joylashuv, vaqt va vizual dalillarni saqlash.
3. Takroriy, shubhali yoki yetarli dalilsiz yozuvlarni aniqlash.
4. Zarur hollarda inson tomonidan tekshirish imkonini yaratish.
5. Ekilgan daraxtlarning 30/90 kun yoki boshqa belgilangan muddatlardagi holatini kuzatish.
6. Tasdiqlangan natijalarni xarita va statistikada ko‘rsatish.
7. Yoshlarni faqat ko‘p daraxt kiritishga emas, sifatli ekish va parvarishga ham rag‘batlantirish.

### Asosiy tamoyillar

- **Dalilga asoslanish:** yuborilgan ma’lumot avtomatik ravishda “tasdiqlangan” hisoblanmaydi.
- **Shaffoflik:** daraxtning tekshiruv holati ochiq ko‘rsatiladi.
- **Ekologik sifat:** ekish soni bilan birga daraxtning yashab qolishi ham muhim.
- **Adolat:** shubhali deb belgilangan yozuv avtomatik tarzda firibgarlik deb hisoblanmaydi; qo‘shimcha tekshiruv va murojaat qilish imkoniyati bo‘ladi.
- **Maxfiylik:** foydalanuvchining telefon raqami va boshqa shaxsiy ma’lumotlari ommaviy ko‘rsatilmaydi.
- **Oddiy UX:** foydalanuvchining asosiy vazifasi — daraxtni tez va tushunarli tarzda topshirish.
- **Bosqichma-bosqich rivojlanish:** avval ishlaydigan kichik versiya, keyin murakkab AI funksiyalari.

---

## 4. Foydalanuvchilar va rollar

### 4.1. Oddiy foydalanuvchi

- ro‘yxatdan o‘tadi;
- daraxtni ro‘yxatga olish uchun dalillarni yuboradi;
- o‘z yozuvlarining holatini kuzatadi;
- xaritada tasdiqlangan daraxtlarni ko‘radi;
- shaxsiy statistikasi va reytingini ko‘radi;
- belgilangan vaqtda daraxt holati haqida yangilanish yuboradi.

### 4.2. Volontyor yoki tadbir tashkilotchisi

- ekish tadbiri tashkil etadi yoki unga qo‘shiladi;
- tadbir ishtirokchilariga joy va ekish bo‘yicha ko‘rsatmalar beradi;
- zarur bo‘lsa, tadbir uchun maxsus QR-kod yoki bir martalik tasdiqlash kodidan foydalanadi;
- tadbirdagi umumiy natijalarni ko‘radi.

### 4.3. Moderator / tekshiruvchi

- shubhali yoki qo‘lda ko‘rib chiqilishi kerak bo‘lgan yozuvlarni tekshiradi;
- dalillarni solishtiradi;
- qo‘shimcha ma’lumot so‘raydi;
- yozuvni tasdiqlaydi yoki asosini ko‘rsatgan holda rad etadi;
- daraxtning keyingi holati bo‘yicha tekshiruvlarni qayd etadi.

### 4.4. Administrator

- foydalanuvchilar va rollarni boshqaradi;
- hududlar, tadbirlar va daraxt turlari ro‘yxatini sozlaydi;
- tekshiruv qoidalari va ball tizimini boshqaradi;
- shikoyat va audit tarixini ko‘radi;
- umumiy hisobotlarni tayyorlaydi.

---

## 5. Ilova navigatsiyasi: 5 ta asosiy menyu

Ilovaning pastki navigatsiyasida quyidagi besh bo‘lim bo‘ladi:

`Home` · `Add Tree` · `Map` · `Ranking` · `Profile`

### 5.1. 🏠 Home — bosh sahifa

**Vazifasi:** foydalanuvchiga eng kerakli ma’lumotlarni bir qarashda ko‘rsatish va asosiy harakatga tez olib borish.

Tarkibi:

- katta **“Daraxt qo‘shish”** tugmasi;
- foydalanuvchining tasdiqlangan daraxtlari soni;
- tekshiruv kutilayotgan yozuvlar soni;
- kuzatuvi vaqti kelgan daraxtlar haqida eslatma;
- so‘nggi faollik va tekshiruv natijalari;
- tasdiqlangan, ishonchli ma’lumotlardan olingan hududiy statistika;
- qisqa ekologik maslahat yoki yaqin tadbir.

**Muhim:** Home ekranida yuborilgan, lekin hali tekshirilmagan daraxtlar “tasdiqlangan daraxtlar” ko‘rsatkichi bilan qo‘shib yuborilmaydi.

### 5.2. 🌱 Add Tree — daraxt qo‘shish

**Vazifasi:** yangi ekilgan daraxt haqida standartlashtirilgan qayd yaratish.

Asosiy bosqichlar:

1. Ekish joyini va ruxsat/kelishuv holatini ko‘rsatish.
2. Ilova kamerasi bilan dalil suratlarini olish.
3. Ilova so‘rasa, qisqa jonli video yoki tasodifiy topshiriqni bajarish.
4. GPS joylashuvi va vaqtni qayd etish.
5. Daraxt turi ma’lum bo‘lsa tanlash; noma’lum bo‘lsa “aniq emas” variantini qoldirish.
6. Ma’lumotlarni tekshirib yuborish.
7. Tekshiruv holati va keyingi qadamni ko‘rish.

Daraxt qo‘shish jarayonining batafsil qoidalari 6- va 7-bo‘limlarda berilgan.

### 5.3. 🗺 Map — xarita

**Vazifasi:** tekshiruvdan o‘tgan daraxtlar va ekish tadbirlarini hudud bo‘yicha ko‘rsatish.

Tarkibi:

- tasdiqlangan daraxtlarning xaritadagi belgilari;
- tekshiruv holatiga qarab belgi rangi yoki ikonasi;
- daraxt turi, ekilgan sana va ommaga ko‘rsatishga ruxsat etilgan dalillar;
- hudud, tur, sana yoki holat bo‘yicha filtrlar;
- daraxt tafsilotlari kartasi;
- muammoli yoki noto‘g‘ri joy ko‘rsatilgan yozuv haqida xabar berish imkoniyati.

**Maxfiylik qoidasi:** foydalanuvchining shaxsiy manzili, telefon raqami yoki boshqa shaxsiy ma’lumoti xaritada ko‘rsatilmaydi. Zarur bo‘lsa, jamoatga aniq koordinata emas, taxminiy joylashuv beriladi.

### 5.4. 🏆 Ranking — reyting

**Vazifasi:** ekologik faoliyatni sog‘lom va adolatli rag‘batlantirish.

Tarkibi:

- umumiy reyting;
- hudud yoki ta’lim muassasasi bo‘yicha reyting;
- haftalik, oylik va mavsumiy davr;
- tasdiqlangan daraxtlar va kuzatuv natijalariga asoslangan ball;
- faol jamoalar va tadbirlar reytingi.

Faqat tasdiqlangan yozuvlar ball beradi. Reyting foydalanuvchilarni son ortidan quvishga undamasligi kerak: daraxtni parvarish qilish va uning yashab qolishi ham qadrlanishi zarur.

### 5.5. 👤 Profile — profil

**Vazifasi:** foydalanuvchining shaxsiy faoliyati va sozlamalarini jamlash.

Tarkibi:

- ism yoki tanlangan ommaviy taxallus;
- tasdiqlangan daraxtlar soni;
- tekshiruvdagi yozuvlar;
- ball va yutuqlar;
- “Mening daraxtlarim” ro‘yxati;
- har bir daraxtning tekshiruv tarixi;
- monitoring eslatmalari;
- bildirishnoma, maxfiylik va hisob sozlamalari;
- xato tekshiruv bo‘yicha murojaat yuborish.

---

## 6. Daraxtni ro‘yxatga olish jarayoni

### 6.1. Avval bitta muhim farq

Ilova ikki xil hodisani ajrata olishi kerak:

1. **Ekish hodisasi:** foydalanuvchi daraxt ekish jarayonida qatnashganini bildiradi.
2. **Daraxt qaydi:** ma’lum joyda mavjud bo‘lgan daraxtning holati qayd etiladi.

Faqat tayyor daraxtning bitta rasmi uning aynan shu foydalanuvchi tomonidan hozir ekilganini isbotlamaydi. Shu sababli dalil turi alohida ko‘rsatiladi: “ekish jarayoni”, “ekishdan keyingi holat” yoki “mavjud daraxt monitoringi”.

### 6.2. Tavsiya etiladigan foydalanuvchi oqimi

**1-qadam — Joyni tasdiqlash**

- GPS ruxsati so‘raladi.
- Xarita foydalanuvchining joyini ko‘rsatadi.
- Joy jamoat joyimi, ta’lim muassasasi hududimi yoki boshqa hududmi — tanlanadi.
- Zarur hollarda joy egasi yoki tashkilotchining ruxsati borligi belgilanadi.
- Ruxsatsiz yoki ekishga yaroqsiz joyni tavsiya etmaslik haqida ogohlantirish beriladi.

**2-qadam — Dalillarni olish**

MVP uchun dalil formati:

- ekishdan oldingi holat — imkon bo‘lsa;
- ekish jarayonidan kamida bitta kadr yoki qisqa video;
- ekishdan keyingi yakuniy holat;
- kamera atrofni ko‘rsata oladigan qisqa jonli video — shubha darajasi yuqori bo‘lsa yoki tizim talab qilsa.

Barcha foydalanuvchidan hamma dalilni doim talab qilish UX’ni og‘irlashtirishi mumkin. Shu sababli oddiy holatda eng kam zarur dalillar, xavf signallari bo‘lganda esa qo‘shimcha dalil so‘rash maqsadga muvofiq.

**3-qadam — Daraxt haqidagi ma’lumot**

- daraxt turi — ro‘yxatdan tanlash yoki “aniq emas”;
- ekilgan sana va vaqt — avtomatik qayd etiladi, foydalanuvchi xato bo‘lsa tuzatish so‘rashi mumkin;
- ko‘chat turi yoki o‘lchami — keyingi bosqichda qo‘shilishi mumkin;
- suv berish/parvarish rejasi — ixtiyoriy yoki tadbirga qarab majburiy;
- qisqa izoh — ixtiyoriy.

**4-qadam — Tekshiruv**

Tizim quyidagilarni ko‘rib chiqadi:

- zarur ma’lumotlar to‘ldirilganmi;
- GPS aniqligi yetarlimi;
- bir xil yoki juda o‘xshash rasm avval yuborilganmi;
- shu joyda juda ko‘p takroriy yozuv bormi;
- jonli kamera/video talabi bajarilganmi;
- AI yoki avtomatik tahlil qo‘shimcha tekshiruvni tavsiya qilyaptimi.

**5-qadam — Natija**

Foydalanuvchiga aniq status ko‘rsatiladi: “Tekshiruv kutilmoqda”, “Qo‘shimcha dalil kerak”, “Tasdiqlandi” yoki “Rad etildi”. Rad etilsa, sabab yoziladi va qayta murojaat qilish yo‘li beriladi.

---

## 7. Haqiqiylikni tekshirish va soxtalashtirishdan himoya

### 7.1. Nima uchun birgina rasm yetarli emas?

Sun’iy intellekt yordamida yaratilgan rasm, tahrirlangan foto yoki boshqa joyda olingan eski suratni aniqlash har doim ham oson emas. Xuddi shuningdek, GPS ma’lumotini soxtalashtirish, videoni montaj qilish yoki kamera kadrini aldashga urinishlar ham bo‘lishi mumkin. Shuning uchun EcoKelajak **bitta “sehrli detektor”ga emas, bir nechta mustaqil tekshiruv qatlamiga** tayanadi.

### 7.2. Tekshiruv qatlamlari

#### A. Ilova ichidagi kamera

- Ishonch darajasi yuqori bo‘lgan yuborishlarda surat ilovaning o‘z kamerasida olinadi.
- Galereyadan yuklangan fayllar alohida belgilanishi yoki qo‘shimcha tekshiruvga yo‘naltirilishi mumkin.
- Buning o‘zi soxtalashtirishni to‘liq to‘xtatmaydi: boshqa ekrandagi rasmni qayta suratga olish yoki soxta sahnani videoga olish ehtimoli qoladi.

#### B. Bir martalik jonli topshiriq

Tizim tasodifiy topshiriq berishi mumkin, masalan:

- kamerani sekin burib, daraxt atrofidagi joyni ko‘rsatish;
- daraxt tanasi, tuproq va umumiy manzarani bir videoda ko‘rsatish;
- tadbir tashkilotchisi bergan bir martalik kod yoki QR-kodni kadrga kiritish.

Topshiriq har safar o‘zgarishi mumkin. Bu oldindan tayyorlangan rasmni qayta yuborishni qiyinlashtiradi, ammo ilg‘or soxtalashtirishni butunlay imkonsiz qilmaydi.

#### C. GPS va vaqt signallari

- koordinata, vaqt va GPS aniqligi saqlanadi;
- koordinata tadbirning ruxsat etilgan hududiga mos kelishi tekshirilishi mumkin;
- juda katta tezlikda turli joylardan yuborilgan yozuvlar yoki bir nuqtada g‘ayritabiiy ko‘p yozuvlar qo‘shimcha tekshiruvga tushadi;
- GPS soxtalashtirilishi mumkinligi sababli joylashuv yakka o‘zi isbot hisoblanmaydi.

#### D. Takroriy kontentni aniqlash

- faylning aniq xeshi (hash) orqali aynan bir xil faylni topish;
- pHash yoki tasvir o‘xshashligi orqali kesilgan, siqilgan yoki biroz o‘zgartirilgan nusxalarni aniqlash;
- bir xil daraxt yoki manzara turli foydalanuvchi nomidan takroran qayd etilganini tekshirish.

Tasvirlar o‘xshashligi haqiqiy ikki daraxtni xato ravishda takroriy deb belgilashi mumkin. Shu sababli o‘xshashlik signali avtomatik rad etish uchun emas, tekshiruvga yo‘naltirish uchun ishlatilgani ma’qul.

#### E. Sun’iy intellekt yordamidagi risk tahlili

AI modeli tasvir yoki videoda quyidagilarni baholashga yordam berishi mumkin:

- tasvir sun’iy yaratilgan bo‘lish ehtimoli;
- keskin montaj yoki vizual nomuvofiqlik alomatlari;
- tasvirda daraxt, ko‘chat, tuproq yoki ekish jarayoni ko‘rinish-ko‘rinmasligi;
- turli kadrlar bir-biriga mos kelishi.

**Muhim cheklov:** AI detektori mutlaq haqiqatni aytmaydi. U haqiqiy tasvirni soxta deb belgilashi yoki soxta tasvirni o‘tkazib yuborishi mumkin. Shuning uchun uning natijasi “risk signali” sifatida ishlatiladi, yakuniy hukm sifatida emas.

#### F. Inson yoki tashkilot tomonidan tasdiqlash

Quyidagi holatlarda moderator, o‘qituvchi, tadbir tashkilotchisi yoki vakolatli volontyor tekshiruvi talab qilinishi mumkin:

- avtomatik tizimda bir nechta xavf signali aniqlansa;
- yozuv ommaviy statistikaga sezilarli ta’sir qilsa;
- foydalanuvchi qaror ustidan murojaat qilsa;
- tasdiqlangan daraxt haqida asosli shikoyat kelib tushsa.

Jamoa a’zolarining bir-birini tasdiqlashi qo‘shimcha dalil bo‘lishi mumkin, ammo mustaqil tekshiruv o‘rnini har doim ham bosa olmaydi.

### 7.3. Risk asosida qaror chiqarish

Tizim quyidagi yondashuvdan foydalanishi mumkin:

| Risk darajasi | Misol | Tizimning harakati |
|---|---|---|
| Past | GPS mos, dalillar to‘liq, takroriylik aniqlanmadi | Avtomatik tekshiruvdan keyin tasdiqlash yoki qisqa navbatga qo‘yish |
| O‘rta | GPS aniqligi past yoki faqat yakuniy foto bor | Qo‘shimcha foto/video so‘rash |
| Yuqori | Takroriy rasm, joyga mos kelmaslik va boshqa shubhali signallar | Moderator tekshiruviga yuborish |
| Yetarli dalil yo‘q | Daraxt yoki joy aniqlanmaydi | “Qo‘shimcha dalil kerak” holatiga o‘tkazish yoki sabab bilan rad etish |

Bu jadval dastlabki dizayn taklifidir. Aniq chegaralar pilot sinov natijalari asosida sozlanishi kerak.

---

## 8. Tekshiruv holatlari va xaritadagi ko‘rinish

Har bir daraxtning aniq holati bo‘ladi.

| Holat | Ma’nosi | Ommaviy xaritada ko‘rsatish |
|---|---|---|
| `draft` | Foydalanuvchi hali yubormagan | Yo‘q |
| `submitted` | Yozuv yuborildi | Yo‘q |
| `under_review` | Avtomatik yoki inson tekshiruvi davom etmoqda | Odatda yo‘q |
| `needs_more_evidence` | Qo‘shimcha dalil kerak | Yo‘q |
| `verified_planted` | Ekish bo‘yicha dalillar tekshiruvdan o‘tdi | Ha, maxfiylik qoidalariga muvofiq |
| `monitoring_due` | Keyingi holatni tekshirish vaqti keldi | Ha, “kuzatuv kutilmoqda” belgisi bilan |
| `alive_confirmed` | Keyingi kuzatuvda daraxt tirik ekani tasdiqlandi | Ha |
| `dead_or_missing` | Daraxt qurigan yoki topilmadi | Zarur bo‘lsa tarixiy qayd sifatida, alohida belgida |
| `rejected` | Yozuv tasdiqlanmadi | Yo‘q; foydalanuvchi profilida sabab bilan ko‘rinadi |

“Ekish tasdiqlandi” va “daraxt yashab qoldi” — ikki xil natija. Ularni bitta statusga birlashtirmaslik kerak.

---

## 9. Daraxtning keyingi holatini monitoring qilish

Daraxtni ekish — ishning boshlanishi. Uning keyingi holatini kuzatish ham muhim.

### Taklif etiladigan nazorat nuqtalari

- ekilgan kundagi qayd;
- taxminan 30 kundan keyingi tekshiruv;
- taxminan 90 kundan keyingi tekshiruv;
- zarur bo‘lsa mavsumiy yoki 6–12 oylik tekshiruv.

Aniq muddatlar hudud iqlimi, daraxt turi va ekish mavsumiga qarab ekolog yoki mahalliy mutaxassis bilan belgilanadi. Bu muddatlar hozircha loyiha dizaynidagi boshlang‘ich taklifdir.

### Monitoring qanday ishlaydi?

1. Ilova foydalanuvchiga kuzatuv vaqti yaqinlashganini eslatadi.
2. Foydalanuvchi o‘sha daraxtning yangi fotosuratini ilova kamerasi orqali oladi.
3. Tizim eski va yangi suratni, joylashuvni hamda sanani solishtiradi.
4. Zarur holatda moderator tekshiradi.
5. Natija `alive_confirmed`, `dead_or_missing` yoki `needs_more_evidence` kabi holatlardan biriga o‘tadi.

Agar foydalanuvchi tekshiruvni bajarmasa, daraxt “o‘lgan” deb belgilanmaydi. U “kuzatuv ma’lumoti yo‘q” yoki “tekshiruv muddati o‘tgan” holatida qoladi. Ma’lumot yo‘qligi daraxt nobud bo‘lganiga teng emas.

---

## 10. Ball, yutuqlar va reyting

### Maqsad

Rag‘bat tizimi foydalanuvchini ko‘p yozuv yuborishga emas, **tasdiqlangan va parvarish qilinadigan daraxtlar** bilan natija ko‘rsatishga undashi kerak.

### Dastlabki ball modeli — sozlanadigan taklif

Quyidagi qiymatlar hozircha namunaviy; pilot davomida foydalanuvchi xatti-harakatiga ta’siri tekshirilishi kerak.

| Harakat | Namunaviy ball | Shart |
|---|---:|---|
| Ekish qaydi tasdiqlandi | +5 | Dalillar moderator yoki belgilangan avtomatik jarayondan o‘tgan |
| 30 kunlik monitoring tasdiqlandi | +2 | Aynan shu daraxt ekaniga yetarli dalil mavjud |
| 90 kunlik monitoringda tirikligi tasdiqlandi | +5 | Tekshiruvdan o‘tgan yangi dalil |
| Rasmiy tadbirda ko‘ngilli sifatida qatnashish | +3 | Tashkilotchi tasdiqlagan ishtirok |

Ballni daraxt turiga qarab farqlash kerak bo‘lsa, mezonlar mutaxassislar bilan belgilanadi. Shunchaki katta ball berish uchun foydalanuvchini ko‘p ko‘chat ekishga undash ekologik jihatdan noto‘g‘ri rag‘bat yaratishi mumkin.

### Yutuqlar namunasi

- **Birinchi qadam:** birinchi tasdiqlangan ekish qaydi;
- **Parvarishchi:** bir nechta daraxt bo‘yicha monitoringni bajargan;
- **Jamoa kuchi:** tasdiqlangan jamoaviy tadbirda qatnashgan;
- **Uzluksiz hissa:** bir necha davr davomida faol qatnashgan.

Reytingda faqat tekshirilgan amallar hisoblanadi. Shubhali qayd bo‘yicha qaror chiqarilmaguncha ball vaqtincha berilmasligi mumkin. Foydalanuvchiga qoidalar ochiq tushuntirilishi kerak.

---

## 11. Statistika va ekologik ta’sirni o‘lchash

EcoKelajak statistikasi tekshirilgan ma’lumotlarni ko‘rsatishi kerak. Taklif etiladigan ko‘rsatkichlar:

- yuborilgan daraxt qaydlari;
- tekshiruvdan o‘tgan ekish qaydlari;
- keyingi monitoring muddati kelgan daraxtlar;
- 30/90 kunlik kuzatuvdan o‘tgan daraxtlar;
- kuzatuv vaqtida tirikligi tasdiqlangan daraxtlar;
- hududlar va tadbirlar kesimidagi natijalar;
- dalil yetishmasligi yoki takroriylik sabab tekshiruvga tushgan yozuvlar ulushi.

### Muhim formulalar

**Tasdiqlash ulushi**

`Tasdiqlangan ekish qaydlari / yakuniy qarori chiqarilgan barcha qaydlar × 100%`

Kutilayotgan yoki tekshiruvdagi qaydlar maxrajga kiritilmasligi kerak.

**90 kunlik yashab qolish ulushi**

`90 kunlik tekshiruvda tirikligi tasdiqlangan daraxtlar / 90 kunlik tekshiruv muddati kelgan va natijasi qayd etilgan daraxtlar × 100%`

Alohida ravishda tekshiruvi bajarilmagan daraxtlar ulushi ham ko‘rsatilishi kerak; aks holda yashab qolish ko‘rsatkichi haddan tashqari ijobiy ko‘rinishi mumkin. Hisobotda denominator, davr va ma’lumot to‘liqligi aniq yoziladi.

**Takroriy yozuvlar ulushi**

`Takroriy deb belgilangan qaydlar / barcha yuborilgan qaydlar × 100%`

Bu ko‘rsatkich foydalanuvchilarni ayblash uchun emas, tizim sifatini yaxshilash uchun ishlatiladi.

### CO₂ va kislorod hisoblari haqida

Birinchi versiyada “falon daraxt aniq falon kilogramm CO₂ yutdi” kabi qat’iy raqamlarni ko‘rsatmaslik ma’qul. CO₂ yutilishi daraxt turi, yoshi, o‘sish sharoiti, iqlim va hisoblash metodikasiga bog‘liq. Keyinchalik bunday hisob kerak bo‘lsa, manbasi va formulasi ochiq ko‘rsatiladigan, mos sharoitlarga asoslangan model tanlanadi. Taxminiy raqamlar real o‘lchov sifatida taqdim etilmaydi.

---

## 12. MVP: birinchi ishlaydigan versiya

MVP — katta platformaning eng kichik, lekin haqiqatan ishlaydigan versiyasi. Avval barcha g‘oyalarni birdaniga yaratish shart emas.

### MVP ichiga kiritish tavsiya etiladi

1. Ro‘yxatdan o‘tish va kirish.
2. 5 ta asosiy menyuning soddalashtirilgan ko‘rinishi.
3. Ilova kamerasi orqali foto dalil olish.
4. GPS joylashuv va vaqtni saqlash.
5. Daraxt turi, joy va izohni kiritish.
6. Daraxt qaydini serverga yuborish.
7. `submitted`, `under_review`, `verified_planted`, `needs_more_evidence`, `rejected` holatlari.
8. Moderator uchun oddiy veb-panel yoki xavfsiz boshqaruv sahifasi.
9. Tekshirilgan daraxtlarni xaritada ko‘rsatish.
10. Tasdiqlangan qaydlar asosida sodda profil statistikasi.
11. Monitoring sanasini belgilash va keyingi foto yuborish.
12. Asosiy audit tarixi va foydalanuvchi murojaati.

### Keyingi bosqichlarga qoldirish mumkin

- murakkab AI-generated image detektori;
- ilg‘or video liveness tahlili;
- jamoalararo katta reytinglar;
- ko‘p tilli kontent;
- murakkab ekologik ta’sir/CO₂ hisoblagichi;
- tashkilotlar uchun avtomatlashtirilgan hisobotlar;
- keng ko‘lamli bildirishnoma va tadbirlar tizimi.

**Tavsiya:** dastlab tekshiruvni moderator yordamida amalga oshiring. Avval real ma’lumot to‘plash jarayonini sinab ko‘ring, keyin yetarli ma’lumot asosida avtomatik tahlilni qo‘shing.

---

## 13. Tavsiya etiladigan texnik arxitektura

Quyidagi texnologiyalar majburiy tanlov emas, balki boshlash uchun amaliy variant.

### Variant A — kichik jamoa uchun boshqarilishi oson arxitektura

- **Mobil ilova:** Flutter (Android va iOS uchun umumiy kod bazasi).
- **Backend/API:** Python FastAPI yoki NestJS.
- **Ma’lumotlar bazasi:** PostgreSQL.
- **Geografik qidiruv:** PostGIS kengaytmasi.
- **Foto/video fayllar:** maxsus obyekt saqlash xizmati (S3-mos saqlash yoki boshqariladigan ekvivalent).
- **Autentifikatsiya:** xavfsiz tokenli kirish, parolni tiklash va rollar.
- **Moderator paneli:** oddiy veb-interfeys.
- **Bildirishnomalar:** keyingi bosqichda push bildirishnoma xizmati.
- **AI tekshiruvi:** dastlab ajratilgan, ixtiyoriy servis; MVP ishga tushishi unga bog‘liq bo‘lmasin.

### Yuqori darajadagi ma’lumot oqimi

```text
Mobil ilova
   │
   ├── Login / foydalanuvchi profili
   ├── Kamera, GPS va dalillar
   │
   ▼
Backend API
   ├── Ma’lumotlarni tekshirish
   ├── Takroriylik va risk signallari
   ├── Tekshiruv holatini boshqarish
   └── Ball va monitoring qoidalari
   │
   ├────────► PostgreSQL + PostGIS
   │
   ├────────► Foto/video saqlash
   │
   └────────► Moderator paneli / keyinchalik AI servisi
```

### Texnik tanlovga oid izohlar

- Flutter — mobil interfeysni Android va iOS uchun umumiy kod bilan ishlab chiqish imkonini beradi.
- PostgreSQL — foydalanuvchi, daraxt, tekshiruv va monitoring ma’lumotlarini bog‘lash uchun mos.
- PostGIS — koordinata bo‘yicha masofa, hudud va takroriy joylashuvlarni tekshirishga yordam beradi.
- AI detektori birinchi kundan albatta zarur emas. Avval qoidalar, fayl o‘xshashligi va moderator jarayonini ishlab chiqish mumkin.

Texnologiya tanlovi jamoaning tajribasi, internet/server xarajati va tanlov uchun belgilangan muddatga qarab yakunlanadi.

---

## 14. Ma’lumotlar tuzilmasi

Dastlabki ma’lumotlar modeli quyidagi obyektlarni o‘z ichiga olishi mumkin.

### `users` — foydalanuvchilar

- `id` — noyob identifikator;
- `display_name` — ommaviy ko‘rinadigan ism yoki taxallus;
- `email_or_phone` — kirish uchun zarur aloqa ma’lumoti, ommaga ko‘rsatilmaydi;
- `role` — `user`, `reviewer` yoki `admin`;
- `created_at` — ro‘yxatdan o‘tgan vaqt;
- `privacy_settings` — ommaviy ko‘rinish tanlovlari.

### `trees` — daraxt qaydlari

- `id` — daraxt qaydi identifikatori;
- `created_by` — qaydni yuborgan foydalanuvchi;
- `species` — daraxt turi yoki `unknown`;
- `planted_at` — ekilgan deb bildirilgan sana;
- `latitude`, `longitude` — himoyalangan aniq koordinatalar;
- `location_accuracy_m` — GPS aniqligi, metrda;
- `site_type` — jamoat joyi, ta’lim muassasasi, tadbir hududi va boshqalar;
- `permission_confirmed` — kerakli ruxsat tasdiqlanganmi;
- `status` — tekshiruv holati;
- `public_location` — xaritada ko‘rsatiladigan joylashuv yoki umumlashtirilgan geometriya;
- `created_at`, `updated_at` — tizim vaqt belgilari.

### `evidence` — dalillar

- `id`;
- `tree_id`;
- `evidence_type` — `before_photo`, `planting_photo`, `after_photo`, `video`, `monitoring_photo`;
- `storage_key` — fayl manzili yoki saqlash kaliti;
- `captured_at` — qayd etilgan surat/video vaqti;
- `server_received_at` — server qabul qilgan vaqt;
- `file_hash` — aynan takroriy faylni aniqlash uchun;
- `similarity_flags` — o‘xshashlik natijalari;
- `risk_score` — agar ishlatilsa, risk bahosi va uning versiyasi.

### `reviews` — tekshiruvlar tarixi

- `id`;
- `tree_id`;
- `reviewer_id` yoki `system`;
- `decision` — tasdiqlash, qo‘shimcha dalil so‘rash, rad etish;
- `reason_code` — standart sabab;
- `comment` — izoh;
- `created_at`.

### `monitoring_checks` — keyingi kuzatuv

- `id`;
- `tree_id`;
- `scheduled_for` — rejalashtirilgan sana;
- `submitted_at` — foydalanuvchi yuborgan vaqt;
- `status` — tirik, qurigan, topilmadi, dalil yetarli emas, bajarilmadi;
- `evidence_id` — monitoring fotosurati yoki videosi;
- `reviewed_by` — zarur bo‘lsa tekshiruvchi;
- `notes` — qo‘shimcha izoh.

### `points_ledger` — ball tarixi

- `id`;
- `user_id`;
- `tree_id` yoki `event_id`;
- `action_type`;
- `points_delta`;
- `reason`;
- `created_at`.

Ballarni faqat umumiy son sifatida saqlashdan ko‘ra, har bir o‘zgarish tarixini saqlash adolatli tekshiruv va xatoni tuzatishni osonlashtiradi.

---

## 15. API uchun dastlabki reja

API endpointlari backend texnologiyasi tanlangandan keyin aniq belgilanadi. Dastlab quyidagi amallar zarur bo‘lishi mumkin:

| Method | Endpoint namunasi | Vazifasi |
|---|---|---|
| `POST` | `/auth/register` | Ro‘yxatdan o‘tish |
| `POST` | `/auth/login` | Tizimga kirish |
| `GET` | `/me` | Joriy foydalanuvchi ma’lumoti |
| `POST` | `/trees` | Daraxt qaydini yaratish |
| `GET` | `/trees/{id}` | Bitta daraxt qaydini ko‘rish |
| `GET` | `/me/trees` | Foydalanuvchining daraxtlari |
| `POST` | `/trees/{id}/evidence` | Foto/video dalilini biriktirish |
| `POST` | `/trees/{id}/monitoring` | Keyingi kuzatuvni yuborish |
| `GET` | `/map/trees` | Ommaviy ko‘rsatishga ruxsat etilgan daraxtlar |
| `GET` | `/ranking` | Reytingni olish |
| `GET` | `/statistics/summary` | Tasdiqlangan umumiy ko‘rsatkichlar |
| `GET` | `/review/queue` | Moderator navbati; faqat tegishli rol uchun |
| `POST` | `/review/trees/{id}` | Moderator qarorini saqlash |
| `POST` | `/trees/{id}/appeal` | Qaror ustidan murojaat yuborish |

Barcha endpointlarda autentifikatsiya, ruxsat tekshiruvi, kiritilgan ma’lumotlarni validatsiya qilish va zarur audit jurnali bo‘lishi kerak. Moderator endpointlari oddiy foydalanuvchiga ochiq bo‘lmasligi shart.

---

## 16. Maxfiylik va xavfsizlik

EcoKelajak GPS koordinatalari, fotosuratlar, video va foydalanuvchi hisob ma’lumotlari bilan ishlashi mumkin. Bu ma’lumotlarga ehtiyotkor munosabat zarur.

### Minimal talablar

- kamera va GPS ruxsati nima uchun so‘ralayotgani tushuntiriladi;
- foydalanuvchiga qanday ma’lumot ommaga chiqishi aytiladi;
- aniq koordinata bazada himoyalanadi;
- ommaviy xaritada zarur bo‘lmagan shaxsiy ma’lumotlar chiqarilmaydi;
- shaxsiy fayllar ochiq, taxmin qilish oson bo‘lgan URL orqali tarqatilmaydi;
- server va admin paneli rollar bilan himoyalanadi;
- moderatsiya amallari audit tarixida saqlanadi;
- ma’lumotni saqlash muddati va o‘chirish tartibi belgilanadi;
- zaxira nusxalari va tiklash rejasi bo‘ladi;
- tegishli yurisdiksiyadagi shaxsiy ma’lumotlarni himoya qilish talablariga rioya qilinadi.

Yosh foydalanuvchilar qatnashishi mumkinligi sababli, interfeys tushunarli, xavfsiz va yoshga mos bo‘lishi kerak. Ommaviy profil uchun foydalanuvchining haqiqiy to‘liq ismini ko‘rsatish majburiy qilinmasin.

---

## 17. Boshqaruv va moderatsiya

### Moderator nimalarni ko‘radi?

- yuborilgan dalillar;
- daraxt joylashuvi va GPS aniqligi;
- yuborilgan vaqt va server qabul qilgan vaqt;
- dublikat/o‘xshashlik ogohlantirishlari;
- oldingi qarorlar;
- monitoring tarixi;
- foydalanuvchidan kelgan izohlar.

### Moderatorning mumkin bo‘lgan qarorlari

1. **Tasdiqlash:** dalillar talabga mos.
2. **Qo‘shimcha dalil so‘rash:** ma’lumot yetarli emas.
3. **Rad etish:** aniq sabab bilan.
4. **Yuqori darajadagi ko‘rib chiqishga yuborish:** jiddiy shubha yoki bahsli holat.

### Adolatli jarayon

- AI flag yoki avtomatik signalning o‘zi foydalanuvchini firibgar deb e’lon qilish uchun yetarli emas.
- Foydalanuvchi qaror sababini ko‘ra oladi.
- Xato rad etilgan yozuv bo‘yicha murojaat qilish imkoniyati bo‘ladi.
- Bir moderator qarori kerak bo‘lgan holatlar va ikkinchi tekshiruv talab qilinadigan holatlar oldindan belgilanadi.
- Tekshiruv muddati va navbatdagi yozuvlar soni monitoring qilinadi.

---

## 18. Amalga oshirish yo‘l xaritasi

Quyidagi muddatlar kafolatlangan jadval emas, balki kichik jamoa uchun rejalashtirish namunasi. Jamoa soni va texnik tajribaga qarab o‘zgaradi.

### 0-bosqich — Talablarni aniqlash

**Natija:** loyiha doirasi, foydalanuvchi oqimlari va tekshiruv qoidalari kelishilgan hujjat.

Ishlar:

- foydalanuvchi bilan suhbatlar;
- pilot hudud va hamkorlarni aniqlash;
- daraxt ekish dalillari standartini ekologik mutaxassis bilan kelishish;
- xaritada ko‘rsatiladigan ma’lumotlarni belgilash;
- Figma yoki qog‘oz prototipni sinash.

### 1-bosqich — MVP ishlab chiqish

**Natija:** foydalanuvchi qayd yubora oladigan, moderator esa uni tekshira oladigan ilk versiya.

Ishlar:

- login va profil;
- daraxt qaydi formasi;
- foto/video saqlash;
- GPS va vaqt;
- qayd holatlari;
- moderator paneli;
- xaritada tasdiqlangan qaydlar;
- minimal statistika.

### 2-bosqich — Pilot sinov

**Natija:** cheklangan hudud yoki ta’lim muassasasida haqiqiy foydalanish natijalari.

Ishlar:

- bir nechta aniq ekish joyini tanlash;
- foydalanuvchilar bilan sinov;
- takroriy yozuv va xatolarni o‘lchash;
- tekshiruv vaqtini o‘lchash;
- foydalanuvchi fikrlarini yig‘ish;
- monitoring eslatmalarini sinash.

Pilot miqyosi uchun, masalan, 50–100 foydalanuvchi va 100–300 qayd kabi kichik maqsadlar tanlanishi mumkin; bu tavsiya etilgan sinov hajmi, kafolatlangan natija emas.

### 3-bosqich — Ishonchlilikni kuchaytirish

**Natija:** soxtalashtirish xavfini kamaytiradigan qo‘shimcha tekshiruvlar.

Ishlar:

- takroriy tasvirni aniqlash;
- bir martalik video topshirig‘i;
- tadbir QR-kodi;
- riskga asoslangan moderator navbati;
- monitoring jarayonini yaxshilash.

### 4-bosqich — Kengaytirish

**Natija:** bir nechta hudud yoki tashkilotlar ishlata oladigan tizim.

Ishlar:

- tashkilotlar uchun panel;
- jamoa reytingi;
- eksport qilinadigan hisobotlar;
- ko‘p tilli interfeys;
- kerak bo‘lsa, baholangan AI modullari;
- server ishlashi va xavfsizlikni kuchaytirish.

---

## 19. Natijalarni o‘lchash mezonlari

Loyiha muvaffaqiyatini faqat ilovani yuklab olganlar soni bilan o‘lchamaslik kerak.

| Ko‘rsatkich | Nimani o‘lchaydi? | Nima uchun kerak? |
|---|---|---|
| Faol foydalanuvchilar | Belgilangan davrda muhim amal bajargan foydalanuvchilar | Haqiqiy foydalanishni ko‘rsatadi |
| Dalili to‘liq qaydlar ulushi | Talab etilgan dalillari mavjud qaydlar ulushi | Forma va UX sifatini o‘lchaydi |
| Tekshiruvga ketgan vaqt | Yuborishdan yakuniy qarorgacha bo‘lgan vaqt | Moderatsiya yukini ko‘rsatadi |
| Takroriy qaydlar ulushi | Takroriy deb belgilangan qaydlar ulushi | Dublikat muammosini o‘lchaydi |
| 30/90 kunlik monitoring bajarilishi | Vaqti kelgan kuzatuvlarning nechasi yakunlangan | Foydalanuvchi ishtiroki va monitoring sifatini ko‘rsatadi |
| Kuzatuvda tirikligi tasdiqlangan ulush | Tegishli muddatda tekshirilib, tirik deb belgilangan daraxtlar ulushi | Ekishdan keyingi natijani baholaydi |
| Qo‘lda tekshirish ulushi | Moderatorga yuborilgan qaydlar ulushi | Avtomatlashtirish ehtiyojini ko‘rsatadi |
| Murojaat natijalari | Qaror ustidan berilgan murojaatlar va ularning natijasi | Tekshiruv adolatini kuzatadi |

Har bir ko‘rsatkich uchun davr, ma’lumot manbasi va hisoblash formulasi hujjatlashtiriladi. Dastlabki raqamlar mavjud bo‘lmasa, taxminiy natijani fakt sifatida yozmaslik kerak.

---

## 20. Xatarlar va ularni kamaytirish

| Xatar | Oqibat | Kamaytirish yo‘li |
|---|---|---|
| AI orqali yaratilgan yoki tahrirlangan kontent | Soxta daraxt qaydlari | Jonli dalil, GPS, takroriylik tahlili va inson tekshiruvini birlashtirish |
| GPS soxtalashtirilishi yoki noaniqligi | Noto‘g‘ri joylashuv | GPS aniqligi, tadbir geofensi va qo‘shimcha dalil; GPSni yakka isbot deb olmaslik |
| Haqiqiy rasm noto‘g‘ri rad etilishi | Foydalanuvchi ishonchi kamayishi | Risk flaglarini yakuniy hukm emas, tekshiruv signali sifatida ishlatish; murojaat yo‘li |
| Daraxt ekish uchun joy ruxsati yo‘qligi | Hududga zarar yoki nizo | Joy ruxsatini aniqlash va hamkor tashkilotlar bilan kelishish |
| Daraxt turi noto‘g‘ri tanlanishi | Ekologik samara pasayishi | Mahalliy ekolog yoki agronom tavsiyasi, hududga mos turlar ro‘yxati |
| Daraxt ekilib, keyin qurishi | Haqiqiy ekologik natija pasayishi | Monitoring, sug‘orish va parvarish bo‘yicha tavsiyalar |
| Reyting noto‘g‘ri rag‘bat yaratishi | Sifat o‘rniga miqdor ortidan quvish | Parvarish va yashab qolishni ham baholash |
| Shaxsiy ma’lumot oshkor bo‘lishi | Maxfiylik buzilishi | Minimal ma’lumot, ruxsatlar va ommaviy joylashuvni cheklash |
| Ilova interneti yomon joyda ishlamasligi | Qayd yuborilmay qolishi | Saqlab turish/kechiktirib yuborish funksiyasini keyingi bosqichda ko‘rib chiqish |
| Moderatsiya navbati ko‘payishi | Tasdiqlash sekinlashishi | Riskga asoslangan navbat, standart qaror sabablari va moderatorlar uchun yo‘riqnoma |

---

## 21. Foydalanuvchi ssenariysi

**Vaziyat:** talaba ekologik aksiya davomida ko‘chat ekdi.

1. Talaba EcoKelajak ilovasini ochadi va `Add Tree` bo‘limiga kiradi.
2. Joylashuv ruxsatini beradi va xaritada ekish joyini tekshiradi.
3. Joy ekish uchun belgilangan hudud ekanini tasdiqlaydi.
4. Ilova kamerasida ekish jarayonidan dalil va yakuniy holat suratini oladi.
5. Daraxt turini tanlaydi yoki hozircha noma’lum deb belgilaydi.
6. Qaydni yuboradi; tizim GPS, vaqt va fayl takroriyligini tekshiradi.
7. Qayd shubhali bo‘lmasa ham, dastlabki siyosatga ko‘ra moderator ko‘rib chiqishiga tushishi mumkin.
8. Moderator dalillarni tekshirib, tasdiqlaydi yoki qo‘shimcha dalil so‘raydi.
9. Tasdiqlangan daraxt xaritada ko‘rinadi, ball foydalanuvchiga yoziladi.
10. 30 kun o‘tgach, foydalanuvchi daraxt holatini yangilash haqida eslatma oladi.
11. Yangi dalil tekshiruvdan o‘tsa, daraxtning monitoring tarixi yangilanadi.
12. Hudud statistikasi faqat tegishli holatdagi tekshirilgan ma’lumotlar asosida yangilanadi.

---

## 22. Birinchi versiya uchun qabul mezonlari

MVP tayyor deb hisoblanishi uchun quyidagi shartlar bajarilishi kerak:

- [ ] Foydalanuvchi hisob ochishi va tizimga kira olishi.
- [ ] Foydalanuvchi daraxt qaydini foto dalili bilan yubora olishi.
- [ ] GPS koordinatasi va aniqligi saqlanishi.
- [ ] Takroriy fayl tekshiruvi ishlashi.
- [ ] Qayd holati foydalanuvchiga aniq ko‘rsatilishi.
- [ ] Moderator qaydni ko‘rishi va standart sabablar bilan qaror berishi.
- [ ] Tasdiqlanmagan daraxt ommaviy statistikaga tasdiqlangan daraxt sifatida qo‘shilmasligi.
- [ ] Faqat ko‘rsatishga ruxsat etilgan daraxtlar ommaviy xaritada chiqishi.
- [ ] Foydalanuvchi o‘z daraxtlari va statuslarini ko‘ra olishi.
- [ ] Monitoring uchun sana va keyingi dalil yuborish imkoniyati mavjud bo‘lishi.
- [ ] AI signalining o‘zi yakuniy rad qarorini bermasligi.
- [ ] Moderatsiya tarixi va murojaat qilish imkoniyati ishlashi.
- [ ] Shaxsiy aloqa ma’lumotlari ommaviy ko‘rsatilmasligi.

---

## 23. Loyihaning qisqa ta’rifi

**EcoKelajak — daraxt ekishni foto/video dalillari va GPS orqali qayd etish, yozuvlarni tekshiruvdan o‘tkazish, tasdiqlangan daraxtlarni xaritada ko‘rsatish va ularning keyingi holatini monitoring qilishga mo‘ljallangan jamoatchilik platformasi.** Platforma foydalanuvchilarning ekologik faolligini reyting va yutuqlar orqali rag‘batlantiradi. Soxta kontent xavfini kamaytirish uchun ilova kamerasida olingan dalillar, joylashuv va vaqt signallari, takroriy tasvir tahlili, xavfga asoslangan inson tekshiruvi birgalikda ishlatiladi. Sun’iy intellekt tekshiruvga yordam beruvchi vosita sifatida qo‘llanadi, lekin yakka o‘zi mutlaq haqiqat manbai hisoblanmaydi. Loyiha natijasi nafaqat ekilgan daraxtlar soni, balki keyingi monitoringda tirikligi tasdiqlangan daraxtlar bilan ham baholanadi.

---

## 24. Atamalar lug‘ati

- **MVP:** asosiy foydani tekshirish uchun yaratiladigan eng kichik ishlaydigan mahsulot.
- **GPS:** qurilmaning geografik joylashuvini aniqlash texnologiyasi.
- **Geofens:** xaritada belgilangan hudud ichida yoki tashqarisida ekanini tekshiruvchi geografik chegara.
- **Hash:** faylni solishtirish va aynan takroriy nusxani aniqlashga yordam beruvchi raqamli qiymat.
- **Perceptual hash (pHash):** tasvirlar o‘xshashligini taxminiy baholash usuli.
- **Risk signali:** yozuvda muammo bo‘lishi mumkinligini ko‘rsatuvchi belgi; o‘zi yakuniy hukm emas.
- **Moderatsiya:** inson yoki vakolatli xodim tomonidan yozuvni tekshirish jarayoni.
- **Monitoring:** ekilgan daraxtning keyingi holati haqida belgilangan vaqtlarda dalil yig‘ish.
- **Tasdiqlangan ekish:** ekish hodisasi bo‘yicha berilgan dalillar belgilangan tekshiruvdan o‘tgan holat.
- **Tirikligi tasdiqlangan daraxt:** keyingi kuzatuv vaqtida tirik ekani yetarli dalil bilan tasdiqlangan daraxt.

---

## Keyingi amaliy qadamlar

1. MVP funksiyalarini yakuniy kelishib olish.
2. 5 ta asosiy ekran uchun interaktiv UX prototip tayyorlash.
3. Daraxtni tasdiqlash siyosatini ekolog yoki mahalliy hamkor bilan tekshirish.
4. Ma’lumotlar bazasi va backend API ni ishlab chiqish.
5. Moderatsiya panelini yaratish.
6. Bitta ta’lim muassasasi yoki kichik hududda pilot sinov o‘tkazish.
7. Pilot natijalari asosida tekshiruv qoidalari va foydalanuvchi tajribasini yaxshilash.

**Asosiy qoida:** avval kichik miqyosda ishonchli ishlaydigan jarayon yarating. Keyin uni avtomatlashtiring va kengaytiring.
