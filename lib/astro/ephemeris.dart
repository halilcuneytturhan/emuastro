import 'dart:math' as math;

/// Düşük hassasiyetli efemeris (Paul Schlyter yöntemi, ~1-2 yay dakikası).
/// Tüm boylamlar tarihin ekinoksuna göre, tropikal zodyak, derece.
const planetIds = [
  'sun', 'moon', 'mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus',
  'neptune', 'pluto', 'node', 'lilith'
];

double _rev(double x) => x - 360 * (x / 360).floorToDouble();
double _sin(double d) => math.sin(d * math.pi / 180);
double _cos(double d) => math.cos(d * math.pi / 180);
double _atan2(double y, double x) => math.atan2(y, x) * 180 / math.pi;

/// 2000 Ocak 0.0 UT'den bu yana gün.
double dayNumber(DateTime utc) {
  final ms = utc.millisecondsSinceEpoch;
  return ms / 86400000.0 + 2440587.5 - 2451543.5;
}

class _El {
  final double n, i, w, a, e, m;
  _El(this.n, this.i, this.w, this.a, this.e, this.m);
}

_El _elements(String p, double d) {
  switch (p) {
    case 'mercury':
      return _El(48.3313 + 3.24587e-5 * d, 7.0047 + 5.00e-8 * d,
          29.1241 + 1.01444e-5 * d, 0.387098, 0.205635 + 5.59e-10 * d,
          168.6562 + 4.0923344368 * d);
    case 'venus':
      return _El(76.6799 + 2.46590e-5 * d, 3.3946 + 2.75e-8 * d,
          54.8910 + 1.38374e-5 * d, 0.723330, 0.006773 - 1.302e-9 * d,
          48.0052 + 1.6021302244 * d);
    case 'mars':
      return _El(49.5574 + 2.11081e-5 * d, 1.8497 - 1.78e-8 * d,
          286.5016 + 2.92961e-5 * d, 1.523688, 0.093405 + 2.516e-9 * d,
          18.6021 + 0.5240207766 * d);
    case 'jupiter':
      return _El(100.4542 + 2.76854e-5 * d, 1.3030 - 1.557e-7 * d,
          273.8777 + 1.64505e-5 * d, 5.20256, 0.048498 + 4.469e-9 * d,
          19.8950 + 0.0830853001 * d);
    case 'saturn':
      return _El(113.6634 + 2.38980e-5 * d, 2.4886 - 1.081e-7 * d,
          339.3939 + 2.97661e-5 * d, 9.55475, 0.055546 - 9.499e-9 * d,
          316.9670 + 0.0334442282 * d);
    case 'uranus':
      return _El(74.0005 + 1.3978e-5 * d, 0.7733 + 1.9e-8 * d,
          96.6612 + 3.0565e-5 * d, 19.18171 - 1.55e-8 * d,
          0.047318 + 7.45e-9 * d, 142.5905 + 0.011725806 * d);
    case 'neptune':
      return _El(131.7806 + 3.0173e-5 * d, 1.7700 - 2.55e-7 * d,
          272.8461 - 6.027e-6 * d, 30.05826 + 3.313e-8 * d,
          0.008606 + 2.15e-9 * d, 260.2471 + 0.005995147 * d);
    case 'moon':
      return _El(125.1228 - 0.0529538083 * d, 5.1454,
          318.0634 + 0.1643573223 * d, 60.2666, 0.054900,
          115.3654 + 13.0649929509 * d);
    default: // sun
      return _El(0, 0, 282.9404 + 4.70935e-5 * d, 1.0,
          0.016709 - 1.151e-9 * d, 356.0470 + 0.9856002585 * d);
  }
}

double _kepler(double mDeg, double e) {
  final m = _rev(mDeg) * math.pi / 180;
  var ea = m + e * math.sin(m) * (1 + e * math.cos(m));
  for (var k = 0; k < 8; k++) {
    ea = ea - (ea - e * math.sin(ea) - m) / (1 - e * math.cos(ea));
  }
  return ea;
}

