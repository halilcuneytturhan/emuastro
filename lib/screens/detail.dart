import 'package:flutter/material.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/sprites.dart';
import '../widgets/surface.dart';
import 'premium.dart';

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

/// 15 bölümlük kişisel harita raporu. İlk bölüm ücretsiz, diğerleri Premium.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int open = 0;
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
              const Align(alignment: Alignment.centerLeft, child: _Back()),
              const SizedBox(height: 22),
              const Text('KİŞİSEL HARİTAN', style: T.sectionLabel),
              const SizedBox(height: 8),
              const Text('Detaylı analiz', style: T.monoTitleBold),
              const SizedBox(height: 6),
              Text(
                  'Güneş ${app.sun} · Ay ${app.moon} · Yükselen ${app.asc}',
                  style: T.body),
              const SizedBox(height: 20),
              for (var i = 0; i < reportSections.length; i++) ...[
                GestureDetector(
                  onTap: () {
                    if (i >= app.unlocked) {
                      openPremium(context);
                    } else {
                      setState(() => open = open == i ? -1 : i);
                    }
                  },
                  child: Pearl(
                    pal: open == i ? Pal.purple : Pal.charcoal,
                    radius: 22,
                    shadowAlpha: open == i ? .4 : .15,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Row(children: [
                      DotText('${i + 1}'.padLeft(2, '0'), pitch: 3.2, glow: 0),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Text(reportSections[i],
                              style: T.monoCard.copyWith(fontSize: 15))),
                      if (i >= app.unlocked)
                        const Sprite('lock', size: 14, cells: 14)
                      else
                        Icon(
                            open == i
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: Colors.white70),
                    ]),
                  ),
                ),
                if (open == i && i < app.unlocked)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                    child: Text(reportText(app.chart, i),
                        style: T.body.copyWith(color: C.ink, fontSize: 14)),
                  ),
                const SizedBox(height: 10),
              ],
            ],
          ),
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
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final earned = app.badges.contains(event.key);
            return ListView(
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
                GestureDetector(
                  onTap: earned
                      ? null
                      : () {
                          app.earnBadge(event.key);
                          showInfo(context, 'Rozet kazandın',
                              '“${event.title}” rozeti Profil > Rozetlerim bölümüne eklendi.');
                        },
                  child: Pearl(
                    pal: pal,
                    radius: 22,
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      EventBadge(event.kind, pal, size: 70, locked: !earned),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Text(
                              earned
                                  ? 'Bu dönemin rozeti koleksiyonunda.'
                                  : 'Etkiyi okudum — rozeti koleksiyonuma ekle',
                              style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
