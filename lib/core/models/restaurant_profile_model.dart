class RestaurantProfileModel {
  final String name;
  final String tagline;
  final String address;
  final String? logoUrl;
  final double minOrderValue;
  final double defaultDeliveryFee;
  final String defaultEstimatedTime;
  final String openTimeStr;
  final String closeTimeStr;
  final bool isTemporarilyClosed;

  const RestaurantProfileModel({
    required this.name,
    required this.tagline,
    required this.address,
    this.logoUrl,
    required this.minOrderValue,
    required this.defaultDeliveryFee,
    required this.defaultEstimatedTime,
    required this.openTimeStr,
    required this.closeTimeStr,
    required this.isTemporarilyClosed,
  });

  factory RestaurantProfileModel.fromMap(Map<String, dynamic> map) {
    return RestaurantProfileModel(
      name: map['name'] ?? 'Elite Dining',
      tagline: map['tagline'] ?? 'Exquisite Flavors, Unmatched Luxury',
      address: map['address'] ?? '789 Fifth Avenue, New York, NY',
      logoUrl: map['logo_url'],
      minOrderValue: (map['min_order_value'] as num?)?.toDouble() ?? 20.0,
      defaultDeliveryFee: (map['default_delivery_fee'] as num?)?.toDouble() ?? 2.0,
      defaultEstimatedTime: map['default_estimated_time'] ?? '30-40 min',
      openTimeStr: map['open_time_str'] ?? '09:00',
      closeTimeStr: map['close_time_str'] ?? '22:00',
      isTemporarilyClosed: map['is_temporarily_closed'] ?? false,
    );
  }

  bool get isCurrentlyOpen {
    if (isTemporarilyClosed) return false;
    
    final now = DateTime.now();
    try {
      final openParts = openTimeStr.split(':');
      final closeParts = closeTimeStr.split(':');
      
      final openH = int.parse(openParts[0]);
      final openM = int.parse(openParts[1]);
      final closeH = int.parse(closeParts[0]);
      final closeM = int.parse(closeParts[1]);

      final nowTotalMinutes = now.hour * 60 + now.minute;
      final openTotalMinutes = openH * 60 + openM;
      final closeTotalMinutes = closeH * 60 + closeM;

      if (closeTotalMinutes < openTotalMinutes) {
        return nowTotalMinutes >= openTotalMinutes || nowTotalMinutes <= closeTotalMinutes;
      }

      return nowTotalMinutes >= openTotalMinutes && nowTotalMinutes <= closeTotalMinutes;
    } catch (e) {
      return true;
    }
  }
}
