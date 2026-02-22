import 'package:flutter/material.dart';


void main() {
  runApp(Home());
}
class Home extends StatelessWidget{
  Widget build(BuildContext context){
    return
      MaterialApp( home:
      Scaffold(
      body: Text(
            'assets/Leaf.png',
      style: TextStyle(
        fontSize: 100,
      ),),
    ),
      );
  }
}