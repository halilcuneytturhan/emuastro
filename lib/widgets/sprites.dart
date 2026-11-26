import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pikselli, hacimli, metalik görünümlü özel ikonlar.
/// Her ikon SDF katmanlarından oluşur; ışık sol üstten gelir,
/// ton geçişleri 4x4 Bayer düzenli dither ile pikselleştirilir.
typedef Sdf = double Function(double x, double y);

class _Layer {
  final Sdf sdf;
  final List<Color> ramp;
  final Offset? sphereC; // küre normali için
  final double sphereR;
  final double pillow;
  final double bias;
  const _Layer(this.sdf, this.ramp,
      {this.sphereC, this.sphereR = 1, this.pillow = 0.25, this.bias = 0});
}

const _bayer = [
  [0, 8, 2, 10],
  [12, 4, 14, 6],
  [3, 11, 1, 9],
  [15, 7, 13, 5]
];

// Paletler (koyu -> aydınlık)
const rampMoon = [
  Color(0xFF1C1450), Color(0xFF34298A), Color(0xFF5546BE), Color(0xFF8576E0),
  Color(0xFFB9AFF5), Color(0xFFF4F1FF)
];
const rampGold = [
  Color(0xFF5E3F06), Color(0xFF9A6C0E), Color(0xFFD09D1F), Color(0xFFEFC64A),
  Color(0xFFFBE58E), Color(0xFFFFFBE6)
];
const rampViolet = [
  Color(0xFF241466), Color(0xFF3E25A8), Color(0xFF6243D8), Color(0xFF8F74F0),
  Color(0xFFC6B6FB), Color(0xFFF5F0FF)
];
const rampBlue = [
  Color(0xFF0A1866), Color(0xFF16349F), Color(0xFF2856D8), Color(0xFF5B8AF5),
  Color(0xFFA9C4FF), Color(0xFFEFF5FF)
];
const rampSteel = [
  Color(0xFF2E2E36), Color(0xFF55555F), Color(0xFF85858F), Color(0xFFB8B8C2),
  Color(0xFFE2E2EA), Color(0xFFFFFFFF)
];
const rampRed = [
  Color(0xFF4E0A0A), Color(0xFF8E1616), Color(0xFFCB2B23), Color(0xFFEE5A45),
  Color(0xFFFFA58F), Color(0xFFFFEDE6)
];
const rampOrange = [
  Color(0xFF5A2604), Color(0xFF9A4A0A), Color(0xFFD27417), Color(0xFFF0A040),
  Color(0xFFFFD08E), Color(0xFFFFF4E4)
];
const rampPink = [
  Color(0xFF5C0A30), Color(0xFF9A1A55), Color(0xFFD23C80), Color(0xFFF07AAE),
  Color(0xFFFFC2DC), Color(0xFFFFF1F7)
];
const rampIndigo = [
  Color(0xFF0E0A2E), Color(0xFF221A5C), Color(0xFF3A3090), Color(0xFF6458BE),
  Color(0xFFA79DE6), Color(0xFFEDEAFF)
];
const rampLilac = [
  Color(0xFF3A2A7A), Color(0xFF6A55C0), Color(0xFF9C8BE8), Color(0xFFC7BCF8),
  Color(0xFFE9E3FF), Color(0xFFFFFFFF)
];

double _circle(double x, double y, double cx, double cy, double r) =>
    math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy)) - r;
double _box(double x, double y, double cx, double cy, double hw, double hh,
    double r) {
  final qx = (x - cx).abs() - hw + r, qy = (y - cy).abs() - hh + r;
  final ox = math.max(qx, 0.0), oy = math.max(qy, 0.0);
  return math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0.0) - r;
}

double _sub(double a, double b) => math.max(a, -b);
double _uni(double a, double b) => math.min(a, b);

