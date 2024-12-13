import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'calibration_flow.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  RegisterPage({super.key});

  Future<void> _registerUser(BuildContext context) async {
    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

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
      // Check if email is already registered
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // Email already exists in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This email is already registered. Please log in. "),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create user with Firebase Authentication
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
          'workout_type': '', // Default value
          'avatar': 'boy-default.png',
        });

        var currDate = DateTime.now();
        print(currDate.add(Duration(days:(7 - currDate.weekday + 1))).subtract(Duration(hours:currDate.hour, minutes:currDate.minute)));
        await FirebaseFirestore.instance.collection('user_weekly_workout_progress').doc(user.uid).set({
          'uid':user.uid,
          'last_update': currDate.add(Duration(days:(7 - currDate.weekday + 1))).subtract(Duration(hours:currDate.hour, minutes:currDate.minute)), //set last updated to beginning to next week (Monday 00:00)
          'day0':<String>[],
          'day1':<String>[],
          'day2':<String>[],
          'day3':<String>[],
          'day4':<String>[],
          'day5':<String>[],
          'day6':<String>[]
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
        // FirebaseAuth email already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This email is already in use. Please try logging in."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Handle other FirebaseAuth exceptions
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to create account: ${e.message}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Catch any other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An unexpected error occurred: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
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
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
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
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm your Password',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _registerUser(context), // Call the Firebase registration logic
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
                // Navigate to the Login page
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