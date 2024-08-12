import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:camera_app/models/box_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as IMG;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

import '../../models/param_image.dart';

class TimeFormat {
  static String createKey() {
    DateTime currentDate = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH-mm-ss');
    return dateFormat.format(currentDate);
  }

  static String crateFileName() {
    return "${DateTime.now().millisecondsSinceEpoch}_in";
  }
}

class DatabaseLocal {
  static Future<void> createTableImage(sql.Database database) async {
    await database.execute("""CREATE TABLE images(
        name TEXT,
        input1 INTEGER,
        input2 INTEGER,
        input3 INTEGER,
        model TEXT,
        time TEXT
      )
      """);
  }

  static Future<void> createTableResult(sql.Database database) async {
    await database.execute("""CREATE TABLE results(
        name TEXT,
        object TEXT,
        number INTEGER
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'camera_app.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTableImage(database);
        await createTableResult(database);
      },
    );
  }

  static addResult(String name, List<BoxModel> result) async {
    final db = await DatabaseLocal.db();
    for (var entry in BoxModel.countItem(result).entries) {
      Map<String, dynamic> map = {
        'name': name,
        'object': entry.key,
        'number': entry.value
      };
      await db.insert(
        'results',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getResultByName(String name) async {
    final db = await DatabaseLocal.db();
    return db.query('results', where: "name = ?", whereArgs: [name]);
  }

  static Future<List<Map<String, dynamic>>> getAllImage() async {
    final db = await DatabaseLocal.db();
    return db.query('images', orderBy: "name");
  }

  static Future<List<Map<String, dynamic>>> getImageByName(String name) async {
    final db = await DatabaseLocal.db();
    return db.query('images', where: "name = ?", whereArgs: [name], limit: 1);
  }

  static addImage(ParamImage data) async {
    final db = await DatabaseLocal.db();
    await db.insert(
      'images',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static deleteResult(String name) async {
    final db = await DatabaseLocal.db();
    try {
      await db.delete("results", where: "name = ?", whereArgs: [name]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteImage(String name) async {
    final db = await DatabaseLocal.db();
    try {
      await db.delete("images", where: "name = ?", whereArgs: [name]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}

class FileModel {
  static resize(String path, int width, int height) async {
    _readFileByte(path).then((data) async {
      IMG.Image? img = IMG.decodeImage(data);
      IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
      Uint8List resizedImg = Uint8List.fromList(IMG.encodePng(resized));
      await File(path).writeAsBytes(resizedImg).then((_) {
        return true;
      });
    });
  }

  static Future<Uint8List> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = File.fromUri(myUri);
    Uint8List bytes = Uint8List(0);
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:$onError');
    });
    return bytes;
  }

  static Future<void> unzipFile(String pathin, String folder) async {
    final compressedFile = File(pathin);
    final bytes = await compressedFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    await compressedFile.delete();

    var appDocDir = await getApplicationDocumentsDirectory();
    String path = "${appDocDir.path}$folder";
    Map<String, String> map = {};

    if (!File(path).existsSync()) {
      await Directory(path).create();
    }

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$path/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('$path/$filename').createSync(recursive: true);
      }
    }
  }

  static Future<void> setupDownload() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    var path = "${appDocDir.path}/assets/models";
    Map<String, String> map = {};

    if (!File(path).existsSync()) {
      await Directory(path).create();
    }
    for (FileSystemEntity item in io.Directory(path).listSync()) {
      if (item.path.contains('?')) {
        String newName = (item.path.split("%2F").last).split("?").first;
        await item.rename("$path/$newName.zip");
      }
    }
  }

  static getFileModel() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    var path = "${appDocDir.path}/assets/models";
    Map<String, String> map = {};

    if (!File(path).existsSync()) {
      await Directory(path).create();
    }
    for (FileSystemEntity item in io.Directory(path).listSync()) {
      if (item.path.contains('?')) {
        String newName = (item.path.split("%2F").last).split("?").first;
        // item.rename("$path/$newName.zip");
      }

      String key = (item.path.split("/").last).split(".").first;

      map.addAll({key: item.path});
    }

    return map;
  }

  static getImages() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    var folder = "${appDocDir.path}/assets/images";

    if (!await Directory(folder).exists()) {
      await Directory(folder).create(recursive: true);
    }

    List<String> paths = [];
    for (FileSystemEntity item in io.Directory(folder).listSync()) {
      paths.add(item.path);
    }
    Map<String, String> images = {};
    for (int i = 0; i < paths.length; i = i + 2) {
      images.addAll({paths[i]: paths[i + 1]});
    }
    return images;
  }

  static deleteImage(File file) async {
    if (File(file.path).existsSync()) {
      await file.delete();
    }
  }

  static deleteImageFromPath(String path) async {
    File file = File(path);
    deleteImage(file);
  }

  static pathTflite(String path) {
    String name = path.split('/').last;
    return "$path/${name}_tflite.tflite";
  }

  static pathYaml(String path) {
    String name = path.split('/').last;
    return "$path/${name}_yaml.yaml";
  }

  static deleteModel(String path) async {
    if (path.contains(".zip")) {
      path = path.split(".zip").first;
    }
    if (!await Directory(path).exists()) {
      return;
    }
    final dir = Directory(path);
    dir.deleteSync(recursive: true);
  }

  static saveImage(String fileInput, Uint8List output) async {
    var appDocDir = await getApplicationDocumentsDirectory();
    var folder = "${appDocDir.path}/assets/images";

    if (!await Directory(folder).exists()) {
      await Directory(folder).create();
    }
    String name = (fileInput.split('/').last).split('.').first;

    // setup path file _in
    String newPath = "$folder/${name}_in.jpg";

    if (File(newPath).existsSync()) return true;
    // create file _in from fileInput
    File(fileInput).copy(newPath);

    // setup path file _in
    String out = "$folder/${name}_out.jpg";

    // create file _out from output
    File fileOut = await File(out).create();
    fileOut.writeAsBytesSync(output);

    //return true if create successfull file _out
    return out;
  }
}

class FirebasePath {
  static Reference getStorageOutput() {
    return FirebaseStorage.instance.ref('output');
  }

  static Reference getModelsStorage() {
    return FirebaseStorage.instance.ref('models');
  }

  static DatabaseReference getModelsRealtime() {
    return FirebaseDatabase.instance.ref('models');
  }

  static Reference getStorageInput() {
    return FirebaseStorage.instance.ref('input');
  }

  static DatabaseReference getRealtimeOutput() {
    return FirebaseDatabase.instance.ref('output');
  }

  static DatabaseReference getRealtimeInput() {
    return FirebaseDatabase.instance.ref('input');
  }
}
