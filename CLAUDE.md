# Yappin — Realtime Chat (Flutter + Firebase)

**Yappin** adalah repo praktikum **Mobile Intermediate** (D4 RPL tingkat 3, 8 jam). Hasil akhirnya aplikasi chat room realtime yang **JALAN**, rapi, dan terasa hidup (loading state, animasi kecil). Itu saja.

> Prinsip utama: **simple af, fast af.** Kalau ragu, pilih cara yang paling sedikit kodenya.

## Aturan keras (jangan dilanggar)
- **Tidak ada**: Firebase Auth, Security Rules (pakai test mode), state management library (Provider/Riverpod/Bloc/GetX), arsitektur berlapis (repository/usecase/DI), test, package animasi.
- **Package hanya**: `firebase_core`, `cloud_firestore`, `shared_preferences`. Jangan tambah package lain.
- **Harus jalan di Flutter 3.47 (Dart 3.13) dan 3.50.** Pakai `package:flutter/material.dart`, **jangan** `material_ui`/`cupertino_ui` (hapus dari pubspec kalau ditambahkan template). `environment: sdk: ">=3.9.0 <4.0.0"`. Pilih versi `firebase_core`, `cloud_firestore`, `shared_preferences` yang minimum SDK-nya ≤ Dart 3.13 (cek pub.dev), lalu pin di pubspec. Detail: F0 langkah 8.
- **Semua akses Firestore hanya di `lib/services/chat_service.dart`.**
- **Komponen di `lib/widgets/` murni UI**: data masuk lewat parameter, aksi keluar lewat callback. Tidak memanggil `ChatService`/Firestore. Diekspor lewat `lib/widgets/widgets.dart`.
- **Halaman (`lib/pages/`) hanya menyambungkan** stream/aksi `ChatService` ke komponen. Styling detail ada di komponen, bukan di halaman.
- State realtime = Firestore stream + `StreamBuilder`. State user = class statis `Session`.
- UI **monokrom lembut minimalis**: gelap `#424242`, off-white `#F5F5F5`/`#FAFAFA`, bukan pitch black/pure white. Semua warna dari konstanta di `lib/theme.dart`. **Dilarang** `Colors.black`/`Colors.white` (lihat `specs/F0-setup-theme.md`).
- Animasi hanya bawaan Flutter, halus & singkat (≤ 350 ms), sesuai `specs/C-komponen.md`.
- Semua teks UI berbahasa Indonesia.
- **Jangan membuat `lib/firebase_options.dart` sendiri.** File itu dihasilkan `flutterfire configure` oleh user. Kalau belum ada, berhenti dan minta user menjalankannya.
- Kode harus mudah dibaca mahasiswa: nama jelas, tanpa trik, komentar seperlunya.

## Urutan kerja
1. Di branch **`app`**: F0 → F1 → **C (semua komponen)** → F2 → F3 → F4 → F5 → F6. Satu bagian satu commit (`feat(F2): daftar room realtime`).
2. Setelah tiap bagian: `flutter analyze` tanpa error, lalu cek acceptance criteria di spec-nya.
3. F7: bikin branch **`main`** jadi starter untuk mahasiswa.
4. Push kedua branch. Default branch di GitHub = `main`.

| Spec | Isi |
|---|---|
| `specs/F0-setup-theme.md` | Setup project, package, Firebase, theme monokrom lembut |
| `specs/F1-input-nama.md` | Halaman input nama + `Session` |
| `specs/C-komponen.md` | **Semua komponen UI**: skeleton, empty state, room tile, bubble (pop + status kirim), input, dialog, sheet, toast |
| `specs/F2-daftar-room.md` | Daftar room realtime, urut pesan terbaru |
| `specs/F3-buat-room.md` | Buat room baru |
| `specs/F4-chat-room.md` | Halaman chat: pesan realtime + bubble |
| `specs/F5-kirim-pesan.md` | Kirim pesan + update preview room |
| `specs/F6-hapus-pesan.md` | Hapus pesan sendiri |
| `specs/F7-branch-starter.md` | Branch `app` vs `main` (starter + daftar TODO) |

## Struktur folder (final)
```
lib/
  main.dart
  firebase_options.dart        # dari flutterfire configure (user)
  theme.dart                   # palet + ThemeData
  session.dart                 # nama + id user (shared_preferences)
  utils.dart                   # formatTime()
  models/
    room.dart
    message.dart               # termasuk isPending (hasPendingWrites)
  services/
    chat_service.dart          # SATU-SATUNYA tempat akses Firestore
  pages/
    name_page.dart
    rooms_page.dart
    chat_page.dart
  widgets/
    widgets.dart               # barrel export
    pulse.dart
    skeletons.dart
    empty_state.dart
    initial_avatar.dart
    room_tile.dart
    message_bubble.dart
    message_input.dart
    message_popup.dart         # popup pesan baru dari room lain (MessagePopupHost)
    dialogs.dart
```

## Data model (Firestore)
```
rooms/{roomId}
  name: string
  createdBy: string            # nama pembuat
  createdAt: timestamp         # serverTimestamp
  lastMessage: string | null   # preview di daftar room
  lastSenderName: string | null
  lastMessageAt: timestamp     # dipakai untuk urutan daftar room (desc)

rooms/{roomId}/messages/{messageId}
  text: string
  senderId: string             # Session.userId
  senderName: string           # Session.userName
  createdAt: timestamp         # serverTimestamp
```
Tidak perlu composite index (hanya `orderBy` satu field).

## Kontrak kode inti
```dart
// lib/session.dart
class Session {
  static String userId = '';
  static String userName = '';
  static Future<String?> loadSavedName();   // baca prefs, isi userId kalau ada
  static Future<void> save(String name);    // simpan nama, buat userId kalau belum ada
}

// lib/services/chat_service.dart
class ChatService {
  static Stream<List<Room>> watchRooms();
  static Future<void> createRoom(String name);
  static Stream<List<Message>> watchMessages(String roomId);   // includeMetadataChanges: true
  static Future<void> sendMessage(String roomId, String text);
  static Future<void> deleteMessage(String roomId, String messageId);
}
```

## Tugas user (manusia), bukan AI
1. Buat Firebase project, lalu **Firestore Database** (lokasi `asia-southeast2`, mode **test**).
2. Rules Firestore diset `allow read, write: if true;`.
3. `flutterfire configure --platforms=android,web` → menghasilkan `lib/firebase_options.dart`.
4. Tes di 2 device sekaligus (mis. emulator Android + `flutter run -d chrome`).

## Definisi selesai (branch `app`)
- [ ] Input nama → masuk daftar room
- [ ] Loading tampil sebagai skeleton berdenyut; kosong/error tampil sebagai `EmptyState`
- [ ] Buat room → toast, room muncul di daftar di semua device tanpa refresh
- [ ] Buka room yang sama di 2 device → pesan muncul realtime dengan animasi pop
- [ ] Pesan sendiri: ikon jam → centang setelah sampai server
- [ ] Bubble kanan = pesan sendiri (`#424242`), kiri = orang lain (off-white + nama pengirim)
- [ ] Kirim pesan → room naik ke paling atas daftar, preview berganti halus di bawah nama room
- [ ] Long-press pesan sendiri → sheet → hapus → hilang di semua device, toast, preview room ter-update
- [ ] `flutter analyze` tanpa error, jalan di Android dan Chrome
