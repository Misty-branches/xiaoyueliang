import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiProvider {
  final String id;
  final String name;
  final String apiMode; // openai, custom
  final String apiKey;
  final String apiHost;
  final String apiPath;
  final List<String> models;
  final String activeModel;
  final bool useProxy;

  ApiProvider({
    required this.id,
    required this.name,
    this.apiMode = 'openai',
    this.apiKey = '',
    this.apiHost = '',
    this.apiPath = '/v1/chat/completions',
    this.models = const [],
    this.activeModel = '',
    this.useProxy = false,
  });

  bool get isConfigured => apiKey.isNotEmpty && apiHost.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'apiMode': apiMode,
    'apiKey': apiKey,
    'apiHost': apiHost,
    'apiPath': apiPath,
    'models': models,
    'activeModel': activeModel,
    'useProxy': useProxy,
  };

  factory ApiProvider.fromJson(Map<String, dynamic> json) => ApiProvider(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    apiMode: json['apiMode'] ?? 'openai',
    apiKey: json['apiKey'] ?? '',
    apiHost: json['apiHost'] ?? '',
    apiPath: json['apiPath'] ?? '/v1/chat/completions',
    models: List<String>.from(json['models'] ?? []),
    activeModel: json['activeModel'] ?? '',
    useProxy: json['useProxy'] ?? false,
  );

  ApiProvider copyWith({
    String? name,
    String? apiKey,
    String? apiHost,
    String? apiPath,
    List<String>? models,
    String? activeModel,
    bool? useProxy,
  }) => ApiProvider(
    id: id,
    name: name ?? this.name,
    apiMode: apiMode,
    apiKey: apiKey ?? this.apiKey,
    apiHost: apiHost ?? this.apiHost,
    apiPath: apiPath ?? this.apiPath,
    models: models ?? this.models,
    activeModel: activeModel ?? this.activeModel,
    useProxy: useProxy ?? this.useProxy,
  );
}

class ProviderConfigProvider extends ChangeNotifier {
  List<ApiProvider> _providers = [];
  String _activeProviderId = '';
  bool _isLoading = false;

  List<ApiProvider> get providers => _providers;
  String get activeProviderId => _activeProviderId;
  ApiProvider? get activeProvider => _providers.where((p) => p.id == _activeProviderId).firstOrNull;
  bool get isLoading => _isLoading;

  Future<void> loadProviders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('api_providers');
      if (jsonStr != null) {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        final List<dynamic> providersList = json['providers'] ?? [];
        _providers = providersList.map((j) => ApiProvider.fromJson(j)).toList();
        _activeProviderId = json['activeProviderId'] ?? '';
      } else {
        // 初始化默认配置
        _providers = [
          ApiProvider(
            id: 'openai',
            name: 'OpenAI',
            apiHost: 'https://api.openai.com',
            apiPath: '/v1/chat/completions',
            models: ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo'],
            activeModel: 'gpt-4o',
          ),
          ApiProvider(
            id: 'claude',
            name: 'Claude',
            apiHost: 'https://api.anthropic.com',
            apiPath: '/v1/messages',
            models: ['claude-sonnet-4', 'claude-opus-4'],
          ),
          ApiProvider(
            id: 'custom',
            name: '自定义接入',
          ),
        ];
        _activeProviderId = 'openai';
        await _saveToPrefs();
      }
    } catch (e) {
      debugPrint('加载服务商配置失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProvider(ApiProvider provider) async {
    _providers.add(provider);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateProvider(String id, ApiProvider updatedProvider) async {
    final index = _providers.indexWhere((p) => p.id == id);
    if (index != -1) {
      _providers[index] = updatedProvider;
      if (id == _activeProviderId) {
        _activeProviderId = updatedProvider.id;
      }
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> removeProvider(String id) async {
    _providers.removeWhere((p) => p.id == id);
    if (_activeProviderId == id) {
      _activeProviderId = _providers.isNotEmpty ? _providers.first.id : '';
    }
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setActiveProvider(String id) async {
    _activeProviderId = id;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setApiKey(String providerId, String apiKey) async {
    final index = _providers.indexWhere((p) => p.id == providerId);
    if (index != -1) {
      _providers[index] = _providers[index].copyWith(apiKey: apiKey);
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> setModels(String providerId, List<String> models) async {
    final index = _providers.indexWhere((p) => p.id == providerId);
    if (index != -1) {
      _providers[index] = _providers[index].copyWith(models: models);
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> setActiveModel(String providerId, String model) async {
    final index = _providers.indexWhere((p) => p.id == providerId);
    if (index != -1) {
      _providers[index] = _providers[index].copyWith(activeModel: model);
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = {
      'providers': _providers.map((p) => p.toJson()).toList(),
      'activeProviderId': _activeProviderId,
    };
    await prefs.setString('api_providers', jsonEncode(json));
  }
}
