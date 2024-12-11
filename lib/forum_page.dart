import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'reply_page.dart';
import 'setting_page.dart';

class ForumPage extends StatefulWidget {
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _postController = TextEditingController();

  String? currentUserName;

  // Track liked posts locally
  Set<String> likedPosts = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserName();
  }

  Future<void> _fetchCurrentUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        setState(() {
          currentUserName = doc['fullname'];
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> _addPostToFirestore(String postContent) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && currentUserName != null) {
        await FirebaseFirestore.instance.collection('forum').add({
          'content': postContent,
          'fullname': currentUserName,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 0, // Default value for likes
          'uid': user.uid,
        });
      }
    } catch (e) {
      print("Error adding post to Firestore: $e");
    }
  }

  Future<void> _toggleLike(DocumentSnapshot post) async {
    try {
      final postId = post.id;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Ensure user is authenticated.

      // Toggle like/unlike
      if (likedPosts.contains(postId)) {
        // Unlike the post
        await post.reference.update({'likes': post['likes'] - 1});
        setState(() {
          likedPosts.remove(postId);
        });
      } else {
        // Like the post
        await post.reference.update({'likes': post['likes'] + 1});
        setState(() {
          likedPosts.add(postId);
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  void _replyToPost(String postId) {
    // Implement reply functionality by navigating to the ReplyPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyPage(postId: postId), // Navigate to the ReplyPage
      ),
    );
  }

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
                const Text(
                  'Forum',
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
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _handlePostAction(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                    ),
                    child: const Text("Post"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('forum')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;
                      final postId = posts[index].id;
                      return Column(
                        children: [
                          _buildForumCard(
                            postId,
                            post['fullname'] ?? 'Unknown',
                            post['content'] ?? '',
                            post['likes'] ?? 0,
                            post['timestamp'] as Timestamp?,
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
              SizedBox(width: 10),
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
              IconButton(
                onPressed: () {
                  // Follow user action
                  print("Follow user: $userName");
                },
                icon: const Icon(Icons.person_add),
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
                onPressed: () async {
                  final docSnapshot = await FirebaseFirestore.instance.collection('forum').doc(postId).get();
                  _toggleLike(docSnapshot);
                },
                icon: Icon(
                  Icons.thumb_up,
                  color: likedPosts.contains(postId) ? Colors.blue : Colors.grey,
                ),
              ),
              Text('$likes Likes  '),
              TextButton.icon(
                onPressed: () => _replyToPost(postId),
                icon: const Icon(Icons.reply, color: Colors.grey), // Icon
                label: const Text('Reply', style: TextStyle(color: Colors.grey)), // Text
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePostAction(BuildContext context) {
    String postContent = _postController.text.trim();

    if (postContent.isEmpty) {
      _showErrorDialog(context);
    } else {
      _addPostToFirestore(postContent);
      _postController.clear();
      _showPostSuccessDialog(context);
    }
  }

  void _showPostSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Post Successful"),
          content: const Text("Your post has been successfully submitted!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, {String message = "Please enter some text before posting."}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
