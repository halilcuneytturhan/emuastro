import 'package:flutter/material.dart';

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
              Text('Ayarlar', style: T.display),
              const SizedBox(height: 20),
              row('Profil ve doğum bilgileri',
                  '${app.profile.name} · ${app.profile.place}', () => editProfile(context)),
              row('Premium', app.premium ? 'Etkin' : 'Ücretsiz plan',
                  () => openPremium(context)),
              row('Kullanıcı adı', app.username == null ? 'Oluşturulmadı' : '@${app.username}',
                  () => createUsername(context)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: app.notificationsOn,
                onChanged: (v) {
                  app.setNotifications(v);
                  Notifications.reschedule();
                },
                title: Text('Bildirimler', style: T.heading),
                subtitle: Text('Her sabah 09:00 günlük skor, önemli gökyüzü olaylarından bir gün önce uyarı',
                    style: T.body.copyWith(fontSize: 12)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Görünüm', style: T.heading),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'system', label: Text('Sistem')),
                      ButtonSegment(value: 'light', label: Text('Açık')),
                      ButtonSegment(value: 'dark', label: Text('Karanlık')),
                    ],
                    selected: {app.themeMode},
                    onSelectionChanged: (v) => app.setThemeMode(v.first),
                  ),
                ),
              ),
              row('Aydınlatma Metni ve Gizlilik', 'KVKK kapsamındaki bilgilendirme', () => openLegal(context)),
              row('Hakkında', 'EmuAstro 1.0', () => showInfo(context, 'EmuAstro',
                  'Gezegen konumları cihazda hesaplanır (Schlyter yöntemi, ~1–2 yay dakikası doğruluk). Ev sistemi: eşit ev. Yorumlar eğlence ve öz farkındalık amaçlıdır.')),
              const SizedBox(height: 12),
              row('Tüm verileri sil', 'Profil, arkadaşlar, sohbet ve rozetler silinir', () async {
                final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                          title: const Text('Tüm veriler silinsin mi?'),
                          content: const Text('Bu işlem geri alınamaz.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Vazgeç')),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Sil',
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
              title: Text('Kullanıcı adı', style: T.monoTitleBold),
              content: TextField(
                controller: c,
                autofocus: true,
                decoration: InputDecoration(prefixText: '@', errorText: err),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Vazgeç')),
                TextButton(
                    onPressed: () {
                      final v = c.text.trim().toLowerCase();
                      if (!RegExp(r'^[a-z0-9_.]{3,20}$').hasMatch(v)) {
                        setS(() => err = '3–20 karakter: harf, rakam, _ ve .');
                        return;
                      }
                      app.setUsername(v);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Kaydet')),
              ],
            ),
          ));
}
