import 'dart:async';
// import 'dart:collection';
import 'dart:io' as io;
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:camera_app/models/box_model.dart';
import 'package:camera_app/models/predict_settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:ultralytics_yolo/camera_preview/ultralytics_yolo_camera_controller.dart';
import 'package:ultralytics_yolo/predict/detect/detect.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

import '../../apps/utils/const.dart';
import '../../models/param_image.dart';

class PredictImage extends StatefulWidget {
  final String imagePath;
  final PredictSettingsModel predictSettingsModel;
  final String modelPath;
  final String metadataPath;
  final int width;
  final int height;
  final void Function(List<BoxModel> result)? detected;
  final void Function(bool state)? downloaded;

  const PredictImage(
      {super.key,
      required this.imagePath,
      required this.height,
      required this.width,
      required this.predictSettingsModel,
      required this.metadataPath,
      required this.modelPath,
      this.detected,
      this.downloaded});

  @override
  State<PredictImage> createState() => _PredictImageState();
}

class _PredictImageState extends State<PredictImage> {
  List<BoxModel> boxs = [];
  bool detected = false;
  late ByteData _imgBytes;

  final colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];

  @override
  initState() {
    super.initState();
    _imgBytes = ByteData(0);
    predictImage();
  }

  predictImage() async {
    final modelPath = widget.modelPath;
    final metadataPath = widget.metadataPath;

    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.tflite,
      modelPath: modelPath,
      metadataPath: metadataPath,
    );

    double confidence =
        double.parse(widget.predictSettingsModel.currentThreshold.toString());
    double iou =
        double.parse(widget.predictSettingsModel.currentIoU.toString());
    int numberitem = widget.predictSettingsModel.getCurrentExposureOffset();

    var objectDetector = ObjectDetector(model: model);
    await objectDetector.loadModel(useGpu: true);
    objectDetector.setConfidenceThreshold(confidence);
    objectDetector.setIouThreshold(iou);
    objectDetector.setNumItemsThreshold(numberitem);

    await objectDetector.detect(imagePath: widget.imagePath).then((object) {
      if (mounted) {
        setState(() {
          boxs = [];
          for (var item in object!) {
            final String label = item!.label;
            final double confidence = item.confidence;
            if (confidence > 0.15) {
              boxs.add(
                BoxModel(
                  rect: item.boundingBox,
                  label: label,
                  confidence: confidence,
                ),
              );
            }
          }
          detected = true;
          if (boxs.isNotEmpty) {
            generateImage();
          }
        });
      }
    });
  }

  generateImage() async {
    final recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0.0, 0.0),
            Offset(
              double.parse((widget.width).toString()),
              double.parse((widget.height).toString()),
            )));

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < boxs.length; i++) {
      final BoxModel box = boxs[i];
      final Paint paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      final value = widget.height / widget.width;
      final double x = box.rect.left;
      final double y = box.rect.top;
      final double width = box.rect.width;
      final double height = box.rect.height;
      final double right = box.rect.right * value;
      final double bottom = box.rect.bottom * value;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width, height),
          const Radius.circular(8),
        ),
        paint,
      );

      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 20,
          textDirection: TextDirection.ltr,
        ),
      )
        ..pushStyle(
          ui.TextStyle(
            color: colors[i % colors.length],
            background: paint,
          ),
        )
        ..addText(' ${box.label} '
            '${(box.confidence * 100).toStringAsFixed(1)}\n')
        ..pop();
      canvas.drawParagraph(
        builder.build()..layout(ui.ParagraphConstraints(width: right - x)),
        Offset(max(0, x), max(0, y)),
      );
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      widget.width,
      widget.height,
    );
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    setState(() {
      _imgBytes = pngBytes!;
      widget.detected!(boxs);
    });
  }

  downloadImage() async {
    await FileModel.saveImage(
            widget.imagePath, Uint8List.view(_imgBytes.buffer))
        .then((name) async {
      ParamImage paramImage = ParamImage(
        time: TimeFormat.createKey(),
        name: name.toString(),
        input1: widget.predictSettingsModel.getCurrentIoU(),
        input2: widget.predictSettingsModel.getCurrentThreshold(),
        input3: widget.predictSettingsModel.getCurrentExposureOffset(),
        model: widget.modelPath,
      );
      await DatabaseLocal.addImage(paramImage);
      await DatabaseLocal.addResult(name.toString(), boxs);
      setState(() {
        widget.downloaded!(true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!detected) {
      return Center(
        child: LoadingAnimationWidget.discreteCircle(
          size: 30,
          color: Colors.white,
        ),
      );
    }

    return _imgBytes.buffer.asInt8List().isNotEmpty
        ? Stack(
            children: [
              Image.memory(
                Uint8List.view(_imgBytes.buffer),
                alignment: Alignment.center,
              ),
              Positioned(
                bottom: 20,
                right: 10,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    downloadImage();
                  },
                  child: const Icon(Icons.download_rounded, size: 35),
                ),
              )
            ],
          )
        : Container();
  }
}
