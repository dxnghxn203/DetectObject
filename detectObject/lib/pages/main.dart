import 'package:camera_app/pages/my_app.dart';
import 'package:camera_app/repository/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final cameras = await availableCameras();

  runApp(
    MyApp(
      camera: cameras,
    ),
  );
}
