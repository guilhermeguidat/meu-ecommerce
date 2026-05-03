import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class LoginProvider extends ChangeNotifier {
  final AuthService authService;

  LoginProvider({required this.authService}) {
    _loadUserData();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _role;
  String? get role => _role;
  bool get isAdmin => _role == 'ADMIN' || _role == 'ROLE_ADMIN';

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await authService.login(email, password);
      _role = await authService.getUserRole();
      _userName = await authService.getUserName();
      _userEmail = await authService.getUserEmail();
      _isSuccess = true;
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    _role = await authService.getUserRole();
    _userName = await authService.getUserName();
    _userEmail = await authService.getUserEmail();
    notifyListeners();
  }
}
