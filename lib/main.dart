import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'database_helper.dart';
import 'home_screen.dart';

// Global list to hold available cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database to ensure it's ready when the app starts
  await DatabaseHelper.instance.database;

  // Obtain a list of the available cameras on the device.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  runApp(const CeaRecyclingApp());
}

class CeaRecyclingApp extends StatelessWidget {
  const CeaRecyclingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centrala Recycling',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}