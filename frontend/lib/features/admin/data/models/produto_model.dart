import 'produto_variacao_model.dart';

class ProdutoModel {
  final int? id;
  final String descricao;
  final String? urlImagem;
  final double valorUnitario;
  final int quantidade;
  final String? categoria;
  final List<ProdutoVariacaoModel> variacoes;

  ProdutoModel({
    this.id,
    required this.descricao,
    this.urlImagem,
    required this.valorUnitario,
    required this.quantidade,
    this.categoria,
    this.variacoes = const [],
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      urlImagem: json['urlImagem'],
      valorUnitario: (json['valorUnitario'] ?? 0).toDouble(),
      quantidade: json['quantidade'] ?? 0,
      categoria: json['categoria'],
      variacoes: (json['variacoes'] as List<dynamic>? ?? [])
          .map((v) => ProdutoVariacaoModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'descricao': descricao,
      if (urlImagem != null) 'urlImagem': urlImagem,
      'valorUnitario': valorUnitario,
      'quantidade': quantidade,
      if (categoria != null) 'categoria': categoria,
      'variacoes': variacoes.map((v) => v.toJson()).toList(),
    };
  }
}
