import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';  // Make sure to import the login page
import 'calibration_flow.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.all(30.0)),
            Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text("Fullname",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Enter your fullname', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey,  // Change hint text color
                  fontSize: 16.0,      // Change font size
                  fontStyle: FontStyle.italic, // Make it italic
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Text("Email",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey,  // Change hint text color
                  fontSize: 16.0,      // Change font size
                  fontStyle: FontStyle.italic, // Make it italic
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Text("Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Enter your password', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey,  // Change hint text color
                  fontSize: 16.0,      // Change font size
                  fontStyle: FontStyle.italic, // Make it italic
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Text("Confirm Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: 'Confirm your Password', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey,  // Change hint text color
                  fontSize: 16.0,      // Change font size
                  fontStyle: FontStyle.italic, // Make it italic
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // Simple registration logic: check passwords match
                if (_passwordController.text == _confirmPasswordController.text) {
                  // Save the login state (user is now logged in)
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalibrationPage()),
                  );

                } else {
                  // Show error if passwords do not match
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Passwords do not match!"),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x9954473F), // Button color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 60), // Full width, 60px height
              ),
              child: Text('SIGN UP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to the Login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
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