import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';

import '../data/sample.dart';
import 'sprites.dart';
import 'common.dart' show showInfo;
import '../astro/interpret.dart' show planetName, signs;

Map<String, String> get planetMeaning => {
  'sun': tr('Özün, kimliğin ve yaşam enerjin. Nerede parlamak istediğini gösterir.'),
  'moon': tr('Duyguların, ihtiyaçların ve güvende hissetme biçimin.'),
  'mercury': tr('Düşünme, konuşma ve öğrenme tarzın.'),
  'venus': tr('Sevgi dilin, zevklerin ve değer verdiklerin.'),
  'mars': tr('Enerjin, arzuların ve harekete geçme biçimin.'),
  'jupiter': tr('Şansın, büyüme alanın ve inançların.'),
  'saturn': tr('Sorumlulukların, sınırların ve olgunlaştığın alan.'),
  'uranus': tr('Özgürlük isteğin ve ani değişimler.'),
  'neptune': tr('Hayallerin, sezgilerin ve ilham kaynağın.'),
  'pluto': tr('Dönüşüm gücün ve derin tutkuların.'),
  'node': tr('Ruhsal yönün: bu hayatta büyümeye çağrıldığın yol.'),
  'lilith': tr('Bastırılan arzular ve bağımsızlık ihtiyacı.'),
};

const _signGlyph = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
const planetGlyph = {
  'sun': '☉', 'moon': '☽', 'mercury': '☿', 'venus': '♀', 'mars': '♂',
  'jupiter': '♃', 'saturn': '♄', 'uranus': '♅', 'neptune': '♆', 'pluto': '♇',
  'node': '☊', 'lilith': '⚸', 'chiron': '⚷'
};
const _sprite = {
  'sun': 'gold', 'moon': 'moonSmall', 'mercury': 'mercury', 'venus': 'venus',
  'mars': 'mars', 'jupiter': 'jupiter', 'saturn': 'saturn', 'uranus': 'blue',
  'neptune': 'neptune', 'pluto': 'pluto', 'node': 'star', 'lilith': 'star',
  'chiron': 'star'
};

/// Veriden çizilen doğum haritası.
class ChartWheel extends StatelessWidget {
  final double size;
  final AppData data;
  const ChartWheel({super.key, required this.size, required this.data});

  Offset _pos(double lon, double r) {
    final th = math.pi + (lon - data.ascLon) * math.pi / 180;
    return Offset(size / 2 + math.cos(th) * r, size / 2 - math.sin(th) * r);
  }

  @override
  Widget build(BuildContext context) {
    final R = size / 2;
    final children = <Widget>[
      RepaintBoundary(
        child: CustomPaint(
            size: Size.square(size), painter: _WheelPainter(data, size)),
      ),
    ];
    // burç diskleri
    for (var i = 0; i < 12; i++) {
      final o = _pos(i * 30 + 15, R * .9);
      children.add(Positioned(
        left: o.dx - 12,
        top: o.dy - 12,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF6D4ECF).withValues(alpha: .25),
                    blurRadius: 3)
              ]),
          child: Center(
              child: Text(_signGlyph[i],
                  style: const TextStyle(
                      fontSize: 11.5,
                      height: 1,
                      color: Color(0xFF4A2FB0),
                      fontFamilyFallback: ['Noto Sans Symbols', 'Apple Symbols']))),
        ),
      ));
    }
    // gezegenler: metalik küreler + glif
    final placed = <double>[];
    for (final p in data.planets) {
      var lon = p.lon;
      for (final q in placed) {
        if ((q - lon).abs() < 7) lon = q + 7;
      }
      placed.add(lon);
      final small = p.id == 'node' || p.id == 'lilith' || p.id == 'chiron';
      final o = _pos(lon, R * (small ? .7 : .63));
      final s = small ? 12.0 : 19.0;
      children.add(Positioned(
          left: o.dx - s / 2,
          top: o.dy - s / 2,
          child: Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => showInfo(ctx, planetName[p.id] ?? p.id,
                  '${signs[(p.lon ~/ 30) % 12]} ${(p.lon % 30).toStringAsFixed(0)}°${p.retro ? ' · retro' : ''} · ${l('${data.chart.house(p.lon)}. ev', 'house ${data.chart.house(p.lon)}')}\n\n${planetMeaning[p.id] ?? ''}'),
              child: Sprite(_sprite[p.id]!, size: s, cells: small ? 10 : 15, shadow: false),
            ),
          )));
      final g = _pos(lon + 4, R * .5);
      children.add(Positioned(
        left: g.dx - 6,
        top: g.dy - 6,
        child: SizedBox(
          width: 18,
          height: 12,
          child: Text('${planetGlyph[p.id]}${p.retro ? 'ᴿ' : ''}',
              style: const TextStyle(
                  fontSize: 7.5,
                  height: 1,
                  color: Color(0xFF6F6A85),
                  fontFamilyFallback: ['Noto Sans Symbols', 'Apple Symbols'])),
        ),
      ));
    }
    if (data.transit) {
      for (final (i, l) in [12.0, 98.0, 187.0, 241.0, 300.0].indexed) {
        final o = _pos(l, R * 1.04);
        children.add(Positioned(
            left: o.dx - 5,
            top: o.dy - 5,
            child: Sprite(['gold', 'mars', 'venus', 'violet', 'blue'][i],
                size: 10, cells: 9, shadow: false)));
      }
    }
    return SizedBox.square(
        dimension: size, child: Stack(clipBehavior: Clip.none, children: children));
  }
}

