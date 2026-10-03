class PromoModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isActive;

  const PromoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isActive,
  });

  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Deal',
      subtitle: map['subtitle']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      isActive: map['is_active'] ?? true,
    );
  }
}
