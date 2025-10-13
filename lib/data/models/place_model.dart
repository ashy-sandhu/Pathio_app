class Place {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final double lat;
  final double lon;
  final String cityName;
  final String countryName;
  final String category;
  final double? rating;
  final bool isPopular;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.lat,
    required this.lon,
    required this.cityName,
    required this.countryName,
    required this.category,
    this.rating,
    required this.isPopular,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
      cityName: json['city_name'] ?? '',
      countryName: json['country_name'] ?? '',
      category: json['category'] ?? 'place',
      rating: json['rating']?.toDouble(),
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'lat': lat,
      'lon': lon,
      'city_name': cityName,
      'country_name': countryName,
      'category': category,
      'rating': rating,
      'is_popular': isPopular,
    };
  }

  @override
  String toString() {
    return 'Place(id: $id, name: $name, cityName: $cityName, countryName: $countryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
