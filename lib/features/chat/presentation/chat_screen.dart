import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_usecase.dart';
import 'package:opennutritracker/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/chat_message_widget.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/chat_settings_dialog.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = locator<ChatBloc>();
    _chatBloc.add(LoadChatEvent());
    
    // Ensure scroll to bottom when chat is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).chatTitle),
        actions: [
          BlocBuilder<ChatBloc, ChatState>(
            bloc: _chatBloc,
            builder: (context, state) {
              if (state is ChatLoaded && state.messages.isNotEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Debug toggle button
                    IconButton(
                      onPressed: () {
                        _chatBloc.add(ToggleDebugModeEvent());
                      },
                      icon: Icon(
                        state.showDebugMessages ? Icons.bug_report : Icons.bug_report_outlined,
                        color: state.showDebugMessages ? Colors.orange : null,
                      ),
                      tooltip: 'Toggle Debug Messages',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'clear') {
                          _showClearHistoryDialog();
                        } else if (value == 'settings') {
                          _showChatSettings();
                        } else if (value == 'debug') {
                          _clearAllData();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'settings',
                          child: Text(S.of(context).chatSettingsLabel),
                        ),
                        PopupMenuItem(
                          value: 'clear',
                          child: Text(S.of(context).chatClearHistory),
                        ),
                        PopupMenuItem(
                          value: 'debug',
                          child: Text('Debug: Clear All Data'),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (state is ChatLoaded) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Debug toggle button
                    IconButton(
                      onPressed: () {
                        _chatBloc.add(ToggleDebugModeEvent());
                      },
                      icon: Icon(
                        state.showDebugMessages ? Icons.bug_report : Icons.bug_report_outlined,
                        color: state.showDebugMessages ? Colors.orange : null,
                      ),
                      tooltip: 'Toggle Debug Messages',
                    ),
                    IconButton(
                      onPressed: _showChatSettings,
                      icon: const Icon(Icons.settings),
                    ),
                    IconButton(
                      onPressed: _clearAllData,
                      icon: const Icon(Icons.bug_report),
                      tooltip: 'Debug: Clear All Data',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: _chatBloc,
        listener: (context, state) {
          if (state is ChatApiKeySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).chatApiKeySuccess)),
            );
            _chatBloc.add(LoadChatEvent());
          } else if (state is ChatApiKeyRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).chatApiKeyRemoved)),
            );
            _chatBloc.add(LoadChatEvent());
          } else if (state is ChatHistoryCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).chatClearHistorySuccess)),
            );
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ChatLoaded && state.messages.isNotEmpty) {
            // Auto-scroll to bottom when new messages are added
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) {
          if (state is ChatInitial || state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatNoApiKey) {
            return _buildApiKeySetup();
          } else if (state is ChatLoaded) {
            return _buildChatInterface(state);
          } else if (state is ChatError) {
            return _buildChatInterfaceWithError(state);
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }

  Widget _buildApiKeySetup() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).chatApiKeyTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).chatApiKeySubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showChatSettings,
            icon: const Icon(Icons.settings),
            label: Text(S.of(context).chatSettingsLabel),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).chatWelcome,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface(ChatLoaded state) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return ChatMessageWidget(
                  message: message,
                  onDelete: () => _chatBloc.add(DeleteMessageEvent(message.id)),
                  showDebugMessages: state.showDebugMessages,
                );
              },
            ),
          ),
          if (state.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Text(S.of(context).chatLoading),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatInterfaceWithError(ChatError state) {
    return SafeArea(
      child: Column(
        children: [
          // Error banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade100,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Retry the last message
                    if (state.messages.isNotEmpty) {
                      final lastMessage = state.messages.last;
                      if (lastMessage.type == ChatMessageType.user) {
                        _chatBloc.add(SendMessageEvent(lastMessage.content));
                      }
                    }
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return ChatMessageWidget(
                  message: message,
                  onDelete: () => _chatBloc.add(DeleteMessageEvent(message.id)),
                  showDebugMessages: state.showDebugMessages,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 48,
                  maxHeight: 120,
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: S.of(context).chatPlaceholder,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatBloc.add(SendMessageEvent(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showChatSettings() {
    showDialog(
      context: context,
      builder: (context) => const ChatSettingsDialog(),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).chatClearHistory),
        content: Text(S.of(context).chatClearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _chatBloc.add(ClearChatHistoryEvent());
            },
            child: Text(S.of(context).buttonYesLabel),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug: Clear All Data'),
        content: const Text('This will clear all chat data including API key and custom models. This is for debugging only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear all data and reload
              locator<ChatUsecase>().clearAllChatData();
              _chatBloc.add(LoadChatEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
} 