import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessageEntity message;
  final VoidCallback? onDelete;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == ChatMessageType.user;
    
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
                    color: isUser 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isUser 
                      ? Text(
                          message.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : null,
                          ),
                          textAlign: isUser ? TextAlign.right : TextAlign.left,
                        )
                      : _buildMarkdownWithScrollableTables(context),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (onDelete != null) ...[
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

  Widget _buildMarkdownWithScrollableTables(BuildContext context) {
    return MarkdownBody(
      data: message.content,
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
        strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        em: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
        listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        code: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey.shade700,
          color: Colors.white,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      selectable: true,
      builders: {
        'table': ScrollableTableBuilder(),
      },
    );
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(S.of(context).chatCopyMessage),
              onTap: () {
                Navigator.of(context).pop();
                _copyMessage(context);
              },
            ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  S.of(context).chatDeleteMessage,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).chatMessageCopied)),
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