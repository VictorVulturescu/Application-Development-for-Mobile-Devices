import 'package:flutter/material.dart';

import 'models/user.dart';
import 'models/bank_account.dart';
import 'models/library.dart';
import 'models/library_item.dart';
import 'models/book.dart';
import 'models/magazine.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const LabPage(),
    );
  }
}

class LabPage extends StatefulWidget {
  const LabPage({super.key});

  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  final users = [
    User(name: 'Ana', age: 20, email: 'ana@example.com'),
    User(name: 'Mihai', age: 21),
    User(name: 'Maria'),
  ];
  final accounts = [
    BankAccount(holderName: 'Ana', balance: 150, bankBranch: 'Bucharest'),
    BankAccount(holderName: 'Mihai'),
  ];
  final library = Library();
  String? titleQuery;
  String? authorQuery;
  String message = '';

  @override
  void initState() {
    super.initState();
    accounts[0].initializeAccount('RO001');
    library.addItem(
      Book(
        title: 'The Hobbit',
        author: 'J. R. R. Tolkien',
        publishDate: DateTime(1937, 9, 21),
        pageCount: 310,
        isbn: '9780007525492',
      ),
    );
    library.addItem(Book(title: 'Dart Notes'));
    library.addItem(
      Magazine(
        title: 'Science Monthly',
        issueNumber: 12,
        publisher: 'Student Press',
        publishDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    );
  }

  String titles(List<LibraryItem> items) {
    return items.isEmpty
        ? 'No results'
        : items.map((item) => item.title).join(', ');
  }

  String dateText(DateTime? date) {
    if (date == null) return 'Not provided';
    return '${date.day}/${date.month}/${date.year}';
  }

  String itemDetails(LibraryItem item) {
    String details =
        'Author: ${item.author ?? 'Not provided'}\n'
        'Published: ${dateText(item.publishDate)}';
    if (item is Book) {
      details +=
          '\nPages: ${item.pageCount ?? 'Not provided'}'
          '\nISBN: ${item.isbn ?? 'Not provided'}';
    } else if (item is Magazine) {
      details +=
          '\nIssue: ${item.issueNumber ?? 'Not provided'}'
          '\nPublisher: ${item.publisher ?? 'Not provided'}';
    }
    return '$details\nBorrower: ${item.borrower?.name ?? 'Available'}'
        '\nDue: ${dateText(item.dueDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab 2 - Dart TypeSaftey'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Accounts'),
              Tab(text: 'Library'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    'Age: ${user.getDisplayAge()}\n'
                    'Email: ${user.email ?? 'Not provided'}',
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return ListTile(
                  title: Text(account.holderName),
                  subtitle: Text(
                    'Balance: ${account.balance.toStringAsFixed(2)} RON\n'
                    'Branch: ${account.bankBranch ?? 'N/A'}\n'
                    'Account: ${account.isAccountNumberSet() ? account.accountNumber : 'Not initialized'}',
                  ),
                );
              },
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Borrowing as Ana. Loan duration: 14 days.'),
                for (final item in library.items) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.title),
                    subtitle: Text(itemDetails(item)),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final success = library.borrowItem(
                              item,
                              users[0],
                              DateTime.now().add(const Duration(days: 14)),
                            );
                            message = success
                                ? 'Borrowed ${item.title}.'
                                : 'Already borrowed.';
                          });
                        },
                        child: const Text('Borrow'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final success = library.returnItem(item);
                            message = success
                                ? 'Returned ${item.title}.'
                                : 'Item is not borrowed.';
                          });
                        },
                        child: const Text('Return'),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
                Text(message),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by title',
                  ),
                  onChanged: (value) => setState(() => titleQuery = value),
                ),
                Text(titles(library.searchByTitle(titleQuery))),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Author (full name)',
                  ),
                  onChanged: (value) => setState(() => authorQuery = value),
                ),
                Text(titles(library.getItemsByAuthor(authorQuery))),
                const SizedBox(height: 16),
                const Text('Published in the last 365 days:'),
                Text(
                  titles(
                    library.getRecentItems(
                      DateTime.now().subtract(const Duration(days: 365)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
