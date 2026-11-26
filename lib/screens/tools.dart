import 'package:flutter/material.dart';

import '../astro/ephemeris.dart';
import '../astro/interpret.dart';
import '../data/sample.dart' hide Chart, BirthData, scoreLabel, scoreCats;
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/share_card.dart';
import '../widgets/surface.dart';
import 'friends.dart' show fmtDate;
import 'premium.dart';

const _days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

Widget _scaffold(BuildContext context, String kicker, String title, List<Widget> children) {
  final top = MediaQuery.of(context).padding.top;
  return Scaffold(
    backgroundColor: C.page,
    body: PaperBackground(
      child: ListView(
        padding: EdgeInsets.fromLTRB(kSide, top + 14, kSide, 60),
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left_rounded, size: 32))),
          const SizedBox(height: 10),
          Text(kicker, style: T.sectionLabel),
          const SizedBox(height: 6),
          Text(title, style: T.monoTitleBold),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    ),
  );
}

Widget _lockedRow(BuildContext context, String t) => GestureDetector(
      onTap: () => openPremium(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.panel, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const Icon(Icons.lock_rounded, color: C.accent),
          const SizedBox(width: 12),
          Expanded(child: Text(t, style: T.heading.copyWith(fontSize: 13.5))),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );

// ---------------- UYGUN GÜN BULUCU ----------------

class GoodDayFinder extends StatefulWidget {
  const GoodDayFinder({super.key});
  @override
  State<GoodDayFinder> createState() => _GoodDayFinderState();
}

class _GoodDayFinderState extends State<GoodDayFinder> {
  static const purposes = [
    ('İş görüşmesi', 1, ['mercury', 'sun', 'jupiter']),
    ('İlk buluşma', 0, ['venus', 'moon']),
    ('Taşınma / yeni başlangıç', 2, ['moon', 'jupiter', 'mars']),
    ('Önemli bir karar', 1, ['mercury', 'saturn']),
    ('Spor hedefi başlatmak', 2, ['mars', 'sun']),
  ];
  int sel = 0;

  @override
  Widget build(BuildContext context) {
    final (_, cat, planets) = purposes[sel];
    final days = <(DateTime, int, String)>[];
    for (var k = 0; k < 30; k++) {
      final d = app.today.add(Duration(days: k));
      var s = dailyScore(app.chart, d, cat).toDouble();
      final hits = transitHits(app.chart, DateTime(d.year, d.month, d.day, 12), only: planets);
      String why = 'Genel akış destekleyici.';
      for (final h in hits) {
        final good = h.asp == 'üçgen' || h.asp == 'altmışlık';
        s += good ? 6 : (h.asp == 'kavuşum' ? 2 : -6);
        if (good && why.startsWith('Genel')) why = '${aspectPhrase(h.transit, h.natal, h.asp)} destekliyor.';
      }
      days.add((d, s.round().clamp(5, 99), why));
    }
    days.sort((a, b) => b.$2.compareTo(a.$2));
    return _scaffold(context, 'PREMIUM ARAÇ', 'Uygun gün bulucu', [
      Text('Ne için gün arıyorsun?', style: T.body.copyWith(color: C.ink)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var i = 0; i < purposes.length; i++)
          ChoiceChip(
            label: Text(purposes[i].$1, style: const TextStyle(fontFamily: 'Figtree')),
            selected: sel == i,
            onSelected: (_) => setState(() => sel = i),
          ),
      ]),
      const SizedBox(height: 20),
      Text('Önümüzdeki 30 günün en uygun günleri', style: T.heading),
      const SizedBox(height: 12),
      for (final (i, (d, s, why)) in days.take(5).indexed)
        if (i > 0 && !app.premium)
          _lockedRow(context, '${i + 1}. gün Premium’da')
        else
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Pearl(
              pal: i == 0 ? Pal.purple : Pal.charcoal,
              radius: 20,
              shadowAlpha: .2,
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                DotText('%$s', pitch: 3.4, glow: .2),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${d.day} ${_months[d.month - 1]} ${_days[d.weekday - 1]}',
                        style: T.monoCard.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(why,
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: .7))),
                  ]),
                ),
              ]),
            ),
          ),
    ]);
  }
}

// ---------------- YILLIK ÖNGÖRÜ ----------------

