import 'dart:io';

import 'package:camera_app/pages/datasets/detail_image.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  final String pathInput;
  final String pathOuput;
  final void Function(bool state)? deleted;

  const ImageWidget(
      {super.key,
      required this.pathInput,
      required this.pathOuput,
      this.deleted});
  @override
  State<ImageWidget> createState() => _ItemImageWidgetState();
}

class _ItemImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: InkWell(
        radius: 100,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailImage(
                pathInput: widget.pathInput,
                pathOuput: widget.pathOuput,
                deleted: (state) {
                  setState(() {
                    widget.deleted!(true);
                  });
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
          child: Stack(
            children: [
              Ink.image(
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                image: FileImage(File(widget.pathInput)),
              ),
              Ink.image(
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                image: FileImage(File(widget.pathOuput)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
