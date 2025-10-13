class City {
  final int id;
  final String name;
  final String countryName;
  final double lat;
  final double lon;
  final int placesCount;

  const City({
    required this.id,
    required this.name,
    required this.countryName,
    required this.lat,
    required this.lon,
    required this.placesCount,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      countryName: json['country_name'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
      placesCount: json['places_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_name': countryName,
      'lat': lat,
      'lon': lon,
      'places_count': placesCount,
    };
  }

  @override
  String toString() {
    return 'City(id: $id, name: $name, countryName: $countryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
