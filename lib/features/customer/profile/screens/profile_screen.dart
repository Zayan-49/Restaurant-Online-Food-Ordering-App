import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final user = ref.watch(userProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 24, desktop: 32);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxWidth(context),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    // User Info Header
                    _ProfileHeader(
                      name: user.name,
                      email: user.email,
                      imagePath: user.profileImagePath,
                    ),
                    SizedBox(height: padding * 2),

                    // Order History Section
                    _SectionHeader(
                      title: 'Order History',
                      action: TextButton(
                        onPressed: () => context.pushNamed(AppRouteNames.orderHistory),
                        child: const Text('View All'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _OrderHistoryPreview(),
                    SizedBox(height: padding * 2),

                    // Account Settings Section
                    const _SectionHeader(title: 'Account Settings'),
                    const SizedBox(height: 16),
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () => context.pushNamed(AppRouteNames.editProfile),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.payment_rounded,
                      title: 'Payment Methods',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      textColor: Colors.redAccent,
                      onTap: () async {
                        await ref.read(authControllerProvider).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    this.imagePath,
  });

  final String name;
  final String email;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: imagePath != null && imagePath!.isNotEmpty
              ? (imagePath!.startsWith('http') 
                  ? NetworkImage(imagePath!) 
                  : FileImage(File(imagePath!)) as ImageProvider)
              : null,
          child: imagePath == null || imagePath!.isEmpty
              ? const Text(
                  'JD',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
      ),
        const SizedBox(height: 16),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          email,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
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
              child: Text('No orders yet', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        
        final previewOrders = orders.take(2).toList();

        return Column(
          children: previewOrders.map((order) {
            final firstItem = order.items.isNotEmpty ? order.items.first.food.title : 'Food Order';
            final itemCount = order.items.length;
            final title = itemCount > 1 ? '$firstItem +${itemCount - 1} more' : firstItem;
            final dateStr = DateFormat('MMM dd, yyyy').format(order.createdAt);

            return _OrderHistoryTile(
              title: title,
              date: dateStr,
              price: '\$${order.totalPrice.toStringAsFixed(2)}',
              status: order.status == OrderStatus.handedToDriver ? 'Delivered' : 'Pending',
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading history'),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  const _OrderHistoryTile({
    required this.title,
    required this.date,
    required this.price,
    required this.status,
  });

  final String title;
  final String date;
  final String price;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fastfood_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: status == 'Delivered' ? Colors.green : Colors.orange, 
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
