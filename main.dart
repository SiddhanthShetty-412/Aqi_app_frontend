// main.dart
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'dashboard_screen.dart';

void main() => runApp(CloudAQIApp());

class CloudAQIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud AQI',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

// welcome_screen.dart



class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade800, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo placeholder
                  Icon(Icons.cloud_outlined, size: 100, color: Colors.white),
                  SizedBox(height: 30),

                  // Welcome Text
                  Text(
                    'AQI Prediction Model',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your personalized air quality solution',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  // Login / Sign-Up Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple[900],
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text('Login / Sign-Up'),
                  ),
                  SizedBox(height: 20),




                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


