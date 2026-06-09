import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../widgets/theme_colors.dart';
import '../widgets/glass_card.dart';

class EchoEntry {
  final String id;
  final String title;
  final String content;
  final String code;
  final String link;
  final DateTime date;

  EchoEntry({
    required this.id,
    required this.title,
    required this.content,
    this.code = '',
    this.link = '',
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'code': code,
        'link': link,
        'date': date.toIso8601String(),
      };

  factory EchoEntry.fromJson(Map<String, dynamic> json) => EchoEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        code: json['code'] as String? ?? '',
        link: json['link'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
      );
}

class EchoWallPage extends StatefulWidget {
  const EchoWallPage({super.key});

  @override
  State<EchoWallPage> createState() => _EchoWallPageState();
}

class _EchoWallPageState extends State<EchoWallPage> {
  List<EchoEntry> _entries = [];
  final _uuid = const Uuid();
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('echo_entries');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        _entries = list.map((e) => EchoEntry.fromJson(e)).toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('echo_entries', data);
  }

  Future<void> _addEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EchoEditorPage()),
    );
    if (result != null && result is EchoEntry) {
      setState(() {
        _entries.insert(0, result);
      });
      await _saveEntries();
    }
  }

  Future<void> _deleteEntry(EchoEntry entry) async {
    setState(() {
      _entries.removeWhere((e) => e.id == entry.id);
    });
    await _saveEntries();
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
          '回音墙',
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
            onPressed: _addEntry,
          ),
        ],
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeColors.echoIcon(context, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '还没有回音',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addEntry,
                    child: Text(
                      '留下你的回音',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 14,
                        color: colors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final expanded = _expandedIndex == index;
                return _buildEchoCard(
                    context, colors, entry, index, expanded);
              },
            ),
    );
  }

  Widget _buildEchoCard(BuildContext context, AppColors colors,
      EchoEntry entry, int index, bool expanded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _expandedIndex = expanded ? -1 : index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: expanded ? colors.accent : colors.accentWarm,
                width: 3,
              ),
              top: BorderSide(color: colors.border, width: 0.5),
              right: BorderSide(color: colors.border, width: 0.5),
              bottom: BorderSide(color: colors.border, width: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.mainText,
                      ),
                    ),
                  ),
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
                entry.content,
                style: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 14,
                  color: colors.mainText,
                  height: 1.5,
                ),
                maxLines: expanded ? null : 3,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (expanded && entry.code.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.cardBase,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    entry.code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: colors.accent,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              if (expanded && entry.link.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.link,
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 10,
                      letterSpacing: 1,
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
              if (!expanded && (entry.code.isNotEmpty || entry.link.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (entry.code.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.tag.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '代码',
                            style: TextStyle(
                              fontFamily: 'NotoSansSC',
                              fontSize: 10,
                              letterSpacing: 1,
                              color: colors.tag,
                            ),
                          ),
                        ),
                      if (entry.link.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '链接',
                            style: TextStyle(
                              fontFamily: 'NotoSansSC',
                              fontSize: 10,
                              letterSpacing: 1,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class EchoEditorPage extends StatefulWidget {
  const EchoEditorPage({super.key});

  @override
  State<EchoEditorPage> createState() => _EchoEditorPageState();
}

class _EchoEditorPageState extends State<EchoEditorPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _codeCtrl.dispose();
    _linkCtrl.dispose();
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
          '新回音',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
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
            const SizedBox(height: 16),
            TextField(
              controller: _contentCtrl,
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 14,
                color: colors.mainText,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: '写下你的回音...',
                hintStyle: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 14,
                  color: colors.secondaryText,
                ),
                border: InputBorder.none,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            Text(
              '代码（可选）',
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 12,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _codeCtrl,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colors.accent,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: '粘贴一段代码...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Text(
              '链接（可选）',
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 12,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _linkCtrl,
              style: TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 14,
                color: colors.mainText,
              ),
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: TextStyle(
                  fontFamily: 'NotoSansSC',
                  fontSize: 14,
                  color: colors.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final entry = EchoEntry(
      id: _uuid.v4(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
      date: DateTime.now(),
    );
    Navigator.pop(context, entry);
  }
}
