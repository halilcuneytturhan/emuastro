import 'package:flutter/foundation.dart';

/// Örnek veriler (referansla birebir karşılaştırma için). Tümü değiştirilebilir.
class SkyEvent {
  final String kicker, title, sub, body;
  final String kind; // sun, moon, saturn
  const SkyEvent(this.kicker, this.title, this.kind,
      {this.sub = 'Sana olan etkilerini incele', this.body = ''});
}

class Twin {
  final int pct;
  final String name, job, common;
  final String pal;
  const Twin(this.pct, this.name, this.job, this.common, this.pal);
}

class Planet {
  final String id;
  final double lon; // ekliptik boylam (derece)
  final bool retro;
  const Planet(this.id, this.lon, {this.retro = false});
}

class Profile {
  String name;
  DateTime birth;
  String time;
  String place;
  Profile(this.name, this.birth, this.time, this.place);
}

class AppData extends ChangeNotifier {
  final profile =
      Profile('buket', DateTime(2004, 7, 25), '09:30', 'İstanbul, Türkiye');
  DateTime today = DateTime(2026, 11, 25);
  int unlocked = 1, totalSections = 15;
  int performance = 60;
  String performanceLabel = 'Güçlü';
  int streak = 2;
  int giftsLeft = 3;
  List<double> trend = [0.18, 0.55, 0.45, 0.44, 0.52, 0.56, 0.54];

  String sun = 'Aslan', moon = 'Akrep', asc = 'Başak';

  final neverToday =
      "Akşama doğru bir konuşmayı güç savaşına çevirecek keskin cümleler kurma, çünkü Ay'ın Plüton'la karşıtlığı kontrol etme isteğini artırabilir.";

  final moves = const [
    ('BUGÜN YAP',
        'Sabah erken bir başvuru, eğitim planı ya da uzaklarla ilgili işi görünür bir sonraki adıma taşı.'),
    ('DİKKAT ET',
        'Öğleden sonra aceleyle verilen sözler sonradan yük olabilir; takvimini kontrol etmeden onay verme.'),
    ('HATIRLATMA',
        'Bugün küçük bir rutini tamamlamak, büyük planlardan daha çok güven verecek.'),
    ('BU DÖNEM',
        'Güneş Yay’dayken öğrenmek, yolculuk ve yayın konuları haritanda öne çıkıyor.'),
  ];

  final events = const [
    SkyEvent('22 KASIM · BURÇ GEÇİŞİ', "Güneş Yay'a geçiyor", 'sun',
        body:
            'Güneş’in Yay burcuna geçişi, haritanda iletişim ve öğrenme alanını aydınlatıyor.'),
    SkyEvent('24 KASIM · DOLUNAY', 'İkizler Dolunayı', 'moon',
        body:
            'İkizler Dolunayı kariyer ve görünürlük alanında bir döngüyü tamamlıyor.'),
    SkyEvent('11 ARALIK · RETRO BİTİYOR', 'Satürn Retrosu', 'saturn',
        body:
            'Satürn düz harekete dönerken ertelediğin sorumluluklar netleşiyor.'),
  ];

  final twins = const [
    Twin(66, 'Frida Kahlo', 'Ressam', 'Güneş Aslan · Ay Akrep', 'navy'),
    Twin(65, 'Beyoncé', 'Müzisyen', 'Ay Akrep · Venüs–Neptün açısı ortak',
        'rose'),
    Twin(64, 'Fiona Apple', 'Müzisyen', 'Venüs–Neptün açısı ortak', 'amber'),
    Twin(61, 'Virginia Woolf', 'Yazar', 'Yükselen Başak ortak', 'deepGreen'),
  ];

  final boxTips = const [
    'Bugün bir arkadaşına uzun zamandır söylemek istediğin teşekkürü ilet.',
    'Akşam yürüyüşü Ay–Plüton gerginliğini yumuşatır.',
    'Mor ya da koyu kırmızı bir detay seni bugün daha güçlü hissettirir.',
  ];

  // Referanstaki haritaya benzeyen yerleşim (ASC 160° ≈ Başak 10°).
  double ascLon = 160;
  final planets = const [
    Planet('sun', 122.9),
    Planet('moon', 222.6),
    Planet('mercury', 140.2),
    Planet('venus', 74.6),
    Planet('mars', 133.5),
    Planet('jupiter', 155.8),
    Planet('saturn', 103.1),
    Planet('uranus', 335.2, retro: true),
    Planet('neptune', 314.0, retro: true),
    Planet('pluto', 259.6, retro: true),
    Planet('node', 28.5, retro: true),
    Planet('lilith', 293.0),
    Planet('chiron', 290.0, retro: true),
  ];
  final aspects = const [
    ('sun', 'neptune', 'pink'),
    ('moon', 'venus', 'purple'),
    ('mars', 'uranus', 'pink'),
    ('venus', 'pluto', 'purple'),
    ('mercury', 'neptune', 'pink'),
    ('moon', 'saturn', 'purple'),
  ];

  bool transit = false;
  void toggleTransit() {
    transit = !transit;
    notifyListeners();
  }

  void updateProfile(String name, DateTime b, String t, String p) {
    profile
      ..name = name
      ..birth = b
      ..time = t
      ..place = p;
    notifyListeners();
  }

  void useGift() {
    if (giftsLeft > 0) giftsLeft--;
    notifyListeners();
  }
}

final app = AppData();

const trMonths = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos',
  'Eylül', 'Ekim', 'Kasım', 'Aralık'
];
const trDays = [
  'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
];

String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
