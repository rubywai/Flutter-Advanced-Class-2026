import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  @override
  Widget build(BuildContext context) {
    StatefulNavigationShell shell = widget.shell;
    return Scaffold(
      appBar: AppBar(title: const Text('Crypto Price App')),
      body: widget.shell,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          shell.goBranch(index);
        },
        selectedIndex: shell.currentIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Overview'),
          NavigationDestination(
            icon: Icon(Icons.stacked_bar_chart),
            label: 'Prices',
          ),
          NavigationDestination(icon: Icon(Icons.newspaper), label: 'News'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
