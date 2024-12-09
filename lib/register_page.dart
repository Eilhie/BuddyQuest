import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Make sure to import the login page
import 'calibration_flow.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

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
            _buildLabel('Fullname'),
            _buildTextField(
              controller: _fullNameController,
              hintText: 'Enter your fullname',
            ),
            SizedBox(height: 10),
            _buildLabel('Email'),
            _buildTextField(
              controller: _emailController,
              hintText: 'Enter your email',
            ),
            SizedBox(height: 10),
            _buildLabel('Password'),
            _buildPasswordField(
              controller: _passwordController,
              hintText: 'Enter your password',
              isHidden: _isPasswordHidden,
              onVisibilityToggle: () {
                setState(() {
                  _isPasswordHidden = !_isPasswordHidden;
                });
              },
            ),
            SizedBox(height: 10),
            _buildLabel('Confirm Password'),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: 'Confirm your password',
              isHidden: _isConfirmPasswordHidden,
              onVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Dummy registration action
                if (_passwordController.text == _confirmPasswordController.text) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalibrationPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Passwords do not match!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x9954473F),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 60),
              ),
              child: Text(
                'SIGN UP',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
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

  // Helper for labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Helper for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // Helper for password fields
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isHidden,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isHidden,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
        ),
        suffixIcon: IconButton(
          icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: onVisibilityToggle,
        ),
      ),
    );
  }
}
