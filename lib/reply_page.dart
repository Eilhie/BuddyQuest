import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Import your actual user service (the same one used by the Forum page)
import 'package:software_engineering_project/services/user_sevice.dart';
import 'setting_page.dart';

class ReplyPage extends StatefulWidget {
  final String postId;

  const ReplyPage({Key? key, required this.postId}) : super(key: key);

  @override
  _ReplyPageState createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  final TextEditingController _replyController = TextEditingController();

  String userName = "";
  String postContent = "";
  Timestamp? postTimestamp;
  String _postUserId = ""; // We'll store the main post owner's UID here

  // Same user service you use in ForumPage
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchPostDetails();
  }

  Future<void> _fetchPostDetails() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        setState(() {
          userName = postDoc['fullname'] ?? "Unknown";
          postContent = postDoc['content'] ?? "";
          postTimestamp = postDoc['timestamp'];
          _postUserId = postDoc['uid'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching post details: $e");
    }
  }

  Future<void> _addReplyToFirestore(String replyContent) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final currentUserName = userDoc['fullname'];

        await FirebaseFirestore.instance
            .collection('forum')
            .doc(widget.postId)
            .collection('replies')
            .add({
          'uid': user.uid,
          'fullname': currentUserName,
          'content': replyContent,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _replyController.clear();
      }
    } catch (e) {
      print("Error adding reply to Firestore: $e");
    }
  }

  Stream<QuerySnapshot> _getRepliesStream() {
    return FirebaseFirestore.instance
        .collection('forum')
        .doc(widget.postId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown Time";
    final dateTime = timestamp.toDate();
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top row: back button, title, settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Reply',
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
            const SizedBox(height: 32),

            // MAIN POST display with a FutureBuilder (just like the Forum page)
            FutureBuilder<String?>(
              future: userService.getUserProfilePicture(_postUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // If userService returns null or there's an error, default to 'default_profile.png'
                final profileImage = snapshot.data ?? 'default_profile.png';
                final profilePath = "assets/profiles/$profileImage";

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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // EXACT same avatar style as in _buildForumCard
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            backgroundImage: AssetImage(profilePath),
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
                                  _formatTimestamp(postTimestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // TextField to write a reply
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  // You can keep it as a simple placeholder or do a FutureBuilder
                  // to show the current user's avatar. Up to you.
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final replyContent = _replyController.text.trim();
                      if (replyContent.isNotEmpty) {
                        _addReplyToFirestore(replyContent);
                      }
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

            // Replies list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getRepliesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final replies = snapshot.data!.docs;
                  if (replies.isEmpty) {
                    return const Center(child: Text("No replies yet."));
                  }

                  return ListView.builder(
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      final replyDoc = replies[index];
                      final replyData = replyDoc.data() as Map<String, dynamic>;
                      final replyUid = replyData['uid'] ?? '';
                      final replyName = replyData['fullname'] ?? 'Unknown User';
                      final replyContent = replyData['content'] ?? '';
                      final replyTimestamp = replyData['timestamp'] as Timestamp?;

                      return _buildReplyCard(
                        replyUid,
                        replyName,
                        replyContent,
                        replyTimestamp,
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

  // This is just like _buildForumCard, but for replies
  Widget _buildReplyCard(
      String replyUserId,
      String replyUserName,
      String replyContent,
      Timestamp? replyTimestamp,
      ) {
    return FutureBuilder<String?>(
      future: userService.getUserProfilePicture(replyUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final profileImage = snapshot.data ?? 'default_profile.png';
        final profilePath = "assets/profiles/$profileImage";

        return Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Same style as forum
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: AssetImage(profilePath),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replyUserName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatTimestamp(replyTimestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                replyContent,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}
