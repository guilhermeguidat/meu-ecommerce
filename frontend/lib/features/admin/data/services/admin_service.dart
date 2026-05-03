import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/utils/log.dart';
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
    } on DioException catch (e) {
      Log.e('[AdminService] getLojaConfig erro ${e.response?.statusCode}', e.response?.data);
      throw Exception('Erro ao buscar configurações da loja: ${e.response?.data ?? e.message}');
    } on Exception catch (e) {
      throw Exception('Erro ao buscar configurações da loja: $e');
    }
  }

  Future<LojaModel> updateLojaConfig({
    required String corPrimaria,
    required String nome,
    List<Uint8List>? bannerBytes,
    List<String>? bannerNames,
    Uint8List? logoBytes,
    String? logoName,
    Uint8List? imagemLoginBytes,
    String? imagemLoginName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'corPrimaria': corPrimaria,
        'nome': nome,
      });

      if (logoBytes != null && logoName != null) {
        formData.files.add(MapEntry(
          'logo',
          MultipartFile.fromBytes(
            logoBytes,
            filename: logoName,
            contentType: _mimeTypeFromName(logoName),
          ),
        ));
      }

      if (imagemLoginBytes != null && imagemLoginName != null) {
        formData.files.add(MapEntry(
          'imagemLogin',
          MultipartFile.fromBytes(
            imagemLoginBytes,
            filename: imagemLoginName,
            contentType: _mimeTypeFromName(imagemLoginName),
          ),
        ));
      }

      if (bannerBytes != null && bannerBytes.isNotEmpty) {
        for (int i = 0; i < bannerBytes.length; i++) {
          final name = (bannerNames != null && i < bannerNames.length) ? bannerNames[i] : 'banner_$i.jpg';
          formData.files.add(MapEntry(
            'bannerFiles',
            MultipartFile.fromBytes(
              bannerBytes[i],
              filename: name,
              contentType: _mimeTypeFromName(name),
            ),
          ));
        }
      }

      final response = await dio.put('/loja', data: formData);
      return LojaModel.fromJson(response.data);
    } on DioException catch (e) {
      Log.e('[AdminService] updateLojaConfig erro ${e.response?.statusCode}', e.response?.data);
      throw Exception('Erro ao atualizar configurações da loja: ${e.response?.data ?? e.message}');
    } on Exception catch (e) {
      throw Exception('Erro ao atualizar configurações da loja: $e');
    }
  }

  MediaType _mimeTypeFromName(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<List<ProdutoModel>> getProdutos() async {
    try {
      final response = await dio.get('/produto/buscaTodos');
      final List<dynamic> data = response.data;
      return data.map((json) => ProdutoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      Log.e('[AdminService] getProdutos erro ${e.response?.statusCode}', e.response?.data);
      throw Exception('Erro ao buscar produtos: ${e.response?.data ?? e.message}');
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
    } on DioException catch (e) {
      Log.e('[AdminService] createProduto erro ${e.response?.statusCode}', e.response?.data);
      throw Exception('Erro ao criar produto: ${e.response?.data ?? e.message}');
    } on Exception catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

  Future<void> deleteProduto(int id) async {
    try {
      await dio.delete('/produto/$id');
    } on DioException catch (e) {
      Log.e('[AdminService] deleteProduto erro ${e.response?.statusCode}', e.response?.data);
      throw Exception('Erro ao excluir produto: ${e.response?.data ?? e.message}');
    } on Exception catch (e) {
      throw Exception('Erro ao excluir produto: $e');
    }
  }
}
