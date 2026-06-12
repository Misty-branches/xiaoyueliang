import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/theme_colors.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final todo = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(colors: colors, incompleteCount: todo.incompleteCount),
            Expanded(
              child: todo.todos.isEmpty
                  ? _EmptyState(colors: colors)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        // 未完成
                        if (todo.incompleteTodos.isNotEmpty) ...[
                          Text('待办 · ${todo.incompleteCount}', style: TextStyle(
                            fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                            fontSize: 13, color: colors.mutedText,
                          )),
                          const SizedBox(height: 8),
                          ...todo.incompleteTodos.map((t) => _TodoCard(
                            colors: colors, item: t,
                            onToggle: () => todo.toggleTodo(t.id),
                          )),
                          const SizedBox(height: 16),
                        ],
                        // 已完成
                        if (todo.completedTodos.isNotEmpty) ...[
                          Text('已完成', style: TextStyle(
                            fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                            fontSize: 13, color: colors.mutedText,
                          )),
                          const SizedBox(height: 8),
                          ...todo.completedTodos.map((t) => _TodoCard(
                            colors: colors, item: t,
                            onToggle: () => todo.toggleTodo(t.id),
                          )),
                        ],
                      ],
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
  final int incompleteCount;
  const _Header({required this.colors, required this.incompleteCount});

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
              Text('工作台', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('Tasks · $incompleteCount 件事待办', style: TextStyle(
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

class _TodoCard extends StatelessWidget {
  final AppColors colors;
  final TodoItem item;
  final VoidCallback onToggle;
  const _TodoCard({required this.colors, required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 22,
              color: item.isCompleted ? colors.accent : colors.mutedText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.title, style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              )),
            ),
            if (item.tag.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.tag.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(item.tag, style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 11, color: colors.tag,
                )),
              ),
          ],
        ),
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
          Icon(Icons.check_circle_outline, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text('没有待办事项\n清清爽爽的一天', textAlign: TextAlign.center, style: TextStyle(
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
