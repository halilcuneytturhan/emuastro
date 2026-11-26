import 'dart:math' as math;

import 'ephemeris.dart';
import 'places.dart';
import '../l10n.dart';

const _signsTr = [
  'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep',
  'Yay', 'Oğlak', 'Kova', 'Balık'
];
const _signLocTr = [
  'Koç’ta', 'Boğa’da', 'İkizler’de', 'Yengeç’te', 'Aslan’da', 'Başak’ta',
  'Terazi’de', 'Akrep’te', 'Yay’da', 'Oğlak’ta', 'Kova’da', 'Balık’ta'
];
const _signToTr = [
  'Koç’a', 'Boğa’ya', 'İkizler’e', 'Yengeç’e', 'Aslan’a', 'Başak’a',
  'Terazi’ye', 'Akrep’e', 'Yay’a', 'Oğlak’a', 'Kova’ya', 'Balık’a'
];
const _planetNameTr = {
  'sun': 'Güneş', 'moon': 'Ay', 'mercury': 'Merkür', 'venus': 'Venüs',
  'mars': 'Mars', 'jupiter': 'Jüpiter', 'saturn': 'Satürn',
  'uranus': 'Uranüs', 'neptune': 'Neptün', 'pluto': 'Plüton',
  'node': 'Kuzey Ay Düğümü', 'lilith': 'Lilith', 'asc': 'Yükselen'
};
const _genTr = {
  'sun': 'Güneş’in', 'moon': 'Ay’ın', 'mercury': 'Merkür’ün',
  'venus': 'Venüs’ün', 'mars': 'Mars’ın', 'jupiter': 'Jüpiter’in',
  'saturn': 'Satürn’ün', 'uranus': 'Uranüs’ün', 'neptune': 'Neptün’ün',
  'pluto': 'Plüton’un'
};
const _withTr = {
  'sun': 'Güneş’le', 'moon': 'Ay’la', 'mercury': 'Merkür’le',
  'venus': 'Venüs’le', 'mars': 'Mars’la', 'jupiter': 'Jüpiter’le',
  'saturn': 'Satürn’le', 'uranus': 'Uranüs’le', 'neptune': 'Neptün’le',
  'pluto': 'Plüton’la', 'asc': 'Yükselen’le'
};
const _aspNounTr = {
  'kavuşum': 'kavuşumu', 'altmışlık': 'altmışlığı', 'kare': 'karesi',
  'üçgen': 'üçgeni', 'karşıtlık': 'karşıtlığı'
};

/// Burç nitelikleri (mizaç cümleleri için)
const _signTraitTr = [
  'cesur, hızlı karar veren ve ilk adımı atmayı seven',
  'sakin, sadık ve güzelliğe, konfora değer veren',
  'meraklı, konuşkan ve birçok konuyla aynı anda ilgilenen',
  'şefkatli, korumacı ve duygusal bağlara önem veren',
  'sıcak, cömert ve görünür olmaktan çekinmeyen',
  'dikkatli, düzenli ve ayrıntıda mükemmeli arayan',
  'uyumlu, zarif ve ilişkilerde denge kuran',
  'derin, tutkulu ve sezgileri güçlü',
  'iyimser, özgür ruhlu ve anlam arayan',
  'disiplinli, sabırlı ve uzun vadeli düşünen',
  'özgün, bağımsız ve geleceğe bakan',
  'hayalci, empatik ve sezgisiyle hareket eden',
];
const _signLoveTr = [
  'heyecanı ve açık sözlülüğü', 'güveni ve fiziksel yakınlığı',
  'zekâ oyunlarını ve sohbeti', 'koruyucu sıcaklığı ve aidiyeti',
  'hayranlığı ve cömert jestleri', 'küçük ama düzenli ilgiyi',
  'nezaketi ve estetik paylaşımı', 'derin bağlılığı ve sırları',
  'macerayı ve özgür alanı', 'sözünün eri olmayı',
  'arkadaşlıkla başlayan aşkı', 'romantizmi ve ruhsal yakınlığı',
];
const _signWorkTr = [
  'girişimcilik ve liderlik gerektiren', 'emeğin somut karşılığını veren',
  'iletişim, yazı ve ticaret odaklı', 'insanlara bakım ve güven veren',
  'sahne, yaratıcılık ve yönetim içeren', 'analiz, sağlık ve hizmet odaklı',
  'diplomasi, tasarım ve hukuk içeren', 'araştırma, finans ve dönüşüm odaklı',
  'eğitim, yayıncılık ve yurt dışı bağlantılı', 'yapı kuran, kurumsal ve kalıcı',
  'teknoloji, topluluk ve yenilik odaklı', 'sanat, şifa ve hayal gücü isteyen',
];