/// Yörüngedeki (v+w ve r) konum: (lon, lat, r) yörünge düzleminden ekliptiğe.
(double, double, double) _orbit(_El el) {
  final ea = _kepler(el.m, el.e);
  final xv = el.a * (math.cos(ea) - el.e);
  final yv = el.a * math.sqrt(1 - el.e * el.e) * math.sin(ea);
  final v = _atan2(yv, xv);
  final r = math.sqrt(xv * xv + yv * yv);
  final vw = v + el.w;
  final xh = r * (_cos(el.n) * _cos(vw) - _sin(el.n) * _sin(vw) * _cos(el.i));
  final yh = r * (_sin(el.n) * _cos(vw) + _cos(el.n) * _sin(vw) * _cos(el.i));
  final zh = r * _sin(vw) * _sin(el.i);
  final lon = _rev(_atan2(yh, xh));
  final lat = _atan2(zh, math.sqrt(xh * xh + yh * yh));
  return (lon, lat, r);
}

/// Jeosantrik ekliptik boylam.
double geoLongitude(String p, double d) {
  final sun = _elements('sun', d);
  final (sLon, _, sR) = _orbit(sun);
  if (p == 'sun') return sLon;
  if (p == 'node') return _rev(125.1228 - 0.0529538083 * d);
  if (p == 'lilith') {
    return _rev(125.1228 + 318.0634 + (0.1643573223 - 0.0529538083) * d + 180);
  }
  if (p == 'moon') {
    final el = _elements('moon', d);
    var (lon, _, _) = _orbit(el);
    final ms = _rev(sun.m), mm = _rev(el.m);
    final ls = _rev(sun.m + sun.w), lm = _rev(el.m + el.w + el.n);
    final dd = _rev(lm - ls), f = _rev(lm - el.n);
    lon += -1.274 * _sin(mm - 2 * dd) +
        0.658 * _sin(2 * dd) -
        0.186 * _sin(ms) -
        0.059 * _sin(2 * mm - 2 * dd) -
        0.057 * _sin(mm - 2 * dd + ms) +
        0.053 * _sin(mm + 2 * dd) +
        0.046 * _sin(2 * dd - ms) +
        0.041 * _sin(mm - ms) -
        0.035 * _sin(dd) -
        0.031 * _sin(mm + ms) -
        0.015 * _sin(2 * f - 2 * dd) +
        0.011 * _sin(mm - 4 * dd);
    return _rev(lon);
  }
  double lon, lat, r;
  if (p == 'pluto') {
    final s = 50.03 + 0.033459652 * d, pp = 238.95 + 0.003968789 * d;
    lon = 238.9508 + 0.00400703 * d - 19.799 * _sin(pp) + 19.848 * _cos(pp) +
        0.897 * _sin(2 * pp) - 4.956 * _cos(2 * pp) + 0.610 * _sin(3 * pp) +
        1.211 * _cos(3 * pp) - 0.341 * _sin(4 * pp) - 0.190 * _cos(4 * pp) +
        0.128 * _sin(5 * pp) - 0.034 * _cos(5 * pp) - 0.038 * _sin(6 * pp) +
        0.031 * _cos(6 * pp) + 0.020 * _sin(s - pp) - 0.010 * _cos(s - pp);
    lat = -3.9082 - 5.453 * _sin(pp) - 14.975 * _cos(pp) + 3.527 * _sin(2 * pp) +
        1.673 * _cos(2 * pp) - 1.051 * _sin(3 * pp) + 0.328 * _cos(3 * pp) +
        0.179 * _sin(4 * pp) - 0.292 * _cos(4 * pp) + 0.019 * _sin(5 * pp) +
        0.100 * _cos(5 * pp) - 0.031 * _sin(6 * pp) - 0.026 * _cos(6 * pp) +
        0.011 * _cos(s - pp);
    r = 40.72 + 6.68 * _sin(pp) + 6.90 * _cos(pp) - 1.18 * _sin(2 * pp) -
        0.03 * _cos(2 * pp) + 0.15 * _sin(3 * pp) - 0.14 * _cos(3 * pp);
    lon += 3.82e-5 * d; // J2000 -> tarih ekinoksu
  } else {
    final el = _elements(p, d);
    (lon, lat, r) = _orbit(el);
    final mj = _elements('jupiter', d).m,
        msa = _elements('saturn', d).m,
        mu = _elements('uranus', d).m;
    if (p == 'jupiter') {
      lon += -0.332 * _sin(2 * mj - 5 * msa - 67.6) -
          0.056 * _sin(2 * mj - 2 * msa + 21) +
          0.042 * _sin(3 * mj - 5 * msa + 21) -
          0.036 * _sin(mj - 2 * msa) +
          0.022 * _cos(mj - msa) +
          0.023 * _sin(2 * mj - 3 * msa + 52) -
          0.016 * _sin(mj - 5 * msa - 69);
    } else if (p == 'saturn') {
      lon += 0.812 * _sin(2 * mj - 5 * msa - 67.6) -
          0.229 * _cos(2 * mj - 4 * msa - 2) +
          0.119 * _sin(mj - 2 * msa - 3) +
          0.046 * _sin(2 * mj - 6 * msa - 69) +
          0.014 * _sin(mj - 3 * msa + 32);
      lat += -0.020 * _cos(2 * mj - 4 * msa - 2) +
          0.018 * _sin(2 * mj - 6 * msa - 49);
    } else if (p == 'uranus') {
      lon += 0.040 * _sin(msa - 2 * mu + 6) +
          0.035 * _sin(msa - 3 * mu + 33) -
          0.015 * _sin(mj - mu + 20);
    }
  }
  final xh = r * _cos(lon) * _cos(lat), yh = r * _sin(lon) * _cos(lat);
  final xg = xh + sR * _cos(sLon), yg = yh + sR * _sin(sLon);
  return _rev(_atan2(yg, xg));
}

