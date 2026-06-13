import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';
import '../providers/observation_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';

/// 观察层调试面板
///
/// 只读展示 ObservationProvider 最新观察快照的全部数据。
/// 无数据时提示用户去聊天室发消息或写日记触发观察。
class ObservationDebugPage extends StatefulWidget {
  const ObservationDebugPage({super.key});

  @override
  State<ObservationDebugPage> createState() => _ObservationDebugPageState();
}

class _ObservationDebugPageState extends State<ObservationDebugPage> {
  ObservationSnapshot? _snapshot;
  Map<String, dynamic>? _rawJson;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProvider());
  }

  void _loadFromProvider() {
    if (!mounted) return;
    final provider = context.read<ObservationProvider>();
    final snapshot = provider.latestObservation;
    if (snapshot != null) {
      setState(() {
        _snapshot = snapshot;
        _rawJson = snapshot.toJson();
        _loading = false;
      });
    } else {
      // Provider 无数据 → 尝试读缓存（可能之前产生过）
      _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('moon_latest_observation');
      if (raw != null && mounted) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        setState(() {
          _snapshot = ObservationSnapshot.fromJson(json);
          _rawJson = json;
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
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

  Widget _buildHeader(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: ThemeColors.backIcon(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const Spacer(),
          Column(
            children: [
              Text('观察层调试', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('OBSERVATION DEBUG', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
              )),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_off_outlined, size: 48, color: colors.mutedText),
          const SizedBox(height: 16),
          Text('暂无观察数据', style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 16, color: colors.secondaryText,
          )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '去聊天室发条消息或去信件室写日记\n系统会自动观察并生成数据',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mutedText, height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppColors colors) {
    final snapshot = _snapshot!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(context, colors, snapshot),
          const SizedBox(height: 12),
          _buildInterestsCard(context, colors, snapshot),
          const SizedBox(height: 12),
          _buildMoodCard(context, colors, snapshot),
          const SizedBox(height: 12),
          _buildProjectsCard(context, colors, snapshot),
          const SizedBox(height: 12),
          _buildReadingCard(context, colors, snapshot),
          const SizedBox(height: 12),
          _buildBehaviorCard(context, colors, snapshot),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 卡片
  // ═══════════════════════════════════════════
  Widget _buildInfoCard(BuildContext context, AppColors colors, ObservationSnapshot snapshot) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.info_outline, '基本信息'),
          const Divider(height: 24),
          _buildInfoRow(colors, '快照 ID', snapshot.id),
          const SizedBox(height: 8),
          _buildInfoRow(colors, '生成时间', _formatDateTime(snapshot.date)),
          const SizedBox(height: 8),
          _buildInfoRow(colors, '可信度', '${(snapshot.confidence * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildInterestsCard(BuildContext context, AppColors colors, ObservationSnapshot snapshot) {
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
                        child: Text(item.topic, style: TextStyle(
                          fontFamily: 'NotoSansSC', fontWeight: FontWeight.w500,
                          fontSize: 13, color: colors.mainText,
                        )),
                      ),
                      _buildSourceTypeBadge(colors, item.sourceType),
                      const SizedBox(width: 8),
                      Text('${(item.score * 100).toInt()}%', style: TextStyle(
                        fontFamily: 'NotoSansSC', fontSize: 12, color: colors.secondaryText,
                      )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.score,
                      backgroundColor: colors.accentLight,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('最近提及: ${_formatDateTime(item.lastMention)}', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 10, color: colors.mutedText,
                  )),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, AppColors colors, ObservationSnapshot snapshot) {
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: moodColors.$1.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: moodColors.$1, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getMoodIcon(snapshot.mood.mood), size: 16, color: moodColors.$1),
                    const SizedBox(width: 6),
                    Text(_getMoodLabel(snapshot.mood.mood), style: TextStyle(
                      fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                      fontSize: 14, color: moodColors.$1,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildSourceTypeBadge(colors, snapshot.mood.sourceType),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('置信度', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 10, color: colors.mutedText,
                  )),
                  const SizedBox(height: 2),
                  Text('${(snapshot.mood.confidence * 100).toInt()}%', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                    fontSize: 16, color: moodColors.$1,
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCard(BuildContext context, AppColors colors, ObservationSnapshot snapshot) {
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
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status, colors),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(project.name, style: TextStyle(
                      fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mainText,
                    )),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accentLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_getStatusLabel(project.status), style: TextStyle(
                      fontFamily: 'NotoSansSC', fontSize: 10, color: colors.accent,
                    )),
                  ),
                  const SizedBox(width: 8),
                  Text(_formatDateTime(project.lastUpdate), style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 10, color: colors.mutedText,
                  )),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildReadingCard(BuildContext context, AppColors colors, ObservationSnapshot snapshot) {
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
                          Text(r.book, style: TextStyle(
                            fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                            fontSize: 14, color: colors.mainText,
                          )),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: r.progress / 100.0,
                                    backgroundColor: colors.accentLight,
                                    valueColor: AlwaysStoppedAnimation<Color>(colors.accentWarm),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${r.progress}%', style: TextStyle(
                                fontFamily: 'NotoSansSC', fontWeight: FontWeight.w500,
                                fontSize: 12, color: colors.accentWarm,
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('讨论次数: ${r.discussions}', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 12, color: colors.secondaryText,
                )),
              ];
            }(),
        ],
      ),
    );
  }

  Widget _buildBehaviorCard(BuildContext context, AppColors colors, ObservationSnapshot snapshot) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(colors, Icons.schedule_outlined, '行为模式'),
          const Divider(height: 24),
          _buildInfoRow(colors, '活跃时段', snapshot.behavior.activeTime.isNotEmpty
              ? snapshot.behavior.activeTime : '未记录'),
          const SizedBox(height: 8),
          _buildInfoRow(colors, '最爱模块', snapshot.behavior.favoriteModule.isNotEmpty
              ? snapshot.behavior.favoriteModule : '未记录'),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, AppColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _loading = true;
                _snapshot = null;
                _rawJson = null;
              });
              _loadFromProvider();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('刷新', style: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, fontWeight: FontWeight.w600,
            )),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.accent,
              side: BorderSide(color: colors.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
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
        Text(title, style: TextStyle(
          fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
          fontSize: 14, color: colors.mainText,
        )),
      ],
    );
  }

  Widget _buildInfoRow(AppColors colors, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 12, color: colors.secondaryText,
          )),
        ),
        Expanded(
          child: Text(value, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 12, color: colors.mainText,
          )),
        ),
      ],
    );
  }

  Widget _buildEmptyRow(AppColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: TextStyle(
        fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mutedText,
        fontStyle: FontStyle.italic,
      )),
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
      child: Text(label, style: TextStyle(
        fontFamily: 'NotoSansSC', fontSize: 9, color: badgeColor,
        fontWeight: FontWeight.w500,
      )),
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
      case 'active': return colors.accent;
      case 'paused': return Colors.orange;
      case 'completed': return Colors.green;
      default: return colors.mutedText;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active': return '进行中';
      case 'paused': return '已暂停';
      case 'completed': return '已完成';
      default: return status;
    }
  }

  (Color, IconData) _getMoodColors(String mood) {
    switch (mood) {
      case 'happy': return (Colors.green, Icons.emoji_emotions_outlined);
      case 'sad': return (Colors.blue, Icons.sentiment_dissatisfied_outlined);
      case 'calm': return (Colors.teal, Icons.self_improvement);
      case 'angry': return (Colors.red, Icons.mood_bad_outlined);
      default: return (Colors.grey, Icons.sentiment_neutral_outlined);
    }
  }

  IconData _getMoodIcon(String mood) => _getMoodColors(mood).$2;
  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'happy': return '开心';
      case 'sad': return '低落';
      case 'calm': return '平静';
      case 'angry': return '生气';
      default: return '中性';
    }
  }
}
