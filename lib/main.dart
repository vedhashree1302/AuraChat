import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Note: You must run 'flutterfire configure' in your terminal
// to generate this file (firebase_options.dart) and the configuration.
import 'firebase_options.dart';
import 'HomePage.dart'; // The screen for signed-in users
import 'LoginPage.dart'; // The screen for signed-out users

void main() async {
  // 1. Ensure Flutter widgets are initialized before calling native code (Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using the automatically generated options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    // If Firebase initialization fails, display a fatal error screen.
    print("FATAL ERROR: Firebase initialization failed: $e");
    runApp(const FatalErrorApp());
  }
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraChat',
      theme: ThemeData(
        // General theme settings
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF16101B), // darkIndigo
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16101B), // darkIndigo
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The app starts here, checking the user's authentication state.
      home: const AuthWrapper(),
    );
  }
}

/// A router widget that listens to the Firebase authentication state.
/// It shows the LoginPage if no user is signed in, or the HomePage if one is.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens for changes in the user's sign-in status
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while Firebase is determining the user's status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFAEB8FF),
              ), // lightAccent color
            ),
          );
        }

        // If a User object is present (signed in)
        if (snapshot.hasData && snapshot.data != null) {
          // If signed in, show the Home Page
          return const HomePage();
        }

        // If the user is signed out (snapshot.data is null), show the Login Page
        return const LoginPage();
      },
    );
  }
}

/// A fallback widget to display if the main Firebase initialization fails.
class FatalErrorApp extends StatelessWidget {
  const FatalErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Error: Could not initialize app services. Check Firebase setup.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
