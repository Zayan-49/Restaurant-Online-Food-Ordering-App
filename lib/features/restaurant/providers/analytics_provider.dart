import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/models/order_model.dart';
import 'package:online_food_ordering/features/restaurant/providers/restaurant_orders_provider.dart';
import 'package:intl/intl.dart';

class RevenueData {
  final String day;
  final double amount;
  const RevenueData(this.day, this.amount);
}

class DishPerformance {
  final String name;
  final int salesCount;
  const DishPerformance(this.name, this.salesCount);
}

class CategoryPerformance {
  final String name;
  final double percentage;
  const CategoryPerformance(this.name, this.percentage);
}

class AnalyticsState {
  final List<RevenueData> weeklyRevenue;
  final List<DishPerformance> topDishes;
  final List<CategoryPerformance> categoryDistribution;
  final double totalRevenue;
  final double avgOrderValue;
  final int totalCustomers;
  final String selectedRange;

  const AnalyticsState({
    this.weeklyRevenue = const [],
    this.topDishes = const [],
    this.categoryDistribution = const [],
    this.totalRevenue = 0.0,
    this.avgOrderValue = 0.0,
    this.totalCustomers = 0,
    this.selectedRange = 'Last 7 Days',
  });

  AnalyticsState copyWith({
    List<RevenueData>? weeklyRevenue,
    List<DishPerformance>? topDishes,
    List<CategoryPerformance>? categoryDistribution,
    double? totalRevenue,
    double? avgOrderValue,
    int? totalCustomers,
    String? selectedRange,
  }) {
    return AnalyticsState(
      weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
      topDishes: topDishes ?? this.topDishes,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      avgOrderValue: avgOrderValue ?? this.avgOrderValue,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      selectedRange: selectedRange ?? this.selectedRange,
    );
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final orders = ref.watch(restaurantOrdersProvider).value ?? [];
  return AnalyticsNotifier(orders);
});

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final List<OrderModel> _allOrders;

  AnalyticsNotifier(this._allOrders) : super(const AnalyticsState()) {
    _calculateAnalytics();
  }

  void setRange(String range) {
    state = state.copyWith(selectedRange: range);
    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    if (_allOrders.isEmpty) return;

    // 1. Filter orders based on range
    final now = DateTime.now();
    DateTime filterDate;
    if (state.selectedRange == 'Today') {
      filterDate = DateTime(now.year, now.month, now.day);
    } else if (state.selectedRange == 'This Month') {
      filterDate = DateTime(now.year, now.month, 1);
    } else {
      filterDate = now.subtract(const Duration(days: 7));
    }

    final filteredOrders = _allOrders.where((o) => o.createdAt.isAfter(filterDate)).toList();

    // 2. Basic KPI Calculations
    final totalRevenue = filteredOrders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final avgOrder = filteredOrders.isEmpty ? 0.0 : totalRevenue / filteredOrders.length;
    final totalCust = filteredOrders.map((o) => o.customerId).toSet().length;

    // 3. Revenue Trends (Last 7 days logic)
    Map<String, double> revenueByDay = {};
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      revenueByDay[DateFormat('E').format(d)] = 0.0;
    }
    for (var o in filteredOrders) {
      final day = DateFormat('E').format(o.createdAt);
      if (revenueByDay.containsKey(day)) {
        revenueByDay[day] = (revenueByDay[day] ?? 0) + o.totalPrice;
      }
    }
    final weeklyRev = revenueByDay.entries.map((e) => RevenueData(e.key, e.value)).toList();

    // 4. Popular Dishes & Category distribution
    Map<String, int> dishCounts = {};
    Map<String, int> categoryCounts = {};
    int totalItemsSold = 0;

    for (var o in filteredOrders) {
      for (var item in o.items) {
        dishCounts[item.food.title] = (dishCounts[item.food.title] ?? 0) + item.quantity;
        categoryCounts[item.food.category] = (categoryCounts[item.food.category] ?? 0) + item.quantity;
        totalItemsSold += item.quantity;
      }
    }

    final topDishes = dishCounts.entries
        .map((e) => DishPerformance(e.key, e.value))
        .toList()
      ..sort((a, b) => b.salesCount.compareTo(a.salesCount));

    final catDist = categoryCounts.entries.map((e) {
      final percentage = totalItemsSold == 0 ? 0.0 : (e.value / totalItemsSold) * 100;
      return CategoryPerformance(e.key, percentage);
    }).toList();

    state = state.copyWith(
      totalRevenue: totalRevenue,
      avgOrderValue: avgOrder,
      totalCustomers: totalCust,
      weeklyRevenue: weeklyRev,
      topDishes: topDishes.take(5).toList(),
      categoryDistribution: catDist,
    );
  }
}
