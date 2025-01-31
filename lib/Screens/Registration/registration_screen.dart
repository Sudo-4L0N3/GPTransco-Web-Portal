import 'package:flutter/material.dart';
import 'widgets/registered_users_list.dart';
import 'widgets/registration_form.dart'; // Import the right container widget

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileOrTablet = screenWidth < 850; // Adjust breakpoint as needed

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Adjust margin to your requirement
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isMobileOrTablet
                ? const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RegistrationForm(),
                        SizedBox(height: 16.0),
                        RegisteredUsersList(),
                      ],
                    ),
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: RegistrationForm(),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        flex: 2,
                        child: RegisteredUsersList(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: RegistrationScreen(),
  ));
}
