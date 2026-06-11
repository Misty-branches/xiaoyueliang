import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

class ChatProvider extends ChangeNotifier {
  // ─── 对话管理 ───
  List<Conversation> _conversations = [];
  String? _activeConversationId;
  List<ChatMessage> _messages = [];

  // ─── API 配置 ───
  bool _isLoading = false;
  String _apiKey = '';
  String _apiBaseUrl = '';
  String _systemPrompt =
      '你是一个名叫「小月亮」的温暖陪伴型AI助手。你温柔、体贴、善解人意，像月光一样静静地陪伴着用户。你说话简洁而温暖，用中文回答。';
  String _model = '';

  // ─── Getters ───
  List<Conversation> get conversations => _conversations;
  String? get activeConversationId => _activeConversationId;
  Conversation? get activeConversation => _activeConversationId != null
      ? _conversations.cast<Conversation?>().firstWhere(
          (c) => c!.id == _activeConversationId,
          orElse: () => null)
      : null;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get apiKey => _apiKey;
  String get apiBaseUrl => _apiBaseUrl;
  String get systemPrompt => _systemPrompt;
  String get model => _model;

  final _uuid = const Uuid();

  // ─── 持久化 ───

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('api_key') ?? '';
    _apiBaseUrl = prefs.getString('api_base_url') ?? '';
    _systemPrompt =
        prefs.getString('system_prompt') ?? _systemPrompt;
    _model = prefs.getString('model_name') ?? _model;

    // 加载会话列表
    final convData = prefs.getString('conversations');
    if (convData != null) {
      final list = jsonDecode(convData) as List;
      _conversations =
          list.map((e) => Conversation.fromJson(e)).toList();
    }

    // 恢复上次打开的会话
    final lastId = prefs.getString('active_conversation_id');
    if (lastId != null &&
        _conversations.any((c) => c.id == lastId)) {
      _activeConversationId = lastId;
      await _loadMessagesFor(lastId);
    } else if (_conversations.isNotEmpty) {
      _activeConversationId = _conversations.first.id;
      await _loadMessagesFor(_conversations.first.id);
    }

