import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setting_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FollowingFollowersPage(),
    );
  }
}

class FollowingFollowersPage extends StatefulWidget {
  @override
  _FollowingFollowersPageState createState() => _FollowingFollowersPageState();
}

class _FollowingFollowersPageState extends State<FollowingFollowersPage> {
  List<Map<String, String>> _following = [];
  List<Map<String, String>> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Fetch following and followers
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final followingSnapshot = await userDoc.collection('following').get();
      final followersSnapshot = await userDoc.collection('followers').get();

      // Helper function to fetch user details
      Future<Map<String, String>> fetchUserDetails(String uid) async {
        final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = userSnapshot.data();
        if (data != null) {
          return {
            'fullname': data['fullname'] ?? 'Unknown User',
            'avatar': data['avatar'] ?? 'default.png',
          };
        }
        return {'fullname': 'Unknown User', 'avatar': 'default.png'};
      }

      // Fetch details for each UID
      final following = await Future.wait(followingSnapshot.docs.map((doc) => fetchUserDetails(doc.id)));
      final followers = await Future.wait(followersSnapshot.docs.map((doc) => fetchUserDetails(doc.id)));

      setState(() {
        _following = following;
        _followers = followers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            // Custom AppBar
            SizedBox(height: 40), // Add spacing at the top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  'Following & Followers',
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
            // TabBar
            TabBar(
              tabs: [
                Tab(text: 'Following'),
                Tab(text: 'Followers'),
              ],
            ),
            Expanded(
              // TabBarView content
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TabBarView(
                children: [
                  // Tab content for "Following"
                  ListView.builder(
                    itemCount: _following.length,
                    itemBuilder: (context, index) {
                      final user = _following[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/profiles/${user['avatar']}'),
                        ),
                        title: Text(user['fullname']!),
                      );
                    },
                  ),
                  // Tab content for "Followers"
                  ListView.builder(
                    itemCount: _followers.length,
                    itemBuilder: (context, index) {
                      final user = _followers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/profiles/${user['avatar']}'),
                        ),
                        title: Text(user['fullname']!),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
