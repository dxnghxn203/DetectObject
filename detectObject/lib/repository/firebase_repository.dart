import 'dart:io';

import 'package:camera_app/apps/utils/const.dart';
import 'package:camera_app/models/model_predict.dart';
import 'package:camera_app/models/param_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseRepository {
  FirebaseRepository();

  getModelsRealTime() async {
    try {
      List<ModelsPredict> modelsPredicts = [];
      await FirebasePath.getModelsRealtime()
          .once(DatabaseEventType.value)
          .then((data) {
        modelsPredicts = [];
        for (var item in data.snapshot.children) {
          print(item.value);
          var map = item.value as Map<dynamic, dynamic>;
          ModelsPredict modelsPredict = ModelsPredict.fromJson(map);
          modelsPredicts.add(modelsPredict);
        }
      });
      return modelsPredicts;
    } catch (e) {
      // error
    }
    return null;
  }

  Future<String> uploadStorage(File file) async {
    try {
      String storageName = TimeFormat.crateFileName();
      UploadTask uploadTask = FirebasePath.getStorageInput()
          .child("$storageName.jpg")
          .putFile(file);
      await uploadTask.whenComplete(() {});
      return storageName;
    } catch (e) {
      print('Error uploading storage: $e');
      return '';
    }
  }

  getModelsStorage(String model) async {
    String downloadUrl =
        await FirebasePath.getModelsStorage().child(model).getDownloadURL();
    print('Get successfully. Download URL: $downloadUrl');
    return downloadUrl;
  }

  Future<String> getStorageInput(String storageName) async {
    String input = "$storageName.jpg";
    print("INPUT STORAGE: $input");
    return await getStorage("$storageName.jpg", FirebasePath.getStorageInput());
  }

  Future<String> getStorageOutput(String storageName) async {
    String output = "${storageName.split('_')[0]}_out.jpg";
    print("OUTPUT STORAGE: $output");
    return await getStorage(output, FirebasePath.getStorageOutput());
  }

  Future<String> getStorage(String name, Reference ref) async {
    print("STORAGE DETAIL: $name");
    try {
      String downloadUrl = await ref.child(name).getDownloadURL();
      print('Get successfully. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error getStorage file: $e');
      return '';
    }
  }
}
