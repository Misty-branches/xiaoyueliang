import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/daily_message_provider.dart';
import '../providers/shared_goals_provider.dart';
import '../providers/recent_activity_provider.dart';
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
      context.read<DailyMessageProvider>().loadMessage();
      context.read<SharedGoalsProvider>().loadGoals();
      context.read<RecentActivityProvider>().loadActivities();
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
              // Data cards - 今日寄语
              _buildDailyMessageCard(context, colors),
              const SizedBox(height: 12),
              // 共同目标
              _buildSharedGoalsCard(context, colors),
              const SizedBox(height: 12),
              // 最近活动
              _buildRecentActivityCard(context, colors),
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

  Widget _buildDailyMessageCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<DailyMessageProvider>(
        builder: (context, provider, _) {
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined, size: 18, color: colors.accentWarm),
                    const SizedBox(width: 8),
                    Text(
                      '今日寄语',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.mainText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'From Hermes',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 11,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  provider.hasMessage
                      ? provider.message!.message
                      : '今天也要开开心心的呀 ☀️',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.hasMessage
                      ? '${provider.message!.generatedAt.month}/${provider.message!.generatedAt.day}, ${provider.message!.generatedAt.year}'
                      : '${DateTime.now().month}/${DateTime.now().day}, ${DateTime.now().year}',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 11,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSharedGoalsCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<SharedGoalsProvider>(
        builder: (context, provider, _) {
          final goal = provider.activeGoals.isNotEmpty ? provider.activeGoals.first : null;
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18, color: colors.accent),
                    const SizedBox(width: 8),
                    Text(
                      '共同目标',
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
                if (goal != null) ...[
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.mainText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: goal.progressPercent,
                            backgroundColor: colors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${goal.progress} / ${goal.total}',
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    '暂无共同目标',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<RecentActivityProvider>(
        builder: (context, provider, _) {
          final activities = provider.recentActivities;
          return GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, size: 18, color: colors.accent),
                    const SizedBox(width: 8),
                    Text(
                      '最近活动',
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
                if (activities.isEmpty) ...[
                  Text(
                    '暂无活动记录',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                  ),
                ] else ...[
                  ...activities.map((activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          decoration: BoxDecoration(
                            color: activity.type == 'realtime' 
                                ? colors.accent 
                                : colors.accentWarm,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.text,
                                style: TextStyle(
                                  fontFamily: 'NotoSansSC',
                                  fontSize: 13,
                                  color: colors.mainText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: activity.type == 'realtime'
                                          ? colors.accent.withOpacity(0.1)
                                          : colors.accentWarm.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      activity.type == 'realtime' ? '实时' : '定时',
                                      style: TextStyle(
                                        fontFamily: 'NotoSansSC',
                                        fontSize: 10,
                                        color: activity.type == 'realtime'
                                            ? colors.accent
                                            : colors.accentWarm,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    activity.timeStr,
                                    style: TextStyle(
                                      fontFamily: 'NotoSansSC',
                                      fontSize: 11,
                                      color: colors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
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
