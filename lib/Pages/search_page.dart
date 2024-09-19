// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  String _searchTerm = '';

  Future<QuerySnapshot<Map<String, dynamic>>> _searchUsers(
      String searchTerm) async {
    if (searchTerm.isEmpty) {
      return FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: "")
          .get();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: searchTerm.toLowerCase())
          .get();
    }
  }

  Future<void> _addFriend(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Check if the friend is already added
        final friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('friends')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text('This user is already your friend!'),
            ),
          );
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('friends')
              .doc(friendId)
              .set({});

          await FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('friends')
              .doc(currentUser.uid)
              .set({});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('${searchController.text} added to your friends!'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error adding friend: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                keyboardType: TextInputType.emailAddress,
                controller: searchController,
                hintText: "Search users by email or ID",
                elevation: const WidgetStatePropertyAll(0),
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    _searchTerm = value;
                  });
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: _searchUsers(_searchTerm),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 50,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: Colors.blueGrey,
                        size: 50,
                      ),
                    );
                  }

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> users =
                      snapshot.data!.docs;
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 50),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              _searchTerm.isEmpty
                                  ? 'Search for users by email'
                                  : 'No users found matching "$_searchTerm"',
                              style: const TextStyle(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userDoc = users[index];
                        final userData = userDoc.data();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userData['profileImageUrl'] != null
                                ? CachedNetworkImageProvider(
                                    userData['profileImageUrl'],
                                  )
                                : const AssetImage(
                                    "assets/images/profile_pic.jpg",
                                  ),
                          ),
                          title: Text(
                            userData['displayName'] ?? userData['email'],
                          ),
                          subtitle: userData['displayName'] != null
                              ? Text(userData['email'])
                              : const Text(""),
                          trailing: TextButton(
                            onPressed: () {
                              _addFriend(userDoc.id);
                            },
                            child: const Text("Add Friend"),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
