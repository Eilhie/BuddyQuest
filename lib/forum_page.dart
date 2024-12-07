import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _postController = TextEditingController();
  List<String> posts = [
    "Why am I not gaining more muscle although I eat and exercise a lot? :(",
    "Anyone else experiencing low energy despite good sleep?",
    "Struggling to stay consistent with my workout routine, any tips?",
    "What exercises can I do at home to build strength?",
    "I feel like I'm not progressing in my workout, any advice?",
  ]; // Initialize with some sample posts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  'Forum',
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
            // Post Input Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _postController, // Set controller
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _handlePostAction(context);
                    },
                    child: Text("Post"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // List of Forum Posts
            Expanded(
              child: ListView.builder(
                itemCount: posts.length, // Dynamically update the number of posts
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildForumCard(posts[index]), // Pass the post content to the card
                      SizedBox(height: 8),
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
        onTap: (index) {
          // Handle navigation based on the selected item
          if (index == 3) {
            Navigator.pushNamed(context, '/leaderboard');
          } else if (index == 1) {
            // Example for navigating to a "Workout" page
            Navigator.pushNamed(context, '/workout');
          } else if (index == 2) {
            // Example for navigating to a "Leaderboard" page
            Navigator.pushNamed(context, '/leaderboard');
          } else if (index == 0) {
            // Example for navigating to a "Profile" page
            Navigator.pushNamed(context, '/home');
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
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

  // Forum Card Widget
  Widget _buildForumCard(String postContent) {
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
              CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cornel Karel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Just now",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  // Follow action
                },
                child: Text(
                  "Follow",
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            postContent,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionIcon(Icons.chat_bubble_outline, "10"),
                  SizedBox(width: 16),
                  _buildActionIcon(Icons.thumb_up_alt_outlined, "10"),
                  SizedBox(width: 16),
                  _buildActionIcon(Icons.thumb_down_alt_outlined, "10"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action Icon Widget
  Widget _buildActionIcon(IconData icon, String count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // Handle Post Action
  void _handlePostAction(BuildContext context) {
    String postContent = _postController.text.trim();

    if (postContent.isEmpty) {
      // Show validation error if post is empty
      _showErrorDialog(context);
    } else {
      setState(() {
        // Add the new post to the top of the list
        posts.insert(0, postContent);
      });

      // Show success dialog if post is valid
      _showPostSuccessDialog(context);
      _postController.clear(); // Clear the input after posting
    }
  }

  // Show Success Dialog
  void _showPostSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Post Successful"),
          content: Text("Your post has been successfully submitted!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Show Error Dialog for empty post
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Please enter some text before posting."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
