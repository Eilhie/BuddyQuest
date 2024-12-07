import 'package:flutter/material.dart';

class WorkoutPlanPage extends StatefulWidget {
  @override
  _WorkoutPlanPageState createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  String selectedDay = "Monday"; // Default selected day
  Map<String, bool> blackedOutExercises = {}; // To track blacked-out state for each exercise

  // Map of exercises for each day
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
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to Settings Page or Open Settings
                  },
                ),
              ],
            ),
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
              child: ListView.builder(
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
              ),
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
