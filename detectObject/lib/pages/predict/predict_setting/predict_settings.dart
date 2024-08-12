import 'package:camera_app/models/predict_settings_model.dart';
import 'package:flutter/material.dart';

import '../slider.dart';

class PredictSettingsPage extends StatefulWidget {
  final PredictSettingsModel predictSettingsModel;
  const PredictSettingsPage({super.key, required this.predictSettingsModel});
  @override
  State<PredictSettingsPage> createState() => _PredictSettingsPageState();
}

class _PredictSettingsPageState extends State<PredictSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Divider(
                    color: Colors.grey[300],
                    thickness: 5,
                    endIndent: MediaQuery.of(context).size.width / 3,
                    indent: MediaQuery.of(context).size.width / 3,
                  ),
                  const Text(
                    'Predict Settings',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 6, 19, 81)),
                  ),
                  _buildExposureSlider(),
                  _buildIouThreshold(),
                  _buildThreshold(),
                ],
              ),
            );
          },
        );
      },
      icon: const Icon(
        Icons.filter_list,
        color: Colors.black,
        size: 30,
      ),
    );
  }

  Widget _buildExposureSlider() {
    return SliderCamera(
      current: widget.predictSettingsModel.currentExposureOffset,
      style: 1,
      onChanged: _updateExposureOffset,
    );
  }

  Widget _buildIouThreshold() {
    return SliderCamera(
      current: widget.predictSettingsModel.currentIoU,
      onChanged: _updateIoU,
      style: 2,
    );
  }

  Widget _buildThreshold() {
    return SliderCamera(
      current: widget.predictSettingsModel.currentThreshold,
      style: 3,
      onChanged: _updateThreshold,
    );
  }

  void _updateExposureOffset(double value) {
    setState(() {
      widget.predictSettingsModel.currentExposureOffset = value;
    });
  }

  void _updateThreshold(double value) {
    setState(() {
      widget.predictSettingsModel.currentThreshold = value;
    });
  }

  void _updateIoU(double value) {
    setState(() {
      widget.predictSettingsModel.currentIoU = value;
    });
  }
}
