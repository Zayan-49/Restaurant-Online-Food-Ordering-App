import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/restaurant/providers/admin_nav_provider.dart';
import 'package:online_food_ordering/features/restaurant/screens/restaurant_dashboard_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/menu_editor_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/analytics_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/admin_settings_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/advertisement_management_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/admin_order_history_screen.dart';
import 'package:online_food_ordering/features/restaurant/screens/deal_management_screen.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AdminShellScreen extends ConsumerWidget {
  const AdminShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavIndexProvider);
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final List<Widget> screens = [
      const RestaurantDashboardScreen(),
      const MenuEditorScreen(),
      const DealManagementScreen(),
      const AdvertisementManagementScreen(),
      const AdminOrderHistoryScreen(),
      const AnalyticsScreen(),
      const AdminSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: Row(
        children: [
          if (isDesktop) _AdminSidebar(currentIndex: currentIndex),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F2),
                borderRadius: isDesktop 
                  ? const BorderRadius.only(topLeft: Radius.circular(32), bottomLeft: Radius.circular(32))
                  : BorderRadius.zero,
              ),
              child: IndexedStack(
                index: currentIndex,
                children: screens,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop 
        ? Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => ref.read(adminNavIndexProvider.notifier).state = index,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey.shade400,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded), label: 'Menu'),
                BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion_rounded), label: 'Deals'),
                BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Ads'),
                BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Stats'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
              ],
            ),
          )
        : null,
    );
  }
}

class _AdminSidebar extends ConsumerWidget {
  const _AdminSidebar({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), 
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ELITE',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                    Text(
                      'RESTAURANT',
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', isSelected: currentIndex == 0, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 0),
                  _SidebarItem(icon: Icons.restaurant_rounded, label: 'Menu Manager', isSelected: currentIndex == 1, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 1),
                  _SidebarItem(icon: Icons.auto_awesome_motion_rounded, label: 'Bundle Deals', isSelected: currentIndex == 2, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 2),
                  _SidebarItem(icon: Icons.campaign_rounded, label: 'Advertisement', isSelected: currentIndex == 3, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 3),
                  _SidebarItem(icon: Icons.history_rounded, label: 'Order History', isSelected: currentIndex == 4, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 4),
                  _SidebarItem(icon: Icons.analytics_outlined, label: 'Sales Analytics', isSelected: currentIndex == 5, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 5),
                  _SidebarItem(icon: Icons.settings_outlined, label: 'System Settings', isSelected: currentIndex == 6, onTap: () => ref.read(adminNavIndexProvider.notifier).state = 6),
                ],
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: primaryColor,
                  child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Admin User', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.icon, required this.label, required this.isSelected, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : (color ?? Colors.grey.shade500), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label, 
                    style: TextStyle(
                      color: isSelected ? Colors.white : (color ?? Colors.grey.shade400), 
                      fontSize: 13, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
