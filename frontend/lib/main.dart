import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/login_provider.dart';
import 'features/auth/presentation/providers/register_provider.dart';
import 'features/admin/presentation/providers/admin_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: getIt<ThemeProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<LoginProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<RegisterProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<AdminProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Meu E-commerce',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(themeProvider.primaryColor),
            darkTheme: AppTheme.darkTheme(themeProvider.primaryColor),
            themeMode: themeProvider.themeMode,
            home: const LoginPage(),
          );
        },
      ),
    );
  }
}
