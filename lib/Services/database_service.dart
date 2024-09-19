import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving user data: $e');
    }
  }
}
