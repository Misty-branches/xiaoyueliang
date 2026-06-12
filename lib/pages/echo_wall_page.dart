import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/echo_provider.dart';
import '../widgets/theme_colors.dart';

class EchoWallPage extends StatelessWidget {
  const EchoWallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final echo = context.watch<EchoProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(colors: colors, count: echo.entryCount),
            Expanded(
              child: echo.entries.isEmpty
                  ? _EmptyState(colors: colors)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: echo.entries.length,
                      itemBuilder: (ctx, i) {
                        final entry = echo.entries[i];
                        return _EchoCard(colors: colors, entry: entry);
                      },
                    ),
            ),
            _BottomNav(colors: colors, context: context),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppColors colors;
  final int count;
  const _Header({required this.colors, required this.count});

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
              Text('回忆馆', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('Memories · $count 件收藏', style: TextStyle(
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

class _EchoCard extends StatelessWidget {
  final AppColors colors;
  final EchoEntry entry;
  const _EchoCard({required this.colors, required this.entry});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.title, style: TextStyle(
            fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
            fontSize: 15, color: colors.mainText,
          )),
          const SizedBox(height: 8),
          Text(entry.content, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.secondaryText, height: 1.5,
          )),
          if (entry.link.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.link, size: 14, color: colors.accent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(entry.link, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 12, color: colors.accent,
                  )),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text('${entry.date.month}/${entry.date.day}', style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
          )),
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
          Icon(Icons.favorite_outline, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text('回忆馆还是空的\n收藏一些美好的瞬间吧', textAlign: TextAlign.center, style: TextStyle(
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
