import 'package:flutter/material.dart';
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
  String _fullName = 'Guest';
  int _followerCount = 0;
  int _followingCount = 0;
  List<Map<String, dynamic>> _userPosts = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadProfileData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Fetch user data
      final doc = await userDoc.get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _fullName = data?['fullname'] ?? 'Guest';
          final avatarFilename = data?['avatar'];
          if (avatarFilename != null && avatarFilename.isNotEmpty) {
            _profileImage = 'assets/profiles/$avatarFilename';
          }
        });
      }

      // Count followers
      final followersSnapshot = await userDoc.collection('followers').get();
      setState(() {
        _followerCount = followersSnapshot.docs.length;
      });

      // Count following
      final followingSnapshot = await userDoc.collection('following').get();
      setState(() {
        _followingCount = followingSnapshot.docs.length;
      });

      // Fetch user posts
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('forum')
          .where('uid', isEqualTo: currentUser.uid)
          .get();
      setState(() {
        _userPosts = postsSnapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadProfileData(),
      builder: (context, snapshot) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: AssetImage(_profileImage),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  _fullName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FollowingFollowersPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$_followingCount ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 16),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FollowingFollowersPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$_followerCount ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 16),
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
                  color: Colors.grey,
                  thickness: 1,
                ),
                SizedBox(height: 20),
                Text(
                  'Recent Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _userPosts.isEmpty
                    ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.post_add,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No recent posts',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: _userPosts
                      .map((post) => _buildPostCard(post))
                      .toList(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 3,
            onTap: (index) {
              if (index == 3) {
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
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
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
                  backgroundImage: AssetImage(_profileImage),
                ),
                SizedBox(width: 10),
                Text(
                  _fullName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              post['content'] ?? 'No content available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
