import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
      errors: json['errors']?.cast<String, dynamic>(),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // المصادقة
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: data['success'] ?? false,
        data: data,
        message: data['message'],
        errors: data['errors']?.cast<String, dynamic>(),
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: data['success'] ?? false,
        data: data,
        message: data['message'],
        errors: data['errors']?.cast<String, dynamic>(),
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: data['success'] ?? false,
        data: data,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return ApiResponse<User>(
        success: data['success'] ?? false,
        data: data['user'] != null ? User.fromJson(data['user']) : null,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  // المحادثات
  Future<ApiResponse<List<Conversation>>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['conversations'] != null) {
        final conversations = (data['conversations'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
        return ApiResponse<List<Conversation>>(
          success: true,
          data: conversations,
          message: data['message'],
        );
      }
      
      return ApiResponse<List<Conversation>>(
        success: false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<List<Conversation>>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  Future<ApiResponse<Conversation>> createConversation({
    required int participantId,
    String? name,
    String type = 'private',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: _headers,
        body: jsonEncode({
          'participant_id': participantId,
          'type': type,
          if (name != null) 'name': name,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Conversation>(
        success: data['success'] ?? false,
        data: data['conversation'] != null 
            ? Conversation.fromJson(data['conversation']) 
            : null,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<Conversation>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  // الرسائل
  Future<ApiResponse<List<Message>>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations/$conversationId/messages?page=$page&limit=$limit'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['messages'] != null) {
        final messagesData = data['messages']['data'] ?? data['messages'];
        final messages = (messagesData as List)
            .map((json) => Message.fromJson(json))
            .toList();
        return ApiResponse<List<Message>>(
          success: true,
          data: messages,
          message: data['message'],
        );
      }
      
      return ApiResponse<List<Message>>(
        success: false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<List<Message>>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  Future<ApiResponse<Message>> sendMessage({
    required int conversationId,
    required String content,
    String type = 'text',
    int? replyTo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages'),
        headers: _headers,
        body: jsonEncode({
          'conversation_id': conversationId,
          'content': content,
          'type': type,
          if (replyTo != null) 'reply_to': replyTo,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<Message>(
        success: data['success'] ?? false,
        data: data['message'] != null 
            ? Message.fromJson(data['message']) 
            : null,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<Message>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  Future<ApiResponse<void>> markAsRead(int messageId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages/mark-read'),
        headers: _headers,
        body: jsonEncode({
          'message_id': messageId,
        }),
      );

      final data = jsonDecode(response.body);
      return ApiResponse<void>(
        success: data['success'] ?? false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }

  // البحث عن المستخدمين
  Future<ApiResponse<List<User>>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/users/search?query=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['users'] != null) {
        final users = (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
        return ApiResponse<List<User>>(
          success: true,
          data: users,
          message: data['message'],
        );
      }
      
      return ApiResponse<List<User>>(
        success: false,
        message: data['message'],
      );
    } catch (e) {
      return ApiResponse<List<User>>(
        success: false,
        message: 'خطأ في الاتصال: $e',
      );
    }
  }
}