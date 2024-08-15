import 'dart:io';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/models/model_predict.dart';
import 'package:camera_app/repository/firebase_repository.dart';
import 'package:download_assets/download_assets.dart';
import 'package:flutter/material.dart';

class ButtonDownload extends StatefulWidget {
  final ModelsPredict modelsPredict;
  final bool state;

  final Function(bool state)? downloaded;

  const ButtonDownload({
    super.key,
    required this.modelsPredict,
    required this.state,
    this.downloaded,
  });
  @override
  State<ButtonDownload> createState() => _PredictPageWidgetState();
}

class _PredictPageWidgetState extends State<ButtonDownload> {
  FirebaseRepository firebaseRepository = FirebaseRepository();
  DownloadAssetsController downloadAssetsController =
      DownloadAssetsController();

  String message = "Download";
  bool state = true;

  @override
  initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await downloadAssetsController.init(assetDir: "assets/models");
  }

  @override
  Widget build(BuildContext context) {
    var text = !widget.state
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          )
        : const Text(
            "Downloaded",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          );
    var color = !widget.state ? Colors.indigo : Colors.green[700];

    return ButtonTheme(
      minWidth: MediaQuery.of(context).size.width * .60,
      child: MaterialButton(
        onPressed: () async {
          if (state) {
            firebaseRepository
                .getModelsStorage(widget.modelsPredict.name)
                .then((url) {
              _downloadFile(url.toString());
            });
          }
        },
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: text,
      ),
    );
  }

  _downloadFile(String fileurl) async {
    message = "Prepare!";
    try {
      await downloadAssetsController.startDownload(
          onCancel: () {
            if (mounted) {
              setState(() {
                message = "Cancel!";
                widget.downloaded!(false);
              });
            }
          },
          assetsUrls: [
            fileurl.toString(),
          ],
          onProgress: (progressValue) {
            if (mounted) {
              setState(() {
                state = false;
                message =
                    'Downloading...(${(progressValue * 100).toStringAsFixed(2)}%)';
              });
            }
          },
          onDone: () async {
            await FileModel.setupDownload().whenComplete(() {
              String newName =
                  (fileurl.toString().split("%2F").last).split("?").first;
              FileModel.unzipFile(
                  File('${downloadAssetsController.assetsDir}/$newName.zip')
                      .path,
                  "/assets/models/");
            });

            if (mounted) {
              setState(() {
                state = true;
                message = "Downloaded!";
                widget.downloaded!(true);
              });
            }
          });
    } on DownloadAssetsException catch (e) {
      print(e.toString());
    }
  }
}
