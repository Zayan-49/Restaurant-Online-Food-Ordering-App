import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the current active tab in the Restaurant Admin App.
final adminNavIndexProvider = StateProvider<int>((ref) => 0);
