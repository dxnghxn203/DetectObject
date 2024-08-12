import 'package:flutter/material.dart';

class SliderCamera extends StatefulWidget {
  const SliderCamera({
    super.key,
    required this.current,
    required this.style,
    required this.onChanged,
  });

  @override
  State<SliderCamera> createState() => _SliderExposureState();
  final double current;
  final int style;
  final ValueChanged<double> onChanged;
}

class _SliderExposureState extends State<SliderCamera> {
  double current = 0.00;
  double min = 0.00;
  double max = 1.00;

  @override
  void initState() {
    super.initState();
    current = widget.current;
  }

  // ignore: non_constant_identifier_names
  String get_context() {
    String context = "";
    switch (widget.style) {
      case 1:
        context = 'Number of items (max ${(current * 100).toStringAsFixed(0)})';
        break;
      case 2:
        context = '${current.toStringAsFixed(2)} IoU Threshold';
        break;
      default:
        context = '${current.toStringAsFixed(2)} Confidence Threshold';
        break;
    }
    return context;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text(
            get_context(),
            style: const TextStyle(
              color: Color.fromARGB(255, 6, 19, 81),
              fontSize: 16,
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 12.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
          ),
          child: Slider(
            thumbColor: Colors.white,
            activeColor: const Color.fromARGB(255, 13, 44, 199),
            value: current,
            min: min,
            max: max,
            onChanged: (value) {
              setState(() {
                current = value;
              });
              widget.onChanged(value);
            },
            label: current.toStringAsFixed(2),
          ),
        ),
      ],
    );
  }
}
