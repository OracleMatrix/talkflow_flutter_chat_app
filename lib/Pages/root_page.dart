import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:talkflow_chat_app/Pages/home_page.dart';
import 'package:talkflow_chat_app/Pages/search_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentIndex = 0;

  List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
  ];

  List<IconData> icons = [
    Icons.home,
    Icons.search,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor:
            AdaptiveTheme.of(context).mode.isDark ? Colors.black26: Colors.white,
        elevation: 0,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
        splashColor: Colors.blueAccent,
        gapWidth: 1,
        icons: icons,
        activeIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
    );
  }
}
