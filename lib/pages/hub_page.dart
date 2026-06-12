import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/letter_provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/echo_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/glass_card.dart';
import 'chat_page.dart';
import 'diary_page.dart';
import 'bookshelf_page.dart';
import 'todo_page.dart';
import 'echo_wall_page.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().load();
      context.read<LetterProvider>().loadLetters();
      context.read<BookshelfProvider>().loadBooks();
      context.read<TodoProvider>().loadTodos();
      context.read<EchoProvider>().loadEntries();
    });
  }

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
            const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomTabBar(context, colors),
    );
  }

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
          const SizedBox(width: 36), // 占位，保持标题居中
        ],
      ),
    );
  }

  Widget _buildRoomGrid(BuildContext context, AppColors colors) {
    final rooms = [
      _RoomItem(
        icon: Icons.chat_bubble_outline,
        label: '聊天室',
        subLabel: 'CHAT',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
      ),
      _RoomItem(
        icon: Icons.edit_outlined,
        label: '信件室',
        subLabel: 'LETTERS',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryPage())),
      ),
      _RoomItem(
        icon: Icons.book_outlined,
        label: '书房',
        subLabel: 'BOOKS',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookshelfPage())),
      ),
      _RoomItem(
        icon: Icons.check_circle_outline,
        label: '工作台',
        subLabel: 'TASKS',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodoPage())),
      ),
      _RoomItem(
        icon: Icons.favorite_outline,
        label: '回忆馆',
        subLabel: 'MEMORIES',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EchoWallPage())),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: rooms.map((room) => _buildRoomCard(context, colors, room)).toList(),
    );
  }

  Widget _buildRoomCard(BuildContext context, AppColors colors, _RoomItem room) {
    return GlassCard(
      onTap: room.onTap,
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
            child: Icon(
              room.icon,
              size: 24,
              color: colors.accent,
            ),
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

  Widget _buildBottomTabBar(BuildContext context, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(
          top: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(context, colors, Icons.home, '窗台', false, () => Navigator.pop(context)),
              _buildTabItem(context, colors, Icons.weekend, '客厅', true, () {}),
              _buildTabItem(context, colors, Icons.settings, '设置', false, () {
                // TODO: 导航到设置页
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, AppColors colors, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? colors.accent : colors.mutedText,
          ),
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

class _RoomItem {
  final IconData icon;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  _RoomItem({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });
}
