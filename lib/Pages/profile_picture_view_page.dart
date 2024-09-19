import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePictureViewPage extends StatelessWidget {
  final String profileImageUrl;

  const ProfilePictureViewPage({super.key, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff141218),
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: profileImageUrl,
            errorWidget: (context, url, error) => const Icon(
              Icons.error,
              size: 50,
            ),
            progressIndicatorBuilder: (context, url, progress) =>
                CircularProgressIndicator(
              value: progress.progress,
            ),
          ),
        ),
      ),
    );
  }
}
