import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _promptCtrl;
  late String _selectedModel;

  final List<String> _models = [
    'gpt-3.5-turbo',
    'gpt-4',
    'gpt-4-turbo',
    'gpt-4o',
  ];

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatProvider>();
    _apiKeyCtrl = TextEditingController(text: chat.apiKey);
    _promptCtrl = TextEditingController(text: chat.systemPrompt);
    _selectedModel = chat.model;
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
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
          // Theme section
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

          // API section
          _buildSectionTitle(context, colors, 'AI 配置'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Key',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyCtrl,
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.mainText,
                  ),
                  obscureText: true,
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
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.save_outlined,
                          size: 18, color: colors.accent),
                      onPressed: () {
                        chat.setApiKey(_apiKeyCtrl.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('API Key 已保存'),
                            backgroundColor: colors.accent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '模型选择',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedModel,
                  items: _models
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: TextStyle(
                                fontFamily: 'NotoSansSC',
                                fontSize: 14,
                                color: colors.mainText,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedModel = v);
                      chat.setModel(v);
                    }
                  },
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
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Prompt',
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

          // About
          _buildSectionTitle(context, colors, '关于'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ThemeColors.moonIcon(context, size: 32),
                    const SizedBox(width: 10),
                    Text(
                      '小月亮 v1.0.0',
                      style: TextStyle(
                        fontFamily: 'NotoSerifSC',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: colors.mainText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '月下窗，温暖陪伴',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
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
}
