import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/models/box_model.dart';
import 'package:camera_app/models/param_image.dart';
import 'package:camera_app/pages/datasets/detail_image.dart';
import 'package:camera_app/pages/predict/predict_image.dart';
import 'package:camera_app/models/predict_settings_model.dart';
import 'package:camera_app/pages/predict/result_image/detail_result.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ResultImagePage extends StatefulWidget {
  final String file;
  final PredictSettingsModel predictSettingsModel;
  final String pathModel;
  final int width;
  final int height;
  const ResultImagePage({
    super.key,
    required this.file,
    required this.predictSettingsModel,
    required this.pathModel,
    required this.width,
    required this.height,
  });

  @override
  State<ResultImagePage> createState() => _ResultImagePageState();
}

class _ResultImagePageState extends State<ResultImagePage> {
  String? imageUrl;
  late PredictImage predict;
  List<BoxModel> results = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showDialogNotifi(text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            text.first,
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            text.last,
          ),
        );
      },
    );
  }

  _buildDetailResult() {
    return DetailResult(
      boxModels: results,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            FileModel.deleteImageFromPath(widget.file);
            Navigator.pop(context);
            // Or any other action
          },
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.file(
                File(widget.file),
                filterQuality: FilterQuality.high,
              ),
              PredictImage(
                imagePath: widget.file,
                width: widget.width,
                height: widget.height,
                predictSettingsModel: widget.predictSettingsModel,
                metadataPath: FileModel.pathYaml(widget.pathModel),
                modelPath: FileModel.pathTflite(widget.pathModel),
                detected: (result) => {
                  setState(() {
                    results = result;
                  }),
                },
                downloaded: (state) {
                  if (state) {
                    showDialogNotifi(["Download image", "Downloaded!"]);
                  }
                },
              ),
            ],
          ),
          if (results.isNotEmpty) ...[
            _buildDetailResult(),
          ]
        ],
      ),
    );
  }
}
