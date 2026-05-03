import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_toast.dart';
import '../../../../core/utils/log.dart';
import '../../data/models/produto_variacao_model.dart';
import '../../data/models/produto_model.dart';
import '../providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';

class AddProductModal extends StatefulWidget {
  final ProdutoModel? produto;

  const AddProductModal({super.key, this.produto});

  static Future<void> show(BuildContext context, {ProdutoModel? produto}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => AddProductModal(produto: produto),
    );
  }

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _categoriaController = TextEditingController();

  Uint8List? _imagemBytes;
  String? _imagemNome;
  String? _urlImagemExistente;

  final List<ProdutoVariacaoModel> _variacoes = [];
  bool _isLoading = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    if (widget.produto != null) {
      final p = widget.produto!;
      _descricaoController.text = p.descricao;
      _precoController.text = p.valorUnitario.toStringAsFixed(2).replaceAll('.', ',');
      _quantidadeController.text = p.quantidade.toString();
      _categoriaController.text = p.categoria ?? '';
      _urlImagemExistente = p.urlImagem;
      
      if (p.variacoes.isNotEmpty) {
        _variacoes.addAll(p.variacoes);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
      if (picked == null) {
        return;
      }
      final bytes = await picked.readAsBytes();
      setState(() {
        _imagemBytes = bytes;
        _imagemNome = picked.name;
      });
    } on Exception catch (e) {
      Log.e('[AddProductModal] Erro ao selecionar imagem', e);
      if (mounted) {
        CustomToast.show(context, message: 'Erro ao selecionar imagem: $e', isError: true);
      }
    }
  }

  void _addVariacao() {
    _showVariacaoDialog(context);
  }

  void _showVariacaoDialog(BuildContext ctx) {
    final variacaoFormKey = GlobalKey<FormState>();
    final tamanhoCtrl = TextEditingController();
    final corCtrl = TextEditingController();
    final qtdCtrl = TextEditingController();
    final theme = Theme.of(ctx);
    Color pickerColor = theme.primaryColor;

    corCtrl.addListener(() {
      final hex = corCtrl.text.trim();
      if (hex.length >= 4 && hex.startsWith('#')) {
        try {
          final color = _parseColor(hex);
          pickerColor = color;
        } catch (_) {}
      }
    });

    showDialog(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nova Variação', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: variacaoFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tamanhoCtrl,
                  decoration: const InputDecoration(labelText: 'Tamanho', hintText: 'Ex: P, M, G, 38...'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Selecione uma cor'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: (color) {
                                setDialogState(() {
                                  pickerColor = color;
                                  corCtrl.text = _colorToHex(color);
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
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: pickerColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.colorize, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: corCtrl,
                      decoration: const InputDecoration(labelText: 'Cor', hintText: 'Ex: Azul, #2563EB...'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: qtdCtrl,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!variacaoFormKey.currentState!.validate()) {
                  return;
                }
                
                final variacaoQtd = int.tryParse(qtdCtrl.text) ?? 0;
                setState(() {
                  _variacoes.add(ProdutoVariacaoModel(
                    tamanho: tamanhoCtrl.text.trim(),
                    cor: corCtrl.text.trim(),
                    quantidade: variacaoQtd,
                  ));

                  // Atualiza quantidade total automaticamente se houver variações
                  final totalQtd = _variacoes.fold<int>(0, (sum, v) => sum + v.quantidade);
                  _quantidadeController.text = totalQtd.toString();
                });
                Navigator.pop(dCtx);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    String formattedHex = hex.replaceFirst('#', '');
    if (formattedHex.length == 3) {
      formattedHex = formattedHex.split('').map((e) => '$e$e').join();
    }
    if (formattedHex.length == 6) {
      formattedHex = 'FF$formattedHex';
    }
    try {
      return Color(int.parse(formattedHex, radix: 16));
    } catch (_) {
      return Theme.of(context).primaryColor;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // Cria MultipartFile fresh a cada tentativa para evitar 'already finalized'
      final imagemBytes = _imagemBytes;
      final imagemNome = _imagemNome;
      
      if (widget.produto != null) {
        await context.read<AdminProvider>().updateProduto(
          id: widget.produto!.id!,
          descricao: _descricaoController.text.trim(),
          valorUnitario: double.parse(_precoController.text.replaceAll(',', '.')),
          quantidade: int.parse(_quantidadeController.text),
          categoria: _categoriaController.text.trim().isEmpty ? null : _categoriaController.text.trim(),
          imagemBytes: imagemBytes,
          imagemNome: imagemNome,
          variacoes: _variacoes,
        );
      } else {
        await context.read<AdminProvider>().adminService.createProduto(
          descricao: _descricaoController.text.trim(),
          valorUnitario: double.parse(_precoController.text.replaceAll(',', '.')),
          quantidade: int.parse(_quantidadeController.text),
          categoria: _categoriaController.text.trim().isEmpty ? null : _categoriaController.text.trim(),
          imagemBytes: imagemBytes,
          imagemNome: imagemNome,
          variacoes: _variacoes,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        context.read<AdminProvider>().loadData();
        CustomToast.show(context, message: widget.produto != null ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!');
      }
    } catch (e) {
      Log.e('[AddProductModal] Erro ao salvar produto', e);
      if (mounted) {
        CustomToast.show(context, message: 'Erro inesperado: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(theme, isDark),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildImagePicker(theme, isDark),
                          const SizedBox(height: 20),
                          _buildSectionLabel(theme, 'Informações Básicas'),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _descricaoController,
                            label: 'Nome do Produto',
                            hint: 'Ex: Camiseta Básica Algodão',
                            icon: Icons.inventory_2_outlined,
                            validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildField(
                                  controller: _precoController,
                                  label: 'Preço (R\$)',
                                  hint: '0.00',
                                  icon: Icons.attach_money_rounded,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Campo obrigatório';
                                    }
                                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
                                      return 'Valor inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _quantidadeController,
                                  label: 'Qtd.',
                                  hint: '0',
                                  icon: Icons.tag_rounded,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _categoriaController,
                            label: 'Categoria',
                            hint: 'Ex: Roupas, Calçados...',
                            icon: Icons.label_outline_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel(theme, 'Variações'),
                          const SizedBox(height: 12),
                          _buildVariacoesList(theme, isDark),
                          const SizedBox(height: 10),
                          _buildAddVariacaoButton(theme, isDark),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(context, theme, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_box_rounded, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.produto != null ? 'Editar Produto' : 'Novo Produto',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              Text(
                widget.produto != null ? 'Atualize as informações do produto' : 'Preencha os dados para adicionar ao catálogo',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 140,
        decoration: BoxDecoration(
          color: _imagemBytes != null
              ? Colors.transparent
              : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _imagemBytes != null ? theme.primaryColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: _imagemBytes != null ? 2 : 1.5,
            style: BorderStyle.solid,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imagemBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_imagemBytes!, fit: BoxFit.cover),
                  Container(color: Colors.black38),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          _imagemNome ?? 'Alterar imagem',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : (_urlImagemExistente != null && _urlImagemExistente!.isNotEmpty)
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_urlImagemExistente!, fit: BoxFit.cover),
                      Container(color: Colors.black38),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'Alterar imagem atual',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cloud_upload_outlined, color: theme.primaryColor, size: 28),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Clique para adicionar imagem',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG ou WEBP • Máx. 5MB',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String text) {
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: Theme.of(context).primaryColor.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildVariacoesList(ThemeData theme, bool isDark) {
    if (_variacoes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            const SizedBox(width: 8),
            Text(
              'Nenhuma variação adicionada',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _variacoes.asMap().entries.map((entry) {
        final i = entry.key;
        final v = entry.value;
        return _buildVariacaoChip(theme, v, i, isDark);
      }).toList(),
    );
  }

  Widget _buildVariacaoChip(ThemeData theme, ProdutoVariacaoModel v, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.style_rounded, color: theme.primaryColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: v.tamanho,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: v.cor,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  TextSpan(
                    text: '  •  ${v.quantidade} unid.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _variacoes.removeAt(index);
                // Atualiza quantidade total ao remover variação
                final totalQtd = _variacoes.fold<int>(0, (sum, v) => sum + v.quantidade);
                _quantidadeController.text = totalQtd.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddVariacaoButton(ThemeData theme, bool isDark) {
    return OutlinedButton.icon(
      onPressed: _addVariacao,
      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
      label: const Text('Adicionar Variação'),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.primaryColor,
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: theme.primaryColor.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(widget.produto != null ? 'Salvar Alterações' : 'Cadastrar Produto', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
