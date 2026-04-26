import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/presentation/providers/login_provider.dart';
import '../../features/auth/presentation/providers/register_provider.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Network
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: 'http://localhost:8080',
        receiveTimeout: const Duration(seconds: 15),
        connectTimeout: const Duration(seconds: 15),
      )));

  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(dio: getIt<Dio>()));

  // Providers
  getIt.registerFactory<LoginProvider>(() => LoginProvider(authService: getIt<AuthService>()));
  getIt.registerFactory<RegisterProvider>(() => RegisterProvider(authService: getIt<AuthService>()));
}
