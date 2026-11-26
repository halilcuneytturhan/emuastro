import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/sample.dart';
import 'screens/chat.dart';
import 'screens/home.dart';
import 'screens/premium.dart';
import 'screens/profile.dart';
import 'screens/relations.dart';
import 'theme.dart';
import 'widgets/nav.dart';
import 'widgets/surface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Grain.init();
  DateTime? fixedDay;
  if (kIsWeb) {
    // Karşılaştırma görüntüleri için: ?date=2026-11-25
    fixedDay = DateTime.tryParse(Uri.base.queryParameters['date'] ?? '');
  }
  await app.load(overrideToday: fixedDay);
  Purchases.init();
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
  final ctl = List.generate(4, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    // Karşılaştırma için: ?tab=0..3&scroll=300
    if (kIsWeb) {
      final q = Uri.base.queryParameters;
      tab = (int.tryParse(q['tab'] ?? '') ?? 0).clamp(0, 3);
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

  void _select(int i) {
    if (i == tab && ctl[i].hasClients) {
      ctl[i].animateTo(0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
    }
    setState(() => tab = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: tab == 2,
      body: PaperBackground(
        child: Stack(children: [
          ListenableBuilder(
            listenable: app,
            builder: (context, _) => IndexedStack(index: tab, children: [
              HomeScreen(controller: ctl[0]),
              RelationsScreen(controller: ctl[1]),
              ChatScreen(controller: ctl[2]),
              ProfileScreen(controller: ctl[3], openRelations: () => _select(1)),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: EmuNavBar(selectedIndex: tab, onSelected: _select),
          ),
        ]),
      ),
    );
  }
}
