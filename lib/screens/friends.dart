import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../astro/interpret.dart';
import '../astro/places.dart';
import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/surface.dart';
import 'premium.dart';
import 'tools.dart' show synastrySections;
import '../services/backend.dart';

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// İsim + doğum tarihi/saati/yeri formu. Kaydedince değerleri döndürür.
Future<(String, DateTime, String, String, bool)?> birthForm(BuildContext context,
    {String title = 'Arkadaş ekle',
    String name = '',
    DateTime? birth,
    String time = '12:00',
    String place = 'İstanbul, Türkiye',
    bool showPartner = false,
    String? note}) {
  final nameC = TextEditingController(text: name);
  var b = birth ?? DateTime(1995, 1, 1);
  var t = time;
  var pl = place;
  var partner = false;
  return showModalBottomSheet<(String, DateTime, String, String, bool)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
              color: C.page, borderRadius: BorderRadius.circular(28)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.monoTitleBold),
                if (note != null) ...[
                  const SizedBox(height: 6),
                  Text(note, style: T.body.copyWith(fontSize: 11.5)),
                ],
                const SizedBox(height: 14),
                TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'İsim')),
                const SizedBox(height: 8),
                _pickRow('Doğum tarihi', fmtDate(b), () async {
                  final d = await showDatePicker(
                      context: ctx,
                      initialDate: b,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now());
                  if (d != null) setS(() => b = d);
                }),
                _pickRow('Doğum saati', t, () async {
                  final parts = t.split(':');
                  final r = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay(
                          hour: int.tryParse(parts[0]) ?? 12,
                          minute: int.tryParse(parts.last) ?? 0));
                  if (r != null) {
                    setS(() => t =
                        '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}');
                  }
                }),
                _pickRow('Doğum yeri', pl, () async {
                  final r = await showModalBottomSheet<String>(
                      context: ctx,
                      builder: (c2) => ListView(children: [
                            for (final p in places)
                              ListTile(
                                  title: Text(p.name),
                                  onTap: () => Navigator.pop(c2, p.name)),
                          ]));
                  if (r != null) setS(() => pl = r);
                }),
                if (showPartner)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: partner,
                    onChanged: (v) => setS(() => partner = v ?? false),
                    title: const Text('Ruh eşim / partnerim',
                        style: TextStyle(fontFamily: 'Figtree')),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: const StadiumBorder()),
                    onPressed: () {
                      if (nameC.text.trim().isEmpty) return;
                      Navigator.pop(ctx, (nameC.text.trim(), b, t, pl, partner));
                    },
                    child: const Text('Kaydet',
                        style: TextStyle(
                            fontFamily: 'Figtree', fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
        ),
      ),
    ),
  );
}

Widget _pickRow(String label, String value, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Text(label, style: T.body.copyWith(color: C.grey, fontSize: 13)),
          const Spacer(),
          Text(value, style: T.heading.copyWith(fontSize: 14)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: C.greyLight),
        ]),
      ),
    );

Future<void> addFriendFlow(BuildContext context,
    {String name = '', bool partner = false}) async {
  final r = await birthForm(context,
      title: partner ? 'Partner ekle' : 'Arkadaş ekle',
      name: name,
      showPartner: !partner,
      note: 'Doğum saatini bilmiyorsan 12:00 bırak; Ay ve Yükselen yaklaşık olur.');
  if (r == null) return;
  final (n, b, t, pl, isPartner) = r;
  final hm = t.split(':');
  app.addFriend(Friend(
      BirthData(n, DateTime(b.year, b.month, b.day, int.parse(hm[0]), int.parse(hm[1])), pl),
      partner: partner || isPartner));
}

