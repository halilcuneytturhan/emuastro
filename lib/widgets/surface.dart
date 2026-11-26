import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Tek seferde üretilen, döşenen sabit gren dokusu (kaydırmada yeniden üretilmez).
class Grain {
  static ui.Image? image;
  static ui.Image? paper;
  static final ready = ValueNotifier<bool>(false);

  static Future<void> init() async {
    image = await _make(192, 7, 0.11);
    paper = await _make(256, 11, 0.035);
    ready.value = true;
  }

  static Future<ui.Image> _make(int n, int seed, double alpha) {
    final r = math.Random(seed);
    final px = Uint8List(n * n * 4);
    for (var i = 0; i < n * n; i++) {
      final v = r.nextDouble();
      final light = v > 0.5;
      final a = ((v - 0.5).abs() * 2);
      final al = (a * a * alpha * 255).round();
      final c = light ? al : 0; // ön-çarpılmış alfa
      px[i * 4] = c;
      px[i * 4 + 1] = c;
      px[i * 4 + 2] = c;
      px[i * 4 + 3] = al;
    }
    final comp = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, n, n, ui.PixelFormat.rgba8888,
        (img) => comp.complete(img));
    return comp.future;
  }
}

void paintGrain(Canvas canvas, Rect r, {double opacity = 1, ui.Image? img}) {
  final g = img ?? Grain.image;
  if (g == null) return;
  final m = Matrix4.identity()..scaleByDouble(0.5, 0.5, 1, 1);
  final p = Paint()
    ..shader = ImageShader(g, TileMode.repeated, TileMode.repeated, m.storage,
        filterQuality: FilterQuality.none)
    ..color = Colors.white.withValues(alpha: opacity);
  canvas.drawRect(r, p);
}

typedef PathFn = Path Function(Size s);

Path rrectPath(Size s, double r) =>
    Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(r)));

/// Simli, sedefli kart yüzeyi.
class PearlPainter extends CustomPainter {
  final Pal pal;
  final PathFn shape;
  final Alignment sheenAt;
  final double sheenSize;
  final double shadowBlur, shadowY, shadowAlpha;
  final double grain;
  final Alignment lightFrom;
  final double sheenAngle, sheenStretch;
  PearlPainter(this.pal, this.shape,
      {this.sheenAt = const Alignment(0.35, 0.1),
      this.sheenSize = 0.6,
      this.shadowBlur = 22,
      this.shadowY = 10,
      this.shadowAlpha = 0.55,
      this.grain = 0.9,
      this.lightFrom = Alignment.topLeft,
      this.sheenAngle = -0.55,
      this.sheenStretch = 1.7})
      : super(repaint: Grain.ready);

  @override
  void paint(Canvas canvas, Size s) {
    final path = shape(s);
    final r = Offset.zero & s;
    // zemine düşen renkli gölge
    if (shadowAlpha > 0) {
      canvas.drawPath(
          path.shift(Offset(0, shadowY)),
          Paint()
            ..color = pal.shadow.withValues(alpha: shadowAlpha)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur));
    }
    canvas.save();
    canvas.clipPath(path);
    // temel geçiş
    canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
                  begin: lightFrom,
                  end: -lightFrom,
                  colors: [pal.light, pal.base, pal.dark],
                  stops: const [0, 0.5, 1])
              .createShader(r));
    // sedef yansıması: geniş, yumuşak, hafif düzensiz iki leke
    final c = sheenAt.alongSize(s);
    final rad = s.shortestSide * sheenSize + s.longestSide * 0.15;
    void blob(Offset o, double rr, double a, double sx) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(sheenAngle);
      canvas.scale(sx, 1);
      canvas.drawCircle(
          Offset.zero,
          rr,
          Paint()
            ..shader = RadialGradient(colors: [
              pal.sheen.withValues(alpha: a),
              pal.sheen.withValues(alpha: a * 0.45),
              pal.sheen.withValues(alpha: 0)
            ], stops: const [0, 0.45, 1])
                .createShader(Rect.fromCircle(center: Offset.zero, radius: rr)));
      canvas.restore();
    }

    blob(c, rad, pal.sheenStrength * 0.9, sheenStretch);
    blob(c + Offset(rad * 0.45, rad * 0.35), rad * 0.55,
        pal.sheenStrength * 0.55, 1.3);
    blob(c - Offset(rad * 0.5, rad * 0.1), rad * 0.4, pal.sheenStrength * 0.35,
        1.1);
    // köşe koyuluğu
    canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(
                  center: const Alignment(-0.1, -0.2),
                  radius: 1.05,
                  colors: [Colors.transparent, pal.dark.withValues(alpha: 0.42)],
                  stops: const [0.55, 1])
              .createShader(r));
    // ince gren
    paintGrain(canvas, r, opacity: grain);
    canvas.restore();
    // ince kenar aydınlığı
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.38),
                Colors.white.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.12),
              ]).createShader(r));
  }

  @override
  bool shouldRepaint(covariant PearlPainter o) =>
      o.pal != pal || o.sheenAt != sheenAt;
}

