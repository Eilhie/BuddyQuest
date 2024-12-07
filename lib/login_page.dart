import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:software_engineering_project/flutter_dotenv.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'google_signin_config.dart';

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

  // Login with Email & Password
  Future<void> _signInWithEmailPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
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

      // Create a new credential for Firebase
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error during Google sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed. Please try again.')),
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
                hintText: 'Enter your email',
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
              decoration: InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signInWithEmailPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x9954473F),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 60),
              ),
              child: Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: Icon(Icons.login),
              label: Text('Sign In with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
