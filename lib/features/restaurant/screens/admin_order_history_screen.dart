import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/core/providers/order_history_provider.dart';
import 'package:online_food_ordering/features/restaurant/widgets/admin_order_card.dart';

class AdminOrderHistoryScreen extends ConsumerWidget {
  const AdminOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(orderHistoryProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final padding = ResponsiveHelper.getAdaptivePadding(context, mobileValue: 16, desktopValue: 32);
    final dateRange = ref.watch(historyDateRangeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Order Archive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => _selectDateRange(context, ref),
            icon: Icon(
              dateRange == null ? Icons.calendar_today_rounded : Icons.calendar_month_rounded, 
              color: Colors.white
            ),
            tooltip: 'Filter by Date',
          ),
          if (dateRange != null)
            IconButton(
              onPressed: () => ref.read(historyDateRangeProvider.notifier).state = null,
              icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
              tooltip: 'Clear Filters',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(ref),
            if (dateRange != null) _buildActiveFilterChip(context, ref, dateRange),
            Expanded(
              child: historyAsync.when(
                data: (orders) {
                  if (orders.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    padding: padding,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return AdminOrderCard(
                        order: orders[index],
                        onStatusUpdate: (_) {}, // Status update not needed in history view
                      ).animate().fadeIn(delay: (index * 30).ms).slideX(begin: 0.05);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        onChanged: (v) => ref.read(historySearchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'Search by Order ID, Item, or Phone...',
          prefixIcon: const Icon(Icons.search_rounded),
          fillColor: Colors.grey.shade100,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(BuildContext context, WidgetRef ref, DateTimeRange range) {
    final start = DateFormat('MMM dd').format(range.start);
    final end = DateFormat('MMM dd').format(range.end);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Showing: $start - $end',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => ref.read(historyDateRangeProvider.notifier).state = null,
            child: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No matching orders found in archive.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(historyDateRangeProvider.notifier).state = picked;
    }
  }
}
