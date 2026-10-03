class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String email) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['full_name'] ?? 'Guest User',
      email: email,
      avatarUrl: map['avatar_url'],
    );
  }
}