    notifyListeners();
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'conversations',
        jsonEncode(
            _conversations.map((c) => c.toJson()).toList()));
    await prefs.setString(
        'active_conversation_id', _activeConversationId ?? '');
  }

  Future<void> _loadMessagesFor(String convId) async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        prefs.getString('chat_messages_$convId');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _messages =
          list.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      _messages = [];
    }
  }

  Future<void> _saveMessages() async {
    if (_activeConversationId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'chat_messages_$_activeConversationId',
        jsonEncode(_messages.map((m) => m.toJson()).toList()));
  }

  // ─── API 配置 ───

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
    notifyListeners();
  }

  Future<void> setApiBaseUrl(String url) async {
    _apiBaseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    notifyListeners();
  }

  Future<void> setSystemPrompt(String prompt) async {
    _systemPrompt = prompt;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('system_prompt', prompt);
    notifyListeners();
  }

  Future<void> setModel(String model) async {
    _model = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model_name', model);
    notifyListeners();
  }

  Future<String> _extractContent(String body) {
    try {
      final data = jsonDecode(body);
      final choice = data['choices']?[0];
      if (choice != null) {
        final content = choice['message']?['content'];
        if (content != null && content is String) return content;
        final text = choice['text'];
        if (text != null && text is String) return text;
      }
      final claudeContent = data['content']?[0]?['text'];
      if (claudeContent != null && claudeContent is String)
        return claudeContent;
      return body;
    } catch (_) {
      return body;
    }
  }

  // ─── 对话 CRUD ───

  Future<void> createConversation({String? title}) async {
    final conv = Conversation(
      id: _uuid.v4(),
      title: title ?? '新对话',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messageCount: 0,
      modelName: _model,
    );
    _conversations.insert(0, conv);
    _activeConversationId = conv.id;
    _messages = [];
    await _saveConversations();
    await _saveMessages();
    notifyListeners();
  }

  Future<void> switchConversation(String id) async {
    if (id == _activeConversationId) return;
    await _saveMessages();
    _activeConversationId = id;
    await _loadMessagesFor(id);
    notifyListeners();
  }

  Future<void> renameConversation(String id, String title) async {
    final idx = _conversations.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        title: title,
        updatedAt: DateTime.now(),
      );
      await _saveConversations();
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String id) async {
    _conversations.removeWhere((c) => c.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages_$id');

    if (_activeConversationId == id) {
      _activeConversationId =
          _conversations.isNotEmpty ? _conversations.first.id : null;
      if (_activeConversationId != null) {
        await _loadMessagesFor(_activeConversationId!);
      } else {
        _messages = [];
      }
    }
    await _saveConversations();
    notifyListeners();
  }

  Future<void> clearMessages() async {
    _messages.clear();
    if (_activeConversationId != null) {
      final idx = _conversations
          .indexWhere((c) => c.id == _activeConversationId);
      if (idx != -1) {
        _conversations[idx] = _conversations[idx]
            .copyWith(messageCount: 0, updatedAt: DateTime.now());
        await _saveConversations();
      }
    }
    await _saveMessages();
    notifyListeners();
  }

  // ─── 消息操作 ───

  Future<void> addMessage(String role, String content,
      {String? thinking, String? language}) async {
    if (_activeConversationId == null) return;

    final msg = ChatMessage(
      id: _uuid.v4(),
      role: role,
      content: content,
      timestamp: DateTime.now(),
      thinking: thinking,
      language: language ?? 'zh',
    );
    _messages.add(msg);

    // 更新对话元数据
    final idx = _conversations
        .indexWhere((c) => c.id == _activeConversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        messageCount: _messages.length,
        updatedAt: DateTime.now(),
      );
      await _saveConversations();
    }
    await _saveMessages();
    notifyListeners();
  }

  Future<void> deleteMessage(String id) async {
    _messages.removeWhere((m) => m.id == id);
    if (_activeConversationId != null) {
      final idx = _conversations
          .indexWhere((c) => c.id == _activeConversationId);
      if (idx != -1) {
        _conversations[idx] = _conversations[idx].copyWith(
          messageCount: _messages.length,
          updatedAt: DateTime.now(),
        );
        await _saveConversations();
      }
    }
    await _saveMessages();
    notifyListeners();
  }

  Future<void> updateMessage(String id, String newContent) async {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _messages[idx] =
          _messages[idx].copyWith(content: newContent);
      await _saveMessages();
      notifyListeners();
    }
  }

  Future<void> regenerateMessage(String id) async {
    // 找到这条消息的位置
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1 || _messages[idx].role != 'assistant') return;

    // 删除这条AI消息
    _messages.removeAt(idx);

    // 如果上一条也是AI消息，一并删除（保持用户→AI配对）
    // 否则会用已删除的AI消息当上下文
    await _saveMessages();

    // 用当前上下文中最后一条用户消息重新调用API
    final lastUserIdx = _messages.lastIndexWhere(
        (m) => m.role == 'user');
    if (lastUserIdx == -1) {
      notifyListeners();
      return;
    }

    // 重新发送
    await _callApi();
  }

  // ─── API 调用 ───

  Future<void> sendMessage(String content) async {
    if (_apiKey.isEmpty || _apiBaseUrl.isEmpty) return;

    // 如果没有活跃对话，自动创建一个
    if (_activeConversationId == null) {
      await createConversation();
    }

    await addMessage('user', content);
    await _callApi();
  }

  Future<void> _callApi() async {
    if (_activeConversationId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            ..._messages
                .map((m) =>
                    {'role': m.role, 'content': m.content})
                .toList(),
          ],
        }),
      );

      if (response.statusCode == 200) {
        final reply = await _extractContent(response.body);
        await addMessage('assistant', reply);
      } else {
        await addMessage('assistant',
            '抱歉，我暂时无法回应。错误：${response.statusCode}');
      }
    } catch (e) {
      await addMessage(
          'assistant', '抱歉，连接出了问题。$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
