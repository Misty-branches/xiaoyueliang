import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookshelf_provider.dart';
import '../models/book_item.dart';
import '../widgets/theme_colors.dart';

class BookshelfPage extends StatelessWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final shelf = context.watch<BookshelfProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(colors: colors),
            Expanded(
              child: shelf.books.isEmpty
                  ? _EmptyState(colors: colors)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: shelf.books.length,
                      itemBuilder: (ctx, i) {
                        final book = shelf.books[i];
                        return _BookCard(colors: colors, book: book);
                      },
                    ),
            ),

          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppColors colors;
  const _Header({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.mainText),
          ),
          const Spacer(),
          Column(
            children: [
              Text('书房', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('Books · 一起读书', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
              )),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final AppColors colors;
  final BookItem book;
  const _BookCard({required this.colors, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // 封面 emoji
          Container(
            width: 48, height: 64,
            decoration: BoxDecoration(
              color: colors.accentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(book.coverEmoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: TextStyle(
                  fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                  fontSize: 15, color: colors.mainText,
                )),
                if (book.author.isNotEmpty)
                  Text(book.author, style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 12, color: colors.secondaryText,
                  )),
                const SizedBox(height: 8),
                // 进度条
                if (book.totalPages > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      minHeight: 6,
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${book.currentPages}/${book.totalPages} 页 · ${book.progressPercent}', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text('书架还是空的\n添加一本想读的书吧', textAlign: TextAlign.center, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText, height: 1.5,
          )),
        ],
      ),
    );
  }
}

Widget _BottomNav({required AppColors colors, required BuildContext context}) {
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
            _NavItem(colors: colors, icon: Icons.home, label: '窗台', active: false, onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
            _NavItem(colors: colors, icon: Icons.weekend, label: '客厅', active: false, onTap: () => Navigator.pop(context)),
            _NavItem(colors: colors, icon: Icons.settings, label: '设置', active: false, onTap: () {}),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.colors, required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: active ? colors.accent : colors.mutedText),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'NotoSansSC', fontSize: 10, color: active ? colors.accent : colors.mutedText)),
        ],
      ),
    );
  }
}
