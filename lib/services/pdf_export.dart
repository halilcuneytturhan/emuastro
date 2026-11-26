import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../astro/interpret.dart';
import '../data/sample.dart';

/// Tüm başlıkları tek PDF'te toplar ve paylaşım menüsünü açar.
Future<String?> exportPdf() async {
  final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Figtree-400.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Figtree-800.ttf'));
  final mono = pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexMono-500.ttf'));
  final c = app.chart;
  final d = app.day;
  final doc = pw.Document(title: 'EmuAstro – ${app.profile.name}');
  pw.Widget h(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
      child: pw.Text(t, style: pw.TextStyle(font: mono, fontSize: 14)));
  pw.Widget p(String t) =>
      pw.Text(t, style: pw.TextStyle(font: regular, fontSize: 11, lineSpacing: 3));
  final b = app.profile;
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => [
      pw.Text('EmuAstro', style: pw.TextStyle(font: bold, fontSize: 24)),
      pw.Text(
          '${b.name} · ${b.birth.day}.${b.birth.month}.${b.birth.year} ${b.time} · ${b.place}',
          style: pw.TextStyle(font: regular, fontSize: 11, color: PdfColors.grey700)),
      pw.SizedBox(height: 8),
      p('Güneş ${c.signName('sun')} · Ay ${c.signName('moon')} · Yükselen ${c.signName('asc')}'),
      h('Gezegen konumları'),
      for (final pl in c.planets)
        p('${planetName[pl.id]}: ${signs[pl.sign]} ${pl.degInSign.toStringAsFixed(1)}°${pl.retro ? ' (R)' : ''} · ${c.house(pl.lon)}. ev'),
      h('Bugün (${dateLine(app.today)})'),
      p('Fırsat ve akış %${d.scores[0]} · Zihin ve odak %${d.scores[1]} · Enerji %${d.scores[2]}'),
      p('Bugün yap: ${d.todo}'),
      p('Bugün asla yapma: ${d.never}'),
      p('Dikkat et: ${d.watch}'),
      p('Bu dönem: ${d.period}'),
      h('Gökyüzünde neler oluyor'),
      for (final e in app.events) p('${e.kicker} – ${e.title}: ${e.body}'),
      h('Kişisel harita raporu'),
      for (var i = 0; i < reportSections.length; i++)
        if (i < app.unlocked) ...[
          pw.Text(reportSections[i], style: pw.TextStyle(font: bold, fontSize: 12)),
          p(reportText(c, i)),
          pw.SizedBox(height: 6),
        ],
      if (!app.premium)
        p('Diğer ${reportSections.length - 1} bölüm Premium ile açılır.'),
      pw.SizedBox(height: 20),
      pw.Text(
          'Astrolojik yorumlar eğlence ve öz farkındalık amaçlıdır; tıbbi, finansal veya hukuki tavsiye değildir.',
          style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
    ],
  ));
  final bytes = await doc.save();
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
