import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/todo_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';
import '../widgets/glass_card.dart';
import '../models/todo_item.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  Future<void> _addTodo() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _TodoFormDialog(),
    );
    if (result != null) {
      final todo = TodoItem(
        id: _uuid.v4(),
        title: result['title']!,
        tag: result['tag'] ?? '',
      );
      await context.read<TodoProvider>().addTodo(todo);
    }
  }

  Future<void> _toggleTodo(TodoItem item) async {
    await context.read<TodoProvider>().toggleTodo(item.id);
  }

  Future<void> _deleteTodo(TodoItem item) async {
    await context.read<TodoProvider>().deleteTodo(item.id);
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
          '待办',
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
            onPressed: _addTodo,
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProv, _) {
          final todos = todoProv.todos;
          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ThemeColors.todoIcon(context, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '还没有待办事项',
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
          final incomplete = todoProv.incompleteTodos;
          final completed = todoProv.completedTodos;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Incomplete section
              if (incomplete.isNotEmpty) ...[
                Text(
                  '进行中',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors.mainText,
                  ),
                ),
                const SizedBox(height: 8),
                ...incomplete.map((todo) =>
                    _buildTodoCard(context, colors, todo)),
                const SizedBox(height: 20),
              ],
              // Completed section
              if (completed.isNotEmpty) ...[
                Text(
                  '已完成',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                ...completed
                    .map((todo) => _buildTodoCard(context, colors, todo)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodoCard(
      BuildContext context, AppColors colors, TodoItem todo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SmallCard(
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => _toggleTodo(todo),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: todo.isCompleted ? colors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: todo.isCompleted ? colors.accent : colors.border,
                    width: 2,
                  ),
                ),
                child: todo.isCompleted
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 14,
                      color: todo.isCompleted
                          ? colors.secondaryText
                          : colors.mainText,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (todo.tag.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.tag.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        todo.tag,
                        style: TextStyle(
                          fontFamily: 'NotoSansSC',
                          fontSize: 10,
                          letterSpacing: 1,
                          color: colors.tag,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _deleteTodo(todo),
              child: ThemeColors.trashIcon(context, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoFormDialog extends StatefulWidget {
  @override
  State<_TodoFormDialog> createState() => _TodoFormDialogState();
}

class _TodoFormDialogState extends State<_TodoFormDialog> {
  final _titleCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return AlertDialog(
      backgroundColor: colors.cardSurface,
      title: Text(
        '添加待办',
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
              labelText: '事项',
              labelStyle: TextStyle(color: colors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(color: colors.mainText),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagCtrl,
            decoration: InputDecoration(
              labelText: '标签（可选）',
              labelStyle: TextStyle(color: colors.secondaryText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(color: colors.mainText),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: TextStyle(color: colors.secondaryText)),
        ),
        TextButton(
          onPressed: () {
            if (_titleCtrl.text.trim().isEmpty) return;
            Navigator.pop(context, {
              'title': _titleCtrl.text.trim(),
              'tag': _tagCtrl.text.trim(),
            });
          },
          child: Text('添加', style: TextStyle(color: colors.accent)),
        ),
      ],
    );
  }
}
