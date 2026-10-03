import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/restaurant_profile_model.dart';

/// Real-time provider that listens to the restaurant_settings table in Supabase.
/// This ensures branding and operations are synced across both apps instantly.
final restaurantProfileProvider = StreamProvider<RestaurantProfileModel>((ref) {
  return SupabaseConfig.client
      .from('restaurant_settings')
      .stream(primaryKey: ['id'])
      .map((data) {
        if (data.isEmpty) {
          return const RestaurantProfileModel(
            name: 'Elite Dining',
            tagline: 'Exquisite Flavors, Unmatched Luxury',
            address: '789 Fifth Avenue, New York, NY',
            minOrderValue: 20.0,
            openTimeStr: '09:00',
            closeTimeStr: '22:00',
            isTemporarilyClosed: false, defaultDeliveryFee: 5, defaultEstimatedTime: '',
          );
        }
        return RestaurantProfileModel.fromMap(data.first);
      });
});
