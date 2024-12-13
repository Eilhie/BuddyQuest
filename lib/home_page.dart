import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forum_page.dart';
import 'reply_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userFirstName = "Guest"; // Default value
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<DocumentSnapshot> _latestPosts = [];
  final Set<String> likedPosts = {}; // Track liked posts
  String? currentUserId; // Track the logged-in user's ID
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadUserFirstName();
    _fetchCurrentUserId();
    _fetchLatestPosts();
  }

  // Fetch the current user's first name
  Future<void> _loadUserFirstName() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          String fullname = userDoc['fullname'] ?? 'Guest';
          setState(() {
            _userFirstName = fullname.split(' ').first;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _userFirstName = "Guest";
      });
    }
  }

  // Fetch the current user's ID
  Future<void> _fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  // Fetch the latest forum posts
  Future<void> _fetchLatestPosts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('forum')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      for (final post in querySnapshot.docs) {
        await _loadLikeState(post.id);
      }

      setState(() {
        _latestPosts.addAll(querySnapshot.docs);
        _isLoadingPosts = false;
      });
    } catch (e) {
      print("Error fetching latest posts: $e");
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  // Toggle like or unlike for a post
  Future<void> _toggleLike(String postId) async {
    try {
      if (currentUserId == null) return;

      final postRef = FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('post_likes')
          .doc(currentUserId);

      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final postDoc = FirebaseFirestore.instance.collection('forum').doc(postId);
          final freshPostSnapshot = await transaction.get(postDoc);

          if (!freshPostSnapshot.exists) return;

          final currentLikes = freshPostSnapshot['likes'] ?? 0;
          transaction.update(postDoc, {'likes': currentLikes - 1});
          transaction.delete(postRef);
        });

        setState(() {
          likedPosts.remove(postId);
        });
      } else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final postDoc = FirebaseFirestore.instance.collection('forum').doc(postId);
          final freshPostSnapshot = await transaction.get(postDoc);

          if (!freshPostSnapshot.exists) return;

          final currentLikes = freshPostSnapshot['likes'] ?? 0;
          transaction.update(postDoc, {'likes': currentLikes + 1});
          transaction.set(postRef, {'uid': currentUserId});
        });

        setState(() {
          likedPosts.add(postId);
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  // Load the like state for a specific post
  Future<void> _loadLikeState(String postId) async {
    try {
      if (currentUserId == null) return;

      final postLikeRef = FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('post_likes')
          .doc(currentUserId);

      final postLikeSnapshot = await postLikeRef.get();
      if (postLikeSnapshot.exists) {
        setState(() {
          likedPosts.add(postId);
        });
      }
    } catch (e) {
      print("Error loading like state: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "EVERY DAY WE MUSCLE'N",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Hey, $_userFirstName",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Today's Plan",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Streaks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text('4/7 days'),
                ],
              ),
              StreakChart(completedDays: 4),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Points",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text('270 points'),
                ],
              ),
              PointsChart(points: [100, 50, 30, 90, 0, 0, 0]),
              const SizedBox(height: 30),
              const Text(
                "Latest Forum",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingPosts
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                children: _latestPosts.map((postDoc) {
                  final post = postDoc.data() as Map<String, dynamic>;
                  return _buildForumCard(
                    postDoc.id,
                    post['fullname'] ?? 'Unknown',
                    post['content'] ?? '',
                    post['likes'] ?? 0,
                    post['timestamp'] as Timestamp?,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForumPage()),
                  );
                },
                child: const Text(
                  "See More",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildForumCard(String postId, String userName, String postContent, int likes, Timestamp? timestamp) {
    String formattedTime = "Unknown Time";
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      formattedTime =
      "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            postContent,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () => _toggleLike(postId),
                icon: Icon(
                  Icons.thumb_up,
                  color: likedPosts.contains(postId) ? Colors.blue : Colors.grey,
                ),
              ),
              Text('$likes Likes'),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReplyPage(postId: postId),
                    ),
                  );
                },
                icon: const Icon(Icons.reply, color: Colors.grey),
                label: const Text('Reply', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Streak Chart Widget (UI Only)
class StreakChart extends StatelessWidget {
  final int completedDays; // Number of completed streak days out of 7
  final List<String> weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  StreakChart({required this.completedDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        bool isCompleted = index < completedDays;
        return Column(
          children: [
            Container(
              height: 60,
              width: 45,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.black : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weekDays[index],
              style: TextStyle(
                color: isCompleted ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class PointsChart extends StatelessWidget {
  final List<int> points; // List containing the points for each day
  final List<String> weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  PointsChart({required this.points});

  @override
  Widget build(BuildContext context) {
    int maxHeight = points.isNotEmpty ? points.reduce((a, b) => a > b ? a : b) : 0; // Get the max height for normalization

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        int dayPoints = points[index];

        // Calculate the normalized height based on the max height
        double normalizedHeight = (dayPoints / maxHeight) * 100; // Adjust as needed

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Stack to ensure all bars start from the same ground
            Container(
              height: 100, // Maximum height for the chart
              width: 45,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  // Bar
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: normalizedHeight, // Bar height based on points
                      width: 45,
                      decoration: BoxDecoration(
                        color: dayPoints > 0 ? Colors.black : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weekDays[index],
              style: TextStyle(
                color: dayPoints > 0 ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}
