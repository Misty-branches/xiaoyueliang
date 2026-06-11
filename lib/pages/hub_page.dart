import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/echo_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/moon_icon.dart';
import 'chat_page.dart';
import 'diary_page.dart';
import 'bookshelf_page.dart';
import 'todo_page.dart';
import 'echo_wall_page.dart';
import 'settings_page.dart';

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
      context.read<DiaryProvider>().loadEntries();
      context.read<TodoProvider>().loadTodos();
      context.read<BookshelfProvider>().loadBooks();
      context.read<EchoProvider>().loadEntries();
      context.read<ChatProvider>().load();
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
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: ThemeColors.backIcon(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      '月下窗',
                      style: TextStyle(
                        fontFamily: 'NotoSerifSC',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: 1,
                        color: colors.mainText,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    icon: ThemeColors.settingsIcon(context, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ThemeColors.moonIcon(context, size: 56),
            const SizedBox(height: 8),
            Text(
              '想要去哪里？',
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 14,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Consumer<ChatProvider>(
                      builder: (context, chat, _) {
                        final lastMsg = chat.messages.isNotEmpty ? chat.messages.last : null;
                        final subtitle = lastMsg != null
                            ? '最后消息 ${lastMsg.timestamp.hour}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}'
                            : '开始对话';
                        return _buildNavCard(
                          context,
                          colors,
                          icon: ThemeColors.chatIcon(context, size: 28),
                          title: '聊天',
                          desc: subtitle,
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const ChatPage())),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<DiaryProvider>(
                      builder: (context, diary, _) {
                        return _buildNavCard(
                          context,
                          colors,
                          icon: ThemeColors.diaryIcon(context, size: 28),
                          title: '日记',
                          desc: '${diary.entryCount} 篇记录',
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const DiaryPage())),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<BookshelfProvider>(
                      builder: (context, bookshelf, _) {
                        return _buildNavCard(
                          context,
                          colors,
                          icon: ThemeColors.bookIcon(context, size: 28),
                          title: '书架',
                          desc: '${bookshelf.bookCount} 本书',
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const BookshelfPage())),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<TodoProvider>(
                      builder: (context, todoProv, _) {
                        return _buildNavCard(
                          context,
                          colors,
                          icon: ThemeColors.todoIcon(context, size: 28),
                          title: '待办',
                          desc: '${todoProv.incompleteCount} 项待办',
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const TodoPage())),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Consumer<EchoProvider>(
                      builder: (context, echo, _) {
                        return _buildNavCard(
                          context,
                          colors,
                          icon: ThemeColors.echoIcon(context, size: 28),
                          title: '回音墙',
                          desc: '${echo.entryCount} 条回音',
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const EchoWallPage())),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context,
    AppColors colors, {
    required Widget icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.cardBase,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors.mainText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ThemeColors.arrowRightIcon(context),
        ],
      ),
    );
  }
}
