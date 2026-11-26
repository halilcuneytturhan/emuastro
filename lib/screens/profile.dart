import 'package:flutter/material.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/sprites.dart';
import '../widgets/surface.dart';
import '../widgets/wheel.dart';
import 'detail.dart';
import 'friends.dart' show birthForm;
import 'premium.dart';
import 'settings.dart';
import 'tools.dart';

class ProfileScreen extends StatefulWidget {
  final ScrollController controller;
  final VoidCallback openRelations;
  const ProfileScreen(
      {super.key, required this.controller, required this.openRelations});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final twinCtl = ScrollController();

  Widget _p(Widget w) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: kSide), child: w);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;
    final pr = app.profile;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => ListView(
        controller: widget.controller,
        padding: EdgeInsets.only(top: top + 26, bottom: 150),
        children: [
          _p(Text('PROFİL', style: T.sectionLabel)),
          const SizedBox(height: 4),
          _p(Row(children: [
            Text(pr.name,
                style: T.monoTitleBold.copyWith(
                    fontSize: 26, letterSpacing: 0, fontWeight: FontWeight.w600)),
            const SizedBox(width: 9),
            GestureDetector(
                onTap: () => editProfile(context),
                child: const Sprite('pencil', size: 17, cells: 14)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Sprite('gear', size: 19, cells: 16),
              ),
            ),
          ])),
          const SizedBox(height: 22),
          _p(GestureDetector(
            onTap: () => app.premium
                ? Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const DetailScreen()))
                : openPremium(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 97),
              child: Pearl(
                pal: Pal.purpleBand,
                radius: 22,
                sheenAt: const Alignment(.6, -.6),
                sheenSize: .55,
                shadowAlpha: .5,
                shadowBlur: 18,
                child: Row(children: [
                  const SizedBox(width: 22),
                  const Sprite('star', size: 33, cells: 20),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EMUASTRO PREMIUM', style: T.bandKicker),
                          const SizedBox(height: 4),
                          Text('Haritanın tamamını aç',
                              style: T.monoCard.copyWith(fontSize: 15.2)),
                          const SizedBox(height: 3),
                          const Text(
                              'Tüm rapor bölümleri, günde 5 soru,\nilişki raporları',
                              style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 10.4,
                                  height: 1.2,
                                  color: Color(0xE6FFFFFF))),
                        ]),
                  ),
                  const _ArrowCircle(),
                  const SizedBox(width: 18),
                ]),
              ),
            ),
          )),
          const SizedBox(height: 44),
          _p(Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: app.toggleTransit,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: app.transit ? C.accent : Colors.transparent,
                        border: Border.all(
                            color: const Color(0xFF9C8BE8), width: 1.4)),
                  ),
                  const SizedBox(width: 10),
                  Text('Transit',
                      style: T.monoCard
                          .copyWith(color: const Color(0xFF55506A), fontSize: 13)),
                ]),
              ),
            ),
          )),
          const SizedBox(height: 4),
          Stack(clipBehavior: Clip.none, children: [
            Center(child: ChartWheel(size: w * .597, data: app)),
            Positioned(
              right: kSide,
              bottom: -22,
              child: GestureDetector(
                onTap: () => _fullChart(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: C.panel, shape: BoxShape.circle),
                  child: const Icon(Icons.open_in_full_rounded,
                      size: 13, color: Color(0xFF9C8BE8)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 26),
          _p(Row(children: [
            for (final (k, v) in [
              ('Güneş', app.sun),
              ('Ay', app.moon),
              ('Yükselen', app.asc)
            ])
              Expanded(
                child: Column(children: [
                  Text(k, style: T.body.copyWith(fontSize: 9.4)),
                  const SizedBox(height: 5),
                  Text(v, style: T.heading.copyWith(fontSize: 13.4)),
                ]),
              ),
          ])),
          const SizedBox(height: 28),
          _p(Divider(height: 1, color: C.line)),
          const SizedBox(height: 46),
          _p(Row(children: [
            Text('Rozetlerim', style: T.monoTitle),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => showInfo(context, 'Rozetler',
                  'Ana Sayfa’daki gökyüzü olaylarına dokun, etkisini oku ve rozeti koleksiyonuna ekle. Şu ana kadar ${app.badges.length} rozet kazandın.'),
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                        center: Alignment(-.4, -.4),
                        colors: [Color(0xFF9C8BE8), Color(0xFF4C35B5)])),
                child: const Center(
                    child: Text('?',
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: Colors.white))),
              ),
            ),
          ])),
          const SizedBox(height: 17),
          Padding(
              padding: const EdgeInsets.only(left: kSide + 15, right: kSide + 6),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final b in app.badges.toList().reversed.take(3))
                  DottedCircle(
                    size: 92,
                    fill: const Color(0xFFF3EFFF),
                    color: const Color(0xFF9C8BE8),
                    count: 60,
                    child: Sprite(
                        b.startsWith('streak')
                            ? 'star'
                            : b.startsWith('ingress')
                            ? 'sun'
                            : b.contains('saturn')
                                ? 'saturn'
                                : 'moon',
                        size: 40,
                        cells: 22),
                  ),
                for (var k = app.badges.length; k < 3; k++)
                  DottedCircle(
                    size: 92,
                    fill: C.panel,
                    color: Color(0xFFA3A2A8),
                    count: 60,
                    child: DotText('?',
                        pitch: 3.0, color: Color(0xFF8E8D93), glow: 0),
                  ),
              ])),
          const SizedBox(height: 33),
          _p(Divider(height: 1, color: C.line)),
          const SizedBox(height: 39),
          _p(Text('HARİTA İKİZLERİN', style: T.sectionLabel)),
          const SizedBox(height: 10),
          _p(Text('Haritan kimlere benziyor?', style: T.monoTitle)),
          const SizedBox(height: 28),
          SizedBox(
            height: 194,
            child: ListView.separated(
              controller: twinCtl,
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kSide),
              itemCount: app.twins.length,
              separatorBuilder: (_, __) => const SizedBox(width: 13),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: _TwinCard(app.twins[i]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _p(Divider(height: 1, color: C.line)),
          const SizedBox(height: 37),
          _p(Text('Bu ara senin için', style: T.monoTitle)),
          const SizedBox(height: 62),
          const _GiftBox(),
          const SizedBox(height: 30),
          _p(Divider(height: 1, color: C.line)),
          const SizedBox(height: 23),
          _p(Text('Araçlar', style: T.monoTitle)),
          const SizedBox(height: 16),
          for (final (pal, sp, k, t, sub, page) in [
            (Pal.purpleBand, 'star', 'PREMIUM', 'Uygun gün bulucu', 'İş, buluşma, taşınma için en iyi günler', const GoodDayFinder() as Widget),
            (Pal.amber, 'saturn', 'PREMIUM', 'Önümüzdeki 12 ay', 'Büyük gezegenlerin haritana etkisi', const YearForecast() as Widget),
            (Pal.rose, 'venus', 'ÜCRETSİZ', 'Hızlı uyum testi', 'Doğum tarihiyle uyumunu gör, paylaş', const QuickMatch() as Widget),
            (Pal.navy, 'moon', 'PAYLAŞ', 'Yılın özeti', 'Senin yılın tek kartta', const YearSummary() as Widget),
          ]) ...[
            _p(_NavBand(
                pal: pal,
                sprite: sp,
                kicker: k,
                title: t,
                sub: sub,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => page)))),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 9),
          _p(Divider(height: 1, color: C.line)),
          const SizedBox(height: 23),
          _p(_BirthCard(onEdit: () => editProfile(context))),
          const SizedBox(height: 23),
          _p(_NavBand(
            pal: Pal.plum,
            sprite: 'people',
            kicker: 'İLİŞKİLER',
            title: 'Arkadaşlar ve ilişkiler',
            sub: 'Doğum haritalarınızı karşılaştır',
            onTap: widget.openRelations,
          )),
          const SizedBox(height: 23),
          _p(_NavBand(
            pal: Pal.charcoal,
            sprite: 'gear',
            kicker: 'AYARLAR',
            title: 'Hesap ve gizlilik',
            sub: 'Premium, kullanıcı adı, verilerini yönet',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )),
        ],
      ),
    );
  }

  void _fullChart(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: C.page,
              insetPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Doğum haritan', style: T.monoTitleBold),
                  const SizedBox(height: 16),
                  ChartWheel(
                      size: MediaQuery.of(ctx).size.width - 64, data: app),
                  const SizedBox(height: 10),
                ]),
              ),
            ));
  }
}

