
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AvatarSelectionPage extends StatelessWidget {
  final List<String> avatarImages = [

    'assets/profiles/boy-default.png',
    'assets/profiles/boy-2.png',
    'assets/profiles/boy-3.png',
    'assets/profiles/boy-4.png',
    'assets/profiles/boy-5.png',
    'assets/profiles/boy-6.png',
    'assets/profiles/boy-7.png',
    'assets/profiles/boy-8.png',
    'assets/profiles/boy-9.png',
    'assets/profiles/boy-10.png',
    'assets/profiles/girl-default.png',
    'assets/profiles/girl-2.png',
    'assets/profiles/girl-3.png',
    'assets/profiles/girl-4.png',
    'assets/profiles/girl-5.png',
    'assets/profiles/girl-6.png',
    'assets/profiles/girl-7.png',
    'assets/profiles/girl-8.png',
    'assets/profiles/girl-9.png',
    'assets/profiles/girl-10.png'
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
              onPressed: () async {
                try {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    String uid = currentUser.uid;

                    // Extract the filename from the selectedAvatar string
                    String avatarFilename = selectedAvatar.split('/').last;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({'avatar': avatarFilename});

                    // Navigate back to Profile Page and pass the selected avatar
                    Navigator.pop(context); // Close the confirmation dialog
                    Navigator.pop(context, avatarFilename); // Navigate back with the avatar filename

                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Avatar updated successfully!'),
                      ),
                    );
                  }
                } catch (error) {
                  // Handle errors, e.g., display an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating avatar: $error'),
                    ),
                  );
                }
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
