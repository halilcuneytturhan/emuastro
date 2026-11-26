import 'dart:convert';
import 'dart:math' as math;

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../astro/ephemeris.dart';
import '../astro/interpret.dart';
import '../services/backend.dart';
import '../l10n.dart';

export '../astro/interpret.dart'
    show SkyEvent, BirthData, Chart, scoreCats, scoreLabel, reportSections, reportText;

class Twin {
  final int pct;
  final String name, job, common, pal;
  const Twin(this.pct, this.name, this.job, this.common, this.pal);
}

class Planet {
  final String id;
  final double lon;
  final bool retro;
  const Planet(this.id, this.lon, {this.retro = false});
}

class Profile {
  String name;
  DateTime birth;
  String time;
  String place;
  Profile(this.name, this.birth, this.time, this.place);
  DateTime get local {
    final p = time.split(':');
    return DateTime(birth.year, birth.month, birth.day,
        int.tryParse(p.first) ?? 12, p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
  }
}

class Friend {
  final BirthData data;
  final bool partner;
  Friend(this.data, {this.partner = false});
  Map<String, dynamic> toJson() => {...data.toJson(), 'partner': partner};
  factory Friend.fromJson(Map<String, dynamic> j) =>
      Friend(BirthData.fromJson(j), partner: j['partner'] as bool? ?? false);
}

class ChatMsg {
  final bool me;
  final String text;
  ChatMsg(this.me, this.text);
  Map<String, dynamic> toJson() => {'me': me, 'text': text};
}

/// Uygulama durumu: hesaplanan harita + cihazda saklanan kullanıcı verisi.
class AppData extends ChangeNotifier {
  SharedPreferences? _prefs;
  final profile =
      Profile('buket', DateTime(2004, 7, 25), '09:30', 'İstanbul, Türkiye');
  DateTime today = DateTime.now();
  final totalSections = 15;

  // kalıcı alanlar
  int giftsLeft = 3;
  int streak = 1;
  String? username;
  String? phone;
  DateTime? lastBirthEdit;
  DateTime? trialUntil;
  bool purchased = false;
  bool trialUsed = false;
  final badges = <String>{};
  final friends = <Friend>[];
  final chat = <ChatMsg>[];
  final sentCodes = <String>[];
  int questionsToday = 0;
  String? boxOpenedDay;
  bool transit = false;
  String? rewardMessage;

  // hesaplanan
  late Chart chart;
  late Daily day;
  late List<SkyEvent> events;
  late List<Twin> twins;

  bool onboarded = false;
  String themeMode = 'system';
  String lang = 'system';
  void setLang(String v) {
    lang = v;
    _prefs?.setString('lang', v);
    twinsCache.clear();
    notifyListeners();
  }

  /// Dil değişince metinleri yeniden üret.
  void relocalize() {
    twinsCache.clear();
    _recompute();
  }
  void setThemeMode(String m) {
    themeMode = m;
    _prefs?.setString('theme', m);
    notifyListeners();
  }
  bool notificationsOn = true;

  Future<void> finishOnboarding(String name, DateTime b, String t, String place) async {
    profile
      ..name = name
      ..birth = b
      ..time = t
      ..place = place;
    onboarded = true;
    twinsCache.clear();
    _recompute();
    await _save();
    await _prefs?.setBool('onboarded', true);
  }

  void setNotifications(bool v) {
    notificationsOn = v;
    _prefs?.setBool('notif', v);
    notifyListeners();
  }

  bool get premium =>
      purchased || (trialUntil != null && trialUntil!.isAfter(DateTime.now()));
  int get unlocked => premium ? totalSections : 1;
  int get questionLimit => premium ? 5 : 1;
  String get sun => chart.signName('sun');
  String get moon => chart.signName('moon');
  String get asc => chart.signName('asc');
  double get ascLon => chart.asc;
  String get neverToday => day.never;
  List<double> get trend => day.trends[0];
  int get performance => day.scores[0];
  List<String> get boxTips => day.tips;
  List<(String, String)> get moves => [
        (tr('YAP'), day.todo),
        (tr('ÖZEN GÖSTER'), day.watch),
        (tr('UNUTMA'), day.reminder),
        (tr('DÖNEMİN TEMASI'), day.period),
      ];
  List<Planet> get planets => [
        for (final p in chart.planets) Planet(p.id, p.lon, retro: p.retro)
      ];
  List<(String, String, String)> get aspects => [
        for (final (a, b, asp) in chart.aspects())
          if (asp != 'altmışlık')
            (a, b, (asp == 'kare' || asp == 'karşıtlık') ? 'pink' : 'purple')
      ];
  List<Planet> get transitPlanets => [
        for (final p in positions(DateTime.now().toUtc()))
          if (p.id != 'node' && p.id != 'lilith') Planet(p.id, p.lon)
      ];

