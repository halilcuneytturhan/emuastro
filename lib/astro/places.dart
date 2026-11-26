/// Doğum yeri: enlem/boylam ve saat dilimi kuralı.
class Place {
  final String name;
  final double lat, lon;
  final double std; // standart saat farkı (saat)
  final String dst; // 'tr' | 'eu' | 'us' | 'none'
  const Place(this.name, this.lat, this.lon, this.std, this.dst);
}

const places = <Place>[
  Place('İstanbul, Türkiye', 41.01, 28.98, 2, 'tr'),
  Place('Ankara, Türkiye', 39.93, 32.86, 2, 'tr'),
  Place('İzmir, Türkiye', 38.42, 27.14, 2, 'tr'),
  Place('Bursa, Türkiye', 40.19, 29.06, 2, 'tr'),
  Place('Antalya, Türkiye', 36.90, 30.70, 2, 'tr'),
  Place('Adana, Türkiye', 37.00, 35.32, 2, 'tr'),
  Place('Konya, Türkiye', 37.87, 32.48, 2, 'tr'),
  Place('Gaziantep, Türkiye', 37.07, 37.38, 2, 'tr'),
  Place('Şanlıurfa, Türkiye', 37.16, 38.79, 2, 'tr'),
  Place('Kocaeli, Türkiye', 40.77, 29.92, 2, 'tr'),
  Place('Mersin, Türkiye', 36.80, 34.63, 2, 'tr'),
  Place('Diyarbakır, Türkiye', 37.91, 40.24, 2, 'tr'),
  Place('Kayseri, Türkiye', 38.73, 35.48, 2, 'tr'),
  Place('Eskişehir, Türkiye', 39.78, 30.52, 2, 'tr'),
  Place('Samsun, Türkiye', 41.29, 36.33, 2, 'tr'),
  Place('Trabzon, Türkiye', 41.00, 39.72, 2, 'tr'),
  Place('Erzurum, Türkiye', 39.90, 41.27, 2, 'tr'),
  Place('Van, Türkiye', 38.49, 43.38, 2, 'tr'),
  Place('Malatya, Türkiye', 38.35, 38.31, 2, 'tr'),
  Place('Denizli, Türkiye', 37.78, 29.09, 2, 'tr'),
  Place('Sakarya, Türkiye', 40.78, 30.40, 2, 'tr'),
  Place('Muğla, Türkiye', 37.22, 28.36, 2, 'tr'),
  Place('Tekirdağ, Türkiye', 40.98, 27.51, 2, 'tr'),
  Place('Edirne, Türkiye', 41.68, 26.56, 2, 'tr'),
  Place('Balıkesir, Türkiye', 39.65, 27.88, 2, 'tr'),
  Place('Manisa, Türkiye', 38.61, 27.43, 2, 'tr'),
  Place('Aydın, Türkiye', 37.85, 27.84, 2, 'tr'),
  Place('Hatay, Türkiye', 36.20, 36.16, 2, 'tr'),
  Place('Kahramanmaraş, Türkiye', 37.58, 36.94, 2, 'tr'),
  Place('Sivas, Türkiye', 39.75, 37.02, 2, 'tr'),
  Place('Lefkoşa, KKTC', 35.19, 33.36, 2, 'eu'),
  Place('Berlin, Almanya', 52.52, 13.40, 1, 'eu'),
  Place('Köln, Almanya', 50.94, 6.96, 1, 'eu'),
  Place('Münih, Almanya', 48.14, 11.58, 1, 'eu'),
  Place('Amsterdam, Hollanda', 52.37, 4.90, 1, 'eu'),
  Place('Brüksel, Belçika', 50.85, 4.35, 1, 'eu'),
  Place('Paris, Fransa', 48.86, 2.35, 1, 'eu'),
  Place('Viyana, Avusturya', 48.21, 16.37, 1, 'eu'),
  Place('Londra, Birleşik Krallık', 51.51, -0.13, 0, 'eu'),
  Place('Bakü, Azerbaycan', 40.41, 49.87, 4, 'none'),
  Place('Dubai, BAE', 25.20, 55.27, 4, 'none'),
  Place('New York, ABD', 40.71, -74.01, -5, 'us'),
  Place('Los Angeles, ABD', 34.05, -118.24, -8, 'us'),
  Place('Houston, ABD', 29.76, -95.37, -6, 'us'),
  Place('Toronto, Kanada', 43.65, -79.38, -5, 'us'),
];

Place? findPlace(String name) {
  final q = name.toLowerCase().trim();
  for (final p in places) {
    if (p.name.toLowerCase() == q) return p;
  }
  for (final p in places) {
    if (p.name.toLowerCase().startsWith(q.split(',').first)) return p;
  }
  return null;
}

DateTime _lastSunday(int y, int m) {
  var d = DateTime.utc(y, m + 1, 0);
  while (d.weekday != DateTime.sunday) {
    d = d.subtract(const Duration(days: 1));
  }
  return d;
}

/// Yerel saat -> UTC.
DateTime toUtc(DateTime local, Place p) {
  double off = p.std;
  final y = local.year;
  bool inEuDst() {
    final s = _lastSunday(y, 3).add(const Duration(hours: 3));
    final e = _lastSunday(y, 10).add(const Duration(hours: 3));
    final l = DateTime.utc(y, local.month, local.day, local.hour, local.minute);
    return !l.isBefore(s) && l.isBefore(e);
  }

  switch (p.dst) {
    case 'tr':
      if (local.isAfter(DateTime(2016, 9, 7))) {
        off = 3;
      } else if (inEuDst()) {
        off = 3;
      }
    case 'eu':
      if (inEuDst()) off += 1;
    case 'us':
      // Mart 2. pazar – Kasım 1. pazar (2007 sonrası kuralı)
      var s = DateTime.utc(y, 3, 1);
      var sundays = 0;
      while (true) {
        if (s.weekday == DateTime.sunday && ++sundays == 2) break;
        s = s.add(const Duration(days: 1));
      }
      var e = DateTime.utc(y, 11, 1);
      while (e.weekday != DateTime.sunday) {
        e = e.add(const Duration(days: 1));
      }
      final l = DateTime.utc(y, local.month, local.day);
      if (!l.isBefore(s) && l.isBefore(e)) off += 1;
  }
  final asUtc = DateTime.utc(
      local.year, local.month, local.day, local.hour, local.minute);
  return asUtc.subtract(Duration(minutes: (off * 60).round()));
}
