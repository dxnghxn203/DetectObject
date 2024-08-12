import 'dart:io';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/models/param_image.dart';
import 'package:flutter/material.dart';

class DetailImage extends StatefulWidget {
  String pathInput;
  String pathOuput;
  void Function(bool state)? deleted;

  DetailImage(
      {super.key,
      required this.pathInput,
      required this.pathOuput,
      this.deleted});
  @override
  State<DetailImage> createState() => _ItemPageWidgetState();
}

class _ItemPageWidgetState extends State<DetailImage> {
  late ParamImage paramImage = ParamImage(
      name: 'name',
      input1: 0,
      input2: 0,
      input3: 0,
      model: "model",
      time: "time");

  List<Widget> results = [];

  @override
  initState() {
    super.initState();
    DatabaseLocal.getImageByName(widget.pathOuput).then((data) {
      for (var item in data) {
        setState(() {
          paramImage = ParamImage.fromJson(item);
        });
      }
    });
    results.add(const Row(children: [
      Text("Objects:",
          style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              letterSpacing: 0.1,
              fontWeight: FontWeight.bold)),
    ]));
    DatabaseLocal.getResultByName(widget.pathOuput).then((data) {
      for (var item in data) {
        results.add(
          Row(
            children: [
              Text(" ${item['object']}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    letterSpacing: 0.1,
                  )),
              Text(":${item['number']} ",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.indigo,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.bold))
            ],
          ),
        );
      }
    });
  }

  _buildInforImage() {
    return Column(
      children: [
        const Text(
          "Output",
          style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              letterSpacing: 0.1,
              fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(" ${paramImage.getModel()}",
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold)),
            Text("[${paramImage.time}] ",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  letterSpacing: 0.1,
                ))
          ],
        ),
        Row(
          children: [
            _buildValue("Threshold", paramImage.getThreshold()),
            _buildValue("Iou", paramImage.getIou()),
            _buildValue("Number item", paramImage.input3),
          ],
        ),
      ],
    );
  }

  _buildResult() {}
  _deleteImage() {
    _showDialogDelete();
  }

  _showDialogDelete() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Delete image?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            content: const Text.rich(
              TextSpan(
                text: 'Are you sure you want to delete ',
                children: <TextSpan>[
                  TextSpan(
                      text: '"image"?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            actions: [
              ButtonTheme(
                child: MaterialButton(
                  onPressed: () async {
                    await FileModel.deleteImageFromPath(widget.pathInput);
                    await FileModel.deleteImageFromPath(widget.pathOuput);
                    await DatabaseLocal.deleteImage(widget.pathOuput);
                    await DatabaseLocal.deleteResult(widget.pathOuput);
                    setState(() {
                      widget.deleted!(true);
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Delete image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context); //close Dialog
                },
                icon: const Icon(Icons.close_outlined),
              )
            ],
          );
        });
  }

  _buildValue(title, value) {
    return Row(
      children: [
        Text(" $title:"),
        Text(" $value",
            style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                letterSpacing: 0.1,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // Or any other action
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_outlined),
                  onPressed: () {
                    // Or any other action
                    _deleteImage();
                  },
                ),
              ],
            )),
        body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const Center(
                    child: Text(
                      "Input",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Image.file(File(widget.pathInput)),
                  _buildInforImage(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Image.file(File(widget.pathInput)),
                        Image.file(File(widget.pathOuput)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                    child: Column(
                      children: results,
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
