import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkflow_chat_app/Pages/profile_picture_view_page.dart';

class UserInfoPage extends StatelessWidget {
  final String userImageUrl, name, email, uid;

  const UserInfoPage({
    super.key,
    required this.userImageUrl,
    required this.name,
    required this.email,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                if (userImageUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePictureViewPage(profileImageUrl: userImageUrl),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(milliseconds: 500),
                      backgroundColor: Colors.orange,
                      content: Text("User has no Profile image!"),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 100,
                backgroundImage: userImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(userImageUrl)
                    : const AssetImage("assets/images/profile_pic.jpg"),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                email,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Text("ID : $uid"),
            const SizedBox(height: 15),
            const Divider()
          ],
        ),
      ),
    );
  }
}
