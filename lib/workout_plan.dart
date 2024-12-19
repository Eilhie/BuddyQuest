import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:software_engineering_project/services/workout_plan_service.dart';
import 'services/user_sevice.dart';
import 'setting_page.dart';
import 'package:intl/intl.dart';

class WorkoutPlanPage extends StatefulWidget {
  @override
  _WorkoutPlanPageState createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  WorkoutPlanService workoutPlanService = WorkoutPlanService();
  UserService userService = UserService();

  String selectedDay = DateFormat('EEEE').format(DateTime.now()); // Select day of week now
  Map<String, bool> blackedOutExercises = {}; // To track blacked-out state for each exercise
  // Map of exercises for each day
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

  // Define a mapping of workouts to GIFs
  final Map<String, String> workoutGifs = {
    'Push Up': 'assets/workoutAsset/GIF_Push_Up.gif',
    'Squat': 'assets/workoutAsset/GIF_Squat.gif',
    'Plank': 'assets/workoutAsset/GIF_Plank.gif',
    'Walk': 'assets/workoutAsset/GIF_Walk.gif',
    'Back Up': 'assets/workoutAsset/GIF_Back_Up.gif',
    'Stretching Dinamis dan Statis': 'assets/workoutAsset/GIF_Stretching.gif',
    'Yoga Dasar': 'assets/workoutAsset/GIF_Yoga.gif',
    'Bench Press': 'assets/workoutAsset/GIF_Bench_Press.gif',
    'Incline Bench Press': 'assets/workoutAsset/GIF_Incline_Bench_Press.gif',
    'Cable Crossover': 'assets/workoutAsset/GIF_Cable_Crossover.gif',
    'Pull Up': 'assets/workoutAsset/GIF_Pull_Up.gif',
    'Dumbbell Row': 'assets/workoutAsset/GIF_Dumbbell_Row.gif',
    'Leg Extension': 'assets/workoutAsset/GIF_Leg_Extension.gif',
    'Leg Curl': 'assets/workoutAsset/GIF_Leg_Curl.gif',
    'Lateral Raise': 'assets/workoutAsset/GIF_Lateral_Raise.gif',
    'Bicep Curl': 'assets/workoutAsset/GIF_Bicep_Curl.gif',
    'Tricep Extension': 'assets/workoutAsset/GIF_Tricep_Extension.gif',
    'Dead Lift': 'assets/workoutAsset/GIF_Dead_Lift.gif',
    'Reverse Dumbbell Flyes': 'assets/workoutAsset/GIF_Reverse_Dumbbell_Flyes.gif',
    'Kardio': 'assets/workoutAsset/GIF_Walk.gif',
    'Dumbbell_Chest_Flyes': 'assets/workoutAsset/GIF_Dumbbell_Chest_Flyes.gif'
    // Add more workouts and their respective GIFs here
  };

  int _currentIndex = 0; // To track the selected tab

