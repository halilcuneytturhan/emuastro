import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'l10n.dart';
import 'package:flutter/services.dart';

import 'data/sample.dart';
import 'screens/chat.dart';
import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'services/notifications.dart';
import 'screens/premium.dart';
import 'services/backend.dart';
import 'screens/profile.dart';
import 'screens/relations.dart';
import 'theme.dart';
import 'widgets/common.dart' show showInfo;
import 'widgets/nav.dart';
import 'l10n.dart';
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
  await Backend.init();
  await Notifications.init();
  if (app.onboarded) Notifications.reschedule();
  Purchases.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const EmuAstroApp());
}

/// Web önizlemede (karşılaştırma ekran görüntüleri için) iPhone güvenli alanını taklit et.
const _simulateInsets = kIsWeb;

class EmuAstroApp extends StatefulWidget {
  const EmuAstroApp({super.key});
  @override
  State<EmuAstroApp> createState() => _EmuAstroAppState();
}

class _EmuAstroAppState extends State<EmuAstroApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    app.addListener(_onApp);
  }

  String _lastMode = app.themeMode;
  String _lastLang = app.lang;
  void _onApp() {
    if (app.themeMode != _lastMode || app.lang != _lastLang) {
      final langChanged = app.lang != _lastLang;
      _lastMode = app.themeMode;
      _lastLang = app.lang;
      setState(() {});
      if (langChanged) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          app.relocalize();
          Notifications.reschedule();
        });
      }
    }
  }

  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    app.removeListener(_onApp);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sys = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final dark = app.themeMode == 'dark' ||
        (app.themeMode == 'system' && sys == Brightness.dark);
    C.dark = dark;
    final sysLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    L.en = app.lang == 'en' || (app.lang == 'system' && sysLang != 'tr');
    SystemChrome.setSystemUIOverlayStyle(
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    return MaterialApp(
      key: ValueKey('$dark-${L.en}'),
      title: 'EmuAstro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Figtree',
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: C.page,
        colorScheme: ColorScheme.fromSeed(
            seedColor: C.accent,
            brightness: dark ? Brightness.dark : Brightness.light),
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
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  @override
  Widget build(BuildContext context) {
    // Web karşılaştırma görüntülerinde (?date=) tanıtım atlanır.
    final skip = kIsWeb && Uri.base.queryParameters.containsKey('date');
    if (!app.onboarded && !skip) {
      return OnboardingScreen(onDone: () {
        Notifications.reschedule();
        setState(() {});
      });
    }
    return const Shell();
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with WidgetsBindingObserver {
  int tab = 0;
  final ctl = List.generate(4, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final m = app.rewardMessage;
      if (m != null && mounted) {
        app.rewardMessage = null;
        showInfo(context, tr('Seri ödülü'), m);
      }
    });
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) app.refreshDay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
