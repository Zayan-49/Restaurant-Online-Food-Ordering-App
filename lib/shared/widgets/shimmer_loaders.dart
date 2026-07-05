import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';

/// Base shimmer effect wrapper following Luxury UI rules.
class BaseShimmer extends StatelessWidget {
  const BaseShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Shimmer skeleton for FoodCard.
class FoodCardShimmer extends StatelessWidget {
  const FoodCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    
    return BaseShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image skeleton (Flex 5)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
            // 2. Content skeleton (Flex 4) - Resized to prevent overflow
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced slightly from 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Title placeholder
                    Container(
                      width: double.infinity,
                      height: 12, // Reduced from 14
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced from 8
                    // Subtitle placeholder
                    Container(
                      width: 80, // Reduced from 100
                      height: 8, // Reduced from 10
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    // Bottom row (Price + Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40, // Reduced from 50
                          height: 14, // Reduced from 16
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 24, // Reduced from 28
                          height: 24, // Reduced from 28
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Category chips.
class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        width: 80,
        height: 40,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

/// Full screen overlay loader with shimmer.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BaseShimmer(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            BaseShimmer(
              child: Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
