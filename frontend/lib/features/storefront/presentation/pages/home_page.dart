import 'package:flutter/material.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../../core/di/dependency_injection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await getIt<AuthService>().getUserRole();
    if (mounted) {
      setState(() {
        _isAdmin = role == 'ROLE_ADMIN';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storefront Home (Fase 2)'),
        actions: [
          if (!_isLoading && _isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Painel da Empresa',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                );
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo à Loja!',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'A vitrine (Fase 2) será implementada aqui em breve.\nPor enquanto, use o ícone no topo para acessar o Painel da Empresa.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
