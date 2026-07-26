class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? role;

  const UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'email': email,
        'role': role,
      };
}