Future<void> editProfile(BuildContext context) async {
  final pr = app.profile;
  final r = await birthForm(context,
      title: 'Profili düzenle',
      name: pr.name,
      birth: pr.birth,
      time: pr.time,
      place: pr.place,
      note: app.canEditBirth
          ? 'Yükselen ve evler bu bilgilerden hesaplanır. Doğum bilgisini ayda bir kez düzeltebilirsin.'
          : 'Doğum bilgisini bu ay düzelttin; şimdilik yalnızca ismini değiştirebilirsin.');
  if (r == null) return;
  final (n, b, t, pl, _) = r;
  final err = app.updateProfile(n, b, t, pl);
  if (err != null && context.mounted) showInfo(context, 'Değiştirilemedi', err);
}

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class _ArrowCircle extends StatelessWidget {
  const _ArrowCircle();
  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: .14)),
        child: const Icon(Icons.north_east_rounded, color: Colors.white, size: 18),
      );
}

class _TwinCard extends StatelessWidget {
  final Twin t;
  const _TwinCard(this.t);
  @override
  Widget build(BuildContext context) {
    final pal = switch (t.pal) {
      'rose' => Pal.rose,
      'amber' => Pal.amber,
      'navy' => Pal.navy,
      _ => Pal.deepGreen,
    };
    return SizedBox(
      width: 209,
      child: Pearl(
        pal: pal,
        radius: 22,
        sheenAt: const Alignment(.55, -.55),
        sheenSize: .6,
        shadowAlpha: .5,
        shadowBlur: 20,
        padding: const EdgeInsets.fromLTRB(18, 18, 0, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DotText('%${t.pct}', pitch: 3.4, dot: .74, glow: .2),
          const SizedBox(height: 14),
          Text(t.name,
              style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.8,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(t.job,
              style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 9.4,
                  color: Colors.white.withValues(alpha: .6))),
          const SizedBox(height: 12),
          DotLine(count: 30, filled: (30 * t.pct / 100 * 1.24).round().clamp(0, 30),
              size: 2.6, gap: 1.75, off: Colors.white.withValues(alpha: .2)),
          const SizedBox(height: 14),
          Text(t.common,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 9.8,
                  color: Colors.white.withValues(alpha: .72))),
        ]),
      ),
    );
  }
}

