import 'place_model.dart';

class SavedPlace {
  final String id;
  final String userId;
  final String placeId;
  final Place? placeData; // Full place data for offline access
  final DateTime savedAt;

  SavedPlace({
    required this.id,
    required this.userId,
    required this.placeId,
    this.placeData,
    required this.savedAt,
  });

  factory SavedPlace.fromFirestore(Map<String, dynamic> doc, String id) {
    return SavedPlace(
      id: id,
      userId: doc['userId'] ?? '',
      placeId: doc['placeId'] ?? '',
      placeData: doc['placeData'] != null
          ? Place.fromJson(doc['placeData'])
          : null,
      savedAt: doc['savedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'placeId': placeId,
      'placeData': placeData?.toJson(),
      'savedAt': savedAt,
    };
  }
}

