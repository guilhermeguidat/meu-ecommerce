import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import '../../../../core/utils/log.dart';
import '../../data/models/loja_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService adminService;
  final ThemeProvider themeProvider;

  AdminProvider({
    required this.adminService,
    required this.themeProvider,
  });

  void _updateGlobalTheme() {
    if (_loja != null) {
      themeProvider.updatePrimaryColor(_parseColor(_loja!.corPrimaria));
    }
  }

  Color _parseColor(String hex) {
    String formattedHex = hex.replaceFirst('#', '');
    if (formattedHex.length == 3) {
      formattedHex = formattedHex.split('').map((e) => '$e$e').join();
    }
    if (formattedHex.length == 6) {
      formattedHex = 'FF$formattedHex';
    }
    try {
      return Color(int.parse(formattedHex, radix: 16));
    } catch (_) {
      return themeProvider.primaryColor;
    }
  }

  bool _isLoading = false;
  String? _errorMessage;
  LojaModel? _loja;
  List<ProdutoModel> _produtos = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LojaModel? get loja => _loja;
  List<ProdutoModel> get produtos => _produtos;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Carrega config da loja (pode ser pública)
      try {
        _loja = await adminService.getLojaConfig();
        _updateGlobalTheme();
      } catch (e) {
        Log.w('[AdminProvider] Erro ao carregar config da loja: $e');
      }

      // Carrega produtos (geralmente requer token)
      try {
        _produtos = await adminService.getProdutos();
      } catch (e) {
        Log.w('[AdminProvider] Erro ao carregar produtos (pode ser falta de login): $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreConfig({
    required String corPrimaria,
    required String nome,
    List<Uint8List>? bannerBytes,
    List<String>? bannerNames,
    Uint8List? logoBytes,
    String? logoName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loja = await adminService.updateLojaConfig(
        corPrimaria: corPrimaria,
        nome: nome,
        bannerBytes: bannerBytes,
        bannerNames: bannerNames,
        logoBytes: logoBytes,
        logoName: logoName,
      );
      _updateGlobalTheme();
    } on Exception catch (e) {
      Log.e('[AdminProvider] Erro ao atualizar loja', e);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduto(int id) async {
    try {
      await adminService.deleteProduto(id);
      _produtos.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