  User? currentUser;
  String? currUid;
  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    currUid = currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: workoutPlanService.checkUpdateUserProgress(currUid),
      builder: (context, snapshot) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Workout Plan',
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
                SizedBox(height: 20),
                Text(
                  "Select Day",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Days Selector (Scrollable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: dailyExercises.keys.map((day) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = day;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedDay == day ? Colors.deepPurple : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              color: selectedDay == day ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),

                // Exercise List
                Text(
                  "$selectedDay's Exercises",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
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
                              listOfDays.indexWhere((dow) => dow == selectedDay)),
                          workoutPlanService.getUserProgressByDay(currUid, listOfDays.indexWhere((dow) => dow == selectedDay))
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if (snapshot.data?[0] == null) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.beach_access,
                                      size: 100,
                                      color: Colors.deepPurple,
                                    ),
                                    SizedBox(height: 20),
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
                                      "\"Take time to relax. Recovery is just as important as the workout itself.\"",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            Map<String, dynamic>? exercisesOfDay = snapshot.data?[0] as Map<String, dynamic>;
                            List<String> doneExercisesOfDay = snapshot.data?[1] as List<String>;
                            return ListView.builder(
                              itemCount: exercisesOfDay["exercises"].length ?? 0,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> currIndexExercise = exercisesOfDay["exercises"][index];
                                String? exerciseDetails = currIndexExercise.containsKey("details")
                                    ? currIndexExercise["details"]
                                    : null;
                                int? exerciseSets = currIndexExercise.containsKey("sets") ? currIndexExercise["sets"] : null;
                                int? exerciseReps = currIndexExercise.containsKey("reps") ? currIndexExercise["reps"] : null;
                                String? exerciseDuration = currIndexExercise.containsKey("duration")
                                    ? currIndexExercise["duration"]
                                    : null;
                                String exerciseDetailsText = exerciseDetails != null
                                    ? exerciseDetails
                                    : (exerciseDuration != null
                                    ? "Duration : $exerciseDuration"
                                    : (exerciseReps == null ? "" : "$exerciseSets sets, $exerciseReps reps each"));
                                var currIsBlacked = doneExercisesOfDay.contains(currIndexExercise["name"]);
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8, // Increased shadow for more emphasis
                                  color: currIsBlacked ? Colors.green.withOpacity(0.5) : Colors.white,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding inside the card
                                    leading: Icon(
                                      Icons.fitness_center, // Icon on the left
                                      color: Colors.deepPurple,
                                    ),
                                    title: Text(
                                      currIndexExercise["name"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    subtitle: Text(
                                      exerciseDetailsText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.info_outline, // Info icon on the right
                                        color: Colors.deepPurple,
                                      ),
                                      onPressed: () {
                                        // Show exercise details when info icon is tapped
                                        if (!currIsBlacked) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  currIndexExercise["name"],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.deepPurple,
                                                  ),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Timer Row with Icon
                                                      Card(
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.timer, color: Colors.deepPurple),
                                                              SizedBox(width: 8),
                                                              Text(
                                                                exerciseDetailsText,
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      // Equipment Row with Icon
                                                      Card(
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.fitness_center, color: Colors.deepPurple),
                                                              SizedBox(width: 8),
                                                              Text(
                                                                "Equipment: None",
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      // Description
                                                      Text(
                                                        "Description:",
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                      Card(
                                                        elevation: 4,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            "This exercise helps improve strength and endurance. Make sure to maintain proper form.",
                                                            style: TextStyle(fontSize: 16),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),

                                                      // Dynamic GIF Display
                                                      AspectRatio(
                                                        aspectRatio: 1.78,
                                                        child: Center(
                                                          child: Image.asset(
                                                            workoutGifs[currIndexExercise["name"]] ??
                                                                'assets/workoutAsset/GIF_Bicycle.gif', // Fallback GIF if not found
                                                            fit: BoxFit.contain, // Ensure GIF fits properly
                                                          ),
                                                        )
                                                      ),
                                                      SizedBox(height: 20),

                                                      // Action Button
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            Navigator.pop(context);
                                                            DateTime currDate = DateTime.now();
                                                            if (selectedDay == listOfDays[currDate.weekday - 1]) {
                                                              await workoutPlanService.updateUserProgressByDay(
                                                                  currUid,
                                                                  listOfDays.indexWhere((dow) => dow == selectedDay),
                                                                  currIndexExercise["name"]);
                                                              await userService.addUserPoints(currUid ?? "", 50);
                                                              setState(() {});
                                                            } else {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  Future.delayed(Duration(seconds: 2), () {
                                                                    Navigator.pop(context);
                                                                  });
                                                                  return Align(
                                                                    alignment: Alignment.topCenter,
                                                                    child: Card(
                                                                      elevation: 5,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                      ),
                                                                      child: Container(
                                                                        width: 500,
                                                                        height: 50,
                                                                        child: Center(
                                                                          child: Text(
                                                                            "You can only finish a workout on the current day!",
                                                                            style: TextStyle(color: Colors.deepPurple),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                barrierColor: Colors.white.withOpacity(0),
                                                              );
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.deepPurple,
                                                            textStyle: TextStyle(fontSize: 16),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                            child: Text("Mark as Done", style: TextStyle(color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context); // Close the dialog
                                                    },
                                                    child: Text(
                                                      "Close",
                                                      style: TextStyle(
                                                        color: Colors.deepPurple,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },

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
                ),

              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/workout');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/leaderboard');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/profile');
                  break;
              }
            },
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
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
      },
    );
  }
}
