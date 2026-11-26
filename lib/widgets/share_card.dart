import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

/// İçindeki kartı görsel (PNG) olarak paylaşılabilir yapar.
/// Kartın içindeki herhangi bir [ShareTap] dokununca görüntüyü yakalar.
class ShareCard extends StatefulWidget {
  final Widget child;
  final String text;
  const ShareCard({super.key, required this.child, required this.text});

  static _ShareCardState? of(BuildContext c) =>
      c.findAncestorStateOfType<_ShareCardState>();

  @override
  State<ShareCard> createState() => _ShareCardState();
}

class _ShareCardState extends State<ShareCard> {
  final _key = GlobalKey();

  Future<void> share() async {
    try {
      final b = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 3);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      await SharePlus.instance.share(ShareParams(
        text: '${widget.text}\n\n${l('EmuAstro ile günlük haritanı keşfet.', 'Discover your daily chart with EmuAstro.')}',
        files: [
          XFile.fromData(data!.buffer.asUint8List(),
              name: 'emuastro.png', mimeType: 'image/png')
        ],
      ));
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: widget.text));
    }
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(key: _key, child: widget.child);
}

/// Dokununca en yakın [ShareCard]'ı paylaşır.
class ShareTap extends StatelessWidget {
  final Widget child;
  const ShareTap({super.key, required this.child});
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ShareCard.of(context)?.share(),
        child: Padding(padding: const EdgeInsets.all(6), child: child),
      );
}
