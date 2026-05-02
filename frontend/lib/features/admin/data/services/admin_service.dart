import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/loja_model.dart';
import '../models/produto_model.dart';
import '../models/produto_variacao_model.dart';

class AdminService {
  final Dio dio;

  AdminService({required this.dio});

  Future<LojaModel> getLojaConfig() async {
    try {
      final response = await dio.get('/loja');
      return LojaModel.fromJson(response.data);
    } on Exception catch (e) {
      throw Exception('Erro ao buscar configurações da loja: $e');
    }
  }

  Future<LojaModel> updateLojaConfig(String corPrimaria, List<String> banners, {dynamic logoFile}) async {
    try {
      final formData = FormData.fromMap({
        'corPrimaria': corPrimaria,
        'banners': banners,
      });

      if (logoFile != null) {
        // Logo handling (assuming it's a MultipartFile from image_picker)
        // formData.files.add(MapEntry('logo', logoFile));
      }

      final response = await dio.put('/loja', data: formData);
      return LojaModel.fromJson(response.data);
    } on Exception catch (e) {
      throw Exception('Erro ao atualizar configurações da loja: $e');
    }
  }

  Future<List<ProdutoModel>> getProdutos() async {
    try {
      final response = await dio.get('/produto/buscaTodos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProdutoModel.fromJson(json)).toList();
    } on Exception catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  Future<ProdutoModel> createProduto({
    required String descricao,
    required double valorUnitario,
    required int quantidade,
    String? categoria,
    Uint8List? imagemBytes,
    String? imagemNome,
    List<ProdutoVariacaoModel> variacoes = const [],
  }) async {
    try {
      final fields = <String, dynamic>{
        'descricao': descricao,
        'valorUnitario': valorUnitario,
        'quantidade': quantidade,
      };

      if (categoria != null && categoria.isNotEmpty) {
        fields['categoria'] = categoria;
      }

      // Add variations as indexed form fields
      for (var i = 0; i < variacoes.length; i++) {
        final v = variacoes[i];
        fields['variacoes[$i].tamanho'] = v.tamanho;
        fields['variacoes[$i].cor'] = v.cor;
        fields['variacoes[$i].quantidade'] = v.quantidade;
      }

      final formData = FormData.fromMap(fields);

      // Cria MultipartFile fresh aqui para nunca reutilizar um stream já finalizado
      if (imagemBytes != null && imagemNome != null) {
        formData.files.add(
          MapEntry('imagem', MultipartFile.fromBytes(imagemBytes, filename: imagemNome)),
        );
      }

      final response = await dio.post('/produto', data: formData);
      return ProdutoModel.fromJson(response.data);
    } on Exception catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

  Future<void> deleteProduto(int id) async {
    try {
      await dio.delete('/produto/$id');
    } on Exception catch (e) {
      throw Exception('Erro ao excluir produto: $e');
    }
  }
}
