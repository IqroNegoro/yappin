import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Kolom tulis pesan + tombol kirim.
class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuild supaya tombol kirim aktif/redup mengikuti isi teks.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty;
    const duration = Duration(milliseconds: 150);

    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kLine)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                // Di web langsung siap mengetik saat room dibuka.
                // Di HP tidak, supaya keyboard tidak tiba-tiba muncul.
                autofocus: kIsWeb,
                // Enter = kirim (tanpa ini, field multi-baris memakai Enter untuk baris baru)
                textInputAction: TextInputAction.send,
                // Pakai onEditingComplete (bukan onSubmitted) supaya fokus
                // tetap di kolom input setelah Enter, jadi bisa langsung ngetik lagi.
                onEditingComplete: _send,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan…',
                  filled: true,
                  fillColor: kField,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: canSend ? 1 : 0.85,
              duration: duration,
              child: AnimatedOpacity(
                opacity: canSend ? 1 : 0.4,
                duration: duration,
                child: IconButton.filled(
                  onPressed: canSend ? _send : null,
                  icon: const Icon(Icons.arrow_upward),
                  style: IconButton.styleFrom(
                    backgroundColor: kInk,
                    foregroundColor: kOnInk,
                    disabledBackgroundColor: kInk,
                    disabledForegroundColor: kOnInk,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