const _outerTheme = {
  'jupiter': 'büyüme ve fırsat',
  'saturn': 'sorumluluk ve olgunlaşma',
  'uranus': 'ani değişim ve özgürleşme',
  'neptune': 'hayaller ve sezgi',
  'pluto': 'derin dönüşüm',
};
const _natalArea = {
  'sun': 'kimliğin ve hedeflerin',
  'moon': 'duygusal dünyan ve evin',
  'mercury': 'iletişimin ve eğitimin',
  'venus': 'ilişkilerin ve paran',
  'mars': 'enerjin ve kariyer hamlelerin',
  'jupiter': 'inançların ve şansın',
  'saturn': 'düzenin ve sorumlulukların',
  'pluto': 'güç alanların',
  'asc': 'görünüşün ve yaklaşımın',
};

class YearForecast extends StatelessWidget {
  const YearForecast({super.key});
  @override
  Widget build(BuildContext context) {
    final months = <(DateTime, List<String>)>[];
    for (var m = 0; m < 12; m++) {
      final d = DateTime(app.today.year, app.today.month + m, 15);
      final hits = transitHits(app.chart, d,
              only: ['jupiter', 'saturn', 'uranus', 'neptune', 'pluto'])
          .where((h) => h.orb < 3)
          .take(3);
      final lines = [
        for (final h in hits)
          '${aspectPhrase(h.transit, h.natal, h.asp)}: ${_natalArea[h.natal] ?? ''} alanında ${_outerTheme[h.transit]} ${h.asp == 'kare' || h.asp == 'karşıtlık' ? 'sınavı' : 'desteği'}.'
      ];
      final sun = positions(d.toUtc()).first;
      if (lines.isEmpty) {
        lines.add('Güneş haritanın ${app.chart.house(sun.lon)}. evinde: sakin ve dengeli bir ay; ${signs[sun.sign]} temaları öne çıkıyor.');
      }
      months.add((d, lines));
    }
    return _scaffold(context, 'PREMIUM RAPOR', 'Önümüzdeki 12 ay', [
      Text('Jüpiter, Satürn, Uranüs, Neptün ve Plüton’un doğum haritana etkileri.',
          style: T.body),
      const SizedBox(height: 18),
      for (final (i, (d, lines)) in months.indexed)
        if (i > 0 && !app.premium)
          _lockedRow(context, '${_months[d.month - 1]} ${d.year} Premium’da')
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_months[d.month - 1]} ${d.year}', style: T.heading),
              const SizedBox(height: 6),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $l', style: T.body.copyWith(color: C.ink, fontSize: 13.5)),
                ),
            ]),
          ),
    ]);
  }
}

// ---------------- HIZLI UYUM TESTİ ----------------

class QuickMatch extends StatefulWidget {
  const QuickMatch({super.key});
  @override
  State<QuickMatch> createState() => _QuickMatchState();
}

class _QuickMatchState extends State<QuickMatch> {
  final name = TextEditingController();
  DateTime? birth;
  (int, List<String>)? result;
  Chart? other;

  void _calc() {
    if (birth == null) return;
    final n = name.text.trim().isEmpty ? 'O' : name.text.trim();
    other = Chart.of(BirthData(n, DateTime(birth!.year, birth!.month, birth!.day, 12),
        'İstanbul, Türkiye', timeKnown: false));
    setState(() => result = synastry(app.chart, other!));
  }

  @override
  Widget build(BuildContext context) {
    return _scaffold(context, 'ÜCRETSİZ', 'Hızlı uyum testi', [
      Text('Yalnızca doğum tarihiyle iki harita arasındaki uyumu gör, sonucu paylaş.',
          style: T.body),
      const SizedBox(height: 16),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Onun ismi')),
      const SizedBox(height: 10),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Doğum tarihi', style: TextStyle(fontFamily: 'Figtree')),
        trailing: Text(birth == null ? 'Seç' : fmtDate(birth!), style: T.heading),
        onTap: () async {
          final d = await showDatePicker(
              context: context,
              initialDate: DateTime(1998),
              firstDate: DateTime(1920),
              lastDate: DateTime.now());
          if (d != null) {
            birth = d;
            _calc();
          }
        },
      ),
      const SizedBox(height: 16),
      if (result != null)
        ShareCard(
          text: '${app.profile.name} & ${other!.data.name}: uyumumuz %${result!.$1}! Seninkini EmuAstro’da test et.',
          child: Pearl(
            pal: Pal.rose,
            radius: 26,
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Text('${app.profile.name} & ${other!.data.name}',
                  style: T.monoCard.copyWith(fontSize: 16)),
              const SizedBox(height: 16),
              DotText('%${result!.$1}', pitch: 7.5),
              const SizedBox(height: 10),
              Text('${scoreLabel(result!.$1)} uyum · Güneş ${app.chart.signName('sun')} & ${other!.signName('sun')}',
                  style: const TextStyle(fontFamily: 'Figtree', color: Colors.white, fontSize: 13)),
              const SizedBox(height: 10),
              const Align(
                  alignment: Alignment.centerRight,
                  child: ShareTap(child: ShareIcon(size: 14))),
            ]),
          ),
        ),
    ]);
  }
}

