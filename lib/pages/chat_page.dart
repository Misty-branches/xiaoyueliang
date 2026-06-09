import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/chat_bubble.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages().then((_) {
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: ThemeColors.backIcon(context),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.cardBase,
                border: Border.all(color: colors.accent, width: 1.5),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(18, 18),
                  painter: _MiniMoonFillPainter(color: colors.accent),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小月亮',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors.mainText,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '在线',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 10,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: ThemeColors.trashIcon(context),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('清空聊天'),
                  content: const Text('确定要清空所有聊天记录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ChatProvider>().clearMessages();
                        Navigator.pop(ctx);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                if (chat.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeColors.moonIcon(context, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          '和小月亮说说话吧 🌙',
                          style: TextStyle(
                            fontFamily: 'NotoSansSC',
                            fontSize: 14,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chat.messages[index];
                    return ChatBubble(
                      message: msg.content,
                      isUser: msg.role == 'user',
                      time: DateFormat('HH:mm').format(msg.timestamp),
                    );
                  },
                );
              },
            ),
          ),
          if (context.watch<ChatProvider>().isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                height: 20,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                    ),
                  ),
                ),
              ),
            ),
          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: colors.cardSurface,
              border: Border(
                top: BorderSide(color: colors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.cardBase,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 13,
                        color: colors.mainText,
                      ),
                      decoration: InputDecoration(
                        hintText: '说点什么...',
                        hintStyle: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 13,
                          color: colors.secondaryText,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final chat = context.read<ChatProvider>();
    if (chat.apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先在设置中配置 API Key'),
          backgroundColor: Theme.of(context).extension<AppColors>()!.accent,
        ),
      );
      return;
    }
    _controller.clear();
    chat.sendMessage(text.trim()).then((_) => _scrollToBottom());
  }
}

class _MiniMoonFillPainter extends CustomPainter {
  final Color color;
  _MiniMoonFillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2 - 1, paint);
    final fillPaint = Paint()
      ..color = const Color(0xFFF2F0EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx + 3, center.dy - 2),
      size.width / 2 - 3,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
