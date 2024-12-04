import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

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
              // Header with back button and title
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
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to Settings Page
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Settings button pressed')),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Profile Picture Section
              CircleAvatar(
                radius: 64,
                backgroundImage: AssetImage('assets/profile_picture.png'),
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(height: 20),

              // Username Input Field
              _buildInputField(
                title: 'Username',
                controller: _usernameController,
                hintText: '@username',
              ),

              // Location Input Field
              _buildInputField(
                title: 'Location',
                controller: _locationController,
                hintText: 'Your location',
              ),

              // Age Input Field
              _buildInputField(
                title: 'Age',
                controller: _ageController,
                hintText: 'Your age',
              ),

              // Save Changes Button
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Makes the button full width
                child: ElevatedButton(
                  onPressed: () async {
                    // Add save changes functionality here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Changes saved!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x99FFFAFA), // Button color
                    padding: EdgeInsets.symmetric(vertical: 16), // Add vertical padding for button height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Footer Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Set the Profile page as active
        onTap: (index) {
          // Handle navigation logic
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/workout');
              break;
            case 2:
              Navigator.pushNamed(context, '/leaderboard');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
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

  // Helper Widget for Input Fields
  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
