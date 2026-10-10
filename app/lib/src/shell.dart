import 'package:flutter/material.dart';

import 'add_tree/add_tree_screen.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';
import 'profile/profile_screen.dart';
import 'ranking/ranking_screen.dart';

/// Pastki navigatsiya: Home · Add Tree · Map · Ranking · Profile.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  // Har safar tab ochilganda ma'lumot yangilanishi uchun kalit.
  int _refresh = 0;

  void _go(int i) => setState(() {
    _index = i;
    _refresh++;
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(key: ValueKey('home$_refresh'), onAddTree: () => _go(1)),
      AddTreeScreen(key: ValueKey('add$_refresh'), onSubmitted: () => _go(4)),
      MapScreen(key: ValueKey('map$_refresh')),
      RankingScreen(key: ValueKey('rank$_refresh')),
      ProfileScreen(key: ValueKey('profile$_refresh')),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Bosh sahifa'),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Qo\'shish',
          ),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Xarita'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Reyting',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
