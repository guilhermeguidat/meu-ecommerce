import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../data/models/loja_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService adminService;

  AdminProvider({required this.adminService});

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
      final results = await Future.wait([
        adminService.getLojaConfig(),
        adminService.getProdutos(),
      ]);

      _loja = results[0] as LojaModel;
      _produtos = results[1] as List<ProdutoModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreConfig({
    required String corPrimaria,
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
        bannerBytes: bannerBytes,
        bannerNames: bannerNames,
        logoBytes: logoBytes,
        logoName: logoName,
      );
    } on Exception catch (e) {
      print('[AdminProvider] Erro ao atualizar loja: $e');
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
