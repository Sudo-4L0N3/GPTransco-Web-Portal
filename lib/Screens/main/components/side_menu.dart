import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Login/Screen/login_screen.dart';
import '../../../const/controllers/menu_app_controller.dart';
import '../../AdminControl/admin_control_screen.dart';
import '../../Lost And Found/LNF_Screen.dart';
import '../../Paymen Approval/payment_approval_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../registration/registration_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final menuAppController = context.read<MenuAppController>();
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 120, // Limit the height of the DrawerHeader
              child: Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 100, // Adjust the size of the logo
                  width: 100,  // Adjust the size of the logo
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          DrawerListTile(
            title: "    DASHBOARD",
            svgSrc: "assets/icons/dashboard.svg",
            press: () {
              menuAppController.changeScreen(const DashboardScreen());
              _closeDrawerIfNeeded(context);
            },
          ),
          // New Button for Payment Approval
          DrawerListTile(
            title: "    PAYMENT APPROVAL",
            svgSrc: "assets/icons/payment.svg", // Ensure you have this icon in your assets
            press: () {
              menuAppController.changeScreen(const PaymentApprovalScreen()); // Replace with your actual screen
              _closeDrawerIfNeeded(context);
            },
          ),
          DrawerListTile(
            title: "    ADMIN CONTROL",
            svgSrc: "assets/icons/control.svg",
            press: () {
              menuAppController.changeScreen(const AdminControlScreen());
              _closeDrawerIfNeeded(context);
            },
          ),
          DrawerListTile(
            title: "    REGISTRATION",
            svgSrc: "assets/icons/registration.svg",
            press: () {
              menuAppController.changeScreen(const RegistrationScreen());
              _closeDrawerIfNeeded(context);
            },
          ),
          DrawerListTile(
            title: "    LOST AND FOUND",
            svgSrc: "assets/icons/box.svg",
            press: () {
              menuAppController.changeScreen(const LNFScreen());
              _closeDrawerIfNeeded(context);
            },
          ),
          DrawerListTile(
            title: "    LOGOUT",
            svgSrc: "assets/icons/logout.svg",
            press: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: navy,
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel", style: TextStyle(color: white)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Logout", style: TextStyle(color: red)),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                // Clear login status
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('isLoggedIn');
                // Sign out from FirebaseAuth
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                _closeDrawerIfNeeded(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper method to close drawer only for mobile/tablet screen sizes
  void _closeDrawerIfNeeded(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // If screen width is less than or equal to 768px, assume it's mobile or tablet
    if (screenWidth <= 768) {
      Navigator.pop(context); // Close the drawer only on mobile or tablet
    }
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}