import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/pages/predict/option_model/predict_option.dart';
import 'package:camera_app/pages/predict/predict_setting/predict_settings.dart';
import 'package:camera_app/models/predict_settings_model.dart';
import 'package:camera_app/pages/predict/slider.dart';
import 'package:camera_app/pages/predict/result_image/result_image.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';

class BodyCameraPage extends StatefulWidget {
  final List<CameraDescription> camera;
  const BodyCameraPage({super.key, required this.camera});
  @override
  State<BodyCameraPage> createState() => _BodyCameraPageState();
}

class _BodyCameraPageState extends State<BodyCameraPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;

  PredictSettingsModel _predictSettingsModel =
      PredictSettingsModel(1, 0.75, 0.2);

  String _pathModels = "";

  @override
  void initState() {
    super.initState();
    restartCamera();
  }

  void restartCamera() {
    cameraController = CameraController(
      widget.camera[0],
      ResolutionPreset.high,
    );
    cameraValue = cameraController.initialize();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  _showDialogNotChooseModel() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.transparent, width: 0.5),
      ),
      content: const Center(
          child: Text("Please choose model!",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))),
    ));
  }

  Future<XFile?> pickImage() async {
    await cameraValue;
    final XFile file = await cameraController.takePicture();
    File rotatedImage = await FlutterExifRotation.rotateImage(path: file.path);
    return XFile(rotatedImage.path);
  }

  Future<void> _takePicture() async {
    if (_pathModels.isEmpty) {
      _showDialogNotChooseModel();
    } else {
      try {
        pickImage().then((file) async {
          int newsizeW = _key.currentContext!.size!.width.toInt();
          int newsizeH = _key.currentContext!.size!.height.toInt();
          File rotatedImage =
              await FlutterExifRotation.rotateImage(path: file!.path);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultImagePage(
                file: rotatedImage.path,
                predictSettingsModel: _predictSettingsModel,
                pathModel: _pathModels,
                width: newsizeW,
                height: newsizeH,
              ),
            ),
          );
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          _cameraWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 30, 30),
                child: _buildPredictSettings(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    width: 100,
                  ),
                  _buildButtonTakePhoto(),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: IconButton(
                      onPressed: () {
                        // _takePicture();
                        _getImage();
                      },
                      icon: const Icon(
                        Icons.perm_media_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      floatingActionButton: PredictOptionModelPage(
        chooseModel: (model) {
          setState(() {
            _pathModels = model;
          });
        },
      ),
    );
  }

  _buildPredictSettings() {
    return PredictSettingsPage(predictSettingsModel: _predictSettingsModel);
  }

  _getImage() async {
    if (_pathModels.isEmpty) {
      _showDialogNotChooseModel();
    } else {
      try {
        int newsizeW = _key.currentContext!.size!.width.toInt();
        int newsizeH = _key.currentContext!.size!.height.toInt();
        final XFile? image =
            await ImagePicker().pickImage(source: ImageSource.gallery);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultImagePage(
              file: image!.path,
              predictSettingsModel: _predictSettingsModel,
              pathModel: _pathModels,
              width: newsizeW,
              height: newsizeH,
            ),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  late final GlobalKey _key = GlobalKey();
  FutureBuilder<void> _cameraWidget() {
    return FutureBuilder<void>(
      future: cameraValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AspectRatio(
                  key: _key,
                  aspectRatio: 1 / cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController))
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _buildButtonTakePhoto() {
    return IconButton(
      onPressed: () {
        _takePicture();
      },
      icon: const Icon(
        Icons.camera,
        size: 50,
        color: Colors.white,
      ),
    );
  }
}
