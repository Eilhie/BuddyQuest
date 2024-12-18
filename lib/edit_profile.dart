import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Edit Profile',
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
              const SizedBox(height: 20),

              // Profile Picture Section
              FutureBuilder<DocumentSnapshot>(
                future: _getCurrentUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.grey[300],
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage('assets/profiles/default-avatar.png'),
                      backgroundColor: Colors.grey[300],
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final avatar = data['avatar'] ?? 'default-avatar.png';
                    return CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage('assets/profiles/$avatar'),
                      backgroundColor: Colors.grey[300],
                    );
                  }
                  return CircleAvatar(
                    radius: 64,
                    backgroundImage: AssetImage('assets/profiles/default-avatar.png'),
                    backgroundColor: Colors.grey[300],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Username Input Field
              FutureBuilder<DocumentSnapshot>(
                future: _getCurrentUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildInputField(
                      title: 'Username',
                      controller: _usernameController,
                      hintText: 'Loading...',
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildInputField(
                      title: 'Username',
                      controller: _usernameController,
                      hintText: '@username',
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final fullname = data['fullname'] ?? '@username';
                    return _buildInputField(
                      title: 'Username',
                      controller: _usernameController,
                      hintText: fullname,
                    );
                  }
                  return _buildInputField(
                    title: 'Username',
                    controller: _usernameController,
                    hintText: '@username',
                  );
                },
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        String uid = currentUser.uid;
                        String fullname = _usernameController.text.trim();

                        if (fullname.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({'fullname': fullname});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Changes saved!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Full name cannot be empty!')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User not logged in!')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0x99FFFAFA),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
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
        currentIndex: 3,
        onTap: (index) {
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

  Future<DocumentSnapshot> _getCurrentUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    } else {
      throw Exception('User not logged in');
    }
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
