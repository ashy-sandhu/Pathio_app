import 'place_model.dart';

class Trip {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<Place> places;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.places,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromFirestore(Map<String, dynamic> doc, String id) {
    return Trip(
      id: id,
      userId: doc['userId'] ?? '',
      name: doc['name'] ?? '',
      description: doc['description'],
      startDate: doc['startDate']?.toDate() ?? DateTime.now(),
      endDate: doc['endDate']?.toDate() ?? DateTime.now(),
      places: (doc['places'] as List<dynamic>?)
              ?.map((p) => Place.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: doc['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: doc['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'places': places.map((p) => p.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<Place>? places,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      places: places ?? this.places,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

