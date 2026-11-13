import 'dart:async';

import 'package:flutter/material.dart';

import '../models/room.dart';
import '../session.dart';
import '../theme.dart';
import 'initial_avatar.dart';

/// Membungkus seluruh app dan menampilkan popup kecil di atas layar
/// saat ada pesan baru di room LAIN, ketika user sedang membuka sebuah room chat.
///
/// Popup tidak muncul untuk:
/// - pesan sendiri,
/// - room yang sedang dibuka,
/// - saat user di halaman daftar room (perubahannya sudah terlihat di daftar).
class MessagePopupHost extends StatefulWidget {
  final Stream<List<Room>> rooms;
  final ValueChanged<Room> onTap;
  final Widget child;

  const MessagePopupHost({
    super.key,
    required this.rooms,
    required this.onTap,
    required this.child,
  });

  @override
  State<MessagePopupHost> createState() => _MessagePopupHostState();
}

class _MessagePopupHostState extends State<MessagePopupHost> {
  StreamSubscription<List<Room>>? _subscription;
  Timer? _hideTimer;

  // Waktu pesan terakhir tiap room yang sudah kita lihat, untuk mendeteksi pesan baru.
  final Map<String, DateTime?> _lastSeen = {};
  bool _isFirstData = true;

  Room? _room; // room yang sedang ditampilkan di popup
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.rooms.listen(_onRooms);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onRooms(List<Room> rooms) {
    for (final room in rooms) {
      final before = _lastSeen[room.id];
      final now = room.lastMessageAt;
      _lastSeen[room.id] = now;

      // Data pertama hanya dicatat, bukan dianggap pesan baru.
      if (_isFirstData || now == null) continue;
      final isNewMessage = before == null || now.isAfter(before);

      if (isNewMessage &&
          room.lastMessage != null &&
          room.lastSenderName != Session.userName &&
          Session.openRoomId != null &&
          Session.openRoomId != room.id) {
        _show(room);
      }
    }
    _isFirstData = false;
  }

  void _show(Room room) {
    _hideTimer?.cancel();
    setState(() {
      _room = room;
      _visible = true;
    });
    _hideTimer = Timer(const Duration(seconds: 3), _hide);
  }

  void _hide() {
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: IgnorePointer(
              ignoring: !_visible,
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, -1.5),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: _room == null
                      ? const SizedBox.shrink()
                      : _PopupCard(
                          room: _room!,
                          onTap: () {
                            _hide();
                            widget.onTap(_room!);
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tampilan popup: avatar pengirim, "Nama · Room", dan isi pesan.
class _PopupCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const _PopupCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sender = room.lastSenderName ?? '';

    // Material dibutuhkan karena popup berada di luar halaman (di atas Navigator).
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kLine),
              boxShadow: [
                BoxShadow(
                  color: kInk.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                InitialAvatar(name: sender, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$sender · ${room.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kSubtle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        room.lastMessage ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: kText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
