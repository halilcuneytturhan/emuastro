import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/sprites.dart';
import '../widgets/surface.dart';
import 'detail.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController controller;
  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final d = app.today;
    final dateLabel = trUpper(
        '${d.day} ${trMonths[d.month - 1]} ${trDays[d.weekday - 1]}');
    return ListView(
      controller: controller,
      padding: EdgeInsets.only(top: top + 25.5, bottom: 140),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSide),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel, style: T.sectionLabel),
                    const SizedBox(height: 4.5),
                    Text('Merhaba, ${app.profile.name}', style: T.display),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 10),
              child: GestureDetector(
                onTap: () => showInfo(context, 'Bildirimler',
                    'İkizler Dolunayı etkilerin hazır. Satürn 11 Aralık’ta düz harekete geçiyor.'),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Stack(clipBehavior: Clip.none, children: [
                    const Sprite('bell', size: 22, cells: 18),
                    Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                                color: Color(0xFFF2343C),
                                shape: BoxShape.circle))),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _pad(EventBand(app.events[1], Pal.goldBand,
            onTap: () => openEvent(context, app.events[1], Pal.goldBand))),
        const SizedBox(height: 16),
        _pad(const _ChartFolders()),
        const SizedBox(height: 23),
        _pad(const _NeverCard()),
        const SizedBox(height: 24),
        const _Performance(),
        const SizedBox(height: 81),
        _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Gökyüzünde neler oluyor', style: T.monoTitle),
          const SizedBox(height: 6),
          Text('Bu dönemin olayları ve senin haritana etkileri',
              style: T.body.copyWith(fontSize: 12.6)),
          const SizedBox(height: 11),
          for (final (i, e) in app.events.indexed) ...[
            EventBand(e, [Pal.redBand, Pal.goldBand, Pal.greenBand][i],
                onTap: () => openEvent(
                    context, e, [Pal.redBand, Pal.goldBand, Pal.greenBand][i])),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
          const Text('Görünürlük ve Hareket', style: T.monoTitleBold),
          const SizedBox(height: 24),
        ])),
        const _MoveFolders(),
        const SizedBox(height: 25),
        _pad(_DarkButton(
            label: 'Detaylı analiz',
            mono: true,
            height: 68,
            color: const Color(0xFF1C1B21),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 26),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const DetailScreen())))),
        const SizedBox(height: 43),
        _pad(_DarkButton(
            label: 'PDF indir / paylaş',
            height: 61,
            color: Colors.black,
            trailing: const ShareIcon(size: 13),
            onTap: () => showInfo(context, 'PDF hazırlanıyor',
                'Tüm başlıklar tek dosyada toplanıyor. Paylaş menüsünden Dosyalar’a kaydedebilirsin.'))),
        const SizedBox(height: 14),
        _pad(Text(
            'Tüm başlıklar tek dosyada. Paylaş menüsünden Dosyalar’a kaydedebilirsin.',
            style: T.body.copyWith(fontSize: 9.4))),
        const SizedBox(height: 40),
        _pad(Text(
            'Astrolojik yorumlar eğlence ve öz farkındalık amaçlıdır; tıbbi, finansal, hukuki tavsiye, garanti edilmiş performans veya kesin sonuç değildir.',
            style: T.body.copyWith(fontSize: 9.4, color: C.greyLight))),
      ],
    );
  }
}

Widget _pad(Widget w) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: kSide), child: w);

void openEvent(BuildContext context, SkyEvent e, Pal pal) =>
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EventDetail(event: e, pal: pal)));

