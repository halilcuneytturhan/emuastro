import 'package:flutter/material.dart';

import '../astro/places.dart';
import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import '../widgets/sprites.dart';
import '../widgets/surface.dart';
import 'friends.dart' show fmtDate;
import 'legal.dart';

/// İlk açılış: isim, doğum tarihi, saat, yer ve gizlilik onayı.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final name = TextEditingController();
  DateTime birth = DateTime(2000, 1, 1);
  TimeOfDay? time = const TimeOfDay(hour: 12, minute: 0);
  bool unknownTime = false;
  String place = places.first.name;
  bool consent = false;

  bool get _canNext => switch (step) {
        0 => true,
        1 => name.text.trim().isNotEmpty,
        4 => consent,
        _ => true,
      };

  Future<void> _next() async {
    if (step < 4) {
      setState(() => step++);
      return;
    }
    final t = unknownTime || time == null
        ? '12:00'
        : '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
    await app.finishOnboarding(name.text.trim(), birth, t, place);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: C.page,
      body: PaperBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(kSide, top + 20, kSide, bottom + 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                        color: i <= step ? C.accent : const Color(0xFFE3E0EA),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ]),
            const SizedBox(height: 36),
            Expanded(child: SingleChildScrollView(child: _body(context))),
            Row(children: [
              if (step > 0)
                TextButton(
                    onPressed: () => setState(() => step--),
                    child: const Text('Geri',
                        style: TextStyle(fontFamily: 'Figtree', color: C.grey))),
              const Spacer(),
              GestureDetector(
                onTap: _canNext ? _next : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _canNext ? 1 : .35,
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(27)),
                    child: Center(
                      child: Text(step == 4 ? 'Haritamı oluştur' : 'Devam',
                          style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _title(String k, String t, String sub) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: T.sectionLabel),
        const SizedBox(height: 8),
        Text(t, style: T.display.copyWith(fontSize: 28)),
        const SizedBox(height: 10),
        Text(sub, style: T.body.copyWith(fontSize: 14)),
        const SizedBox(height: 28),
      ]);

  Widget _field(String label, String value, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E0E8))),
          child: Row(children: [
            Text(label, style: T.body.copyWith(fontSize: 13)),
            const Spacer(),
            Text(value, style: T.heading.copyWith(fontSize: 15)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: C.greyLight),
          ]),
        ),
      );

  Widget _body(BuildContext context) {
    switch (step) {
      case 0:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const Center(child: Sprite('star', size: 90, cells: 30)),
          const SizedBox(height: 30),
          _title('EMUASTRO', 'Gökyüzü sana ne söylüyor?',
              'Doğum haritanı hesaplayıp her gün sana özel skorlar, uyarılar ve öneriler hazırlıyoruz.'),
          Pearl(
            pal: Pal.purple,
            radius: 24,
            padding: const EdgeInsets.all(22),
            child: Row(children: [
              DotText('%72', pitch: 4.4),
              const SizedBox(width: 18),
              const Expanded(
                child: Text('Günlük yaşam haritan, transitlerin doğum haritana etkisinden hesaplanır.',
                    style: TextStyle(
                        fontFamily: 'Figtree', color: Colors.white, fontSize: 13)),
              ),
            ]),
          ),
        ]);
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('1 / 4', 'Sana nasıl hitap edelim?', 'Ana sayfada seni bu isimle karşılarız.'),
          TextField(
            controller: name,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: T.heading.copyWith(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'İsmin',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFE2E0E8))),
            ),
          ),
        ]);
      case 2:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('2 / 4', 'Ne zaman doğdun?', 'Güneş ve gezegen burçların doğum tarihinden hesaplanır.'),
          _field('Doğum tarihi', fmtDate(birth), () async {
            final d = await showDatePicker(
                context: context,
                initialDate: birth,
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
            if (d != null) setState(() => birth = d);
          }),
          const SizedBox(height: 12),
          _field('Doğum saati', unknownTime ? 'Bilmiyorum' : time!.format(context), () async {
            final r = await showTimePicker(context: context, initialTime: time!);
            if (r != null) setState(() {
              time = r;
              unknownTime = false;
            });
          }),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: unknownTime,
            onChanged: (v) => setState(() => unknownTime = v ?? false),
            title: Text('Saatimi bilmiyorum (Ay ve Yükselen yaklaşık olur)',
                style: T.body.copyWith(fontSize: 13, color: C.ink)),
          ),
        ]);
      case 3:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('3 / 4', 'Nerede doğdun?', 'Yükselen burcun ve evlerin doğum yerine göre hesaplanır.'),
          for (final p in places.take(12))
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: p.name,
              groupValue: place,
              onChanged: (v) => setState(() => place = v!),
              title: Text(p.name, style: T.heading.copyWith(fontSize: 14)),
            ),
          TextButton(
            onPressed: () async {
              final r = await showModalBottomSheet<String>(
                  context: context,
                  builder: (c) => ListView(children: [
                        for (final p in places)
                          ListTile(title: Text(p.name), onTap: () => Navigator.pop(c, p.name)),
                      ]));
              if (r != null) setState(() => place = r);
            },
            child: Text('Diğer şehirler… (seçili: $place)',
                style: const TextStyle(fontFamily: 'Figtree', color: C.accent)),
          ),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('4 / 4', 'Verilerin sende kalır',
              'Doğum bilgilerin ve tüm uygulama verilerin yalnızca bu cihazda saklanır.'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: consent,
            onChanged: (v) => setState(() => consent = v ?? false),
            title: Text(
                'Aydınlatma Metni’ni okudum; doğum bilgilerimin harita hesaplamak için işlenmesini kabul ediyorum.',
                style: T.body.copyWith(fontSize: 13, color: C.ink)),
          ),
          TextButton(
            onPressed: () => openLegal(context),
            child: const Text('Aydınlatma Metni ve Gizlilik Politikası',
                style: TextStyle(fontFamily: 'Figtree', color: C.accent, fontWeight: FontWeight.w700)),
          ),
        ]);
    }
  }
}
