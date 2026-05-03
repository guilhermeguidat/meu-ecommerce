import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = AppColors.primary;

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => ThemeMode.system;

  void updatePrimaryColor(Color color) {
    if (_primaryColor != color) {
      _primaryColor = color;
      notifyListeners();
    }
  }
}
