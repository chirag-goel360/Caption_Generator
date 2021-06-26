import 'package:flutter/material.dart';
import 'package:live_caption_generator/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caption Generator',
      home: SplashScreenPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
