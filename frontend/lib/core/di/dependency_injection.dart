import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/presentation/providers/login_provider.dart';
import '../../features/auth/presentation/providers/register_provider.dart';
import '../../features/admin/data/services/admin_service.dart';
import '../../features/admin/presentation/providers/admin_provider.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Network
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    receiveTimeout: const Duration(seconds: 15),
    connectTimeout: const Duration(seconds: 15),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));

  getIt.registerLazySingleton<Dio>(() => dio);

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(dio: getIt<Dio>()));
  getIt.registerLazySingleton<AdminService>(() => AdminService(dio: getIt<Dio>()));

  // Providers
  getIt.registerFactory<LoginProvider>(() => LoginProvider(authService: getIt<AuthService>()));
  getIt.registerFactory<RegisterProvider>(() => RegisterProvider(authService: getIt<AuthService>()));
  getIt.registerFactory<AdminProvider>(() => AdminProvider(adminService: getIt<AdminService>()));
}