// ---------------- İNGİLİZCE TABLOLAR ----------------
const _signsEn = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
const _planetNameEn = {
  'sun': 'Sun', 'moon': 'Moon', 'mercury': 'Mercury', 'venus': 'Venus', 'mars': 'Mars',
  'jupiter': 'Jupiter', 'saturn': 'Saturn', 'uranus': 'Uranus', 'neptune': 'Neptune',
  'pluto': 'Pluto', 'node': 'North Node', 'lilith': 'Lilith', 'asc': 'Ascendant'
};
const _aspEn = {'kavuşum': 'conjunct', 'altmışlık': 'sextile', 'kare': 'square', 'üçgen': 'trine', 'karşıtlık': 'opposite'};
const _signTraitEn = [
  'brave, quick to decide and eager to make the first move',
  'calm, loyal and devoted to beauty and comfort',
  'curious, talkative and interested in many things at once',
  'caring, protective and devoted to emotional bonds',
  'warm, generous and unafraid to be seen',
  'careful, organised and perfectionist in the details',
  'harmonious, graceful and a natural balancer in relationships',
  'deep, passionate and highly intuitive',
  'optimistic, free-spirited and searching for meaning',
  'disciplined, patient and focused on the long term',
  'original, independent and future-oriented',
  'dreamy, empathetic and guided by intuition',
];
const _signLoveEn = [
  'excitement and honesty', 'trust and physical closeness', 'wit and conversation',
  'protective warmth and belonging', 'admiration and generous gestures',
  'small but steady attention', 'kindness and shared beauty', 'deep loyalty and secrets',
  'adventure and personal space', 'keeping one’s word', 'love that begins as friendship',
  'romance and spiritual closeness',
];
const _signWorkEn = [
  'entrepreneurial and leadership-driven', 'tangible, rewarding', 'communication, writing and trade',
  'caring and trust-building', 'creative, stage and management', 'analytical, health and service',
  'diplomacy, design and law', 'research, finance and transformation', 'education, publishing and international',
  'structured, corporate and lasting', 'technology, community and innovation', 'art, healing and imagination',
];
const _neverEn = {
  'sun': 'Don’t get into an open power struggle with authority',
  'moon': 'Don’t bottle up your feelings only to explode later',
  'mercury': 'Don’t sign anything without reading it first',
  'venus': 'Don’t give up your boundaries just to be liked',
  'mars': 'Don’t turn an evening conversation into a power struggle with sharp words',
  'jupiter': 'Don’t make promises beyond your capacity',
  'saturn': 'Don’t leave responsibilities to the last minute',
  'pluto': 'Don’t corner others out of fear of losing control',
  'asc': 'Don’t pretend to be someone else for a first impression',
};
const _neverWhyEn = {
  'pluto': 'may intensify the urge to control', 'saturn': 'may increase pressure and fatigue',
  'mars': 'may fuel impatience and anger', 'uranus': 'may trigger sudden, rash reactions',
  'neptune': 'may increase confusion and misunderstanding', 'moon': 'may amplify emotional reactions',
  'sun': 'may set egos against each other', 'mercury': 'may lead to misunderstandings',
  'venus': 'may push expectations away from reality', 'jupiter': 'may push you towards excess and over-optimism',
};
const _doItEn = {
  'sun': 'Around noon take a step that makes you visible; say your idea out loud.',
  'moon': 'Early in the morning arrange a short meet-up with someone who feels good to be around.',
  'mercury': 'Early in the morning move an application, study plan or long-distance matter to its next visible step.',
  'venus': 'Send the thank-you or compliment you have been postponing; relationships are soft today.',
  'mars': 'Your energy is high: start the tough workout or task you have been putting off.',
  'jupiter': 'Think big; reach out about an opportunity or share a new plan.',
  'saturn': 'Make a concrete schedule for a long-term goal.',
  'pluto': 'Make a clear decision today to drop a habit that drains you.',
  'asc': 'Try a small change in your look; your energy is showing.',
};
const _houseTopicEn = ['', 'self-image and new beginnings', 'money and self-worth', 'communication and learning',
  'home and family', 'love and creativity', 'daily routine and health', 'relationships and partnerships',
  'shared resources and transformation', 'travel, education and publishing', 'career and visibility',
  'friends and community', 'inner world and rest'];
const _reportSectionsEn = ['Temperament', 'Emotional world', 'Shadow side', 'Love language', 'Career code',
  'Communication', 'Money', 'Family', 'Friendship', 'Creativity', 'Health routines', 'Transformation',
  'Journeys', 'Society', 'Spiritual path'];

List<String> get signs => L.en ? _signsEn : _signsTr;
List<String> get signLoc => L.en ? [for (final x in _signsEn) 'in $x'] : _signLocTr;
List<String> get signTo => L.en ? [for (final x in _signsEn) 'into $x'] : _signToTr;
Map<String, String> get planetName => L.en ? _planetNameEn : _planetNameTr;
List<String> get signTrait => L.en ? _signTraitEn : _signTraitTr;
List<String> get signLove => L.en ? _signLoveEn : _signLoveTr;
List<String> get signWork => L.en ? _signWorkEn : _signWorkTr;
List<String> get reportSections => L.en ? _reportSectionsEn : _reportSectionsTr;
List<(String, List<String>, List<String>)> get scoreCats => L.en
    ? [for (final (i, c) in _scoreCatsTr.indexed) ((['Luck & flow', 'Mind & focus', 'Energy & body'])[i], c.$2, c.$3)]
    : _scoreCatsTr;
String aspName(String a) => L.en ? (_aspEn[a] ?? a) : a;

class BirthData {
  final String name;
  final DateTime local;
  final bool timeKnown;
  final String place;
  const BirthData(this.name, this.local, this.place, {this.timeKnown = true});
  Map<String, dynamic> toJson() => {
        'name': name,
        'local': local.toIso8601String(),
        'place': place,
        'timeKnown': timeKnown
      };
  factory BirthData.fromJson(Map<String, dynamic> j) => BirthData(
      j['name'] as String, DateTime.parse(j['local'] as String),
      j['place'] as String,
      timeKnown: j['timeKnown'] as bool? ?? true);
}

class Chart {
  final BirthData data;
  final List<PlanetPos> planets;
  final double asc, mc;
  Chart._(this.data, this.planets, this.asc, this.mc);

  factory Chart.of(BirthData b) {
    final p = findPlace(b.place) ?? places.first;
    final local = b.timeKnown
        ? b.local
        : DateTime(b.local.year, b.local.month, b.local.day, 12);
    final utc = toUtc(local, p);
    final (a, m) = angles(utc, p.lat, p.lon);
    return Chart._(b, positions(utc), a, m);
  }

  PlanetPos p(String id) => planets.firstWhere((e) => e.id == id);
  int sign(String id) => id == 'asc' ? (asc / 30).floor() : p(id).sign;
  String signName(String id) => signs[sign(id)];

  /// Eşit ev sistemi: boylamın evi (1-12)
  int house(double lon) => (((lon - asc) % 360 + 360) % 360 ~/ 30) + 1;

  List<(String, String, String)> aspects() {
    const ids = ['sun', 'moon', 'mercury', 'venus', 'mars', 'jupiter',
      'saturn', 'uranus', 'neptune', 'pluto'];
    final out = <(String, String, String)>[];
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = aspectBetween(p(ids[i]).lon, p(ids[j]).lon, orbScale: .8);
        if (a != null) out.add((ids[i], ids[j], a.$1));
      }
    }
    return out;
  }
}

