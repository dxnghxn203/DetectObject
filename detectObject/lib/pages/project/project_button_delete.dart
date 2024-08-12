import 'dart:io';

import 'package:camera_app/apps/utils/const.dart';
import 'package:flutter/material.dart';

class ButtonDelete extends StatefulWidget {
  final void Function(bool state)? deleted;
  final String pathModels;
  final String name;
  const ButtonDelete({
    super.key,
    required this.name,
    required this.pathModels,
    this.deleted,
  });
  @override
  State<ButtonDelete> createState() => _PredictPageWidgetState();
}

class _PredictPageWidgetState extends State<ButtonDelete> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            _showDialogModel();
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  _showDialogModel() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Delete model?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            content: Text.rich(
              TextSpan(
                text: 'Are you sure you want to delete ',
                children: <TextSpan>[
                  TextSpan(
                      text: '"${widget.name}"?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            actions: [
              ButtonTheme(
                child: MaterialButton(
                  onPressed: () async {
                    _deleteModel();
                    Navigator.pop(context);
                  },
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Delete model',
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

  _deleteModel() async {
    await FileModel.deleteModel(widget.pathModels).whenComplete(() {
      setState(() {
        widget.deleted!(true);
      });
    });
  }
}
