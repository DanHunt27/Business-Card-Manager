import 'package:flutter/material.dart';
import 'welcome.dart';

void main() => runApp(HomePage());

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Card Manager',
      debugShowCheckedModeBanner: false, //Get Rid of before git
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignIn(),
    );
  }
}
