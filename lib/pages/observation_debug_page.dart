import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';

/// 观察层调试面板
///
/// 只读页面，从 SharedPreferences 读取 'moon_latest_observation'
/// 并以卡片网格形式展示观察层最新快照的全部数据。
class ObservationDebugPage extends StatefulWidget {
  const ObservationDebugPage({super.key});

  @override
  State<ObservationDebugPage> createState() => _ObservationDebugPageState();
}

class _ObservationDebugPageState extends State<ObservationDebugPage> {
  static const String _storageKey = 'moon_latest_observation';

  ObservationSnapshot? _snapshot;
  Map<String, dynamic>? _rawJson;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadObservation();
  }

  Future<void> _loadObservation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        setState(() {
          _snapshot = ObservationSnapshot.fromJson(json);
          _rawJson = json;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('[ObservationDebugPage] 加载失败: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colors),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _snapshot == null
                      ? _buildEmptyState(colors)
                      : _buildContent(context, colors),
            ),
            if (_snapshot != null) _buildBottomButton(context, colors),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 顶部标题栏
  // ═══════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: MoonIcon.backIcon(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                '观察层调试',
                style: TextStyle(
                  fontFamily: 'NotoSerifSC',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: colors.mainText,
                ),
              ),
              Text(
                'OBSERVATION DEBUG',
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
  // 空状态
  // ═══════════════════════════════════════════
  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_off_outlined,
              size: 48, color: colors.mutedText),
          const SizedBox(height: 16),
          Text(
            '暂无观察数据',
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 16,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '等待 ObservationProvider 生成快照',
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 13,
              color: colors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 内容区
  // ═══════════════════════════════════════════
  Widget _buildContent(BuildContext context, AppColors colors) {
    final snapshot = _snapshot!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息
          _buildInfoCard(context, colors, snapshot),
          const SizedBox(height: 12),
          // 兴趣话题
          _buildInterestsCard(context, colors, snapshot),
          const SizedBox(height: 12),
          // 情绪状态
          _buildMoodCard(context, colors, snapshot),
          const SizedBox(height: 12),
          // 活跃项目
          _buildProjectsCard(context, colors, snapshot),
          const SizedBox(height: 12),
          // 阅读进度
          _buildReadingCard(context, colors, snapshot),
          const SizedBox(height: 12),
          // 行为模式
          _buildBehaviorCard(context, colors, snapshot),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片：基本信息
  // ═══════════════════════════════════════════
  Widget _buildInfoCard(
    BuildContext context,
    AppColors colors,
    ObservationSnapshot snapshot,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.info_outline, '基本信息'),
          const Divider(height: 24),
          _buildInfoRow(colors, '快照 ID', snapshot.id),
          const SizedBox(height: 8),
          _buildInfoRow(
              colors, '生成时间', _formatDateTime(snapshot.date)),
          const SizedBox(height: 8),
          _buildInfoRow(
            colors,
            '数据来源',
            '由 ObservationProvider 从聊天消息和日记中提炼',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片：兴趣话题
  // ═══════════════════════════════════════════
  Widget _buildInterestsCard(
    BuildContext context,
    AppColors colors,
    ObservationSnapshot snapshot,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.trending_up, '兴趣话题'),
          const Divider(height: 24),
          if (snapshot.interests.isEmpty)
            _buildEmptyRow(colors, '暂无兴趣话题')
          else
            ...snapshot.interests.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.topic,
                              style: TextStyle(
                                fontFamily: 'NotoSansSC',
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: colors.mainText,
                              ),
                            ),
                          ),
                          _buildSourceTypeBadge(colors, item.sourceType),
                          const SizedBox(width: 8),
                          Text(
                            '${(item.score * 100).toInt()}%',
                            style: TextStyle(
                              fontFamily: 'NotoSansSC',
                              fontSize: 12,
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.score,
                          backgroundColor: colors.accentLight,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.accent),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '最近提及: ${_formatDateTime(item.lastMention)}',
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 10,
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片：情绪状态
  // ═══════════════════════════════════════════
  Widget _buildMoodCard(
    BuildContext context,
    AppColors colors,
    ObservationSnapshot snapshot,
  ) {
    final moodColors = _getMoodColors(snapshot.mood.mood);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.emoji_emotions_outlined, '情绪状态'),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: moodColors.$1.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: moodColors.$1, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMoodIcon(snapshot.mood.mood),
                      size: 16,
                      color: moodColors.$1,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getMoodLabel(snapshot.mood.mood),
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: moodColors.$1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildSourceTypeBadge(colors, snapshot.mood.sourceType),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '置信度',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 10,
                      color: colors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(snapshot.mood.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: moodColors.$1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片：活跃项目
  // ═══════════════════════════════════════════
  Widget _buildProjectsCard(
    BuildContext context,
    AppColors colors,
    ObservationSnapshot snapshot,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.rocket_launch_outlined, '活跃项目'),
          const Divider(height: 24),
          if (snapshot.activeProjects.isEmpty)
            _buildEmptyRow(colors, '暂无活跃项目')
          else
            ...snapshot.activeProjects.map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(project.status, colors),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          project.name,
                          style: TextStyle(
                            fontFamily: 'NotoSansSC',
                            fontSize: 13,
                            color: colors.mainText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.accentLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusLabel(project.status),
                          style: TextStyle(
                            fontFamily: 'NotoSansSC',
                            fontSize: 10,
                            color: colors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateTime(project.lastUpdate),
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 10,
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片：阅读进度
  // ═══════════════════════════════════════════
  Widget _buildReadingCard(
    BuildContext context,
    AppColors colors,
    ObservationSnapshot snapshot,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.menu_book_outlined, '阅读进度'),
          const Divider(height: 24),
          if (snapshot.reading == null)
            _buildEmptyRow(colors, '暂无')
          else
            ...() {
              final r = snapshot.reading!;
              return [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.book,
                            style: TextStyle(
                              fontFamily: 'NotoSansSC',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: colors.mainText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: r.progress / 100.0,
                                    backgroundColor: colors.accentLight,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.accentWarm),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${r.progress}%',
                                style: TextStyle(
                                  fontFamily: 'NotoSansSC',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: colors.accentWarm,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '讨论次数: ${r.discussions}',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
              ];
            }(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片：行为模式
  // ═══════════════════════════════════════════
  Widget _buildBehaviorCard(
    BuildContext context,
    AppColors colors,
    ObservationSnapshot snapshot,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.schedule_outlined, '行为模式'),
          const Divider(height: 24),
          _buildInfoRow(colors, '活跃时段', snapshot.behavior.activeTime.isNotEmpty
              ? snapshot.behavior.activeTime
              : '未记录'),
          const SizedBox(height: 8),
          _buildInfoRow(colors, '最爱模块', snapshot.behavior.favoriteModule.isNotEmpty
              ? snapshot.behavior.favoriteModule
              : '未记录'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 底部按钮：查看原始 JSON
  // ═══════════════════════════════════════════
  Widget _buildBottomButton(BuildContext context, AppColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showJsonBottomSheet(context, colors),
            icon: const Icon(Icons.code, size: 18),
            label: const Text('查看原始 JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showJsonBottomSheet(BuildContext context, AppColors colors) {
    final jsonStr = _rawJson != null
        ? const JsonEncoder.withIndent('  ').convert(_rawJson)
        : '{}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '原始 JSON',
                        style: TextStyle(
                          fontFamily: 'NotoSerifSC',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: colors.mainText,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _copyToClipboard(context, jsonStr);
                        },
                        icon: Icon(Icons.copy, size: 20, color: colors.accent),
                        tooltip: '复制',
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.cardBase.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SelectableText(
                          jsonStr,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: colors.mainText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).extension<AppColors>()!.accent,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 辅助组件
  // ═══════════════════════════════════════════

  Widget _buildCardTitle(AppColors colors, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colors.mainText,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(AppColors colors, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 12,
              color: colors.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 12,
              color: colors.mainText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRow(AppColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 13,
          color: colors.mutedText,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSourceTypeBadge(AppColors colors, String sourceType) {
    Color badgeColor;
    String label;
    switch (sourceType) {
      case 'explicit':
        badgeColor = Colors.green;
        label = '显式';
        break;
      case 'implicit':
        badgeColor = Colors.orange;
        label = '隐式';
        break;
      default:
        badgeColor = Colors.grey;
        label = '推断';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 9,
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 工具方法
  // ═══════════════════════════════════════════

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Color _getStatusColor(String status, AppColors colors) {
    switch (status) {
      case 'active':
        return colors.accent;
      case 'paused':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return colors.mutedText;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return '进行中';
      case 'paused':
        return '已暂停';
      case 'completed':
        return '已完成';
      default:
        return status;
    }
  }

  (Color, IconData) _getMoodColors(String mood) {
    switch (mood) {
      case 'happy':
        return (Colors.green, Icons.emoji_emotions_outlined);
      case 'sad':
        return (Colors.blue, Icons.sentiment_dissatisfied_outlined);
      case 'calm':
        return (Colors.teal, Icons.self_improvement);
      case 'angry':
        return (Colors.red, Icons.mood_bad_outlined);
      default:
        return (Colors.grey, Icons.sentiment_neutral_outlined);
    }
  }

  Color _moodColor(AppColors colors, String mood) {
    return _getMoodColors(mood).$1;
  }

  IconData _getMoodIcon(String mood) {
    return _getMoodColors(mood).$2;
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'happy':
        return '开心';
      case 'sad':
        return '低落';
      case 'calm':
        return '平静';
      case 'angry':
        return '生气';
      default:
        return '中性';
    }
  }
}
