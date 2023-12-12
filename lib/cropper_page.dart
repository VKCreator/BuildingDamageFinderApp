import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:marquee/marquee.dart';

import 'settings_page.dart';
import 'helper_page.dart';
import 'custom_title_app_bar.dart';

class CropperPage extends StatelessWidget {
  final String imagePath;

  const CropperPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const CustomTitleAppBar(text: 'Просмотр изображения'),
// const Text('Просмотр изображения'),
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
        //     bottomAppBar: BottomAppBar(
        //   // shape: const CircularNotchedRectangle(),
        //   child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: <Widget>[
        //         ElevatedButton.icon(
        //           label: const Text(
        //             "Обрезка",
        //             // style: TextStyle(
        //             //     color: Colors.black, fontWeight: FontWeight.bold)
        //           ),
        //           icon: const Icon(Icons.crop),
        //           onPressed: () async {
        //             CroppedFile? cropped = await ImageCropper()
        //                 .cropImage(sourcePath: imagePath, aspectRatioPresets: [
        //               CropAspectRatioPreset.square,
        //               CropAspectRatioPreset.ratio3x2,
        //               CropAspectRatioPreset.original,
        //               CropAspectRatioPreset.ratio4x3,
        //               CropAspectRatioPreset.ratio16x9
        //             ], uiSettings: [
        //               AndroidUiSettings(
        //                   // hideBottomControls: true,
        //                   // backgroundColor: Colors.white,
        //                   // toolbarColor:
        //                   //     isDarkMode ? Colors.teal[300] : Colors.amber,
        //                   activeControlsWidgetColor:
        //                       (Theme.of(context).brightness == Brightness.dark)
        //                           ? Colors.white
        //                           : Colors.black,
        //                   // toolbarWidgetColor: Colors.red,
        //                   toolbarTitle: 'Режим обрезки',
        //                   // cropGridColor:
        //                   //     isDarkMode ? Colors.teal[500] : Colors.amber,
        //                   initAspectRatio: CropAspectRatioPreset.original,
        //                   lockAspectRatio: false)
        //             ]);

        //             if (cropped != null) {
        //               if (!context.mounted) return;
        //               Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                       builder: (context) => SettingsPage(
        //                             img: cropped.path,
        //                           )));
        //             }
        //           },
        //         ),
        //       ]),
        // )),
        body: Column(children: [
          Expanded(
            child: SingleChildScrollView(
                child: Column(
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
                      imageProvider: FileImage(File(imagePath)),
                    )),
              ],
            )),
          ),
        ]),
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
                  onPressed: () async {
                    CroppedFile? cropped = await ImageCropper()
                        .cropImage(sourcePath: imagePath, aspectRatioPresets: [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9
                    ], uiSettings: [
                      AndroidUiSettings(
                          // hideBottomControls: true,
                          // backgroundColor: Colors.white,
                          // toolbarColor:
                          //     (Theme.of(context).brightness == Brightness.dark)
                          //         ? Colors.grey
                          //         : Colors.amber,
                          // cropFrameColor:
                          //     (Theme.of(context).brightness ==
                          //             Brightness.dark)
                          //         ? Colors.teal
                          //         : Colors.white,
                          activeControlsWidgetColor:
                              !(Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.black
                                  : const Color(0xff13f0db),

                          // toolbarWidgetColor: Colors.white,
                          toolbarTitle: 'Режим обрезки',
                          // cropGridColor:
                          //     isDarkMode ? Colors.teal[500] : Colors.amber,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false)
                    ]);

                    if (cropped != null) {
                      if (!context.mounted) return;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                    img: cropped.path,
                                  )));
                    }
                  },
                  child: const Icon(Icons.crop))),
          Container(
              margin: const EdgeInsets.symmetric(),
              child: FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage(
                                  img: imagePath,
                                )));
                  },
                  child: const Icon(Icons.check)))
        ]));
  }
}
