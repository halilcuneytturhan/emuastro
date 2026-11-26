import 'package:flutter/material.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/sprites.dart';
import '../widgets/surface.dart';

class _Back extends StatelessWidget {
  const _Back();
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6E4EC))),
          child: const Icon(Icons.chevron_left_rounded, color: C.ink),
        ),
      );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});
  static const sections = [
    'Mizaç', 'Duygusal dünya', 'Gölge yönler', 'Aşk dili', 'Kariyer kodu',
    'İletişim', 'Para', 'Aile', 'Arkadaşlık', 'Yaratıcılık', 'Sağlık rutinleri',
    'Dönüşüm', 'Yolculuklar', 'Toplum', 'Ruhsal yol'
  ];
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.page,
      body: PaperBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(kSide, top + 14, kSide, 60),
          children: [
            const Align(alignment: Alignment.centerLeft, child: _Back()),
            const SizedBox(height: 22),
            const Text('KİŞİSEL HARİTAN', style: T.sectionLabel),
            const SizedBox(height: 8),
            const Text('Detaylı analiz', style: T.monoTitleBold),
            const SizedBox(height: 20),
            for (final (i, s) in sections.indexed) ...[
              Pearl(
                pal: i == 0 ? Pal.purple : Pal.charcoal,
                radius: 22,
                shadowAlpha: i == 0 ? .4 : .15,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(children: [
                  DotText('${i + 1}'.padLeft(2, '0'), pitch: 3.2, glow: 0),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Text(s,
                          style: T.monoCard.copyWith(fontSize: 15))),
                  if (i > 0) const Sprite('lock', size: 14, cells: 14),
                ]),
              ),
              if (i == 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                  child: Text(
                      'Güneş Aslan’da: sahneye çıkmaktan çekinmeyen, sıcak ve cömert bir öz. Ay Akrep’te: duyguların derin, sadakatin yoğun. Yükselen Başak ise dünyaya düzenli, dikkatli ve seçici bir yüz gösteriyor.',
                      style: T.body.copyWith(color: C.ink, fontSize: 14)),
                ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class EventDetail extends StatelessWidget {
  final SkyEvent event;
  final Pal pal;
  const EventDetail({super.key, required this.event, required this.pal});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.page,
      body: PaperBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(kSide, top + 14, kSide, 60),
          children: [
            const Align(alignment: Alignment.centerLeft, child: _Back()),
            const SizedBox(height: 22),
            EventBand(event, pal),
            const SizedBox(height: 26),
            Text(event.title, style: T.monoTitleBold),
            const SizedBox(height: 12),
            Text(event.body,
                style: T.body.copyWith(color: C.ink, fontSize: 14.5)),
            const SizedBox(height: 22),
            Pearl(
              pal: pal,
              radius: 22,
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                EventBadge(event.kind, pal, size: 70),
                const SizedBox(width: 14),
                const Expanded(
                    child: Text(
                        'Etkiyi okumayı tamamla, bu dönemin rozetini koleksiyonuna ekle.',
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 13,
                            color: Colors.white))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
