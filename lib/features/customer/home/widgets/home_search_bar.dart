import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/home/providers/home_provider.dart';
import 'package:online_food_ordering/services/ai/ai_service.dart';

/// Luxury AI-powered search bar for home screen.
class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizontalPadding = ResponsiveHelper.getAdaptiveSize(context,
        mobile: 16, tablet: 20, desktop: 24);
    final height = 55.0; 
    final iconSize = 22.0;
    final isAILoading = ref.watch(isAISearchLoadingProvider);
    final controller = TextEditingController(text: ref.read(searchQueryProvider));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.search_rounded,
                color: Colors.grey,
                size: iconSize,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  if (value.isEmpty) {
                    ref.read(aiSearchKeywordsProvider.notifier).state = null;
                  }
                },
                onSubmitted: (value) async {
                  if (value.trim().length > 2) {
                    ref.read(isAISearchLoadingProvider.notifier).state = true;
                    try {
                      final keywords = await AIService().interpretSearchIntent(value);
                      ref.read(aiSearchKeywordsProvider.notifier).state = keywords;
                    } finally {
                      ref.read(isAISearchLoadingProvider.notifier).state = false;
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Try "Something spicy" or "Heavy lunch"...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (isAILoading)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                onPressed: () {
                  controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(aiSearchKeywordsProvider.notifier).state = null;
                },
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
