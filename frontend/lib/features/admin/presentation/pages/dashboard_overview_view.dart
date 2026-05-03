import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class DashboardOverviewView extends StatelessWidget {
  const DashboardOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildStatGrid(context),
          const SizedBox(height: 32),
          // Here goes the chart and recent orders in the future
          _buildPlaceholderChart(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Admin',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's what's happening with your store today.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Product'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 1;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.8,
          children: [
            StatCard(
              title: 'Total Revenue',
              value: '\$24,560.00',
              icon: Icons.payments,
              iconBgColor: Colors.blue[50]!,
              iconColor: Colors.blue[600]!,
              trendValue: '+12.5%',
              isTrendUp: true,
            ),
            StatCard(
              title: 'Total Orders',
              value: '1,245',
              icon: Icons.shopping_cart,
              iconBgColor: Colors.purple[50]!,
              iconColor: Colors.purple[600]!,
              trendValue: '+5.2%',
              isTrendUp: true,
            ),
            StatCard(
              title: 'Active Customers',
              value: '892',
              icon: Icons.group,
              iconBgColor: Colors.orange[50]!,
              iconColor: Colors.orange[600]!,
              trendValue: '-2.1%',
              isTrendUp: false,
            ),
            StatCard(
              title: 'Avg. Order Value',
              value: '\$84.50',
              icon: Icons.receipt_long,
              iconBgColor: Colors.teal[50]!,
              iconColor: Colors.teal[600]!,
              trendValue: '+8.4%',
              isTrendUp: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderChart(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          'Sales Performance Chart Placeholder',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
