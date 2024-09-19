// ignore_for_file: use_build_context_synchronously, control_flow_in_finally

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:talkflow_chat_app/Pages/auth_page.dart';
import 'package:talkflow_chat_app/Pages/current_user_info_page.dart';
import 'package:talkflow_chat_app/Provider/firebase_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final firebaseProvider =
        Provider.of<FirebaseProvider>(context, listen: false);
    User? user = firebaseProvider.firebaseAuth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: const Text("Profile"),
                trailing: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrentUserInfoPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            endIndent: 50,
            indent: 50,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: SizedBox(
              width: 300,
              height: 50,
              child: MaterialButton(
                color: Colors.red,
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Account"),
                        content: const Text(
                            "Are you sure you want to delete your account?\nWhen you delete your account all of your data such as your friends, chats, medias and... will be delete permanently!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              setState(() {
                                _isDeleting = true;
                              });
                              try {
                                if (user != null && user.uid.isNotEmpty) {
                                  deleteUser();
                                  deleteUserFriendsCollections(user);
                                  deleteUserCollection(user);
                                  deleteUserStorage(user);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuthPage(),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          "Your account deleted successfully!\nCome back later ;)"),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                          "Failed to delete your account!"),
                                    ),
                                  );
                                }
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Process failed!"),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isDeleting = false;
                                });
                              }
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: _isDeleting
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.white,
                        size: 20,
                      )
                    : const Text("Delete Account"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteUserFriendsCollections(User user) async {
    final friendsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('friends');

    final friendsSnapshot = await friendsCollection.get();
    for (var doc in friendsSnapshot.docs) {
      String friendUserId = doc.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(friendUserId)
          .collection('friends')
          .doc(user.uid)
          .delete();

      await doc.reference.delete();
    }
  }

  Future<void> deleteUserCollection(User user) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();
  }

  Future<void> deleteUserStorage(User user) async {
    await FirebaseStorage.instance
        .ref()
        .child('profile_images/${user.uid}.jpg')
        .delete();
  }
}
