import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Future<String?> uploadImage(File image, String userId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      final uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() => null);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'profileImageUrl': imageUrl}, SetOptions(merge: true));

      return imageUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
