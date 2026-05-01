import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class ManageProductsView extends StatelessWidget {
  const ManageProductsView({super.key});

  void _showAddProductDialog(BuildContext context) {
    final descricaoController = TextEditingController();
    final precoController = TextEditingController();
    final quantidadeController = TextEditingController();
    final categoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
              const SizedBox(height: 16),
              TextField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: categoriaController, decoration: const InputDecoration(labelText: 'Categoria')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AdminProvider>().adminService.createProduto({
                  'descricao': descricaoController.text,
                  'valorUnitario': double.parse(precoController.text),
                  'quantidade': int.parse(quantidadeController.text),
                  'categoria': categoriaController.text,
                });
                if (context.mounted) {
                  Navigator.pop(ctx);
                  context.read<AdminProvider>().loadData();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerenciar Produtos',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gerencie seu catálogo de produtos e estoque.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Produto'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: provider.produtos.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('Nenhum produto cadastrado.')),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey[50], // neutral-50
                          ),
                          columns: const [
                            DataColumn(label: Text('Produto')),
                            DataColumn(label: Text('Categoria')),
                            DataColumn(label: Text('Estoque')),
                            DataColumn(label: Text('Preço')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: provider.produtos.map((produto) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.inventory_2, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(produto.descricao, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      produto.categoria ?? 'Sem Categoria',
                                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                                    ),
                                  ),
                                ),
                                DataCell(Text('${produto.quantidade} unid.')),
                                DataCell(Text('R\$ ${produto.valorUnitario.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => provider.deleteProduto(produto.id!),
                                    tooltip: 'Excluir Produto',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
