import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/provider_config_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _promptCtrl;

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatProvider>();
    _promptCtrl = TextEditingController(text: chat.systemPrompt);
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = context.watch<ThemeProvider>();
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: ThemeColors.backIcon(context),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '设置',
          style: TextStyle(
            fontFamily: 'NotoSerifSC',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 1,
            color: colors.mainText,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // API 接入服务
          _buildSectionTitle(context, colors, 'SERVICE · API 接入'),
          const SizedBox(height: 8),
          _buildProviderList(context, colors),
          const SizedBox(height: 24),

          // 外观
          _buildSectionTitle(context, colors, '外观'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ThemeColors.sunIcon(context, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '夜间模式',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.mainText,
                    ),
                  ),
                ),
                Switch(
                  value: theme.isDark,
                  onChanged: (v) => theme.setDark(v),
                  activeColor: colors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 能力
          _buildSectionTitle(context, colors, 'ABILITY · 能力'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '自定义 Prompt',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _promptCtrl,
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.mainText,
                    height: 1.5,
                  ),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: '你是月下窗的AI助手…',
                    hintStyle: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      chat.setSystemPrompt(_promptCtrl.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('System Prompt 已保存'),
                          backgroundColor: colors.accent,
                        ),
                      );
                    },
                    child: Text(
                      '保存',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 14,
                        color: colors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 数据
          _buildSectionTitle(context, colors, 'DATA · 数据'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildSettingRow(
                  context,
                  colors,
                  icon: Icons.backup_outlined,
                  title: '备份与恢复',
                  subtitle: '同步日记、待办和收藏',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('备份功能开发中...'),
                        backgroundColor: colors.accent,
                      ),
                    );
                  },
                ),
                _buildSettingRow(
                  context,
                  colors,
                  icon: Icons.health_and_safety_outlined,
                  title: '本地体检',
                  subtitle: '查看本机数据体积',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('体检功能开发中...'),
                        backgroundColor: colors.accent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 关于
          _buildSectionTitle(context, colors, 'ABOUT · 关于'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildSettingRow(
                  context,
                  colors,
                  icon: Icons.help_outline,
                  title: '使用文档',
                  subtitle: '使用指南与功能说明',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('文档功能开发中...'),
                        backgroundColor: colors.accent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, AppColors colors, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'NotoSansSC',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: colors.mainText,
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    AppColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.secondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.mainText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 12,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, AppColors colors) {
    return Consumer<ProviderConfigProvider>(
      builder: (context, providerConfig, _) {
        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              ...providerConfig.providers.map((provider) {
                final isActive = provider.id == providerConfig.activeProviderId;
                final icon = _getProviderIcon(provider.id);
                final status = isActive ? '使用中' : (provider.apiKey.isNotEmpty ? '已配置' : '未配置');
                
                return InkWell(
                  onTap: () => _openProviderDetail(context, colors, provider),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isActive ? colors.accent.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? colors.accent : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(icon, style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.name,
                                style: TextStyle(
                                  fontFamily: 'NotoSansSC',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: colors.mainText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$status · ${provider.models.length} 个模型',
                                style: TextStyle(
                                  fontFamily: 'NotoSansSC',
                                  fontSize: 11,
                                  color: colors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20, color: colors.secondaryText),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              // 添加服务商按钮
              InkWell(
                onTap: () => _addProvider(context, colors),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: colors.accent),
                      const SizedBox(width: 8),
                      Text(
                        '添加服务商',
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 13,
                          color: colors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getProviderIcon(String id) {
    switch (id) {
      case 'openai':
        return '🤖';
      case 'claude':
        return '🧠';
      case 'custom':
        return '🔧';
      default:
        return '🔌';
    }
  }

  void _openProviderDetail(BuildContext context, AppColors colors, ApiProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderDetailPage(provider: provider),
      ),
    );
  }

  void _addProvider(BuildContext context, AppColors colors) {
    final providerConfig = context.read<ProviderConfigProvider>();
    final newProvider = ApiProvider(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: '新服务商',
    );
    providerConfig.addProvider(newProvider);
    _openProviderDetail(context, colors, newProvider);
  }
}

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
      appBar: AppBar(
        backgroundColor: colors.cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: ThemeColors.backIcon(context),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _nameCtrl.text,
          style: TextStyle(
            fontFamily: 'NotoSerifSC',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 1,
            color: colors.mainText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[300]),
            onPressed: () => _deleteProvider(context, providerConfig),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // 名称
          _buildField(context, colors, '名称', _nameCtrl),
          const SizedBox(height: 16),

          // API 模式
          _buildDropdownField(context, colors, 'API 模式', _apiMode, [
            const DropdownMenuItem(value: 'openai', child: Text('OpenAI API 兼容')),
            const DropdownMenuItem(value: 'custom', child: Text('自定义')),
          ], (v) => setState(() => _apiMode = v!)),
          const SizedBox(height: 16),

          // API 密钥
          _buildKeyField(context, colors),
          const SizedBox(height: 16),

          // API 主机
          _buildField(context, colors, 'API 主机', _hostCtrl, hint: 'https://api.openai.com'),
          const SizedBox(height: 16),

          // API 路径
          _buildField(context, colors, 'API 路径', _pathCtrl, hint: '/v1/chat/completions'),
          const SizedBox(height: 16),

          // 网络兼容性
          _buildToggleField(context, colors, '改善网络兼容性', '启用代理和重试机制', _useProxy, 
            (v) => setState(() => _useProxy = v)),
          const SizedBox(height: 24),

          // 配置预览
          _buildPreview(context, colors),
          const SizedBox(height: 24),

          // 保存按钮
          ElevatedButton(
            onPressed: () => _saveProvider(context, providerConfig),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context, AppColors colors, String label, TextEditingController ctrl, {String? hint}) {
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
        const SizedBox(height: 6),
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
              color: colors.secondaryText,
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
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context, AppColors colors, String label, String value, List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
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
        const SizedBox(height: 6),
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
            contentPadding: const EdgeInsets.all(12),
          ),
          dropdownColor: colors.cardSurface,
        ),
      ],
    );
  }

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
        const SizedBox(height: 6),
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
                    color: colors.secondaryText,
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
                  contentPadding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildToggleField(BuildContext context, AppColors colors, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
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
              const SizedBox(height: 2),
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

  Widget _buildPreview(BuildContext context, AppColors colors) {
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.accent.withOpacity(0.1),
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
