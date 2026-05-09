import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storefront_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/storefront_app_bar.dart';

class StorefrontHomePage extends StatefulWidget {
  const StorefrontHomePage({super.key});

  @override
  State<StorefrontHomePage> createState() => _StorefrontHomePageState();
}

class _StorefrontHomePageState extends State<StorefrontHomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StorefrontProvider>().loadData();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        final banners = context.read<StorefrontProvider>().loja?.banners ?? [];
        if (banners.isNotEmpty) {
          int nextPage = _pageController.page!.round() + 1;
          if (nextPage >= banners.length) {
            _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          } else {
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorefrontProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (provider.isLoading && provider.loja == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFf6f6f8),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101622) : const Color(0xFFf6f6f8),
      appBar: StorefrontAppBar(provider: provider, isDark: isDark),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(provider, isDark),
                  const SizedBox(height: 48),
                  _buildCategoryRail(provider, isDark),
                  const SizedBox(height: 48),
                  _buildTrendingHeader(provider, isDark),
                  const SizedBox(height: 24),
                  _buildProductGrid(provider, context),
                  const SizedBox(height: 64),
                  _buildFooter(provider, context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.storefront, color: Colors.white, size: 24),
    );
  }

  Widget _buildHeroBanner(StorefrontProvider provider, bool isDark) {
    final banners = provider.loja?.banners ?? [];
    if (banners.isEmpty) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text('Bem-vindo à nossa loja!', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 500,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Image.network(
                  banners[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRail(StorefrontProvider provider, bool isDark) {
    final productCategories = provider.produtos
        .map((e) => e.categoria)
        .where((c) => c != null && c.isNotEmpty)
        .map((c) => c!)
        .toSet()
        .toList();
        
    final categories = ['Todos', ...productCategories];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categorias',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(provider, categories[index], isDark, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(StorefrontProvider provider, String title, bool isDark, BuildContext context) {
    IconData icon;
    switch (title) {
      case 'Todos': icon = Icons.apps; break;
      case 'Roupas': icon = Icons.checkroom; break;
      case 'Acessórios': icon = Icons.watch; break;
      case 'Eletrônicos': icon = Icons.headphones; break;
      case 'Casa': icon = Icons.chair; break;
      case 'Beleza': icon = Icons.face; break;
      case 'Esportes': icon = Icons.sports_tennis; break;
      default: icon = Icons.category;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: InkWell(
        onTap: () {
          provider.setCategory(title);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Icon(icon, color: isDark ? Colors.grey[300] : Colors.grey[700], size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingHeader(StorefrontProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produtos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Explore nosso catálogo completo.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildTrendingFilter(provider, 'Todos', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendingFilter(StorefrontProvider provider, String title, bool isDark) {
    final isSelected = provider.selectedCategory == title;

    return InkWell(
      onTap: () {
        provider.setCategory(title);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white : const Color(0xFF0F172A))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected 
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.grey[300] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(StorefrontProvider provider, BuildContext context) {
    final produtos = provider.filteredProdutos;

    if (produtos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Text(
            'Nenhum produto encontrado.',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 900) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.70,
        crossAxisSpacing: 24,
        mainAxisSpacing: 32,
      ),
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        return ProductCard(produto: produtos[index]);
      },
    );
  }

  Widget _buildFooter(StorefrontProvider provider, BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final lojaNome = provider.loja?.nome ?? 'LUMIÈRE';

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
                    errorBuilder: (_, __, ___) => _buildFallbackLogo(theme),
                  ),
                )
              else
                _buildFallbackLogo(theme),
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
              IconButton(
                icon: const Icon(Icons.facebook),
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.alternate_email),
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} $lojaNome. Todos os direitos reservados.',
            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
