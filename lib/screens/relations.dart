import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sprites.dart';

class RelationsScreen extends StatefulWidget {
  final ScrollController controller;
  const RelationsScreen({super.key, required this.controller});
  @override
  State<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends State<RelationsScreen> {
  int seg = 0;
  final friends = <String>[];

  void _addFriend() async {
    final c = TextEditingController();
    final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: C.page,
              title: const Text('Arkadaş ekle', style: T.monoTitleBold),
              content: TextField(
                  controller: c,
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'Kullanıcı adı veya isim')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Vazgeç')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, c.text.trim()),
                    child: const Text('Ekle')),
              ],
            ));
    if (name != null && name.isNotEmpty) setState(() => friends.add(name));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(children: [
      ListView(
        controller: widget.controller,
        padding: EdgeInsets.only(top: top + 91, bottom: 150),
        children: seg == 0 ? _friends(context) : _soulmate(context),
      ),
      // kaydırırken üstte kalan segment kontrolü
      Positioned(
        top: top + 13,
        left: 0,
        right: 0,
        child: Center(child: _Segment(seg, (i) => setState(() => seg = i))),
      ),
    ]);
  }

  Widget _p(Widget w) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: kSide), child: w);

  List<Widget> _header(String label) => [
        _p(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: T.sectionLabel),
              const SizedBox(height: 9),
              const Text('İlişkiler', style: T.display),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: () => showInfo(context, 'Kullanıcı adı',
                    'Arkadaşların seni kullanıcı adınla bulabilir. Örn: @${app.profile.name}'),
                child: Row(children: [
                  const Sprite('at', size: 17, cells: 14),
                  const SizedBox(width: 7),
                  Text('Kullanıcı adı oluştur',
                      style: T.heading.copyWith(
                          color: C.accent, fontWeight: FontWeight.w700, fontSize: 13.4)),
                ]),
              ),
            ]),
          ),
          GestureDetector(
            onTap: _addFriend,
            child: Container(
              width: 67,
              height: 57,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: const Color(0xFFDCDAE2), width: .8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: const Center(child: DotPlus(size: 17)),
            ),
          ),
        ])),
      ];

  List<Widget> _friends(BuildContext context) => [
        ..._header('ARKADAŞLAR · İLİŞKİLER'),
        const SizedBox(height: 19),
        _p(const Text('Rehberinde EmuAstro\'da olanlar', style: T.heading)),
        const SizedBox(height: 10),
        _p(Container(
          padding: const EdgeInsets.fromLTRB(17, 22, 17, 18),
          decoration: BoxDecoration(
              color: C.panel, borderRadius: BorderRadius.circular(23)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const SizedBox(width: 6),
              const Sprite('book', size: 34, cells: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Rehberindeki arkadaşlarını bul',
                    style: T.heading.copyWith(fontSize: 14.2)),
              ),
            ]),
            const SizedBox(height: 16),
            Text(
                'Bağlarsan numaralar telefonunda şifrelenir; bu sürümde hiçbir veri sunucuya gönderilmez, rehberin kaydedilmez.',
                style: T.body.copyWith(fontSize: 12.8, height: 1.3)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => showInfo(context, 'Rehber erişimi',
                  'Rehber eşleştirmesi henüz etkin değil. Bu sürümde rehberine erişilmez ve sunucuya hiçbir numara ya da e-posta gönderilmez.'),
              child: Container(
                width: 134,
                height: 41,
                decoration: BoxDecoration(
                    color: const Color(0xFF7146F4),
                    borderRadius: BorderRadius.circular(21)),
                child: const Center(
                  child: Text('Rehberini bağla',
                      style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Colors.white)),
                ),
              ),
            ),
          ]),
        )),
        const SizedBox(height: 13),
        _p(GestureDetector(
          onTap: () => showInfo(context, 'Numaranı ekle',
              'Numaranı eklediğinde, rehberinde seni kayıtlı olanlar seni burada görebilir. Bu sürümde numara cihazda kalır.'),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
                color: C.panel, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const Sprite('phone', size: 28, cells: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Numaranı ekle',
                          style: T.heading.copyWith(fontSize: 13.6, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('Rehberinde seni kayıtlı olanlar seni burada görsün.',
                          style: T.body.copyWith(fontSize: 9.2, height: 1.2)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: Color(0xFF8E7AE8)),
            ]),
          ),
        )),
        const SizedBox(height: 25),
        _p(const Text('Eklediklerin', style: T.heading)),
        const SizedBox(height: 10),
        _p(SizedBox(
          height: 82,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            GestureDetector(
              onTap: _addFriend,
              child: const Column(children: [
                DottedCircle(size: 64, child: DotPlus(size: 18)),
                SizedBox(height: 4),
                Text('Ekle',
                    style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 9.6,
                        color: C.ink)),
              ]),
            ),
            for (final f in friends)
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Column(children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [Color(0xFF8E6BC9), Color(0xFF4C3585)])),
                    child: Center(
                        child: Text(f.characters.first.toUpperCase(),
                            style: T.monoTitleBold
                                .copyWith(color: Colors.white))),
                  ),
                  const SizedBox(height: 4),
                  Text(f,
                      style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 9.6,
                          color: C.ink)),
                ]),
              ),
          ]),
        )),
        const SizedBox(height: 14),
        _p(Row(children: [
          const SizedBox(width: 4),
          const Sprite('people', size: 30, cells: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
                'Arkadaşlarını ekle; doğum haritalarınızı karşılaştır, istersen ilişki raporu aç.',
                style: T.body.copyWith(fontSize: 12.8, height: 1.27)),
          ),
        ])),
        const SizedBox(height: 74),
        const Center(child: _Doodles(width: 262)),
        const SizedBox(height: 30),
        Center(
            child: Text('EmuAstro\'yu arkadaşına hediye et',
                style: T.heading.copyWith(fontSize: 16.2, fontWeight: FontWeight.w800))),
        const SizedBox(height: 7),
        _p(Text(
            'Arkadaşın 3 gün boyunca EmuAstro Premium\'u ücretsiz denesin.\nEn fazla 3 arkadaşına hediye gönderebilirsin.',
            textAlign: TextAlign.center,
            style: T.body.copyWith(fontSize: 12.4, height: 1.3))),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () {
              if (app.giftsLeft == 0) return;
              app.useGift();
              setState(() {});
              showInfo(context, 'Hediye hazır',
                  'Hediye kodun: EMU-${(1000 + app.giftsLeft * 371) % 9999}\nKodu arkadaşınla paylaş; 3 gün Premium açılır.');
            },
            child: Container(
              width: 151,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('Hediye gönder',
                      style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w800,
                          fontSize: 13.8,
                          color: Colors.white))),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
            child: Text('${app.giftsLeft} hediye hakkın kaldı',
                style: T.body.copyWith(
                    fontSize: 9.2, fontWeight: FontWeight.w600, color: C.grey))),
        const SizedBox(height: 15),
        Center(
          child: GestureDetector(
            onTap: () => showInfo(context, 'Hediye kodu',
                'Sana gelen kodu girerek 3 günlük Premium denemeni başlatabilirsin.'),
            child: Text('Sana hediye mi geldi? Kodu gir',
                style: T.body.copyWith(
                    fontSize: 10.4,
                    fontWeight: FontWeight.w700,
                    color: C.accent)),
          ),
        ),
      ];

  List<Widget> _soulmate(BuildContext context) => [
        ..._header('RUH EŞİ · İLİŞKİLER'),
        const SizedBox(height: 40),
        const Center(child: _Doodles(width: 220)),
        const SizedBox(height: 26),
        _p(Text('Ruh eşi raporu',
            textAlign: TextAlign.center,
            style: T.monoTitleBold)),
        const SizedBox(height: 10),
        _p(Text(
            'Partnerinin doğum bilgilerini ekle; Venüs, Mars ve Ay açılarına göre uyum haritanı çıkaralım.',
            textAlign: TextAlign.center,
            style: T.body.copyWith(fontSize: 12.8))),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _addFriend,
            child: Container(
              width: 170,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('Partner ekle',
                      style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w800,
                          fontSize: 13.8,
                          color: Colors.white))),
            ),
          ),
        ),
      ];
}

