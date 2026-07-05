import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:online_food_ordering/core/responsive/responsive_helper.dart';
import 'package:online_food_ordering/features/customer/cart/providers/cart_providers.dart';
import 'package:online_food_ordering/features/customer/orders/providers/customer_orders_provider.dart';
import 'package:online_food_ordering/core/providers/restaurant_profile_provider.dart';
import 'package:online_food_ordering/features/customer/checkout/widgets/order_summary_card.dart';
import 'package:online_food_ordering/features/customer/checkout/widgets/payment_method_card.dart';
import 'package:online_food_ordering/features/customer/checkout/widgets/delivery_address_card.dart';
import 'package:online_food_ordering/routes/app_router.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isPlacingOrder = false;
  String _orderType = 'delivery'; 
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder(double dynamicFee, String estimatedTime) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);
    
    try {
      // Logic: Only charge fee if it's 'delivery'
      final feeToCharge = _orderType == 'delivery' ? dynamicFee : 0.0;
      
      final orderId = await ref.read(cartProvider.notifier).placeOrder(
        address: _orderType == 'delivery' ? _addressController.text : 'Takeaway / In-Store Pickup',
        phone: _phoneController.text,
        type: _orderType,
        fee: feeToCharge,
        estimatedTime: estimatedTime, // Dynamic from Admin Settings
      );
      
      if (mounted) {
        ref.read(lastOrderIdProvider.notifier).state = orderId;
        context.pushReplacementNamed(AppRouteNames.orders); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().contains('estimated_time') 
          ? 'Database Error: Please run the updated SQL code to add missing columns.'
          : e.toString().replaceAll('Exception: ', '');
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = ref.watch(cartTotalProvider);
    final restaurantAsync = ref.watch(restaurantProfileProvider);
    final padding = ResponsiveHelper.getAdaptiveSize(context, mobile: 16, tablet: 24, desktop: 32);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: restaurantAsync.when(
        data: (restaurant) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxWidth(context)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTypeCard('delivery', 'Delivery', Icons.delivery_dining_rounded)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTypeCard('takeaway', 'Takeaway', Icons.shopping_bag_rounded)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      if (_orderType == 'delivery') ...[
                        _buildLabel('Delivery Address'),
                        TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration('Enter your full address', Icons.location_on_outlined),
                          validator: (v) => (v == null || v.isEmpty) ? 'Address is required for delivery' : null,
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildLabel('Phone Number'),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('e.g. 03XXXXXXXXX', Icons.phone_android_rounded),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Phone number is required';
                          final regExp = RegExp(r'^((\+92)|(0092)|(92)|(0))3\d{9}$');
                          if (!regExp.hasMatch(v)) return 'Enter a valid Pakistan phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      OrderSummaryCard(
                        total: cartTotal,
                        deliveryFee: _orderType == 'delivery' ? restaurant.defaultDeliveryFee : 0.0,
                      ),
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(restaurant.defaultDeliveryFee, restaurant.defaultEstimatedTime),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isPlacingOrder 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Confirm & Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Failed to load settings: $e')),
      ),
    );
  }

  Widget _buildTypeCard(String type, String label, IconData icon) {
    final isSelected = _orderType == type;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _orderType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
}
