/// Model representing the user's profile information.
class UserModel {
  final String name;
  final String email;
  final String? profileImagePath;

  const UserModel({
    required this.name,
    required this.email,
    this.profileImagePath,
  });

  /// Copy with helper for immutability.
  UserModel copyWith({
    String? name,
    String? email,
    String? profileImagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