  AppData() {
    _recompute();
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> load({DateTime? overrideToday}) async {
    if (overrideToday != null) today = overrideToday;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _recompute();
      return;
    }
    final p = _prefs!;
    onboarded = p.getBool('onboarded') ?? false;
    themeMode = p.getString('theme') ?? 'system';
    lang = p.getString('lang') ?? 'system';
    if (kIsWeb && Uri.base.queryParameters['lang'] != null) {
      lang = Uri.base.queryParameters['lang']!;
    }
    final sys = PlatformDispatcher.instance.locale.languageCode;
    L.en = lang == 'en' || (lang == 'system' && sys != 'tr');
    if (kIsWeb && Uri.base.queryParameters['theme'] != null) {
      themeMode = Uri.base.queryParameters['theme']!;
    }
    notificationsOn = p.getBool('notif') ?? true;
    final pj = p.getString('profile');
    if (pj != null) {
      final j = jsonDecode(pj) as Map<String, dynamic>;
      profile
        ..name = j['name'] as String
        ..birth = DateTime.parse(j['birth'] as String)
        ..time = j['time'] as String
        ..place = j['place'] as String;
    }
    giftsLeft = p.getInt('giftsLeft') ?? 3;
    username = p.getString('username');
    phone = p.getString('phone');
    purchased = p.getBool('purchased') ?? false;
    trialUsed = p.getBool('trialUsed') ?? false;
    final tu = p.getString('trialUntil');
    trialUntil = tu == null ? null : DateTime.parse(tu);
    final lb = p.getString('lastBirthEdit');
    lastBirthEdit = lb == null ? null : DateTime.parse(lb);
    badges.addAll(p.getStringList('badges') ?? const []);
    sentCodes.addAll(p.getStringList('sentCodes') ?? const []);
    for (final f in p.getStringList('friends') ?? const <String>[]) {
      friends.add(Friend.fromJson(jsonDecode(f) as Map<String, dynamic>));
    }
    for (final m in p.getStringList('chat') ?? const <String>[]) {
      final j = jsonDecode(m) as Map<String, dynamic>;
      chat.add(ChatMsg(j['me'] as bool, j['text'] as String));
    }
    final tk = _dayKey(today);
    questionsToday = p.getString('qDay') == tk ? (p.getInt('qCount') ?? 0) : 0;
    boxOpenedDay = p.getString('boxDay');
    seenEvents = p.getString('seenEvents');
    // seri: art arda açılan günler
    final last = p.getString('lastOpen');
    streak = p.getInt('streak') ?? 1;
    if (last != tk) {
      final y = _dayKey(today.subtract(const Duration(days: 1)));
      streak = last == y ? streak + 1 : 1;
      await p.setString('lastOpen', tk);
      await p.setInt('streak', streak);
      // Seri ödülü: her 7 günde bir 1 günlük Premium + rozet
      if (streak % 7 == 0) {
        final until = DateTime.now().add(const Duration(days: 1));
        if (trialUntil == null || trialUntil!.isBefore(until)) trialUntil = until;
        badges.add('streak-$streak');
        rewardMessage =
            '$streak gün üst üste geldin! Ödül olarak 24 saat Premium açıldı ve seri rozeti kazandın.';
      }
    }
    _recompute();
    if (rewardMessage != null) await _save();
  }

  void _recompute() {
    chart = Chart.of(BirthData(profile.name, profile.local, profile.place));
    day = daily(chart, today);
    events = skyEvents(chart, today);
    twins = [
      for (final t in twinsOf(chart))
        Twin(t.pct, t.c.name, tr(t.c.job), t.common, t.c.pal)
    ];
    notifyListeners();
  }

