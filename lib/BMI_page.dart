import 'package:flutter/material.dart';

void main() => runApp(BMICalculator());

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BMIPage(),
    );
  }
}

class BMIPage extends StatefulWidget {
  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  int age = 30;
  int weight = 78;
  double height = 175;
  double bmi = 0.0;

  void calculateBMI() {
    setState(() {
      bmi = weight / ((height / 100) * (height / 100));
    });

    // Show a popup dialog with the results
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "BMI Results",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bmi.toStringAsFixed(2),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                _getBMICategory(),
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  'BMI Calculator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48), // To balance spacing
              ],
            ),
            const SizedBox(height: 20),
            // Body Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Age and Weight counters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCounterCard("Age", age, () => setState(() => age++),
                                () => setState(() => age--)),
                        _buildCounterCard("Weight (KG)", weight,
                                () => setState(() => weight++), () => setState(() => weight--)),
                      ],
                    ),
                    // Height Slider
                    Column(
                      children: [
                        const Text("Height (CM)", style: TextStyle(fontSize: 18)),
                        Slider(
                          value: height,
                          min: 50,
                          max: 300,
                          onChanged: (val) => setState(() => height = val),
                        ),
                        Text("${height.toInt()} CM", style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                    // Calculate BMI Button
                    ElevatedButton(
                      onPressed: calculateBMI,
                      child: const Text("Calculate BMI"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(
      String label, int value, VoidCallback increment, VoidCallback decrement) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: decrement),
            Text("$value", style: const TextStyle(fontSize: 24)),
            IconButton(icon: const Icon(Icons.add), onPressed: increment),
          ],
        ),
      ],
    );
  }

  String _getBMICategory() {
    if (bmi < 18.5) return "Underweight";
    if (bmi >= 18.5 && bmi < 25) return "Normal BMI";
    if (bmi >= 25 && bmi < 30) return "Overweight";
    return "Obesity";
  }
}
