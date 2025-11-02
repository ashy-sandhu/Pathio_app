class Review {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final String placeId;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.placeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromFirestore(Map<String, dynamic> doc, String id) {
    return Review(
      id: id,
      userId: doc['userId'] ?? '',
      userDisplayName: doc['userDisplayName'] ?? '',
      userPhotoUrl: doc['userPhotoUrl'],
      placeId: doc['placeId'] ?? '',
      rating: doc['rating'] ?? 0,
      comment: doc['comment'] ?? '',
      createdAt: doc['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: doc['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'placeId': placeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userPhotoUrl,
    String? placeId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      placeId: placeId ?? this.placeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

