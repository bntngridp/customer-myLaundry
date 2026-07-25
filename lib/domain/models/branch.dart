class BranchModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double rating;
  final String imageUrl;
  final bool isActive;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0.0,
    required this.rating,
    required this.imageUrl,
    this.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'myLaundry Branch',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.9740,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 107.6303,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      imageUrl: json['image_url'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get formattedDistance => '+${distanceKm.toStringAsFixed(1)} Km';
}
