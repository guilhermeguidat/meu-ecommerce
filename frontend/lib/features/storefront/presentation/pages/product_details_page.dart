import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../admin/data/models/produto_model.dart';
import '../../../admin/data/models/produto_variacao_model.dart';
import '../providers/storefront_provider.dart';
import '../widgets/storefront_app_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProdutoModel produto;

  const ProductDetailsPage({super.key, required this.produto});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  
  ProdutoVariacaoModel? _selectedVariation;
  int _quantity = 1;

  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    var hex = hexColor.toUpperCase().replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    if (hex.length == 8) {
      final intVal = int.tryParse(hex, radix: 16);
      if (intVal != null) {
        return Color(intVal);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.produto.variacoes.isNotEmpty) {
      _selectedVariation = widget.produto.variacoes.first;
    }
  }

  void _incrementQuantity() {
    if (_selectedVariation != null && _quantity < _selectedVariation!.quantidade) {
      setState(() {
        _quantity++;
      });
    } else if (_selectedVariation == null && _quantity < widget.produto.quantidade) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorefrontProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalPrice = widget.produto.valorUnitario * _quantity;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFf6f6f8),
      appBar: StorefrontAppBar(provider: provider, isDark: isDark),
      bottomNavigationBar: _buildStickyBottomBar(isDark, theme, totalPrice),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 768;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagem (Esquerda)
                        Expanded(
                          flex: 5,
                          child: _buildImageGallery(isDark),
                        ),
                        const SizedBox(width: 48),
                        // Informações (Direita)
                        Expanded(
                          flex: 5,
                          child: _buildProductInfo(isDark, theme),
                        ),
                      ],
                    );
                  } else {
                    // Mobile Layout
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageGallery(isDark),
                        const SizedBox(height: 24),
                        _buildProductInfo(isDark, theme),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: widget.produto.urlImagem != null && widget.produto.urlImagem!.isNotEmpty
              ? Image.network(
                  widget.produto.urlImagem!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                )
              : Icon(Icons.image, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildProductInfo(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (Nome, Preço, Categoria)
        Text(
          widget.produto.categoria ?? 'Categoria Geral',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.primaryColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.produto.descricao,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currencyFormat.format(widget.produto.valorUnitario),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        
        const SizedBox(height: 32),
        Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
        const SizedBox(height: 24),

        // Variações
        if (widget.produto.variacoes.isNotEmpty) ...[
          Text(
            'Selecione a Variação',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.produto.variacoes.map((variacao) {
              final isSelected = _selectedVariation == variacao;
              final bool outOfStock = variacao.quantidade <= 0;
              final colorValue = _parseColor(variacao.cor);
              
              return InkWell(
                onTap: outOfStock ? null : () {
                  setState(() {
                    _selectedVariation = variacao;
                    // Reset quantity se for maior que o estoque da nova variação
                    if (_quantity > variacao.quantidade) {
                      _quantity = variacao.quantidade > 0 ? variacao.quantidade : 1;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.primaryColor 
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                        ? theme.primaryColor 
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (colorValue != null) ...[
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: colorValue,
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? Colors.white30 : Colors.black12, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            variacao.tamanho,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected 
                                ? Colors.white 
                                : (outOfStock ? Colors.grey : (isDark ? Colors.white : Colors.black87)),
                              fontWeight: FontWeight.bold,
                              decoration: outOfStock ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? Colors.white.withValues(alpha: 0.2)
                            : (outOfStock ? Colors.red.withValues(alpha: 0.1) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          outOfStock ? 'Esgotado' : '${variacao.quantidade} no estoque',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                              ? Colors.white
                              : (outOfStock ? Colors.red : (isDark ? Colors.grey[300] : Colors.grey[700])),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 24),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.produto.quantidade <= 0 
                ? Colors.red.withValues(alpha: 0.1) 
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.produto.quantidade <= 0 ? Colors.red.withValues(alpha: 0.2) : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              ),
            ),
            child: Text(
              widget.produto.quantidade <= 0 ? 'Esgotado' : '${widget.produto.quantidade} no estoque',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.produto.quantidade <= 0 ? Colors.red : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildStickyBottomBar(bool isDark, ThemeData theme, double totalPrice) {
    int maxStock = _selectedVariation?.quantidade ?? widget.produto.quantidade;
    bool outOfStock = maxStock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xEE0F172A) : const Color(0xEEFFFFFF),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 48 > 1280 ? 1280 : MediaQuery.of(context).size.width - 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total Price
                    if (MediaQuery.of(context).size.width > 600)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Preço Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalPrice),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    
                    // Actions
                    Row(
                      children: [
                        // Stepper
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: outOfStock ? null : _decrementQuantity,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  outOfStock ? '0' : '$_quantity',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: outOfStock ? null : _incrementQuantity,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Add to Cart Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: outOfStock ? null : () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: outOfStock ? 0 : 4,
                            ),
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(
                              outOfStock ? 'Esgotado' : 'Adicionar',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
