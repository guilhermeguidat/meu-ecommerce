import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import 'store_settings_view.dart';
import 'manage_products_view.dart';
import 'dashboard_overview_view.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadData();
    });
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBody(AdminProvider provider) {
    if (provider.isLoading && provider.loja == null) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentIndex) {
      case 0:
        return const DashboardOverviewView();
      case 1:
        return const ManageProductsView();
      case 5:
        return const StoreSettingsView();
      default:
        return const Center(child: Text('Em breve...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Meu Ecommerce'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.loadData(),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: AdminSidebar(
                currentIndex: _currentIndex,
                onNavigate: (index) {
                  _onNavigate(index);
                  Navigator.pop(context); // Close drawer
                },
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              currentIndex: _currentIndex,
              onNavigate: _onNavigate,
            ),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopHeader(provider),
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: _buildBody(provider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(AdminProvider provider) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Visão Geral',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(), // Removidos botões de ação conforme solicitado
        ],
      ),
    );
  }
}
