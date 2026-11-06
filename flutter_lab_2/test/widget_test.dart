import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab_2/main.dart';
import 'package:flutter_lab_2/models/user.dart';
import 'package:flutter_lab_2/models/bank_account.dart';
import 'package:flutter_lab_2/models/book.dart';
import 'package:flutter_lab_2/models/magazine.dart';
import 'package:flutter_lab_2/models/library.dart';

void main() {
  test('Optional user fields and late account initialization', () {
    expect(User(name: 'Ana').getDisplayAge(), 'Age not specified');
    expect(User(name: 'Ana', age: 20).getDisplayAge(), '20');
    final account = BankAccount(holderName: 'Ana');
    expect(account.balance, 0.0);
    expect(account.isAccountNumberSet(), isFalse);
    account.initializeAccount('RO001');
    expect(account.isAccountNumberSet(), isTrue);
    expect(account.accountNumber, 'RO001');
  });

  test('Validation, nullable searches, and recent publications', () {
    final library = Library();
    final book = Book(title: 'Dart', author: 'Ana');
    final recent = Magazine(
      title: 'Science',
      publishDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    expect(library.addItem(Book(title: '  ')), isFalse);
    expect(library.addItem(book), isTrue);
    expect(library.addItem(book), isFalse);
    library.addItem(recent);
    expect(library.searchByTitle(null), isEmpty);
    expect(library.getItemsByAuthor(null), isEmpty);
    expect(library.getRecentItems(null), isEmpty);
    expect(library.searchByTitle(' DAR '), [book]);
    expect(library.getItemsByAuthor('ana'), [book]);
    expect(
      library.getRecentItems(
        DateTime.now().subtract(const Duration(days: 365)),
      ),
      [recent],
    );
  });

  test('Borrowing is protected and returning clears both fields', () {
    final library = Library();
    final book = Book(title: 'Dart');
    final ana = User(name: 'Ana');
    final due = DateTime.now().add(const Duration(days: 14));
    expect(library.borrowItem(book, ana, due), isFalse);
    library.addItem(book);
    expect(library.borrowItem(book, ana, due), isTrue);
    expect(library.borrowItem(book, User(name: 'Mihai'), due), isFalse);
    expect(book.borrower, ana);
    expect(book.dueDate, due);
    expect(library.returnItem(book), isTrue);
    expect(book.borrower, isNull);
    expect(book.dueDate, isNull);
    expect(library.returnItem(book), isFalse);
  });

  testWidgets('Users and accounts display missing fields safely', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Maria'), findsOneWidget);
    expect(find.textContaining('Age not specified'), findsOneWidget);
    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Not initialized'), findsOneWidget);
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('The Hobbit'), findsOneWidget);
    await tester.tap(find.text('Borrow').first);
    await tester.pump();
    expect(find.textContaining('Borrower: Ana'), findsOneWidget);
    await tester.tap(find.text('Return').first);
    await tester.pump();
    expect(find.textContaining('Borrower: Ana'), findsNothing);
  });
}
