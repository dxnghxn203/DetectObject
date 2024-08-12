import 'package:flutter/material.dart';

class ItemOption extends StatefulWidget {
  final String name;
  bool state = false;
  ItemOption(
      {super.key, required this.name, required this.state, this.chooseModel});
  void Function(String model)? chooseModel;
  @override
  State<ItemOption> createState() => _ItemOptionState();
}

class _ItemOptionState extends State<ItemOption> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width * .60,
        child: MaterialButton(
          onPressed: () {
            if (!widget.state) {
              setState(() {
                widget.chooseModel!(widget.name);
                widget.state = true;
              });
            }
          },
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: _buildContext(),
        ),
      ),
    );
  }

  _buildContext() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.name,
              style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold),
            ),
          ),
          if (widget.state) ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.check_circle_outlined,
                color: Colors.green,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