/// Rehberden kişi seçip arkadaş olarak ekler. Rehber yalnızca cihazda okunur.
Future<void> pickFromContacts(BuildContext context) async {
  if (kIsWeb) {
    showInfo(context, 'Rehber', 'Rehber erişimi yalnızca iOS ve Android uygulamasında çalışır.');
    return;
  }
  try {
    final st = await FlutterContacts.permissions.request(PermissionType.read);
    if (st != PermissionStatus.granted && st != PermissionStatus.limited) {
      if (context.mounted) {
        showInfo(context, 'İzin gerekli',
            'Rehber izni verilmedi. Ayarlar > EmuAstro > Kişiler bölümünden izin verebilirsin.');
      }
      return;
    }
    final list = await FlutterContacts.getAll(properties: {ContactProperty.phone});
    if (!context.mounted) return;
    if (Backend.enabled) {
      final phones = [for (final c in list) for (final ph in c.phones) ph.number];
      try {
        final m = await Backend.matchContacts(phones);
        if (context.mounted && m.isNotEmpty) {
          showInfo(context, 'Rehberinde EmuAstro’da olanlar',
              m.map((u) => '• ${u['name']}${u['username'] != null ? ' (@${u['username']})' : ''}').join('\n'));
        }
      } catch (_) {}
    }
    final picked = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (c) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: .7,
              builder: (c, sc) => ListView(controller: sc, children: [
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Rehberinden seç', style: T.monoTitleBold),
                ),
                for (final ct in list)
                  ListTile(
                      title: Text(ct.displayName ?? ''),
                      onTap: () => Navigator.pop(c, ct.displayName ?? '')),
              ]),
            ));
    if (picked != null && context.mounted) {
      await addFriendFlow(context, name: picked);
    }
  } catch (_) {
    if (context.mounted) {
      showInfo(context, 'Rehber', 'Rehbere şu an erişilemedi.');
    }
  }
}

/// Doğum haritalarını karşılaştıran ilişki raporu.
class FriendReport extends StatelessWidget {
  final Friend friend;
  const FriendReport({super.key, required this.friend});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final other = Chart.of(friend.data);
    final (score, notes) = synastry(app.chart, other);
    final premiumNeeded = !app.premium;
    return Scaffold(
      backgroundColor: C.page,
      body: PaperBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(kSide, top + 14, kSide, 60),
          children: [
            Row(children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left_rounded, size: 32)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  app.removeFriend(friend);
                  Navigator.pop(context);
                },
                child: const Text('Sil',
                    style: TextStyle(fontFamily: 'Figtree', color: Colors.red)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(friend.partner ? 'RUH EŞİ RAPORU' : 'İLİŞKİ RAPORU',
                style: T.sectionLabel),
            const SizedBox(height: 6),
            Text('${app.profile.name} & ${friend.data.name}', style: T.monoTitleBold),
            const SizedBox(height: 18),
            Pearl(
              pal: friend.partner ? Pal.rose : Pal.purple,
              radius: 26,
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                DotText('%$score', pitch: 7),
                const SizedBox(height: 10),
                Text(scoreLabel(score),
                    style: const TextStyle(
                        fontFamily: 'Figtree', color: Colors.white, fontSize: 14)),
                const SizedBox(height: 14),
                Text(
                    '${friend.data.name}: Güneş ${other.signName('sun')} · Ay ${other.signName('moon')} · Venüs ${other.signName('venus')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Figtree',
                        color: Colors.white.withValues(alpha: .75),
                        fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 22),
            for (final (i, (h, b)) in synastrySections(app.chart, other).indexed) ...[
              if (i == 0 || !premiumNeeded) ...[
                Text(h, style: T.heading),
                const SizedBox(height: 4),
                Text(b, style: T.body.copyWith(color: C.ink, fontSize: 13.5)),
                const SizedBox(height: 14),
              ],
            ],
            if (premiumNeeded)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('İletişim, duygusal bağ ve uzun vade bölümleri Premium’da.',
                    style: T.body.copyWith(color: C.accent, fontWeight: FontWeight.w700)),
              ),
            const Text('Haritalarınız arası açılar', style: T.heading),
            const SizedBox(height: 10),
            if (notes.isEmpty)
              Text('Belirgin bir açı yok; ilişki daha çok ortak deneyimle şekillenir.',
                  style: T.body),
            for (final (i, n) in notes.indexed)
              if (!premiumNeeded || i < 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $n', style: T.body.copyWith(color: C.ink, fontSize: 13.5)),
                ),
            if (premiumNeeded && notes.length > 2) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => openPremium(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: C.panel, borderRadius: BorderRadius.circular(18)),
                  child: Row(children: [
                    const Icon(Icons.lock_rounded, color: C.accent),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text('${notes.length - 2} açı daha Premium’da',
                            style: T.heading.copyWith(fontSize: 13.5))),
                    const Icon(Icons.chevron_right_rounded),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
