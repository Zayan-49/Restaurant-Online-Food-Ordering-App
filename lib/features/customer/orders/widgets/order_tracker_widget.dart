import 'package:flutter/material.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/models/order_model.dart';

class OrderTrackerWidget extends StatelessWidget {
  const OrderTrackerWidget({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    final padding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 20, desktop: 24);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TrackerStep(
                icon: Icons.timer_outlined,
                label: 'Waiting',
                isActive: status == OrderStatus.waiting,
                isCompleted: status.index > OrderStatus.waiting.index,
                isPulse: status == OrderStatus.waiting,
              ),
              _TrackerConnector(isCompleted: status.index > OrderStatus.waiting.index),
              _TrackerStep(
                icon: Icons.check_circle_outline_rounded,
                label: 'Confirmed',
                isActive: status == OrderStatus.confirmed,
                isCompleted: status.index > OrderStatus.confirmed.index,
                isPulse: status == OrderStatus.confirmed,
              ),
              _TrackerConnector(isCompleted: status.index > OrderStatus.confirmed.index),
              _TrackerStep(
                icon: Icons.delivery_dining_outlined,
                label: 'On the Way',
                isActive: status == OrderStatus.handedToDriver,
                isCompleted: false, // Last step
                isPulse: status == OrderStatus.handedToDriver,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackerStep extends StatefulWidget {
  const _TrackerStep({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.isPulse,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final bool isPulse;

  @override
  State<_TrackerStep> createState() => _TrackerStepState();
}

class _TrackerStepState extends State<_TrackerStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCompleted || widget.isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? color
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                boxShadow: widget.isActive && widget.isPulse
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8 * _controller.value,
                          spreadRadius: 4 * _controller.value,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.isCompleted ? Icons.check : widget.icon,
                color: widget.isCompleted ? Colors.white : color,
                size: 20,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
            color: widget.isActive ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _TrackerConnector extends StatelessWidget {
  const _TrackerConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 20),
        color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
      ),
    );
  }
}
