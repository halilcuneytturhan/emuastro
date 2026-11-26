import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../astro/interpret.dart';
import '../data/sample.dart';
import '../l10n.dart';
import 'emu_pdf.dart';

/// Tüm başlıkları tek PDF'te toplar ve paylaşım menüsünü açar.
Future<String?> exportPdf() async {
  final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Figtree-400.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Figtree-800.ttf'));
  final logo = (await rootBundle.load('assets/brand/logo.png')).buffer.asUint8List();
  final c = app.chart;
  final d = app.day;
  final b = app.profile;
  final t = app.today;
  final pdf = EmuPdf(
    brand: EmuPdfBrand(
        appName: 'EmuAstro', accent: const PdfColor.fromInt(0xFF784CF9), logo: logo),
    fonts: EmuPdfFonts(regular: regular, bold: bold),
    title: b.name,
    subtitle:
        '${b.birth.day}.${b.birth.month}.${b.birth.year} ${b.time} · ${b.place}',
    disclaimer:
        'Astrolojik yorumlar eğlence ve öz farkındalık amaçlıdır; tıbbi, finansal veya hukuki tavsiye değildir.',
  );
  final bytes = await pdf.build([
    pdf.stats([
      ('Güneş', c.signName('sun')),
      ('Ay', c.signName('moon')),
      ('Yükselen', c.signName('asc')),
    ]),
    pdf.section('Gezegen konumları'),
    pdf.keyValues([
      for (final pl in c.planets)
        (
          planetName[pl.id] ?? pl.id,
          '${signs[pl.sign]} ${pl.degInSign.toStringAsFixed(1)}°${pl.retro ? ' (R)' : ''} · ${c.house(pl.lon)}. ev'
        ),
    ]),
    pdf.section('${tr('Bugün')} (${t.day}.${t.month}.${t.year})'),
    pdf.stats([
      ('Fırsat ve akış', '%${d.scores[0]}'),
      ('Zihin ve odak', '%${d.scores[1]}'),
      ('Enerji', '%${d.scores[2]}'),
    ]),
    pw.SizedBox(height: 8),
    pdf.keyValues([
      ('Bugün yap', d.todo),
      ('Uzak dur', d.never),
      ('Dikkat et', d.watch),
      ('Bu dönem', d.period),
    ]),
    pdf.section('Gökyüzü takvimi'),
    for (final e in app.events) ...[
      pdf.heading('${e.kicker} – ${e.title}'),
      pdf.paragraph(e.body),
    ],
    pdf.section('Kişisel harita raporu'),
    for (var i = 0; i < reportSections.length; i++)
      if (i < app.unlocked) ...[
        pdf.heading(reportSections[i]),
        pdf.paragraph(reportText(c, i)),
      ],
    if (!app.premium)
      pdf.note('Diğer ${reportSections.length - 1} bölüm Premium ile açılır.'),
  ]);
  final name = 'EmuAstro_${b.name}.pdf';
  if (kIsWeb) {
    await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, name: name, mimeType: 'application/pdf')]));
    return null;
  }
  final dir = await getTemporaryDirectory();
  final f = File('${dir.path}/$name');
  await f.writeAsBytes(bytes);
  await SharePlus.instance.share(
      ShareParams(files: [XFile(f.path, mimeType: 'application/pdf')], subject: name));
  return null;
}
