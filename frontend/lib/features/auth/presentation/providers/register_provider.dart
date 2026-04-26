import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class RegisterProvider extends ChangeNotifier {
  final AuthService authService;

  RegisterProvider({required this.authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  Future<bool> register(String email, String password, String nome, String cpf, String? dataNascimento) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await authService.register(email, password, nome, cpf, dataNascimento);
      _isSuccess = true;
      return true;
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
