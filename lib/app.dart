import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'views/bookmarks/bookmarks_screen.dart';
import 'views/calendar/calendar_screen.dart';
import 'views/home/home_screen.dart';
import 'views/search/search_screen.dart';
import 'views/works/works_screen.dart';

class OshiSukeApp extends StatelessWidget {
  const OshiSukeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '推しスケ',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold();

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    WorksScreen(),
    CalendarScreen(),
    SearchScreen(),
    BookmarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'ホーム',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'マイ作品',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'カレンダー',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: '検索',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'ブックマーク',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
