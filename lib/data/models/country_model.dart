class Country {
  final int id;
  final String name;
  final int citiesCount;
  final int placesCount;

  const Country({
    required this.id,
    required this.name,
    required this.citiesCount,
    required this.placesCount,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      citiesCount: json['cities_count'] ?? 0,
      placesCount: json['places_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cities_count': citiesCount,
      'places_count': placesCount,
    };
  }

  @override
  String toString() {
    return 'Country(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
