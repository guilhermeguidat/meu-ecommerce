import 'package:flutter/material.dart';
import 'package:frontend/features/admin/data/models/produto_model.dart';
import 'package:frontend/features/admin/data/models/produto_variacao_model.dart';

class CartItemModel {
  final ProdutoModel produto;
  final ProdutoVariacaoModel? variacao;
  int quantidade;

  CartItemModel({
    required this.produto,
    this.variacao,
    required this.quantidade,
  });

  double get precoUnitario => produto.valorUnitario;
  double get precoTotal => precoUnitario * quantidade;

  int get estoqueDisponivel => variacao?.quantidade ?? produto.quantidade;

  String get descricaoVariacao => variacao?.tamanho ?? '';

  Color? get corVariacao {
    if (variacao == null) return null;
    return _parseHexColor(variacao!.cor);
  }

  static Color? _parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    var hex = hexColor.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) {
      final intVal = int.tryParse(hex, radix: 16);
      if (intVal != null) return Color(intVal);
    }
    return null;
  }

  String get itemKey {
    final produtoId = produto.id?.toString() ?? produto.descricao;
    final variacaoId = variacao?.id?.toString() ?? 'sem-variacao';
    return '$produtoId-$variacaoId';
  }
}
