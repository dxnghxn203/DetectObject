import 'dart:io';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/pages/datasets/image.dart';
import 'package:flutter/material.dart';

class DatasetPage extends StatefulWidget {
  const DatasetPage({super.key});
  @override
  State<DatasetPage> createState() => _DatasetPageWidgetState();
}

class _DatasetPageWidgetState extends State<DatasetPage> {
  List<Widget> _images = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    FileModel.getImages().then((data) {
      setState(() {
        _images = [];
        for (var entry in data.entries) {
          _images.add(
            ImageWidget(
                pathInput: entry.key.toString(),
                pathOuput: entry.value.toString(),
                deleted: (state) {
                  _init();
                }),
          );
        }
      });
    });
  }

  @override
  Widget build(Object context) {
    var body = _images.isNotEmpty
        ? GridView(
            padding: const EdgeInsets.all(25),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0),
            children: _images,
          )
        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                ),
                Text('No Image!'),
              ],
            ),
          ]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Images",
          style: TextStyle(
              fontSize: 25,
              color: Colors.indigo,
              letterSpacing: 0.1,
              fontWeight: FontWeight.bold),
        ),
      ),
      // Implement the GridView
      body: body,
    );
  }
}