/// Kişisel Haritan dosya yığını.
class _ChartFolders extends StatelessWidget {
  const _ChartFolders();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: LayoutBuilder(builder: (ctx, c) {
        final w = c.maxWidth;
        Widget back(
                {required double top,
                required double l,
                required double r,
                required double tabS,
                required double tabE,
                required Pal pal,
                required String label}) =>
            Positioned(
              top: top,
              left: l,
              right: r,
              height: 330 - top - 30,
              child: Pearl(
                pal: pal,
                shadowAlpha: .25,
                sheenAt: const Alignment(.5, -1),
                shape: (s) => folderPath(s,
                    tabStart: tabS, tabEnd: tabE, tabH: 34, slope: 26, r: 22),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: tabS + 14, top: 9),
                    child: SizedBox(
                        width: tabE - tabS,
                        height: 18,
                        child: Center(
                            child: Text(label,
                                style: T.tabLabel.copyWith(
                                    color: Colors.white.withValues(alpha: .85),
                                    fontWeight: FontWeight.w600)))),
                  ),
                ),
              ),
            );
        return Stack(clipBehavior: Clip.none, children: [
          back(
              top: 0,
              l: 19.5,
              r: 18,
              tabS: (w - 37.5) * .5 - 15,
              tabE: (w - 37.5) * .78,
              pal: Pal.pink,
              label: 'YILDIZ'),
          back(
              top: 25,
              l: 8,
              r: 8.5,
              tabS: (w - 16.5) * .4 - 18,
              tabE: (w - 16.5) * .68,
              pal: Pal.blue,
              label: 'AY'),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            height: 280,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DetailScreen())),
              child: Pearl(
                pal: Pal.purple,
                sheenAt: const Alignment(.42, .02),
                sheenSize: .42,
                sheenAngle: -1.05,
                sheenStretch: 2.3,
                shadowAlpha: .45,
                shadowBlur: 24,
                shadowY: 12,
                shape: (s) => folderPath(s,
                    tabEnd: w * .43, tabH: 35, slope: 30, r: 24, tr: 20),
                child: const _ChartFolderFront(),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _ChartFolderFront extends StatelessWidget {
  const _ChartFolderFront();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned(
          left: 16,
          top: 8,
          child: Text('Kişisel Haritan',
              style: TextStyle(
                  fontFamily: 'PlexMono',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.6,
                  letterSpacing: .3,
                  color: Colors.white))),
      const Positioned(
          right: 25, top: 44, child: Sprite('lock', size: 19, cells: 16)),
      Positioned(
        left: 0,
        right: 0,
        top: 106,
        child: Column(children: [
          DotText('${app.unlocked}/${app.totalSections}', pitch: 6.75),
          const SizedBox(height: 12),
          Text(
              '${app.unlocked} bölüm açık · ${app.totalSections - app.unlocked} bölüm Premium\'da',
              style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12.6,
                  fontWeight: FontWeight.w500,
                  color: Color(0xE6FFFFFF))),
        ]),
      ),
      Positioned(
        left: 31,
        right: 31,
        top: 211,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
              app.totalSections,
              (i) => Container(
                    width: i < app.unlocked ? 7 : 4,
                    height: i < app.unlocked ? 7 : 4,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < app.unlocked
                            ? Colors.white
                            : Colors.white.withValues(alpha: .3)),
                  )),
        ),
      ),
      Positioned(
        left: 22,
        bottom: 22,
        width: 228,
        child: Text('Mizaç, duygusal dünya, gölge yönler, aşk ve kariyer kodların.',
            style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 10.6,
                height: 1.3,
                color: Colors.white.withValues(alpha: .6))),
      ),
      Positioned(
        right: 22,
        bottom: 22,
        child: Container(
          width: 88,
          height: 27,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Sprite('lock', size: 11, cells: 11, shadow: false),
            SizedBox(width: 9),
            Flexible(
              child: Text('Premium',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 10.4,
                      color: C.ink)),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _NeverCard extends StatelessWidget {
  const _NeverCard();
  @override
  Widget build(BuildContext context) {
    return Pearl(
      pal: Pal.red,
      radius: 23,
      sheenAt: const Alignment(.9, -.9),
      sheenSize: .45,
      shadowAlpha: .55,
      shadowBlur: 22,
      shadowY: 10,
      padding: const EdgeInsets.fromLTRB(21.5, 20, 21.5, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Bugün asla yapma', style: T.monoCard),
        const SizedBox(height: 11),
        Text(app.neverToday, style: T.cardBody),
        const SizedBox(height: 18),
        Row(children: [
          Text('25 Kasım · emuastro', style: T.small.copyWith(color: Colors.white54)),
          const Spacer(),
          const ShareIcon(size: 12.5),
        ]),
      ]),
    );
  }
}

class _Performance extends StatefulWidget {
  const _Performance();
  @override
  State<_Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<_Performance> {
  int front = 0;
  static const cards = [
    ('Fırsat ve akış', 60, 'Güçlü', Pal.gold),
    ('Zihin ve odak', 48, 'Dengeli', Pal.navy),
    ('Enerji ve beden', 72, 'Yüksek', Pal.deepGreen),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cw = w * .6935; // 298 / 430
    const ch = 359.0;
    final order = [(front + 1) % 3, (front + 2) % 3, front];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Text('BUGÜNÜN PERFORMANS KODU', style: T.sectionLabel)),
      const SizedBox(height: 13),
      _pad(Row(children: [
        const Expanded(child: Text('Günlük yaşam haritası', style: T.monoTitle)),
        Container(
          width: 51,
          height: 29,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF5C9A8), width: .8),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 11,
              height: 13,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF7B07A), Color(0xFFF58C8C)])),
            ),
            const SizedBox(width: 8),
            Text('${app.streak}',
                style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: C.ink)),
          ]),
        ),
      ])),
      const SizedBox(height: 34),
      SizedBox(
        height: ch + 14,
        child: GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() < 50) return;
            setState(() => front = (front + (v < 0 ? 1 : 2)) % 3);
          },
          onTap: () => setState(() => front = (front + 1) % 3),
          child: Stack(alignment: Alignment.topCenter, children: [
            for (final i in order)
              AnimatedPositioned(
                key: ValueKey(i),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                top: i == front ? 0 : 10,
                left: w / 2 -
                    cw / 2 +
                    (i == front ? 0 : (i == (front + 2) % 3 ? 37 : -29)),
                width: cw,
                height: ch,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 380),
                  turns: i == front
                      ? 0
                      : (i == (front + 2) % 3 ? 4.5 / 360 : -4 / 360),
                  child: _PerfCard(
                      data: cards[i], isFront: i == front, cw: cw),
                ),
              ),
          ]),
        ),
      ),
    ]);
  }
}

