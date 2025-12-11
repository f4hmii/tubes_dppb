import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MovrApp());
}

class MovrApp extends StatelessWidget {
  const MovrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOVR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}