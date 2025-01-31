// admin_control_screen.dart
import 'package:flutter/material.dart';
import 'widget/customer_list_container.dart';
import 'widget/report_list.dart';

class AdminControlScreen extends StatelessWidget {
  const AdminControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile and tablet layout
              return const Column(
                children: [
                  Expanded(
                    child: CustomerListContainer(),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ReportList(),
                  ),
                ],
              );
            } else {
              // Desktop layout
              return const Row(
                children: [
                  Expanded(
                    child: CustomerListContainer(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ReportList(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
