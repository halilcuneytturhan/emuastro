import 'package:flutter/material.dart';

import '../l10n.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/surface.dart';
import 'premium.dart';
import 'legal.dart';
import '../services/notifications.dart';
import 'profile.dart' show editProfile;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    Widget row(String t, String sub, VoidCallback onTap, {Color? color}) =>
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t, style: T.heading.copyWith(color: color)),
          subtitle: Text(sub, style: T.body.copyWith(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        );
    return Scaffold(
      backgroundColor: C.page,
      body: PaperBackground(
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) => ListView(
            padding: EdgeInsets.fromLTRB(kSide, top + 14, kSide, 60),
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.chevron_left_rounded, size: 32))),
              const SizedBox(height: 10),
              Text('AYARLAR', style: T.sectionLabel),
              const SizedBox(height: 6),
              Text(tr('Ayarlar'), style: T.display),
              const SizedBox(height: 20),
              row(tr('Profil ve doğum bilgileri'),
                  '${app.profile.name} · ${app.profile.place}', () => editProfile(context)),
              row('Premium', app.premium ? tr('Etkin') : tr('Ücretsiz plan'),
                  () => openPremium(context)),
              row(tr('Kullanıcı adı'), app.username == null ? tr('Oluşturulmadı') : '@${app.username}',
                  () => createUsername(context)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: app.notificationsOn,
                onChanged: (v) {
                  app.setNotifications(v);
                  Notifications.reschedule();
                },
                title: Text(tr('Bildirimler'), style: T.heading),
                subtitle: Text(tr('Her sabah 09:00 günlük skor, önemli gökyüzü olaylarından bir gün önce uyarı'),
                    style: T.body.copyWith(fontSize: 12)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('Dil'), style: T.heading),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'system', label: Text(tr('Sistem'))),
                      const ButtonSegment(value: 'tr', label: Text('Türkçe')),
                      const ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {app.lang},
                    onSelectionChanged: (v) => app.setLang(v.first),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('Görünüm'), style: T.heading),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'system', label: Text(tr('Sistem'))),
                      ButtonSegment(value: 'light', label: Text(tr('Açık'))),
                      ButtonSegment(value: 'dark', label: Text(tr('Karanlık'))),
                    ],
                    selected: {app.themeMode},
                    onSelectionChanged: (v) => app.setThemeMode(v.first),
                  ),
                ),
              ),
              row(tr('Aydınlatma Metni ve Gizlilik'), tr('KVKK kapsamındaki bilgilendirme'), () => openLegal(context)),
              row(tr('Hakkında'), tr('EmuAstro 1.0 · logo ve marka EmuAstro’ya aittir'), () => showInfo(context, 'EmuAstro',
                  tr('Gezegen konumları cihazda hesaplanır (Schlyter yöntemi, ~1–2 yay dakikası doğruluk). Ev sistemi: eşit ev. Yorumlar eğlence ve öz farkındalık amaçlıdır.'))),
              const SizedBox(height: 12),
              row(tr('Tüm verileri sil'), tr('Profil, arkadaşlar, sohbet ve rozetler silinir'), () async {
                final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                          title: Text(tr('Tüm veriler silinsin mi?')),
                          content: Text(tr('Bu işlem geri alınamaz.')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: Text(tr('Vazgeç'))),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: Text(tr('Sil'),
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ));
                if (ok == true) await app.resetAll();
              }, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> createUsername(BuildContext context) async {
  final c = TextEditingController(text: app.username ?? '');
  String? err;
  await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
            builder: (ctx, setS) => AlertDialog(
              backgroundColor: C.page,
              title: Text(tr('Kullanıcı adı'), style: T.monoTitleBold),
              content: TextField(
                controller: c,
                autofocus: true,
                decoration: InputDecoration(prefixText: '@', errorText: err),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(tr('Vazgeç'))),
                TextButton(
                    onPressed: () {
                      final v = c.text.trim().toLowerCase();
                      if (!RegExp(r'^[a-z0-9_.]{3,20}$').hasMatch(v)) {
                        setS(() => err = tr('3–20 karakter: harf, rakam, _ ve .'));
                        return;
                      }
                      app.setUsername(v);
                      Navigator.pop(ctx);
                    },
                    child: Text(tr('Kaydet'))),
              ],
            ),
          ));
}
