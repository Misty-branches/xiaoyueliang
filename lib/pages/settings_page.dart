import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/provider_config_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';
import 'provider_detail_page.dart';
import 'hub_page.dart';

class SettingsPage extends StatelessWidget {
  final bool embedded;
  const SettingsPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final themeProvider = context.watch<ThemeProvider>();
    final providerConfig = context.watch<ProviderConfigProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏
            _buildHeader(context, colors),
            const SizedBox(height: 24),
            // 设置列表
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // API 接入
                    _buildSectionTitle(colors, 'SERVICE · API 接入'),
                    const SizedBox(height: 12),
                    _buildProviderList(context, colors, providerConfig),
                    const SizedBox(height: 24),
                    // 能力
                    _buildSectionTitle(colors, 'ABILITY · 能力'),
                    const SizedBox(height: 12),
                    _buildAbilitySection(context, colors),
                    const SizedBox(height: 24),
                    // 数据
                    _buildSectionTitle(colors, 'DATA · 数据'),
                    const SizedBox(height: 12),
                    _buildDataSection(context, colors),
                    const SizedBox(height: 24),
                    // 外观
                    _buildSectionTitle(colors, '外观'),
                    const SizedBox(height: 12),
                    _buildAppearanceSection(context, colors, themeProvider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: embedded ? null : _buildBottomNav(context, colors),
    );
  }

  // ═══════════════════════════════════════════
  // 顶部状态栏
  // ═══════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppColors colors) {
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
          Column(
            children: [
              Text(
                '设置',
                style: TextStyle(
                  fontFamily: 'NotoSerifSC',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: colors.mainText,
                ),
              ),
              Text(
                'Config · 配置你的小月亮',
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 11,
                  color: colors.mutedText,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 章节标题
  // ═══════════════════════════════════════════
  Widget _buildSectionTitle(AppColors colors, String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'NotoSansSC',
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: colors.mutedText,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // API 接入（服务商列表）
  // ═══════════════════════════════════════════
  Widget _buildProviderList(
    BuildContext context, 
    AppColors colors, 
    ProviderConfigProvider providerConfig,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...providerConfig.providers.map((provider) {
            final isActive = provider.id == providerConfig.activeProviderId;
            final icon = _getProviderIcon(provider.id);
            final status = isActive ? '使用中' : (provider.apiKey.isNotEmpty ? '已配置' : '未配置');
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProviderDetailPage(provider: provider),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? colors.accent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? colors.accent : colors.border,
                      width: isActive ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.accentLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
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
              ),
            );
          }),
          const SizedBox(height: 8),
          // 添加服务商按钮
          InkWell(
            onTap: () {
              final newProvider = ApiProvider(
                id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                name: '新服务商',
              );
              providerConfig.addProvider(newProvider);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProviderDetailPage(provider: newProvider),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
  }

  String _getProviderIcon(String id) {
    switch (id) {
      case 'openai': return '🤖';
      case 'claude': return '🧠';
      case 'custom': return '🔧';
      default: return '🔌';
    }
  }

  // ═══════════════════════════════════════════
  // 能力设置
  // ═══════════════════════════════════════════
  Widget _buildAbilitySection(BuildContext context, AppColors colors) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingRow(
            context,
            colors,
            icon: Icons.edit_outlined,
            title: '自定义 Prompt',
            subtitle: '设置助手语气和风格',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 数据设置
  // ═══════════════════════════════════════════
  Widget _buildDataSection(BuildContext context, AppColors colors) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingRow(
            context,
            colors,
            icon: Icons.backup_outlined,
            title: '备份与恢复',
            subtitle: '同步日记、待办和收藏',
            onTap: () {},
          ),
          _buildSettingRow(
            context,
            colors,
            icon: Icons.health_and_safety_outlined,
            title: '本地体检',
            subtitle: '查看本机数据体积',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 外观设置
  // ═══════════════════════════════════════════
  Widget _buildAppearanceSection(
    BuildContext context, 
    AppColors colors, 
    ThemeProvider themeProvider,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.dark_mode_outlined, size: 22, color: colors.secondaryText),
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
            value: themeProvider.isDark,
            onChanged: (v) => themeProvider.setDark(v),
            activeColor: colors.accent,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 设置行
  // ═══════════════════════════════════════════
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
            Icon(Icons.chevron_right, size: 20, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 底部导航栏
  // ═══════════════════════════════════════════
  Widget _buildBottomNav(BuildContext context, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, colors, Icons.home, '窗台', false, () {
                Navigator.pop(context);
              }),
              _buildNavItem(context, colors, Icons.weekend, '客厅', false, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HubPage()));
              }),
              _buildNavItem(context, colors, Icons.settings, '设置', true, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, 
    AppColors colors, 
    IconData icon, 
    String label, 
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isActive ? colors.accent : colors.mutedText),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 10,
              color: isActive ? colors.accent : colors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
