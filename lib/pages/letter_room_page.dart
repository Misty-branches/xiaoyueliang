import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/message_board_provider.dart';
import '../providers/diary_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/project_provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/observation_provider.dart';
import '../services/observation_service.dart';
import '../models/message_post.dart';
import '../models/diary_entry.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import 'hub_page.dart';
import 'settings_page.dart';

class LetterRoomPage extends StatefulWidget {
  const LetterRoomPage({super.key});

  @override
  State<LetterRoomPage> createState() => _LetterRoomPageState();
}

class _LetterRoomPageState extends State<LetterRoomPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 留言板输入
  final _messageController = TextEditingController();

  // 日记新增弹窗输入
  final _diaryTitleController = TextEditingController();
  final _diaryContentController = TextEditingController();
  String _diaryCategory = 'diary';

  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageBoardProvider>().loadPosts();
      context.read<DiaryProvider>().loadEntries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _diaryTitleController.dispose();
    _diaryContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colors),
            _buildTabBar(colors),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMessageBoardTab(context, colors),
                  _buildDiaryTab(context, colors),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, colors),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showDiaryBottomSheet(context, colors),
              backgroundColor: colors.accent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // ═══════════════════════════════════════════
  // 顶部标题栏
  // ═══════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ThemeColors.backIcon(context),
          ),
          const Spacer(),
          Column(
            children: [
              Text('信件室', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('Letters · 写下想说的话', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
              )),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TabBar
  // ═══════════════════════════════════════════
  Widget _buildTabBar(AppColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        labelColor: colors.accent,
        unselectedLabelColor: colors.mutedText,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: colors.accentLight,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: '留言板'),
          Tab(text: '日记'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 1：留言板
  // ═══════════════════════════════════════════
  Widget _buildMessageBoardTab(BuildContext context, AppColors colors) {
    final board = context.watch<MessageBoardProvider>();

    return Column(
      children: [
        // 留言列表
        Expanded(
          child: board.posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: colors.mutedText),
                      const SizedBox(height: 12),
                      Text('还没有留言，写点什么吧', style: TextStyle(
                        fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText,
                      )),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: board.posts.length,
                  itemBuilder: (ctx, i) {
                    final post = board.posts[i];
                    return _MessageCard(colors: colors, post: post);
                  },
                ),
        ),
        // 底部输入框
        Container(
          decoration: BoxDecoration(
            color: colors.cardSurface,
            border: Border(top: BorderSide(color: colors.border, width: 0.5)),
          ),
          padding: EdgeInsets.only(
            left: 12,
            right: 8,
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.cardBase,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '写点什么…',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: TextStyle(
                      fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _sendMessage(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.send, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(BuildContext context) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final post = MessagePost(
      id: _uuid.v4(),
      userId: 'self',
      content: content,
      mood: 'share',
    );
    context.read<MessageBoardProvider>().addPost(post);
    _messageController.clear();

    // 留言发送后触发观察层
    _triggerObservation(context);
  }

  // ═══════════════════════════════════════════
  // Tab 2：日记
  // ═══════════════════════════════════════════
  Widget _buildDiaryTab(BuildContext context, AppColors colors) {
    final diary = context.watch<DiaryProvider>();

    if (diary.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 48, color: colors.mutedText),
            const SizedBox(height: 12),
            Text('还没有日记\n写下今天的心情吧', textAlign: TextAlign.center, style: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText, height: 1.5,
            )),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: diary.entries.length,
      itemBuilder: (ctx, i) {
        final entry = diary.entries[i];
        return _DiaryCard(colors: colors, entry: entry);
      },
    );
  }

  // ═══════════════════════════════════════════
  // 日记新增底部弹窗
  // ═══════════════════════════════════════════
  void _showDiaryBottomSheet(BuildContext context, AppColors colors) {
    _diaryTitleController.clear();
    _diaryContentController.clear();
    _diaryCategory = 'diary';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: colors.cardSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text('写日记', style: TextStyle(
                    fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                    fontSize: 18, color: colors.mainText,
                  )),
                  const SizedBox(height: 16),
                  // 标题输入
                  TextField(
                    controller: _diaryTitleController,
                    decoration: InputDecoration(
                      hintText: '标题',
                      filled: true,
                      fillColor: colors.cardBase,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: TextStyle(
                      fontFamily: 'NotoSansSC', fontSize: 15, color: colors.mainText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 内容输入
                  TextField(
                    controller: _diaryContentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '写下今天的心情…',
                      filled: true,
                      fillColor: colors.cardBase,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: TextStyle(
                      fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText, height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // 分类选择
                  Row(
                    children: [
                      _categoryChip(ctx, colors, 'diary', '日记', setSheetState),
                      const SizedBox(width: 10),
                      _categoryChip(ctx, colors, 'dream', '梦境', setSheetState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 保存按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveDiaryEntry(context);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('保存', style: TextStyle(
                        fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600, fontSize: 16,
                      )),
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

  Widget _categoryChip(BuildContext context, AppColors colors, String value, String label,
      void Function(void Function()) setSheetState) {
    final isSelected = _diaryCategory == value;
    return GestureDetector(
      onTap: () {
        setSheetState(() {
          _diaryCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.accentLight : colors.cardSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'NotoSansSC', fontSize: 13,
          color: isSelected ? colors.accent : colors.secondaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }

  void _saveDiaryEntry(BuildContext context) {
    final title = _diaryTitleController.text.trim();
    final content = _diaryContentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final entry = DiaryEntry(
      id: _uuid.v4(),
      title: title,
      content: content,
      category: _diaryCategory,
      date: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.read<DiaryProvider>().addOrUpdateEntry(entry);

    // 日记保存后触发观察层
    _triggerObservation(context);
  }

  /// 触发观察层：收集所有 Provider 数据并生成观察快照
  void _triggerObservation(BuildContext context) {
    ObservationService.triggerObservation(
      chatProvider: context.read<ChatProvider>(),
      diaryProvider: context.read<DiaryProvider>(),
      projectProvider: context.read<ProjectProvider>(),
      bookshelfProvider: context.read<BookshelfProvider>(),
      todoProvider: context.read<TodoProvider>(),
      observationProvider: context.read<ObservationProvider>(),
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
// 留言卡片
// ═══════════════════════════════════════════
class _MessageCard extends StatelessWidget {
  final AppColors colors;
  final MessagePost post;
  const _MessageCard({required this.colors, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 内容
          Text(post.content, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText, height: 1.5,
          )),
          const SizedBox(height: 10),
          // 底部：时间 + 情绪标签 + 删除按钮
          Row(
            children: [
              // 时间
              Text(_formatTime(post.createdAt), style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
              )),
              const SizedBox(width: 8),
              // 情绪标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accentLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_moodLabel(post.mood), style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 10, color: colors.accent,
                )),
              ),
              const Spacer(),
              // 删除按钮
              GestureDetector(
                onTap: () => _confirmDeletePost(context),
                child: Icon(Icons.delete_outline, size: 18, color: colors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${dt.month}/${dt.day}';
  }

  String _moodLabel(String mood) {
    switch (mood) {
      case 'happy': return '开心';
      case 'sad': return '难过';
      case 'angry': return '生气';
      case 'calm': return '平静';
      case 'excited': return '兴奋';
      default: return '分享';
    }
  }

  void _confirmDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除', style: TextStyle(fontFamily: 'NotoSansSC')),
        content: const Text('确定要删除这条留言吗？', style: TextStyle(fontFamily: 'NotoSansSC')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(fontFamily: 'NotoSansSC')),
          ),
          TextButton(
            onPressed: () {
              context.read<MessageBoardProvider>().deletePost(post.id);
              Navigator.pop(ctx);
            },
            child: Text('删除', style: TextStyle(
              fontFamily: 'NotoSansSC', color: colors.accentWarm,
            )),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// 日记卡片
// ═══════════════════════════════════════════
class _DiaryCard extends StatelessWidget {
  final AppColors colors;
  final DiaryEntry entry;
  const _DiaryCard({required this.colors, required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _confirmDeleteEntry(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(entry.title, style: TextStyle(
                    fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                    fontSize: 15, color: colors.mainText,
                  )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.accentLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(entry.category == 'dream' ? '梦境' : '日记', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 11, color: colors.accent,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(entry.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, color: colors.secondaryText, height: 1.5,
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${entry.date.month}/${entry.date.day}', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
                )),
                const Spacer(),
                // 滑动删除提示（仅长按）
                GestureDetector(
                  onTap: () => _confirmDeleteEntry(context),
                  child: Icon(Icons.delete_outline, size: 18, color: colors.mutedText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteEntry(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除', style: TextStyle(fontFamily: 'NotoSansSC')),
        content: const Text('确定要删除这篇日记吗？', style: TextStyle(fontFamily: 'NotoSansSC')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(fontFamily: 'NotoSansSC')),
          ),
          TextButton(
            onPressed: () {
              context.read<DiaryProvider>().deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            child: Text('删除', style: TextStyle(
              fontFamily: 'NotoSansSC', color: colors.accentWarm,
            )),
          ),
        ],
      ),
    );
  }
}
