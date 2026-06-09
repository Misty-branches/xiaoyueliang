import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/diary_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/moon_icon.dart';
import 'hub_page.dart';

class WindowsillPage extends StatefulWidget {
  const WindowsillPage({super.key});

  @override
  State<WindowsillPage> createState() => _WindowsillPageState();
}

class _WindowsillPageState extends State<WindowsillPage> {
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryProvider>().loadEntries();
      context.read<TodoProvider>().loadTodos();
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 6) {
        _greeting = '夜深了，月亮还在陪着你';
      } else if (hour < 12) {
        _greeting = '早安，今天也是好天气';
      } else if (hour < 18) {
        _greeting = '午后时光，静静流淌';
      } else {
        _greeting = '夜幕降临，月光正好';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '小月亮',
                      style: TextStyle(
                        fontFamily: 'NotoSerifSC',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: colors.mainText,
                      ),
                    ),
                    // Settings icon removed from here — moved to hub page
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Frame with moon
              _buildMoonFrame(context, colors),
              const SizedBox(height: 30),
              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _greeting,
                  style: TextStyle(
                    fontFamily: 'NotoSerifSC',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 1,
                    color: colors.mainText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Data cards
              _buildTodayThoughtCard(context, colors),
              const SizedBox(height: 12),
              _buildTodoOverviewCard(context, colors),
              const SizedBox(height: 12),
              _buildRecentChatCard(context, colors),
              const SizedBox(height: 16),
              // Shortcut to hub
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HubPage()),
                    );
                  },
                  child: Row(
                    children: [
                      ThemeColors.moonIcon(context, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '月下窗',
                              style: TextStyle(
                                fontFamily: 'NotoSansSC',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: colors.mainText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '聊天 · 日记 · 书架 · 待办 · 回音墙',
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
                ),
              ),
              const SizedBox(height: 24),
              // Bottom decoration
              _buildBottomDecor(context, colors),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayThoughtCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<DiaryProvider>(
        builder: (context, diary, _) {
          final latest = diary.latestEntry;
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ThemeColors.starIcon(context, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '今日随想',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.mainText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  latest != null
                      ? '${latest.title}\n${latest.content.length > 60 ? '${latest.content.substring(0, 60)}...' : latest.content}'
                      : '还没有记录 🌙',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodoOverviewCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<TodoProvider>(
        builder: (context, todoProv, _) {
          final incompleteCount = todoProv.incompleteCount;
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ThemeColors.todoIcon(context, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '待办概览',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.mainText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  incompleteCount > 0
                      ? '$incompleteCount 项待完成'
                      : '今天都做完啦 ✅',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentChatCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          final lastMsg = chat.messages.isNotEmpty ? chat.messages.last : null;
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ThemeColors.chatIcon(context, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '最近聊天',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.mainText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lastMsg != null
                      ? '${lastMsg.content.length > 20 ? '${lastMsg.content.substring(0, 20)}...' : lastMsg.content}'
                      : '和小月亮说说话吧',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoonFrame(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: CustomPaint(
        size: const Size(double.infinity, 180),
        painter: _WindowFramePainter(borderColor: colors.border, accentColor: colors.accentWarm),
      ),
    );
  }

  Widget _buildBottomDecor(BuildContext context, AppColors colors) {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: _BottomLinePainter(color: colors.border),
      ),
    );
  }
}

class _WindowFramePainter extends CustomPainter {
  final Color borderColor;
  final Color accentColor;
  _WindowFramePainter({required this.borderColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Window frame
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(8),
    );
    canvas.drawRRect(frameRect, paint);

    // Cross in window
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - 2),
      paint,
    );
    canvas.drawLine(
      Offset(2, size.height / 2),
      Offset(size.width - 2, size.height / 2),
      paint,
    );

    // Moon
    final moonPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final moonCenter = Offset(size.width * 0.65, size.height * 0.35);
    final moonRadius = 28.0;
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);
    // Moon crescent effect
    final fillPaint = Paint()
      ..color = const Color(0xFFF2F0EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(moonCenter.dx + 10, moonCenter.dy - 8),
      moonRadius * 0.7,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomLinePainter extends CustomPainter {
  final Color color;
  _BottomLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Simple mountain/hill line art
    final path = Path();
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 4) {
      final y = size.height - 8 - math.sin(x * 0.02) * 6 - math.cos(x * 0.01) * 4;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8);

    // Stars
    for (int i = 0; i < 5; i++) {
      final sx = 20 + i * (size.width / 5);
      final sy = size.height - 16 - (i * 3) % 7;
      canvas.drawCircle(Offset(sx, sy), 1.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
