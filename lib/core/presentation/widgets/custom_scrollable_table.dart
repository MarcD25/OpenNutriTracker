import 'package:flutter/material.dart';

/// A custom scrollable table widget that provides enhanced table rendering
/// with horizontal and vertical scrolling, sticky headers, and proper spacing.
class CustomScrollableTable extends StatefulWidget {
  final List<String> headers;
  final List<List<String>> tableData;
  final double? maxHeight;
  final double columnWidth;
  final double columnSpacing;
  final Color? headerColor;
  final Color? bodyColor;
  final Color? borderColor;
  final TextStyle? headerTextStyle;
  final TextStyle? bodyTextStyle;
  final bool stickyHeader;

  const CustomScrollableTable({
    super.key,
    required this.headers,
    required this.tableData,
    this.maxHeight = 400,
    this.columnWidth = 150,
    this.columnSpacing = 16,
    this.headerColor,
    this.bodyColor,
    this.borderColor,
    this.headerTextStyle,
    this.bodyTextStyle,
    this.stickyHeader = true,
  });

  @override
  State<CustomScrollableTable> createState() => _CustomScrollableTableState();
}

class _CustomScrollableTableState extends State<CustomScrollableTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Sync horizontal scrolling between header and body
    _horizontalController.addListener(_syncHeaderScroll);
  }

  @override
  void dispose() {
    _horizontalController.removeListener(_syncHeaderScroll);
    _horizontalController.dispose();
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    super.dispose();
  }

  void _syncHeaderScroll() {
    if (widget.stickyHeader && _headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_horizontalController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = widget.headerColor ?? theme.colorScheme.surfaceVariant;
    final bodyColor = widget.bodyColor ?? theme.colorScheme.surface;
    final borderColor = widget.borderColor ?? theme.dividerColor;
    
    final headerTextStyle = widget.headerTextStyle ?? 
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        );
    
    final bodyTextStyle = widget.bodyTextStyle ?? 
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        );

    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Sticky header
          if (widget.stickyHeader && widget.headers.isNotEmpty)
            _buildStickyHeader(headerColor, borderColor, headerTextStyle),
          
          // Scrollable body
          Expanded(
            child: _buildScrollableBody(bodyColor, borderColor, bodyTextStyle, headerTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(Color headerColor, Color borderColor, TextStyle? headerTextStyle) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: SingleChildScrollView(
        controller: _headerHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Controlled by body scroll
        child: Row(
          children: widget.headers.asMap().entries.map((entry) {
            final index = entry.key;
            final header = entry.value;
            return _buildHeaderCell(header, headerTextStyle, borderColor, isLast: index == widget.headers.length - 1);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScrollableBody(Color bodyColor, Color borderColor, TextStyle? bodyTextStyle, TextStyle? headerTextStyle) {
    return SingleChildScrollView(
      controller: _verticalController,
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header row (if not sticky)
            if (!widget.stickyHeader && widget.headers.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: widget.headerColor ?? Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Row(
                  children: widget.headers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final header = entry.value;
                    return _buildHeaderCell(header, headerTextStyle, borderColor, isLast: index == widget.headers.length - 1);
                  }).toList(),
                ),
              ),
            
            // Data rows
            ...widget.tableData.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final rowData = entry.value;
              final isLastRow = rowIndex == widget.tableData.length - 1;
              
              return Container(
                decoration: BoxDecoration(
                  color: rowIndex.isEven ? bodyColor : bodyColor.withOpacity(0.5),
                ),
                child: Row(
                  children: _buildDataRow(rowData, bodyTextStyle, borderColor, isLastRow),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextStyle? textStyle, Color borderColor, {required bool isLast}) {
    return Container(
      width: widget.columnWidth,
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: widget.columnSpacing / 2, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  List<Widget> _buildDataRow(List<String> rowData, TextStyle? textStyle, Color borderColor, bool isLastRow) {
    return rowData.asMap().entries.map((entry) {
      final index = entry.key;
      final cellData = entry.value;
      final isLast = index == rowData.length - 1;
      
      return Container(
        width: widget.columnWidth,
        constraints: const BoxConstraints(minHeight: 48),
        padding: EdgeInsets.symmetric(horizontal: widget.columnSpacing / 2, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            right: isLast ? BorderSide.none : BorderSide(color: borderColor, width: 0.5),
            bottom: isLastRow ? BorderSide.none : BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            cellData,
            style: textStyle,
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      );
    }).toList();
  }
}

/// Helper class to parse markdown table content
class TableContentParser {
  static TableContent parseMarkdownTable(String markdownContent) {
    final lines = markdownContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) {
      return TableContent(headers: [], rows: []);
    }

    final headers = <String>[];
    final rows = <List<String>>[];
    
    bool foundSeparator = false;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.contains('---') || line.contains('===')) {
        foundSeparator = true;
        continue;
      }
      
      if (_isTableRow(line)) {
        final cells = _parseTableRow(line);
        
        if (cells.isNotEmpty) {
          if (headers.isEmpty && !foundSeparator) {
            headers.addAll(cells);
          } else {
            rows.add(cells);
          }
        }
      }
    }
    
    return TableContent(headers: headers, rows: rows);
  }
  
  static bool _isTableRow(String line) {
    return line.startsWith('|') && line.endsWith('|');
  }
  
  static List<String> _parseTableRow(String line) {
    return line
        .substring(1, line.length - 1) // Remove leading and trailing |
        .split('|')
        .map((cell) => cell.trim())
        .toList();
  }
}

/// Data class to hold parsed table content
class TableContent {
  final List<String> headers;
  final List<List<String>> rows;
  
  const TableContent({
    required this.headers,
    required this.rows,
  });
  
  bool get isEmpty => headers.isEmpty && rows.isEmpty;
  bool get hasHeaders => headers.isNotEmpty;
}