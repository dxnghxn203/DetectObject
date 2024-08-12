import 'package:camera/camera.dart';
import 'package:camera_app/pages/predict/predict_page.dart';
import 'package:camera_app/pages/menu_page/menu_main.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final List<CameraDescription> camera;
  const MyApp({super.key, required this.camera});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: MenuMain(
        camera: camera,
      ),
    );
  }
}
