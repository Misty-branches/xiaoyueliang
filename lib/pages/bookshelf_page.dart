import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../widgets/theme_colors.dart';
import '../widgets/glass_card.dart';
import '../models/book_item.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  List<BookItem> _books = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('books');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        _books = list.map((e) => BookItem.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_books.map((b) => b.toJson()).toList());
    await prefs.setString('books', data);
  }

  Future<void> _addBook() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _BookFormDialog(),
    );
    if (result != null) {
      final book = BookItem(
        id: _uuid.v4(),
        title: result['title']!,
        author: result['author'] ?? '',
        totalPages: int.tryParse(result['totalPages'] ?? '0') ?? 0,
      );
      setState(() => _books.add(book));
      await _saveBooks();
    }
  }

  Future<void> _updateProgress(BookItem book) async {
    final totalCtrl =
        TextEditingController(text: book.totalPages.toString());
    final currentCtrl =
        TextEditingController(text: book.currentPages.toString());

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('更新进度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: totalCtrl,
              decoration: const InputDecoration(labelText: '总页数'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: currentCtrl,
              decoration: const InputDecoration(labelText: '已读页数'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final total = int.tryParse(totalCtrl.text) ?? book.totalPages;
              final current =
                  int.tryParse(currentCtrl.text) ?? book.currentPages;
              book.totalPages = total;
              book.currentPages = current;
              await _saveBooks();
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBook(BookItem book) async {
    setState(() => _books.removeWhere((b) => b.id == book.id));
    await _saveBooks();
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
          '书架',
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
            onPressed: _addBook,
          ),
        ],
      ),
      body: _books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeColors.bookIcon(context, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '书架空空如也',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _addBook,
                    child: Text(
                      '添加一本书',
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
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return _buildBookCard(context, colors, book);
              },
            ),
    );
  }

  Widget _buildBookCard(BuildContext context, AppColors colors, BookItem book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => _updateProgress(book),
        child: Row(
          children: [
            // Cover placeholder
            Container(
              width: 56,
              height: 80,
              decoration: BoxDecoration(
                color: colors.cardBase,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Text(
                  book.coverEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: colors.mainText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.author.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 12,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            minHeight: 4,
                            backgroundColor: colors.cardBase,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        book.progressPercent,
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteBook(book),
              child: ThemeColors.trashIcon(context, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookFormDialog extends StatefulWidget {
  @override
  State<_BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<_BookFormDialog> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return AlertDialog(
      backgroundColor: colors.cardSurface,
      title: Text(
        '添加书目',
        style: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: colors.mainText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: '书名',
              labelStyle: TextStyle(color: colors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(color: colors.mainText),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorCtrl,
            decoration: InputDecoration(
              labelText: '作者',
              labelStyle: TextStyle(color: colors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(color: colors.mainText),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pagesCtrl,
            decoration: InputDecoration(
              labelText: '总页数',
              labelStyle: TextStyle(color: colors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(color: colors.mainText),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消',
              style: TextStyle(color: colors.secondaryText)),
        ),
        TextButton(
          onPressed: () {
            if (_titleCtrl.text.trim().isEmpty) return;
            Navigator.pop(context, {
              'title': _titleCtrl.text.trim(),
              'author': _authorCtrl.text.trim(),
              'totalPages': _pagesCtrl.text.trim(),
            });
          },
          child: Text('添加', style: TextStyle(color: colors.accent)),
        ),
      ],
    );
  }
}
