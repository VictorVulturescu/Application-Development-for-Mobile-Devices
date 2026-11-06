class User {
  final String name;
  final int? age;
  final String? email;

  User({required this.name, this.age, this.email});

  String getDisplayAge() => age?.toString() ?? 'Age not specified';
}
