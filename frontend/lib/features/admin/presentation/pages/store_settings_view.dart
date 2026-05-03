import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';

class StoreSettingsView extends StatefulWidget {
  const StoreSettingsView({super.key});

  @override
  State<StoreSettingsView> createState() => _StoreSettingsViewState();
}

class _StoreSettingsViewState extends State<StoreSettingsView> {
  final _corPrimariaController = TextEditingController();

  // Banners selecionados via image_picker (novos uploads)
  final List<Uint8List> _bannerBytes = [];
  final List<String> _bannerNames = [];

  // URLs dos banners já salvos no servidor (carregados via getLojaConfig)
  List<String> _bannersExistentes = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminProvider>();
    if (provider.loja != null) {
      _corPrimariaController.text = provider.loja!.corPrimaria;
      _bannersExistentes = List.from(provider.loja!.banners);
    }
  }

  @override
  void dispose() {
    _corPrimariaController.dispose();
    super.dispose();
  }

  Future<void> _pickBanners() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(maxWidth: 1920, imageQuality: 85);
      if (picked.isEmpty) {
        return;
      }
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        setState(() {
          _bannerBytes.add(bytes);
          _bannerNames.add(file.name);
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar banners: $e')),
        );
      }
    }
  }

  void _removeBannerNovo(int index) {
    setState(() {
      _bannerBytes.removeAt(index);
      _bannerNames.removeAt(index);
    });
  }

  void _removeBannerExistente(int index) {
    setState(() {
      _bannersExistentes.removeAt(index);
    });
  }

  void _saveSettings() {
    final cor = _corPrimariaController.text.trim();
    if (cor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a cor primária')),
      );
      return;
    }
    context.read<AdminProvider>().updateStoreConfig(
      corPrimaria: cor,
      bannerBytes: _bannerBytes.isNotEmpty ? List.from(_bannerBytes) : null,
      bannerNames: _bannerNames.isNotEmpty ? List.from(_bannerNames) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações da Loja',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gerencie a aparência e os banners da sua vitrine.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identidade Visual',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 32),

                if (provider.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ---- Cor Primária ----
                const Text('Cor Primária', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _corPrimariaController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: #135bec',
                    prefixIcon: Icon(Icons.color_lens_outlined),
                  ),
                ),
                const SizedBox(height: 28),

                // ---- Banners ----
                const Text('Banners Promocionais', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  'Selecione uma ou mais imagens para os banners da vitrine.',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
                const SizedBox(height: 12),

                // Banners já salvos no servidor
                if (_bannersExistentes.isNotEmpty) ...[
                  _buildSectionLabel('Banners Atuais', isDark),
                  const SizedBox(height: 8),
                  _buildBannersExistentesGrid(isDark),
                  const SizedBox(height: 16),
                ],

                // Novos banners selecionados
                if (_bannerBytes.isNotEmpty) ...[
                  _buildSectionLabel('Novos Banners (${_bannerBytes.length})', isDark),
                  const SizedBox(height: 8),
                  _buildNovoBannersGrid(isDark),
                  const SizedBox(height: 12),
                ],

                // Botão de adicionar banner
                OutlinedButton.icon(
                  onPressed: _pickBanners,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Adicionar Banners'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Salvar Configurações', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBannersExistentesGrid(bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _bannersExistentes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildBannerCardNetwork(_bannersExistentes[index], index, isDark);
        },
      ),
    );
  }

  Widget _buildNovoBannersGrid(bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _bannerBytes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildBannerCardBytes(_bannerBytes[index], _bannerNames[index], index, isDark);
        },
      ),
    );
  }

  Widget _buildBannerCardNetwork(String url, int index, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeBannerExistente(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCardBytes(Uint8List bytes, String name, int index, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeBannerNovo(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