class _WheelPainter extends CustomPainter {
  final AppData d;
  final double size;
  _WheelPainter(this.d, this.size);

  Offset _pos(double lon, double r) {
    final th = math.pi + (lon - d.ascLon) * math.pi / 180;
    return Offset(size / 2 + math.cos(th) * r, size / 2 - math.sin(th) * r);
  }

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final R = s.width / 2;
    final ringIn = R * .82;
    // pikselli dama halkası
    const cell = 2.4;
    final lav = Paint()..color = const Color(0xFF8B6CF0);
    final lavLight = Paint()..color = const Color(0xFFC9BCFA);
    for (var y = -R; y < R; y += cell) {
      for (var x = -R; x < R; x += cell) {
        final r = math.sqrt((x + cell / 2) * (x + cell / 2) + (y + cell / 2) * (y + cell / 2));
        if (r > R || r < ringIn) continue;
        final t = (r - ringIn) / (R - ringIn); // 0 iç, 1 dış
        final ix = (x / cell).round(), iy = (y / cell).round();
        final checker = (ix + iy).isEven;
        // kenarlara yakın yoğun, ortada daha açık dama
        final edge = t < .14 || t > .86;
        if (edge) {
          canvas.drawRect(Rect.fromLTWH(c.dx + x, c.dy + y, cell + .2, cell + .2), lav);
        } else if (checker) {
          canvas.drawRect(Rect.fromLTWH(c.dx + x, c.dy + y, cell + .2, cell + .2),
              (ix % 4 == 0 && iy % 4 == 0) ? lav : lavLight);
        }
      }
    }
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFFB7A8EE);
    // iç daire ve ev çizgileri (eşit ev)
    final inner = R * .37;
    canvas.drawCircle(c, inner, thin);
    canvas.drawCircle(c, inner * .78, thin..color = const Color(0xFFD4CAF6));
    thin.color = const Color(0xFFB7A8EE);
    for (var h = 0; h < 12; h++) {
      final lon = d.ascLon + h * 30;
      canvas.drawLine(_pos(lon, inner), _pos(lon, ringIn), thin);
      final np = _pos(lon + 15, inner * .89);
      final tp = TextPainter(
          text: TextSpan(
              text: '${h + 1}',
              style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 6.2,
                  color: Color(0xFF55506A))),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, np - Offset(tp.width / 2, tp.height / 2));
    }
    // ASC çizgisi ve derece işaretleri
    final ascP = Paint()
      ..color = const Color(0xFF7A5AF0)
      ..strokeWidth = 1.4;
    canvas.drawLine(_pos(d.ascLon, inner), _pos(d.ascLon, R * 1.08), ascP);
    canvas.drawLine(_pos(d.ascLon + 180, inner), _pos(d.ascLon + 180, ringIn), ascP);
    for (var deg = 0; deg < 360; deg += 5) {
      canvas.drawLine(_pos(deg.toDouble(), ringIn), _pos(deg.toDouble(), ringIn - (deg % 30 == 0 ? 5 : 2.5)),
          thin);
    }
    // açı çizgileri
    double lonOf(String id) => d.planets.firstWhere((p) => p.id == id).lon;
    for (final (a, b, col) in d.aspects) {
      canvas.drawLine(
          _pos(lonOf(a), inner),
          _pos(lonOf(b), inner),
          Paint()
            ..strokeWidth = 1.1
            ..color = col == 'pink'
                ? const Color(0xFFEC6FA8)
                : const Color(0xFF7B5AE6));
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter o) => true;
}
