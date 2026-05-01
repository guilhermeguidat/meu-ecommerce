import 'package:dio/dio.dart';
import '../models/loja_model.dart';
import '../models/produto_model.dart';

class AdminService {
  final Dio dio;

  AdminService({required this.dio});

  Future<LojaModel> getLojaConfig() async {
    try {
      final response = await dio.get('/loja');
      return LojaModel.fromJson(response.data);
    } catch (e) {
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
    } catch (e) {
      throw Exception('Erro ao atualizar configurações da loja: $e');
    }
  }

  Future<List<ProdutoModel>> getProdutos() async {
    try {
      final response = await dio.get('/produto/buscaTodos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProdutoModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  Future<ProdutoModel> createProduto(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await dio.post('/produto', data: formData);
      return ProdutoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

  Future<void> deleteProduto(int id) async {
    try {
      await dio.delete('/produto/$id');
    } catch (e) {
      throw Exception('Erro ao excluir produto: $e');
    }
  }
}