  List<TwinMatch> twinsOf(Chart c) => twinsCache[_dayKeyBirth()] ??= twins_(c);
  final twinsCache = <String, List<TwinMatch>>{};
  String _dayKeyBirth() => '${profile.local}-${profile.place}-${L.en}';

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString(
        'profile',
        jsonEncode({
          'name': profile.name,
          'birth': profile.birth.toIso8601String(),
          'time': profile.time,
          'place': profile.place,
        }));
    await p.setInt('giftsLeft', giftsLeft);
    if (username != null) await p.setString('username', username!);
    if (phone != null) await p.setString('phone', phone!);
    await p.setBool('purchased', purchased);
    await p.setBool('trialUsed', trialUsed);
    if (trialUntil != null) {
      await p.setString('trialUntil', trialUntil!.toIso8601String());
    }
    if (lastBirthEdit != null) {
      await p.setString('lastBirthEdit', lastBirthEdit!.toIso8601String());
    }
    await p.setStringList('badges', badges.toList());
    await p.setStringList('sentCodes', sentCodes);
    await p.setStringList(
        'friends', [for (final f in friends) jsonEncode(f.toJson())]);
    await p.setStringList(
        'chat', [for (final m in chat.length > 60 ? chat.sublist(chat.length - 60) : chat) jsonEncode(m.toJson())]);
    await p.setString('qDay', _dayKey(today));
    await p.setInt('qCount', questionsToday);
    if (boxOpenedDay != null) await p.setString('boxDay', boxOpenedDay!);
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  // ---------- eylemler ----------

  bool get canEditBirth =>
      lastBirthEdit == null ||
      DateTime.now().difference(lastBirthEdit!).inDays >= 30;

  /// Doğum bilgisi değiştiyse ayda bir sınırı uygular. Hata mesajı döner.
  String? updateProfile(String name, DateTime b, String t, String place) {
    final birthChanged = b != profile.birth || t != profile.time || place != profile.place;
    if (birthChanged && !canEditBirth) {
      final next = lastBirthEdit!.add(const Duration(days: 30));
      return 'Doğum bilgilerini ayda bir kez düzeltebilirsin. Sonraki: ${next.day}.${next.month}.${next.year}';
    }
    profile
      ..name = name
      ..birth = b
      ..time = t
      ..place = place;
    if (birthChanged) lastBirthEdit = DateTime.now();
    twinsCache.clear();
    _recompute();
    _save();
    return null;
  }

  void toggleTransit() {
    transit = !transit;
    notifyListeners();
  }

  void earnBadge(String key) {
    if (badges.add(key)) _commit();
  }

  void setUsername(String u) {
    username = u;
    _commit();
    Backend.syncProfile().catchError((_) {});
  }

  void setPhone(String p) {
    phone = p;
    _commit();
    Backend.syncProfile().catchError((_) {});
  }

  void addFriend(Friend f) {
    friends.add(f);
    _commit();
  }

  void removeFriend(Friend f) {
    friends.remove(f);
    _commit();
  }

  void openBox() {
    boxOpenedDay = _dayKey(today);
    _commit();
  }

  bool get boxOpenedToday => boxOpenedDay == _dayKey(today);

  /// Uygulama öne gelince tarih değiştiyse günlük içeriği yeniden hesaplar.
  void refreshDay() {
    final now = DateTime.now();
    if (_dayKey(now) == _dayKey(today)) return;
    today = now;
    questionsToday = 0;
    _recompute();
  }

  String? seenEvents;
  bool get hasUnseen =>
      events.isNotEmpty && seenEvents != events.map((e) => e.key).join(',');
  void markEventsSeen() {
    seenEvents = events.map((e) => e.key).join(',');
    _prefs?.setString('seenEvents', seenEvents!);
    notifyListeners();
  }

  void startTrial(int days) {
    trialUntil = DateTime.now().add(Duration(days: days));
    _commit();
  }

  bool startFreeTrial() {
    if (trialUsed) return false;
    trialUsed = true;
    startTrial(3);
    return true;
  }

  void setPurchased(bool v) {
    purchased = v;
    _commit();
  }