/// Havada duran 3B pembe kutu. Dokununca kapak açılır, öneri görünür.
class _GiftBox extends StatefulWidget {
  const _GiftBox();
  @override
  State<_GiftBox> createState() => _GiftBoxState();
}

class _GiftBoxState extends State<_GiftBox> with SingleTickerProviderStateMixin {
  late final AnimationController ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  bool open = false;

  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = app.today;
    final lines = [
      d.day.toString().padLeft(2, '0'),
      d.month.toString().padLeft(2, '0'),
      (d.year % 100).toString().padLeft(2, '0')
    ];
    return GestureDetector(
      onTap: () {
        setState(() => open = !open);
        if (open) {
          ac.forward();
          app.openBox();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted) {
              showInfo(context, 'Bugünün önerileri',
                  app.boxTips.map((t) => '• $t').join('\n\n'));
            }
          });
        } else {
          ac.reverse();
        }
      },
      child: Column(children: [
        SizedBox(
          width: 205,
          height: 278,
          child: AnimatedBuilder(
            animation: ac,
            builder: (_, __) => Stack(clipBehavior: Clip.none, children: [
              // zemine dağılan pembe gölge
              Positioned(
                left: 10,
                right: 30,
                bottom: -6,
                height: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFFF8CC8).withValues(alpha: .55),
                          blurRadius: 34,
                          spreadRadius: 4),
                    ],
                  ),
                ),
              ),
              // açıldığında çıkan kart
              Positioned(
                left: 22,
                width: 140,
                top: 30 - 120 * Curves.easeOutBack.transform(ac.value),
                height: 150,
                child: Opacity(
                  opacity: ac.value.clamp(0, 1),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: .12),
                              blurRadius: 14)
                        ]),
                    child: Text(app.boxTips[0],
                        style: T.body.copyWith(color: C.ink, fontSize: 12)),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _BoxPainter(ac.value),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, right: 26),
                    child: Column(
                      children: [
                        for (final l in lines) ...[
                          DotText(l, pitch: 6.0, dot: .68, glow: .5),
                          const SizedBox(height: 13),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 26,
                top: 24,
                child: Center(
                  child: Opacity(
                    opacity: 1 - ac.value,
                    child: const Text('emuastro',
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 8.8,
                            fontWeight: FontWeight.w500,
                            color: Color(0xE6FFFFFF))),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Text(open ? 'Bugünün önerisi' : 'Bugünün önerileri kutuda',
            style: T.monoCard.copyWith(color: C.ink, fontSize: 14.4)),
        const SizedBox(height: 7),
        Text(open ? 'Kapatmak için dokun' : 'Kutuyu açmak için dokun',
            style: T.body.copyWith(fontSize: 12.4)),
      ]),
    );
  }
}

