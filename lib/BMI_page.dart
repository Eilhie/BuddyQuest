import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BMIPage extends StatefulWidget {
  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmi;
  String _bmiCategory = "";

  void _calculateBMI() {
    final String heightText = _heightController.text;
    final String weightText = _weightController.text;

    if (heightText.isEmpty || weightText.isEmpty) {
      _showErrorDialog("Please enter both height and weight.");
      return;
    }

    try {
      final double height = double.parse(heightText) / 100; // Convert to meters
      final double weight = double.parse(weightText);

      if (height <= 0 || weight <= 0) {
        _showErrorDialog("Height and weight must be greater than zero.");
        return;
      }

      setState(() {
        _bmi = weight / (height * height);
        _bmiCategory = _getBMICategory(_bmi!);
      });
    } catch (e) {
      _showErrorDialog("Please enter valid numbers.");
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return "Normal weight";
    } else if (bmi >= 25 && bmi < 29.9) {
      return "Overweight";
    } else {
      return "Obesity";
    }
  }

  void _showErrorDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Calculate your Body Mass Index (BMI) easily!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Height (cm)",
                            prefixIcon: const Icon(Icons.height),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Weight (kg)",
                            prefixIcon: const Icon(Icons.line_weight),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _calculateBMI,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Calculate BMI",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _bmi != null
                      ? Card(
                    key: ValueKey(_bmi),
                    color: Colors.deepPurple.shade50,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Your BMI: ${_bmi!.toStringAsFixed(1)}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Category: $_bmiCategory",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
