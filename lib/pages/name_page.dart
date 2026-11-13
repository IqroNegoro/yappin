import 'package:flutter/material.dart';

import '../session.dart';
import '../theme.dart';
import 'rooms_page.dart';

/// Halaman isi nama (pengganti login).
class NamePage extends StatefulWidget {
  final String? initialName;

  const NamePage({super.key, this.initialName});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void initState() {
    super.initState();
    // Rebuild supaya tombol "Masuk" aktif/nonaktif mengikuti isi teks.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await Session.save(name);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoomsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Yappin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan nama untuk mulai ngobrol',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kSubtle),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  maxLength: 20,
                  // Pertama kali buka app: langsung siap mengetik nama.
                  autofocus: widget.initialName == null,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Nama kamu'),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
