import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessageEntity message;
  final VoidCallback? onDelete;
  final bool showDebugMessages;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onDelete,
    this.showDebugMessages = false,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.type == ChatMessageType.user;
    final isFunctionCall = widget.message.type == ChatMessageType.function_call;
    
    // Don't render invisible messages unless debug mode is enabled
    if (!widget.message.isVisible && !widget.showDebugMessages) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getMessageColor(context, widget.message.type),
                    borderRadius: BorderRadius.circular(12),
                    border: isFunctionCall ? Border.all(color: Colors.orange, width: 2) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isFunctionCall 
                      ? _buildFunctionCallWidget(context)
                      : _buildTextMessageWidget(context),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(widget.message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (widget.onDelete != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showMessageOptions(context),
                        child: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCallWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            Text(
              'Function Call',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.orange,
                size: 16,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              widget.message.content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextMessageWidget(BuildContext context) {
    final isUser = widget.message.type == ChatMessageType.user;
    
    return isUser 
        ? Text(
            widget.message.content,
            style: TextStyle(
              color: isUser ? Colors.white : null,
            ),
            textAlign: isUser ? TextAlign.right : TextAlign.left,
          )
        : MarkdownBody(
            data: widget.message.content,
            styleSheet: MarkdownStyleSheet(
              h1: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
              h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
              h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
              p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              strong: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              em: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              code: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                fontFamily: 'monospace',
              ),
              codeblockDecoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              blockquote: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
              listBullet: TextStyle(color: Colors.white),
              tableHead: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              tableBody: TextStyle(color: Colors.white),
            ),
            onTapLink: (url, title, content) {
              // Handle link taps if needed
            },
          );
  }

  Color _getMessageColor(BuildContext context, ChatMessageType type) {
    switch (type) {
      case ChatMessageType.user:
        return Theme.of(context).primaryColor;
      case ChatMessageType.assistant:
        return Theme.of(context).cardColor;
      case ChatMessageType.function_call:
        return Colors.orange.withValues(alpha: 0.1);
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(S.of(context).chatDeleteMessage),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(S.of(context).chatCopyMessage),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollableTableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'table') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildTable(element),
      );
    }
    return null;
  }

  Widget _buildTable(md.Element element) {
    final rows = element.children ?? [];
    if (rows.isEmpty) return const SizedBox.shrink();

    final tableRows = <TableRow>[];
    
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i] as md.Element;
      final cells = row.children ?? [];
      final tableCells = <Widget>[];

      for (final cell in cells) {
        final cellElement = cell as md.Element;
        final isHeader = row.tag == 'thead' || (i == 0 && (element.children!.first as md.Element).tag != 'thead');
        tableCells.add(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHeader ? Colors.grey.shade700 : Colors.grey.shade800,
              border: Border.all(color: Colors.grey.shade600, width: 1),
            ),
            child: Text(
              cellElement.textContent,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }
      
      tableRows.add(TableRow(children: tableCells));
    }

    return Table(
      children: tableRows,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    );
  }
} 