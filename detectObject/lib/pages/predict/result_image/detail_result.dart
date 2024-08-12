import 'package:camera_app/models/box_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailResult extends StatefulWidget {
  final List<BoxModel> boxModels;
  const DetailResult({
    super.key,
    required this.boxModels,
  });

  @override
  State<DetailResult> createState() => _ResultImagePageState();
}

class _ResultImagePageState extends State<DetailResult> {
  _builDetailObject(box) {
    List<Widget> objects = [];
    int counter = 0;
    for (var entry in BoxModel.countItem(box).entries) {
      counter += 1;
      objects.add(
        Row(
          children: [
            Text.rich(
              TextSpan(
                text: '   ${entry.key}: ',
                style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 6, 19, 81)),
                children: [
                  TextSpan(
                    text: '${entry.value}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 7, 46, 239)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    objects.add(
      const Divider(
        color: Colors.black26,
        thickness: 1,
        endIndent: 5,
        indent: 5,
      ),
    );
    objects.add(Row(
      children: [
        Text.rich(
          TextSpan(
            text: ' Total object: ',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 5, 7, 18)),
            children: [
              TextSpan(
                text: '$counter',
                style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 28, 14, 225)),
              ),
            ],
          ),
        ),
      ],
    ));
    return Column(
      children: objects,
    );
  }

  _buildMoreResult() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: Colors.grey[300],
                thickness: 5,
                endIndent: MediaQuery.of(context).size.width / 3,
                indent: MediaQuery.of(context).size.width / 3,
              ),
              Text(
                '${widget.boxModels.length} item',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 6, 19, 81)),
              ),
              const Divider(
                color: Colors.black26,
                thickness: 1,
                endIndent: 5,
                indent: 5,
              ),
              const Row(
                children: [
                  Text(
                    " Detail",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 5, 7, 18)),
                  )
                ],
              ),
              _builDetailObject(widget.boxModels),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _builDetailObject(widget.boxModels);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              _buildMoreResult();
            },
            icon: const Icon(Icons.output_outlined)),
        Text.rich(
          TextSpan(
            text: ' Result: ',
            style: const TextStyle(
                fontSize: 20,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 6, 19, 81)),
            children: [
              TextSpan(
                text: '${widget.boxModels.length}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 6, 19, 81)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