  /// Hediye kodu üretir (EMU-XXXX-C biçimi, son hane sağlama).
  String? createGiftCode() {
    if (giftsLeft <= 0) return null;
    final r = math.Random();
    const abc = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final body = List.generate(6, (_) => abc[r.nextInt(abc.length)]).join();
    final code = 'EMU-$body-${abc[stableHash(body) % abc.length]}';
    giftsLeft--;
    sentCodes.add(code);
    _commit();
    return code;
  }

  String? redeemCode(String raw) {
    final code = raw.trim().toUpperCase();
    final m = RegExp(r'^EMU-([A-Z0-9]{6})-([A-Z0-9])$').firstMatch(code);
    const abc = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    if (m == null || abc[stableHash(m[1]!) % abc.length] != m[2]) {
      return 'Kod geçersiz. EMU-XXXXXX-X biçiminde olmalı.';
    }
    if (sentCodes.contains(code)) return 'Kendi gönderdiğin kodu kullanamazsın.';
    if (premium) return 'Premium zaten açık.';
    startTrial(3);
    return null;
  }

  /// Sohbet: yerel yorum motoru, günlük soru sınırı.
  String? ask(String q) {
    if (questionsToday >= questionLimit) {
      return premium
          ? 'Bugünkü 5 soru hakkını kullandın. Yarın yeniden sorabilirsin.'
          : 'Ücretsiz planda günde 1 soru hakkın var. Premium ile günde 5 soru sorabilirsin.';
    }
    questionsToday++;
    chat.add(ChatMsg(true, q));
    chat.add(ChatMsg(false, answer(chart, q, DateTime.now())));
    _commit();
    return null;
  }

  // ---------- sunucu varsa sunucu, yoksa yerel ----------

  Future<String?> askAsync(String q) async {
    if (!Backend.enabled) return ask(q);
    try {
      final a = await Backend.ask(q);
      chat.add(ChatMsg(true, q));
      chat.add(ChatMsg(false, a));
      _commit();
      return null;
    } catch (e) {
      final m = '$e';
      if (m.contains('limit')) {
        return premium
            ? 'Bugünkü 5 soru hakkını kullandın.'
            : 'Ücretsiz planda günde 1 soru hakkın var. Premium ile günde 5 soru sorabilirsin.';
      }
      return ask(q); // bağlantı yoksa yerel motor
    }
  }

  Future<String?> createGiftCodeAsync() async {
    if (!Backend.enabled) return createGiftCode();
    try {
      final c = await Backend.createGiftCode();
      giftsLeft = (giftsLeft - 1).clamp(0, 3);
      sentCodes.add(c);
      _commit();
      return c;
    } catch (_) {
      return null;
    }
  }

  Future<String?> redeemCodeAsync(String code) async {
    if (!Backend.enabled) return redeemCode(code);
    try {
      await Backend.redeemGiftCode(code);
      return null;
    } on Exception catch (e) {
      final m = '$e';
      for (final k in ['Kod geçersiz', 'Kendi kodunu kullanamazsın', 'Bu kod kullanılmış']) {
        if (m.contains(k)) return '$k.';
      }
      return 'Kod şu an doğrulanamadı.';
    }
  }

  Future<void> resetAll() async {
    await _prefs?.clear();
    friends.clear();
    chat.clear();
    badges.clear();
    sentCodes.clear();
    giftsLeft = 3;
    username = null;
    phone = null;
    purchased = false;
    trialUsed = false;
    trialUntil = null;
    lastBirthEdit = null;
    questionsToday = 0;
    boxOpenedDay = null;
    profile
      ..name = 'buket'
      ..birth = DateTime(2004, 7, 25)
      ..time = '09:30'
      ..place = 'İstanbul, Türkiye';
    twinsCache.clear();
    _recompute();
  }
}

List<TwinMatch> twins_(Chart c) => twins(c);

final app = AppData();

const trMonths = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos',
  'Eylül', 'Ekim', 'Kasım', 'Aralık'
];
const trDays = [
  'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
];

String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

String dateLine(DateTime d) => '${d.day} ${trMonths[d.month - 1]}';

// Not: kDebugMode yalnız hata ayıklama günlükleri için.
bool get debug => kDebugMode;
