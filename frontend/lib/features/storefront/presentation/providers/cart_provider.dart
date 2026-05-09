import 'package:flutter/material.dart';
import 'package:frontend/features/admin/data/models/produto_model.dart';
import 'package:frontend/features/admin/data/models/produto_variacao_model.dart';
import 'package:frontend/features/storefront/data/models/cart_item_model.dart';
import 'package:frontend/core/utils/log.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantidade);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.precoTotal);

  bool get isEmpty => _items.isEmpty;

  void addItem(ProdutoModel produto, ProdutoVariacaoModel? variacao, int quantidade) {
    try {
      final key = _makeKey(produto, variacao);
      final existingIndex = _items.indexWhere((item) => item.itemKey == key);

      if (existingIndex >= 0) {
        final existing = _items[existingIndex];
        final maxStock = variacao?.quantidade ?? produto.quantidade;
        final novaQtd = existing.quantidade + quantidade;
        existing.quantidade = novaQtd > maxStock ? maxStock : novaQtd;
      } else {
        _items.add(CartItemModel(
          produto: produto,
          variacao: variacao,
          quantidade: quantidade,
        ));
      }
      notifyListeners();
    } on Exception catch (e) {
      Log.e('[CartProvider] Erro ao adicionar item: $e');
    }
  }

  void removeItem(String itemKey) {
    _items.removeWhere((item) => item.itemKey == itemKey);
    notifyListeners();
  }

  void updateQuantity(String itemKey, int novaQuantidade) {
    final index = _items.indexWhere((item) => item.itemKey == itemKey);
    if (index >= 0) {
      if (novaQuantidade <= 0) {
        _items.removeAt(index);
      } else {
        final item = _items[index];
        final maxStock = item.estoqueDisponivel;
        _items[index].quantidade = novaQuantidade > maxStock ? maxStock : novaQuantidade;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  String _makeKey(ProdutoModel produto, ProdutoVariacaoModel? variacao) {
    final produtoId = produto.id?.toString() ?? produto.descricao;
    final variacaoId = variacao?.id?.toString() ?? 'sem-variacao';
    return '$produtoId-$variacaoId';
  }
}
