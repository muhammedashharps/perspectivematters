// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matter/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perspective Matters',
      theme: ThemeData(
        fontFamily: "Poppins",
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
