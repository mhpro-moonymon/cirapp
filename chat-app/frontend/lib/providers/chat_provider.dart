import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Conversation> _conversations = [];
  Map<int, List<Message>> _conversationMessages = {};
  List<User> _searchResults = [];
  
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSearching = false;
  String? _error;

  ChatProvider(this._apiService);

  // Getters
  List<Conversation> get conversations => _conversations;
  Map<int, List<Message>> get conversationMessages => _conversationMessages;
  List<User> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSearching => _isSearching;
  String? get error => _error;

  List<Message> getMessagesForConversation(int conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMessages(bool loading) {
    _isLoadingMessages = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // تحميل المحادثات
  Future<void> loadConversations() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getConversations();
      
      if (response.success && response.data != null) {
        _conversations = response.data!;
        notifyListeners();
      } else {
        _setError(response.message ?? 'خطأ في تحميل المحادثات');
      }
    } catch (e) {
      _setError('خطأ في الاتصال');
    } finally {
      _setLoading(false);
    }
  }

  // إنشاء محادثة جديدة
  Future<Conversation?> createConversation({
    required int participantId,
    String? name,
    String type = 'private',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.createConversation(
        participantId: participantId,
        name: name,
        type: type,
      );

      if (response.success && response.data != null) {
        final conversation = response.data!;
        
        // إضافة المحادثة إلى القائمة إذا لم تكن موجودة
        final existingIndex = _conversations.indexWhere((c) => c.id == conversation.id);
        if (existingIndex >= 0) {
          _conversations[existingIndex] = conversation;
        } else {
          _conversations.insert(0, conversation);
        }
        
        notifyListeners();
        return conversation;
      } else {
        _setError(response.message ?? 'خطأ في إنشاء المحادثة');
        return null;
      }
    } catch (e) {
      _setError('خطأ في الاتصال');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // تحميل رسائل المحادثة
  Future<void> loadMessages(int conversationId, {int page = 1}) async {
    _setLoadingMessages(true);
    if (page == 1) {
      _setError(null);
    }

    try {
      final response = await _apiService.getMessages(
        conversationId: conversationId,
        page: page,
      );

      if (response.success && response.data != null) {
        final messages = response.data!;
        
        if (page == 1) {
          // الصفحة الأولى - استبدال الرسائل
          _conversationMessages[conversationId] = messages.reversed.toList();
        } else {
          // الصفحات التالية - إضافة الرسائل
          final existingMessages = _conversationMessages[conversationId] ?? [];
          _conversationMessages[conversationId] = [
            ...messages.reversed.toList(),
            ...existingMessages,
          ];
        }
        
        notifyListeners();
      } else {
        if (page == 1) {
          _setError(response.message ?? 'خطأ في تحميل الرسائل');
        }
      }
    } catch (e) {
      if (page == 1) {
        _setError('خطأ في الاتصال');
      }
    } finally {
      _setLoadingMessages(false);
    }
  }

  // إرسال رسالة
  Future<Message?> sendMessage({
    required int conversationId,
    required String content,
    String type = 'text',
    int? replyTo,
  }) async {
    try {
      final response = await _apiService.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        replyTo: replyTo,
      );

      if (response.success && response.data != null) {
        final message = response.data!;
        
        // إضافة الرسالة إلى القائمة المحلية
        final messages = _conversationMessages[conversationId] ?? [];
        _conversationMessages[conversationId] = [...messages, message];
        
        // تحديث آخر رسالة في المحادثة
        final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
        if (conversationIndex >= 0) {
          _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
            lastMessage: message,
            updatedAt: message.createdAt,
          );
          
          // نقل المحادثة إلى أعلى القائمة
          final conversation = _conversations.removeAt(conversationIndex);
          _conversations.insert(0, conversation);
        }
        
        notifyListeners();
        return message;
      } else {
        _setError(response.message ?? 'خطأ في إرسال الرسالة');
        return null;
      }
    } catch (e) {
      _setError('خطأ في الاتصال');
      return null;
    }
  }

  // البحث عن المستخدمين
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);
    _setError(null);

    try {
      final response = await _apiService.searchUsers(query);
      
      if (response.success && response.data != null) {
        _searchResults = response.data!;
        notifyListeners();
      } else {
        _setError(response.message ?? 'خطأ في البحث');
        _searchResults = [];
        notifyListeners();
      }
    } catch (e) {
      _setError('خطأ في الاتصال');
      _searchResults = [];
      notifyListeners();
    } finally {
      _setSearching(false);
    }
  }

  // تحديد الرسالة كمقروءة
  Future<void> markAsRead(int messageId) async {
    try {
      await _apiService.markAsRead(messageId);
    } catch (e) {
      // تجاهل أخطاء تحديد القراءة
    }
  }

  // إضافة رسالة جديدة (للاستخدام مع WebSocket)
  void addMessage(Message message) {
    final messages = _conversationMessages[message.conversationId] ?? [];
    _conversationMessages[message.conversationId] = [...messages, message];
    
    // تحديث المحادثة
    final conversationIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (conversationIndex >= 0) {
      _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
        lastMessage: message,
        updatedAt: message.createdAt,
      );
      
      // نقل المحادثة إلى أعلى القائمة
      final conversation = _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversation);
    }
    
    notifyListeners();
  }

  // تحديث حالة المستخدم (للاستخدام مع WebSocket)
  void updateUserStatus(int userId, bool isOnline) {
    // تحديث حالة المستخدم في قائمة البحث
    for (int i = 0; i < _searchResults.length; i++) {
      if (_searchResults[i].id == userId) {
        _searchResults[i] = _searchResults[i].copyWith(isOnline: isOnline);
        break;
      }
    }
    
    // تحديث حالة المستخدم في المحادثات
    for (int i = 0; i < _conversations.length; i++) {
      final participants = _conversations[i].participants;
      if (participants != null) {
        for (int j = 0; j < participants.length; j++) {
          if (participants[j].id == userId) {
            participants[j] = participants[j].copyWith(isOnline: isOnline);
            break;
          }
        }
      }
    }
    
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}