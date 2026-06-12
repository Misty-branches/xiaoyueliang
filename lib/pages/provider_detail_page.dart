import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_config_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';

class ProviderDetailPage extends StatefulWidget {
  final ApiProvider provider;

  const ProviderDetailPage({super.key, required this.provider});

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _hostCtrl;
  late TextEditingController _pathCtrl;
  late String _apiMode;
  late bool _useProxy;
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.provider.name);
    _keyCtrl = TextEditingController(text: widget.provider.apiKey);
    _hostCtrl = TextEditingController(text: widget.provider.apiHost);
    _pathCtrl = TextEditingController(text: widget.provider.apiPath);
    _apiMode = widget.provider.apiMode;
    _useProxy = widget.provider.useProxy;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _hostCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final providerConfig = context.watch<ProviderConfigProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏
            _buildHeader(context, colors, providerConfig),
            const SizedBox(height: 24),
            // 表单内容
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名称
                    _buildField(colors, '名称', _nameCtrl),
                    const SizedBox(height: 20),
                    // API 模式
                    _buildDropdownField(colors, 'API 模式', _apiMode, [
                      const DropdownMenuItem(value: 'openai', child: Text('OpenAI API 兼容')),
                      const DropdownMenuItem(value: 'custom', child: Text('自定义')),
                    ], (v) => setState(() => _apiMode = v!)),
                    const SizedBox(height: 20),
                    // API 密钥
                    _buildKeyField(context, colors),
                    const SizedBox(height: 20),
                    // API 主机
                    _buildField(colors, 'API 主机', _hostCtrl, hint: 'https://api.openai.com'),
                    const SizedBox(height: 20),
                    // API 路径
                    _buildField(colors, 'API 路径', _pathCtrl, hint: '/v1/chat/completions'),
                    const SizedBox(height: 20),
                    // 网络兼容性
                    _buildToggleField(colors, '改善网络兼容性', '启用代理和重试机制', _useProxy, 
                      (v) => setState(() => _useProxy = v)),
                    const SizedBox(height: 24),
                    // 配置预览
                    _buildPreview(colors),
                    const SizedBox(height: 32),
                    // 保存按钮
                    _buildSaveButton(context, colors, providerConfig),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 顶部状态栏
  // ═══════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: ThemeColors.backIcon(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const Spacer(),
          Text(
            _nameCtrl.text,
            style: TextStyle(
              fontFamily: 'NotoSerifSC',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: colors.mainText,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _deleteProvider(context, providerConfig),
            icon: Icon(Icons.delete_outline, color: Colors.red[300]),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 输入字段
  // ═══════════════════════════════════════════
  Widget _buildField(AppColors colors, String label, TextEditingController ctrl, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 11,
            color: colors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 14,
            color: colors.mainText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 14,
              color: colors.mutedText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.accent),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 下拉选择字段
  // ═══════════════════════════════════════════
  Widget _buildDropdownField(
    AppColors colors, 
    String label, 
    String value, 
    List<DropdownMenuItem<String>> items, 
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 11,
            color: colors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 14,
            color: colors.mainText,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
          dropdownColor: colors.cardSurface,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // API 密钥字段
  // ═══════════════════════════════════════════
  Widget _buildKeyField(BuildContext context, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API 密钥',
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 11,
            color: colors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keyCtrl,
                obscureText: !_showKey,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 14,
                  color: colors.mainText,
                ),
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  hintStyle: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.mutedText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.accent),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _showKey ? Icons.visibility_off : Icons.visibility,
                color: colors.secondaryText,
              ),
              onPressed: () => setState(() => _showKey = !_showKey),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('检查功能需要后端支持'),
                    backgroundColor: colors.accent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '检查',
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 开关字段
  // ═══════════════════════════════════════════
  Widget _buildToggleField(AppColors colors, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 13,
                  color: colors.mainText,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 11,
                  color: colors.secondaryText,
                ),
              ),
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
  // 配置预览
  // ═══════════════════════════════════════════
  Widget _buildPreview(AppColors colors) {
    final host = _hostCtrl.text;
    final path = _pathCtrl.text;
    final preview = host + path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前配置预览',
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 11,
            color: colors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.accentLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            preview.isEmpty ? '-' : preview,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: colors.mainText,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 保存按钮
  // ═══════════════════════════════════════════
  Widget _buildSaveButton(BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _saveProvider(context, providerConfig),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '保存',
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 删除服务商
  // ═══════════════════════════════════════════
  void _deleteProvider(BuildContext context, ProviderConfigProvider providerConfig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确定删除'),
        content: Text('确定要删除 ${_nameCtrl.text} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              providerConfig.removeProvider(widget.provider.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 保存服务商
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
        content: const Text('服务商配置已保存'),
        backgroundColor: Theme.of(context).extension<AppColors>()!.accent,
      ),
    );
    
    Navigator.pop(context);
  }
}
