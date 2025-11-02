class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String provider; // 'email', 'google', 'facebook'

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.provider,
  });

  // Convert from Firestore document
  factory AppUser.fromFirestore(Map<String, dynamic> doc, String id) {
    DateTime createdAt;
    if (doc['createdAt'] != null) {
      if (doc['createdAt'] is DateTime) {
        createdAt = doc['createdAt'] as DateTime;
      } else {
        createdAt = (doc['createdAt'] as dynamic).toDate();
      }
    } else {
      createdAt = DateTime.now();
    }

    return AppUser(
      uid: id,
      email: doc['email'] ?? '',
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
      createdAt: createdAt,
      provider: doc['provider'] ?? 'email',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'provider': provider,
    };
  }

  // Convert from Firebase Auth User
  factory AppUser.fromFirebaseAuth(
    String uid,
    String email, {
    String? displayName,
    String? photoUrl,
    String provider = 'email',
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      provider: provider,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? provider,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      provider: provider ?? this.provider,
    );
  }
}

