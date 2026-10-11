import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    StatefulNavigationShell shell = widget.shell;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Price App'),
        bottom: TabBar(
          controller: _controller,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Overview'),
            Tab(icon: Icon(Icons.stacked_bar_chart), text: 'Prices'),
            Tab(icon: Icon(Icons.newspaper), text: 'News'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
          onTap: (int index) {
            shell.goBranch(index);
          },
        ),
      ),
      body: widget.shell,
    );
  }
}
