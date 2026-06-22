import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/core/responsive/screen_breakpoints.dart';
import 'package:online_food_ordering/features/customer/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/core/models/food_model.dart';
import 'package:online_food_ordering/features/customer/home/providers/favorites_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.food});

  final FoodModel food;

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesProvider).contains(widget.food.id);
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);
    final isDesktop = ScreenBreakpoints.isDesktop(context) || ScreenBreakpoints.isLargeDesktop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        right: true,
        left: true,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              // Main Content
              isDesktop ? _buildDesktopLayout(padding) : _buildMobileLayout(padding),

              // Custom Back Button Overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: _CircularIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => context.pop(),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
              ),

              // Favorite Button Overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: _CircularIconButton(
                  icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  iconColor: isFavorite ? Colors.red : null,
                  onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(widget.food.id),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(padding),
    );
  }

  Widget _buildMobileLayout(double padding) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image with HERO + subtle entry animation
          Hero(
            tag: 'food_image_${widget.food.id}',
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.45,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Burger.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ).animate().shimmer(duration: 1000.ms, color: Colors.white.withValues(alpha: 0.2)).scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOut,
              ),
          
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                _buildDescription().animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),
                _buildQuantitySection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(double padding) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
        child: Padding(
          padding: EdgeInsets.all(padding + 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Section with HERO + Animation
              Expanded(
                flex: 1,
                child: Hero(
                  tag: 'food_image_${widget.food.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        'assets/images/Burger.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ).animate().scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                    ).fadeIn(duration: 400.ms),
              ),
              const SizedBox(width: 64),
              // Details Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderInfo().animate().fadeIn(duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 32),
                    _buildDescription().animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.05),
                    const SizedBox(height: 48),
                    _buildQuantitySection().animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.food.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getHeadlineMediumFontSize(context),
                    ),
              ),
            ),
            _buildRatingBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.food.category,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
                fontSize: ResponsiveHelper.getBodyLargeFontSize(context),
              ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            '${widget.food.rating}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getTitleLargeFontSize(context),
              ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.food.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.6,
                fontSize: ResponsiveHelper.getBodyMediumFontSize(context),
              ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Row(
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getTitleMediumFontSize(context),
              ),
        ),
        const SizedBox(width: 24),
        _buildCounter(),
      ],
    );
  }

  Widget _buildCounter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: _decrement, icon: const Icon(Icons.remove)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$_quantity',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(onPressed: _increment, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Price', style: TextStyle(color: Colors.grey)),
                Text(
                  '\$${(widget.food.price * _quantity).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < _quantity; i++) {
                    ref.read(cartProvider.notifier).addItem(widget.food);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_quantity x ${widget.food.title} added to cart'),
                      behavior: SnackBarBehavior.floating,
                      width: 280,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
    );
  }
}
