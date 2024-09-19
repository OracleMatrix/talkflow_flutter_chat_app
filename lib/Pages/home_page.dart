// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkflow_chat_app/Pages/auth_page.dart';
import 'package:talkflow_chat_app/Pages/chat_page.dart';
import 'package:talkflow_chat_app/Pages/profile_picture_view_page.dart';
import 'package:talkflow_chat_app/Pages/settings_page.dart';
import 'package:talkflow_chat_app/Pages/current_user_info_page.dart';
import 'package:talkflow_chat_app/Provider/firebase_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<Map<String, dynamic>?> getLastMessageStream(
      String currentUserId, String otherUserId) {
    final chatId = getChatId(currentUserId, otherUserId);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final messageData = snapshot.docs.first.data();
        return {
          'content': messageData['content'] as String?,
          'type': messageData['messageType'] as String?,
          'mediaUrl': messageData['mediaUrl'] as String?,
        };
      }
      return null;
    });
  }

  String getChatId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) < 0) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  String searchTerm = '';

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
    _getProfileImageUrl().then((url) {
      if (url != null) {
        setState(() {
          selectedImage = url;
        });
      }
    });
  }

  Stream<List<QueryDocumentSnapshot>> _getFriendsStream(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  String? selectedImage;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      /*
      Appbar
      */
      appBar: AppBar(
        title: const Text("TalkFlow"),
        centerTitle: true,
      ),
      /*
      Drawer
      */
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Colors.blueGrey, size: 50),
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading user data'));
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              children: [
                /*
               DrawerHeader
                */
                DrawerHeader(
                  child: Column(
                    children: [
                      GestureDetector(
                        onLongPressUp: () {
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
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CurrentUserInfoPage(),
                              ));
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: userData['profileImageUrl'] != null
                              ? CachedNetworkImageProvider(
                                  userData['profileImageUrl'])
                              : const AssetImage("assets/images/profile_pic.jpg"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userData['displayName'] ??
                            currentUser!.email.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        currentUser?.displayName != null
                            ? currentUser!.email.toString()
                            : "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                /*
                Drawer Options
                */
                ListTile(
                  title: const Text("Theme"),
                  trailing: Switch(
                    value: AdaptiveTheme.of(context).mode.isDark,
                    onChanged: (value) {
                      AdaptiveTheme.of(context).setThemeMode(value
                          ? AdaptiveThemeMode.dark
                          : AdaptiveThemeMode.light);
                    },
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                ListTile(
                  title: const Text("Settings"),
                  trailing: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                const Spacer(),
                const Divider(
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: const Text("Log Out"),
                    trailing: const Icon(Icons.logout),
                    onTap: () async {
                      /*
                      Show alert dialog for logout
                      */
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout!"),
                            content:
                                const Text("Are you sure you want to logout?!"),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await firebaseProvider.firebaseServices
                                      .logOutUser();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuthPage(),
                                    ),
                                  );
                                },
                                child: const Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("No"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      /*
       Body Stream Builder get friends
      */
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _getFriendsStream(currentUser!.uid),
        // Get friends instead of all users
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error: ${snapshot.error}'),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Colors.blueGrey, size: 50),
            );
          }

          List<QueryDocumentSnapshot> friends = snapshot.data!;
          friends
              .where(
                (element) => element.exists,
              )
              .toList();

          if (friends.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text("No friends yet! Add some friends!"),
                ],
              ),
            );
          }
          /*
          ListView Builder Chats
          */
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friendDoc = friends[index];
              final friendId = friendDoc.id;
              /*
              Stream Builder Chats show friends
              */
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(),
                      title: Text("Loading..."),
                      subtitle: Text(""),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  final friendData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  /*
                  Final StreamBuilder Chats get last messages
                  * */
                  return StreamBuilder<Map<String, dynamic>?>(
                    stream: getLastMessageStream(
                        currentUser!.uid, friendData['uid']!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                friendData['profileImageUrl'] != null
                                    ? CachedNetworkImageProvider(
                                        friendData['profileImageUrl'])
                                    : const AssetImage(
                                        "assets/images/profile_pic.jpg"),
                          ),
                          title: Text(
                              friendData['displayName'] ?? friendData['email']),
                          subtitle: const Text('Loading...'),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                friendData['profileImageUrl'] != null
                                    ? CachedNetworkImageProvider(
                                        friendData['profileImageUrl'])
                                    : const AssetImage(
                                        "assets/images/profile_pic.jpg"),
                          ),
                          title: Text(
                              friendData['displayName'] ?? friendData['email']),
                          subtitle: const Text('Error loading message'),
                        );
                      } else {
                        final lastMessageData = snapshot.data;
                        final lastMessage = lastMessageData?['content'];
                        final messageType = lastMessageData?['type'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(receiverUser: friendData),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      friendData['profileImageUrl'] != null
                                          ? CachedNetworkImageProvider(
                                              friendData['profileImageUrl'])
                                          : const AssetImage(
                                              "assets/images/profile_pic.jpg"),
                                ),
                                title: Text(friendData['displayName'] ??
                                    friendData['email']),
                                subtitle: messageType == "Media"
                                    ? const Text("Sent an Image")
                                    : Text(
                                        lastMessage ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
