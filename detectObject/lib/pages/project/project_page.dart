import 'dart:io';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/models/model_predict.dart';
import 'package:camera_app/pages/project/project_button_delete.dart';
import 'package:camera_app/repository/firebase_repository.dart';
import 'package:flutter/material.dart';

import 'package:download_assets/download_assets.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'project_button_download.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});
  @override
  State<ProjectPage> createState() => _PredictPageWidgetState();
}

class _PredictPageWidgetState extends State<ProjectPage> {
  FirebaseRepository firebaseRepository = FirebaseRepository();
  Map _pathModels = {};

  List<Widget> _widgets = [
    const Center(
      child: Text(
        "Models",
        style: TextStyle(
          fontSize: 25,
          color: Colors.indigo,
          letterSpacing: 0.1,
        ),
      ),
    ),
  ];

  @override
  initState() {
    super.initState();
    _buildModelsPredicts();
  }

  _buildModelsPredicts() async {
    FileModel.getFileModel().then((files) {
      if (mounted) {
        setState(() {
          print(files);
          _pathModels.addAll(files);
        });
      }
    });

    await firebaseRepository.getModelsRealTime().then((models) {
      _widgets = [
        const Center(
          child: Text(
            "Models",
            style: TextStyle(
                fontSize: 25,
                color: Colors.indigo,
                letterSpacing: 0.1,
                fontWeight: FontWeight.bold),
          ),
        ),
      ];
      for (var model in models) {
        if (mounted) {
          setState(() {
            bool containsItem = _pathModels.containsKey("${model.name}");
            _widgets.add(buildCard(model, containsItem));
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          if (_widgets.length == 1) ...[
            Column(
              children: [
                _widgets.first,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    size: 30,
                    color: Colors.indigoAccent,
                  ),
                ),
              ],
            ),
          ] else
            ListView(
              scrollDirection: Axis.vertical,
              children: _widgets,
            ),
        ],
      ),
    );
  }

  Widget buildCard(ModelsPredict modelsPredict, bool state) {
    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.transparent, width: 0.5),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: const AlignmentDirectional(0, 0),
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          modelsPredict.name,
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (state) ...[
                    ButtonDelete(
                      name: modelsPredict.name,
                      pathModels: _pathModels[modelsPredict.name],
                      deleted: (stateDelete) {
                        if (stateDelete) {
                          _showDialogNotifi(['Delete model', 'Model deleted!']);
                          _buildModelsPredicts();
                        }
                      },
                    )
                  ]
                ],
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.3,
                endIndent: 10,
                indent: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    " ${modelsPredict.getMB().toStringAsFixed(2)} MB ",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: 0.1,
                      backgroundColor: Color.fromARGB(255, 238, 238, 238),
                    ),
                  ),
                  Text(
                    "[${modelsPredict.time}]",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              ButtonDownload(
                modelsPredict: modelsPredict,
                state: state,
                downloaded: (state) {
                  if (state) {
                    _showDialogNotifi(['Download model', 'Model downloaded!']);
                    _buildModelsPredicts();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showDialogNotifi(text) {
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
}
