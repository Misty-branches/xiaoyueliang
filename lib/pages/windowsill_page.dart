import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_message_provider.dart';
import '../providers/shared_goals_provider.dart';
import '../providers/recent_activity_provider.dart';
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
  int _dayCount = 7;

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
              const SizedBox(height: 16),
              // 顶部状态栏
              _buildHeader(context, colors),
              const SizedBox(height: 20),
              // 欢迎卡片
              _buildWelcomeCard(context, colors),
              const SizedBox(height: 16),
              // 快捷入口网格
              _buildQuickAccessGrid(context, colors),
              const SizedBox(height: 16),
              // 今日寄语
              _buildDailyMessageCard(context, colors),
              const SizedBox(height: 12),
              // 共同目标
              _buildSharedGoalsCard(context, colors),
              const SizedBox(height: 12),
              // 最近活动
              _buildRecentActivityCard(context, colors),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomTabBar(context, colors),
    );
  }

  Widget _buildHeader(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ThemeColors.moonIcon(context, size: 28),
              const SizedBox(width: 10),
              Text(
                '月下窗',
                style: TextStyle(
                  fontFamily: 'NotoSerifSC',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: colors.mainText,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$_dayCount',
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'day',
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 10,
                  color: colors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MOON WINDOW · OUR HOME',
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 10,
                letterSpacing: 2,
                color: colors.mutedText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '我们的家',
              style: TextStyle(
                fontFamily: 'NotoSerifSC',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: colors.mainText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '听听音乐，看看日历，逛逛工具箱',
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 14,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HubPage()),
                );
              },
              child: Row(
                children: [
                  Text(
                    '进入客厅',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: colors.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, AppColors colors) {
    final items = [
      _QuickAccessItem(icon: Icons.music_note, label: '音乐', onTap: () {}),
      _QuickAccessItem(icon: Icons.calendar_today, label: '日历', onTap: () {}),
      _QuickAccessItem(icon: Icons.shopping_cart, label: '购物', onTap: () {}),
      _QuickAccessItem(icon: Icons.more_horiz, label: '更多', onTap: () {}),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
        children: items.map((item) => _buildQuickAccessItem(context, colors, item)).toList(),
      ),
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, AppColors colors, _QuickAccessItem item) {
    return GlassCard(
      onTap: item.onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: colors.accent),
          const SizedBox(width: 10),
          Text(
            item.label,
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 14,
              color: colors.mainText,
            ),
          ),
        ],
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.hasMessage
                          ? '${provider.message!.generatedAt.month}/${provider.message!.generatedAt.day}, ${provider.message!.generatedAt.year}'
                          : '${DateTime.now().month}/${DateTime.now().day}, ${DateTime.now().year}',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 11,
                        color: colors.mutedText,
                      ),
                    ),
                    Text(
                      '展开全文 ▾',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 11,
                        color: colors.accent,
                      ),
                    ),
                  ],
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
                                      color: colors.mutedText,
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
              _buildTabItem(context, colors, Icons.home, '窗台', true),
              _buildTabItem(context, colors, Icons.living, '客厅', false),
              _buildTabItem(context, colors, Icons.settings, '设置', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, AppColors colors, IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {
        // TODO: 切换标签页
      },
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

class _QuickAccessItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
