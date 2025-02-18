import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forum_page.dart';
import 'reply_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_engineering_project/services/workout_plan_service.dart';
import 'services/user_sevice.dart';
import 'package:intl/intl.dart';
import 'workout_plan.dart';


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

  WorkoutPlanService workoutPlanService = WorkoutPlanService();
  UserService userService = UserService();
  User? currentUser;
  String? currUid;

  final List<String> listOfDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final Map<String, List<String>> dailyExercises = {
    "Monday": ["Push-ups", "Squats", "Plank"],
    "Tuesday": ["Burpees", "Jumping Jacks", "Mountain Climbers"],
    "Wednesday": ["Lunges", "Deadlifts", "Crunches"],
    "Thursday": ["Pull-ups", "Bench Press", "Tricep Dips"],
    "Friday": ["Bicep Curls", "Leg Raises", "Russian Twists"],
    "Saturday": ["Yoga Stretches", "Pilates Core", "Foam Rolling"],
    "Sunday": ["Rest", "Light Walk", "Stretching"],
  };

  String selectedDay = DateFormat('EEEE').format(DateTime.now()); // Select day of week now

  @override
  void initState() {
    super.initState();
    _loadUserFirstName();
    _fetchCurrentUserId();
    _fetchLatestPosts();

    currentUser = FirebaseAuth.instance.currentUser;
    currUid = currentUser?.uid??"";

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

              // Today's plan from rici api
              Container(
                child: FutureBuilder(
                  future: userService.getUserWorkoutCategory(currUid ?? ""),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return FutureBuilder(
                      future: Future.wait([
                        workoutPlanService.getExcerciseByCategoryDay(
                          snapshot.data ?? "",
                          listOfDays.indexWhere((dow) => dow == selectedDay),
                        ),
                        workoutPlanService.getUserProgressByDay(
                          currUid,
                          listOfDays.indexWhere((dow) => dow == selectedDay),
                        )
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          if (snapshot.data?[0] == null) {
                            return Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.beach_access, // Icon representing rest
                                    size: 60,
                                    color: Colors.deepPurple,
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rest Day",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "\"Take time to relax. Recovery is important.\"",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          Map<String, dynamic>? exercisesOfDay = snapshot.data?[0] as Map<String, dynamic>;
                          List<String> doneExercisesOfDay = snapshot.data?[1] as List<String>;

                          return ListView.builder(
                            shrinkWrap: true, // Ensures the ListView's height is determined by its content
                            physics: NeverScrollableScrollPhysics(), // Prevents scrolling inside the ListView
                            itemCount: exercisesOfDay["exercises"].length ?? 0,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> currIndexExercise = exercisesOfDay["exercises"][index];
                              String? exerciseDetails = currIndexExercise.containsKey("details") ? currIndexExercise["details"] : null;
                              int? exerciseSets = currIndexExercise.containsKey("sets") ? currIndexExercise["sets"] : null;
                              int? exerciseReps = currIndexExercise.containsKey("reps") ? currIndexExercise["reps"] : null;
                              String? exerciseDuration = currIndexExercise.containsKey("duration") ? currIndexExercise["duration"] : null;

                              String exerciseDetailsText = exerciseDetails != null
                                  ? exerciseDetails
                                  : (exerciseDuration != null
                                  ? "Duration: $exerciseDuration"
                                  : (exerciseReps == null ? "" : "$exerciseSets sets, $exerciseReps reps each"));

                              var currIsBlacked = doneExercisesOfDay.contains(currIndexExercise["name"]);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkoutPlanPage(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  color: currIsBlacked ? Colors.green.withOpacity(0.5) : null,
                                  child: ListTile(
                                    leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                                    title: Text(
                                      currIndexExercise["name"],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(exerciseDetailsText),
                                    trailing: Icon(Icons.info, color: Colors.deepPurple),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                ),
                width: MediaQuery.of(context).size.width,
              ),




              const SizedBox(height: 30),
              Row(
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
                  FutureBuilder(
                      future: workoutPlanService.getDidWorkoutList(currUid??""),
                      builder: (context, snapshot)
                      {
                        if(snapshot.connectionState == ConnectionState.waiting)
                        {
                          return Center(child:CircularProgressIndicator());
                        }
                        List<bool> didWorkoutList = snapshot.data!;
                        var didCount = 0;
                        for(bool didWorkout in didWorkoutList)
                        {
                          didCount += didWorkout?1:0;
                        }
                        return Text("Total Streaks $didCount Days");
                      })
                ],
              ),
              StreakChart(),


              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Points",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  FutureBuilder(
                      future: userService.getUserPoint(currUid??""),
                      builder: (context, snapshot)
                      {
                        if(snapshot.connectionState == ConnectionState.waiting)
                        {
                          return Center(child:CircularProgressIndicator());
                        }
                        int currPoints =  snapshot.data??0;
                        return Text("$currPoints points");
                      }
                  ),

                ],
              ),
              PointsChart(),


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
                  return Column(
                    children: [
                      FutureBuilder(
                          future: userService.getUserProfilePicture(post['uid']),
                          builder: (context, snapshot)
                          {
                            if(snapshot.connectionState == ConnectionState.waiting)
                            {
                              return Center(child:CircularProgressIndicator());
                            }
                            return _buildForumCard(postDoc.id,
                              post['fullname'] ?? 'Unknown',
                              post['content'] ?? '',
                              post['likes'] ?? 0,
                              post['timestamp'] as Timestamp?,
                              snapshot.data!
                            );
                          }
                      ),
                      const SizedBox(height: 20), // Add space after each forum card
                    ],
                  );
                }).toList(),
              ),

              Center(
                child: TextButton(
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

  Widget _buildForumCard(String postId, String userName, String postContent, int likes, Timestamp? timestamp, String profileImage) {
    String formattedTime = "Unknown Time";
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      formattedTime =
      "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    UserService userService = UserService();
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
                  backgroundImage: AssetImage(profilePath)
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


}

// Streak Chart Widget (UI Only)
class StreakChart extends StatelessWidget {
  List<bool> completedDays = []; // Number of completed streak days out of 7
  final List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final workoutService = WorkoutPlanService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var currUid = currentUser?.uid??"";
    return FutureBuilder(
        future: workoutService.getDidWorkoutList(currUid),
        builder: (context, snapshot)
        {
          if(snapshot.connectionState == ConnectionState.waiting)
          {
            Center(child: CircularProgressIndicator());
          }
          completedDays = (snapshot.data??[false,false,false,false,false,false,false]) as List<bool>;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool isCompleted = completedDays[index];
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
        });
  }
}

class PointsChart extends StatelessWidget {
  List<int> points = []; // List containing the points for each day
  final List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final workoutPlanService = WorkoutPlanService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var currUid = currentUser?.uid ?? "";

    return FutureBuilder(
      future: workoutPlanService.getPointsList(currUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        points = (snapshot.data ?? [0, 0, 0, 0, 0, 0, 0]) as List<int>;
        int maxHeight = points.isNotEmpty ? points.reduce((a, b) => a > b ? a : b) : 0; // Get the max height for normalization
        int todayIndex = DateTime.now().weekday - 1; // Monday is 0
        int yesterdayIndex = (todayIndex - 1 + 7) % 7; // Wrap around to handle Sundays
        int todayPoints = points[todayIndex];
        int yesterdayPoints = points[yesterdayIndex];

        // Calculate percentage change from yesterday
        double percentageChange = yesterdayPoints == 0
            ? (todayPoints > 0 ? 100 : 0) // Handle division by zero
            : ((todayPoints - yesterdayPoints) / yesterdayPoints) * 100;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bar chart row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                int dayPoints = points[index];
                double normalizedHeight = maxHeight == 0 ? 0 : (dayPoints / maxHeight) * 100;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bar container
                    Container(
                      height: 100, // Maximum height for the chart
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        children: [
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
                    Text(
                      '$dayPoints p',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            // Percentage change text
            Text(
              "Change from yesterday: ${percentageChange.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: percentageChange >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}


