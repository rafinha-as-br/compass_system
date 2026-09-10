import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/shared/widgets/app_data_table.dart';

class _Item {
  final String name;
  final String city;

  const _Item(this.name, this.city);
}

const _items = [_Item('Ana', 'Recife'), _Item('Bruno', 'Salvador')];

List<AppDataColumn<_Item>> _columns() => [
  AppDataColumn(
    label: 'Nome',
    width: const FlexColumnWidth(),
    cellBuilder: (context, item) => Text(item.name),
  ),
  AppDataColumn(
    label: 'Cidade',
    width: const FlexColumnWidth(),
    cellBuilder: (context, item) => Text(item.city),
  ),
];

Widget _wrap({void Function(BuildContext context, _Item item)? onRowTap}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: AppDataTable<_Item>(columns: _columns(), items: _items, onRowTap: onRowTap),
    ),
  );
}

void main() {
  testWidgets('renders header labels and every row cell', (tester) async {
    await tester.pumpWidget(_wrap());

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Cidade'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Recife'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
    expect(find.text('Salvador'), findsOneWidget);
  });

  testWidgets('tapping any cell in a row triggers onRowTap with that row\'s item', (tester) async {
    _Item? tapped;
    await tester.pumpWidget(_wrap(onRowTap: (context, item) => tapped = item));

    // Toca na célula da segunda coluna (Cidade) da primeira linha (Ana) —
    // prova que TableRowInkWell cobre a linha toda, não só a célula tocada.
    await tester.tap(find.text('Recife'));
    await tester.pump();

    expect(tapped, _items[0]);
  });

  testWidgets('rows are not clickable when onRowTap is not given', (tester) async {
    await tester.pumpWidget(_wrap());

    expect(find.byType(TableRowInkWell), findsNothing);
  });

  testWidgets('border and header background come from theme, not hardcoded colors', (tester) async {
    await tester.pumpWidget(_wrap());

    final table = tester.widget<Table>(find.byType(Table));
    final border = table.border as TableBorder;
    expect(border.top.color, AppTheme.lightTheme.colorScheme.outlineVariant);

    final headerRow = table.children.first;
    final decoration = headerRow.decoration as BoxDecoration;
    expect(decoration.color, AppTheme.lightTheme.colorScheme.surfaceContainerHighest);
  });
}
