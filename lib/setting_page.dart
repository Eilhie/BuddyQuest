import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'avatar_selection_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'BMI_page.dart';
import 'calibration_flow.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _profileImage = 'assets/profiles/boy-default.png'; // Default profile image

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        final avatarFilename = doc.data()?['avatar'];
        if (avatarFilename != null && avatarFilename.isNotEmpty) {
          setState(() {
            _profileImage = 'assets/profiles/$avatarFilename';
          });
        }
      }
    }
  }

  Future<String> _getUserFullName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return doc.data()?['fullname'] ?? 'Guest';
      }
    }
    return 'Guest'; // Default value if no user or fullname found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '             '
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(10.0)),
              // Profile Picture
              GestureDetector(
                onTap: () {
                  _navigateToAvatarSelection(context);
                },
                child: CircleAvatar(
                  radius: 64,
                  backgroundImage: AssetImage(_profileImage),
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 20),

              // Profile Options with dynamic @username
              FutureBuilder<String>(
                future: _getUserFullName(),
                builder: (context, snapshot) {
                  String fullname = '@username';
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    fullname = 'Loading...';
                  } else if (snapshot.hasError) {
                    fullname = '@username';
                  } else if (snapshot.hasData) {
                    fullname = snapshot.data!;
                  }
                  return _buildProfileOption(
                    context,
                    icon: Icons.person_outline,
                    title: fullname,
                    subtitle: 'Tap to edit User Info',
                    onTap: () {
                      Navigator.pushNamed(context, '/editProfile');
                    },
                  );
                },
              ),

              _buildProfileOption(
                context,
                icon: Icons.fitness_center,
                title: 'Workout Plan',
                subtitle: 'Tap to edit workout plan',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CalibrationPage()),
                  );
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.calculate_outlined,
                title: 'BMI Calculator',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BMIPage()),
                  );
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Shortcuts',
                onTap: () {
                  // Navigate to Privacy Shortcuts
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  // Navigate to Help Center
                },
              ),
              const SizedBox(height: 40),

              // Log Out Button
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) {
          // Handle navigation
          if (index == 3) {
            // Already on Profile page
          } else if (index == 1) {
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/leaderboard');
          } else if (index == 0) {
            Navigator.pushNamed(context, '/home');
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Profile option helper
  Widget _buildProfileOption(BuildContext context,
      {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Navigate to AvatarSelectionPage and get the selected avatar
  void _navigateToAvatarSelection(BuildContext context) async {
    String? selectedAvatar = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AvatarSelectionPage()),
    );

    if (selectedAvatar != null && selectedAvatar.isNotEmpty) {
      setState(() {
        _profileImage = 'assets/profiles/$selectedAvatar';
      });
    }
  }
}
