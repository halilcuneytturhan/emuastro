import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// EMU Technologies ortak PDF şablonu.
///
/// Tüm Emu uygulamaları (EmuAstro, EmuFit, EmuMakrofis, EmuMini, EmuBoykot,
/// EmuEzan) aynı düzeni kullanır; uygulamaya özel olan yalnızca ad, logo ve
/// vurgu rengidir. Bu dosya bağımlılık olarak yalnız `package:pdf` ister,
/// diğer uygulamalara olduğu gibi kopyalanabilir.
class EmuPdfBrand {
  const EmuPdfBrand({
    required this.appName,
    required this.accent,
    this.logo,
  });

  final String appName;
  final PdfColor accent;
  final Uint8List? logo;

  static const company = 'EMU Technologies';
}

class EmuPdfFonts {
  const EmuPdfFonts({required this.regular, required this.bold, this.mono});
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font? mono;
}

class EmuPdf {
  EmuPdf({
    required this.brand,
    required this.fonts,
    required this.title,
    this.subtitle,
    this.disclaimer,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  final EmuPdfBrand brand;
  final EmuPdfFonts fonts;
  final String title;
  final String? subtitle;
  final String? disclaimer;
  final DateTime date;

  static const _ink = PdfColor.fromInt(0xFF15141A);
  static const _muted = PdfColor.fromInt(0xFF77757F);
  static const _line = PdfColor.fromInt(0xFFE6E5EB);
  static const _panel = PdfColor.fromInt(0xFFF5F4F8);

  String get _dateText =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  pw.TextStyle get body =>
      pw.TextStyle(font: fonts.regular, fontSize: 10.5, lineSpacing: 3, color: _ink);
  pw.TextStyle get small =>
      pw.TextStyle(font: fonts.regular, fontSize: 8, color: _muted);

  // ---- İçerik yapı taşları ----

  /// Bölüm başlığı: vurgu çizgisi + başlık.
  pw.Widget section(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
        child: pw.Row(children: [
          pw.Container(width: 3, height: 13, color: brand.accent),
          pw.SizedBox(width: 7),
          pw.Text(text.toUpperCase(),
              style: pw.TextStyle(
                  font: fonts.bold, fontSize: 11, letterSpacing: 0.8, color: _ink)),
        ]),
      );

  pw.Widget heading(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
        child: pw.Text(text,
            style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: _ink)),
      );

  pw.Widget paragraph(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(text, style: body),
      );

  /// Etiket–değer satırları (tablo görünümü).
  pw.Widget keyValues(List<(String, String)> rows) => pw.Table(
        columnWidths: const {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(5)},
        border: const pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _line, width: 0.6)),
        children: [
          for (final (k, v) in rows)
            pw.TableRow(children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(k,
                      style: pw.TextStyle(font: fonts.bold, fontSize: 9.5, color: _muted))),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(v, style: body)),
            ]),
        ],
      );

  /// Öne çıkan sayılar (ör. skorlar, kalori, makrolar).
  pw.Widget stats(List<(String, String)> items) => pw.Row(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                  color: _panel, borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(items[i].$2,
                    style: pw.TextStyle(font: fonts.bold, fontSize: 16, color: brand.accent)),
                pw.SizedBox(height: 2),
                pw.Text(items[i].$1, style: small),
              ]),
            ),
          ),
        ],
      ]);

  /// Bilgi kutusu (not, uyarı, kilitli içerik vb.).
  pw.Widget note(String text) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 6),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _panel,
          border: pw.Border(left: pw.BorderSide(color: brand.accent, width: 2)),
        ),
        child: pw.Text(text, style: body.copyWith(fontSize: 9.5, color: _muted)),
      );

  // ---- Sayfa iskeleti ----

  pw.Widget _cover() => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.only(bottom: 14),
        decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _line, width: 0.8))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(title,
              style: pw.TextStyle(font: fonts.bold, fontSize: 22, color: _ink)),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(subtitle!, style: body.copyWith(color: _muted)),
          ],
        ]),
      );

  pw.Widget _header(pw.Context ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: brand.accent, width: 1.2))),
        child: pw.Row(children: [
          if (brand.logo != null) ...[
            pw.ClipRRect(
              horizontalRadius: 4,
              verticalRadius: 4,
              child: pw.Image(pw.MemoryImage(brand.logo!), width: 20, height: 20),
            ),
            pw.SizedBox(width: 8),
          ],
          pw.Text(brand.appName,
              style: pw.TextStyle(font: fonts.bold, fontSize: 12, color: _ink)),
          pw.Spacer(),
          pw.Text(_dateText, style: small),
        ]),
      );

  pw.Widget _footer(pw.Context ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 12),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line, width: 0.6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          if (disclaimer != null && ctx.pageNumber == ctx.pagesCount) ...[
            pw.Text(disclaimer!, style: small.copyWith(fontSize: 7)),
            pw.SizedBox(height: 4),
          ],
          pw.Row(children: [
            pw.Text('${brand.appName} · ${EmuPdfBrand.company}',
                style: small.copyWith(font: fonts.bold)),
            pw.Spacer(),
            pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: small),
          ]),
        ]),
      );

  /// İçeriği EMU şablonuna yerleştirip PDF baytlarını döndürür.
  Future<Uint8List> build(List<pw.Widget> content) async {
    final doc = pw.Document(
      title: '${brand.appName} – $title',
      author: EmuPdfBrand.company,
      creator: '${brand.appName} · ${EmuPdfBrand.company}',
      producer: EmuPdfBrand.company,
    );
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 32, 44, 28),
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      header: _header,
      footer: _footer,
      build: (_) => [_cover(), ...content],
    ));
    return doc.save();
  }
}
