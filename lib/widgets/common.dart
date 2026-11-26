import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sample.dart';
import '../theme.dart';
import 'sprites.dart';
import 'surface.dart';

const kSide = 20.5; // referanstan ölçülen dış boşluk (44px / 2.1465)

/// Etkinlik bantlarının sağındaki "ROZET KAZAN" rozeti.
class EventBadge extends StatelessWidget {
  final String kind;
  final Pal pal;
  final double size;
  final bool locked;
  const EventBadge(this.kind, this.pal,
      {super.key, this.size = 62, this.locked = true});
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(children: [
        CustomPaint(size: Size.square(size), painter: _BadgeRing(pal)),
        Center(
            child: Sprite(kind == 'moon' ? 'moonSmall' : kind,
                size: size * .2, cells: 12, shadow: false)),
        if (locked)
        Positioned(
            right: size * .17,
            bottom: size * .2,
            child: _MiniLock(size: size * .2)),
      ]),
    );
  }
}

class _MiniLock extends StatelessWidget {
  final double size;
  const _MiniLock({required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
            color: Color(0xFF26222A), shape: BoxShape.circle),
        child: CustomPaint(painter: _LockGlyph()),
      );
}

class _LockGlyph extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.white;
    final w = s.width;
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .32, w * .46, w * .36, w * .28),
            Radius.circular(w * .04)),
        p);
    c.drawArc(Rect.fromLTWH(w * .37, w * .26, w * .26, w * .32), math.pi, math.pi,
        false, p..style = PaintingStyle.stroke..strokeWidth = w * .07);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _BadgeRing extends CustomPainter {
  final Pal pal;
  _BadgeRing(this.pal);
  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final R = s.width / 2;
    // dış çember boyunca "ROZET KAZAN · ROZET KAZAN ·"
    const text = 'ROZET KAZAN · ROZET KAZAN · ';
    final chars = text.split('');
    final style = TextStyle(
        fontFamily: 'Figtree',
        fontWeight: FontWeight.w800,
        fontSize: R * .2,
        color: Colors.white,
        letterSpacing: 0);
    final step = 2 * math.pi / chars.length;
    for (var i = 0; i < chars.length; i++) {
      final a = -math.pi / 2 + i * step + .35;
      final tp = TextPainter(
          text: TextSpan(text: chars[i], style: style),
          textDirection: TextDirection.ltr)
        ..layout();
      canvas.save();
      canvas.translate(c.dx + math.cos(a) * R * .86, c.dy + math.sin(a) * R * .86);
      canvas.rotate(a + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    // madalyon
    final mr = R * .6;
    canvas.drawCircle(
        c + const Offset(0, 1.5),
        mr,
        Paint()
          ..color = Colors.black.withValues(alpha: .25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5));
    canvas.drawCircle(
        c,
        mr,
        Paint()
          ..shader = RadialGradient(
                  center: const Alignment(-.4, -.5),
                  colors: [
                    Color.lerp(pal.light, const Color(0xFFF1ECE0), .6)!,
                    Color.lerp(pal.base, const Color(0xFF8F8676), .55)!,
                    Color.lerp(pal.dark, const Color(0xFF3A342B), .6)!
                  ],
                  stops: const [0, .55, 1])
              .createShader(Rect.fromCircle(center: c, radius: mr)));
    canvas.drawCircle(
        c,
        mr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: .45));
    // ince noktalı iç halka
    final dp = Paint()..color = Colors.white.withValues(alpha: .7);
    for (var i = 0; i < 40; i++) {
      final a = i * 2 * math.pi / 40;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * mr * .78, .45, dp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Gökyüzü etkinlik bandı.
class EventBand extends StatelessWidget {
  final SkyEvent e;
  final Pal pal;
  final VoidCallback? onTap;
  const EventBand(this.e, this.pal, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 93,
        child: Pearl(
          pal: pal,
          radius: 22,
          sheenAt: const Alignment(-.1, -1.2),
          sheenSize: .5,
          shadowAlpha: .55,
          shadowBlur: 16,
          shadowY: 6,
          lightFrom: Alignment.topCenter,
          child: Row(children: [
            const SizedBox(width: 22),
            Sprite(e.kind, size: 40, cells: 24),
            const SizedBox(width: 15),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(e.kicker, style: T.bandKicker),
                  const SizedBox(height: 4),
                  Text(e.title, style: T.bandTitle),
                  const SizedBox(height: 3),
                  Text(e.sub, style: T.bandSub),
                ])),
            EventBadge(e.kind, pal, locked: !app.badges.contains(e.key)),
            const SizedBox(width: 18),
          ]),
        ),
      ),
    );
  }
}

