class LojaModel {
  final String corPrimaria;
  final String nome;
  final String? urlLogo;
  final String? urlImagemLogin;
  final List<String> banners;

  LojaModel({
    required this.corPrimaria,
    required this.nome,
    required this.urlLogo,
    this.urlImagemLogin,
    required this.banners,
  });

  factory LojaModel.fromJson(Map<String, dynamic> json) {
    return LojaModel(
      corPrimaria: json['corPrimaria'] ?? '',
      nome: json['nome'] ?? 'Meu Ecommerce',
      urlLogo: json['urlLogo'],
      urlImagemLogin: json['urlImagemLogin'],
      banners: (json['banners'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corPrimaria': corPrimaria,
      'nome': nome,
      if (urlLogo != null) 'urlLogo': urlLogo,
      if (urlImagemLogin != null) 'urlImagemLogin': urlImagemLogin,
      'banners': banners,
    };
  }
}
