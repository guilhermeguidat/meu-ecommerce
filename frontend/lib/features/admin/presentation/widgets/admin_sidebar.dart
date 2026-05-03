import 'package:flutter/material.dart';

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
          _buildBrand(primaryColor, theme),
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
                  label: 'Analytics',
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
                  label: 'Store Settings',
                  index: 5,
                  primaryColor: primaryColor,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildUserProfile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand(Color primaryColor, ThemeData theme) {
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
          Text(
            'MerchantOS',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
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

  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 20, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin User',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'admin@store.com',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
