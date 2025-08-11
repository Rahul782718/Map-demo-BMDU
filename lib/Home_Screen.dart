import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapapi/Map_Screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Open Map"),
      ),
      body: Center(
        child: IconButton(
            onPressed: (){
             Navigator.push(context, MaterialPageRoute(builder: (context) => Map_Screen(),));
            },
            icon: Icon(CupertinoIcons.map_pin_ellipse,size: 28,)),
      ),
    );
  }
}
