import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_config_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';

/// 服务商详情页 — 双 Tab 布局
///
/// Tab 1「配置」：API 连接参数
/// Tab 2「模型」：模型列表管理
class ProviderDetailPage extends StatefulWidget {
  final ApiProvider provider;

  const ProviderDetailPage({super.key, required this.provider});

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 配置表单
  late TextEditingController _nameCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _hostCtrl;
  late TextEditingController _pathCtrl;
  late bool _useProxy;
  bool _showKey = false;

  // 模型添加
  final _newModelCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameCtrl = TextEditingController(text: widget.provider.name);
    _keyCtrl = TextEditingController(text: widget.provider.apiKey);
    _hostCtrl = TextEditingController(text: widget.provider.apiHost);
    _pathCtrl = TextEditingController(text: widget.provider.apiPath);
    _useProxy = widget.provider.useProxy;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _hostCtrl.dispose();
    _pathCtrl.dispose();
    _newModelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final providerConfig = context.watch<ProviderConfigProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors, providerConfig),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConfigTab(context, colors, providerConfig),
          _buildModelsTab(context, colors, providerConfig),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    return AppBar(
      backgroundColor: colors.cardSurface,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: ThemeColors.backIcon(context),
      ),
      title: Text(
        widget.provider.name,
        style: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: colors.mainText,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _deleteProvider(context, providerConfig),
          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: colors.accent,
        unselectedLabelColor: colors.mutedText,
        indicatorColor: colors.accent,
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: '配置'),
          Tab(text: '模型'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 1：配置
  // ═══════════════════════════════════════════
  Widget _buildConfigTab(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称
          _buildField(colors, '名称', _nameCtrl),
          const SizedBox(height: 20),
          // API Key
          _buildKeyField(colors),
          const SizedBox(height: 20),
          // API Host
          _buildField(colors, 'API 主机', _hostCtrl, hint: 'https://api.deepseek.com'),
          const SizedBox(height: 20),
          // API 路径
          _buildField(colors, 'API 路径', _pathCtrl, hint: '/v1/chat/completions',
              enabled: false),
          const SizedBox(height: 20),
          // 网络兼容
          _buildToggleField(colors, '改善网络兼容性', '启用代理和重试机制', _useProxy,
              (v) => setState(() => _useProxy = v)),
          const SizedBox(height: 32),
          // 保存
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveProvider(context, providerConfig),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('保存', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 15, fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 2：模型列表
  // ═══════════════════════════════════════════
  Widget _buildModelsTab(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    final models = widget.provider.models;
    final activeModel = widget.provider.activeModel;

    return Stack(
      children: [
        // 模型列表
        if (models.isEmpty)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.model_training, size: 48, color: colors.mutedText),
                const SizedBox(height: 12),
                Text('还没有添加模型', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 15, color: colors.secondaryText,
                )),
                const SizedBox(height: 6),
                Text('点击下方按钮添加', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mutedText,
                )),
              ],
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: models.length,
            itemBuilder: (ctx, i) => _buildModelCard(
              colors, models[i], activeModel == models[i], providerConfig, i),
          ),

        // 底部添加按钮
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Row(
            children: [
              // 已启用模型数
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 18, color: colors.accent),
                    const SizedBox(width: 6),
                    Text('${models.length}', style: TextStyle(
                      fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                      fontSize: 14, color: colors.mainText,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddModelDialog(context, colors, providerConfig),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('添加新模型', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 14, fontWeight: FontWeight.w600,
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 模型卡片
  // ═══════════════════════════════════════════
  Widget _buildModelCard(AppColors colors, String modelName, bool isActive,
      ProviderConfigProvider providerConfig, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? colors.accent.withOpacity(0.06) : colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? colors.accent : colors.border,
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: colors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.smart_toy_outlined, size: 20, color: colors.accent),
          ),
          const SizedBox(width: 12),
          // 名称 + 标签
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modelName, style: TextStyle(
                  fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                  fontSize: 14, color: colors.mainText,
                )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // 聊天标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.accentLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('聊天', style: TextStyle(
                        fontFamily: 'NotoSansSC', fontSize: 10, color: colors.accent,
                      )),
                    ),
                    const SizedBox(width: 6),
                    // 推理标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.accentWarm.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('推理', style: TextStyle(
                        fontFamily: 'NotoSansSC', fontSize: 10, color: colors.accentWarm,
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 切换按钮
          if (!isActive)
            GestureDetector(
              onTap: () {
                providerConfig.setActiveModel(widget.provider.id, modelName);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.accentLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('使用', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 12, color: colors.accent,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('当前', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
            ),
          const SizedBox(width: 4),
          // 删除
          GestureDetector(
            onTap: () => _removeModel(providerConfig, modelName),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close, size: 16, color: colors.mutedText),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 添加模型弹窗
  // ═══════════════════════════════════════════
  void _showAddModelDialog(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    _newModelCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('添加模型', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 17, color: colors.mainText,
              )),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _newModelCtrl,
                      autofocus: true,
                      style: TextStyle(
                        fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'deepseek-v4-flash / gpt-4o / claude-sonnet-4',
                        hintStyle: TextStyle(
                          fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mutedText,
                        ),
                        filled: true,
                        fillColor: colors.cardBase,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 预设快速选项
                    Row(
                      children: [
                        _modelChip(ctx, colors, 'deepseek-chat', setDialogState),
                        const SizedBox(width: 6),
                        _modelChip(ctx, colors, 'deepseek-reasoner', setDialogState),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _modelChip(ctx, colors, 'gpt-4o', setDialogState),
                        const SizedBox(width: 6),
                        _modelChip(ctx, colors, 'claude-sonnet-4', setDialogState),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('取消', style: TextStyle(
                    fontFamily: 'NotoSansSC', color: colors.secondaryText,
                  )),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _newModelCtrl.text.trim();
                    if (name.isNotEmpty) {
                      _addModel(providerConfig, name);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('添加', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                  )),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _modelChip(BuildContext ctx, AppColors colors, String name,
      void Function(void Function()) setDialogState) {
    return GestureDetector(
      onTap: () {
        setDialogState(() => _newModelCtrl.text = name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.accentLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(name, style: TextStyle(
          fontFamily: 'NotoSansSC', fontSize: 11, color: colors.accent,
        )),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 模型操作
  // ═══════════════════════════════════════════
  void _addModel(ProviderConfigProvider providerConfig, String modelName) {
    final newModels = List<String>.from(widget.provider.models)..add(modelName);
    // 如果是第一个模型，自动设为当前
    final newActive = widget.provider.activeModel.isEmpty ? modelName : widget.provider.activeModel;
    final updated = widget.provider.copyWith(models: newModels, activeModel: newActive);
    providerConfig.updateProvider(widget.provider.id, updated);
    if (mounted) setState(() {});
  }

  void _removeModel(ProviderConfigProvider providerConfig, String modelName) {
    final newModels = List<String>.from(widget.provider.models)..remove(modelName);
    String newActive = widget.provider.activeModel;
    if (newActive == modelName) {
      newActive = newModels.isNotEmpty ? newModels.first : '';
    }
    final updated = widget.provider.copyWith(models: newModels, activeModel: newActive);
    providerConfig.updateProvider(widget.provider.id, updated);
    if (mounted) setState(() {});
  }

  // ═══════════════════════════════════════════
  // 表单控件
  // ═══════════════════════════════════════════
  Widget _buildField(AppColors colors, String label, TextEditingController ctrl,
      {String? hint, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontFamily: 'NotoSansSC', fontSize: 11, color: colors.secondaryText,
          fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          enabled: enabled,
          style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText,
            ),
            filled: true,
            fillColor: enabled ? colors.cardSurface : colors.cardBase,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.accent),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API Key', style: TextStyle(
          fontFamily: 'NotoSansSC', fontSize: 11, color: colors.secondaryText,
          fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 8),
        TextField(
          controller: _keyCtrl,
          obscureText: !_showKey,
          style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
          ),
          decoration: InputDecoration(
            hintText: 'sk-...',
            hintStyle: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText,
            ),
            filled: true,
            fillColor: colors.cardSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.accent),
            ),
            contentPadding: const EdgeInsets.all(14),
            suffixIcon: IconButton(
              icon: Icon(
                _showKey ? Icons.visibility_off : Icons.visibility,
                color: colors.secondaryText, size: 20,
              ),
              onPressed: () => setState(() => _showKey = !_showKey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleField(AppColors colors, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mainText,
              )),
              Text(subtitle, style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.secondaryText,
              )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colors.accent,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 保存 & 删除
  // ═══════════════════════════════════════════
  void _saveProvider(BuildContext context, ProviderConfigProvider providerConfig) {
    final updatedProvider = widget.provider.copyWith(
      name: _nameCtrl.text,
      apiKey: _keyCtrl.text,
      apiHost: _hostCtrl.text,
      apiPath: _pathCtrl.text,
      useProxy: _useProxy,
    );
    providerConfig.updateProvider(widget.provider.id, updatedProvider);
    providerConfig.setActiveProvider(widget.provider.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('配置已保存'),
        backgroundColor: Theme.of(context).extension<AppColors>()!.accent,
      ),
    );
  }

  void _deleteProvider(BuildContext context, ProviderConfigProvider providerConfig) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).extension<AppColors>()!.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('删除服务商', style: TextStyle(
          fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
          color: Theme.of(ctx).extension<AppColors>()!.mainText,
        )),
        content: Text('确定删除 ${widget.provider.name} 吗？', style: TextStyle(
          fontFamily: 'NotoSansSC',
          color: Theme.of(ctx).extension<AppColors>()!.secondaryText,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(
              fontFamily: 'NotoSansSC',
              color: Theme.of(ctx).extension<AppColors>()!.secondaryText,
            )),
          ),
          TextButton(
            onPressed: () {
              providerConfig.removeProvider(widget.provider.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('删除', style: TextStyle(
              fontFamily: 'NotoSansSC', color: Colors.red[300],
            )),
          ),
        ],
      ),
    );
  }
}
