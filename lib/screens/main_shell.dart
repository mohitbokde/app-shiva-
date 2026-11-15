import 'package:flutter/material.dart';

import '../app_info.dart';
import 'about_screen.dart';
import 'bhajan_screen.dart';
import 'devotion_screen.dart';
import 'home_screen.dart';
import 'jap_screen.dart';
import 'jyotirlinga_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔱 ${AppInfo.name} 🔱'),
        actions: [
          IconButton(
            tooltip: 'परिचय',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('परिचय')),
                    body: const AboutScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onGoTab: _go),
          const JapScreen(),
          const BhajanScreen(),
          const JyotirlingaScreen(),
          const DevotionScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'होम',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_unchecked_rounded),
            selectedIcon: Icon(Icons.radio_button_checked_rounded),
            label: 'जाप',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note_rounded),
            label: 'भजन',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance_rounded),
            label: 'दर्शन',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'भक्ति',
          ),
        ],
      ),
    );
  }
}