class Pearl extends StatelessWidget {
  final Pal pal;
  final double radius;
  final PathFn? shape;
  final Widget? child;
  final Alignment sheenAt;
  final double sheenSize, shadowAlpha, shadowBlur, shadowY;
  final EdgeInsets padding;
  final Alignment lightFrom;
  final double sheenAngle, sheenStretch;
  const Pearl(
      {super.key,
      required this.pal,
      this.radius = 22,
      this.shape,
      this.child,
      this.sheenAt = const Alignment(0.35, 0.1),
      this.sheenSize = 0.6,
      this.shadowAlpha = 0.55,
      this.shadowBlur = 22,
      this.shadowY = 10,
      this.lightFrom = Alignment.topLeft,
      this.sheenAngle = -0.55,
      this.sheenStretch = 1.7,
      this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      isComplex: true,
      willChange: false,
      painter: PearlPainter(pal, shape ?? (s) => rrectPath(s, radius),
          sheenAt: sheenAt,
          sheenSize: sheenSize,
          shadowAlpha: shadowAlpha,
          shadowBlur: shadowBlur,
          shadowY: shadowY,
          lightFrom: lightFrom,
          sheenAngle: sheenAngle,
          sheenStretch: sheenStretch),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Dosya silueti: solda yüksek kulak, yuvarlatılmış eğimle sağa alçalır.
Path folderPath(Size s,
    {double tabStart = 0,
    required double tabEnd,
    double tabH = 35,
    double slope = 30,
    double r = 24,
    double tr = 16}) {
  final p = Path();
  final x0 = tabStart;
  final x1 = tabEnd;
  p.moveTo(x0, tabH + r);
  if (x0 == 0) {
    p.lineTo(0, tr);
    p.quadraticBezierTo(0, 0, tr, 0);
  } else {
    // arka dosya: gövde üst kenarı soldan başlar
    p.moveTo(0, tabH + r);
    p.quadraticBezierTo(0, tabH, r, tabH);
    p.lineTo(x0 - slope * 0.2, tabH);
    p.cubicTo(x0 + slope * 0.25, tabH, x0 + slope * 0.2, 0,
        x0 + slope * 0.75, 0);
  }
  final topStart = x0 == 0 ? tr : x0 + slope * 0.75;
  p.lineTo(math.max(topStart, x1 - slope * 0.55), 0);
  p.cubicTo(x1 - slope * 0.05, 0, x1 + slope * 0.1, tabH, x1 + slope * 0.95,
      tabH);
  p.lineTo(s.width - r, tabH);
  p.quadraticBezierTo(s.width, tabH, s.width, tabH + r);
  p.lineTo(s.width, s.height - r);
  p.quadraticBezierTo(s.width, s.height, s.width - r, s.height);
  p.lineTo(r, s.height);
  p.quadraticBezierTo(0, s.height, 0, s.height - r);
  p.close();
  return p;
}

/// Hafif kâğıt dokulu sayfa zemini.
class PaperBackground extends StatelessWidget {
  final Widget child;
  const PaperBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PaperPainter(),
        child: child,
      );
}

class _PaperPainter extends CustomPainter {
  _PaperPainter() : super(repaint: Grain.ready);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = C.page);
    paintGrain(canvas, r, img: Grain.paper);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
