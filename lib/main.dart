import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/room.dart';
import 'pages/chat_page.dart';
import 'pages/name_page.dart';
import 'services/chat_service.dart';
import 'session.dart';
import 'theme.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final savedName = await Session.loadSavedName();
  runApp(App(initialName: savedName));
}

// Dipakai popup pesan baru untuk membuka room dari luar halaman.
final _navigatorKey = GlobalKey<NavigatorState>();

/// Tap popup → kembali ke daftar room, lalu buka room yang dipilih.
void _openRoomFromPopup(Room room) {
  final navigator = _navigatorKey.currentState!;
  navigator.popUntil((route) => route.isFirst);
  navigator.push(MaterialPageRoute(builder: (_) => ChatPage(room: room)));
}

class App extends StatelessWidget {
  final String? initialName;

  const App({super.key, this.initialName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yappin',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      // Popup pesan baru di atas semua halaman (aktif setelah watchRooms jadi).
      builder: (context, child) => MessagePopupHost(
        rooms: ChatService.watchRooms(),
        onTap: _openRoomFromPopup,
        child: child!,
      ),
      home: NamePage(initialName: initialName),
    );
  }
}
