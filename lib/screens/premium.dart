import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sprites.dart';
import '../widgets/surface.dart';

/// App Store / Google Play'de tanımlanması gereken abonelik kimliği.
const premiumProductId = 'emuastro_premium_monthly';

/// Mağaza satın alma akışı. Satın alma güncellemelerini dinler.
class Purchases {
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static ProductDetails? product;
  static String? lastError;

  static Future<void> init() async {
    try {
      final iap = InAppPurchase.instance;
      if (!await iap.isAvailable()) return;
      _sub ??= iap.purchaseStream.listen((list) async {
        for (final p in list) {
          if (p.productID != premiumProductId) continue;
          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            app.setPurchased(true);
          } else if (p.status == PurchaseStatus.error) {
            lastError = p.error?.message;
          }
          if (p.pendingCompletePurchase) await iap.completePurchase(p);
        }
      });
      final r = await iap.queryProductDetails({premiumProductId});
      if (r.productDetails.isNotEmpty) product = r.productDetails.first;
    } catch (_) {
      // Web/test ortamında mağaza yok.
    }
  }

  static Future<String?> buy() async {
    if (product == null) {
      return l('Mağaza ürünü bulunamadı. Abonelik App Store Connect / Google Play Console’da “$premiumProductId” kimliğiyle tanımlandığında satın alma açılır.', 'Store product not found. Purchases open once the subscription is set up in App Store Connect / Google Play Console as “$premiumProductId”.');
    }
    await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product!));
    return null;
  }

  static Future<String?> restore() async {
    try {
      await InAppPurchase.instance.restorePurchases();
      return null;
    } catch (e) {
      return tr('Geri yükleme şu an yapılamadı.');
    }
  }
}

void openPremium(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => const PremiumScreen()));

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
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
                  child: Icon(Icons.close_rounded, size: 28, color: C.ink),
                ),
              ),
              const SizedBox(height: 18),
              Pearl(
                pal: Pal.purpleBand,
                radius: 26,
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Sprite('star', size: 44, cells: 24),
                  const SizedBox(height: 14),
                  Text('EMUASTRO PREMIUM', style: T.bandKicker),
                  const SizedBox(height: 6),
                  Text(tr('Haritanın tamamını aç'),
                      style: T.monoCard.copyWith(fontSize: 19)),
                  const SizedBox(height: 16),
                  for (final f in [
                    tr('15 bölümlük kişisel harita raporu'),
                    tr('Günde 5 soru'),
                    tr('Sınırsız ilişki ve ruh eşi raporu'),
                    tr('PDF olarak tüm rapor'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(f,
                                style: const TextStyle(
                                    fontFamily: 'Figtree',
                                    color: Colors.white,
                                    fontSize: 14))),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: 22),
              if (app.premium)
                Text(
                    app.purchased
                        ? tr('Premium aboneliğin etkin.')
                        : l('Premium deneme süren ${app.trialUntil!.day}.${app.trialUntil!.month}.${app.trialUntil!.year} tarihine kadar açık.', 'Your Premium trial is active until ${app.trialUntil!.day}/${app.trialUntil!.month}/${app.trialUntil!.year}.'),
                    textAlign: TextAlign.center,
                    style: T.heading)
              else ...[
                _btn(
                    Purchases.product == null
                        ? tr('Abone ol')
                        : 'Abone ol · ${Purchases.product!.price}/ay',
                    C.button, () async {
                  final e = await Purchases.buy();
                  if (e != null && context.mounted) {
                    showInfo(context, tr('Satın alma'), e);
                  }
                }),
                const SizedBox(height: 12),
                if (!app.trialUsed)
                  _btn(tr('3 gün ücretsiz dene'), const Color(0xFF7146F4), () {
                    app.startFreeTrial();
                    showInfo(context, tr('Deneme başladı'),
                        tr('3 gün boyunca tüm Premium özellikler açık.'));
                  }),
              ],
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final e = await Purchases.restore();
                    if (context.mounted) {
                      showInfo(context, tr('Satın alımları geri yükle'),
                          e ?? tr('Önceki satın alımın varsa birkaç saniye içinde etkinleşir.'));
                    }
                  },
                  child: Text(tr('Satın alımları geri yükle'),
                      style: TextStyle(
                          fontFamily: 'Figtree',
                          color: C.accent,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              Text(
                  tr('Abonelik, iptal edilmediği sürece dönem sonunda yenilenir. Mağaza hesabının ayarlarından istediğin zaman iptal edebilirsin.'),
                  textAlign: TextAlign.center,
                  style: T.body.copyWith(fontSize: 10.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(String t, Color c, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration:
              BoxDecoration(color: c, borderRadius: BorderRadius.circular(27)),
          child: Center(
              child: Text(t,
                  style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Colors.white))),
        ),
      );
}
