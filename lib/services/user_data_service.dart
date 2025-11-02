import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/saved_place_model.dart';
import '../data/models/trip_model.dart';
import '../data/models/review_model.dart';
import '../data/models/place_model.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Saved Places ====================

  Future<void> savePlace({
    required String userId,
    required String placeId,
    Place? placeData,
  }) async {
    try {
      // Check if already saved
      final existingQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_places')
          .where('placeId', isEqualTo: placeId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // Already saved, just update
        await existingQuery.docs.first.reference.update({
          'placeData': placeData?.toJson(),
          'savedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // New save
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('saved_places')
            .add({
          'userId': userId,
          'placeId': placeId,
          'placeData': placeData?.toJson(),
          'savedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to save place: $e');
    }
  }

  Future<void> removePlace({
    required String userId,
    required String placeId,
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_places')
          .where('placeId', isEqualTo: placeId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove place: $e');
    }
  }

  Future<List<SavedPlace>> getSavedPlaces({required String userId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_places')
          .orderBy('savedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedPlace.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get saved places: $e');
    }
  }

  Future<bool> isPlaceSaved({
    required String userId,
    required String placeId,
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_places')
          .where('placeId', isEqualTo: placeId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== Trips ====================

  Future<String> createTrip({
    required String userId,
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required List<Place> places,
  }) async {
    try {
      final tripData = {
        'userId': userId,
        'name': name,
        'description': description,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'places': places.map((p) => p.toJson()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .add(tripData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  Future<void> updateTrip({
    required String userId,
    required String tripId,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<Place>? places,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (startDate != null) updates['startDate'] = Timestamp.fromDate(startDate);
      if (endDate != null) updates['endDate'] = Timestamp.fromDate(endDate);
      if (places != null) updates['places'] = places.map((p) => p.toJson()).toList();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  Future<void> deleteTrip({
    required String userId,
    required String tripId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  Future<List<Trip>> getUserTrips({required String userId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Trip.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get trips: $e');
    }
  }

  Future<Trip?> getTrip({
    required String userId,
    required String tripId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .get();

      if (!doc.exists) return null;

      return Trip.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get trip: $e');
    }
  }

  // ==================== Reviews ====================

  Future<String> saveReview({
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String placeId,
    required int rating,
    required String comment,
  }) async {
    try {
      final reviewData = {
        'userId': userId,
        'userDisplayName': userDisplayName,
        'userPhotoUrl': userPhotoUrl,
        'placeId': placeId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('reviews').add(reviewData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save review: $e');
    }
  }

  Future<void> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rating != null) updates['rating'] = rating;
      if (comment != null) updates['comment'] = comment;

      await _firestore.collection('reviews').doc(reviewId).update(updates);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> deleteReview({required String reviewId}) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  Future<List<Review>> getPlaceReviews({required String placeId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('placeId', isEqualTo: placeId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get place reviews: $e');
    }
  }

  Future<List<Review>> getUserReviews({required String userId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user reviews: $e');
    }
  }

  Future<Review?> getUserReviewForPlace({
    required String userId,
    required String placeId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('placeId', isEqualTo: placeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return Review.fromFirestore(
        querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id,
      );
    } catch (e) {
      throw Exception('Failed to get user review: $e');
    }
  }
}

