import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_page.dart';

class PredictPage extends StatefulWidget {
  final List<CameraDescription> camera;
  const PredictPage({super.key, required this.camera});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: BodyCameraPage(camera: widget.camera),
        extendBodyBehindAppBar: true,
      ),
    );
  }
}
