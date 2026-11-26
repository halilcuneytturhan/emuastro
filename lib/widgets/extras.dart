import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../astro/ephemeris.dart';
import '../astro/interpret.dart' as astro;
import '../data/sample.dart';
import '../theme.dart';
import 'surface.dart';

/// Ay'ın evresi: (aydınlanma 0-1, büyüyor mu, evre adı)
(double, bool, String) moonPhase(DateTime t) {
  final d = dayNumber(t.toUtc());
  final e = (geoLongitude('moon', d) - geoLongitude('sun', d) + 360) % 360;
  final illum = (1 - math.cos(e * math.pi / 180)) / 2;
  final waxing = e < 180;
  final name = e < 12 || e > 348
      ? 'Yeniay'
      : e < 80
          ? 'Hilal (büyüyen)'
          : e < 100
              ? 'İlk dördün'
              : e < 168
                  ? 'Şişkin Ay (büyüyen)'
                  : e < 192
                      ? 'Dolunay'
                      : e < 260
                          ? 'Şişkin Ay (küçülen)'
                          : e < 280
                              ? 'Son dördün'
                              : 'Hilal (küçülen)';
  return (illum, waxing, name);
}

const _phaseTip = {
  'Yeniay': 'Niyet koymak ve yeni bir şeye başlamak için en uygun gün.',
  'Hilal (büyüyen)': 'Küçük ama kararlı adımlar at; planın filizleniyor.',
  'İlk dördün': 'Engellerle yüzleş; karar verme zamanı.',
  'Şişkin Ay (büyüyen)': 'İnce ayar yap, eksikleri tamamla.',
  'Dolunay': 'Duygular yüksek; sonuçları gör, bırakman gerekeni bırak.',
  'Şişkin Ay (küçülen)': 'Öğrendiklerini paylaş, teşekkür et.',
  'Son dördün': 'Toparlan, gereksizleri ayıkla.',
  'Hilal (küçülen)': 'Dinlen, içe dön, yeni döngüye hazırlan.',
};

class MoonCard extends StatelessWidget {
  const MoonCard({super.key});
  @override
  Widget build(BuildContext context) {
    final now = DateTime(app.today.year, app.today.month, app.today.day, 21);
    final (illum, waxing, name) = moonPhase(now);
    final moon = positions(now.toUtc()).firstWhere((p) => p.id == 'moon');
    return Pearl(
      pal: Pal.charcoal,
      radius: 24,
      shadowAlpha: .25,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(children: [
        CustomPaint(
            size: const Size.square(58), painter: _MoonPainter(illum, waxing)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BUGÜN AY · %${(illum * 100).round()}',
                style: T.bandKicker.copyWith(color: Colors.white60)),
            const SizedBox(height: 4),
            Text('$name · ${astro.signs[moon.sign]}',
                style: T.monoCard.copyWith(fontSize: 14.6)),
            const SizedBox(height: 5),
            Text(_phaseTip[name]!,
                style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 11.6,
                    height: 1.3,
                    color: Colors.white.withValues(alpha: .7))),
          ]),
        ),
      ]),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final double illum;
  final bool waxing;
  _MoonPainter(this.illum, this.waxing);
  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF34333B));
    // aydınlık kısım: aydınlık taraftaki yarım disk ± terminatör elipsi
    final rect = Rect.fromCircle(center: c, radius: r);
    final half = Path()
      ..addRect(waxing
          ? Rect.fromLTRB(c.dx, c.dy - r, c.dx + r, c.dy + r)
          : Rect.fromLTRB(c.dx - r, c.dy - r, c.dx, c.dy + r));
    final disc = Path()..addOval(rect);
    final halfDisc = Path.combine(PathOperation.intersect, disc, half);
    final ew = (2 * illum - 1).abs() * r;
    final ell = Path()
      ..addOval(Rect.fromCenter(center: c, width: 2 * ew, height: 2 * r));
    final lit = illum >= .5
        ? Path.combine(PathOperation.union, halfDisc, ell)
        : Path.combine(PathOperation.difference, halfDisc, ell);
    canvas.drawPath(
        lit,
        Paint()
          ..shader = const RadialGradient(
                  center: Alignment(-.3, -.4),
                  colors: [Color(0xFFFFFBEF), Color(0xFFD9D2F5)])
              .createShader(rect));
    final dot = Paint()..color = Colors.white.withValues(alpha: .06);
    for (final o in [const Offset(-.3, -.2), const Offset(.25, .3), const Offset(.1, -.45)]) {
      canvas.drawCircle(c + o * r, r * .13, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPainter o) => o.illum != illum;
}

/// Önümüzdeki 7 günün fırsat skorları; en iyi gün vurgulu.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});
  static const _g = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  @override
  Widget build(BuildContext context) {
    final days = [
      for (var k = 0; k < 7; k++) app.today.add(Duration(days: k))
    ];
    final scores = [for (final d in days) astro.dailyScore(app.chart, d, 0)];
    final best = scores.indexOf(scores.reduce(math.max));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Bu hafta', style: T.heading),
        const Spacer(),
        Text('En iyi gün: ${_g[days[best].weekday - 1]} · %${scores[best]}',
            style: T.body.copyWith(fontSize: 11.5, color: C.accent, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        for (var k = 0; k < 7; k++)
          Expanded(
            child: Column(children: [
              SizedBox(
                height: 54,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 18,
                    height: 54 * scores[k] / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: k == best
                              ? const [Color(0xFF9C7BFF), Color(0xFF5B3BD6)]
                              : const [Color(0xFFE3DEF3), Color(0xFFCFC8E8)]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(k == 0 ? 'Bugün' : _g[days[k].weekday - 1],
                  style: T.body.copyWith(
                      fontSize: 10,
                      color: k == best ? C.ink : C.grey,
                      fontWeight: k == best ? FontWeight.w800 : FontWeight.w500)),
            ]),
          ),
      ]),
    ]);
  }
}
