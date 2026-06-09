import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';
import '../models/diary_entry.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  String _currentFilter = '全部';
  // DREAM_FILTER_HIDDEN: 梦境分类已暂时隐藏，未来可在 _filters 列表中添加 '梦境' 恢复
  final List<String> _filters = ['全部', '日记'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryProvider>().loadEntries();
    });
  }

  Future<void> _addOrEditEntry({DiaryEntry? existing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEditorPage(entry: existing),
      ),
    );
    if (result != null && result is DiaryEntry) {
      await context.read<DiaryProvider>().addOrUpdateEntry(result);
    }
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    await context.read<DiaryProvider>().deleteEntry(entry.id);
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
        title: Text(
          '日记',
          style: TextStyle(
            fontFamily: 'NotoSerifSC',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 1,
            color: colors.mainText,
          ),
        ),
        actions: [
          IconButton(
            icon: ThemeColors.plusIcon(context),
            onPressed: () => _addOrEditEntry(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colors.cardSurface,
            child: Row(
              children: _filters.map((f) {
                final selected = f == _currentFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _currentFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? colors.accent : colors.cardBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 10,
                          letterSpacing: 1,
                          color: selected ? Colors.white : colors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Consumer<DiaryProvider>(
              builder: (context, diary, _) {
                final entries = _currentFilter == '全部'
                    ? diary.entries
                    : diary.entries
                        .where((e) => e.category == _currentFilter)
                        .toList();
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeColors.diaryIcon(context, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          '还没有日记',
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildEntryCard(context, colors, entry, index, entries.length);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(
      BuildContext context, AppColors colors, DiaryEntry entry, int index, int totalEntries) {
    return Column(
      children: [
        GlassCard(
          onTap: () => _addOrEditEntry(existing: entry),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.tag.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.category == 'dream' ? '梦境' : '日记',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 10,
                        letterSpacing: 1,
                        color: colors.tag,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MM/dd').format(entry.date),
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 12,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteEntry(entry),
                    child: ThemeColors.trashIcon(context, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.title,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: colors.mainText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.content.length > 100
                    ? '${entry.content.substring(0, 100)}...'
                    : entry.content,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 14,
                  color: colors.secondaryText,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Dotted divider
        if (index < totalEntries - 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DottedLinePainter(color: colors.border),
            ),
          ),
      ],
    );
  }
}

class DiaryEditorPage extends StatefulWidget {
  final DiaryEntry? entry;

  const DiaryEditorPage({super.key, this.entry});

  @override
  State<DiaryEditorPage> createState() => _DiaryEditorPageState();
}

class _DiaryEditorPageState extends State<DiaryEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _category;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');
    _category = widget.entry?.category ?? 'diary';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
        title: Text(
          widget.entry == null ? '新日记' : '编辑日记',
          style: TextStyle(
            fontFamily: 'NotoSerifSC',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 1,
            color: colors.mainText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              '保存',
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 14,
                color: colors.accent,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category toggle
            Row(
              children: [
                _buildCategoryChip(context, colors, 'diary', '日记'),
                const SizedBox(width: 8),
                _buildCategoryChip(context, colors, 'dream', '梦境'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: 'NotoSerifSC',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: colors.mainText,
              ),
              decoration: InputDecoration(
                hintText: '标题',
                hintStyle: TextStyle(
                  fontFamily: 'NotoSerifSC',
                  fontSize: 17,
                  color: colors.secondaryText,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 14,
                  color: colors.mainText,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: '写下你的心情...',
                  hintStyle: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      BuildContext context, AppColors colors, String value, String label) {
    final selected = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.cardBase,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? colors.accent : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 12,
            color: selected ? Colors.white : colors.secondaryText,
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final entry = DiaryEntry(
      id: widget.entry?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _category,
      date: widget.entry?.date ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, entry);
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 10; // 6 dash + 4 gap
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
