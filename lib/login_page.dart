import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calibration_flow.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'google_signin_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/user_sevice.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: GoogleSignInConfig.clientId, // Add your client ID here
  );
  final userService = UserService();

  // Initialize FirebaseFirestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable to toggle password visibility
  bool _isPasswordVisible = false;

  // Login with Email & Password
  Future<void> _signInWithEmailPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in. Please try again.')),
      );
    }
  }

  // Login with Google
  Future<void> _signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user data already exists
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CalibrationPage()),
          );
          var workout_type = await userService.getUserWorkoutCategory(user.uid);
          // Store user data only if it's a new user
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'fullname': user.displayName ?? '',
            'email': user.email,
            'points': 0, // Default value
            'workout_type': workout_type, // Default value
            'avatar': 'boy-default',
            'follow_master': {
              'following': <String>[],
              'follower': <String>[]
            }
          }).catchError((error) {
            print('Error storing user data: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign-in failed. Please try again.')),
            );
          });

          // Create entry in weekly workout status if it's a new user
          var currDate = DateTime.now();
          await _firestore.collection('user_weekly_workout_progress').doc(user.uid).set({
            'uid': user.uid,
            'last_update': currDate.add(Duration(days: (7 - currDate.weekday + 1)))
                .subtract(Duration(hours: currDate.hour, minutes: currDate.minute)), // Set last updated to the start of next week
            'day0': <String>[],
            'day1': <String>[],
            'day2': <String>[],
            'day3': <String>[],
            'day4': <String>[],
            'day5': <String>[],
            'day6': <String>[]
          });
        }
      }

      // Navigate to home page
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error during Google sign-in or saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Email",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // Toggle password visibility
              decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signInWithEmailPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0x9954473F),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: Image.asset(
                'assets/logo/google_logo.png', // Path to your local image
                height: 24,
                width: 24,
              ),
              label: const Text(
                'SIGN IN WITH GOOGLE',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
