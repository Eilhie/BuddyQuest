import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'avatar_selection_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setting_page.dart';
import 'follow_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to Settings Page or Open Settings
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(), // Navigate to the ReplyPage
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                // left side
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 55, // Adjust size
                          backgroundImage: AssetImage(_profileImage), // Profile Image
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              print('Follow Button Pressed');
                            },
                            child: Text("Follow")
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Full name',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '@username',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to the "Following" page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FollowingFollowersPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '552 ', // Replace with actual count
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                        ),
                        TextSpan(
                          text: 'Following     ',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to the "Followers" page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FollowingFollowersPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '343 ', // Replace with actual count
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                        ),
                        TextSpan(
                          text: 'Followers',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.grey, // Color of the line
              thickness: 1,       // Thickness of the line
              indent: 0,         // Start margin
              endIndent: 0,      // End margin
            ),
            // Post Cards Section
            SizedBox(height: 20),
            Text(
              'Recent Posts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildPostCard(),
            _buildPostCard(),
            _buildPostCard(),
          ],
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

  // Post Card Widget
  Widget _buildPostCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/profiles/boy-default.png'), // Replace with post owner image
                ),
                SizedBox(width: 10),
                Text(
                  'User Name', // Replace with post owner name
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'This is a post description, showcasing some content by the user.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
