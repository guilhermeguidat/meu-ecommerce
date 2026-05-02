class ProdutoVariacaoModel {
  final int? id;
  final String tamanho;
  final String cor;
  final int quantidade;

  ProdutoVariacaoModel({
    this.id,
    required this.tamanho,
    required this.cor,
    required this.quantidade,
  });

  factory ProdutoVariacaoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoVariacaoModel(
      id: json['id'],
      tamanho: json['tamanho'] ?? '',
      cor: json['cor'] ?? '',
      quantidade: json['quantidade'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tamanho': tamanho,
      'cor': cor,
      'quantidade': quantidade,
    };
  }
}
