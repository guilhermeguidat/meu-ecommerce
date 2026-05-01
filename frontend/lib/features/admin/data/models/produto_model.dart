class ProdutoModel {
  final int? id;
  final String descricao;
  final String urlImagem;
  final double valorUnitario;
  final int quantidade;
  final String? categoria;

  ProdutoModel({
    this.id,
    required this.descricao,
    required this.urlImagem,
    required this.valorUnitario,
    required this.quantidade,
    this.categoria,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      urlImagem: json['urlImagem'] ?? '',
      valorUnitario: (json['valorUnitario'] ?? 0).toDouble(),
      quantidade: json['quantidade'] ?? 0,
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'descricao': descricao,
      'urlImagem': urlImagem,
      'valorUnitario': valorUnitario,
      'quantidade': quantidade,
      if (categoria != null) 'categoria': categoria,
    };
  }
}
