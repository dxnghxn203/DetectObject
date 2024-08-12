// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ParamImage {
  String name = "";
  int input1 = 0;
  int input2 = 0;
  int input3 = 0;
  String model = "";
  String time = "";

  ParamImage(
      {required this.name,
      required this.input1,
      required this.input2,
      required this.input3,
      required this.model,
      required this.time});

  factory ParamImage.fromJson(Map<dynamic, dynamic> json) {
    String name = json['name'].toString();
    int input1 = int.parse(json['input1'].toString());
    int input2 = int.parse(json['input2'].toString());
    int input3 = int.parse(json['input3'].toString());
    String model = json['model'].toString();
    String time = json['time'].toString();
    return ParamImage(
        name: name,
        input1: input1,
        input2: input2,
        input3: input3,
        model: model,
        time: time);
  }

  getModel() {
    return (model.split('/').last).split("_tflite.tflite").first;
  }

  getIou() {
    return (input1 / 100);
  }

  getThreshold() {
    return (input2 / 100);
  }

  getCurrentExposureOffset() {
    return input3;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'input1': input1,
      'input2': input2,
      'input3': input3,
      'model': model,
      'time': time
    };
  }
}
