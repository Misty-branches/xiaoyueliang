import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/theme_colors.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── 顶部 ──
            _Header(colors: colors),
            // ── 会话列表 ──
            Expanded(
              child: chat.conversations.isEmpty
                  ? _EmptyState(colors: colors, text: '还没有对话\n点击右下角开始第一句')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: chat.conversations.length,
                      itemBuilder: (ctx, i) {
                        final conv = chat.conversations[i];
                        return _ConversationCard(
                          colors: colors,
                          title: conv.title,
                          messageCount: conv.messageCount,
                          modelName: conv.modelName,
                          updatedAt: conv.updatedAt,
                          isActive: conv.id == chat.activeConversationId,
                          onTap: () => chat.switchConversation(conv.id),
                        );
                      },
                    ),
            ),
            // ── 底部导航 ──

          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Header
// ═══════════════════════════════════════════════
class _Header extends StatelessWidget {
  final AppColors colors;
  const _Header({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.mainText),
          ),
          const Spacer(),
          Column(
            children: [
              Text('聊天室', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('Chat · 和我说说话', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
              )),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Conversation Card
// ═══════════════════════════════════════════════
class _ConversationCard extends StatelessWidget {
  final AppColors colors;
  final String title;
  final int messageCount;
  final String modelName;
  final DateTime updatedAt;
  final bool isActive;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.colors,
    required this.title,
    required this.messageCount,
    required this.modelName,
    required this.updatedAt,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? colors.accent.withOpacity(0.08) : colors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? colors.accent : colors.border,
            width: isActive ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: colors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.chat_bubble_outline, color: colors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                    fontSize: 15, color: colors.mainText,
                  )),
                  const SizedBox(height: 4),
                  Text('$messageCount 条消息 · $modelName', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 12, color: colors.secondaryText,
                  )),
                ],
              ),
            ),
            Text(_formatTime(updatedAt), style: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
            )),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final String text;
  const _EmptyState({required this.colors, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText, height: 1.5,
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Bottom Nav
// ═══════════════════════════════════════════════
Widget _BottomNav({required AppColors colors, required BuildContext context}) {
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
            _NavItem(colors: colors, icon: Icons.home, label: '窗台', active: false, onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
            _NavItem(colors: colors, icon: Icons.weekend, label: '客厅', active: false, onTap: () => Navigator.pop(context)),
            _NavItem(colors: colors, icon: Icons.settings, label: '设置', active: false, onTap: () {}),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.colors, required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: active ? colors.accent : colors.mutedText),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'NotoSansSC', fontSize: 10, color: active ? colors.accent : colors.mutedText)),
        ],
      ),
    );
  }
}