/// Paylaşım ikonu (kutu + yukarı ok)
class ShareIcon extends StatelessWidget {
  final Color color;
  final double size;
  const ShareIcon({super.key, this.color = Colors.white, this.size = 15});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * 1.2), painter: _SharePainter(color));
}

class _SharePainter extends CustomPainter {
  final Color c;
  _SharePainter(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * .11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = s.width, h = s.height;
    final box = Path()
      ..moveTo(w * .3, h * .38)
      ..lineTo(w * .08, h * .38)
      ..lineTo(w * .08, h * .95)
      ..lineTo(w * .92, h * .95)
      ..lineTo(w * .92, h * .38)
      ..lineTo(w * .7, h * .38);
    canvas.drawPath(box, p);
    canvas.drawLine(Offset(w / 2, h * .05), Offset(w / 2, h * .62), p);
    canvas.drawPath(
        Path()
          ..moveTo(w * .28, h * .24)
          ..lineTo(w / 2, h * .05)
          ..lineTo(w * .72, h * .24),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Noktalardan oluşan artı.
class DotPlus extends StatelessWidget {
  final double size;
  const DotPlus({super.key, this.size = 18});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _DotPlusP());
}

class _DotPlusP extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = C.ink;
    final u = s.width / 6;
    for (var i = -3; i <= 3; i++) {
      final r = i == 0 ? u * .62 : (i.abs() == 3 ? u * .36 : u * .46);
      c.drawCircle(s.center(Offset(i * u * .95, 0)), r, p);
      if (i != 0) c.drawCircle(s.center(Offset(0, i * u * .95)), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Noktalı daire çerçeve.
class DottedCircle extends StatelessWidget {
  final double size;
  final Widget? child;
  final Color color;
  final Color? fill;
  final int count;
  const DottedCircle(
      {super.key,
      required this.size,
      this.child,
      this.color = const Color(0xFF7A7980),
      this.fill,
      this.count = 44});
  @override
  Widget build(BuildContext context) => SizedBox.square(
      dimension: size,
      child: CustomPaint(
          painter: _DottedCircleP(color, fill, count),
          child: Center(child: child)));
}

class _DottedCircleP extends CustomPainter {
  final Color c;
  final Color? fill;
  final int n;
  _DottedCircleP(this.c, this.fill, this.n);
  @override
  void paint(Canvas canvas, Size s) {
    final ctr = s.center(Offset.zero);
    final r = s.width / 2 - 1.2;
    if (fill != null) canvas.drawCircle(ctr, r, Paint()..color = fill!);
    final p = Paint()..color = c;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawCircle(ctr + Offset(math.cos(a), math.sin(a)) * r, .95, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Üst üste iki beyaz konuşma balonu.
class ChatGlyph extends StatelessWidget {
  final double size;
  const ChatGlyph({super.key, this.size = 30});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * .82), painter: _ChatP());
}

class _ChatP extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final white = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = const Color(0xFFAC91FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .06;
    Path bubble(Rect r, bool tailLeft) {
      final p = Path()
        ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.height * .32)));
      final tx = tailLeft ? r.left + r.width * .2 : r.right - r.width * .2;
      p.moveTo(tx - w * .06, r.bottom - 1);
      p.lineTo(tx + (tailLeft ? -w * .07 : w * .07), r.bottom + h * .18);
      p.lineTo(tx + (tailLeft ? w * .1 : -w * .1), r.bottom - 1);
      return p;
    }

    final back = bubble(Rect.fromLTWH(0, 0, w * .66, h * .56), true);
    canvas.drawPath(back, white);
    final front = bubble(Rect.fromLTWH(w * .28, h * .24, w * .7, h * .56), false);
    canvas.drawPath(front, stroke);
    canvas.drawPath(front, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

void showInfo(BuildContext context, String title, String body) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
      decoration: BoxDecoration(
          color: C.page, borderRadius: BorderRadius.circular(28)),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: C.greyLight,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 18),
            Text(title, style: T.monoTitleBold),
            const SizedBox(height: 10),
            Text(body, style: T.body.copyWith(fontSize: 14, color: C.ink)),
          ]),
    ),
  );
}