class _BoxPainter extends CustomPainter {
  final double t;
  _BoxPainter(this.t) : super(repaint: Grain.ready);
  @override
  void paint(Canvas canvas, Size s) {
    // ön yüz: (0,6)-(164,6) ... (8,270)-(164,276)
    const fl = 2.0, fr = 164.0, ft = 6.0, fb = 262.0;
    final front = Path()
      ..moveTo(fl, ft)
      ..lineTo(fr, ft + 6)
      ..lineTo(fr, fb + 4)
      ..lineTo(fl + 6, fb - 4)
      ..close();
    // sağ yüz (parlak pembe)
    final right = Path()
      ..moveTo(fr, ft + 6)
      ..lineTo(fr + 28, ft - 6)
      ..lineTo(fr + 28, fb - 16)
      ..lineTo(fr, fb + 4)
      ..close();
    // üst yüz (ince)
    final top = Path()
      ..moveTo(fl, ft)
      ..lineTo(fl + 28, ft - 12)
      ..lineTo(fr + 28, ft - 6)
      ..lineTo(fr, ft + 6)
      ..close();
    canvas.drawPath(
        right,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF7BC4), Color(0xFFFD6CBB), Color(0xFFE85AA8)])
              .createShader(right.getBounds()));
    canvas.drawPath(top, Paint()..color = const Color(0xFFF07BB8));
    final fr0 = front.getBounds();
    canvas.save();
    canvas.clipPath(front);
    canvas.drawRect(
        fr0,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8E3561), Color(0xFFB97B94), Color(0xFF99687D), Color(0xFF6B2347)],
                  stops: [0, .45, .62, 1])
              .createShader(fr0));
    // sedef ışığı
    canvas.drawCircle(
        Offset(fr0.width * .62, fr0.height * .48),
        fr0.width * .7,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFF2C6DA).withValues(alpha: .45),
            const Color(0xFFF2C6DA).withValues(alpha: 0)
          ]).createShader(Rect.fromCircle(
              center: Offset(fr0.width * .62, fr0.height * .48),
              radius: fr0.width * .7)));
    paintGrain(canvas, fr0, opacity: .9);
    canvas.restore();
    // kapak (koyu vişne), açılırken yukarı kalkar
    canvas.save();
    canvas.translate(0, ft);
    final lidScale = 1 - t * 1.6;
    canvas.scale(1, lidScale.clamp(-1, 1));
    final lid = Path()
      ..moveTo(fl, 0)
      ..lineTo(fr, 6)
      ..lineTo(fr, 36)
      ..quadraticBezierTo(fr, 46, fr - 12, 45)
      ..lineTo(fl + 12, 41)
      ..quadraticBezierTo(fl + 2, 41, fl + 2, 31)
      ..close();
    canvas.drawPath(
        lid.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: .25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(
        lid,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7E1F50), Color(0xFF8A2A5C)])
              .createShader(lid.getBounds()));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoxPainter o) => o.t != t;
}

class _BirthCard extends StatelessWidget {
  final VoidCallback onEdit;
  const _BirthCard({required this.onEdit});
  @override
  Widget build(BuildContext context) {
    final pr = app.profile;
    return Pearl(
      pal: Pal.charcoal,
      radius: 26,
      shadowAlpha: .3,
      shadowBlur: 14,
      sheenAt: const Alignment(.6, -.8),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Doğum bilgilerim', style: T.monoCard.copyWith(fontSize: 14.6)),
          const Spacer(),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFF3A393F)),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 15),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        Center(child: DotText(_fmt(pr.birth), pitch: 6.0, dot: .7, glow: .55)),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(child: _cell('SAAT', pr.time)),
          const SizedBox(width: 13),
          Expanded(child: _cell('YER', pr.place)),
        ]),
        const SizedBox(height: 22),
        Text(
            'Yükselen ve evler bu bilgilerden hesaplanır. Yanlışsa ayda bir kez düzeltebilirsin.',
            style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 9.4,
                height: 1.3,
                color: Colors.white.withValues(alpha: .55))),
      ]),
    );
  }

  Widget _cell(String k, String v) => Container(
        height: 53,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: const Color(0xFF2B2A30),
            borderRadius: BorderRadius.circular(14)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k,
                  style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w800,
                      fontSize: 8.4,
                      letterSpacing: 1,
                      color: Colors.white.withValues(alpha: .55))),
              const SizedBox(height: 3),
              Text(v,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white)),
            ]),
      );
}

class _NavBand extends StatelessWidget {
  final Pal pal;
  final String sprite, kicker, title, sub;
  final VoidCallback onTap;
  const _NavBand(
      {required this.pal,
      required this.sprite,
      required this.kicker,
      required this.title,
      required this.sub,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 84,
          child: Pearl(
            pal: pal,
            radius: 22,
            sheenAt: const Alignment(.6, -.6),
            shadowAlpha: .45,
            shadowBlur: 16,
            child: Row(children: [
              const SizedBox(width: 22),
              Sprite(sprite, size: 30, cells: 20),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kicker, style: T.bandKicker),
                      const SizedBox(height: 4),
                      Text(title, style: T.monoCard.copyWith(fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(sub, style: T.bandSub),
                    ]),
              ),
              const _ArrowCircle(),
              const SizedBox(width: 18),
            ]),
          ),
        ),
      );
}
