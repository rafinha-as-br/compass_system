import 'package:flutter/material.dart';

/// A column of [AppDataTable]: header label, width, and how to render each
/// row's cell from item [T].
///
/// [headerBuilder] lets a custom widget replace the default header
/// (`Text(label)`) — e.g. a "select all" checkbox in a bulk-selection
/// column. [label] is still required even when [headerBuilder] is given, to
/// keep a textual description of the column available.
class AppDataColumn<T> {
  final String label;
  final TableColumnWidth width;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final WidgetBuilder? headerBuilder;

  const AppDataColumn({
    required this.label,
    required this.width,
    required this.cellBuilder,
    this.headerBuilder,
  });
}

/// Generic table for record listings, ported from Geoprag's
/// `GeopragDataTable` (CPS-104) so every Travel Matrix listing can share the
/// same "whole row is clickable, no actions column" pattern — like an email
/// client — instead of each screen hand-rolling its own [DataTable].
///
/// Each row uses [TableRowInkWell] so the tap highlight covers every cell in
/// the row, not just one. If [onRowTap] is not given, rows aren't clickable
/// (only the table formatting is reused).
///
/// Trade-off accepted: [Table] has no horizontal scroll or sorting, unlike
/// [DataTable].
class AppDataTable<T> extends StatelessWidget {
  final List<AppDataColumn<T>> columns;
  final List<T> items;
  final void Function(BuildContext context, T item)? onRowTap;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Table(
      border: TableBorder.all(color: colorScheme.outlineVariant),
      columnWidths: {
        for (var i = 0; i < columns.length; i++) i: columns[i].width,
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
          children: [
            for (final column in columns)
              Padding(
                padding: const EdgeInsets.all(12),
                child: column.headerBuilder != null
                    ? column.headerBuilder!(context)
                    : Text(
                        column.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
          ],
        ),
        for (final item in items) _buildRow(context, item),
      ],
    );
  }

  TableRow _buildRow(BuildContext context, T item) {
    Widget cell(Widget child) {
      final withPadding = Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      );
      if (onRowTap == null) return withPadding;
      return TableRowInkWell(
        onTap: () => onRowTap!(context, item),
        child: withPadding,
      );
    }

    return TableRow(
      children: [
        for (final column in columns) cell(column.cellBuilder(context, item)),
      ],
    );
  }
}
