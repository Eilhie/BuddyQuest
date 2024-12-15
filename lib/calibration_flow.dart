import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/user_sevice.dart';

class CalibrationPage extends StatefulWidget {
  @override
  _CalibrationPageState createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  int _currentStep = 0;
  List<int> selectedOptions = [0,0,0];
  final userService = UserService();

  final List<Map<String, dynamic>> _calibrationSteps = [
    {
      "question": "How often do you exercise in a week?",
      "options": ["Never", "1-3 days a week", "4-5 days a week", "6-7 days a week"],
    },
    {
      "question": "Which category is your age?",
      "options": ["Under 20 years old", "20 - 30 years old", "40 - 50 years old", "Over 50 years old"],
    },
    {
      "question": "What is your goal in exercising?",
      "options": [
        "Focus on building muscle mass",
        "Focus on losing weight",
        "Maintaining weight and increasing muscle mass",
      ],
    },
  ];

  Future<void> _nextStep() async {
    if (_currentStep < _calibrationSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // check workout types
      String workout_type = "";
      if((selectedOptions[0] <= 1) & (selectedOptions[1] <= 1))
      {
        workout_type = "1.1";
      }
      else if ((selectedOptions[0]==0) & (selectedOptions[1]>=2))
      {
        workout_type = "1.2";
      }
      else if ((selectedOptions[0]==2) & (selectedOptions[2]==0))
      {
        workout_type = "2.1";
      }
      else if ((selectedOptions[0]==2) & (selectedOptions[2]==1))
      {
        workout_type = "2.2";
      }
      else if ((selectedOptions[0]==2) & (selectedOptions[2]==2))
      {
        workout_type = "2.3";
      }
      else if ((selectedOptions[0]==3) & (selectedOptions[2]==0))
      {
        workout_type = "3.1";
      }
      else if ((selectedOptions[0]==3) & (selectedOptions[2]==1))
      {
        workout_type = "3.2";
      }
      else
      {
        workout_type = "3.3";
      }

      var currentUser = FirebaseAuth.instance.currentUser;
      var currUid = currentUser?.uid??"";
      await userService.updateUserWorkoutCategory(currUid, workout_type);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _calibrationSteps[_currentStep];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentStep["question"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Ensure all buttons have the same size
            ...currentStep["options"]!.map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity, // Ensures button width fills the available space
                  child: ElevatedButton(
                    onPressed: () async
                    {
                      selectedOptions[_currentStep] = (currentStep["options"] as List<String>).indexOf(option);
                      await _nextStep();
                    },
                    child: Text(option),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // Fixed height and full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
