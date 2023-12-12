import 'package:flutter/material.dart';

class SourceButton extends StatelessWidget {
  const SourceButton(
      {super.key,
      required this.icon,
      required this.semantic,
      required this.label,
      required this.onPressed});

  final VoidCallback onPressed;
  final IconData icon;
  final String semantic;
  final String label;

  @override
  Widget build(BuildContext context) {
    return
        // height: 80,
        // width: 240,
        ElevatedButton.icon(
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(240, 80)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ))),
      label: FittedBox(
        // fit: BoxFit.cov,
        child: Text(
          label,
          style: const TextStyle(fontSize: 30.0),
        ),
      ),

      // Text(label, style: const TextStyle(fontSize: 20)),
      icon: Icon(
        icon,
        size: 50.0,
        semanticLabel: semantic,
      ),
      onPressed: () async {
        onPressed();
      },
      // )
    );
  }
}
