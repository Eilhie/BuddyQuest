import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Place children on the left and right
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text('Profile',
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
              CircleAvatar(
                radius: 64,
                backgroundImage: AssetImage('assets/profile_picture.png'),
                backgroundColor: Colors.grey[300],
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
            ],
          ),
        ),
      ),
      // Add the footer here
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures all icons are always visible
        currentIndex: 3, // Set the default active item
        onTap: (index) {
          // Handle navigation based on the selected item
          if (index == 3) {
            // Already on Home
          } else if (index == 1) {
            // Example for navigating to a "Workout" page
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {
            // Example for navigating to a "Leaderboarc" page
            Navigator.pushNamed(context, '/leaderboard');
          } else if (index == 0) {
            // Example for navigating to a "Profile" page
            Navigator.pushNamed(context, '/home');
          }
        },
        selectedItemColor: Colors.deepPurple, // Active tab color
        unselectedItemColor: Colors.black, // Inactive tab color
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

  // Helper Widget for Profile Options
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
}
