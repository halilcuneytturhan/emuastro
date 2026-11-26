import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

void openLegal(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => const LegalScreen()));

/// KVKK aydınlatma metni ve gizlilik politikası (taslak — yayından önce
/// hukuk danışmanı tarafından gözden geçirilmeli).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});
  static const sections = [
    ('Veri sorumlusu', 'EmuAstro uygulamasının geliştiricisi. İletişim bilgisi mağaza sayfasında yer alır.'),
    ('İşlenen veriler', 'İsim, doğum tarihi, doğum saati, doğum yeri; isteğe bağlı olarak telefon numarası, kullanıcı adı, eklediğin arkadaşların isim ve doğum bilgileri, sohbet geçmişi ve kazandığın rozetler.'),
    ('İşleme amacı', 'Doğum haritanı ve günlük yorumlarını hesaplamak, arkadaşlarınla uyum raporu oluşturmak, uygulama içi tercihlerini hatırlamak.'),
    ('Saklama yeri', 'Bu sürümde tüm veriler yalnızca cihazında saklanır ve sunucuya gönderilmez. Rehberin yalnızca kişi seçerken cihazda okunur, kaydedilmez. Bildirimler cihazda planlanır.'),
    ('Saklama süresi', 'Veriler, uygulamayı silene ya da Ayarlar > Tüm verileri sil seçeneğini kullanana kadar cihazında kalır.'),
    ('Satın almalar', 'Abonelik ödemeleri App Store veya Google Play tarafından işlenir; ödeme bilgilerine erişimimiz yoktur.'),
    ('Hakların', 'KVKK 11. madde kapsamındaki haklarını (bilgi talebi, düzeltme, silme vb.) uygulama içinden verilerini düzenleyerek ya da silerek kullanabilir, sorularını mağaza sayfasındaki iletişim adresine iletebilirsin.'),
    ('Sorumluluk reddi', 'Astrolojik yorumlar eğlence ve öz farkındalık amaçlıdır; tıbbi, psikolojik, finansal veya hukuki tavsiye yerine geçmez.'),
  ];
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.page,
      body: ListView(
        padding: EdgeInsets.fromLTRB(kSide, top + 14, kSide, 60),
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left_rounded, size: 32))),
          const SizedBox(height: 10),
          const Text('KVKK · GİZLİLİK', style: T.sectionLabel),
          const SizedBox(height: 6),
          const Text('Aydınlatma Metni', style: T.monoTitleBold),
          const SizedBox(height: 18),
          for (final (h, b) in sections) ...[
            Text(h, style: T.heading),
            const SizedBox(height: 6),
            Text(b, style: T.body.copyWith(color: C.ink, fontSize: 13.5)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
