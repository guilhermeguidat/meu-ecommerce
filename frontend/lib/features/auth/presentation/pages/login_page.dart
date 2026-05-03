import 'package:flutter/material.dart';
import 'package:frontend/features/admin/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'register_page.dart';
import '../../../storefront/presentation/pages/home_page.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      final loginProvider = context.read<LoginProvider>();
      await loginProvider.login(email, password);
      
      if (mounted && loginProvider.isSuccess) {
        final destination = loginProvider.isAdmin 
            ? const AdminDashboardPage() 
            : const HomePage();
            
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              final width = isDesktop ? 1152.0 : 450.0;
              final height = isDesktop ? 800.0 : null; // auto on mobile

              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDesktop)
                      Expanded(
                        child: _buildLeftBrandArea(theme, isDark, adminProvider),
                      ),
                    Expanded(
                      child: _buildRightLoginForm(context, isDark),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLeftBrandArea(ThemeData theme, bool isDark, AdminProvider adminProvider) {
    final imageUrl = adminProvider.loja?.urlImagemLogin;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildImageFallback(isDark),
          )
        else
          _buildImageFallback(isDark),
        
        // Gradient Overlays
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                theme.primaryColor.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageFallback(bool isDark) {
    return Image.network(
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=2426&auto=format&fit=crop',
      fit: BoxFit.cover,
    );
  }

  Widget _buildFallbackBrandArea(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.storefront,
        size: 120,
        color: theme.primaryColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildRightLoginForm(BuildContext context, bool isDark) {
    final provider = context.watch<LoginProvider>();
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bem-vindo de volta',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                'Por favor, insira seus dados para entrar.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 48),

              // Error Message
              if (provider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (provider.isSuccess)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Login realizado com sucesso!',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Field
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Endereço de e-mail',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Insira seu email',
                  prefixIcon: Icon(Icons.mail_outline, size: 20, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
              ),
              const SizedBox(height: 24),

              // Password Field
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Senha',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Esqueceu a senha?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Insira sua senha',
                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: provider.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 48),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Não tem uma conta? ",
                    style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Criar uma conta',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
