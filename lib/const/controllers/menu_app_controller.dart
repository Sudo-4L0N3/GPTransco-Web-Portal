import 'package:flutter/material.dart';

import '../../Screens/dashboard/dashboard_screen.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  // Track the current screen
  Widget _currentScreen = const DashboardScreen();

  Widget get currentScreen => _currentScreen;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  // Function to change the displayed screen
  void changeScreen(Widget screen) {
    _currentScreen = screen;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
