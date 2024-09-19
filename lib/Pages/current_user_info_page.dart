// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:talkflow_chat_app/Pages/profile_picture_view_page.dart';
import 'package:talkflow_chat_app/Provider/firebase_provider.dart';

class CurrentUserInfoPage extends StatefulWidget {
  const CurrentUserInfoPage({super.key});

  @override
  State<CurrentUserInfoPage> createState() => _CurrentUserInfoPageState();
}

class _CurrentUserInfoPageState extends State<CurrentUserInfoPage> {
  String? selectedImage;
  User? currentUser;
  TextEditingController nameController = TextEditingController();

  Future<String?> _getProfileImageUrl() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.data()?['profileImageUrl'] as String?;
      }
    } catch (e) {
      throw Exception('Error fetching profile image URL: $e');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    nameController.text = currentUser?.displayName ?? "";
    _getProfileImageUrl().then((url) {
      if (url != null) {
        setState(() {
          selectedImage = url;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Profile info"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: () {
                    if (currentUser!.photoURL!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePictureViewPage(
                              profileImageUrl:
                                  currentUser?.photoURL.toString() ?? ""),
                        ),
                      );
                    } else {
                      return;
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: selectedImage == null
                        ? const AssetImage("assets/images/profile_pic.jpg")
                        : selectedImage!.contains('http')
                            ? CachedNetworkImageProvider(selectedImage!)
                            : FileImage(File(selectedImage!)),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedImage =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      setState(() {
                        selectedImage = File(pickedImage.path).path;
                      });
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade500,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "Name"),
                controller: nameController,
              ),
            ),
            /*
            Save Button
            */
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: SizedBox(
                width: 300,
                height: 50,
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    try {
                      setState(() {
                        firebaseProvider.isLoading = true;
                      });
                      if (nameController.text.isNotEmpty) {
                        firebaseProvider.isLoading = true;
                        await firebaseProvider.firestoreService.saveUserData(
                            currentUser!.uid,
                            {"displayName": nameController.text});
                        await currentUser
                            ?.updateDisplayName(nameController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Profile updated successfully!'),
                          ),
                        );
                        firebaseProvider.isLoading = false;
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Name cannot be empty!'),
                          ),
                        );
                      }
                      if (selectedImage != null) {
                        final imageUrl = await firebaseProvider.storageService
                            .uploadImage(
                                File(selectedImage!), currentUser!.uid);
                        if (imageUrl != null) {
                          await currentUser?.updatePhotoURL(imageUrl);
                          setState(() {
                            selectedImage = imageUrl;
                          });
                        }
                      } else {
                        return;
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                              'Error while updating Profile!\nPlease try again'),
                        ),
                      );
                    } finally {
                      setState(() {
                        firebaseProvider.isLoading = false;
                      });
                    }
                  },
                  child: firebaseProvider.isLoading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white, size: 40)
                      : const Text("Save Changes"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
