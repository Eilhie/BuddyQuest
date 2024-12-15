import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_engineering_project/services/user_sevice.dart';
import 'calibration_flow.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordVisible = false; // State for password visibility
  bool _isConfirmPasswordVisible = false; // State for confirm password visibility
  bool _isLoadingRegister = false;

  Future<void> _registerUser(BuildContext context) async {
    _isLoadingRegister = true;
    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final userService = UserService();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This email is already registered. Please log in."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullname': fullName,
          'email': email,
          'points': 0, // Default value
          'workout_type': "",
          "currentStreak" : 0,
          "highestStreak" : 0,
          "lastStreakUpdate":DateTime.now().subtract(Duration(days:1)),
          'avatar': 'boy-default.png',
          'follow_master': {
            'following': <String>[],
            'follower': <String>[]
          }
        });

        var currDate = DateTime.now();
        await FirebaseFirestore.instance
            .collection('user_weekly_workout_progress')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'last_update': currDate
              .add(Duration(days: (7 - currDate.weekday + 1)))
              .subtract(Duration(hours: currDate.hour, minutes: currDate.minute)),
          'day0': <String>[],
          'day1': <String>[],
          'day2': <String>[],
          'day3': <String>[],
          'day4': <String>[],
          'day5': <String>[],
          'day6': <String>[]
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalibrationPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Colors.green,
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This email is already in use. Please try logging in."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to create account: ${e.message}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An unexpected error occurred: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
    _isLoadingRegister = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.all(30.0)),
            const Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Fullname",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your fullname',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10.0)),
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
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10.0)),
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
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
            const Padding(padding: EdgeInsets.all(10.0)),
            const Text(
              "Confirm Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Confirm your password',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async
              {
                _isLoadingRegister ? null : await _registerUser(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0x9954473F),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text('SIGN UP',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
