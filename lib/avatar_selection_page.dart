import 'package:flutter/material.dart';

class AvatarSelectionPage extends StatelessWidget {
  final List<String> avatarImages = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatar5.png',
    'assets/avatar6.png',
    'assets/avatar7.png',
    'assets/avatar8.png',
    'assets/avatar9.png',
    'assets/avatar10.png',
    'assets/avatar11.png',
    'assets/avatar12.png',
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