class PlanetPos {
  final String id;
  final double lon;
  final bool retro;
  const PlanetPos(this.id, this.lon, this.retro);
  int get sign => (lon / 30).floor() % 12;
  double get degInSign => lon % 30;
}

List<PlanetPos> positions(DateTime utc) {
  final d = dayNumber(utc);
  return [
    for (final p in planetIds)
      () {
        final a = geoLongitude(p, d - .5), b = geoLongitude(p, d + .5);
        var diff = b - a;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        final retro = p == 'node' || (p != 'lilith' && diff < 0);
        return PlanetPos(p, geoLongitude(p, d), retro);
      }()
  ];
}

/// Yükselen ve MC (derece).
(double asc, double mc) angles(DateTime utc, double latDeg, double lonEastDeg) {
  final d = dayNumber(utc);
  final jd = d + 2451543.5;
  final gmst = _rev(280.46061837 + 360.98564736629 * (jd - 2451545.0));
  final ramc = _rev(gmst + lonEastDeg);
  final eps = 23.4393 - 3.563e-7 * d;
  final asc = _rev(_atan2(_cos(ramc),
      -(_sin(ramc) * _cos(eps) + math.tan(latDeg * math.pi / 180) * _sin(eps))));
  final mc = _rev(_atan2(_sin(ramc), _cos(ramc) * _cos(eps)));
  return (asc, mc);
}

double angDist(double a, double b) {
  final x = (a - b).abs() % 360;
  return x > 180 ? 360 - x : x;
}

/// İki boylam arasındaki açı türü (orb içinde) ya da null.
(String, double)? aspectBetween(double a, double b, {double orbScale = 1}) {
  final dist = angDist(a, b);
  const asp = {
    'kavuşum': (0.0, 8.0),
    'altmışlık': (60.0, 4.0),
    'kare': (90.0, 6.5),
    'üçgen': (120.0, 6.5),
    'karşıtlık': (180.0, 8.0),
  };
  for (final e in asp.entries) {
    final o = (dist - e.value.$1).abs();
    if (o <= e.value.$2 * orbScale) return (e.key, o);
  }
  return null;
}
