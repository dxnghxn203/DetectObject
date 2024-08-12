import 'package:camera/camera.dart';
import 'package:camera_app/pages/predict/predict_page.dart';
import 'package:camera_app/pages/project/project_page.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

import '../datasets/dataset_page.dart';

class MenuMain extends StatefulWidget {
  final List<CameraDescription> camera;
  const MenuMain({super.key, required this.camera});

  @override
  State<MenuMain> createState() => _MenuMainState();
}

class _MenuMainState extends State<MenuMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _tab = "Datasets";
  List<String> labels = ["Predict", "Project", "Datasets", "Abouts"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          PredictPage(camera: widget.camera),
          const ProjectPage(),
          const DatasetPage(),
          const Center(child: Text('About Page')),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        labels: labels,
        initialSelectedTab: _tab,
        tabIconColor: Colors.grey,
        tabSelectedColor: const Color.fromARGB(255, 13, 44, 199),
        onTabItemSelected: (int value) {
          setState(() {
            _tabController.index = value;
            _tab = labels[value];
          });
        },
        icons: const [
          Icons.phone_android,
          Icons.folder,
          Icons.image,
          Icons.info_outline
        ],
        textStyle: const TextStyle(color: Color.fromARGB(255, 13, 44, 199)),
      ),
    );
  }
}
