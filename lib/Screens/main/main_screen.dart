import 'package:flutter/material.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:provider/provider.dart';

import '../../const/controllers/menu_app_controller.dart';
import '../../const/responsive/responsive.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<bool> _onWillPop() async {
    // Return false to prevent back navigation
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final menuAppController = context.watch<MenuAppController>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: menuAppController.scaffoldKey,
        drawer: !Responsive.isDesktop(context) ? const SideMenu() : null,
        appBar: !Responsive.isDesktop(context)
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    menuAppController.scaffoldKey.currentState?.openDrawer();
                  },
                ),
                title: const Text('Dashboard'),
                backgroundColor: bgColor,
              )
            : null,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isDesktop(context))
                const Expanded(
                  child: SideMenu(),
                ),
              Expanded(
                flex: 5,
                // Display the currently selected screen
                child: menuAppController.currentScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
