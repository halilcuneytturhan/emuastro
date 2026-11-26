import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emuastro/main.dart';
import 'package:emuastro/data/sample.dart';
import 'package:emuastro/astro/interpret.dart' as astro;

void main() {
  test('örnek harita: Güneş Aslan, Ay Akrep, Yükselen Başak', () {
    final c = astro.Chart.of(astro.BirthData(
        'buket', DateTime(2004, 7, 25, 9, 30), 'İstanbul, Türkiye'));
    expect(c.signName('sun'), 'Aslan');
    expect(c.signName('moon'), 'Akrep');
    expect(c.signName('asc'), 'Başak');
  });

  test('hediye kodu: üretilen kod başka cihazda geçerli, kendi kodu reddedilir', () {
    final a = AppData();
    final code = a.createGiftCode()!;
    expect(a.giftsLeft, 2);
    expect(a.redeemCode(code), isNotNull); // kendi kodu
    final b = AppData();
    expect(b.redeemCode('EMU-AAAAAA-A'), isNotNull);
    expect(b.redeemCode(code), isNull);
    expect(b.premium, isTrue);
  });

  test('ücretsiz planda günde 1 soru', () {
    final a = AppData();
    expect(a.ask('Bugün nasıl?'), isNull);
    expect(a.chat.length, 2);
    expect(a.ask('Yine?'), isNotNull);
  });

  testWidgets('ilk açılış ekranı gösterilir', (t) async {
    t.view.physicalSize = const Size(430 * 3, 932 * 3);
    t.view.devicePixelRatio = 3;
    app.lang = 'tr';
    app.onboarded = false;
    await t.pumpWidget(const EmuAstroApp());
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Gökyüzü sana ne söylüyor?'), findsOneWidget);
  });

  testWidgets('dört sekme açılır', (t) async {
    t.view.physicalSize = const Size(430 * 3, 932 * 3);
    t.view.devicePixelRatio = 3;
    app.lang = 'tr';
    app.onboarded = true;
    await t.pumpWidget(const EmuAstroApp());
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Doğum Dosyan'), findsWidgets);
    await t.tap(find.bySemanticsLabel('İlişkiler'));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Rehberi aç', skipOffstage: false), findsWidgets);
    await t.tap(find.bySemanticsLabel('Sor'));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Haritana bir soru sor…', skipOffstage: false), findsWidgets);
    await t.tap(find.bySemanticsLabel('Profil'));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Transit', skipOffstage: false), findsWidgets);
  });
}

