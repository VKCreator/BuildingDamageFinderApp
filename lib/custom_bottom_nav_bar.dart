import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.bottomAppBar,
  });

  final BottomAppBar bottomAppBar;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: !(Theme.of(context).brightness == Brightness.dark)
                  ? const Color.fromARGB(255, 144, 143, 143)
                  : Colors.black,
              blurRadius: 10,
            ),
          ],
        ),
        child: bottomAppBar);
  }
}
