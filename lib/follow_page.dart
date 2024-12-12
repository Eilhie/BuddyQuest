import 'package:flutter/material.dart';
import 'setting_page.dart'; // Ensure you have this page implemented

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

class FollowingFollowersPage extends StatelessWidget {
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
              child: TabBarView(
                children: [
                  // Tab content for "Following"
                  ListView.builder(
                    itemCount: 20, // Replace with your following count
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('F$index'), // Example avatar
                        ),
                        title: Text('Following User $index'),
                      );
                    },
                  ),
                  // Tab content for "Followers"
                  ListView.builder(
                    itemCount: 15, // Replace with your followers count
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('R$index'), // Example avatar
                        ),
                        title: Text('Follower User $index'),
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
