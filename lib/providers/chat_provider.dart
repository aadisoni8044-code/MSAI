import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/contact.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService;
  final StorageService _storageService;

  late StreamSubscription _incomingSub;

  Map<String, List<ChatMessage>> _messagesByPeer = {};
  List<Contact> _contacts = [];
  String? _activePeerId;
  ChatMessage? _replyingToMessage;

  Map<String, List<ChatMessage>> get messagesByPeer => _messagesByPeer;
  List<Contact> get contacts => _contacts;
  String? get activePeerId => _activePeerId;
  ChatMessage? get replyingToMessage => _replyingToMessage;

  ChatProvider({
    required BluetoothService bluetoothService,
    required StorageService storageService,
  })  : _bluetoothService = bluetoothService,
        _storageService = storageService {
    _init();
  }

  void _init() async {
    _contacts = await _storageService.loadContacts();

    if (_contacts.isEmpty) {
      _contacts = [
        Contact(
          id: 'zip_dev_alex',
          name: 'Alex (ZIP Mobile)',
          isNearby: true,
          isConnected: false,
          lastMessage: 'Hey! Ready for ZIPGRAM chat.',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Contact(
          id: 'zip_dev_sara',
          name: 'Sara (ZIP Pad)',
          isNearby: true,
          isConnected: false,
          lastMessage: 'Sent image via Bluetooth.',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
      await _storageService.saveContacts(_contacts);
    }

    // Pre-populate chat histories for default contacts
    for (var contact in _contacts) {
      final storedMsgs = await _storageService.loadMessagesForChat(contact.id);
      if (storedMsgs.isNotEmpty) {
        _messagesByPeer[contact.id] = storedMsgs;
      } else {
        _messagesByPeer[contact.id] = [
          ChatMessage(
            id: 'init_${contact.id}',
            senderId: contact.id,
            recipientId: 'user_local_me',
            text: 'Hello! Connected via ZIPGRAM Bluetooth.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
            status: MessageStatus.delivered,
          ),
        ];
      }
    }

    // Listen for incoming Bluetooth messages
    _incomingSub = _bluetoothService.incomingMessageStream.listen((msg) {
      _receiveMessage(msg);
    });

    notifyListeners();
  }

  void setActivePeer(String? peerId) {
    _activePeerId = peerId;
    _replyingToMessage = null;

    if (peerId != null) {
      // Clear unread count for peer
      final index = _contacts.indexWhere((c) => c.id == peerId);
      if (index != -1 && _contacts[index].unreadCount > 0) {
        _contacts[index] = _contacts[index].copyWith(unreadCount: 0);
        _storageService.saveContacts(_contacts);
      }
    }

    notifyListeners();
  }

  void setReplyTo(ChatMessage? message) {
    _replyingToMessage = message;
    notifyListeners();
  }

  List<ChatMessage> getMessagesForPeer(String peerId) {
    return _messagesByPeer[peerId] ?? [];
  }

  Future<void> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user_local_me',
      recipientId: recipientId,
      text: text.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      replyToId: _replyingToMessage?.id,
      replyToText: _replyingToMessage?.text,
    );

    _replyingToMessage = null;

    if (!_messagesByPeer.containsKey(recipientId)) {
      _messagesByPeer[recipientId] = [];
    }

    _messagesByPeer[recipientId]!.add(newMsg);
    _updateLastContactMessage(recipientId, newMsg.text, newMsg.timestamp);
    notifyListeners();

    // Send message via Bluetooth service
    final sentSuccess = await _bluetoothService.sendMessageOverBluetooth(newMsg);

    final updatedStatus = sentSuccess ? MessageStatus.delivered : MessageStatus.failed;
    final index = _messagesByPeer[recipientId]!.indexWhere((m) => m.id == newMsg.id);
    if (index != -1) {
      _messagesByPeer[recipientId]![index] =
          _messagesByPeer[recipientId]![index].copyWith(status: updatedStatus);
    }

    await _storageService.saveMessagesForChat(
        recipientId, _messagesByPeer[recipientId]!);
    notifyListeners();
  }

  void _receiveMessage(ChatMessage message) async {
    final peerId = message.senderId;
    if (!_messagesByPeer.containsKey(peerId)) {
      _messagesByPeer[peerId] = [];
    }

    _messagesByPeer[peerId]!.add(message);

    // Ensure contact exists or create contact card
    int contactIndex = _contacts.indexWhere((c) => c.id == peerId);
    if (contactIndex == -1) {
      _contacts.add(
        Contact(
          id: peerId,
          name: 'ZIP Device ($peerId)',
          isNearby: true,
          isConnected: true,
          lastMessage: message.text,
          lastMessageTime: message.timestamp,
          unreadCount: _activePeerId == peerId ? 0 : 1,
        ),
      );
    } else {
      final existing = _contacts[contactIndex];
      _contacts[contactIndex] = existing.copyWith(
        lastMessage: message.text,
        lastMessageTime: message.timestamp,
        unreadCount: _activePeerId == peerId
            ? 0
            : existing.unreadCount + 1,
      );
    }

    await _storageService.saveMessagesForChat(peerId, _messagesByPeer[peerId]!);
    await _storageService.saveContacts(_contacts);

    notifyListeners();
  }

  Future<void> deleteMessage(String peerId, String messageId) async {
    if (_messagesByPeer.containsKey(peerId)) {
      _messagesByPeer[peerId]!.removeWhere((m) => m.id == messageId);
      await _storageService.saveMessagesForChat(
          peerId, _messagesByPeer[peerId]!);
      notifyListeners();
    }
  }

  Future<void> addReaction(
      String peerId, String messageId, String emoji) async {
    if (_messagesByPeer.containsKey(peerId)) {
      final index =
          _messagesByPeer[peerId]!.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final currentReaction = _messagesByPeer[peerId]![index].reaction;
        _messagesByPeer[peerId]![index] = _messagesByPeer[peerId]![index]
            .copyWith(reaction: currentReaction == emoji ? null : emoji);

        await _storageService.saveMessagesForChat(
            peerId, _messagesByPeer[peerId]!);
        notifyListeners();
      }
    }
  }

  Future<void> clearChatHistory(String peerId) async {
    _messagesByPeer[peerId] = [];
    await _storageService.saveMessagesForChat(peerId, []);
    _updateLastContactMessage(peerId, 'Chat history cleared', DateTime.now());
    notifyListeners();
  }

  void _updateLastContactMessage(
      String peerId, String lastText, DateTime time) async {
    final index = _contacts.indexWhere((c) => c.id == peerId);
    if (index != -1) {
      _contacts[index] = _contacts[index].copyWith(
        lastMessage: lastText,
        lastMessageTime: time,
      );
      await _storageService.saveContacts(_contacts);
    }
  }

  @override
  void dispose() {
    _incomingSub.cancel();
    super.dispose();
  }
}
