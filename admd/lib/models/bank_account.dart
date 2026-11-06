class BankAccount {
  late String accountNumber;
  final String holderName;
  double balance;
  final String? bankBranch;
  bool _initialized = false;

  BankAccount({required this.holderName, this.balance = 0.0, this.bankBranch});

  void initializeAccount(String number) {
    if (number.trim().isEmpty) throw ArgumentError('Empty account number');
    accountNumber = number;
    _initialized = true;
  }

  // Check before reading the late field.
  bool isAccountNumberSet() => _initialized;
}
