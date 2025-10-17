import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:opennutritracker/core/presentation/widgets/custom_scrollable_table.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/validation_feedback_widget.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessageEntity message;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;
  final bool showDebugMessages;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onDelete,
    this.onRetry,
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
                    border: isFunctionCall 
                        ? Border.all(color: Colors.orange, width: 2) 
                        : widget.message.hasValidationFailure 
                            ? Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1)
                            : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isFunctionCall 
                          ? _buildFunctionCallWidget(context)
                          : _buildTextMessageWidget(context),
                      // Add validation feedback for assistant messages
                      if (widget.message.type == ChatMessageType.assistant && 
                          widget.message.validationResult != null)
                        ValidationFeedbackWidget(
                          validationResult: widget.message.validationResult!,
                          onRetry: widget.onRetry,
                          showDebugInfo: widget.showDebugMessages,
                        ),
                    ],
                  ),
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
                color: Colors.white,
                fontWeight: FontWeight.w500,
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
        : _buildMarkdownContent(context);
  }

  Widget _buildMarkdownContent(BuildContext context) {
    // Check if content contains tables for enhanced rendering
    if (_containsTable(widget.message.content)) {
      return _buildContentWithEnhancedTables(context);
    }
    
    return MarkdownBody(
      data: widget.message.content,
      builders: {
        'table': ScrollableTableBuilder(),
      },
      extensionSet: md.ExtensionSet.gitHubFlavored,
      styleSheet: _getMarkdownStyleSheet(context),
      onTapLink: (url, title, content) {
        // Handle link taps if needed
      },
    );
  }

  Widget _buildContentWithEnhancedTables(BuildContext context) {
    final parts = _splitContentByTables(widget.message.content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part.isTable) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomScrollableTable(
              headers: part.headers,
              tableData: part.rows,
              maxHeight: 400,
              columnWidth: 150,
              columnSpacing: 16,
              headerColor: Colors.grey.shade700,
              bodyColor: Colors.grey.shade800,
              borderColor: Colors.grey.shade600,
              headerTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              bodyTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              stickyHeader: true,
            ),
          );
        } else {
          return MarkdownBody(
            data: part.content,
            styleSheet: _getMarkdownStyleSheet(context),
            extensionSet: md.ExtensionSet.gitHubFlavored,
            onTapLink: (url, title, content) {
              // Handle link taps if needed
            },
          );
        }
      }).toList(),
    );
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
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
      strong: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      em: const TextStyle(
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
      listBullet: const TextStyle(color: Colors.white),
      tableHead: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      tableBody: const TextStyle(color: Colors.white),
    );
  }

  bool _containsTable(String content) {
    return content.contains('|') && content.contains('---');
  }

  List<ContentPart> _splitContentByTables(String content) {
    final parts = <ContentPart>[];
    final lines = content.split('\n');
    
    List<String> currentTextLines = [];
    List<String> currentTableLines = [];
    bool inTable = false;
    
    for (String line in lines) {
      if (_isTableLine(line)) {
        if (!inTable) {
          // Starting a table, save any accumulated text
          if (currentTextLines.isNotEmpty) {
            parts.add(ContentPart(
              content: currentTextLines.join('\n'),
              isTable: false,
            ));
            currentTextLines.clear();
          }
          inTable = true;
        }
        currentTableLines.add(line);
      } else {
        if (inTable) {
          // Ending a table, save the table
          parts.add(_parseTablePart(currentTableLines));
          currentTableLines.clear();
          inTable = false;
        }
        currentTextLines.add(line);
      }
    }
    
    // Handle remaining content
    if (currentTableLines.isNotEmpty) {
      parts.add(_parseTablePart(currentTableLines));
    }
    if (currentTextLines.isNotEmpty) {
      parts.add(ContentPart(
        content: currentTextLines.join('\n'),
        isTable: false,
      ));
    }
    
    return parts;
  }

  bool _isTableLine(String line) {
    return line.trim().startsWith('|') || line.contains('---');
  }

  ContentPart _parseTablePart(List<String> tableLines) {
    final headers = <String>[];
    final rows = <List<String>>[];
    
    for (int i = 0; i < tableLines.length; i++) {
      final line = tableLines[i].trim();
      if (line.contains('---')) continue; // Skip separator line
      
      final cells = line.split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty)
          .toList();
      
      if (headers.isEmpty) {
        headers.addAll(cells);
      } else {
        rows.add(cells);
      }
    }
    
    return ContentPart(
      content: '',
      isTable: true,
      headers: headers,
      rows: rows,
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
      final tableData = _parseTableData(element);
      
      final hasHeader = _hasTableHeader(element);
      final headers = hasHeader && tableData.isNotEmpty ? tableData.first : <String>[];
      final rows = hasHeader && tableData.isNotEmpty ? tableData.skip(1).toList() : tableData;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CustomScrollableTable(
          headers: headers,
          tableData: rows,
          maxHeight: 400,
          columnWidth: 150,
          columnSpacing: 16,
          headerColor: Colors.grey.shade700,
          bodyColor: Colors.grey.shade800,
          borderColor: Colors.grey.shade600,
          headerTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          bodyTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          stickyHeader: true,
        ),
      );
    }
    return null;
  }

  List<List<String>> _parseTableData(md.Element element) {
    final tableData = <List<String>>[];
    
    for (final child in element.children ?? []) {
      final section = child as md.Element;
      
      // Handle thead, tbody, or direct tr elements
      final rowElements = section.tag == 'tr' 
          ? [section] 
          : section.children?.where((e) => (e as md.Element).tag == 'tr').cast<md.Element>().toList() ?? [];
      
      for (final rowElement in rowElements) {
        final cellData = <String>[];
        for (final cellElement in rowElement.children ?? []) {
          final cell = cellElement as md.Element;
          cellData.add(cell.textContent.trim());
        }
        if (cellData.isNotEmpty) {
          tableData.add(cellData);
        }
      }
    }
    
    return tableData;
  }

  bool _hasTableHeader(md.Element element) {
    // Check if first section is thead or if first row contains th elements
    final firstChild = element.children?.first as md.Element?;
    if (firstChild?.tag == 'thead') return true;
    
    // Check if first row has th elements
    final firstRow = element.children?.first as md.Element?;
    if (firstRow?.tag == 'tr') {
      final firstCell = firstRow?.children?.first as md.Element?;
      return firstCell?.tag == 'th';
    }
    
    return false;
  }
}

class ContentPart {
  final String content;
  final bool isTable;
  final List<String> headers;
  final List<List<String>> rows;
  
  ContentPart({
    required this.content,
    required this.isTable,
    this.headers = const [],
    this.rows = const [],
  });
} 