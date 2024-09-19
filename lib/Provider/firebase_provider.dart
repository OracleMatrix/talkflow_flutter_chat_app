import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:talkflow_chat_app/Services/database_service.dart';
import 'package:talkflow_chat_app/Services/firebase_services.dart';
import 'package:talkflow_chat_app/Services/storage_service.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool isLoading = false;

  FirebaseServices get firebaseServices => _firebaseServices;

  StorageService get storageService => _storageService;

  FirestoreService get firestoreService => _firestoreService;

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  FirebaseFirestore get firestore => _firestore;

  FirebaseStorage get firebaseStorage => _firebaseStorage;

}