String aspectPhrase(String transit, String natal, String asp) => L.en
    ? '${_planetNameEn[transit]} ${_aspEn[asp]} your ${_planetNameEn[natal]}'
    : '${_genTr[transit] ?? planetName[transit]} ${_withTr[natal] ?? planetName[natal]} ${_aspNounTr[asp]}';

bool _hard(String a) => a == 'kare' || a == 'karşıtlık';

// ---------------- GÜNLÜK ----------------

class Hit {
  final String transit, natal, asp;
  final double orb;
  Hit(this.transit, this.natal, this.asp, this.orb);
}

List<Hit> transitHits(Chart natal, DateTime when, {List<String>? only}) {
  final tr = positions(when.toUtc());
  const nat = ['sun', 'moon', 'mercury', 'venus', 'mars', 'jupiter', 'saturn',
    'pluto', 'asc'];
  final hits = <Hit>[];
  for (final t in tr) {
    if (t.id == 'node' || t.id == 'lilith') continue;
    if (only != null && !only.contains(t.id)) continue;
    for (final n in nat) {
      if (n == t.id && t.id != 'moon') continue;
      final lon = n == 'asc' ? natal.asc : natal.p(n).lon;
      final a = aspectBetween(t.lon, lon, orbScale: t.id == 'moon' ? .9 : .6);
      if (a != null) hits.add(Hit(t.id, n, a.$1, a.$2));
    }
  }
  hits.sort((a, b) => a.orb.compareTo(b.orb));
  return hits;
}

const _scoreCatsTr = [
  ('Şans ve akış', ['jupiter', 'venus', 'sun'], ['sun', 'jupiter', 'venus', 'asc']),
  ('Zihin ve odak', ['mercury', 'moon', 'saturn'], ['mercury', 'moon', 'saturn']),
  ('Enerji ve beden', ['mars', 'sun', 'moon'], ['mars', 'sun', 'asc']),
];

int dailyScore(Chart natal, DateTime day, int cat) {
  final (_, trs, nats) = scoreCats[cat];
  var s = 52.0;
  for (final h in transitHits(natal, DateTime(day.year, day.month, day.day, 12))) {
    if (!trs.contains(h.transit) && !nats.contains(h.natal)) continue;
    final w = (h.transit == 'moon' ? 7 : 11) * (1 - h.orb / 9);
    s += switch (h.asp) {
      'üçgen' => w * 1.2,
      'altmışlık' => w,
      'kavuşum' => (h.transit == 'saturn' || h.transit == 'pluto') ? -w : w * .8,
      _ => -w,
    };
  }
  return s.round().clamp(8, 96);
}

String scoreLabel(int v) => L.en
    ? (v >= 75 ? 'Very strong' : v >= 58 ? 'Strong' : v >= 45 ? 'Balanced' : v >= 32 ? 'Sensitive' : 'Challenging')
    : v >= 75
    ? 'Çok güçlü'
    : v >= 58
        ? 'Güçlü'
        : v >= 45
            ? 'Dengeli'
            : v >= 32
                ? 'Hassas'
                : 'Zorlu';

const _neverTr = {
  'sun': 'otoriteyle açık bir güç gösterisine girme',
  'moon': 'duygularını bastırıp sonra bir anda patlama',
  'mercury': 'imzalayacağın metni okumadan onaylama',
  'venus': 'beğenilmek için kendi sınırlarından taviz verme',
  'mars': 'Akşama doğru bir konuşmayı güç savaşına çevirecek keskin cümleler kurma',
  'jupiter': 'gücünü aşan bir söz verme',
  'saturn': 'sorumluluğu son ana bırakma',
  'pluto': 'kontrolü kaybetme korkusuyla karşındakini sıkıştırma',
  'asc': 'ilk izlenim için kendini olduğundan farklı gösterme',
};
const _neverWhyTr = {
  'pluto': 'kontrol etme isteğini artırabilir',
  'saturn': 'baskı ve yorgunluk hissini artırabilir',
  'mars': 'sabırsızlığı ve öfkeyi körükleyebilir',
  'uranus': 'ani ve düşünülmemiş tepkileri tetikleyebilir',
  'neptune': 'kafa karışıklığını ve yanlış anlaşılmayı artırabilir',
  'moon': 'duygusal tepkileri büyütebilir',
  'sun': 'egoları karşı karşıya getirebilir',
  'mercury': 'yanlış anlaşılmaya açık bir gün yaratabilir',
  'venus': 'beklentileri gerçekçi olmaktan uzaklaştırabilir',
  'jupiter': 'abartıya ve aşırı iyimserliğe itebilir',
};
const _doItTr = {
  'sun': 'Öğlen saatlerinde kendini görünür kılacak bir adım at; fikrini yüksek sesle söyle.',
  'moon': 'Sabah erken duygusal olarak iyi geldiğin biriyle kısa bir buluşma ayarla.',
  'mercury': 'Sabah erken bir başvuru, eğitim planı ya da uzaklarla ilgili işi görünür bir sonraki adıma taşı.',
  'venus': 'Gün içinde ertelediğin bir teşekkürü ya da iltifatı ilet; ilişkiler bugün yumuşak.',
  'mars': 'Enerjin yüksek: zor bir antrenmanı ya da uzun süredir başlamadığın işi bugün başlat.',
  'jupiter': 'Büyük düşün; bir fırsat için iletişime geç ya da yeni bir planı paylaş.',
  'saturn': 'Uzun vadeli bir hedef için somut bir takvim oluştur.',
  'pluto': 'Seni yoran bir alışkanlığı bırakmak için bugün net bir karar ver.',
  'asc': 'Görünüşünde küçük bir yenilik yap; enerjin dışarıya yansıyor.',
};

class Daily {
  final String never, todo, watch, reminder, period;
  final List<int> scores;
  final List<List<double>> trends;
  final List<String> tips;
  Daily(this.never, this.todo, this.watch, this.reminder, this.period,
      this.scores, this.trends, this.tips);
}

