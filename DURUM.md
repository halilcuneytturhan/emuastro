# EmuAstro – Durum ve Yapılacaklar

Son güncelleme: 26.11.2026 · Dal: `claude/brave-lovelace-f6phtl`

Hedef: Backend'i kurmak ve bağlamak, ardından App Store build'i alıp TestFlight ile telefona yüklemek. Bunun yanında tüm Emu uygulamalarında "PDF olarak dışa aktar" için EMU Technologies altında ortak bir tasarım kurmak.

---

## 1. Yapılanlar

### 1.1 EMU Technologies ortak PDF şablonu ✅
- Dosya: `lib/services/emu_pdf.dart`. Tek bağımlılığı `package:pdf`, bu yüzden diğer uygulamalara olduğu gibi kopyalanabilir.
- **Uygulamadan uygulamaya değişen:** ad, logo ve vurgu rengi (`EmuPdfBrand`).
- **Sayfa düzeni:**
  - **Üst bilgi (her sayfa):** logo ve uygulama adı, sağda tarih, altında uygulama renginde çizgi.
  - **Kapak bloğu (ilk sayfa):** büyük başlık ve alt başlık.
  - **Alt bilgi (her sayfa):** `<Uygulama> · EMU Technologies` ve `sayfa / toplam`. Yasal uyarı yalnız son sayfada.
  - **PDF dosya bilgileri:** yazar/üretici "EMU Technologies".
- **İçerik parçaları:**
  - `section()`: vurgu çizgili bölüm başlığı
  - `heading()`: alt başlık
  - `paragraph()`: metin
  - `keyValues()`: etiket–değer tablosu
  - `stats()`: öne çıkan sayı kutuları
  - `note()`: bilgi notu
- **Doğrulama:**
  - Şablon dosyası Dart ile kontrol edildi, hata yok.
  - Örnek veriyle 2 sayfalık PDF basılıp görsel olarak incelendi.

### 1.2 EmuAstro PDF dışa aktarımı yeni şablona taşındı ✅
- Dosya: `lib/services/pdf_export.dart`.
- Bölümler:
  - Güneş/Ay/Yükselen kutuları
  - Gezegen konumları tablosu
  - Bugünün skorları ve önerileri
  - Gökyüzü takvimi
  - Kişisel harita raporu (Premium kilidi notuyla)
- Vurgu rengi: `#784CF9`. Logo: `assets/brand/logo.png`.
- ⚠️ Bulut ortamında Flutter olmadığı için bu dosya uygulama içinde derlenip denenmedi. İlk build'de kontrol edilmeli:

```bash
flutter analyze
```

### 1.3 Diğer uygulamaların incelenmesi ✅

| Uygulama | Mevcut dışa aktarım | `pdf` paketi |
|---|---|---|
| EmuAstro | PDF (artık ortak şablonla) | var |
| EmuFit | yok | yok |
| EmuMakrofis | Hazırlık listesi, düz metin paylaşımı (`prep_guide_screen.dart`) | yok |
| EmuMini | yok | yok |
| EmuBoykot | yok | yok |
| EmuEzan | KVKK verisi, JSON (`features/legal/data_export.dart`) | yok |

Not: EmuMini ve EmuBoykot zaten `packages/` altında ortak paket kullanıyor. İleride `emu_pdf` de oraya ortak paket olarak taşınabilir.

---

## 2. Engeller / Kararını beklediğim konular

1. **Yarım kalan istek:** İlk mesajda "öncelikle senden şunu istiyorum" kısmı yarım kalmıştı. İlk istek neydi?
2. **Supabase bağlantısı:** Oturuma bağlı Supabase hesabı `Invalid access token` hatası veriyor. Seçenekler:
   - claude.ai'de Supabase bağlantısı yenilenir, projeyi ben açar ve kurarım.
   - Ya da proje elle açılır, bana proje kimliği (ref) verilir.
3. **Diğer uygulamalara PDF:** Her birine `pdf` paketi eklemek gerekiyor. EmuFit kuralları yeni paket için onay istiyor. Önerilen içerikler:
   - EmuFit: haftalık beslenme ve antrenman özeti
   - EmuMakrofis: hazırlık / alışveriş listesi
   - EmuEzan: aylık namaz vakitleri tablosu
   - EmuMini / EmuBoykot: tarama geçmişi raporu
4. **iOS build / TestFlight:** Xcode gerekiyor. Seçenekler:
   - Mac bu oturuma bağlanır.
   - Ya da Codemagic kullanılır. EmuFit, EmuMakrofis ve EmuEzan'da `codemagic.yaml` var; aynısı EmuAstro'ya kurulabilir.

---

## 3. Backend kurulum adımları (Supabase)

1. supabase.com'da yeni proje aç, **Authentication › Providers › Anonymous** girişini aç.
2. SQL Editor'da `supabase/schema.sql` dosyasını çalıştır. İçeriği: profil, hediye kodu, rehber eşleştirme, sohbet kotası, bildirim jetonları; tümü RLS'li.
3. Sohbet fonksiyonunu kur. API anahtarını sohbete yapıştırma, yalnızca kendi terminaline yaz.

```bash
supabase link --project-ref <proje-ref>
```

```bash
supabase secrets set ANTHROPIC_API_KEY=...
```

```bash
supabase functions deploy astro-chat
```

4. Uygulamayı backend'e bağla:

```bash
flutter run --dart-define=SUPABASE_URL=https://<proje-ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<publishable anon key>
```

`SUPABASE_URL` ve `SUPABASE_ANON_KEY` verilmezse uygulama tamamen yerel çalışır (`lib/services/backend.dart`).

---

## 4. App Store / TestFlight adımları

1. Apple Developer hesabında Bundle ID oluştur, App Store Connect'te uygulama kaydını aç.
2. `ios/Runner` için imzalama ayarlarını yap (Team, Bundle ID, sürüm / build numarası).
3. Build'i Supabase tanımlarıyla al:

```bash
flutter build ipa --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

4. Build'i yükle: Xcode Organizer, Transporter ya da Codemagic ile App Store Connect'e.
5. TestFlight'ta test kullanıcısını ekle, telefona TestFlight uygulamasından yükle.

---

## 5. Sıradaki işler
- [ ] Supabase projesini aç, şemayı ve `astro-chat` fonksiyonunu kur
- [ ] EmuAstro'yu backend tanımlarıyla derle ve test et (PDF dışa aktarımı dahil)
- [ ] Codemagic yapılandırması veya Mac bağlantısı
- [ ] TestFlight'a ilk build
- [ ] Onay gelirse `emu_pdf.dart` şablonunu diğer Emu uygulamalarına ekle
