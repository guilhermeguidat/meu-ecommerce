import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/storefront_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/storefront_app_bar.dart';
import '../../data/models/cart_item_model.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorefrontProvider>();
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFf6f6f8),
      appBar: StorefrontAppBar(provider: provider, isDark: isDark),
      body: cart.isEmpty
          ? _buildEmptyCart(context, isDark, theme)
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb
                        _buildBreadcrumb(context, isDark, theme),
                        const SizedBox(height: 16),
                        // Título
                        Row(
                          children: [
                            Text(
                              'Seu Carrinho',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '(${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'itens'})',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey[400] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth > 768;
                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: _buildItemsList(context, cart, isDark, theme, currencyFormat),
                                  ),
                                  const SizedBox(width: 32),
                                  SizedBox(
                                    width: 360,
                                    child: _buildOrderSummary(context, cart, isDark, theme, currencyFormat),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildItemsList(context, cart, isDark, theme, currencyFormat),
                                  const SizedBox(height: 24),
                                  _buildOrderSummary(context, cart, isDark, theme, currencyFormat),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 64),
                        _buildFooter(context, provider, isDark, theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context, bool isDark, ThemeData theme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: Text(
            'Início',
            style: TextStyle(
              fontSize: 14,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '/',
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ),
        ),
        Text(
          'Carrinho',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool isDark, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore nossa loja e adicione produtos ao carrinho.',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.storefront),
            label: const Text(
              'Continuar Comprando',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, CartProvider cart, bool isDark, ThemeData theme, NumberFormat fmt) {
    return Column(
      children: [
        ...cart.items.map((item) => _buildCartItem(context, item, cart, isDark, theme, fmt)),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item, CartProvider cart, bool isDark, ThemeData theme, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2433) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                color: isDark ? const Color(0xFF2D3748) : const Color(0xFFF1F5F9),
                child: item.produto.urlImagem != null && item.produto.urlImagem!.isNotEmpty
                    ? Image.network(
                        item.produto.urlImagem!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, size: 40, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      )
                    : Icon(Icons.image, size: 40, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
            const SizedBox(width: 20),
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.produto.descricao,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (item.variacao != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (item.corVariacao != null)
                                    Container(
                                      width: 14,
                                      height: 14,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: item.corVariacao,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                                      ),
                                    ),
                                  if (item.descricaoVariacao.isNotEmpty)
                                    Text(
                                      item.descricaoVariacao,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (item.produto.categoria != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.produto.categoria!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Botão remover
                      IconButton(
                        onPressed: () => cart.removeItem(item.itemKey),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.grey[500],
                        hoverColor: Colors.red.withValues(alpha: 0.1),
                        tooltip: 'Remover item',
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stepper + Preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stepper
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => cart.updateQuantity(item.itemKey, item.quantidade - 1),
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Icon(Icons.remove, size: 16, color: isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${item.quantidade}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => cart.updateQuantity(item.itemKey, item.quantidade + 1),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Icon(Icons.add, size: 16, color: isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Preço
                      Text(
                        fmt.format(item.precoTotal),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart, bool isDark, ThemeData theme, NumberFormat fmt) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2433) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
              Text(
                fmt.format(cart.subtotal),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 24),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                fmt.format(cart.subtotal),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Botão Finalizar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Integrar com backend de pedidos na próxima fase
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Finalização de pedido em breve!'),
                    backgroundColor: theme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text(
                'Finalizar Compra',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Link continuar comprando
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              icon: Icon(Icons.storefront, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              label: Text(
                'Continuar Comprando',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, StorefrontProvider provider, bool isDark, ThemeData theme) {
    final lojaNome = provider.loja?.nome ?? 'Loja';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (provider.loja?.urlLogo != null && provider.loja!.urlLogo!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    provider.loja!.urlLogo!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.storefront, color: Colors.white, size: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 24),
                ),
              const SizedBox(width: 12),
              Text(
                lojaNome,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.facebook), color: isDark ? Colors.grey[400] : Colors.grey[600], onPressed: () {}),
              IconButton(icon: const Icon(Icons.camera_alt), color: isDark ? Colors.grey[400] : Colors.grey[600], onPressed: () {}),
              IconButton(icon: const Icon(Icons.alternate_email), color: isDark ? Colors.grey[400] : Colors.grey[600], onPressed: () {}),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} $lojaNome. Todos os direitos reservados.',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
