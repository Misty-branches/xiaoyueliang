import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/provider_config_provider.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';

/// 服务商详情页 — 双 Tab 布局
///
/// Tab 1「配置」：API 连接参数 + 检查连接
/// Tab 2「模型」：从 API 获取的可用模型列表
class ProviderDetailPage extends StatefulWidget {
  final ApiProvider provider;

  const ProviderDetailPage({super.key, required this.provider});

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 配置表单
  late TextEditingController _nameCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _hostCtrl;
  late TextEditingController _pathCtrl;
  late bool _useProxy;
  bool _showKey = false;

  // 检查连接状态
  bool _checking = false;
  String? _checkResult;
  bool _checkSuccess = false;
  List<String> _fetchedModels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameCtrl = TextEditingController(text: widget.provider.name);
    _keyCtrl = TextEditingController(text: widget.provider.apiKey);
    _hostCtrl = TextEditingController(text: widget.provider.apiHost);
    _pathCtrl = TextEditingController(text: widget.provider.apiPath);
    _useProxy = widget.provider.useProxy;
    // 如果已经有模型就显示
    _fetchedModels = List<String>.from(widget.provider.models);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _hostCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final providerConfig = context.watch<ProviderConfigProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors, providerConfig),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConfigTab(context, colors, providerConfig),
                _buildModelsTab(context, colors, providerConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    return AppBar(
      backgroundColor: colors.cardSurface,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: ThemeColors.backIcon(context),
      ),
      title: Text(
        widget.provider.name,
        style: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: colors.mainText,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _deleteProvider(context, providerConfig),
          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: colors.accent,
        unselectedLabelColor: colors.mutedText,
        indicatorColor: colors.accent,
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: '配置'),
          Tab(text: '模型'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 1：配置
  // ═══════════════════════════════════════════
  Widget _buildConfigTab(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称
          _buildField(colors, '名称', _nameCtrl),
          const SizedBox(height: 20),
          // API Key
          _buildKeyField(colors),
          const SizedBox(height: 20),
          // API Host
          _buildField(colors, 'API 主机', _hostCtrl, hint: 'https://api.deepseek.com'),
          const SizedBox(height: 20),
          // API 路径（不可编辑）
          _buildField(colors, 'API 路径', _pathCtrl, hint: '/v1/chat/completions',
              enabled: false),
          const SizedBox(height: 20),
          // 网络兼容
          _buildToggleField(colors, '改善网络兼容性', '启用代理和重试机制', _useProxy,
              (v) => setState(() => _useProxy = v)),
          const SizedBox(height: 24),
          // 检查连接按钮
          _buildCheckButton(colors),
          const SizedBox(height: 16),
          // 检查结果
          if (_checkResult != null)
            _buildCheckResultCard(colors),
          const SizedBox(height: 24),
          // 保存
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveProvider(context, providerConfig),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('保存', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 15, fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 检查连接
  // ═══════════════════════════════════════════
  Widget _buildCheckButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _checking ? null : _checkConnection,
        icon: _checking
            ? SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: colors.accent,
                ),
              )
            : Icon(Icons.wifi_find, size: 18),
        label: Text(
          _checking ? '正在检查连接…' : '检查连接并获取可用模型',
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accent,
          side: BorderSide(color: colors.accent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckResultCard(AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _checkSuccess ? colors.accent.withOpacity(0.08) : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _checkSuccess ? colors.accent.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _checkSuccess ? Icons.check_circle : Icons.error_outline,
            size: 20,
            color: _checkSuccess ? colors.accent : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _checkSuccess ? '连接成功' : '连接失败',
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _checkSuccess ? colors.accent : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _checkResult!,
                  style: TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 12,
                    color: colors.secondaryText,
                    height: 1.4,
                  ),
                ),
                if (_checkSuccess && _fetchedModels.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '已获取 ${_fetchedModels.length} 个可用模型，切换到「模型」Tab 查看',
                    style: TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontSize: 11,
                      color: colors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkConnection() async {
    final host = _hostCtrl.text.trim();
    final key = _keyCtrl.text.trim();

    if (host.isEmpty || key.isEmpty) {
      setState(() {
        _checkResult = '请先填写 API 主机地址和 API Key';
        _checkSuccess = false;
      });
      return;
    }

    setState(() {
      _checking = true;
      _checkResult = null;
      _fetchedModels = [];
    });

    try {
      // 调用 /v1/models 获取可用模型列表
      final response = await http.get(
        Uri.parse('$host/v1/models'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> modelList = data['data'] ?? [];

        // 提取模型 ID，过滤掉前缀带 "ft:" 的微调模型
        final models = modelList
            .map((m) => m['id'] as String? ?? '')
            .where((id) => id.isNotEmpty && !id.startsWith('ft:'))
            .toList();

        // 按名称排序
        models.sort();

        setState(() {
          _checkSuccess = true;
          _fetchedModels = models;
          _checkResult = '成功获取 ${models.length} 个可用模型';
          // 自动切换到模型 Tab
          _tabController.animateTo(1);
        });
      } else {
        final body = response.body;
        String errorMsg;
        try {
          final err = jsonDecode(body);
          errorMsg = err['error']?['message'] ?? err['error'] ?? body;
        } catch (_) {
          errorMsg = body.length > 200 ? 'HTTP ${response.statusCode}' : body;
        }
        setState(() {
          _checkSuccess = false;
          _checkResult = '请求失败 (${response.statusCode}): $errorMsg';
        });
      }
    } catch (e) {
      setState(() {
        _checkSuccess = false;
        _checkResult = '无法连接到服务器:\n$e';
      });
    } finally {
      setState(() => _checking = false);
    }
  }

  // ═══════════════════════════════════════════
  // Tab 2：模型列表（从 API 获取）
  // ═══════════════════════════════════════════
  Widget _buildModelsTab(
      BuildContext context, AppColors colors, ProviderConfigProvider providerConfig) {
    final activeModel = widget.provider.activeModel;

    // 如果本地还没有保存任何模型，优先展示从 API 获取的
    final displayModels = widget.provider.models.isNotEmpty
        ? widget.provider.models
        : _fetchedModels;

    return Column(
      children: [
        if (!_checkSuccess && _fetchedModels.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_download_outlined, size: 48, color: colors.mutedText),
                  const SizedBox(height: 12),
                  Text('还没有获取模型', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 15, color: colors.secondaryText,
                  )),
                  const SizedBox(height: 6),
                  Text('在「配置」Tab 点击「检查连接」', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mutedText,
                  )),
                  const SizedBox(height: 6),
                  Text('系统会自动获取该 API 支持的模型列表', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 12, color: colors.mutedText,
                  )),
                ],
              ),
            ),
          )
        else if (displayModels.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.model_training, size: 48, color: colors.mutedText),
                  const SizedBox(height: 12),
                  Text('该服务商暂无可用模型', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 15, color: colors.secondaryText,
                  )),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: displayModels.length,
              itemBuilder: (ctx, i) => _buildModelCard(
                colors, displayModels[i], activeModel == displayModels[i],
                providerConfig, displayModels[i] == widget.provider.activeModel),
            ),
          ),

        // 底部操作栏
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.border, width: 0.5)),
          ),
          child: Row(
            children: [
              // 模型计数
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 18, color: colors.accent),
                    const SizedBox(width: 6),
                    Text('${displayModels.length}', style: TextStyle(
                      fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                      fontSize: 14, color: colors.mainText,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // 同步到配置
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchedModels.isEmpty ? null : () {
                    _syncModelsToProvider(providerConfig);
                  },
                  icon: const Icon(Icons.sync, size: 18),
                  label: Text(
                    widget.provider.models.isEmpty ? '同步到当前配置' : '更新模型列表',
                    style: const TextStyle(
                      fontFamily: 'NotoSansSC', fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.mutedText.withOpacity(0.2),
                    disabledForegroundColor: colors.mutedText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 将从 API 获取的模型列表同步到 Provider 配置
  void _syncModelsToProvider(ProviderConfigProvider providerConfig) {
    if (_fetchedModels.isEmpty) return;

    final newActive = widget.provider.activeModel.isNotEmpty
        ? widget.provider.activeModel
        : (_fetchedModels.isNotEmpty ? _fetchedModels.first : '');

    final updated = widget.provider.copyWith(
      models: List<String>.from(_fetchedModels),
      activeModel: newActive,
    );
    providerConfig.updateProvider(widget.provider.id, updated);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已同步 ${_fetchedModels.length} 个模型'),
          backgroundColor: Theme.of(context).extension<AppColors>()!.accent,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════
  // 模型卡片
  // ═══════════════════════════════════════════
  Widget _buildModelCard(AppColors colors, String modelName, bool isActive,
      ProviderConfigProvider providerConfig, bool isSaved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? colors.accent.withOpacity(0.06) : colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? colors.accent : colors.border,
          width: isActive ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.smart_toy_outlined, size: 20, color: colors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modelName, style: TextStyle(
                  fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                  fontSize: 14, color: colors.mainText,
                )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.accentLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('聊天', style: TextStyle(
                        fontFamily: 'NotoSansSC', fontSize: 10, color: colors.accent,
                      )),
                    ),
                    const SizedBox(width: 6),
                    if (!isSaved)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('未同步', style: TextStyle(
                          fontFamily: 'NotoSansSC', fontSize: 9, color: Colors.orange,
                        )),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('当前', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: Colors.white,
                fontWeight: FontWeight.w500,
              )),
            )
          else if (isSaved)
            GestureDetector(
              onTap: () {
                providerConfig.setActiveModel(widget.provider.id, modelName);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.accentLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('使用', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 12, color: colors.accent,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 表单控件
  // ═══════════════════════════════════════════
  Widget _buildField(AppColors colors, String label, TextEditingController ctrl,
      {String? hint, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontFamily: 'NotoSansSC', fontSize: 11, color: colors.secondaryText,
          fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          enabled: enabled,
          style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText,
            ),
            filled: true,
            fillColor: enabled ? colors.cardSurface : colors.cardBase,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.accent),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyField(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API Key', style: TextStyle(
          fontFamily: 'NotoSansSC', fontSize: 11, color: colors.secondaryText,
          fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 8),
        TextField(
          controller: _keyCtrl,
          obscureText: !_showKey,
          style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mainText,
          ),
          decoration: InputDecoration(
            hintText: 'sk-...',
            hintStyle: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText,
            ),
            filled: true,
            fillColor: colors.cardSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.accent),
            ),
            contentPadding: const EdgeInsets.all(14),
            suffixIcon: IconButton(
              icon: Icon(
                _showKey ? Icons.visibility_off : Icons.visibility,
                color: colors.secondaryText, size: 20,
              ),
              onPressed: () => setState(() => _showKey = !_showKey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleField(AppColors colors, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 13, color: colors.mainText,
              )),
              Text(subtitle, style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 11, color: colors.secondaryText,
              )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colors.accent,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 保存 & 删除
  // ═══════════════════════════════════════════
  void _saveProvider(BuildContext context, ProviderConfigProvider providerConfig) {
    // 同步 API Key/Host 到表单值
    final updatedProvider = widget.provider.copyWith(
      name: _nameCtrl.text,
      apiKey: _keyCtrl.text,
      apiHost: _hostCtrl.text,
      apiPath: _pathCtrl.text,
      useProxy: _useProxy,
    );
    providerConfig.updateProvider(widget.provider.id, updatedProvider);

    // 如果已拉取模型且未保存过，自动同步
    if (_fetchedModels.isNotEmpty && widget.provider.models.isEmpty) {
      _syncModelsToProvider(providerConfig);
    } else {
      providerConfig.setActiveProvider(widget.provider.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('配置已保存'),
          backgroundColor: Theme.of(context).extension<AppColors>()!.accent,
        ),
      );
    }
  }

  void _deleteProvider(BuildContext context, ProviderConfigProvider providerConfig) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).extension<AppColors>()!.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('删除服务商', style: TextStyle(
          fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
          color: Theme.of(ctx).extension<AppColors>()!.mainText,
        )),
        content: Text('确定删除 ${widget.provider.name} 吗？', style: TextStyle(
          fontFamily: 'NotoSansSC',
          color: Theme.of(ctx).extension<AppColors>()!.secondaryText,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(
              fontFamily: 'NotoSansSC',
              color: Theme.of(ctx).extension<AppColors>()!.secondaryText,
            )),
          ),
          TextButton(
            onPressed: () {
              providerConfig.removeProvider(widget.provider.id);
              Navigator.pop(ctx);
              Navigator.of(context).maybePop();
            },
            child: Text('删除', style: TextStyle(
              fontFamily: 'NotoSansSC', color: Colors.red[300],
            )),
          ),
        ],
      ),
    );
  }
}
