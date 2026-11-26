import 'package:flutter/material.dart';

import '../l10n.dart';

import '../data/sample.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sprites.dart';
import 'premium.dart';

/// Haritanla ilgili soru-cevap. Yanıtlar cihazdaki yorum motorundan gelir.
class ChatScreen extends StatefulWidget {
  final ScrollController controller;
  const ChatScreen({super.key, required this.controller});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  static List<String> get suggestions => [
    tr('Bugün nelere dikkat etmeliyim?'),
    tr('Bu hafta iş görüşmesi için hangi gün uygun?'),
    tr('Aşk hayatım için haritam ne diyor?'),
    tr('Enerjimi nasıl yükseltirim?'),
  ];

  Future<void> _send(String q) async {
    if (q.trim().isEmpty) return;
    final err = await app.askAsync(q.trim());
    if (!mounted) return;
    if (err != null) {
      showInfo(context, tr('Soru hakkın doldu'), err);
      if (!app.premium) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) openPremium(context);
        });
      }
      return;
    }
    input.clear();
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (widget.controller.hasClients) {
        widget.controller.animateTo(widget.controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => Column(children: [
        Expanded(
          child: ListView(
            controller: widget.controller,
            padding: EdgeInsets.fromLTRB(kSide, top + 26, kSide, 20),
            children: [
              Text(tr('EMUASTRO’YA SOR'), style: T.sectionLabel),
              const SizedBox(height: 5),
              Text(tr('Sor'), style: T.display),
              const SizedBox(height: 6),
              Text(
                  l('Bugün ${(app.questionLimit - app.questionsToday).clamp(0, 9)} soru hakkın kaldı', '${(app.questionLimit - app.questionsToday).clamp(0, 9)} question${(app.questionLimit - app.questionsToday) == 1 ? '' : 's'} left today') + ' · ${app.premium ? 'Premium' : tr('Ücretsiz plan')}',
                  style: T.body),
              const SizedBox(height: 22),
              if (app.chat.isEmpty) ...[
                Row(children: [
                  const Sprite('star', size: 34, cells: 20),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(
                          tr('Haritanı ve bugünkü gökyüzünü birlikte okuyarak yanıt veririm. Bir konu seç ya da kendi sorunu yaz.'),
                          style: T.body.copyWith(color: C.ink, fontSize: 13.5))),
                ]),
                const SizedBox(height: 18),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in suggestions)
                    GestureDetector(
                      onTap: () => _send(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                            color: C.panel,
                            borderRadius: BorderRadius.circular(18)),
                        child: Text(s,
                            style: T.body.copyWith(color: C.ink, fontSize: 12.6)),
                      ),
                    ),
                ]),
              ],
              for (final m in app.chat)
                Align(
                  alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .78),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                    decoration: BoxDecoration(
                      color: m.me ? const Color(0xFF7146F4) : C.panel,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(m.text,
                        style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 13.6,
                            height: 1.4,
                            color: m.me ? Colors.white : C.ink)),
                  ),
                ),
              if (app.chat.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      tr('Yorumlar eğlence ve öz farkındalık amaçlıdır; tıbbi, finansal veya hukuki tavsiye değildir.'),
                      style: T.body.copyWith(fontSize: 9.4, color: C.greyLight)),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(kSide, 6, kSide, bottom + 80),
          child: Row(children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: C.line)),
                child: TextField(
                  controller: input,
                  onSubmitted: _send,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: tr('Haritana bir soru sor…'),
                      hintStyle: TextStyle(fontFamily: 'Figtree', color: C.grey)),
                  style: const TextStyle(fontFamily: 'Figtree', fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(input.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: C.button, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
