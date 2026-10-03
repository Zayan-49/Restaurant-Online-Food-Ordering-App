import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/restaurant/providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);
    final padding = ResponsiveHelper.getAdaptivePadding(context, mobileValue: 16, desktopValue: 32);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Business Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildRangeSelector(ref, analytics.selectedRange),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Key Performance Indicators (Quick Stats)
                  _buildKPISection(context, analytics),
                  const SizedBox(height: 40),

                  _buildSectionTitle(context, 'Revenue Trends'),
                  const SizedBox(height: 20),
                  _buildRevenueChart(context, analytics.weeklyRevenue, primaryColor),
                  const SizedBox(height: 40),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPopularDishes(context, analytics.topDishes, primaryColor)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildCategoryDistribution(context, analytics.categoryDistribution)),
                      ],
                    )
                  else ...[
                    _buildPopularDishes(context, analytics.topDishes, primaryColor),
                    const SizedBox(height: 40),
                    _buildCategoryDistribution(context, analytics.categoryDistribution),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKPISection(BuildContext context, AnalyticsState data) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _KPIItem(
          label: 'Total Revenue',
          value: '\$${data.totalRevenue.toStringAsFixed(0)}',
          icon: Icons.monetization_on_rounded,
          color: Colors.green,
        ),
        _KPIItem(
          label: 'Avg. Order Value',
          value: '\$${data.avgOrderValue.toStringAsFixed(2)}',
          icon: Icons.shopping_basket_rounded,
          color: Colors.blue,
        ),
        _KPIItem(
          label: 'Total Customers',
          value: '${data.totalCustomers}',
          icon: Icons.people_rounded,
          color: Colors.orange,
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildRangeSelector(WidgetRef ref, String selected) {
    return PopupMenuButton<String>(
      onSelected: (val) => ref.read(analyticsProvider.notifier).setRange(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(selected, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => ['Today', 'Last 7 Days', 'This Month']
          .map((r) => PopupMenuItem(value: r, child: Text(r)))
          .toList(),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context, List<RevenueData> data, Color color) {
    return Container(
      height: 350,
      padding: const EdgeInsets.fromLTRB(16, 32, 32, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val.toInt() < 0 || val.toInt() >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[val.toInt()].day, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
              isCurved: true,
              color: color,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildPopularDishes(BuildContext context, List<DishPerformance> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Most Popular Dishes'),
        const SizedBox(height: 20),
        Container(
          height: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (val, meta) {
                      if (val.toInt() < 0 || val.toInt() >= data.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          data[val.toInt()].name.split(' ').first, 
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.salesCount.toDouble(), 
                    color: color, 
                    width: 16, 
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(show: true, toY: 200, color: Colors.grey.shade100),
                  )
                ],
              )).toList(),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildCategoryDistribution(BuildContext context, List<CategoryPerformance> data) {
    final List<Color> colors = [
      Theme.of(context).colorScheme.primary,
      Colors.orange,
      Colors.blue,
      Colors.green,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Category Sales'),
        const SizedBox(height: 20),
        Container(
          height: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: data.asMap().entries.map((e) => PieChartSectionData(
                      color: colors[e.key % colors.length],
                      value: e.value.percentage,
                      title: '${e.value.percentage.toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.value.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

class _KPIItem extends StatelessWidget {
  const _KPIItem({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isMobile = ScreenBreakpoints.isMobile(context);
    final width = isMobile ? (MediaQuery.sizeOf(context).width - 48) / 2 : 220.0;

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