class _Segment extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _Segment(this.index, this.onTap);
  @override
  Widget build(BuildContext context) {
    const labels = ['Arkadaşlar', 'Ruh Eşi'];
    return Container(
      width: 192.5,
      height: 50.5,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [C.navTop, C.navBase]),
        border: Border.all(color: Colors.white.withValues(alpha: .35), width: .8),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF8E6CF5).withValues(alpha: .35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: index == 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: 102,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: .16),
              border: Border.all(color: Colors.white.withValues(alpha: .55)),
            ),
          ),
        ),
        Row(children: [
          for (var i = 0; i < 2; i++)
            Expanded(
              flex: i == 0 ? 102 : 80,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Center(
                    child: Text(labels[i],
                        style: T.nav.copyWith(
                            fontWeight:
                                i == index ? FontWeight.w700 : FontWeight.w500))),
              ),
            ),
        ]),
      ]),
    );
  }
}

/// Siyah noktalarla çizilmiş gök karakterleri.
class _Doodles extends StatelessWidget {
  final double width;
  const _Doodles({required this.width});
  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(width, width * 154 / 262), painter: _DoodleP());
}

class _DoodleP extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 262;
    canvas.scale(k);
    final dot = Paint()..color = C.ink;
    void dots(Path p, {double step = 3.6, double r = .95}) {
      for (final m in p.computeMetrics()) {
        for (var d = 0.0; d < m.length; d += step) {
          final t = m.getTangentForOffset(d);
          if (t != null) canvas.drawCircle(t.position, r, dot);
        }
      }
    }

    Path circle(double x, double y, double r) =>
        Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
    void face(double x, double y, double s, {bool wink = false}) {
      canvas.drawCircle(Offset(x - s * .35, y - s * .15), 1.7 * s / 8 + .6, dot);
      if (wink) {
        dots(Path()
          ..moveTo(x + s * .15, y - s * .1)
          ..quadraticBezierTo(x + s * .35, y - s * .4, x + s * .55, y - s * .1), step: 2.2, r: .8);
      } else {
        canvas.drawCircle(Offset(x + s * .35, y - s * .15), 1.7 * s / 8 + .6, dot);
      }
      final sm = Path()
        ..moveTo(x - s * .4, y + s * .2)
        ..quadraticBezierTo(x, y + s * .62, x + s * .4, y + s * .2);
      dots(sm, step: 2.2, r: .8);
    }

    void line(List<Offset> pts, {double step = 3.6}) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      dots(p, step: step);
    }

    // Halkalı gezegen
    dots(circle(50, 52, 24));
    final ring = Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: 88, height: 22));
    final m = Matrix4.identity()
      ..translateByDouble(42, 55, 0, 1)
      ..rotateZ(-.2);
    dots(ring.transform(m.storage));
    face(50, 52, 9);
    line([const Offset(2, 39), const Offset(16, 52)]); // kol
    line([const Offset(40, 76), const Offset(32, 154)]);
    line([const Offset(58, 76), const Offset(66, 154)]);
    line([const Offset(32, 154), const Offset(25, 154)]);
    line([const Offset(66, 154), const Offset(72, 154)]);

    // Damla
    final drop = Path()
      ..moveTo(130, 0)
      ..cubicTo(136, 20, 155, 40, 155, 60)
      ..arcToPoint(const Offset(105, 60), radius: const Radius.circular(25))
      ..cubicTo(105, 40, 124, 20, 130, 0);
    dots(drop);
    face(130, 60, 9);
    line([const Offset(124, 85), const Offset(122, 98)]);
    line([const Offset(136, 85), const Offset(138, 98)]);
    // alt küçük yuvarlak
    dots(circle(130, 115, 17));
    face(130, 114, 7);
    line([const Offset(120, 130), const Offset(116, 154), const Offset(110, 154)]);
    line([const Offset(140, 130), const Offset(144, 154), const Offset(150, 154)]);

    // Güneş
    final sun = Path();
    for (var i = 0; i <= 64; i++) {
      final a = i * math.pi * 2 / 64;
      final r = 26 + (i.isEven ? 3.5 : 0);
      final o = Offset(204 + math.cos(a) * r, 47 + math.sin(a) * r);
      i == 0 ? sun.moveTo(o.dx, o.dy) : sun.lineTo(o.dx, o.dy);
    }
    dots(sun, step: 3.2);
    face(204, 47, 9, wink: true);
    line([const Offset(228, 52), const Offset(250, 44), const Offset(262, 30)]);
    line([const Offset(196, 76), const Offset(196, 100), const Offset(186, 154), const Offset(180, 154)]);
    line([const Offset(212, 76), const Offset(214, 154), const Offset(220, 154)]);

    // Hilal
    final moon = Path()
      ..moveTo(66, 82)
      ..arcToPoint(const Offset(104, 110), radius: const Radius.circular(26), clockwise: false)
      ..arcToPoint(const Offset(70, 92), radius: const Radius.circular(22));
    dots(moon);
    face(78, 104, 6);
    line([const Offset(74, 124), const Offset(70, 154)]);
    line([const Offset(88, 124), const Offset(90, 154)]);

    // Yıldız
    final star = Path();
    for (var i = 0; i <= 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? 22.0 : 10.0;
      final o = Offset(173 + math.cos(a) * r, 108 + math.sin(a) * r);
      i == 0 ? star.moveTo(o.dx, o.dy) : star.lineTo(o.dx, o.dy);
    }
    dots(star, step: 3.2);
    face(173, 108, 6);
    line([const Offset(168, 126), const Offset(162, 154)]);
    line([const Offset(178, 126), const Offset(182, 154)]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

