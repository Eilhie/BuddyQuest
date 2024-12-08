import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
              'Sign In',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Email",
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
                  color: Colors.grey, // Change hint text color
                  fontSize: 16.0, // Change font size
                  fontStyle: FontStyle.italic, // Make it italic
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Text(
              "Password",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // Hide or show password
              decoration: InputDecoration(
                hintText: 'Enter your password', // Placeholder text
                hintStyle: TextStyle(
                  color: Colors.grey, // Change hint text color
                  fontSize: 16.0, // Change font size
                  fontStyle: FontStyle.italic, // Make it italic
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
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // Simulate login logic (check credentials, etc.)
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', true);

                // Navigate to the home page after login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x9954473F), // Button color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 60), // Full width, 60px height
              ),
              child: Text('SIGN IN',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Placeholder for Google Sign-In logic
              },
              icon: Image.network(
                'https://www.google.com/favicon.ico',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              label: Text('Sign Up with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Google button blue
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 60),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to Register page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text(
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
