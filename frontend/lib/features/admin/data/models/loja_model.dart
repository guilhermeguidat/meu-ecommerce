class LojaModel {
  final String corPrimaria;
  final String urlLogo;
  final List<String> banners;

  LojaModel({
    required this.corPrimaria,
    required this.urlLogo,
    required this.banners,
  });

  factory LojaModel.fromJson(Map<String, dynamic> json) {
    return LojaModel(
      corPrimaria: json['corPrimaria'] ?? '',
      urlLogo: json['urlLogo'] ?? '',
      banners: json['banners'] != null ? List<String>.from(json['banners']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'corPrimaria': corPrimaria,
      'urlLogo': urlLogo,
      'banners': banners,
    };
  }
}
