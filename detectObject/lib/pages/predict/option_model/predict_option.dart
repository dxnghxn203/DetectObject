import 'package:camera_app/apps/utils/const.dart';
// import 'package:camera_app/models/model_predict.dart';
import 'package:camera_app/pages/predict/option_model/item_option.dart';
import 'package:flutter/material.dart';

class PredictOptionModelPage extends StatefulWidget {
  void Function(String model)? chooseModel;
  PredictOptionModelPage({super.key, this.chooseModel});
  @override
  State<PredictOptionModelPage> createState() => _BodyCameraPageState();
}

class _BodyCameraPageState extends State<PredictOptionModelPage> {
  List<Widget> _widgets = [];
  String modelCurrent = "None";

  @override
  void initState() {
    super.initState();
    _buildModelsPredicts();
  }

  @override
  Widget build(Object context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildModels(),
          ],
        ),
      ],
    );
  }

  _buildModelsPredicts() async {
    await FileModel.getFileModel().then((files) {
      if (mounted) {
        setState(() {
          _widgets = [];
          for (var entry in files.entries) {
            setState(() {
              _widgets.add(
                ItemOption(
                  name: entry.key,
                  state: modelCurrent == entry.key,
                  chooseModel: (model) {
                    setState(() {
                      modelCurrent = model;
                      widget.chooseModel!(entry.value);
                      _buildModelsPredicts();
                      Navigator.pop(context);
                    });
                  },
                ),
              );
            });
          }
        });
      }
    });
  }

  _buildModels() {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    color: Colors.grey[300],
                    thickness: 5,
                    endIndent: MediaQuery.of(context).size.width / 3,
                    indent: MediaQuery.of(context).size.width / 3,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Text(
                      'Models',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 6, 19, 81)),
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 0.3,
                    endIndent: 10,
                    indent: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        "Model choose: [${_showText(modelCurrent, 20, 19)}]",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 6, 19, 81)),
                      ),
                      if (_widgets.isEmpty) ...[
                        _buildWidgetNoData(),
                      ] else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: ListView(
                            shrinkWrap: true,
                            children: _widgets,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      icon: const Icon(
        Icons.label_outline,
        color: Colors.white,
        size: 25,
      ),
      label: Text(
        _showText(modelCurrent, 7, 6),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 13, 44, 199),
    );
  }

  _showText(String text, int max, int last) {
    String newText = text;
    if (text.length > max) {
      return "${text.substring(0, last)}...";
    }
    return newText;
  }

  _buildWidgetNoData() {
    return const SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey,
          ),
          Text('No Data!'),
        ],
      ),
    );
  }
}
