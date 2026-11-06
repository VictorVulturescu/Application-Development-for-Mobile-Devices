import 'library_item.dart';
import 'user.dart';

class Library {
  final List<LibraryItem> items = [];

  bool addItem(LibraryItem item) {
    // Require a title and reject the same object added twice.
    if (item.title.trim().isEmpty || items.contains(item)) return false;
    items.add(item);
    return true;
  }

  List<LibraryItem> searchByTitle(String? query) {
    if (query == null || query.trim().isEmpty) return [];
    return items
        .where(
          (item) =>
              item.title.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();
  }

  List<LibraryItem> getItemsByAuthor(String? author) {
    if (author == null || author.trim().isEmpty) return [];
    return items
        .where(
          (item) => item.author?.toLowerCase() == author.trim().toLowerCase(),
        )
        .toList();
  }

  // Recent means published between the supplied date and now.
  List<LibraryItem> getRecentItems(DateTime? since) {
    if (since == null) return [];
    final now = DateTime.now();
    return items.where((item) {
      final date = item.publishDate;
      return date != null && !date.isBefore(since) && !date.isAfter(now);
    }).toList();
  }

  bool borrowItem(LibraryItem item, User user, DateTime dueDate) {
    if (!items.contains(item) || item.borrower != null) return false;
    item.borrower = user;
    item.dueDate = dueDate;
    return true;
  }

  bool returnItem(LibraryItem item) {
    if (!items.contains(item) || item.borrower == null) return false;
    item.borrower = null;
    item.dueDate = null;
    return true;
  }
}
