class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String phoneNumber;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.phoneNumber = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'phone_number': phoneNumber,
    };
  }
}
