import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'settings_change_page.dart';
import 'result_page.dart';
import 'helper_page.dart';
import 'custom_title_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.img}) : super(key: key);
  final String img;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int res = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const CustomTitleAppBar(text: 'Настройка параметров'),

          // title: const Text('Настройка параметров'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelperPage()));
                },
                icon: const Icon(Icons.help))
          ],
        ),
        // bottomNavigationBar: CustomBottomNavBar(
        //   bottomAppBar: BottomAppBar(
        //     shape: const CircularNotchedRectangle(),
        //     child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           TextButton.icon(
        //             label: const Text(
        //               "Настройки",
        //               // style: TextStyle(
        //               //     color: Colors.black, fontWeight: FontWeight.bold)
        //             ),
        //             icon: const Icon(Icons.settings),
        //             onPressed: () {
        //               Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                       builder: (context) => SettingsChangePage(
        //                           img: widget.img, isFromResultPage: false)));
        //             },
        //           ),
        //         ]),
        //   ),
        // ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                  height: 500,
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: PhotoView(
                    backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor),
                    imageProvider: FileImage(File(widget.img)),
                  )),
              const Spacer()
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Wrap(direction: Axis.vertical, children: <Widget>[
          Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: FloatingActionButton(
                  // label: Text(""),
                  heroTag: null,
                  foregroundColor:
                      !(Theme.of(context).brightness == Brightness.dark)
                          ? Colors.black
                          : Colors.white,
                  backgroundColor:
                      !(Theme.of(context).brightness == Brightness.dark)
                          ? Colors.amber
                          : Colors.grey[800],
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsChangePage(
                                img: widget.img, isFromResultPage: false)));
                  },
                  // backgroundColor: const Color.fromARGB(255, 125, 235, 128),
                  child: const Icon(Icons.settings))),
          FloatingActionButton(
              heroTag: null,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(image: widget.img),
                    ));
              },
              // backgroundColor: const Color.fromARGB(255, 125, 235, 128),
              child: const Icon(Icons.check))
        ]));
  }
}
