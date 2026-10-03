import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/providers/order_history_provider.dart';
import 'package:online_food_ordering/features/customer/profile/providers/user_provider.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:online_food_ordering/routes/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if(user == null) return const Center(child: Text('Please login to view profile'));

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      // 1. Dynamic User Info Header
                      _ProfileHeader(
                        name: user.name,
                        email: user.email,
                        avatarUrl: user.avatarUrl,
                      ),
                      const SizedBox(height: 40),

                      // 2. Order History Preview (Live)
                      _SectionHeader(
                        title: 'Recent Orders',
                        action: TextButton(
                          onPressed: () => context.pushNamed(AppRouteNames.orderHistory),
                          child: const Text('View History'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _OrderHistoryPreview(),
                      const SizedBox(height: 32),

                      // 3. Account Settings
                      const _SectionHeader(title: 'Account Settings'),
                      const SizedBox(height: 16),
                      _SettingsCard([
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          onTap: () => context.pushNamed(AppRouteNames.editProfile),
                        ),
                        _SettingsTile(
                          icon: Icons.security_rounded,
                          title: 'Privacy & Security',
                          onTap: () => context.pushNamed(AppRouteNames.privacySecurity),
                        ),
                        _SettingsTile(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          textColor: Colors.redAccent,
                          onTap: () async {
                            await ref.read(authControllerProvider).signOut();
                            if (context.mounted) context.go('/login');
                          },
                        ),
                      ]),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Icon(Icons.person_rounded, size: 60, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),

          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (action != null) action!,
      ],
    );
  }
}

class _OrderHistoryPreview extends ConsumerWidget {
  const _OrderHistoryPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(orderHistoryProvider);

    return historyAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No recent orders', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        
        final previewOrders = orders.take(2).toList();

        return Column(
          children: previewOrders.map((order) {
            final firstItem = order.items.isNotEmpty ? order.items.first.food.title : 'Meal';
            return _OrderHistoryTile(
              title: firstItem,
              date: DateFormat('MMM dd').format(order.createdAt),
              price: '\$${order.totalPrice.toStringAsFixed(2)}',
              status: order.status == OrderStatus.handedToDriver ? 'Delivered' : 'Processing',
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const Text('Error loading summary'),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  const _OrderHistoryTile({required this.title, required this.date, required this.price, required this.status});
  final String title;
  final String date;
  final String price;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.fastfood_rounded, size: 20, color: Colors.grey),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('$date • $status', style: TextStyle(color: status == 'Delivered' ? Colors.green : Colors.orange, fontSize: 12)),
      trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.textColor});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? Colors.black87, size: 22),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black87, fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }
}
