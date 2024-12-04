import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle Post Action
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
                itemCount: 10, // Example: 10 posts
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildForumCard(),
                      SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Forum Card Widget
  Widget _buildForumCard() {
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
                    "6h ago",
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
            "Why am I not gaining more muscle although I eat and exercise a lot? :(",
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
}
