import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// EmuFit ile aynı alt gezinme dili: ekranı neredeyse kenardan kenara
/// kaplayan açık buzlu cam kapsül, yalnız ikonlar, seçili sekmenin
/// arkasında yumuşak gri hap, dokununca içe çöküp yaylanan ikon.
/// Ölçüler EmuFit `HomeBottomNavigation` ile birebir: yükseklik 63,
/// iç boşluk 7, yan boşluk 48.
class EmuNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const EmuNavBar(
      {super.key, required this.selectedIndex, required this.onSelected});

  static const double barHeight = 63;
  static const double _inset = 7;
  static const double _side = 48;

  static const _vibrancy = <double>[
    1.4724, -0.4291, -0.0433, 0, 0, //
    -0.1276, 1.1709, -0.0433, 0, 0, //
    -0.1276, -0.4291, 1.5567, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  static const items = <(NavGlyph, String)>[
    (NavGlyph.home, 'Ana Sayfa'),
    (NavGlyph.people, 'İlişkiler'),
    (NavGlyph.chat, 'Sor'),
    (NavGlyph.profile, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    const fg = Color(0xFF111312);
    final radius = BorderRadius.circular(barHeight / 2);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_side, 0, _side, 4),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: radius, boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4)),
          ]),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.compose(
                outer: const ColorFilter.matrix(_vibrancy),
                inner: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.42),
                    borderRadius: radius),
                child: CustomPaint(
                  foregroundPainter: const _RimPainter(),
                  child: SizedBox(
                    height: barHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(_inset),
                      child: LayoutBuilder(builder: (context, c) {
                        final w = c.maxWidth / items.length;
                        final pill = w * 0.92;
                        return Stack(children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 340),
                            curve: Curves.easeOutCubic,
                            left: (w * (selectedIndex + .5) - pill / 2)
                                .clamp(0.0, c.maxWidth - pill),
                            top: 0,
                            bottom: 0,
                            width: pill,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(
                                    (barHeight - _inset * 2) / 2),
                              ),
                            ),
                          ),
                          Row(children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _NavItem(
                                  glyph: items[i].$1,
                                  label: items[i].$2,
                                  selected: i == selectedIndex,
                                  color: fg,
                                  onTap: () {
                                    if (i != selectedIndex) {
                                      HapticFeedback.selectionClick();
                                    }
                                    onSelected(i);
                                  },
                                ),
                              ),
                          ]),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final NavGlyph glyph;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _NavItem(
      {required this.glyph,
      required this.label,
      required this.selected,
      required this.color,
      required this.onTap});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final _bounce = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 28),
    TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 72),
  ]).animate(_bounce);

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _bounce.forward(from: 0);
          widget.onTap();
        },
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: CustomPaint(
              size: const Size.square(26),
              painter: _GlyphPainter(widget.glyph, widget.color, widget.selected),
            ),
          ),
        ),
      ),
    );
  }
}

enum NavGlyph { home, people, chat, profile }

/// SF Symbols tarzı ince çizgili ikonlar: pasifken çizgi, aktifken dolu.
class _GlyphPainter extends CustomPainter {
  final NavGlyph g;
  final Color color;
  final bool filled;
  const _GlyphPainter(this.g, this.color, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    switch (g) {
      case NavGlyph.home:
        final body = Path()
          ..moveTo(4.5, 10.2)
          ..lineTo(12, 4)
          ..lineTo(19.5, 10.2)
          ..lineTo(19.5, 18.5)
          ..arcToPoint(const Offset(18, 20), radius: const Radius.circular(1.5))
          ..lineTo(6, 20)
          ..arcToPoint(const Offset(4.5, 18.5),
              radius: const Radius.circular(1.5))
          ..close();
        final door = RRect.fromLTRBAndCorners(9.8, 14, 14.2, 20,
            topLeft: const Radius.circular(1.2),
            topRight: const Radius.circular(1.2));
        if (filled) {
          final p = Path.combine(
              PathOperation.difference, body, Path()..addRRect(door));
          canvas.drawPath(p, fill);
          canvas.drawPath(p, stroke);
        } else {
          canvas.drawPath(body, stroke);
          canvas.drawLine(const Offset(9.8, 20), const Offset(9.8, 15.2), stroke);
          canvas.drawLine(
              const Offset(14.2, 20), const Offset(14.2, 15.2), stroke);
          canvas.drawArc(const Rect.fromLTRB(9.8, 14, 14.2, 16.4), 3.14159,
              3.14159, false, stroke);
        }
        canvas.drawLine(const Offset(2.8, 11.6), const Offset(12, 3.9), stroke);
        canvas.drawLine(const Offset(12, 3.9), const Offset(21.2, 11.6), stroke);
      case NavGlyph.people:
        void person(Offset head, double r, double l, double rt, double top,
            double bottom) {
          final sh = Path()
            ..moveTo(l, bottom)
            ..cubicTo(l, top + 2.3, (l + rt) / 2 - 3, top, (l + rt) / 2, top)
            ..cubicTo((l + rt) / 2 + 3, top, rt, top + 2.3, rt, bottom);
          if (filled) {
            canvas.drawCircle(head, r, fill);
            canvas.drawPath(Path.from(sh)..close(), fill);
          }
          canvas.drawPath(sh, stroke);
          canvas.drawCircle(head, r, stroke);
        }
        person(const Offset(16.4, 8.2), 2.6, 13.4, 21.4, 13.2, 18.6);
        person(const Offset(9, 8.6), 3.2, 2.8, 15.2, 14.2, 20);
      case NavGlyph.chat:
        final b = Path()
          ..addRRect(RRect.fromLTRBR(3, 4.5, 21, 16.5, const Radius.circular(5)))
          ..moveTo(7.5, 16.5)
          ..lineTo(6.5, 20.5)
          ..lineTo(11.5, 16.5);
        if (filled) canvas.drawPath(b, fill);
        canvas.drawPath(b, stroke);
        // küçük yıldız: astroloji asistanı
        final st = Path();
        const c = Offset(12, 10.5);
        for (var i = 0; i < 8; i++) {
          final r = i.isEven ? 3.2 : 1.0;
          final a = -1.5708 + i * 0.7854;
          final o = c + Offset(r * math.cos(a), r * math.sin(a));
          i == 0 ? st.moveTo(o.dx, o.dy) : st.lineTo(o.dx, o.dy);
        }
        st.close();
        canvas.drawPath(
            st, Paint()..color = filled ? Colors.white : color);
      case NavGlyph.profile:
        const head = Offset(12, 8);
        final sh = Path()
          ..moveTo(4.8, 20)
          ..cubicTo(4.8, 16.2, 7.8, 13.9, 12, 13.9)
          ..cubicTo(16.2, 13.9, 19.2, 16.2, 19.2, 20);
        if (filled) {
          canvas.drawCircle(head, 3.6, fill);
          canvas.drawPath(Path.from(sh)..close(), fill);
        }
        canvas.drawPath(sh, stroke);
        canvas.drawCircle(head, 3.6, stroke);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter o) =>
      o.g != g || o.color != color || o.filled != filled;
}

class _RimPainter extends CustomPainter {
  const _RimPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(.5), Radius.circular(size.height / 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: .95),
                Colors.black.withValues(alpha: .06),
                Colors.black.withValues(alpha: .08),
              ],
              stops: const [0, .5, 1]).createShader(rect));
  }

  @override
  bool shouldRepaint(_RimPainter o) => false;
}
