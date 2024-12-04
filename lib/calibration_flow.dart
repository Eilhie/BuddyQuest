import 'package:flutter/material.dart';

class CalibrationPage extends StatefulWidget {
  @override
  _CalibrationPageState createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  int _currentStep = 0;

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

  void _nextStep() {
    if (_currentStep < _calibrationSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
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
                    onPressed: _nextStep,
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
