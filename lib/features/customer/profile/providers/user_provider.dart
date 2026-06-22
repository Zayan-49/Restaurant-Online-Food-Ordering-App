import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

/// Provider for the user profile state.
final userProvider = NotifierProvider<UserNotifier, UserModel>(UserNotifier.new);

/// Notifier to manage user profile operations.
class UserNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    // Initial default data
    return const UserModel(
      name: 'John Doe',
      email: 'johndoe@example.com',
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateProfileImage(String? path) {
    state = state.copyWith(profileImagePath: path);
  }
}
