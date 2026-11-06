import 'package:admd/main.dart';
import 'package:admd/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Todo tab adds trimmed tasks and toggles them independently', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Todo'));
    await tester.pumpAndSettle();

    expect(find.text('No todos yet. Add your first task.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byTooltip('Add todo'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);

    for (final title in ['  Read lab 3  ', 'Try DevTools']) {
      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byTooltip('Add todo'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Read lab 3'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    await tester.tap(find.text('Read lab 3'));
    await tester.pump();
    final tiles = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(tiles[0].value, isTrue);
    expect(tiles[1].value, isFalse);
    await tester.tap(find.text('Read lab 3'));
    await tester.pump();
    expect(
      tester
          .widget<CheckboxListTile>(find.byType(CheckboxListTile).first)
          .value,
      isFalse,
    );
  });
  testWidgets('Swipe and undo preserve row order and checked state', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TodoScreen()));
    for (final title in ['First', 'Middle', 'Last']) {
      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byTooltip('Add todo'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Middle'));
    await tester.pump();
    final middle = find.ancestor(
      of: find.text('Middle'),
      matching: find.byType(Dismissible),
    );
    await tester.drag(middle, const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(find.byType(Dismissible), findsNWidgets(3));
    await tester.drag(middle, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Middle'), findsNothing);
    expect(find.byType(Dismissible), findsNWidgets(2));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    final tiles = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(tiles.map((tile) => (tile.title! as Text).data), [
      'First',
      'Middle',
      'Last',
    ]);
    expect(tiles[1].value, isTrue);
    for (final title in ['First', 'Middle', 'Last']) {
      await tester.drag(
        find.ancestor(of: find.text(title), matching: find.byType(Dismissible)),
        const Offset(-600, 0),
      );
      await tester.pumpAndSettle();
    }
    expect(find.text('No todos yet. Add your first task.'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Last'), findsOneWidget);
    expect(find.byType(Dismissible), findsOneWidget);
  });
}
