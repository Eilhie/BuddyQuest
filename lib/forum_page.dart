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
  final List<DocumentSnapshot> _posts = [];
  final int _postLimit = 10; // Number of posts per page
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? currentUserName;
  String? currentUserId;
  Set<String> likedPosts = {};
  Set<String> followingUsers = {};
  Query _postQuery = FirebaseFirestore.instance
      .collection('forum')
      .orderBy('timestamp', descending: true);

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails();
    _loadPosts();
    _loadFollowingUsers();
  }

  Future<void> _fetchCurrentUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          currentUserName = doc['fullname'];
          currentUserId = user.uid;
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _loadFollowingUsers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final followingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .get();

      setState(() {
        followingUsers = followingSnapshot.docs.map((doc) => doc.id).toSet();
      });
    } catch (e) {
      print("Error loading following users: $e");
    }
  }

  Future<void> _toggleFollow(String userId, String userName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || userId == user.uid) return; // Prevent self-follow

      final followingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(userId);

      final followersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('followers')
          .doc(user.uid);

      if (followingUsers.contains(userId)) {
        // Unfollow
        await followingRef.delete();
        await followersRef.delete();
        setState(() {
          followingUsers.remove(userId);
        });

        // Show Snackbar for unfollowing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You unfollowed $userName."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Follow
        await followingRef.set({'uid': userId});
        await followersRef.set({'uid': user.uid});
        setState(() {
          followingUsers.add(userId);
        });

        // Show Snackbar for following
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You are now following $userName."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error toggling follow: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleLike(String postId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Ensure the user is logged in

      final postRef = FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('post_likes')
          .doc(user.uid);

      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        // Unlike
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final postDoc = FirebaseFirestore.instance.collection('forum').doc(postId);
          final postSnapshot = await transaction.get(postDoc);

          if (!postSnapshot.exists) return;

          final currentLikes = postSnapshot['likes'] ?? 0;
          transaction.update(postDoc, {'likes': currentLikes - 1});
          transaction.delete(postRef);
        });

        setState(() {
          likedPosts.remove(postId);
        });
      } else {
        // Like
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final postDoc = FirebaseFirestore.instance.collection('forum').doc(postId);
          final postSnapshot = await transaction.get(postDoc);

          if (!postSnapshot.exists) return;

          final currentLikes = postSnapshot['likes'] ?? 0;
          transaction.update(postDoc, {'likes': currentLikes + 1});
          transaction.set(postRef, {'uid': user.uid});
        });

        setState(() {
          likedPosts.add(postId);
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> _loadLikeState(String postId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final postLikeRef = FirebaseFirestore.instance
          .collection('forum')
          .doc(postId)
          .collection('post_likes')
          .doc(user.uid);

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

  Future<void> _loadPosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Query query = _posts.isEmpty
          ? _postQuery.limit(_postLimit)
          : _postQuery.startAfterDocument(_posts.last).limit(_postLimit);

      final querySnapshot = await query.get();
      final newPosts = querySnapshot.docs;

      for (final post in newPosts) {
        await _loadLikeState(post.id);
      }

      setState(() {
        _posts.addAll(newPosts);
        _hasMore = newPosts.length == _postLimit;
      });
    } catch (e) {
      print("Error loading posts: $e");
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
            const SizedBox(height: 8,),
            _buildPostInputField(),
            const SizedBox(height: 16),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                      !_isLoadingMore) {
                    _loadPosts();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: _posts.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final post = _posts[index].data() as Map<String, dynamic>;
                    final postId = _posts[index].id;
                    return Column(
                      children: [
                        _buildForumCard(
                          postId,
                          post['fullname'] ?? 'Unknown',
                          post['content'] ?? '',
                          post['likes'] ?? 0,
                          post['timestamp'] as Timestamp?,
                          post['uid'] ?? '',
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostInputField() {
    return Container(
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
    );
  }

  Widget _buildForumCard(String postId, String userName, String postContent,
      int likes, Timestamp? timestamp, String userId) {
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
                onPressed: () => _toggleFollow(userId, userName),
                icon: Icon(
                  followingUsers.contains(userId)
                      ? Icons.person_remove
                      : Icons.person_add,
                  color: followingUsers.contains(userId)
                      ? Colors.red
                      : Colors.blue,
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
              TextButton.icon(
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Report Post'),
                        content: const Text('Are you sure you want to report this post?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog

                              // Show "Report Submitted" snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Report Submitted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // Add additional logic for reporting the post here (e.g., API call)
                            },
                            child: const Text('Report'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.reply, color: Colors.red),
                label: const Text('Report', style: TextStyle(color: Colors.red)),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addPostToFirestore(String postContent) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && currentUserName != null) {
        await FirebaseFirestore.instance.collection('forum').add({
          'content': postContent,
          'fullname': currentUserName,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 0,
          'uid': user.uid,
        });
      }
    } catch (e) {
      print("Error adding post to Firestore: $e");
    }
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

  void _showErrorDialog(BuildContext context,
      {String message = "Please enter some text before posting."}) {
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
