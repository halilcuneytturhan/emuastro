import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/relations.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/surface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Grain.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const EmuAstroApp());
}

/// Web önizlemede (karşılaştırma ekran görüntüleri için) iPhone güvenli alanını taklit et.
const _simulateInsets = kIsWeb;

class EmuAstroApp extends StatelessWidget {
  const EmuAstroApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmuAstro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Figtree',
        scaffoldBackgroundColor: C.page,
        colorScheme: ColorScheme.fromSeed(seedColor: C.accent),
      ),
      builder: (context, child) {
        if (!_simulateInsets) return child!;
        final mq = MediaQuery.of(context);
        return MediaQuery(
            data: mq.copyWith(
                padding: const EdgeInsets.only(top: 54, bottom: 34),
                viewPadding: const EdgeInsets.only(top: 54, bottom: 34)),
            child: child!);
      },
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  bool compact = false;
  final ctl = [ScrollController(), ScrollController(), ScrollController()];

  @override
  void initState() {
    super.initState();
    // Karşılaştırma için: ?tab=1&scroll=300&compact=1
    if (kIsWeb) {
      final q = Uri.base.queryParameters;
      tab = int.tryParse(q['tab'] ?? '') ?? 0;
      compact = q['compact'] == '1';
      final sc = double.tryParse(q['scroll'] ?? '');
      if (sc != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (ctl[tab].hasClients) ctl[tab].jumpTo(sc);
          });
        });
      }
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      final c = n.direction != ScrollDirection.idle;
      if (c != compact) setState(() => compact = c);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: Stack(children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: IndexedStack(index: tab, children: [
              HomeScreen(controller: ctl[0]),
              RelationsScreen(controller: ctl[1]),
              ProfileScreen(
                  controller: ctl[2],
                  openRelations: () => setState(() => tab = 1)),
            ]),
          ),
          FloatingNav(
            index: tab,
            compact: compact,
            onTap: (i) {
              if (i == tab && ctl[i].hasClients) {
                ctl[i].animateTo(0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic);
              }
              setState(() => tab = i);
            },
            onChat: () => showInfo(context, 'EmuAstro’ya sor',
                'Haritanla ilgili sorularını burada sorabilirsin. Ücretsiz planda günde 1, Premium’da günde 5 soru hakkın var.\n\nÖrnek: “Bu hafta iş görüşmesi için hangi gün daha uygun?”'),
          ),
        ]),
      ),
    );
  }
}

