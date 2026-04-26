import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio dio;

  AuthService({required this.dio});

  Future<void> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'senha': password,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
        }
      } else {
         throw Exception('Falha ao autenticar.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
         throw Exception(e.response?.data['message'] ?? 'Erro no servidor: ${e.response?.statusCode}');
      }
      throw Exception('Falha de conexão com o servidor.');
    } on Exception catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> register(String email, String password, String nome, String cpf, String? dataNascimento) async {
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'senha': password,
        'nome': nome,
        'cpf': cpf,
      };

      if (dataNascimento != null) {
        data['dataNascimento'] = dataNascimento;
      }

      final response = await dio.post(
        '/auth/register',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData != null && responseData['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', responseData['token']);
        }
      } else {
         throw Exception('Falha ao registrar.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
         throw Exception('Esta conta já está registrada (E-mail já em uso).');
      }
      if (e.response != null && e.response?.data != null) {
         throw Exception(e.response?.data['message'] ?? 'Erro no servidor: ${e.response?.statusCode}');
      }
      throw Exception('Falha de conexão com o servidor.');
    } on Exception catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