Daily daily(Chart natal, DateTime day) {
  if (L.en) return _dailyEn(natal, day);
  final noon = DateTime(day.year, day.month, day.day, 12);
  final hits = transitHits(natal, noon);
  final hard = hits.where((h) => _hard(h.asp)).toList();
  final soft = hits.where((h) => !_hard(h.asp) && h.asp != 'kavuşum').toList();
  String never;
  if (hard.isNotEmpty) {
    final h = hard.first;
    never =
        '${_cap(_neverTr[h.natal] ?? _neverTr['mars']!)}, çünkü ${aspectPhrase(h.transit, h.natal, h.asp)} ${_neverWhyTr[h.transit] ?? 'gerilimi artırabilir'}.';
  } else {
    never = 'Bugün planlarını son dakikada değiştirip başkalarını belirsizlikte bırakma; gün sakin ama ritim önemli.';
  }
  final todo = soft.isNotEmpty
      ? _doItTr[soft.first.natal] ?? _doItTr['mercury']!
      : _doItTr['mercury']!;
  final watch = hard.length > 1
      ? 'Öğleden sonra ${aspectPhrase(hard[1].transit, hard[1].natal, hard[1].asp)} etkili; aceleyle verilen sözler sonradan yük olabilir.'
      : 'Öğleden sonra aceleyle verilen sözler sonradan yük olabilir; takvimini kontrol etmeden onay verme.';
  final moon = positions(noon.toUtc()).firstWhere((p) => p.id == 'moon');
  final reminder =
      'Ay bugün ${signLoc[moon.sign]}: ${signTrait[moon.sign].split(',').first} bir ruh hâli öne çıkıyor. Küçük bir rutini tamamlamak sana güven verecek.';
  final sun = positions(noon.toUtc()).firstWhere((p) => p.id == 'sun');
  final house = natal.house(sun.lon);
  const houseTopic = [
    '', 'kişisel imaj ve yeni başlangıçlar', 'para ve öz değer',
    'iletişim ve öğrenme', 'ev ve aile', 'aşk ve yaratıcılık',
    'günlük rutin ve sağlık', 'ilişkiler ve ortaklıklar',
    'ortak kaynaklar ve dönüşüm', 'yolculuk, eğitim ve yayın',
    'kariyer ve görünürlük', 'arkadaşlar ve topluluk', 'iç dünya ve dinlenme'
  ];
  final period =
      'Güneş ${signLoc[sun.sign]} ve haritanın $house. evinde: ${houseTopic[house]} konuları bu dönem öne çıkıyor.';
  final scores = [for (var c = 0; c < 3; c++) dailyScore(natal, day, c)];
  final trends = [
    for (var c = 0; c < 3; c++)
      [
        for (var k = 6; k >= 0; k--)
          dailyScore(natal, day.subtract(Duration(days: k)), c) / 100.0
      ]
  ];
  final tips = <String>[
    if (soft.isNotEmpty)
      'Bugün ${aspectPhrase(soft.first.transit, soft.first.natal, soft.first.asp)} destekleyici: ${_doItTr[soft.first.natal] ?? ''}',
    'Ay ${signLoc[moon.sign]}; ${signLove[moon.sign]} hatırlatan küçük bir jest gününü güzelleştirir.',
    'Akşam kısa bir yürüyüş, günün gerginliğini dengeler.',
    'Bugünün rengi: ${const ['kırmızı', 'yeşil', 'sarı', 'gümüş', 'altın', 'lacivert', 'pembe', 'mürdüm', 'mor', 'kahverengi', 'turkuaz', 'deniz mavisi'][moon.sign]}.',
  ];
  return Daily(never, todo, watch, reminder, period, scores, trends, tips);
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ---------------- GÖKYÜZÜ OLAYLARI ----------------

class SkyEvent {
  final String key, kicker, title, kind, body;
  final DateTime date;
  const SkyEvent(this.key, this.date, this.kicker, this.title, this.kind,
      this.body);
  String get sub => L.en ? 'What does it mean for you?' : 'Senin için ne anlama geliyor?';
}

const _months = [
  'OCAK', 'ŞUBAT', 'MART', 'NİSAN', 'MAYIS', 'HAZİRAN', 'TEMMUZ', 'AĞUSTOS',
  'EYLÜL', 'EKİM', 'KASIM', 'ARALIK'
];

double _lonAt(String id, DateTime t) => geoLongitude(id, dayNumber(t.toUtc()));

List<SkyEvent> skyEvents(Chart natal, DateTime today) {
  final en = L.en;
  final ev = <SkyEvent>[];
  final base = DateTime.utc(today.year, today.month, today.day, 12);
  // 1) En yakın Güneş burç geçişi (son 25 gün / gelecek 10 gün)
  for (var k = -25; k <= 10; k++) {
    final a = base.add(Duration(days: k)), b = base.add(Duration(days: k + 1));
    final sa = _lonAt('sun', a) ~/ 30, sb = _lonAt('sun', b) ~/ 30;
    if (sa != sb) {
      final h = natal.house(sb * 30.0);
      ev.add(SkyEvent('ingress-${b.year}-$sb', b,
          en ? '${_mEn[b.month - 1]} ${b.day} · SIGN CHANGE' : '${b.day} ${_months[b.month - 1]} · BURÇ GEÇİŞİ', en ? 'Sun enters ${_signsEn[sb]}' : 'Güneş ${signTo[sb]} geçiyor', 'sun',
          en ? 'The Sun moving into ${_signsEn[sb]} lights up your ${_ord(h)} house. For the next four weeks your visibility and energy grow in this area.' : 'Güneş’in ${signTo[sb]} geçişi haritanın $h. evini aydınlatıyor. Bu dört hafta boyunca bu alanda görünürlüğün ve enerjin artıyor.'));
    }
  }
  // 2) En yakın dolunay / yeniay (±15 gün)
  DateTime? best;
  String? kind;
  var bestK = 99;
  for (var k = -15; k <= 15; k++) {
    final t = base.add(Duration(days: k));
    final e = (_lonAt('moon', t) - _lonAt('sun', t) + 360) % 360;
    final e2 = (_lonAt('moon', t.add(const Duration(days: 1))) -
            _lonAt('sun', t.add(const Duration(days: 1))) + 360) % 360;
    if (e < 180 && e2 >= 180 && k.abs() < bestK) {
      best = t;
      kind = 'full';
      bestK = k.abs();
    }
    if (e > 300 && e2 < 60 && k.abs() < bestK) {
      best = t;
      kind = 'new';
      bestK = k.abs();
    }
  }
  if (best != null) {
    final ms = _lonAt('moon', best.add(const Duration(hours: 12))) ~/ 30;
    final full = kind == 'full';
    final h = natal.house(ms * 30.0 + 15);
    ev.add(SkyEvent('lunation-${best.year}-${best.month}-${best.day}', best,
        en ? '${_mEn[best.month - 1]} ${best.day} · ${full ? 'FULL MOON' : 'NEW MOON'}' : '${best.day} ${_months[best.month - 1]} · ${full ? 'DOLUNAY' : 'YENİAY'}',
        en ? '${full ? 'Full' : 'New'} Moon in ${_signsEn[ms]}' : '${signs[ms]} ${full ? 'Dolunayı' : 'Yeniayı'}', 'moon',
        en
            ? (full
                ? 'The Full Moon in ${_signsEn[ms]} completes a cycle in your ${_ord(h)} house. Efforts here may bear fruit; you may notice what to let go of.'
                : 'The New Moon in ${_signsEn[ms]} plants a seed of a new beginning in your ${_ord(h)} house. A good time to set intentions.')
            : full
            ? '${signs[ms]} Dolunayı haritanın $h. evinde bir döngüyü tamamlıyor. Bu alandaki emeklerin sonuç verebilir; bırakman gerekenleri fark edebilirsin.'
            : '${signs[ms]} Yeniayı haritanın $h. evinde yeni bir başlangıç tohumu ekiyor. Niyet koymak için uygun bir zaman.'));
  }
  // 3) Yavaş gezegen duruşu (retro başlangıç/bitiş) — 90 gün içinde
  for (final id in ['mercury', 'venus', 'mars', 'jupiter', 'saturn']) {
    double prev = 0;
    for (var k = -2; k <= 90; k++) {
      final t = base.add(Duration(days: k));
      var d = _lonAt(id, t.add(const Duration(days: 1))) - _lonAt(id, t);
      if (d > 180) d -= 360;
      if (d < -180) d += 360;
      if (k > -2 && prev != 0 && d.sign != prev.sign) {
        final ending = d > 0;
        ev.add(SkyEvent('station-$id-${t.year}-${t.month}-${t.day}', t,
            en ? '${_mEn[t.month - 1]} ${t.day} · RETROGRADE ${ending ? 'ENDS' : 'BEGINS'}' : '${t.day} ${_months[t.month - 1]} · RETRO ${ending ? 'BİTİYOR' : 'BAŞLIYOR'}',
            en ? '${_planetNameEn[id]} Retrograde' : '${planetName[id]} Retrosu', id == 'saturn' ? 'saturn' : 'moon',
            en
                ? (ending
                    ? '${_planetNameEn[id]} turns direct and postponed matters become clear; you can speed up things in your ${_ord(natal.house(_lonAt(id, t)))} house again.'
                    : '${_planetNameEn[id]} turns retrograde; a review period for matters of your ${_ord(natal.house(_lonAt(id, t)))} house.')
                : ending
                ? '${planetName[id]} düz harekete dönerken ertelenen konular netleşiyor; ${natal.house(_lonAt(id, t))}. evindeki işleri yeniden hızlandırabilirsin.'
                : '${planetName[id]} geri harekete başlıyor; ${natal.house(_lonAt(id, t))}. evinle ilgili konularda gözden geçirme dönemi.'));
        break;
      }
      prev = d;
    }
    if (ev.length >= 3) break;
  }
  ev.sort((a, b) => a.date.compareTo(b.date));
  return ev.take(3).toList();
}

// ---------------- RAPOR ----------------

const _reportSectionsTr = [
  'Mizaç', 'Duygusal dünya', 'Gölge yönler', 'Aşk dili', 'Kariyer kodu',
  'İletişim', 'Para', 'Aile', 'Arkadaşlık', 'Yaratıcılık', 'Sağlık rutinleri',
  'Dönüşüm', 'Yolculuklar', 'Toplum', 'Ruhsal yol'
];

String reportText(Chart c, int i) {
  if (L.en) return _reportTextEn(c, i);
  String s(String id) => signLoc[c.sign(id)];
  String t(String id) => signTrait[c.sign(id)];
  int h(String id) => c.house(c.p(id).lon);
  switch (i) {
    case 0:
      return 'Güneş ${s('sun')}: özünde ${t('sun')} birisin. Yükselen ${c.signName('asc')} ise dünyaya ${t('asc')} bir yüz gösteriyor. İlk izlenimin ile iç dünyan arasındaki fark, insanların seni tanıdıkça şaşırmasına neden olabilir.';
    case 1:
      return 'Ay ${s('moon')}: duygusal olarak ${t('moon')} bir yapın var. Güvende hissetmek için ${signLove[c.sign('moon')]} önemsiyorsun.';
    case 2:
      return 'Plüton ${s('pluto')} ve ${h('pluto')}. evde: bu alanda kontrolü bırakmak sana zor gelebilir. Satürn ${s('saturn')} ise ${h('saturn')}. ev konularında kendine fazla yüklenebileceğini gösteriyor.';
    case 3:
      return 'Venüs ${s('venus')}: aşkta ${signLove[c.sign('venus')]} istiyorsun. Mars ${s('mars')} ise arzularını ${t('mars')} bir tarzla ifade ettiğini söylüyor.';
    case 4:
      return 'MC ${signLoc[(c.mc / 30).floor()]}: ${signWork[(c.mc / 30).floor()]} işlerde parlıyorsun. Güneş’in ${h('sun')}. evde olması emeğinin bu alanda görünür olmasını istiyor.';
    case 5:
      return 'Merkür ${s('mercury')}: ${t('mercury')} bir zihin. Fikirlerini ${c.sign('mercury') % 3 == 0 ? 'doğrudan ve hızlı' : c.sign('mercury') % 3 == 1 ? 'sağlam ve planlı' : 'esnek ve çok yönlü'} biçimde aktarıyorsun.';
    case 6:
      return 'Venüs ${h('venus')}. evde, Jüpiter ${s('jupiter')}: kaynaklarını ${signWork[c.sign('jupiter')]} alanlarda büyütme şansın yüksek.';
    case 7:
      return 'Ay ${h('moon')}. evde: aile ve yuva konularında ${signLove[c.sign('moon')]} arıyorsun.';
    case 8:
      return 'Jüpiter ${h('jupiter')}. evde ve ${s('jupiter')}: çevrende ${t('jupiter')} insanlar sana şans getiriyor.';
    case 9:
      return 'Güneş ve Venüs etkileşimi yaratıcılığını ${signTrait[c.sign('venus')]} bir tarza yönlendiriyor.';
    case 10:
      return 'Mars ${h('mars')}. evde: bedenin ${c.sign('mars') % 4 == 0 ? 'yoğun ve kısa' : c.sign('mars') % 4 == 1 ? 'düzenli ve dayanıklılık odaklı' : c.sign('mars') % 4 == 2 ? 'çeşitli ve sosyal' : 'sakin ve akışkan'} hareketi seviyor.';
    case 11:
      return 'Plüton ve Satürn birlikte hayatının dönüm noktalarını ${s('pluto')} temalarıyla şekillendiriyor.';
    case 12:
      return 'Jüpiter ve 9. ev: uzak yerler sende ${c.house(c.p('jupiter').lon) == 9 ? 'çok güçlü' : 'zaman zaman uyanan'} bir merak uyandırıyor.';
    case 13:
      return 'Uranüs ${s('uranus')}: kuşağınla birlikte ${t('uranus')} bir değişimin parçasısın.';
    default:
      return 'Kuzey Ay Düğümü ${s('node')}: ruhsal yolun seni ${t('node')} bir insana dönüşmeye çağırıyor.';
  }
}

// ---------------- UYUM ----------------

(int, List<String>) synastry(Chart a, Chart b) {
  var s = 50.0;
  final notes = <String>[];
  const pairs = [('sun', 'moon'), ('moon', 'sun'), ('venus', 'mars'),
    ('mars', 'venus'), ('moon', 'moon'), ('venus', 'venus'), ('sun', 'sun'),
    ('mercury', 'mercury'), ('saturn', 'sun'), ('saturn', 'moon')];
  for (final (x, y) in pairs) {
    final asp = aspectBetween(a.p(x).lon, b.p(y).lon);
    if (asp == null) continue;
    final good = !_hard(asp.$1);
    final w = x == 'saturn' ? 4.0 : 7.0;
    s += good ? w : -w * .7;
    notes.add('${a.data.name} ${planetName[x]} – ${b.data.name} ${planetName[y]}: ${aspName(asp.$1)} (${L.en ? (good ? 'harmonious' : 'challenging') : (good ? 'uyumlu' : 'zorlayıcı')})');
  }
  final el = (a.sign('sun') % 4) == (b.sign('sun') % 4) ? 6 : 0;
  s += el;
  return (s.round().clamp(10, 98), notes);
}

// ---------------- HARİTA İKİZLERİ ----------------

class Celebrity {
  final String name, job, place;
  final DateTime date;
  final String pal;
  const Celebrity(this.name, this.job, this.date, this.place, this.pal);
}

final celebrities = <Celebrity>[
  Celebrity('Beyoncé', 'Müzisyen', DateTime(1981, 9, 4, 12), 'Houston, ABD', 'rose'),
  Celebrity('Fiona Apple', 'Müzisyen', DateTime(1977, 9, 13, 12), 'New York, ABD', 'amber'),
  Celebrity('Frida Kahlo', 'Ressam', DateTime(1907, 7, 6, 12), 'İstanbul, Türkiye', 'navy'),
  Celebrity('Barış Manço', 'Müzisyen', DateTime(1943, 1, 2, 12), 'İstanbul, Türkiye', 'deepGreen'),
  Celebrity('Sezen Aksu', 'Müzisyen', DateTime(1954, 7, 13, 12), 'Denizli, Türkiye', 'rose'),
  Celebrity('Orhan Pamuk', 'Yazar', DateTime(1952, 6, 7, 12), 'İstanbul, Türkiye', 'navy'),
  Celebrity('Tarkan', 'Müzisyen', DateTime(1972, 10, 17, 12), 'Köln, Almanya', 'amber'),
  Celebrity('Madonna', 'Müzisyen', DateTime(1958, 8, 16, 12), 'New York, ABD', 'rose'),
  Celebrity('Virginia Woolf', 'Yazar', DateTime(1882, 1, 25, 12), 'Londra, Birleşik Krallık', 'deepGreen'),
  Celebrity('Taylor Swift', 'Müzisyen', DateTime(1989, 12, 13, 12), 'New York, ABD', 'amber'),
  Celebrity('Nazım Hikmet', 'Şair', DateTime(1902, 1, 15, 12), 'İstanbul, Türkiye', 'navy'),
  Celebrity('Zeki Müren', 'Müzisyen', DateTime(1931, 12, 6, 12), 'Bursa, Türkiye', 'deepGreen'),
  Celebrity('Lady Gaga', 'Müzisyen', DateTime(1986, 3, 28, 12), 'New York, ABD', 'rose'),
  Celebrity('Albert Einstein', 'Bilim insanı', DateTime(1879, 3, 14, 12), 'Münih, Almanya', 'navy'),
];

class TwinMatch {
  final Celebrity c;
  final int pct;
  final String common;
  TwinMatch(this.c, this.pct, this.common);
}

List<TwinMatch> twins(Chart me) {
  final out = <TwinMatch>[];
  for (final c in celebrities) {
    final ch = Chart.of(BirthData(c.name, c.date, c.place, timeKnown: false));
    var s = 30.0;
    final common = <String>[];
    for (final (id, w) in [('sun', 14.0), ('moon', 12.0), ('venus', 9.0),
      ('mars', 7.0), ('mercury', 6.0)]) {
      if (ch.sign(id) == me.sign(id)) {
        s += w;
        common.add('${planetName[id]} ${signs[me.sign(id)]}');
      } else if (ch.sign(id) % 4 == me.sign(id) % 4) {
        s += w / 3;
      }
    }
    final myVN = aspectBetween(me.p('venus').lon, me.p('neptune').lon);
    final cVN = aspectBetween(ch.p('venus').lon, ch.p('neptune').lon);
    if (myVN != null && cVN != null) {
      s += 8;
      common.add(L.en ? 'Shared Venus–Neptune aspect' : 'Venüs–Neptün açısı ortak');
    }
    out.add(TwinMatch(c, s.round().clamp(20, 97),
        common.isEmpty ? (L.en ? 'Similar element balance' : 'Element dengesi benzer') : common.take(2).join(' · ')));
  }
  out.sort((a, b) => b.pct.compareTo(a.pct));
  return out.take(6).toList();
}

// ---------------- SOHBET ----------------

String answer(Chart c, String q, DateTime now) {
  if (L.en) return _answerEn(c, q, now);
  final s = q.toLowerCase();
  final d = daily(c, now);
  final hits = transitHits(c, now);
  String top() => hits.isEmpty
      ? 'Bugün haritana dokunan güçlü bir transit yok; sakin bir gün.'
      : 'Şu an en güçlü etki: ${aspectPhrase(hits.first.transit, hits.first.natal, hits.first.asp)}.';
  if (s.contains('aşk') || s.contains('sevgili') || s.contains('ilişki') || s.contains('partner')) {
    return 'Venüs’ün ${signLoc[c.sign('venus')]}: ilişkide ${signLove[c.sign('venus')]} arıyorsun. ${top()} Bugün için öneri: ${d.todo}';
  }
  if (s.contains('iş') || s.contains('kariyer') || s.contains('mülakat') || s.contains('görüşme')) {
    final best = <(int, int)>[];
    for (var k = 0; k < 7; k++) {
      best.add((k, dailyScore(c, now.add(Duration(days: k)), 1)));
    }
    best.sort((a, b) => b.$2.compareTo(a.$2));
    final day = now.add(Duration(days: best.first.$1));
    const g = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return 'Önümüzdeki 7 gün içinde zihin ve odak skorun en yüksek ${g[day.weekday - 1]} (${day.day}.${day.month}) günü: %${best.first.$2}. MC ${signLoc[(c.mc / 30).floor()]} olduğu için ${signWork[(c.mc / 30).floor()]} işlerde öne çık.';
  }
  if (s.contains('para') || s.contains('maaş') || s.contains('yatırım')) {
    return '${reportText(c, 6)} ${top()} Not: Bu bir finansal tavsiye değildir.';
  }
  if (s.contains('sağlık') || s.contains('spor') || s.contains('enerji')) {
    return '${reportText(c, 10)} Bugünkü enerji skorun %${d.scores[2]}. Bu bir tıbbi tavsiye değildir.';
  }
  if (s.contains('bugün') || s.contains('gün')) {
    return '${top()} Bugün yap: ${d.todo} Kaçın: ${d.never}';
  }
  if (s.contains('burç') || s.contains('yükselen') || s.contains('ay ')) {
    return 'Güneş ${c.signName('sun')}, Ay ${c.signName('moon')}, Yükselen ${c.signName('asc')}. ${reportText(c, 0)}';
  }
  return '${top()} ${d.reminder} Daha net bir yanıt için aşk, kariyer, para, sağlık ya da “bugün” hakkında sorabilirsin.';
}

int stableHash(String s) {
  var h = 7;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h;
}

double clamp01(double v) => math.max(0, math.min(1, v));


// ---------------- İNGİLİZCE ÜRETİCİLER ----------------
const _mEn = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
String _ord(int n) => '$n${n == 1 ? 'st' : n == 2 ? 'nd' : n == 3 ? 'rd' : 'th'}';

Daily _dailyEn(Chart natal, DateTime day) {
  final noon = DateTime(day.year, day.month, day.day, 12);
  final hits = transitHits(natal, noon);
  final hard = hits.where((h) => _hard(h.asp)).toList();
  final soft = hits.where((h) => !_hard(h.asp) && h.asp != 'kavuşum').toList();
  final never = hard.isNotEmpty
      ? '${_neverEn[hard.first.natal] ?? _neverEn['mars']!}, because ${aspectPhrase(hard.first.transit, hard.first.natal, hard.first.asp)} ${_neverWhyEn[hard.first.transit] ?? 'may raise tension'}.'
      : 'Don’t change plans at the last minute and leave others hanging; the day is calm but rhythm matters.';
  final todo = soft.isNotEmpty ? _doItEn[soft.first.natal] ?? _doItEn['mercury']! : _doItEn['mercury']!;
  final watch = hard.length > 1
      ? 'In the afternoon ${aspectPhrase(hard[1].transit, hard[1].natal, hard[1].asp)} is active; hasty promises may become a burden later.'
      : 'Promises made in a hurry this afternoon may weigh on you later; check your calendar before agreeing.';
  final moon = positions(noon.toUtc()).firstWhere((p) => p.id == 'moon');
  final reminder =
      'The Moon is in ${_signsEn[moon.sign]} today: a ${_signTraitEn[moon.sign].split(',').first} mood stands out. Finishing a small routine will give you confidence.';
  final sun = positions(noon.toUtc()).firstWhere((p) => p.id == 'sun');
  final house = natal.house(sun.lon);
  final period =
      'The Sun is in ${_signsEn[sun.sign]} and your ${_ord(house)} house: ${_houseTopicEn[house]} themes are highlighted this period.';
  final scores = [for (var c = 0; c < 3; c++) dailyScore(natal, day, c)];
  final trends = [
    for (var c = 0; c < 3; c++)
      [for (var k = 6; k >= 0; k--) dailyScore(natal, day.subtract(Duration(days: k)), c) / 100.0]
  ];
  final tips = <String>[
    if (soft.isNotEmpty)
      'Today ${aspectPhrase(soft.first.transit, soft.first.natal, soft.first.asp)} is supportive: ${_doItEn[soft.first.natal] ?? ''}',
    'Moon in ${_signsEn[moon.sign]}: a small gesture of ${_signLoveEn[moon.sign]} brightens your day.',
    'A short evening walk balances the tension of the day.',
    'Colour of the day: ${const ['red', 'green', 'yellow', 'silver', 'gold', 'navy', 'pink', 'plum', 'purple', 'brown', 'turquoise', 'sea blue'][moon.sign]}.',
  ];
  return Daily(never, todo, watch, reminder, period, scores, trends, tips);
}

String _reportTextEn(Chart c, int i) {
  String s(String id) => _signsEn[c.sign(id)];
  String t(String id) => _signTraitEn[c.sign(id)];
  String h(String id) => _ord(c.house(c.p(id).lon));
  final mc = (c.mc / 30).floor();
  switch (i) {
    case 0:
      return 'Sun in ${s('sun')}: at your core you are ${t('sun')}. Your ${c.signName('asc')} Ascendant shows the world a ${t('asc')} face. The gap between first impression and inner world may surprise people as they get to know you.';
    case 1:
      return 'Moon in ${s('moon')}: emotionally you are ${t('moon')}. To feel safe you value ${_signLoveEn[c.sign('moon')]}.';
    case 2:
      return 'Pluto in ${s('pluto')} and your ${h('pluto')} house: letting go of control here may be hard. Saturn in ${s('saturn')} shows you may be too hard on yourself in ${h('saturn')}-house matters.';
    case 3:
      return 'Venus in ${s('venus')}: in love you want ${_signLoveEn[c.sign('venus')]}. Mars in ${s('mars')} says you express desire in a ${t('mars')} way.';
    case 4:
      return 'MC in ${_signsEn[mc]}: you shine in ${_signWorkEn[mc]} work. The Sun in your ${h('sun')} house wants your effort to be visible there.';
    case 5:
      return 'Mercury in ${s('mercury')}: a ${t('mercury')} mind. You share ideas in a ${c.sign('mercury') % 3 == 0 ? 'direct and fast' : c.sign('mercury') % 3 == 1 ? 'solid and planned' : 'flexible and versatile'} way.';
    case 6:
      return 'Venus in your ${h('venus')} house, Jupiter in ${s('jupiter')}: your chances of growing resources are high in ${_signWorkEn[c.sign('jupiter')]} fields.';
    case 7:
      return 'Moon in your ${h('moon')} house: at home and in family you look for ${_signLoveEn[c.sign('moon')]}.';
    case 8:
      return 'Jupiter in your ${h('jupiter')} house and in ${s('jupiter')}: ${t('jupiter')} people around you bring you luck.';
    case 9:
      return 'The Sun–Venus interplay steers your creativity towards a ${_signTraitEn[c.sign('venus')]} style.';
    case 10:
      return 'Mars in your ${h('mars')} house: your body loves ${c.sign('mars') % 4 == 0 ? 'intense, short' : c.sign('mars') % 4 == 1 ? 'steady, endurance-focused' : c.sign('mars') % 4 == 2 ? 'varied and social' : 'calm and flowing'} movement.';
    case 11:
      return 'Pluto and Saturn together shape the turning points of your life with ${s('pluto')} themes.';
    case 12:
      return 'Jupiter and the 9th house: faraway places spark a ${c.house(c.p('jupiter').lon) == 9 ? 'very strong' : 'recurring'} curiosity in you.';
    case 13:
      return 'Uranus in ${s('uranus')}: with your generation you are part of a ${t('uranus')} change.';
    default:
      return 'North Node in ${s('node')}: your soul’s path invites you to become more ${t('node')}.';
  }
}

String _answerEn(Chart c, String q, DateTime now) {
  final s = q.toLowerCase();
  final d = _dailyEn(c, now);
  final hits = transitHits(c, now);
  String top() => hits.isEmpty
      ? 'No strong transit touches your chart today; a calm day.'
      : 'Strongest influence right now: ${aspectPhrase(hits.first.transit, hits.first.natal, hits.first.asp)}.';
  bool has(List<String> w) => w.any(s.contains);
  if (has(['love', 'partner', 'relationship', 'date', 'crush'])) {
    return 'Venus in ${_signsEn[c.sign('venus')]}: in relationships you look for ${_signLoveEn[c.sign('venus')]}. ${top()} Tip for today: ${d.todo}';
  }
  if (has(['job', 'work', 'career', 'interview'])) {
    final best = [for (var k = 0; k < 7; k++) (k, dailyScore(c, now.add(Duration(days: k)), 1))]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final day = now.add(Duration(days: best.first.$1));
    const g = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return 'In the next 7 days your mind & focus score peaks on ${g[day.weekday - 1]} (${day.day}/${day.month}): ${best.first.$2}%. With your MC in ${_signsEn[(c.mc / 30).floor()]}, shine in ${_signWorkEn[(c.mc / 30).floor()]} work.';
  }
  if (has(['money', 'salary', 'invest'])) {
    return '${_reportTextEn(c, 6)} ${top()} Note: this is not financial advice.';
  }
  if (has(['health', 'sport', 'energy', 'fitness'])) {
    return '${_reportTextEn(c, 10)} Your energy score today is ${d.scores[2]}%. This is not medical advice.';
  }
  if (has(['today', 'day'])) {
    return '${top()} Do today: ${d.todo} Avoid: ${d.never}';
  }
  if (has(['sign', 'rising', 'ascendant', 'moon'])) {
    return 'Sun ${c.signName('sun')}, Moon ${c.signName('moon')}, Rising ${c.signName('asc')}. ${_reportTextEn(c, 0)}';
  }
  return '${top()} ${d.reminder} For a sharper answer, ask about love, career, money, health or “today”.';
}
