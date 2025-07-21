import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService) {
    _loadUserFromStorage();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        _apiService.setToken(token);
        final response = await _apiService.getProfile();
        
        if (response.success && response.data != null) {
          _currentUser = response.data;
          notifyListeners();
        } else {
          await _clearAuth();
        }
      }
    } catch (e) {
      await _clearAuth();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final token = response.data!['access_token'];
        final userData = response.data!['user'];
        
        _apiService.setToken(token);
        _currentUser = User.fromJson(userData);
        
        // حفظ التوكن في التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'خطأ في تسجيل الدخول');
        return false;
      }
    } catch (e) {
      _setError('خطأ في الاتصال');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success && response.data != null) {
        final token = response.data!['access_token'];
        final userData = response.data!['user'];
        
        _apiService.setToken(token);
        _currentUser = User.fromJson(userData);
        
        // حفظ التوكن في التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'خطأ في التسجيل');
        return false;
      }
    } catch (e) {
      _setError('خطأ في الاتصال');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.logout();
    } catch (e) {
      // تجاهل أخطاء تسجيل الخروج
    } finally {
      await _clearAuth();
      _setLoading(false);
    }
  }

  Future<void> _clearAuth() async {
    _currentUser = null;
    _apiService.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      // TODO: إضافة API endpoint لتحديث الملف الشخصي
      // في الوقت الحالي، سنحديث البيانات محلياً
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        avatar: avatar ?? _currentUser!.avatar,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في تحديث الملف الشخصي');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}