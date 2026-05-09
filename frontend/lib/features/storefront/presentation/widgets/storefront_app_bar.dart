import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../providers/storefront_provider.dart';

class StorefrontAppBar extends StatelessWidget implements PreferredSizeWidget {
  final StorefrontProvider provider;
  final bool isDark;

  const StorefrontAppBar({
    super.key,
    required this.provider,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loja = provider.loja;

    return AppBar(
      backgroundColor: isDark ? const Color(0xDD101622) : const Color(0xDDFFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              InkWell(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Row(
                  children: [
                    if (loja?.urlLogo != null && loja!.urlLogo!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          loja.urlLogo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackLogo(theme),
                        ),
                      ),
                    ] else
                      _buildFallbackLogo(theme),
                    const SizedBox(width: 12),
                    Text(
                      loja?.nome ?? 'LUMIÈRE',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar (Centered)
              if (MediaQuery.of(context).size.width > 768)
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 500,
                      height: 40,
                      child: TextField(
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar produtos...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 14),
                          prefixIcon: Icon(Icons.search, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                      ),
                    ),
                  ),
                ),

              // Actions
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