class _PerfCard extends StatelessWidget {
  final (String, int, String, Pal) data;
  final bool isFront;
  final double cw;
  const _PerfCard({required this.data, required this.isFront, required this.cw});
  @override
  Widget build(BuildContext context) {
    final (title, v, label, pal) = data;
    return Pearl(
      pal: pal,
      radius: 29,
      sheenAt: const Alignment(.3, .05),
      sheenSize: .55,
      lightFrom: const Alignment(-.4, -1),
      shadowAlpha: isFront ? .5 : .3,
      shadowBlur: 26,
      shadowY: 14,
      child: Stack(children: [
        Positioned(
            left: 21,
            top: 20,
            child: Text(title, style: T.monoCard.copyWith(fontSize: 14.4))),
        Positioned(
          right: 18,
          top: 19,
          child: GestureDetector(
            onTap: () => showInfo(context, title,
                'Günlük yaşam haritası, transitlerin doğum haritana etkisinden hesaplanan 0–100 arası bir skordur. %$v $label anlamına gelir.'),
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                      center: Alignment(-.4, -.4),
                      colors: [Colors.white, Color(0xFFB9B6CC)]),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .25),
                        blurRadius: 2,
                        offset: const Offset(0, 1))
                  ]),
              child: const Center(
                  child: Text('?',
                      style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Color(0xFF5B48B5)))),
            ),
          ),
        ),
        if (isFront) ...[
          Positioned(
            left: 0,
            right: 0,
            top: 86,
            child: Column(children: [
              DotText('%$v', pitch: 9.1, dot: .68),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.6,
                      color: Color(0xE6FFFFFF))),
            ]),
          ),
          Positioned(
              left: 20,
              right: 20,
              top: 252,
              height: 56,
              child: CustomPaint(painter: _TrendPainter(app.trend))),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Row(children: [
              Text('25 Kasım · emuastro',
                  style: T.small.copyWith(color: Colors.white70)),
              const Spacer(),
              const ShareIcon(size: 12.5),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> v;
  _TrendPainter(this.v);
  @override
  void paint(Canvas canvas, Size s) {
    final grid = Paint()..color = Colors.white.withValues(alpha: .16);
    for (final gy in [0.0, .5, 1.0]) {
      for (var x = 0.0; x <= s.width; x += 4.2) {
        canvas.drawCircle(Offset(x, s.height * gy), .55, grid);
      }
    }
    for (var i = 1; i < v.length; i++) {
      final x = s.width * i / (v.length - 1);
      for (var y = 0.0; y <= s.height; y += 4.2) {
        canvas.drawCircle(Offset(x, y), .5, grid);
      }
    }
    final dot = Paint()..color = Colors.white;
    for (var i = 0; i < v.length; i++) {
      final o = Offset(s.width * i / (v.length - 1) * .985 + 3,
          s.height * (1 - v[i] * 1.0) + 2);
      if (i == v.length - 1) {
        canvas.drawCircle(o, 8.5, Paint()..color = Colors.white.withValues(alpha: .35));
        canvas.drawCircle(o, 5.4, dot);
      } else {
        canvas.drawCircle(o, 3, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Görünürlük ve Hareket: kaydırılabilir dosya destesi.
class _MoveFolders extends StatefulWidget {
  const _MoveFolders();
  @override
  State<_MoveFolders> createState() => _MoveFoldersState();
}

class _MoveFoldersState extends State<_MoveFolders> {
  int active = 0;
  static const pals = [Pal.green, Pal.ochre, Pal.lilac, Pal.blue];
  static const _tabStarts = [0.0, 34.0, 92.0, 142.0];

  @override
  Widget build(BuildContext context) {
    const tabW = 147.0;
    // arkadan öne: index 3,2,1,0 (aktif en önde)
    final order = List.generate(4, (k) => (active + 3 - k) % 4);
    return Column(children: [
      SizedBox(
        height: 302,
        child: GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() < 50) return;
            setState(() => active = (active + (v < 0 ? 1 : 3)) % 4);
          },
          child: Stack(children: [
            for (final i in order)
              Builder(builder: (_) {
                final depth = (i - active + 4) % 4; // 0 = önde
                final top = 24.0 * (3 - (3 - depth)) ;
                return AnimatedPositioned(
                  key: ValueKey(i),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  top: 72 - top,
                  left: kSide + depth * 10.0,
                  right: kSide + depth * 9.0 - (depth == 0 ? 0 : 0),
                  height: 227 + top,
                  child: GestureDetector(
                    onTap: () => setState(() => active = i),
                    child: Pearl(
                      pal: pals[i],
                      shadowAlpha: depth == 0 ? .45 : .15,
                      sheenAt: const Alignment(.45, .35),
                      sheenSize: .6,
                      shape: (s) {
                        final ts = _tabStarts[depth];
                        return folderPath(s,
                            tabStart: ts,
                            tabEnd: ts + tabW - (depth == 0 ? 20 : 0),
                            tabH: 34,
                            slope: 26,
                            r: 24,
                            tr: 18);
                      },
                      child: Stack(children: [
                        Positioned(
                          left: _tabStarts[depth],
                          top: 9,
                          width: tabW - 10,
                          child: Padding(
                            padding: EdgeInsets.only(left: depth == 0 ? 30 : 22),
                            child: Text(app.moves[i].$1,
                                style: T.tabLabel.copyWith(
                                    color: Colors.white.withValues(
                                        alpha: depth == 0 ? 1 : .85))),
                          ),
                        ),
                        if (depth == 0)
                          Positioned(
                            left: 22,
                            right: 22,
                            top: 54,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.moves[i].$2,
                                      style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 14.2,
                                          height: 1.45,
                                          color: Colors.white)),
                                  const SizedBox(height: 12),
                                  Text('25 Kasım · emuastro',
                                      style: T.small.copyWith(
                                          color: Colors.white60)),
                                ]),
                          ),
                        if (depth == 0)
                          const Positioned(
                              right: 22, bottom: 20, child: ShareIcon(size: 12.5)),
                      ]),
                    ),
                  ),
                );
              }),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              4,
              (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == active
                            ? const Color(0xFF2FC873)
                            : const Color(0xFFCFCED4)),
                  ))),
    ]);
  }
}

class _DarkButton extends StatelessWidget {
  final String label;
  final bool mono;
  final double height;
  final Color color;
  final Widget trailing;
  final VoidCallback onTap;
  const _DarkButton(
      {required this.label,
      this.mono = false,
      required this.height,
      required this.color,
      required this.trailing,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(height / 2)),
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: mono
                        ? T.monoCard.copyWith(fontSize: 14.6)
                        : const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w800,
                            fontSize: 13.8,
                            color: Colors.white))),
            trailing,
          ]),
        ),
      );
}

double clamp01(double v) => math.max(0, math.min(1, v));
