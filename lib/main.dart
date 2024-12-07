import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'profile.dart';
import 'edit_profile.dart';
import 'leaderboard.dart';
import 'calibration_flow.dart';
import 'workout_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: "..env");

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: FirebaseOptionsConfig.apiKey,
      appId: FirebaseOptionsConfig.appId,
      messagingSenderId: FirebaseOptionsConfig.messagingSenderId,
      projectId: FirebaseOptionsConfig.projectId,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootScreen(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
        '/editProfile': (context) => EditProfilePage(),
        '/leaderboard': (context) => LeaderboardPage(),
        '/calibration': (context) => CalibrationPage(),
        '/workout': (context) => WorkoutPlanPage(),
      },
    );
  }
}

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool? _isLoggedIn; // Track null while loading

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if the user is logged in using SharedPreferences
  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false; // Default to not logged in if an error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while checking login status
    if (_isLoggedIn == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate to the appropriate page
    return _isLoggedIn! ? HomePage() : LoginPage();
  }
}