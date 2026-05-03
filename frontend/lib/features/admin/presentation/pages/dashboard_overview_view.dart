import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/providers/login_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/stat_card.dart';

class DashboardOverviewView extends StatelessWidget {
  const DashboardOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final userName = loginProvider.userName ?? 'Administrador';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, userName),
          const SizedBox(height: 32),
          _buildStatGrid(context),
          const SizedBox(height: 32),
          _buildPerformanceSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, $userName',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Bem-vindo de volta ao seu painel de controle.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
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
              title: 'Receita Total',
              value: 'R\$ 0,00',
              icon: Icons.payments_outlined,
              trendValue: '0%',
              isTrendUp: true,
            ),
            StatCard(
              title: 'Total de Pedidos',
              value: '0',
              icon: Icons.shopping_cart_outlined,
              trendValue: '0%',
              isTrendUp: true,
            ),
            StatCard(
              title: 'Clientes Ativos',
              value: '0',
              icon: Icons.group_outlined,
              trendValue: '0%',
              isTrendUp: true,
            ),
            StatCard(
              title: 'Ticket Médio',
              value: 'R\$ 0,00',
              icon: Icons.receipt_long_outlined,
              trendValue: '0%',
              isTrendUp: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desempenho de Vendas',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum dado disponível',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'As estatísticas de vendas aparecerão aqui assim que você realizar vendas.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
