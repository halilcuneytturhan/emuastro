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
  Place('Adana, Türkiye', 37.00, 35.32, 2, 'tr'),
  Place('Adıyaman, Türkiye', 37.76, 38.28, 2, 'tr'),
  Place('Afyonkarahisar, Türkiye', 38.76, 30.54, 2, 'tr'),
  Place('Ağrı, Türkiye', 39.72, 43.05, 2, 'tr'),
  Place('Amasya, Türkiye', 40.65, 35.83, 2, 'tr'),
  Place('Ankara, Türkiye', 39.93, 32.86, 2, 'tr'),
  Place('Antalya, Türkiye', 36.90, 30.70, 2, 'tr'),
  Place('Artvin, Türkiye', 41.18, 41.82, 2, 'tr'),
  Place('Aydın, Türkiye', 37.85, 27.84, 2, 'tr'),
  Place('Balıkesir, Türkiye', 39.65, 27.88, 2, 'tr'),
  Place('Bilecik, Türkiye', 40.14, 29.98, 2, 'tr'),
  Place('Bingöl, Türkiye', 38.88, 40.50, 2, 'tr'),
  Place('Bitlis, Türkiye', 38.40, 42.11, 2, 'tr'),
  Place('Bolu, Türkiye', 40.74, 31.61, 2, 'tr'),
  Place('Burdur, Türkiye', 37.72, 30.29, 2, 'tr'),
  Place('Bursa, Türkiye', 40.19, 29.06, 2, 'tr'),
  Place('Çanakkale, Türkiye', 40.15, 26.41, 2, 'tr'),
  Place('Çankırı, Türkiye', 40.60, 33.62, 2, 'tr'),
  Place('Çorum, Türkiye', 40.55, 34.95, 2, 'tr'),
  Place('Denizli, Türkiye', 37.78, 29.09, 2, 'tr'),
  Place('Diyarbakır, Türkiye', 37.91, 40.24, 2, 'tr'),
  Place('Edirne, Türkiye', 41.68, 26.56, 2, 'tr'),
  Place('Elazığ, Türkiye', 38.67, 39.22, 2, 'tr'),
  Place('Erzincan, Türkiye', 39.75, 39.49, 2, 'tr'),
  Place('Erzurum, Türkiye', 39.90, 41.27, 2, 'tr'),
  Place('Eskişehir, Türkiye', 39.78, 30.52, 2, 'tr'),
  Place('Gaziantep, Türkiye', 37.07, 37.38, 2, 'tr'),
  Place('Giresun, Türkiye', 40.91, 38.39, 2, 'tr'),
  Place('Gümüşhane, Türkiye', 40.46, 39.48, 2, 'tr'),
  Place('Hakkari, Türkiye', 37.58, 43.74, 2, 'tr'),
  Place('Hatay, Türkiye', 36.20, 36.16, 2, 'tr'),
  Place('Isparta, Türkiye', 37.76, 30.55, 2, 'tr'),
  Place('Mersin, Türkiye', 36.80, 34.63, 2, 'tr'),
  Place('İzmir, Türkiye', 38.42, 27.14, 2, 'tr'),
  Place('Kars, Türkiye', 40.60, 43.10, 2, 'tr'),
  Place('Kastamonu, Türkiye', 41.38, 33.78, 2, 'tr'),
  Place('Kayseri, Türkiye', 38.73, 35.48, 2, 'tr'),
  Place('Kırklareli, Türkiye', 41.73, 27.22, 2, 'tr'),
  Place('Kırşehir, Türkiye', 39.15, 34.16, 2, 'tr'),
  Place('Kocaeli, Türkiye', 40.77, 29.92, 2, 'tr'),
  Place('Konya, Türkiye', 37.87, 32.48, 2, 'tr'),
  Place('Kütahya, Türkiye', 39.42, 29.98, 2, 'tr'),
  Place('Malatya, Türkiye', 38.35, 38.31, 2, 'tr'),
  Place('Manisa, Türkiye', 38.61, 27.43, 2, 'tr'),
  Place('Kahramanmaraş, Türkiye', 37.58, 36.94, 2, 'tr'),
  Place('Mardin, Türkiye', 37.31, 40.74, 2, 'tr'),
  Place('Muğla, Türkiye', 37.22, 28.36, 2, 'tr'),
  Place('Muş, Türkiye', 38.75, 41.51, 2, 'tr'),
  Place('Nevşehir, Türkiye', 38.62, 34.71, 2, 'tr'),
  Place('Niğde, Türkiye', 37.97, 34.68, 2, 'tr'),
  Place('Ordu, Türkiye', 40.98, 37.88, 2, 'tr'),
  Place('Rize, Türkiye', 41.02, 40.52, 2, 'tr'),
  Place('Sakarya, Türkiye', 40.78, 30.40, 2, 'tr'),
  Place('Samsun, Türkiye', 41.29, 36.33, 2, 'tr'),
  Place('Siirt, Türkiye', 37.93, 41.94, 2, 'tr'),
  Place('Sinop, Türkiye', 42.03, 35.15, 2, 'tr'),
  Place('Sivas, Türkiye', 39.75, 37.02, 2, 'tr'),
  Place('Tekirdağ, Türkiye', 40.98, 27.51, 2, 'tr'),
  Place('Tokat, Türkiye', 40.31, 36.55, 2, 'tr'),
  Place('Trabzon, Türkiye', 41.00, 39.72, 2, 'tr'),
  Place('Tunceli, Türkiye', 39.11, 39.55, 2, 'tr'),
  Place('Şanlıurfa, Türkiye', 37.16, 38.79, 2, 'tr'),
  Place('Uşak, Türkiye', 38.68, 29.41, 2, 'tr'),
  Place('Van, Türkiye', 38.49, 43.38, 2, 'tr'),
  Place('Yozgat, Türkiye', 39.82, 34.81, 2, 'tr'),
  Place('Zonguldak, Türkiye', 41.45, 31.79, 2, 'tr'),
  Place('Aksaray, Türkiye', 38.37, 34.03, 2, 'tr'),
  Place('Bayburt, Türkiye', 40.26, 40.23, 2, 'tr'),
  Place('Karaman, Türkiye', 37.18, 33.22, 2, 'tr'),
  Place('Kırıkkale, Türkiye', 39.85, 33.51, 2, 'tr'),
  Place('Batman, Türkiye', 37.89, 41.13, 2, 'tr'),
  Place('Şırnak, Türkiye', 37.52, 42.46, 2, 'tr'),
  Place('Bartın, Türkiye', 41.64, 32.34, 2, 'tr'),
  Place('Ardahan, Türkiye', 41.11, 42.70, 2, 'tr'),
  Place('Iğdır, Türkiye', 39.92, 44.05, 2, 'tr'),
  Place('Yalova, Türkiye', 40.66, 29.27, 2, 'tr'),
  Place('Karabük, Türkiye', 41.20, 32.62, 2, 'tr'),
  Place('Kilis, Türkiye', 36.72, 37.12, 2, 'tr'),
  Place('Osmaniye, Türkiye', 37.07, 36.25, 2, 'tr'),
  Place('Düzce, Türkiye', 40.84, 31.16, 2, 'tr'),
  Place('Lefkoşa, KKTC', 35.19, 33.36, 2, 'eu'),
  Place('Gazimağusa, KKTC', 35.12, 33.94, 2, 'eu'),
  Place('Girne, KKTC', 35.34, 33.32, 2, 'eu'),
  Place('Berlin, Almanya', 52.52, 13.4, 1, 'eu'),
  Place('Köln, Almanya', 50.94, 6.96, 1, 'eu'),
  Place('Münih, Almanya', 48.14, 11.58, 1, 'eu'),
  Place('Hamburg, Almanya', 53.55, 9.99, 1, 'eu'),
  Place('Frankfurt, Almanya', 50.11, 8.68, 1, 'eu'),
  Place('Stuttgart, Almanya', 48.78, 9.18, 1, 'eu'),
  Place('Düsseldorf, Almanya', 51.23, 6.78, 1, 'eu'),
  Place('Duisburg, Almanya', 51.43, 6.76, 1, 'eu'),
  Place('Dortmund, Almanya', 51.51, 7.47, 1, 'eu'),
  Place('Essen, Almanya', 51.46, 7.01, 1, 'eu'),
  Place('Hannover, Almanya', 52.37, 9.73, 1, 'eu'),
  Place('Nürnberg, Almanya', 49.45, 11.08, 1, 'eu'),
  Place('Mannheim, Almanya', 49.49, 8.47, 1, 'eu'),
  Place('Amsterdam, Hollanda', 52.37, 4.9, 1, 'eu'),
  Place('Rotterdam, Hollanda', 51.92, 4.48, 1, 'eu'),
  Place('Lahey, Hollanda', 52.08, 4.3, 1, 'eu'),
  Place('Brüksel, Belçika', 50.85, 4.35, 1, 'eu'),
  Place('Anvers, Belçika', 51.22, 4.4, 1, 'eu'),
  Place('Paris, Fransa', 48.86, 2.35, 1, 'eu'),
  Place('Lyon, Fransa', 45.76, 4.84, 1, 'eu'),
  Place('Strazburg, Fransa', 48.57, 7.75, 1, 'eu'),
  Place('Viyana, Avusturya', 48.21, 16.37, 1, 'eu'),
  Place('Zürih, İsviçre', 47.38, 8.54, 1, 'eu'),
  Place('Basel, İsviçre', 47.56, 7.59, 1, 'eu'),
  Place('Stockholm, İsveç', 59.33, 18.07, 1, 'eu'),
  Place('Kopenhag, Danimarka', 55.68, 12.57, 1, 'eu'),
  Place('Oslo, Norveç', 59.91, 10.75, 1, 'eu'),
  Place('Londra, Birleşik Krallık', 51.51, -0.13, 0, 'eu'),
  Place('Manchester, Birleşik Krallık', 53.48, -2.24, 0, 'eu'),
  Place('Dublin, İrlanda', 53.35, -6.26, 0, 'eu'),
  Place('Roma, İtalya', 41.9, 12.5, 1, 'eu'),
  Place('Milano, İtalya', 45.46, 9.19, 1, 'eu'),
  Place('Madrid, İspanya', 40.42, -3.7, 1, 'eu'),
  Place('Barselona, İspanya', 41.39, 2.17, 1, 'eu'),
  Place('Lizbon, Portekiz', 38.72, -9.14, 0, 'eu'),
  Place('Atina, Yunanistan', 37.98, 23.73, 2, 'eu'),
  Place('Selanik, Yunanistan', 40.64, 22.94, 2, 'eu'),
  Place('Sofya, Bulgaristan', 42.7, 23.32, 2, 'eu'),
  Place('Kırcaali, Bulgaristan', 41.65, 25.37, 2, 'eu'),
  Place('Bükreş, Romanya', 44.43, 26.1, 2, 'eu'),
  Place('Üsküp, Kuzey Makedonya', 42.0, 21.43, 1, 'eu'),
  Place('Saraybosna, Bosna-Hersek', 43.86, 18.41, 1, 'eu'),
  Place('Priştine, Kosova', 42.66, 21.17, 1, 'eu'),
  Place('Varşova, Polonya', 52.23, 21.01, 1, 'eu'),
  Place('Prag, Çekya', 50.08, 14.44, 1, 'eu'),
  Place('Budapeşte, Macaristan', 47.5, 19.04, 1, 'eu'),
  Place('Kiev, Ukrayna', 50.45, 30.52, 2, 'eu'),
  Place('Moskova, Rusya', 55.76, 37.62, 3, 'none'),
  Place('Tiflis, Gürcistan', 41.72, 44.79, 4, 'none'),
  Place('Batum, Gürcistan', 41.64, 41.63, 4, 'none'),
  Place('Bakü, Azerbaycan', 40.41, 49.87, 4, 'none'),
  Place('Taşkent, Özbekistan', 41.3, 69.24, 5, 'none'),
  Place('Astana, Kazakistan', 51.17, 71.45, 5, 'none'),
  Place('Almatı, Kazakistan', 43.24, 76.89, 5, 'none'),
  Place('Bişkek, Kırgızistan', 42.87, 74.59, 6, 'none'),
  Place('Aşkabat, Türkmenistan', 37.95, 58.38, 5, 'none'),
  Place('Tahran, İran', 35.69, 51.39, 3.5, 'none'),
  Place('Erbil, Irak', 36.19, 44.01, 3, 'none'),
  Place('Bağdat, Irak', 33.31, 44.37, 3, 'none'),
  Place('Şam, Suriye', 33.51, 36.29, 3, 'none'),
  Place('Halep, Suriye', 36.2, 37.13, 3, 'none'),
  Place('Beyrut, Lübnan', 33.89, 35.5, 2, 'eu'),
  Place('Amman, Ürdün', 31.95, 35.93, 3, 'none'),
  Place('Kudüs', 31.77, 35.21, 2, 'eu'),
  Place('Kahire, Mısır', 30.04, 31.24, 2, 'none'),
  Place('Riyad, Suudi Arabistan', 24.71, 46.68, 3, 'none'),
  Place('Cidde, Suudi Arabistan', 21.49, 39.19, 3, 'none'),
  Place('Doha, Katar', 25.29, 51.53, 3, 'none'),
  Place('Dubai, BAE', 25.2, 55.27, 4, 'none'),
  Place('Abu Dabi, BAE', 24.45, 54.38, 4, 'none'),
  Place('Kuveyt, Kuveyt', 29.38, 47.99, 3, 'none'),
  Place('Tunus, Tunus', 36.81, 10.18, 1, 'none'),
  Place('Cezayir, Cezayir', 36.75, 3.06, 1, 'none'),
  Place('Kazablanka, Fas', 33.57, -7.59, 1, 'none'),
  Place('Johannesburg, Güney Afrika', -26.2, 28.05, 2, 'none'),
  Place('Lagos, Nijerya', 6.52, 3.38, 1, 'none'),
  Place('Nairobi, Kenya', -1.29, 36.82, 3, 'none'),
  Place('Karaçi, Pakistan', 24.86, 67.01, 5, 'none'),
  Place('İslamabad, Pakistan', 33.68, 73.05, 5, 'none'),
  Place('Yeni Delhi, Hindistan', 28.61, 77.21, 5.5, 'none'),
  Place('Mumbai, Hindistan', 19.08, 72.88, 5.5, 'none'),
  Place('Dakka, Bangladeş', 23.81, 90.41, 6, 'none'),
  Place('Bangkok, Tayland', 13.76, 100.5, 7, 'none'),
  Place('Singapur', 1.35, 103.82, 8, 'none'),
  Place('Kuala Lumpur, Malezya', 3.14, 101.69, 8, 'none'),
  Place('Cakarta, Endonezya', -6.21, 106.85, 7, 'none'),
  Place('Pekin, Çin', 39.9, 116.41, 8, 'none'),
  Place('Şanghay, Çin', 31.23, 121.47, 8, 'none'),
  Place('Hong Kong', 22.32, 114.17, 8, 'none'),
  Place('Seul, Güney Kore', 37.57, 126.98, 9, 'none'),
  Place('Tokyo, Japonya', 35.68, 139.69, 9, 'none'),
  Place('Sidney, Avustralya', -33.87, 151.21, 10, 'none'),
  Place('Melbourne, Avustralya', -37.81, 144.96, 10, 'none'),
  Place('Auckland, Yeni Zelanda', -36.85, 174.76, 12, 'none'),
  Place('New York, ABD', 40.71, -74.01, -5, 'us'),
  Place('Boston, ABD', 42.36, -71.06, -5, 'us'),
  Place('Washington, ABD', 38.91, -77.04, -5, 'us'),
  Place('Miami, ABD', 25.76, -80.19, -5, 'us'),
  Place('Chicago, ABD', 41.88, -87.63, -6, 'us'),
  Place('Houston, ABD', 29.76, -95.37, -6, 'us'),
  Place('Dallas, ABD', 32.78, -96.8, -6, 'us'),
  Place('Denver, ABD', 39.74, -104.99, -7, 'us'),
  Place('Los Angeles, ABD', 34.05, -118.24, -8, 'us'),
  Place('San Francisco, ABD', 37.77, -122.42, -8, 'us'),
  Place('Seattle, ABD', 47.61, -122.33, -8, 'us'),
  Place('New Jersey, ABD', 40.73, -74.17, -5, 'us'),
  Place('Toronto, Kanada', 43.65, -79.38, -5, 'us'),
  Place('Montreal, Kanada', 45.5, -73.57, -5, 'us'),
  Place('Vancouver, Kanada', 49.28, -123.12, -8, 'us'),
  Place('Meksiko, Meksika', 19.43, -99.13, -6, 'none'),
  Place('São Paulo, Brezilya', -23.55, -46.63, -3, 'none'),
  Place('Buenos Aires, Arjantin', -34.6, -58.38, -3, 'none'),
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
