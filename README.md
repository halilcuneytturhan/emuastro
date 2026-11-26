# EmuAstro

Türkçe astroloji uygulaması (Flutter / Dart, iOS + Android). Üç ana sekme: **Ana Sayfa**, **İlişkiler**, **Profil**.

## Çalıştırma

```bash
flutter pub get
flutter run            # bağlı iOS/Android cihaz veya simülatör
flutter run -d chrome  # tarayıcıda önizleme (iPhone güvenli alanı taklit edilir)
```

## Görsel karşılaştırma

`references/emuastro/ref_01..08.jpg` referans ekranlarıdır. Karşılaştırmayı yeniden üretmek için:

```bash
tool/run.sh            # web derler, 430×932 @2.1465 (923×2000) görüntü alır
```

Çıktılar `comparison/` klasöründe: `app_XX.png` (uygulama), `compare_XX.jpg` (referans | uygulama | %50 üst üste), `small_XX.jpg` (yarı boyut).
Web önizlemede `?tab=0|1|2&scroll=<px>&compact=1` parametreleriyle sekme, kaydırma ve kompakt menü seçilebilir.

## Yapı

- `lib/widgets/surface.dart` – sedefli kart malzemesi (renk geçişi, sedef ışığı, sabit önbellekli gren, kenar ışığı, renkli gölge), dosya silueti `Path`'i
- `lib/widgets/dots.dart` – ölçeklenebilir nokta matrisi rakamlar (0–9, %, /, ., ?)
- `lib/widgets/sprites.dart` – SDF tabanlı pikselli metalik ikonlar (hilal, Satürn, Güneş, yıldız, zil, kilit, kalem, dişli, rehber, telefon, @, kişiler, gezegenler)
- `lib/widgets/wheel.dart` – veriden çizilen doğum haritası
- `lib/widgets/common.dart` – rozet, etkinlik bandı, yüzen alt menü, sohbet ikonu
- `lib/screens/` – sekmeler ve detay ekranları
- `lib/data/sample.dart` – değiştirilebilir örnek veriler
