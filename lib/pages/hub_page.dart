import 'package:flutter/material.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';
import 'chat_page.dart';
import 'diary_page.dart';
import 'bookshelf_page.dart';
import 'todo_page.dart';
import 'echo_wall_page.dart';
import 'settings_page.dart';

class HubPage extends StatelessWidget {
  const HubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏
            _buildHeader(context, colors),
            const SizedBox(height: 24),
            // 房间网格
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今晚想待在哪个房间？',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 14,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRoomGrid(context, colors),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, colors),
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
          Text(
            '客厅',
            style: TextStyle(
              fontFamily: 'NotoSerifSC',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: colors.mainText,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 房间网格（2列布局）
  // ═══════════════════════════════════════════
  Widget _buildRoomGrid(BuildContext context, AppColors colors) {
    final rooms = [
      _RoomItem(
        icon: Icons.chat_bubble_outline,
        label: '聊天室',
        subLabel: 'CHAT',
        page: const ChatPage(),
      ),
      _RoomItem(
        icon: Icons.edit_outlined,
        label: '信件室',
        subLabel: 'LETTERS',
        page: const DiaryPage(),
      ),
      _RoomItem(
        icon: Icons.book_outlined,
        label: '书房',
        subLabel: 'BOOKS',
        page: const BookshelfPage(),
      ),
      _RoomItem(
        icon: Icons.check_circle_outline,
        label: '工作台',
        subLabel: 'TASKS',
        page: const TodoPage(),
      ),
      _RoomItem(
        icon: Icons.favorite_outline,
        label: '回忆馆',
        subLabel: 'MEMORIES',
        page: const EchoWallPage(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _buildRoomCard(context, colors, rooms[index]),
    );
  }

  Widget _buildRoomCard(BuildContext context, AppColors colors, _RoomItem room) {
    return GlassCard(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => room.page));
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(room.icon, size: 24, color: colors.accent),
          ),
          const SizedBox(height: 12),
          Text(
            room.label,
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colors.mainText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            room.subLabel,
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 10,
              letterSpacing: 1,
              color: colors.mutedText,
            ),
          ),
        ],
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
              _buildNavItem(context, colors, Icons.weekend, '客厅', true, () {}),
              _buildNavItem(context, colors, Icons.settings, '设置', false, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              }),
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

// ═══════════════════════════════════════════
// 房间数据模型
// ═══════════════════════════════════════════
class _RoomItem {
  final IconData icon;
  final String label;
  final String subLabel;
  final Widget page;

  _RoomItem({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.page,
  });
}
