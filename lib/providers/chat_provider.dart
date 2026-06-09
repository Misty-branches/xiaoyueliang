import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _apiKey = '';
  String _systemPrompt =
      '你是一个名叫「小月亮」的温暖陪伴型AI助手。你温柔、体贴、善解人意，像月光一样静静地陪伴着用户。你说话简洁而温暖，用中文回答。';
  String _model = 'gpt-3.5-turbo';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get apiKey => _apiKey;
  String get systemPrompt => _systemPrompt;
  String get model => _model;

  final _uuid = const Uuid();

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_messages');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _messages = list.map((e) => ChatMessage.fromJson(e)).toList();
    }
    _apiKey = prefs.getString('api_key') ?? '';
    _systemPrompt = prefs.getString('system_prompt') ?? _systemPrompt;
    _model = prefs.getString('model_name') ?? _model;
    notifyListeners();
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_messages', data);
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
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

  Future<void> addMessage(String role, String content) async {
    final msg = ChatMessage(
      id: _uuid.v4(),
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    await saveMessages();
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_apiKey.isEmpty) return;

    await addMessage('user', content);

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            ..._messages
                .map((m) => {'role': m.role, 'content': m.content})
                .toList(),
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        await addMessage('assistant', reply);
      } else {
        await addMessage('assistant',
            '抱歉，我暂时无法回应。错误：${response.statusCode}');
      }
    } catch (e) {
      await addMessage('assistant', '抱歉，连接出了问题。$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearMessages() async {
    _messages.clear();
    await saveMessages();
    notifyListeners();
  }
}
