import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/core/providers/promo_provider.dart';
import 'package:online_food_ordering/core/models/promo_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PromoBanner extends ConsumerStatefulWidget {
  const PromoBanner({super.key});

  @override
  ConsumerState<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends ConsumerState<PromoBanner> {
  PageController? _pageController;
  Timer? _timer;
  int _currentPage = 0;
  double? _lastViewportFraction;

  @override
  void dispose() {
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoSlide(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < itemCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController != null && _pageController!.hasClients) {
        _pageController!.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(allPromosProvider);
    
    // PREMIUM VIEWPORT LOGIC: 
    // Desktop: 0.3 means 3 cards take 90% space, 4th shows thoda sa (10%).
    // Tablet: 0.45 means 2 cards take 90% space.
    // Mobile: 0.85 means 1 card takes 85% space.
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);
    final isTablet = ScreenBreakpoints.isTablet(context);
    final currentFraction = isDesktop ? 0.3 : (isTablet ? 0.45 : 0.85);

    if (_pageController == null || _lastViewportFraction != currentFraction) {
      _pageController?.dispose();
      _pageController = PageController(
        viewportFraction: currentFraction,
        initialPage: _currentPage,
      );
      _lastViewportFraction = currentFraction;
    }

    return promosAsync.when(
      data: (allPromos) {
        final activePromos = allPromos.where((p) => p.isActive).toList();
        if (activePromos.isEmpty) return const SizedBox.shrink();

        WidgetsBinding.instance.addPostFrameCallback((_) {
           _startAutoSlide(activePromos.length);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getAdaptiveSize(context, mobile: 16, desktop: 32)
              ),
              child: Text(
                'Exclusive Promotions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: ResponsiveHelper.getAdaptiveSize(context, mobile: 180, tablet: 200, desktop: 220),
              child: PageView.builder(
                controller: _pageController,
                itemCount: activePromos.length,
                padEnds: false, // Start from the extreme left for luxury look
                onPageChanged: (index) => _currentPage = index,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController!,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: _PromoCard(promo: activePromos[index]),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController!,
                count: activePromos.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 4,
                  dotWidth: 8,
                  expansionFactor: 4,
                  spacing: 8,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});
  final PromoModel promo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. High-Quality Image
            CachedNetworkImage(
              imageUrl: promo.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
            
            // 2. Multi-layered Luxury Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            // 3. Branded Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promo.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    promo.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
