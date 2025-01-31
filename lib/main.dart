import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gptransco/Login/Screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/main/main_screen.dart';
import 'const/colors/colors.dart';
import 'const/controllers/menu_app_controller.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBq8fIj6dM4_yJBWVp9WyHGzuzePrt8QSQ",
        authDomain: "gptransco-254ab.firebaseapp.com",
        projectId: "gptransco-254ab",
        storageBucket: "gptransco-254ab.appspot.com",
        messagingSenderId: "758811365427",
        appId: "1:758811365427:web:aaed83cc3b9a0569f1d346",
        measurementId: "G-NEQWFGBC8E",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    return isLoggedIn ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while checking login status
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => MenuAppController(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'GPTransco Management Portal',
              theme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: bgColor,
                textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                    .apply(bodyColor: Colors.white),
                canvasColor: secondaryColor,
              ),
              home: snapshot.data == true
                  ? const MainScreen()
                  : const LoginScreen(),
            ),
          );
        }
      },
    );
  }
}
