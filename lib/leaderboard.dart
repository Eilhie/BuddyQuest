
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setting_page.dart';

class LeaderboardPage extends StatelessWidget {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'Leaderboard',
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
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: _getLeaderboardData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading leaderboard.'));
                  }

                  final data = snapshot.data as Map<String, dynamic>;
                  final leaderboard = data['leaderboard'] as List<Map<String, dynamic>>;
                  final currentUser = data['currentUser'] as Map<String, dynamic>;

                  return Column(
                    children: [
                      // Top 3 Users Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (leaderboard.length > 1) _buildTopUserCard(leaderboard[1], size: 80, rank: 2),
                          if (leaderboard.isNotEmpty) _buildTopUserCard(leaderboard[0], size: 100, isHighlighted: true, rank: 1),
                          if (leaderboard.length > 2) _buildTopUserCard(leaderboard[2], size: 80, rank: 3),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Display remaining leaderboard
                      Expanded(
                        child: ListView.builder(
                          itemCount: leaderboard.length - 3,
                          itemBuilder: (context, index) {
                            final player = leaderboard[index + 3];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage('assets/profiles/${player['avatar']}'),
                                  backgroundColor: Colors.deepPurple[100],
                                ),
                                title: Text(
                                  player['fullname'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '#${player['rank']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Text(
                                  '${player['points']} pts',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Current user position
                      if (currentUser.isNotEmpty)
                        Card(
                          color: Colors.amber[50],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/profiles/${currentUser['avatar']}'),
                              backgroundColor: Colors.deepPurple[100],
                            ),
                            title: Text(
                              '${currentUser['fullname']} (You)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              '#${currentUser['rank']} - ${currentUser['points']} pts',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Home
          } else if (index == 1) {
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/leaderboard');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
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

  Future<Map<String, dynamic>> _getLeaderboardData() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is logged in.');
    }

    final snapshot = await firestore.collection('users').get();
    final users = snapshot.docs.map((doc) => doc.data()).toList();

    // Sort users by points descending
    users.sort((a, b) => b['points'].compareTo(a['points']));

    // Assign ranks to all users
    for (int i = 0; i < users.length; i++) {
      users[i]['rank'] = i + 1;
    }

    // Identify the current user's rank
    Map<String, dynamic> currentUserData = {};
    for (int i = 0; i < users.length; i++) {
      if (users[i]['uid'] == currentUser.uid) {
        currentUserData = {
          ...users[i],
          'rank': i + 1,
        };
        break;
      }
    }

    // Prepare leaderboard and include only the top 10
    final leaderboard = users.take(10).toList();

    return {
      'leaderboard': leaderboard,
      'currentUser': currentUserData,
    };
  }

  Widget _buildTopUserCard(
      Map<String, dynamic> player, {
        required double size,
        bool isHighlighted = false, required int rank,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/additional/crown.png',
          height: 24, // Adjust size of crown
          color: rank == 1
              ? Colors.amber // Gold tint for 1st place
              : rank == 2
              ? Colors.grey // Silver tint for 2nd place
              : Colors.brown, // Bronze tint for 3rd place
        ),
        CircleAvatar(
          radius: size / 2,
          backgroundImage: AssetImage('assets/profiles/${player['avatar']}'),
          backgroundColor: isHighlighted ? Colors.amber : Colors.deepPurple[100],
        ),
        SizedBox(height: 8),
        Text(
          player['fullname'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlighted ? 18 : 16,
          ),
        ),
        Text(
          '${player['points']} pts',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isHighlighted ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
