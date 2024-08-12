import 'dart:ui';

class BoxModel {
  final Rect rect;
  final String label;
  final double confidence;

  BoxModel({
    required this.confidence,
    required this.rect,
    required this.label,
  });

  static countItem(List<BoxModel> list) {
    Map<String, int> map = {};
    for (BoxModel box in list) {
      var item = map[box.label];
      if (item != null) {
        map[box.label] = map[box.label]! + 1;
      } else {
        map[box.label] = 1;
      }
    }
    return map;
  }
}
