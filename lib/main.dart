import 'package:pharmaguard_app/pages/login.page.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PharmaGuard',
      //theme: ThemeData(primarySwatch: Color.fromARGB(255, 83, 17, 196)),
      home: LoginPage(),
    );
  }
}
