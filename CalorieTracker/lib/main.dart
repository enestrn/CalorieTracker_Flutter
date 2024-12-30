import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/hesap_girisi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalori Takip Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HesapGirisiSayfasi(),
    );
  }
}
