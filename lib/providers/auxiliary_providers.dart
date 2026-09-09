import 'package:flutter/material.dart';
import '../models/status_model.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/media_status_call_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/chat_repository.dart';

class StatusProvider extends ChangeNotifier {
  final StatusRepository _statusRepository;
  List<StatusModel> _statuses = [];
  bool _isLoading = false;

  StatusProvider(this._statusRepository) {
    loadStatuses();
  }

  List<StatusModel> get statuses => _statuses;
  bool get isLoading => _isLoading;

  Future<void> loadStatuses() async {
    _isLoading = true;
    notifyListeners();
    _statuses = await _statusRepository.getStatuses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStatus(StatusItem item) async {
    await _statusRepository.addStatus(item);
    await loadStatuses();
  }

  Future<void> markStatusSeen(String statusId) async {
    await _statusRepository.markStatusSeen(statusId);
    await loadStatuses();
  }
}

class CallProvider extends ChangeNotifier {
  final CallRepository _callRepository;
  List<CallModel> _calls = [];
  bool _isLoading = false;

  CallProvider(this._callRepository) {
    loadCalls();
  }

  List<CallModel> get calls => _calls;
  bool get isLoading => _isLoading;

  Future<void> loadCalls() async {
    _isLoading = true;
    notifyListeners();
    _calls = await _callRepository.getCallHistory();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> makeCall({required String receiverId, required CallType type}) async {
    await _callRepository.makeCall(receiverId: receiverId, type: type);
    await loadCalls();
  }

  Future<void> clearHistory() async {
    await _callRepository.clearCallHistory();
    await loadCalls();
  }
}

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  List<UserModel> _contacts = [];
  bool _isLoading = false;

  UserProvider(this._userRepository) {
    loadContacts();
  }

  List<UserModel> get contacts => _contacts;
  bool get isLoading => _isLoading;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    _contacts = await _userRepository.getContacts();
    _isLoading = false;
    notifyListeners();
  }
}

class SearchProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final ChatRepository _chatRepository;

  List<UserModel> _searchResultsUsers = [];
  List<ChatMessageModel> _searchResultsMessages = [];
  bool _isSearching = false;

  SearchProvider(this._userRepository, this._chatRepository);

  List<UserModel> get searchResultsUsers => _searchResultsUsers;
  List<ChatMessageModel> get searchResultsMessages => _searchResultsMessages;
  bool get isSearching => _isSearching;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResultsUsers = [];
      _searchResultsMessages = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _searchResultsUsers = await _userRepository.searchUsers(query);
    _searchResultsMessages = await _chatRepository.searchMessages(query);

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResultsUsers = [];
    _searchResultsMessages = [];
    _isSearching = false;
    notifyListeners();
  }
}
