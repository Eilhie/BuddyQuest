import 'package:flutter_dotenv/flutter_dotenv.dart';

class FlutterDotenv {
  // Load environment variables from the .env file
  static Future<void> load() async {
    await dotenv.load(fileName: "..env");  // Ensure the correct path to .env file
  }

  // Access the environment variables
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID']!;
  static String get firebaseApiKey => dotenv.env['API_KEY']!;
  static String get firebaseAppId => dotenv.env['APP_ID']!;
  static String get firebaseProjectId => dotenv.env['PROJECT_ID']!;
  static String get firebaseMessagingSenderId => dotenv.env['MESSAGING_SENDER_ID']!;
}


// INI BLOM KEPAKE EROR GAMAU BACA ENV NYA