List<_Layer> _layers(String kind) {
  switch (kind) {
    case 'moon':
      return [
        _Layer((x, y) => _sub(_circle(x, y, 0, 0, .78), _circle(x, y, .42, -.3, .66)),
            rampMoon,
            sphereC: Offset.zero, sphereR: .78, bias: .05)
      ];
    case 'moonSmall':
      return [
        _Layer((x, y) => _sub(_circle(x, y, 0, 0, .8), _circle(x, y, .38, -.28, .7)),
            rampViolet,
            sphereC: Offset.zero, sphereR: .8)
      ];
    case 'sun':
      return [
        _Layer((x, y) => _circle(x, y, 0, 0, .72), rampGold,
            sphereC: Offset.zero, sphereR: .72)
      ];
    case 'saturn':
      return [
        _Layer((x, y) {
          final rx = x * .94 + y * .34, ry = -x * .34 + y * .94;
          final e = math.sqrt(rx * rx / (.98 * .98) + ry * ry / (.3 * .3));
          return (e - 1).abs() * .28 - .05 + (ry < 0 ? 0 : 1); // arka halka
        }, rampLilac, pillow: .1),
        _Layer((x, y) => _circle(x, y, 0, 0, .5), rampViolet,
            sphereC: Offset.zero, sphereR: .5),
        _Layer((x, y) {
          final rx = x * .94 + y * .34, ry = -x * .34 + y * .94;
          final e = math.sqrt(rx * rx / (.98 * .98) + ry * ry / (.3 * .3));
          return (e - 1).abs() * .28 - .05 + (ry >= 0 ? 0 : 1); // ön halka
        }, rampLilac, pillow: .1, bias: .1),
      ];
    case 'star':
      return [
        _Layer((x, y) {
          final v = math.pow(x.abs(), .55) + math.pow((y * 1.05).abs(), .55);
          return (v - .92) * .6;
        }, rampLilac, pillow: .35, bias: .05),
      ];
    case 'bell':
      return [
        _Layer((x, y) {
          final dome = _circle(x, y * 1.1, 0, -.12, .5);
          final body = _box(x, y, 0, .18, .5 - (y - .18) * -.25, .26, .05);
          final rim = _box(x, y, 0, .48, .72, .1, .1);
          final top = _circle(x, y, 0, -.72, .1);
          return _uni(_uni(_uni(dome, body), rim), top);
        }, rampGold, pillow: .35),
        _Layer((x, y) => _circle(x, y, 0, .7, .14), rampGold,
            sphereC: const Offset(0, .7), sphereR: .14),
      ];
    case 'lock':
      return [
        _Layer((x, y) {
          final ring = (_circle(x, y, 0, -.18, .38)).abs() - .11;
          return y < -.05 ? ring : 9;
        }, rampSteel, pillow: .12),
        _Layer((x, y) => _box(x, y, 0, .35, .56, .42, .14), rampSteel,
            pillow: .4),
        _Layer((x, y) => _uni(_circle(x, y, 0, .28, .1), _box(x, y, 0, .42, .04, .12, .02)),
            const [Color(0xFF1E1E24), Color(0xFF2A2A30)], pillow: .05),
      ];
    case 'pencil':
      return [
        _Layer((x, y) {
          final rx = (x + y) * .7071, ry = (y - x) * .7071;
          final body = _box(rx, ry, -.05, 0, .58, .16, .04);
          return body;
        }, rampGold, pillow: .14),
        _Layer((x, y) {
          final rx = (x + y) * .7071, ry = (y - x) * .7071;
          return _box(rx, ry, .62, 0, .1, .16 - (rx - .52) * 1.3 * .5, .01)
              .clamp(-1.0, 1.0);
        }, rampOrange, pillow: .08),
        _Layer((x, y) {
          final rx = (x + y) * .7071, ry = (y - x) * .7071;
          return _box(rx, ry, -.7, 0, .09, .16, .03);
        }, rampPink, pillow: .08),
      ];
    case 'gear':
      return [
        _Layer((x, y) {
          final a = math.atan2(y, x);
          final r = math.sqrt(x * x + y * y);
          final teeth = .66 + .14 * (math.cos(a * 8) > 0 ? 1 : -.2);
          return _sub(r - teeth, r - .26);
        }, rampViolet, pillow: .3),
      ];
    case 'book':
      return [
        _Layer((x, y) => _box(x, y, .05, 0, .62, .8, .12), rampViolet,
            pillow: .3),
        _Layer((x, y) => _box(x, y, -.6, 0, .07, .78, .05), rampIndigo,
            pillow: .1),
        _Layer((x, y) {
          final head = _circle(x, y, .06, -.2, .2);
          final body = _sub(_circle(x, y, .06, .5, .36), -(y - .5));
          return _uni(head, body);
        }, rampLilac, pillow: .15, bias: .25),
      ];
    case 'phone':
      return [
        _Layer((x, y) => _box(x, y, 0, 0, .42, .85, .2), rampBlue, pillow: .3),
        _Layer((x, y) => _box(x, y, 0, -.02, .3, .68, .08), rampIndigo,
            pillow: .1, bias: .15),
      ];
    case 'at':
      return [
        _Layer((x, y) {
          final r = math.sqrt(x * x + y * y);
          final outer = (r - .58).abs() - .14;
          final inner = (_circle(x, y, 0, 0, .22)).abs() - .12;
          final gap = (x > .2 && y > -.05 && y < .2) ? 1.0 : 0.0;
          return math.max(_uni(outer, inner), -gap + 0.0 * gap) +
              (gap > 0 && outer < 0 && inner > 0 ? .2 : 0);
        }, rampGold, pillow: .14),
      ];
    case 'people':
      return [
        _Layer((x, y) => _uni(_circle(x, y, .3, -.38, .2),
                _sub(_circle(x, y, .3, .35, .38), -(y - .32))),
            rampLilac, pillow: .2),
        _Layer((x, y) => _uni(_circle(x, y, -.2, -.2, .24),
                _sub(_circle(x, y, -.2, .62, .48), -(y - .55))),
            rampViolet, pillow: .25),
      ];
    case 'mercury':
      return [_sph(rampSteel, .62)];
    case 'venus':
      return [_sph(rampPink, .62)];
    case 'mars':
      return [_sph(rampRed, .62)];
    case 'jupiter':
      return [_sph(rampOrange, .62)];
    case 'uranus':
    case 'blue':
      return [_sph(rampBlue, .62)];
    case 'neptune':
      return [_sph(rampLilac, .62)];
    case 'pluto':
      return [_sph(rampIndigo, .62)];
    case 'violet':
      return [_sph(rampViolet, .62)];
    case 'gold':
      return [_sph(rampGold, .62)];
    default:
      return [_sph(rampViolet, .62)];
  }
}

