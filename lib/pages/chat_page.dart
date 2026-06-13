import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/provider_config_provider.dart';
import '../providers/diary_provider.dart';
import '../providers/project_provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/observation_provider.dart';
import '../providers/memory_provider.dart';
import '../services/observation_service.dart';
import '../widgets/theme_colors.dart';
import '../widgets/moon_icon.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showConversationList = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProviderConfig();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncProviderConfig() {
    final config = context.read<ProviderConfigProvider>();
    final chat = context.read<ChatProvider>();
    chat.configureFrom(config.activeProvider);
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatProvider>();

    // 检查 API 是否已配置
    if (chat.apiKey.isEmpty || chat.apiBaseUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('请先在「设置」-「服务商配置」中填写 API Key'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).extension<AppColors>()!.accentWarm,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    _inputController.clear();

    // 如果没有活跃对话，自动创建
    if (chat.activeConversationId == null) {
      chat.createConversation().then((_) {
        chat.sendMessage(text);
      });
    } else {
      chat.sendMessage(text);
    }

    // 消息发送后触发观察层（3秒防抖）
    _triggerObservation(context);

    // 发送后自动滚到底
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _newConversation() {
    final chat = context.read<ChatProvider>();
    chat.createConversation().then((_) {
      setState(() => _showConversationList = false);
    });
  }

  /// 触发观察层：收集所有 Provider 数据并生成观察快照
  void _triggerObservation(BuildContext context) {
    ObservationService.triggerObservation(
      chatProvider: context.read<ChatProvider>(),
      diaryProvider: context.read<DiaryProvider>(),
      projectProvider: context.read<ProjectProvider>(),
      bookshelfProvider: context.read<BookshelfProvider>(),
      todoProvider: context.read<TodoProvider>(),
      observationProvider: context.read<ObservationProvider>(),
      memoryProvider: context.read<MemoryProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final chat = context.watch<ChatProvider>();

    final hasActiveConv = chat.activeConversationId != null &&
        chat.activeConversation != null;

    // 聊天模式：有活跃对话且不在会话列表模式
    if (hasActiveConv && !_showConversationList) {
      // 每次 build 时同步最新 API 配置（用户在设置页保存后自动生效）
      final config = context.watch<ProviderConfigProvider>();
      chat.configureFrom(config.activeProvider);
      
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              _ChatHeader(
                colors: colors,
                title: chat.activeConversation!.title,
                onBack: () => setState(() => _showConversationList = true),
                onNew: _newConversation,
              ),
              // 消息气泡列表
              Expanded(
                child: chat.messages.isEmpty
                    ? _EmptyChat(colors: colors, onSend: _sendMessage)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i == chat.messages.length && chat.isLoading) {
                            return _LoadingBubble(colors: colors);
                          }
                          final msg = chat.messages[i];
                          final isUser = msg.role == 'user';
                          return _MessageBubble(
                            colors: colors,
                            content: msg.content,
                            isUser: isUser,
                            time: msg.timestamp,
                          );
                        },
                      ),
              ),
              // 输入区
              _InputBar(
                colors: colors,
                controller: _inputController,
                onSend: _sendMessage,
                isLoading: chat.isLoading,
                apiConfigured: chat.apiKey.isNotEmpty && chat.apiBaseUrl.isNotEmpty,
              ),
            ],
          ),
        ),
      );
    }

    // 会话列表模式
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(colors: colors, onNewConv: _newConversation),
            Expanded(
              child: chat.conversations.isEmpty
                  ? _EmptyState(colors: colors,
                      text: '还没有对话\n点击右下角开始第一句')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: chat.conversations.length,
                      itemBuilder: (ctx, i) {
                        final conv = chat.conversations[i];
                        return _ConversationCard(
                          colors: colors,
                          title: conv.title,
                          messageCount: conv.messageCount,
                          modelName: conv.modelName,
                          updatedAt: conv.updatedAt,
                          isActive: conv.id == chat.activeConversationId,
                          onTap: () {
                            chat.switchConversation(conv.id);
                            setState(() => _showConversationList = false);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newConversation,
        backgroundColor: colors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 聊天对话模式：顶部栏
// ═══════════════════════════════════════════════
class _ChatHeader extends StatelessWidget {
  final AppColors colors;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onNew;

  const _ChatHeader({
    required this.colors,
    required this.title,
    required this.onBack,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.mainText),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: TextStyle(
              fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
              fontSize: 16, color: colors.mainText,
            )),
          ),
          GestureDetector(
            onTap: onNew,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('新对话', style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 12, color: colors.accent,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 消息气泡
// ═══════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final AppColors colors;
  final String content;
  final bool isUser;
  final DateTime time;

  const _MessageBubble({
    required this.colors,
    required this.content,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? colors.accent : colors.cardSurface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
              border: isUser ? null : Border.all(color: colors.border, width: 0.5),
            ),
            child: Text(content, style: TextStyle(
              fontFamily: 'NotoSansSC',
              fontSize: 15,
              color: isUser ? Colors.white : colors.mainText,
              height: 1.4,
            )),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: EdgeInsets.only(left: isUser ? 0 : 4, right: isUser ? 4 : 0),
            child: Text(timeStr, style: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 10, color: colors.mutedText,
            )),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 加载气泡
// ═══════════════════════════════════════════════
class _LoadingBubble extends StatelessWidget {
  final AppColors colors;
  const _LoadingBubble({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text('正在思考…', style: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 13, color: colors.secondaryText,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 空聊天提示
// ═══════════════════════════════════════════════
class _EmptyChat extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onSend;
  const _EmptyChat({required this.colors, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text('开始对话吧\n在下方输入你想说的话', textAlign: TextAlign.center, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText, height: 1.5,
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 输入栏
// ═══════════════════════════════════════════════
class _InputBar extends StatelessWidget {
  final AppColors colors;
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool apiConfigured;

  const _InputBar({
    required this.colors,
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.apiConfigured,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 12, right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isLoading && apiConfigured,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (!isLoading && apiConfigured) ? (_) => onSend() : null,
              decoration: InputDecoration(
                hintText: !apiConfigured
                    ? '请先配置 API Key'
                    : (isLoading ? '等待回复中…' : '输入消息…'),
                hintStyle: TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText,
                ),
                filled: true,
                fillColor: colors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontFamily: 'NotoSansSC', fontSize: 15, color: colors.mainText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: (!isLoading && apiConfigured) ? onSend : null,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: (!isLoading && apiConfigured) ? colors.accent : colors.mutedText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(
                isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                size: 18, color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// 会话列表模式：顶部栏
// ═══════════════════════════════════════════════
class _Header extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onNewConv;
  const _Header({required this.colors, required this.onNewConv});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ThemeColors.backIcon(context),
          ),
          const Spacer(),
          Column(
            children: [
              Text('聊天室', style: TextStyle(
                fontFamily: 'NotoSerifSC', fontWeight: FontWeight.w700,
                fontSize: 20, color: colors.mainText,
              )),
              Text('Chat · 和我说说话', style: TextStyle(
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

// ═══════════════════════════════════════════════
// 会话卡片
// ═══════════════════════════════════════════════
class _ConversationCard extends StatelessWidget {
  final AppColors colors;
  final String title;
  final int messageCount;
  final String modelName;
  final DateTime updatedAt;
  final bool isActive;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.colors,
    required this.title,
    required this.messageCount,
    required this.modelName,
    required this.updatedAt,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? colors.accent.withOpacity(0.08) : colors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? colors.accent : colors.border,
            width: isActive ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: colors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.chat_bubble_outline, color: colors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontFamily: 'NotoSansSC', fontWeight: FontWeight.w600,
                    fontSize: 15, color: colors.mainText,
                  )),
                  const SizedBox(height: 4),
                  Text('$messageCount 条消息 · $modelName', style: TextStyle(
                    fontFamily: 'NotoSansSC', fontSize: 12, color: colors.secondaryText,
                  )),
                ],
              ),
            ),
            Text(_formatTime(updatedAt), style: TextStyle(
              fontFamily: 'NotoSansSC', fontSize: 11, color: colors.mutedText,
            )),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════
// 空状态
// ═══════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final String text;
  const _EmptyState({required this.colors, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: TextStyle(
            fontFamily: 'NotoSansSC', fontSize: 14, color: colors.mutedText, height: 1.5,
          )),
        ],
      ),
    );
  }
}
