import 'package:flutter/material.dart';
import 'setting_page.dart';

class LeaderboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData = [
    {'rank': 1, 'name': 'Alice', 'score': 1500, 'image': 'assets/user1.png'},
    {'rank': 2, 'name': 'Bob', 'score': 1300, 'image': 'assets/user2.png'},
    {'rank': 3, 'name': 'Charlie', 'score': 1200, 'image': 'assets/user3.png'},
    {'rank': 4, 'name': 'Diana', 'score': 1100, 'image': 'assets/user4.png'},
    {'rank': 5, 'name': 'Eve', 'score': 1000, 'image': 'assets/user5.png'},
    {'rank': 6, 'name': 'Eve', 'score': 1000, 'image': 'assets/user5.png'},
    {'rank': 7, 'name': 'Eve', 'score': 1000, 'image': 'assets/user5.png'},
    {'rank': 8, 'name': 'Eve', 'score': 1000, 'image': 'assets/user5.png'},
    {'rank': 9, 'name': 'Eve', 'score': 1000, 'image': 'assets/user5.png'},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                Text('Leaderboard',
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
            SizedBox(height: 20),

            // Top 3 Users Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Second-place user
                _buildTopUserCard(leaderboardData[1], size: 80),
                // First-place user (highlighted)
                _buildTopUserCard(leaderboardData[0], size: 100, isHighlighted: true),
                // Third-place user
                _buildTopUserCard(leaderboardData[2], size: 80),
              ],
            ),

            SizedBox(height: 30),

            // Display remaining leaderboard in a ListView
            Expanded(
              child: ListView.builder(
                itemCount: leaderboardData.length - 3,
                itemBuilder: (context, index) {
                  final player = leaderboardData[index + 3];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(player['image']),
                        backgroundColor: Colors.deepPurple[100],
                      ),
                      title: Text(
                        player['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${player['score']} pts',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures all icons are always visible
        currentIndex: 2, // Set the default active item
        onTap: (index) {
          // Handle navigation based on the selected item
          if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          } else if (index == 1) {
            // Example for navigating to a "Workout" page
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {

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

  // Helper Method to Build Top User Cards
  Widget _buildTopUserCard(
      Map<String, dynamic> player, {
        required double size,
        bool isHighlighted = false,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundImage: AssetImage(player['image']),
          backgroundColor: isHighlighted ? Colors.amber : Colors.deepPurple[100],
        ),
        SizedBox(height: 8),
        Text(
          player['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlighted ? 18 : 16,
          ),
        ),
        Text(
          '${player['score']} pts',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isHighlighted ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
