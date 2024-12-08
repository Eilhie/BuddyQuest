
import 'package:flutter/material.dart';

class AvatarSelectionPage extends StatelessWidget {
  final List<String> avatarImages = [
    'assets/profiles/boy_2945312.png',
    'assets/profiles/boy_2945483.png',
    'assets/profiles/boy_2945493.png',
    'assets/profiles/boy_2945506.png',
    'assets/profiles/boy_2945508.png',
    'assets/profiles/boy_9240480.png',
    'assets/profiles/cowgirl_9240504.png',
    'assets/profiles/girl_2945402.png',
    'assets/profiles/girl_2945416.png',
    'assets/profiles/girl_2945473.png',
    'assets/profiles/girl_2945476.png',
    'assets/profiles/girl_2945504.png',
    'assets/profiles/girl_2945516.png',
    'assets/profiles/man_9240527.png',
    'assets/profiles/queen_9240477.png',
    'assets/profiles/student_8245264.png',
    'assets/profiles/student_8245299.png',
    'assets/profiles/student_8245381.png',
    'assets/profiles/student_8245427.png',
    'assets/profiles/woman_9240481.png',
    'assets/profiles/woman_9240535.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom header
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Navigate back when pressing the back arrow
                },
              ),
              Text(
                'Select Avatar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // Navigate to Settings Page or Open Settings (if needed)
                },
              ),
            ],
          ),
          SizedBox(height: 16), // Add some space after the row

          // Avatar Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 avatars per row
                  crossAxisSpacing: 16.0, // Spacing between avatars
                  mainAxisSpacing: 16.0, // Vertical spacing between avatars
                  childAspectRatio: 1, // Aspect ratio for circle avatars
                ),
                itemCount: avatarImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _showConfirmationDialog(context, avatarImages[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(avatarImages[index]),
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String selectedAvatar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Avatar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(selectedAvatar),
              ),
              SizedBox(height: 16),
              Text('Do you want to set this as your profile picture?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate back to Profile Page and pass the selected avatar
                Navigator.pop(context); // Close the confirmation dialog
                Navigator.pop(context, selectedAvatar); // Navigate back with the selected avatar
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without selecting
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