// ---------------- YILIN ÖZETİ ----------------

class YearSummary extends StatelessWidget {
  const YearSummary({super.key});
  @override
  Widget build(BuildContext context) {
    final y = app.today.year;
    var bestMonth = 0, bestScore = 0;
    for (var m = 1; m <= 12; m++) {
      final s = dailyScore(app.chart, DateTime(y, m, 15), 0);
      if (s > bestScore) {
        bestScore = s;
        bestMonth = m;
      }
    }
    final big = transitHits(app.chart, DateTime(y, 6, 30),
            only: ['jupiter', 'saturn', 'uranus', 'neptune', 'pluto'])
        .firstOrNull;
    final text =
        '$y yılım: en parlak ayım ${_months[bestMonth - 1]} (%$bestScore), ${app.badges.length} rozet, ${app.streak} günlük seri.';
    return _scaffold(context, 'YILIN ÖZETİ', '$y senin yılın', [
      ShareCard(
        text: '$text EmuAstro’da kendi yılını gör.',
        child: Pearl(
          pal: Pal.purple,
          radius: 28,
          padding: const EdgeInsets.all(26),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${app.profile.name} · $y', style: T.monoCard.copyWith(fontSize: 15)),
            const SizedBox(height: 22),
            DotText('$y', pitch: 6),
            const SizedBox(height: 22),
            _row('En parlak ay', '${_months[bestMonth - 1]} · %$bestScore'),
            _row('Yılın teması', big == null ? 'Denge ve istikrar' : '${planetName[big.transit]} · ${_outerTheme[big.transit]}'),
            _row('Kazanılan rozet', '${app.badges.length}'),
            _row('En uzun seri', '${app.streak} gün'),
            _row('Büyük üçlün', '${app.sun} · ${app.moon} · ${app.asc}'),
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerRight, child: ShareTap(child: ShareIcon(size: 14))),
          ]),
        ),
      ),
    ]);
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(k, style: TextStyle(fontFamily: 'Figtree', fontSize: 12.5, color: Colors.white.withValues(alpha: .65))),
          const Spacer(),
          Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.white))),
        ]),
      );
}

// ---------------- AYRINTILI UYUM BÖLÜMLERİ ----------------

List<(String, String)> synastrySections(Chart a, Chart b) {
  String rel(String x, String y, String good, String hard, String none) {
    final asp = aspectBetween(a.p(x).lon, b.p(y).lon);
    if (asp == null) return none;
    return (asp.$1 == 'kare' || asp.$1 == 'karşıtlık') ? hard : good;
  }

  return [
    ('Aşk ve çekim', rel('venus', 'mars', 'Venüs–Mars uyumu güçlü: aranızda doğal bir çekim var.', 'Venüs–Mars gerilimi: çekim yoğun ama tempo farkı tartışma çıkarabilir.', 'Çekim zamanla ve ortak deneyimle büyüyen türden.')),
    ('İletişim', rel('mercury', 'mercury', 'Zihinleriniz aynı dili konuşuyor; uzun sohbetler kolay.', 'Düşünme tarzlarınız farklı; dinlemeye zaman ayırmak önemli.', 'İletişim tarzlarınız birbirini tamamlıyor.')),
    ('Duygusal bağ', rel('moon', 'moon', 'Duygusal ihtiyaçlarınız benzer; birbirinizi rahatlatıyorsunuz.', 'Duygusal ritimleriniz farklı; ihtiyaçlarınızı açıkça söyleyin.', 'Duygusal bağ güvenle derinleşiyor.')),
    ('Uzun vade', rel('saturn', 'sun', 'Satürn bağı: ilişki ciddiyet ve kalıcılık taşıyor.', 'Satürn baskısı: sorumluluklar ilişkiyi zaman zaman ağırlaştırabilir.', 'Uzun vadeli yapı ortak hedeflerle kurulur.')),
  ];
}
