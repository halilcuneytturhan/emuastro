import 'package:flutter/material.dart';

/// 5x7 nokta matrisi glifleri. Sıfır eğik çizgili, "1" tabanlı, "%" iki küçük halkalı.
const _glyphs = <String, List<String>>{
  '0': ['.111.', '1...1', '1..11', '1.1.1', '11..1', '1...1', '.111.'],
  '1': ['..1..', '.11..', '..1..', '..1..', '..1..', '..1..', '.111.'],
  '2': ['.111.', '1...1', '....1', '...1.', '..1..', '.1...', '11111'],
  '3': ['11111', '...1.', '..1..', '...1.', '....1', '1...1', '.111.'],
  '4': ['...1.', '..11.', '.1.1.', '1..1.', '11111', '...1.', '...1.'],
  '5': ['11111', '1....', '1111.', '....1', '....1', '1...1', '.111.'],
  '6': ['..11.', '.1...', '1....', '1111.', '1...1', '1...1', '.111.'],
  '7': ['11111', '....1', '...1.', '..1..', '.1...', '.1...', '.1...'],
  '8': ['.111.', '1...1', '1...1', '.111.', '1...1', '1...1', '.111.'],
  '9': ['.111.', '1...1', '1...1', '.1111', '....1', '...1.', '.11..'],
  '%': ['11...', '11..1', '...1.', '..1..', '.1...', '1..11', '...11'],
  '/': ['.....', '....1', '...1.', '..1..', '.1...', '1....', '.....'],
  '.': ['.', '.', '.', '.', '.', '.', '1'],
  '?': ['.111.', '1...1', '....1', '...1.', '..1..', '.....', '..1..'],
  ' ': ['..', '..', '..', '..', '..', '..', '..'],
};

/// Ölçeklenebilir nokta matrisi metin çizicisi.
class DotText extends StatelessWidget {
  final String text;
  final double pitch; // nokta aralığı
  final double dot; // nokta çapı oranı
  final Color color;
  final double glow;
  final bool dimPercent;
  const DotText(this.text,
      {super.key,
      this.pitch = 6.6,
      this.dot = 0.68,
      this.color = Colors.white,
      this.glow = 0.5,
      this.dimPercent = true});

  static int cols(String t) {
    var c = 0;
    for (final ch in t.split('')) {
      c += (_glyphs[ch]?[0].length ?? 5) + 1;
    }
    return c - 1;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(cols(text) * pitch, 7 * pitch),
      painter: _DotPainter(text, pitch, dot, color, glow, dimPercent),
    );
  }
}

class _DotPainter extends CustomPainter {
  final String t;
  final double p, d, glow;
  final Color c;
  final bool dimPercent;
  _DotPainter(this.t, this.p, this.d, this.c, this.glow, this.dimPercent);
  @override
  void paint(Canvas canvas, Size size) {
    final dotP = Paint()..color = c;
    final glowP = Paint()
      ..color = c.withValues(alpha: 0.35 * glow)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, p * 0.45);
    final dimP = Paint()..color = c.withValues(alpha: 0.62);
    var x = 0.0;
    for (final ch in t.split('')) {
      final g = _glyphs[ch] ?? _glyphs['?']!;
      for (var row = 0; row < 7; row++) {
        for (var col = 0; col < g[row].length; col++) {
          if (g[row][col] != '1') continue;
          final o = Offset(x + (col + 0.5) * p, (row + 0.5) * p);
          final dim = dimPercent && ch == '%' && (row < 2 || row > 4) &&
              ((col < 2 && row < 2) || (col > 2 && row > 4));
          if (glow > 0) canvas.drawCircle(o, p * d * 0.75, glowP);
          canvas.drawCircle(o, p * d / 2, dim ? dimP : dotP);
        }
      }
      x += (g[0].length + 1) * p;
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter o) =>
      o.t != t || o.p != p || o.c != c;
}

/// Noktalı çizgi (ilerleme ve kılavuz).
class DotLine extends StatelessWidget {
  final int count, filled;
  final double size, gap;
  final Color on, off;
  const DotLine(
      {super.key,
      required this.count,
      required this.filled,
      this.size = 2.6,
      this.gap = 1.6,
      this.on = Colors.white,
      this.off = const Color(0x40FFFFFF)});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            count,
            (i) => Container(
                  width: size,
                  height: size,
                  margin: EdgeInsets.only(right: i == count - 1 ? 0 : gap),
                  decoration: BoxDecoration(
                      color: i < filled ? on : off, shape: BoxShape.circle),
                )),
      );
}
