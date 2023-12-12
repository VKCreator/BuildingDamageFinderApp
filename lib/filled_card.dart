import 'package:flutter/material.dart';

class FilledCardExample extends StatelessWidget {
  const FilledCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 0,
              // color: !isDarkMode ? Colors.amber : null,
              child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'Для обнаружения разрушений межпанельных швов здания выберите изображение или сфотографируйте объект:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 23, fontStyle: FontStyle.italic))))),
    );
  }
}