_Layer _sph(List<Color> r, double rad) =>
    _Layer((x, y) => _circle(x, y, 0, 0, rad), r,
        sphereC: Offset.zero, sphereR: rad);

class Sprite extends StatelessWidget {
  final String kind;
  final double size;
  final double? cells;
  final bool shadow;
  const Sprite(this.kind,
      {super.key, this.size = 32, this.cells, this.shadow = true});
  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: _SpritePainter(
              kind, (cells ?? (size / 1.25)).clamp(12, 40).roundToDouble(), shadow),
        ),
      );
}

class _SpritePainter extends CustomPainter {
  final String kind;
  final double n;
  final bool shadow;
  _SpritePainter(this.kind, this.n, this.shadow);

  @override
  void paint(Canvas canvas, Size size) {
    final layers = _layers(kind);
    final cell = size.width / n;
    final N = n.toInt();
    const l = [-0.55, -0.65, 0.52]; // ışık yönü (sol üst, öne)
    final ll = math.sqrt(l[0] * l[0] + l[1] * l[1] + l[2] * l[2]);
    if (shadow) {
      final sp = Paint()
        ..color = const Color(0x33251560)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * .06);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(size.width * .52, size.height * .9),
              width: size.width * .62,
              height: size.height * .12),
          sp);
    }
    final paint = Paint();
    for (var j = 0; j < N; j++) {
      for (var i = 0; i < N; i++) {
        final x = ((i + .5) / n) * 2 - 1, y = ((j + .5) / n) * 2 - 1;
        Color? col;
        for (final L in layers) {
          final d = L.sdf(x, y);
          if (d > 0) continue;
          double nx, ny, nz;
          if (L.sphereC != null) {
            nx = (x - L.sphereC!.dx) / L.sphereR;
            ny = (y - L.sphereC!.dy) / L.sphereR;
            final q = 1 - nx * nx - ny * ny;
            nz = math.sqrt(math.max(q, 0.0));
          } else {
            double h(double a, double b) =>
                math.sqrt((-L.sdf(a, b) / L.pillow).clamp(0.0, 1.0));
            const e = .04;
            final dx = (h(x + e, y) - h(x - e, y)) / (2 * e);
            final dy = (h(x, y + e) - h(x, y - e)) / (2 * e);
            nx = -dx * .35;
            ny = -dy * .35;
            nz = 1;
            final m = math.sqrt(nx * nx + ny * ny + nz * nz);
            nx /= m;
            ny /= m;
            nz /= m;
          }
          var v = (nx * l[0] + ny * l[1] + nz * l[2]) / ll;
          // speküler parlama
          final spec = math.pow(math.max(v, 0.0), 18).toDouble();
          v = (v * .5 + .5) * .85 + spec * .5 + L.bias;
          // koyu alt yüzey için yansıyan ışık
          if (ny > .6) v += .06;
          final steps = L.ramp.length;
          final t = (_bayer[j % 4][i % 4] / 16.0 - .5) * 0.9;
          final idx = (v * (steps - 1) + t).round().clamp(0, steps - 1);
          col = L.ramp[idx];
        }
        if (col == null) continue;
        paint.color = col;
        canvas.drawRect(
            Rect.fromLTWH(i * cell, j * cell, cell + .35, cell + .35), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpritePainter o) =>
      o.kind != kind || o.n != n;
}
