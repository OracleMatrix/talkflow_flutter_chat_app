// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talkflow_chat_app/Models/messages_model.dart';
import 'package:talkflow_chat_app/Pages/profile_picture_view_page.dart';
import 'package:talkflow_chat_app/Pages/user_info_page.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> receiverUser;

  const ChatPage({super.key, required this.receiverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _user = FirebaseAuth.instance.currentUser!;
  List<ChatMessage> messages = [];
  final ChatUser _currentUser = ChatUser(
    id: FirebaseAuth.instance.currentUser!.uid,
    firstName: FirebaseAuth.instance.currentUser!.displayName ??
        FirebaseAuth.instance.currentUser!.email!,
    profileImage: FirebaseAuth.instance.currentUser!.photoURL ??
        "assets/images/profile_pic.jpg",
  );

  late ChatUser secondUser = ChatUser(
    id: widget.receiverUser['uid'], // Changed from 'id' to 'uid'
    firstName:
        widget.receiverUser['displayName'] ?? widget.receiverUser['email'],
    profileImage: widget.receiverUser['profileImageUrl'] ??
        "assets/images/profile_pic.jpg",
  );

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage(ChatMessage message) async {
    try {
      final chatId = _getChatId(_user.uid, widget.receiverUser['uid']!);

      final chatDoc =
          FirebaseFirestore.instance.collection('chats').doc(chatId);
      await chatDoc.set({
        'chatId': chatId,
        'participants': [_user.uid, widget.receiverUser['uid']!],
      }, SetOptions(merge: true));
      final newMessage = Message(
        content: message.text,
        senderID: _user.uid,
        receiverID: widget.receiverUser['uid']!,
        messageType: message.medias != null && message.medias!.isNotEmpty
            ? MessageType.Media
            : MessageType.Text,
        sentAt: Timestamp.fromDate(message.createdAt),
        mediaUrl: message.medias != null && message.medias!.isNotEmpty
            ? message.medias!.first.url
            : null,
      );

      await chatDoc.collection('messages').add(newMessage.toJson());
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  String _getChatId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) < 0) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  Future<void> _sendMediaMessage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final storageRef = FirebaseStorage.instance.ref();
      final mediaRef = storageRef.child('pictures/$fileName');
      await mediaRef.putFile(file);

      final downloadURL = await mediaRef.getDownloadURL();

      final chatMessage = ChatMessage(
        medias: [
          ChatMedia(
            isUploading: true,
            uploadedDate: DateTime.now(),
            url: downloadURL,
            fileName: fileName,
            type: MediaType.image,
          ),
        ],
        user: _currentUser,
        createdAt: DateTime.now(),
      );
      _sendMessage(chatMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatId = _getChatId(_user.uid, widget.receiverUser['uid']!);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserInfoPage(
                  userImageUrl: widget.receiverUser['profileImageUrl'] ?? "",
                  name: widget.receiverUser['displayName'] ?? "",
                  email: widget.receiverUser['email'],
                  uid: widget.receiverUser['uid'],
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.receiverUser['profileImageUrl'] != null
                  ? CachedNetworkImageProvider(
                      widget.receiverUser['profileImageUrl'],
                    )
                  : const AssetImage("assets/images/profile_pic.jpg"),
            ),
            title: Text(
              widget.receiverUser['displayName'] ??
                  widget.receiverUser['email'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              widget.receiverUser['email'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('sentAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Colors.blueGrey, size: 50),
            );
          }

          final messageDocs = snapshot.data!.docs;
          messages = messageDocs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final message = Message.fromJson(data);
                return _mapToDashChatMessage(message);
              })
              .toList()
              .reversed
              .toList();

          return Stack(
            children: [
              DashChat(
                scrollToBottomOptions: ScrollToBottomOptions(
                  scrollToBottomBuilder: (scrollController) {
                    return DefaultScrollToBottom(
                      scrollController: scrollController,
                      textColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                    );
                  },
                ),
                messageOptions: MessageOptions(
                  showTime: true,
                  showCurrentUserAvatar: false,
                  showOtherUsersAvatar: false,
                  currentUserContainerColor: Colors.lightBlueAccent,
                  currentUserTextColor: Colors.white,
                  onTapMedia: (media) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePictureViewPage(profileImageUrl: media.url),
                      ),
                    );
                  },
                ),
                inputOptions: InputOptions(
                  trailing: [
                    IconButton(
                      onPressed: _sendMediaMessage,
                      icon: const Icon(Icons.attach_file),
                    ),
                  ],
                  sendButtonBuilder: (send) {
                    return IconButton(
                      onPressed: send,
                      icon: const Icon(Icons.send),
                    );
                  },
                  inputTextStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                currentUser: _currentUser,
                // Removed extra colon
                onSend: _sendMessage,
                messages: messages,
              ),
              messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 60, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'No messages yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          );
        },
      ),
    );
  }

  ChatMessage _mapToDashChatMessage(Message message) {
    return ChatMessage(
      text: message.content,
      user: ChatUser(
        id: message.senderID,
        firstName: message.senderID == _user.uid
            ? _currentUser.firstName
            : (widget.receiverUser['displayName'] ??
                widget.receiverUser['email']),
        profileImage: message.senderID == _user.uid
            ? _currentUser.profileImage
            : (widget.receiverUser['profileImageUrl'] ?? ''),
      ),
      medias: message.mediaUrl != null
          ? [
              ChatMedia(
                url: message.mediaUrl!,
                fileName: 'media',
                type: message.messageType == MessageType.Media
                    ? MediaType.image
                    : MediaType.file,
              ),
            ]
          : null,
      createdAt: message.sentAt.toDate(),
    );
  }
}
