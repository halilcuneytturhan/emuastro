import 'package:flutter/material.dart';

import '../l10n.dart';

import '../astro/places.dart';
import '../theme.dart';

String _norm(String s) => s
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('İ', 'i')
    .replaceAll('i̇', 'i')
    .replaceAll('ş', 's')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c');

/// Ekranı kaplayan, aramalı doğum yeri seçici.
Future<String?> pickPlace(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: C.page,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => _PlaceSheet(current: current),
  );
}

class _PlaceSheet extends StatefulWidget {
  final String? current;
  const _PlaceSheet({this.current});
  @override
  State<_PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends State<_PlaceSheet> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final nq = _norm(q);
    final list = places.where((p) => nq.isEmpty || _norm(p.name).contains(nq)).toList();
    final h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: h * .92,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(children: [
          const SizedBox(height: 10),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: C.greyLight, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(children: [
              Text(tr('Doğum yeri'), style: T.monoTitleBold),
              const Spacer(),
              Text(l('${places.length} şehir', '${places.length} cities'), style: T.body.copyWith(fontSize: 12)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => q = v),
              style: T.heading.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: tr('Şehir ara (ör. Konya, Berlin)'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: C.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: C.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: C.line)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                          tr('Bu isimde şehir bulunamadı. Doğduğun yere en yakın büyük şehri seçebilirsin; Yükselen birkaç derece değişebilir.'),
                          textAlign: TextAlign.center,
                          style: T.body),
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final p = list[i];
                      final sel = p.name == widget.current;
                      final parts = p.name.split(', ');
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        title: Text(parts.first,
                            style: T.heading.copyWith(fontSize: 15)),
                        subtitle: parts.length > 1
                            ? Text(parts.last, style: T.body.copyWith(fontSize: 12))
                            : null,
                        trailing: sel
                            ? Icon(Icons.check_circle_rounded, color: C.accent)
                            : null,
                        onTap: () => Navigator.pop(context, p.name),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
