import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/admin/data/models/loja_model.dart';
import 'package:frontend/features/admin/data/models/produto_model.dart';
import 'package:frontend/features/admin/data/services/admin_service.dart';
import '../../../../core/utils/log.dart';

class StorefrontProvider extends ChangeNotifier {
  final AdminService adminService; // Usando o AdminService temporariamente para pegar os dados
  final ThemeProvider themeProvider;

  StorefrontProvider({
    required this.adminService,
    required this.themeProvider,
  });

  bool _isLoading = false;
  String? _errorMessage;
  LojaModel? _loja;
  List<ProdutoModel> _produtos = [];
  String _selectedCategory = 'Todos';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LojaModel? get loja => _loja;
  List<ProdutoModel> get produtos => _produtos;
  String get selectedCategory => _selectedCategory;

  List<ProdutoModel> get filteredProdutos {
    if (_selectedCategory == 'Todos') {
      return _produtos;
    }
    // Lógica simples: se fosse "Novos" ou "Mais Vendidos", precisaria de campos na API.
    // Como mock, vamos filtrar pelo campo categoria do produto se bater, ou só retornar tudo se não.
    return _produtos.where((p) => p.categoria == _selectedCategory).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      try {
        _loja = await adminService.getLojaConfig();
        _updateGlobalTheme();
      } catch (e) {
        Log.w('[StorefrontProvider] Erro ao carregar config da loja: $e');
      }

      try {
        // Na vida real seria um endpoint público: getProdutosPublicos
        _produtos = await adminService.getProdutos();
      } catch (e) {
        Log.w('[StorefrontProvider] Erro ao carregar produtos: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
}
