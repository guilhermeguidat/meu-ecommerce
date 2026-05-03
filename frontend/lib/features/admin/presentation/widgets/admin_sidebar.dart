import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/providers/login_provider.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final adminProvider = context.watch<AdminProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final loja = adminProvider.loja;
    final storeName = loja?.nome ?? 'Meu Ecommerce';

    final userName = loginProvider.userName ?? 'Administrador';
    final userEmail = loginProvider.userEmail ?? 'admin@store.com';

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrand(primaryColor, theme, storeName),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Produtos',
                  index: 1,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Pedidos',
                  index: 2,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Clientes',
                  index: 3,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Análise',
                  index: 4,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Configurações',
                  index: 5,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildUserProfile(theme, primaryColor, userName, userEmail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand(Color primaryColor, ThemeData theme, String storeName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              storeName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color primaryColor,
    required ThemeData theme,
  }) {
    final isSelected = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => onNavigate(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? primaryColor : Colors.grey[500],
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? primaryColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(ThemeData theme, Color primaryColor, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
