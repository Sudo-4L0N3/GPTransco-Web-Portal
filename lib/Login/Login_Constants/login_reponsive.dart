import 'package:flutter/material.dart';

class LoginResponsive extends StatelessWidget {
  final Widget child;

  const LoginResponsive({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // For large screens (desktops, tablets)
          return SizedBox(
            width: 400,
            child: child,
          );
        } else {
          // For small screens (mobile)
          return Container(
            margin: const EdgeInsets.all(16.0),
            child: child,
          );
        }
      },
    );
  }
}
