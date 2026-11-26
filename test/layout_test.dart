import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emuastro/main.dart';

void main() {
  testWidgets('ana sekmeler açılır ve etiketler görünür', (t) async {
    t.view.physicalSize = const Size(430 * 3, 932 * 3);
    t.view.devicePixelRatio = 3;
    await t.pumpWidget(const EmuAstroApp());
    await t.pump(const Duration(milliseconds: 500));
    for (final s in ['YILDIZ', 'AY', 'Kişisel Haritan', 'Merhaba, buket']) {
      final f = find.text(s);
      expect(f, findsWidgets, reason: s);
      // ignore: avoid_print
      print('$s -> ${t.getRect(f.first)}');
    }
    await t.tap(find.text('İlişkiler').last);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Rehberini bağla', skipOffstage: false), findsWidgets);
    await t.tap(find.text('Profil').last);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Transit', skipOffstage: false), findsWidgets);
  });
}
