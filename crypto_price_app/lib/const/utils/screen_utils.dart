import 'package:flutter/material.dart';

Widget responsiveScreen({
  required BuildContext context,
  required Widget desktop,
  required Widget mobile,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 750) {
        return desktop;
      } else {
        return mobile;
      }
    },
  );
}

bool isMobileView(BuildContext context) {
  return MediaQuery.of(context).size.width < 750;
}
