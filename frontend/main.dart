import 'package:flutter/material.dart';
import 'login.dart';
// Import the HomePage widget (if needed in future)
const String baseUrl1 = 'http://14.139.187.229:8081';
const String flaskBaseUrl1 = 'http://180.235.121.245:5011';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Set the initial route to the login page
    );
  }
}