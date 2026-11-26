import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../astro/interpret.dart';
import '../data/sample.dart';

/// Supabase bağlantısı. Yalnız şu tanımlar verildiğinde etkin:
///   --dart-define=SUPABASE_URL=https://<proje>.supabase.co
///   --dart-define=SUPABASE_ANON_KEY=<publishable anon key>
/// Verilmezse uygulama tamamen yerel çalışır.
class Backend {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _key = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool enabled = false;

  static SupabaseClient get _c => Supabase.instance.client;

  static Future<void> init() async {
    if (_url.isEmpty || _key.isEmpty) return;
    try {
      await Supabase.initialize(url: _url, anonKey: _key);
      if (_c.auth.currentSession == null) await _c.auth.signInAnonymously();
      enabled = true;
      await syncProfile();
    } catch (e) {
      debugPrint('BACKEND INIT ERROR: $e');
      enabled = false;
    }
  }

  static String _uid() => _c.auth.currentUser!.id;

  static String phoneHash(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('0')) d = '90${d.substring(1)}';
    if (d.length == 10) d = '90$d';
    return sha256.convert(utf8.encode(d)).toString();
  }

  /// Yerel profili sunucuya yazar, sunucudaki Premium süresini okur.
  static Future<void> syncProfile() async {
    if (!enabled) return;
    final p = app.profile;
    try {
      await _c.from('profiles').upsert({
        'id': _uid(),
        'name': p.name,
        'username': app.username,
        'birth_local': p.local.toIso8601String(),
        'birth_place': p.place,
        if (app.phone != null) 'phone_hash': phoneHash(app.phone!),
      });
      final row = await _c
          .from('profiles')
          .select('premium_until')
          .eq('id', _uid())
          .single();
      final pu = row['premium_until'] as String?;
      if (pu != null) {
        final t = DateTime.parse(pu);
        if (app.trialUntil == null || t.isAfter(app.trialUntil!)) {
          app.startTrial(t.difference(DateTime.now()).inMinutes ~/ 1440 + 1);
        }
      }
    } catch (e) {
      debugPrint('BACKEND PROFILE SYNC ERROR: $e');
      rethrow;
    }
  }

  static Future<String> createGiftCode() async =>
      await _c.rpc('create_gift_code') as String;

  static Future<void> redeemGiftCode(String code) async {
    await _c.rpc('redeem_gift_code', params: {'c': code});
    await syncProfile();
  }

  /// Rehberdeki numaraların yalnız hash'ini gönderir; eşleşenleri döner.
  static Future<List<Map<String, dynamic>>> matchContacts(
      List<String> phones) async {
    final res = await _c.rpc('match_contacts',
        params: {'hashes': phones.map(phoneHash).toSet().toList()});
    return (res as List).cast<Map<String, dynamic>>();
  }

  /// Claude destekli sohbet (Edge Function: astro-chat).
  static Future<String> ask(String q) async {
    final c = app.chart;
    final d = app.day;
    final summary = [
      'Güneş ${c.signName('sun')}, Ay ${c.signName('moon')}, Yükselen ${c.signName('asc')}',
      for (final p in c.planets)
        '${planetName[p.id]} ${signs[p.sign]} ${p.degInSign.toStringAsFixed(0)}° ev ${c.house(p.lon)}${p.retro ? ' R' : ''}',
      'Bugün: fırsat %${d.scores[0]}, zihin %${d.scores[1]}, enerji %${d.scores[2]}',
      'Kaçın: ${d.never}',
      'Yap: ${d.todo}',
    ].join('\n');
    final r = await _c.functions
        .invoke('astro-chat', body: {'question': q, 'chartSummary': summary});
    final data = r.data as Map<String, dynamic>;
    if (data['error'] != null) throw Exception(data['error']);
    return data['answer'] as String;
  }
}
