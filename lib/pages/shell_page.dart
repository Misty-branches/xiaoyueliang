import 'package:flutter/material.dart';
import '../widgets/theme_colors.dart';
import 'windowsill_page.dart';
import 'hub_page.dart';
import 'settings_page.dart';

/// 主页面 Shell — 管理底部三个 Tab 的切换
/// 用 IndexedStack 保持每个 Tab 的状态，不会重复创建页面
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0; // 0=窗台, 1=客厅, 2=设置

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          WindowsillPage(embedded: true),
          HubPage(embedded: true),
          SettingsPage(embedded: true),
        ],
      ),
      bottomNavigationBar: Container(
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
                _buildTab(colors, Icons.home, '窗台', 0),
                _buildTab(colors, Icons.weekend, '客厅', 1),
                _buildTab(colors, Icons.settings, '设置', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(AppColors colors, IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isActive ? colors.accent : colors.mutedText),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 10,
            color: isActive ? colors.accent : colors.mutedText,
          )),
        ],
      ),
    );
  }
}
