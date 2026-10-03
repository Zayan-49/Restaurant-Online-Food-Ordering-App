import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/config/supabase_config.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/features/shared/auth/providers/auth_provider.dart';

/// Filter state for searching order history.
final historySearchQueryProvider = StateProvider<String>((ref) => '');

/// Filter state for date range selection.
final historyDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Unified Order History Provider.
/// Automatically detects user role and fetches relevant historical data.
final orderHistoryProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final roleAsync = ref.watch(userRoleProvider);
  final searchQuery = ref.watch(historySearchQueryProvider);
  final dateRange = ref.watch(historyDateRangeProvider);

  if (user == null) return Stream.value([]);

  return roleAsync.when(
    data: (role) {
      // Base query for real-time order stream
      var streamQuery = SupabaseConfig.client
          .from('orders')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false);

      return streamQuery.map((data) {
        var allOrders = data.map((map) => OrderModel.fromMap(map)).toList();
        
        // 1. Role-based filtering (Customers only see their own)
        if (role == 'customer') {
          allOrders = allOrders.where((o) => o.customerId == user.id).toList();
        }

        // 2. Date Range filtering
        if (dateRange != null) {
          allOrders = allOrders.where((o) {
            // Check if order date is within the selected range (inclusive)
            final orderDate = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
            return (orderDate.isAtSameMomentAs(dateRange.start) || orderDate.isAfter(dateRange.start)) &&
                   (orderDate.isAtSameMomentAs(dateRange.end) || orderDate.isBefore(dateRange.end));
          }).toList();
        }

        // 3. Search-based filtering
        if (searchQuery.isEmpty) return allOrders;
        
        return allOrders.where((order) {
          final matchesId = order.id.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesPhone = order.phoneNumber.contains(searchQuery);
          final matchesItem = order.items.any((item) => 
            item.food.title.toLowerCase().contains(searchQuery.toLowerCase())
          );
          return matchesId || matchesItem || matchesPhone;
        }).toList();
      });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
