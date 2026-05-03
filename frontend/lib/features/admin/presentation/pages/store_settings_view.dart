import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  final _nomeController = TextEditingController();
  Color _pickerColor = AppColors.primary;

  // Banners selecionados via image_picker (novos uploads)
  final List<Uint8List> _bannerBytes = [];
  final List<String> _bannerNames = [];

  // Logo da Empresa
  Uint8List? _logoBytes;
  String? _logoName;
  String? _urlLogoExistente;

  // Imagem de Login
  Uint8List? _imagemLoginBytes;
  String? _imagemLoginName;
  String? _urlImagemLoginExistente;

  // URLs dos banners já salvos no servidor (carregados via getLojaConfig)
  List<String> _bannersExistentes = [];

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminProvider>();
    if (provider.loja != null) {
      _corPrimariaController.text = provider.loja!.corPrimaria;
      _nomeController.text = provider.loja!.nome;
      _bannersExistentes = List.from(provider.loja!.banners);
      _urlLogoExistente = provider.loja!.urlLogo;
      _urlImagemLoginExistente = provider.loja!.urlImagemLogin;
      try {
        _pickerColor = _parseColor(provider.loja!.corPrimaria);
      } catch (_) {}
    } else {
      // Tenta pegar a cor do tema atual como fallback inicial
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _pickerColor = Theme.of(context).primaryColor;
          });
        }
      });
    }
    _corPrimariaController.addListener(_onHexChanged);
  }

  void _onHexChanged() {
    final hex = _corPrimariaController.text.trim();
    if (hex.length >= 4 && hex.startsWith('#')) {
      try {
        setState(() {
          _pickerColor = _parseColor(hex);
        });
      } catch (_) {}
    }
  }

  Color _parseColor(String hex) {
    String formattedHex = hex.replaceFirst('#', '');
    if (formattedHex.length == 3) {
      formattedHex = formattedHex.split('').map((e) => '$e$e').join();
    }
    if (formattedHex.length == 6) {
      formattedHex = 'FF$formattedHex';
    }
    return Color(int.parse(formattedHex, radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecione uma cor'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) {
              setState(() {
                _pickerColor = color;
                _corPrimariaController.text = _colorToHex(color);
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _corPrimariaController.removeListener(_onHexChanged);
    _corPrimariaController.dispose();
    _nomeController.dispose();
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

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
      if (picked == null) return;
      
      final bytes = await picked.readAsBytes();
      setState(() {
        _logoBytes = bytes;
        _logoName = picked.name;
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
      }
    }
  }

  void _removeLogoNovo() {
    setState(() {
      _logoBytes = null;
      _logoName = null;
    });
  }

  Future<void> _pickImagemLogin() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
      if (picked == null) return;
      
      final bytes = await picked.readAsBytes();
      setState(() {
        _imagemLoginBytes = bytes;
        _imagemLoginName = picked.name;
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
      }
    }
  }

  void _removeImagemLoginNovo() {
    setState(() {
      _imagemLoginBytes = null;
      _imagemLoginName = null;
    });
  }

  void _saveSettings() {
    final cor = _corPrimariaController.text.trim();
    final nome = _nomeController.text.trim();
    if (cor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a cor primária')),
      );
      return;
    }
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da loja')),
      );
      return;
    }
    context.read<AdminProvider>().updateStoreConfig(
      corPrimaria: cor,
      nome: nome,
      bannerBytes: _bannerBytes.isNotEmpty ? List.from(_bannerBytes) : null,
      bannerNames: _bannerNames.isNotEmpty ? List.from(_bannerNames) : null,
      logoBytes: _logoBytes,
      logoName: _logoName,
      imagemLoginBytes: _imagemLoginBytes,
      imagemLoginName: _imagemLoginName,
      existingBanners: _bannersExistentes.isNotEmpty ? List.from(_bannersExistentes) : [],
    ).then((_) {
      if (mounted && context.read<AdminProvider>().errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Limpa seleções locais pois já foram salvas
        setState(() {
          _bannerBytes.clear();
          _bannerNames.clear();
          _logoBytes = null;
          _logoName = null;
          _imagemLoginBytes = null;
          _imagemLoginName = null;
          
          // Atualiza banners existentes com o que veio do provider após o save
          final updatedLoja = context.read<AdminProvider>().loja;
          if (updatedLoja != null) {
            _bannersExistentes = List.from(updatedLoja.banners);
            _urlLogoExistente = updatedLoja.urlLogo;
            _urlImagemLoginExistente = updatedLoja.urlImagemLogin;
          }
        });
      }
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                ],
              ),
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _saveSettings,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: const Text('Salvar Configurações', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // ---- Nome da Loja ----
                const Text('Nome da Loja', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Minha Loja Inc.',
                    prefixIcon: Icon(Icons.store_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // ---- Cor Primária ----
                const Text('Cor Primária', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _pickerColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: _pickerColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.colorize, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _corPrimariaController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: #135BEC',
                          prefixIcon: Icon(Icons.color_lens_outlined, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ---- Logo da Empresa ----
                const Text('Logo da Empresa', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                if (_urlLogoExistente != null && _logoBytes == null) ...[
                  _buildSectionLabel(theme, 'Logo Atual', isDark),
                  const SizedBox(height: 8),
                  _buildPreviewExistenteCard(_urlLogoExistente!, isDark),
                  const SizedBox(height: 16),
                ],
                if (_logoBytes != null) ...[
                  _buildSectionLabel(theme, 'Nova Logo Selecionada', isDark),
                  const SizedBox(height: 8),
                  _buildPreviewNovoCard(theme, isDark, _logoBytes!, _logoName, _removeLogoNovo),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Selecionar Logo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 28),

                // ---- Imagem de Login ----
                const Text('Imagem da Tela de Login', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                if (_urlImagemLoginExistente != null && _imagemLoginBytes == null) ...[
                  _buildSectionLabel(theme, 'Imagem Atual', isDark),
                  const SizedBox(height: 8),
                  _buildPreviewExistenteCard(_urlImagemLoginExistente!, isDark),
                  const SizedBox(height: 16),
                ],
                if (_imagemLoginBytes != null) ...[
                  _buildSectionLabel(theme, 'Nova Imagem Selecionada', isDark),
                  const SizedBox(height: 8),
                  _buildPreviewNovoCard(theme, isDark, _imagemLoginBytes!, _imagemLoginName, _removeImagemLoginNovo),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _pickImagemLogin,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Selecionar Imagem'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 28),

                // ---- Banners ----
                const Text('Banners Promocionais', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),

                // Banners já salvos no servidor
                if (_bannersExistentes.isNotEmpty) ...[
                  _buildSectionLabel(theme, 'Banners Atuais', isDark),
                  const SizedBox(height: 8),
                  _buildBannersExistentesGrid(isDark),
                  const SizedBox(height: 16),
                ],

                // Novos banners selecionados
                if (_bannerBytes.isNotEmpty) ...[
                  _buildSectionLabel(theme, 'Novos Banners (${_bannerBytes.length})', isDark),
                  const SizedBox(height: 8),
                  _buildNovoBannersGrid(theme, isDark),
                  const SizedBox(height: 12),
                ],

                // Botão de adicionar banner
                OutlinedButton.icon(
                  onPressed: _pickBanners,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Adicionar Banners'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String text, bool isDark) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: theme.primaryColor,
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

  Widget _buildNovoBannersGrid(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _bannerBytes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildBannerCardBytes(theme, _bannerBytes[index], _bannerNames[index], index, isDark);
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

  Widget _buildBannerCardBytes(ThemeData theme, Uint8List bytes, String name, int index, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.5), width: 1.5),
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

  Widget _buildPreviewExistenteCard(String url, bool isDark) {
    return Container(
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
    );
  }

  Widget _buildPreviewNovoCard(ThemeData theme, bool isDark, Uint8List bytes, String? name, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.5), width: 1.5),
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
                  name ?? 'Imagem selecionada',
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
            onTap: onRemove,
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
