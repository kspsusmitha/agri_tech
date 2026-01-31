import '../models/user_model.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UserModel? _currentUser;
  UserModel? get user => _currentUser;

  /// Set current user
  void setUser(UserModel user) {
    _currentUser = user;
  }

  /// Get current user
  UserModel? getCurrentUser() {
    return _currentUser;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUser?.id;
  }

  /// Clear current user (logout)
  void clearUser() {
    _currentUser = null;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _currentUser != null;
  }
}
