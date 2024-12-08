import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'avatar_selection_page.dart'; // Import the new page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _profileImage = 'assets/profile_picture.png'; // Default profile image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to Settings Page or Open Settings
                    },
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(10.0)),
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
              SizedBox(height: 20),

              // Profile Options
              _buildProfileOption(
                context,
                icon: Icons.person_outline,
                title: '@username',
                subtitle: 'Tap to edit User Info',
                onTap: () {
                  Navigator.pushNamed(context, '/editProfile');
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.fitness_center,
                title: 'Workout Plan',
                subtitle: 'Tap to edit workout plan',
                onTap: () {
                  // Navigate to Workout Plan
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.female,
                title: 'Female, 20 years old',
                onTap: () {
                  // Handle Age Edit
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.home_outlined,
                title: 'Kemanggisan, Jakarta Barat',
                onTap: () {
                  // Handle Address Edit
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
              SizedBox(height: 40),
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
                child: Text('Log Out'),
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
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: [
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Navigate to AvatarSelectionPage and get the selected avatar
  void _navigateToAvatarSelection(BuildContext context) async {
    // Wait for the selected avatar image from the AvatarSelectionPage
    String? selectedAvatar = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AvatarSelectionPage()),
    );

    // If an avatar was selected (not null), update the profile image
    if (selectedAvatar != null && selectedAvatar.isNotEmpty) {
      setState(() {
        _profileImage = selectedAvatar;
      });
    }
  }
}