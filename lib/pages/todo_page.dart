import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
  List<TodoItem> _todos = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todos');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() {
        _todos = list.map((e) => TodoItem.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString('todos', data);
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
      setState(() => _todos.insert(0, todo));
      await _saveTodos();
    }
  }

  void _toggleTodo(TodoItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
    _saveTodos();
  }

  Future<void> _deleteTodo(TodoItem item) async {
    setState(() => _todos.removeWhere((t) => t.id == item.id));
    await _saveTodos();
  }

  List<TodoItem> get _incomplete =>
      _todos.where((t) => !t.isCompleted).toList();
  List<TodoItem> get _completed =>
      _todos.where((t) => t.isCompleted).toList();

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
      body: _todos.isEmpty
          ? Center(
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
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Incomplete section
                if (_incomplete.isNotEmpty) ...[
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
                  ..._incomplete.map((todo) => _buildTodoCard(
                      context, colors, todo)),
                  const SizedBox(height: 20),
                ],
                // Completed section
                if (_completed.isNotEmpty) ...[
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
                  ..._completed
                      .map((todo) => _buildTodoCard(context, colors, todo)),
                ],
              ],
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
