import 'package:flutter/material.dart';
import 'package:software_engineering_project/services/workout_plan_service.dart';
import 'setting_page.dart';
import 'package:intl/intl.dart';

class WorkoutPlanPage extends StatefulWidget {
  @override
  _WorkoutPlanPageState createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {

  WorkoutPlanService workoutPlanService = WorkoutPlanService();

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

  int _currentIndex = 0; // To track the selected tab

  @override
  Widget build(BuildContext context) {
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
            ), //"Workout Plan Header"
            SizedBox(height: 20),
            // Title Section
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
              child:FutureBuilder(
                  future: workoutPlanService.getExcerciseByCategoryDay("1.1", listOfDays.indexWhere((dow)=>dow==selectedDay)),
                  builder: (context, snapshot)
                  {
                    if(snapshot.connectionState == ConnectionState.waiting)
                    {
                      return Center(child:CircularProgressIndicator());
                    }
                    else
                    {
                      if(snapshot.data == null)
                      {
                        return Text("Rest Bro");
                      }
                      Map<String, dynamic>? exercisesOfDay = snapshot.data;
                      print(exercisesOfDay);
                      return ListView.builder(
                          itemCount: exercisesOfDay?["exercises"].length ?? 0,
                          itemBuilder: (context, index)
                          {
                            Map<String, dynamic> currIndexExercise = exercisesOfDay?["exercises"][index];
                            String? exerciseDetails = currIndexExercise.containsKey("details")?currIndexExercise["details"]:null;
                            int? exerciseSets = currIndexExercise.containsKey("sets")?currIndexExercise["sets"]:null;
                            int? exerciseReps = currIndexExercise.containsKey("reps")?currIndexExercise["reps"]:null;
                            String? exerciseDuration = currIndexExercise.containsKey("duration")?currIndexExercise["duration"]:null;
                            return GestureDetector(
                              onTap:(){
                                print("Tapped");
                              },
                              child:Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                color: false ? Colors.black.withOpacity(0.5) : null, // Blackout effect for individual card
                                child: ListTile(
                                  leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                                  title:
                                    Text(currIndexExercise["name"],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  subtitle: Text(
                                    exerciseDetails!=null?"$exerciseDetails":(exerciseDuration!=null?"Duration : $exerciseDuration":exerciseReps==null?"":"$exerciseSets sets, $exerciseReps reps each")
                                  ),
                                  trailing: Icon(Icons.info, color: Colors.deepPurple)
                                )
                              )
                            );
                          }
                      );
                    }

                  })
              /*child: ListView.builder(
                itemCount: dailyExercises[selectedDay]?.length ?? 0,
                itemBuilder: (context, index) {
                  String exercise = dailyExercises[selectedDay]?[index] ?? "";
                  bool isBlackedOut = blackedOutExercises[exercise] ?? false;

                  return GestureDetector(
                    onTap: () {
                      // Prevent popup if the exercise is blacked out
                      if (!isBlackedOut) {
                        // Show Popup on Card Tap
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(exercise),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("3 sets of 15 reps"),
                                  SizedBox(height: 10),
                                  Text("Equipment: None"),
                                  SizedBox(height: 10),
                                  Text("Description: This is a great workout for your core."),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      blackedOutExercises[exercise] = true; // Blackout the current card
                                    });
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text("Finish Workout"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text("Close"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: isBlackedOut ? Colors.black.withOpacity(0.5) : null, // Blackout effect for individual card
                      child: ListTile(
                        leading: Icon(Icons.fitness_center, color: Colors.deepPurple),
                        title: Text(
                          exercise,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("3 sets of 15 reps"),
                        trailing: Icon(Icons.info, color: Colors.deepPurple),
                      ),
                    ),
                  );
                },
              ),*/
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Set the default active item
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Example navigation (replace with actual pages)
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // Stay on Workout Plan
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
}

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: WorkoutPlanPage(),
));