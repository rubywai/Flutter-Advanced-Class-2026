import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../const/utils/screen_utils.dart';
import 'desktop_home_page.dart';
import 'mobile_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return responsiveScreen(
     context:  context,
      desktop: DesktopHomePage(shell: widget.shell),
      mobile: MobileHomePage(shell: widget.shell),
    );
  }
}
