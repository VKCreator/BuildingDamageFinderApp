// import 'dart:async';
// import 'dart:isolate';
// import 'dart:io';
// import 'dart:ffi';

// import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
// // import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:share/share.dart';
// import 'package:path/path.dart' as pathPackage;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:ffi/ffi.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_spinbox/material.dart';
// import 'package:gallery_saver/gallery_saver.dart';
// import 'package:flutter/services.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_v3/image_v3.dart' as imageConverter;
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:simple_permissions/simple_permissions.dart';

// import 'start_page.dart';

// // For temporary storage of images
// late Directory tempDir;

// String tempPathSeams = '${tempDir.path}/allSeams.jpg';
// String tempPathCrack = '${tempDir.path}/crack.jpg';
// String tempPathSource = '${tempDir.path}/source.jpg';

// // Data for C++ proccesing
// class ProcessImageArguments {
//   final String inputPath;
//   final String tempPathSource;
//   final String tempPathSeams;
//   final String tempPathCrack;
//   int res; // percent
//   final dynamic port;
//   ParamsDefault params;

//   ProcessImageArguments(this.inputPath, this.tempPathSource, this.tempPathSeams,
//       this.tempPathCrack, this.res, this.params, this.port);
// }

// // FFI C++
// final dylib = Platform.isAndroid
//     ? DynamicLibrary.open("libOpenCV_ffi.so")
//     : DynamicLibrary.process();

// final _processImage = dylib.lookupFunction<
//     Int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
//         Pointer<ResParams>),
//     int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
//         Pointer<ResParams>)>('buildHelper');

// late Pointer<ResParams> p;

// void processImage(ProcessImageArguments args) {
//   Pointer<ResParams> p = calloc<ResParams>();

//   p.ref.contrast = args.params.contrast;
//   p.ref.contrastDamage = args.params.contrastDamage;
//   p.ref.blockSizeThreshold = args.params.blockSizeThreshold;
//   p.ref.gaussianBlockSize = args.params.gaussianBlockSize;
//   p.ref.epsilonHorizontal = args.params.epsilonHorizontal;
//   p.ref.epsilonVertical = args.params.epsilonVertical;
//   p.ref.minLengthLine = args.params.minLengthLine;
//   p.ref.minCountHorizontalLine = args.params.minCountHorizontalLine;
//   p.ref.minCountVerticalLine = args.params.minCountVerticalLine;

//   args.port.send(_processImage(
//       args.inputPath.toNativeUtf8(),
//       args.tempPathSource.toNativeUtf8(),
//       args.tempPathSeams.toNativeUtf8(),
//       args.tempPathCrack.toNativeUtf8(),
//       p));

//   calloc.free(p);
// }

// // Start an app
// void main() {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

//   getTemporaryDirectory().then((dir) => tempDir = dir);

//   // getApplicationDocumentsDirectory().then((dir) => tempDir = dir);
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
//   // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//   //         statusBarBrightness: Brightness.light) // Or Brightness.dark
//   //     );
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
//       .then((_) => {runApp(const MyApp())});
//   // runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BuildingDamageFinderApp',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//           floatingActionButtonTheme: const FloatingActionButtonThemeData(
//             backgroundColor: Color.fromARGB(255, 125, 235, 128),
//             foregroundColor: Colors.black,
//           ),
//           brightness: Brightness.light,
//           primarySwatch: Colors.amber,
//           bottomAppBarTheme: const BottomAppBarTheme(
//             color: Colors.amber,
//             elevation: 4,
//             height: 50.0,
//             // shape: CircularNotchedRectangle(),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(Colors.amber))),
//           textButtonTheme: TextButtonThemeData(
//               style: ButtonStyle(
//                   iconColor: MaterialStateProperty.all(Colors.black),
//                   foregroundColor: MaterialStateProperty.all(Colors.black))),
//           switchTheme: SwitchThemeData(
//             thumbColor: MaterialStateProperty.resolveWith<Color>(
//                 (Set<MaterialState> states) {
//               if (states.contains(MaterialState.selected)) {
//                 return Colors.amber;
//               }
//               return Colors.white;
//             }),
//           ),
//           cardTheme: const CardTheme(color: Colors.amber)),
//       darkTheme: ThemeData(
//         useMaterial3: false,
//         brightness: Brightness.dark,
//         elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all(Colors.teal[300]))),
//         bottomAppBarTheme: const BottomAppBarTheme(
//           height: 50.0,
//           // shape: CircularNotchedRectangle(),
//         ),
//         textButtonTheme: TextButtonThemeData(
//             style: ButtonStyle(
//                 iconColor: MaterialStateProperty.all(Colors.white),
//                 foregroundColor: MaterialStateProperty.all(Colors.white))),
//         switchTheme: SwitchThemeData(),
//         // inputDecorationTheme: InputDecorationTheme(
//         //   counterStyle: TextStyle(color: Colors.blue),
//         //   labelStyle: TextStyle(color: Colors.blue),
//         //   border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
//         //   focusedBorder: OutlineInputBorder(
//         //       borderSide: BorderSide(width: 1, color: Colors.teal[300]!)),
//         //   // activeIndicatorBorder: BorderSide(color: Colors.teal[300]!)
//         // ),
//         // textSelectionTheme: TextSelectionThemeData(
//         //     selectionColor: Colors.teal[300]!,
//         //     cursorColor: Colors.teal[300]!,
//         //     selectionHandleColor: Colors.teal[300]!),
//       ),
//       themeMode: ThemeMode.system,
//       home: StartPage(),
//     );
//   }
// }

// // class StartPage extends StatelessWidget {
// //   final ImagePicker _picker = ImagePicker();

// //   StartPage({super.key}) {
// //     readSettings();

// //     FlutterNativeSplash.remove();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('BuildingDamageFinderApp'),
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 children: [
// //                   const SizedBox(
// //                     height: 50,
// //                   ),
// //                   const FilledCardExample(),
// //                   const SizedBox(
// //                     height: 30,
// //                   ),
// //                   SourceButton(
// //                       icon: Icons.image,
// //                       semantic: "Открыть галерею",
// //                       label: "Галерея",
// //                       onPressed: () async {
// //                         final imageFile = await _picker.pickImage(
// //                             source: ImageSource.gallery);

// //                         final imagePath = imageFile?.path ?? "none";

// //                         if (imageFile == null) return;

// //                         if (!context.mounted) return;
// //                         Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     CropperPage(imagePath: imagePath)));
// //                       }),
// //                   const SizedBox(
// //                     height: 30,
// //                   ),
// //                   SourceButton(
// //                       icon: Icons.camera,
// //                       semantic: "Сделать фото",
// //                       label: "Камера",
// //                       onPressed: () async {
// //                         // запрет на доступ к камере
// //                         late dynamic image;
// //                         try {
// //                           image = await _picker.pickImage(
// //                               source: ImageSource.camera);
// //                         } on PlatformException {
// //                           Fluttertoast.showToast(
// //                               msg: "Разрешите приложению доступ к камере.",
// //                               toastLength: Toast.LENGTH_SHORT,
// //                               gravity: ToastGravity.SNACKBAR,
// //                               timeInSecForIosWeb: 1,
// //                               backgroundColor: Colors.red[200],
// //                               textColor: Colors.white,
// //                               fontSize: 12.0);
// //                           return;
// //                         }

// //                         final imagePath = image?.path ?? "none";

// //                         if (image == null) return;

// //                         if (!context.mounted) return;
// //                         Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     CropperPage(imagePath: imagePath)));
// //                       }),
// //                   const SizedBox(
// //                     height: 100,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class SourceButton extends StatelessWidget {
// //   const SourceButton(
// //       {super.key,
// //       required this.icon,
// //       required this.semantic,
// //       required this.label,
// //       required this.onPressed});

// //   final VoidCallback onPressed;
// //   final IconData icon;
// //   final String semantic;
// //   final String label;

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //         height: 80,
// //         width: 200,
// //         child: ElevatedButton.icon(
// //           style: ButtonStyle(
// //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
// //                   RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(18.0),
// //           ))),
// //           label: Text(label, style: const TextStyle(fontSize: 20)),
// //           icon: Icon(
// //             icon,
// //             size: 50.0,
// //             semanticLabel: semantic,
// //           ),
// //           onPressed: () async {
// //             onPressed();
// //           },
// //         ));
// //   }
// // }

// // class FilledCardExample extends StatelessWidget {
// //   const FilledCardExample({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Card(
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(15.0),
// //               ),
// //               elevation: 0,
// //               // color: !isDarkMode ? Colors.amber : null,
// //               child: const Padding(
// //                   padding: EdgeInsets.all(20),
// //                   child: Text(
// //                       'Для обнаружения разрушений межпанельных швов здания выберите изображение или сфотографируйте объект:',
// //                       textAlign: TextAlign.center,
// //                       style: TextStyle(
// //                           fontSize: 20, fontStyle: FontStyle.italic))))),
// //     );
// //   }
// // }

// class CropperPage extends StatelessWidget {
//   final String imagePath;

//   const CropperPage({super.key, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text('Просмотр изображения')),
//         // bottomNavigationBar: CustomBottomNavBar(
//         //     bottomAppBar: BottomAppBar(
//         //   // shape: const CircularNotchedRectangle(),
//         //   child: Row(
//         //       mainAxisAlignment: MainAxisAlignment.center,
//         //       children: <Widget>[
//         //         ElevatedButton.icon(
//         //           label: const Text(
//         //             "Обрезка",
//         //             // style: TextStyle(
//         //             //     color: Colors.black, fontWeight: FontWeight.bold)
//         //           ),
//         //           icon: const Icon(Icons.crop),
//         //           onPressed: () async {
//         //             CroppedFile? cropped = await ImageCropper()
//         //                 .cropImage(sourcePath: imagePath, aspectRatioPresets: [
//         //               CropAspectRatioPreset.square,
//         //               CropAspectRatioPreset.ratio3x2,
//         //               CropAspectRatioPreset.original,
//         //               CropAspectRatioPreset.ratio4x3,
//         //               CropAspectRatioPreset.ratio16x9
//         //             ], uiSettings: [
//         //               AndroidUiSettings(
//         //                   // hideBottomControls: true,
//         //                   // backgroundColor: Colors.white,
//         //                   // toolbarColor:
//         //                   //     isDarkMode ? Colors.teal[300] : Colors.amber,
//         //                   activeControlsWidgetColor:
//         //                       (Theme.of(context).brightness == Brightness.dark)
//         //                           ? Colors.white
//         //                           : Colors.black,
//         //                   // toolbarWidgetColor: Colors.red,
//         //                   toolbarTitle: 'Режим обрезки',
//         //                   // cropGridColor:
//         //                   //     isDarkMode ? Colors.teal[500] : Colors.amber,
//         //                   initAspectRatio: CropAspectRatioPreset.original,
//         //                   lockAspectRatio: false)
//         //             ]);

//         //             if (cropped != null) {
//         //               if (!context.mounted) return;
//         //               Navigator.push(
//         //                   context,
//         //                   MaterialPageRoute(
//         //                       builder: (context) => SettingsPage(
//         //                             img: cropped.path,
//         //                           )));
//         //             }
//         //           },
//         //         ),
//         //       ]),
//         // )),
//         body: Column(children: [
//           Expanded(
//             child: SingleChildScrollView(
//                 child: Column(
//               children: [
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                     height: 500,
//                     alignment: Alignment.center,
//                     width: double.infinity,
//                     child: PhotoView(
//                       backgroundDecoration: BoxDecoration(
//                           color: Theme.of(context).scaffoldBackgroundColor),
//                       imageProvider: FileImage(File(imagePath)),
//                     )),
//               ],
//             )),
//           ),
//         ]),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         floatingActionButton: Wrap(direction: Axis.vertical, children: <Widget>[
//           Container(
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               child: FloatingActionButton(
//                   // label: Text(""),
//                   heroTag: null,
//                   foregroundColor:
//                       !(Theme.of(context).brightness == Brightness.dark)
//                           ? Colors.black
//                           : Colors.white,
//                   backgroundColor:
//                       !(Theme.of(context).brightness == Brightness.dark)
//                           ? Colors.amber
//                           : Colors.grey[800],
//                   onPressed: () async {
//                     CroppedFile? cropped = await ImageCropper()
//                         .cropImage(sourcePath: imagePath, aspectRatioPresets: [
//                       CropAspectRatioPreset.square,
//                       CropAspectRatioPreset.ratio3x2,
//                       CropAspectRatioPreset.original,
//                       CropAspectRatioPreset.ratio4x3,
//                       CropAspectRatioPreset.ratio16x9
//                     ], uiSettings: [
//                       AndroidUiSettings(
//                           // hideBottomControls: true,
//                           // backgroundColor: Colors.white,
//                           // toolbarColor:
//                           //     isDarkMode ? Colors.teal[300] : Colors.amber,
//                           // cropFrameColor:
//                           //     (Theme.of(context).brightness ==
//                           //             Brightness.dark)
//                           //         ? Colors.teal
//                           //         : Colors.white,
//                           activeControlsWidgetColor:
//                               (Theme.of(context).brightness == Brightness.dark)
//                                   ? Colors.white
//                                   : Colors.black,
//                           // toolbarWidgetColor: Colors.red,
//                           toolbarTitle: 'Режим обрезки',
//                           // cropGridColor:
//                           //     isDarkMode ? Colors.teal[500] : Colors.amber,
//                           initAspectRatio: CropAspectRatioPreset.original,
//                           lockAspectRatio: false)
//                     ]);

//                     if (cropped != null) {
//                       if (!context.mounted) return;
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SettingsPage(
//                                     img: cropped.path,
//                                   )));
//                     }
//                   },
//                   child: const Icon(Icons.crop))),
//           Container(
//               margin: const EdgeInsets.symmetric(),
//               child: FloatingActionButton(
//                   heroTag: null,
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SettingsPage(
//                                   img: imagePath,
//                                 )));
//                   },
//                   child: const Icon(Icons.check)))
//         ]));
//   }
// }

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key, required this.img}) : super(key: key);
//   final String img;

//   @override
//   SettingsPageState createState() => SettingsPageState();
// }

// class SettingsPageState extends State<SettingsPage> {
//   int res = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(title: const Text('Настройка параметров')),
//         // bottomNavigationBar: CustomBottomNavBar(
//         //   bottomAppBar: BottomAppBar(
//         //     shape: const CircularNotchedRectangle(),
//         //     child: Row(
//         //         mainAxisAlignment: MainAxisAlignment.center,
//         //         children: <Widget>[
//         //           TextButton.icon(
//         //             label: const Text(
//         //               "Настройки",
//         //               // style: TextStyle(
//         //               //     color: Colors.black, fontWeight: FontWeight.bold)
//         //             ),
//         //             icon: const Icon(Icons.settings),
//         //             onPressed: () {
//         //               Navigator.push(
//         //                   context,
//         //                   MaterialPageRoute(
//         //                       builder: (context) => SettingsChangePage(
//         //                           img: widget.img, isFromResultPage: false)));
//         //             },
//         //           ),
//         //         ]),
//         //   ),
//         // ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(
//                 height: 10,
//               ),
//               Container(
//                   height: 500,
//                   alignment: Alignment.center,
//                   width: double.infinity,
//                   child: PhotoView(
//                     backgroundDecoration: BoxDecoration(
//                         color: Theme.of(context).scaffoldBackgroundColor),
//                     imageProvider: FileImage(File(widget.img)),
//                   )),
//               const Spacer()
//             ],
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         floatingActionButton: Wrap(direction: Axis.vertical, children: <Widget>[
//           Container(
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               child: FloatingActionButton(
//                   // label: Text(""),
//                   heroTag: null,
//                   foregroundColor:
//                       !(Theme.of(context).brightness == Brightness.dark)
//                           ? Colors.black
//                           : Colors.white,
//                   backgroundColor:
//                       !(Theme.of(context).brightness == Brightness.dark)
//                           ? Colors.amber
//                           : Colors.grey[800],
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SettingsChangePage(
//                                 img: widget.img, isFromResultPage: false)));
//                   },
//                   // backgroundColor: const Color.fromARGB(255, 125, 235, 128),
//                   child: const Icon(Icons.settings))),
//           Container(
//               margin: const EdgeInsets.symmetric(),
//               child: FloatingActionButton(
//                   heroTag: null,
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ResultPage(image: widget.img),
//                         ));
//                   },
//                   // backgroundColor: const Color.fromARGB(255, 125, 235, 128),
//                   child: const Icon(Icons.check)))
//         ]));
//   }
// }

// class CustomBottomNavBar extends StatelessWidget {
//   const CustomBottomNavBar({
//     super.key,
//     required this.bottomAppBar,
//   });

//   final BottomAppBar bottomAppBar;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//               color: !(Theme.of(context).brightness == Brightness.dark)
//                   ? const Color.fromARGB(255, 144, 143, 143)
//                   : Colors.black,
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: bottomAppBar);
//   }
// }

// final ParamsDefault params = ParamsDefault();
// late SharedPreferences paramsData;

// class SettingsChangePage extends StatefulWidget {
//   const SettingsChangePage(
//       {Key? key, required this.img, required this.isFromResultPage})
//       : super(key: key);

//   final String img;
//   final bool isFromResultPage;

//   @override
//   SettingsChangePageState createState() => SettingsChangePageState();
// }

// final class ParamsDefault {
//   double contrast = 1;
//   double contrastDamage = 4;
//   int blockSizeThreshold = 11;
//   int gaussianBlockSize = 11;
//   int minLengthLine = 100;
//   int epsilonVertical = 20;
//   int epsilonHorizontal = 20;
//   int minCountVerticalLine = 10;
//   int minCountHorizontalLine = 20;
//   bool isNotSwipeTabView = true;
// }

// class SettingsChangePageState extends State<SettingsChangePage> {
//   @override
//   void initState() {
//     super.initState();
//     checkParams();
//   }

//   void checkParams() async {
//     readSettings();
//     // !!!!
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.close)),
//           title: const FittedBox(
//             alignment: Alignment.centerLeft,
//             fit: BoxFit.contain,
//             child: AutoSizeText(
//               'Режим настройки параметров',
//               maxLines: 1,
//             ),
//           ),
//           // const Text('Режим настройки параметров',
//           // style: TextStyle(fontSize: 17)),
//           actions: [
//             IconButton(
//               onPressed: () async {
//                 paramsData = await SharedPreferences.getInstance();

//                 paramsData.setDouble('contrast', params.contrast);
//                 paramsData.setDouble('contrastDamage', params.contrastDamage);
//                 paramsData.setInt(
//                     'blockSizeThreshold', params.blockSizeThreshold);
//                 paramsData.setInt(
//                     'gaussianBlockSize', params.gaussianBlockSize);
//                 paramsData.setInt('minLengthLine', params.minLengthLine);
//                 paramsData.setInt('epsilonVertical', params.epsilonVertical);
//                 paramsData.setInt(
//                     'epsilonHorizontal', params.epsilonHorizontal);
//                 paramsData.setInt(
//                     'minCountVerticalLine', params.minCountVerticalLine);
//                 paramsData.setInt(
//                     'minCountHorizontalLine', params.minCountHorizontalLine);

//                 // params.isNotSwipeTabView = selected;
//                 paramsData.setBool(
//                     'isNotSwipeTabView', params.isNotSwipeTabView);

//                 if (!context.mounted) return;
//                 if (widget.isFromResultPage) {
//                   Navigator.pop(context);
//                   Navigator.pop(context);

//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ResultPage(image: widget.img),
//                       ));
//                 } else {
//                   Navigator.pop(context);
//                 }
//               },
//               icon: const Icon(Icons.check),
//             ),
//           ],
//           // leading: BackButton(onPressed: () {
//           //   Navigator.pop(context);
//           // })
//         ),
//         body: Scrollbar(
//           child: ListView(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.contrast,
//                   min: 1,
//                   max: 15,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Контраст изображения (исходное)',
//                     helperText: "По умолчанию: 1",
//                   ),
//                   onChanged: (value) {
//                     params.contrast = value;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.contrastDamage,
//                   min: 4,
//                   max: 15,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Контраст изображения (разрушения)',
//                     helperText: "По умолчанию: 4",
//                   ),
//                   onChanged: (value) {
//                     params.contrastDamage = value;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.blockSizeThreshold.toDouble(),
//                   min: 5,
//                   max: 15,
//                   step: 2,
//                   decoration: const InputDecoration(
//                     labelText: 'Размер окрестности для порогового значения',
//                     helperText: "По умолчанию: 11",
//                   ),
//                   onChanged: (value) {
//                     params.blockSizeThreshold = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.gaussianBlockSize.toDouble(),
//                   min: 9,
//                   max: 25,
//                   step: 2,
//                   decoration: const InputDecoration(
//                     labelText: 'Гауссовский размер ядра',
//                     helperText: "По умолчанию: 11",
//                   ),
//                   onChanged: (value) {
//                     params.gaussianBlockSize = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.minLengthLine.toDouble(),
//                   min: 50,
//                   max: 200,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Минимальный размер линии',
//                     helperText: "По умолчанию: 100",
//                   ),
//                   onChanged: (value) {
//                     params.minLengthLine = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.epsilonVertical.toDouble(),
//                   min: 15,
//                   max: 100,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Окрестность вертикального шва',
//                     helperText: "По умолчанию: 20",
//                   ),
//                   onChanged: (value) {
//                     params.epsilonVertical = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.epsilonHorizontal.toDouble(),
//                   min: 15,
//                   max: 100,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Окрестность горизонтального шва',
//                     helperText: "По умолчанию: 20",
//                   ),
//                   onChanged: (value) {
//                     params.epsilonHorizontal = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.minCountVerticalLine.toDouble(),
//                   min: 1,
//                   max: 100,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Мин. количество вертикальных линий в шве',
//                     helperText: "По умолчанию: 10",
//                   ),
//                   onChanged: (value) {
//                     params.minCountVerticalLine = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SpinBox(
//                   value: params.minCountHorizontalLine.toDouble(),
//                   min: 1,
//                   max: 100,
//                   step: 1,
//                   decoration: const InputDecoration(
//                     labelText: 'Мин. количество горизонтальных линий в шве',
//                     helperText: "По умолчанию: 20",
//                   ),
//                   onChanged: (value) {
//                     params.minCountHorizontalLine = value.toInt();
//                   },
//                 ),
//               ),
//               Padding(
//                   padding: const EdgeInsets.all(5),
//                   child: SwitchListTile(
//                     // activeColor: Colors.amber,
//                     title: const Text(
//                         'Отключить смахивание (swipe) в просмотре результатов'),
//                     value: params.isNotSwipeTabView,
//                     onChanged: (bool? value) {
//                       setState(() {
//                         params.isNotSwipeTabView = value!;
//                       });
//                     },
//                   )),
//             ],
//           ),
//         ));
//   }
// }

// base class ResParams extends Struct {
//   @Double()
//   external double contrast;
//   @Double()
//   external double contrastDamage;
//   @Int()
//   external int blockSizeThreshold;
//   @Int()
//   external int gaussianBlockSize;
//   @Int()
//   external int minLengthLine;
//   @Int()
//   external int epsilonVertical;
//   @Int()
//   external int epsilonHorizontal;
//   @Int()
//   external int minCountVerticalLine;
//   @Int()
//   external int minCountHorizontalLine;
// }

// class ResultPage extends StatefulWidget {
//   ResultPage({Key? key, required this.image}) : super(key: key);
//   final String image;
//   final dynamic port = ReceivePort();
//   late dynamic isolate = null;

//   @override
//   ResultPageState createState() => ResultPageState();
// }

// class ResultPageState extends State<ResultPage> {
//   bool _isLoading = true;
//   String selectedValue = ".jpg";
//   bool _validate = false;

//   late Image imgSeams = Image.asset('assets/img/default.jpg');
//   late Image imgCrack = Image.asset('assets/img/default.jpg');
//   late Image imgSource = Image.asset('assets/img/default.jpg');

//   late int res = 0;
//   late int ind = 1;

//   var imgName = TextEditingController();

//   List<DropdownMenuItem<String>> menuItems = [
//     const DropdownMenuItem(
//       value: ".jpg",
//       child: Text(".jpg"),
//     ),
//     // const DropdownMenuItem(value: ".png", child: Text(".png"))
//   ];

//   Future<void> takeImageAndProcess() async {
//     setState(() {
//       _isLoading = true;
//     });

//     // widget.port = ReceivePort();
//     final args = ProcessImageArguments(widget.image, tempPathSource,
//         tempPathSeams, tempPathCrack, 0, params, widget.port.sendPort);

//     // Spawning an isolate
//     widget.isolate = await Isolate.spawn<ProcessImageArguments>(
//       processImage,
//       args,
//       onError: widget.port.sendPort,
//       onExit: widget.port.sendPort,
//     );

//     // Listening for messages on port
//     widget.port.listen((_) {
//       res = _;
//       imgSource = Image.file(File(args.inputPath));
//       imgCrack = Image.file(key: UniqueKey(), File(args.tempPathCrack));
//       imgSeams = Image.file(key: UniqueKey(), File(args.tempPathSeams));

//       widget.port.close();
//       widget.isolate.kill();
//       _isLoading = false;

//       setState(() {});
//       imageCache.clear();
//       imageCache.clearLiveImages();
//     });
//   }

//   @override
//   void dispose() {
//     if (_isLoading) {
//       imageCache.clear();
//       imageCache.clearLiveImages();
//     }
//     widget.port.close();

//     if (widget.isolate != null) widget.isolate.kill();

//     imgName.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     takeImageAndProcess();

//     super.initState();
//   }

//   void showMessage(value) {
//     String mess;
//     MaterialColor color;

//     mess = "Изображение сохранено в галерее.";
//     color = Colors.green;
//     if (!value) {
//       mess = "Изображение не сохранено в галерее.";
//       color = Colors.red;
//     }

//     Fluttertoast.showToast(
//         msg: mess,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.SNACKBAR,
//         timeInSecForIosWeb: 1,
//         backgroundColor: color,
//         textColor: Colors.white,
//         fontSize: 14.0);
//   }

//   Future<bool?> _dialogBuilder(BuildContext context) {
//     return showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//             builder: (context, setStateSB) => AlertDialog(
//                   title: const Text('Сохранение изображения'),
//                   content: Row(children: [
//                     Expanded(
//                       child: TextField(
//                         autofocus: true,
//                         controller: imgName,
//                         maxLength: 25,
//                         decoration: InputDecoration(
//                           labelText: 'Название',
//                           errorText: _validate ? "Пустое поле" : null,
//                         ),
//                         onChanged: (value) {
//                           if (_validate) {
//                             setState(() {
//                               _validate = false;
//                             });
//                             setStateSB(() {}); // update UI inside Dialog
//                           }
//                         },
//                       ),
//                     ),
//                     // SizedBox(
//                     //   width: 8.0,
//                     // ),
//                     DropdownButtonHideUnderline(
//                       child: DropdownButton(
//                           onChanged: null,
//                           icon: Visibility(
//                               visible: false,
//                               child: Icon(Icons.arrow_downward)),
//                           value: selectedValue,
//                           // style: TextStyle(color: Colors.red),
//                           // onChanged: (String? newValue) {
//                           //   setState(() {
//                           //     selectedValue = newValue!;
//                           //   });
//                           //   setStateSB(() {}); // update UI inside Dialog
//                           // },
//                           items: menuItems),
//                     )
//                   ]),
//                   actions: <Widget>[
//                     IconButton(
//                       color: Colors.red,
//                       icon: const Icon(Icons.close_rounded),
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                     ),
//                     IconButton(
//                       color: Colors.green,
//                       icon: const Icon(Icons.check),
//                       onPressed: () {
//                         setState(() {
//                           _validate = imgName.text.isEmpty;
//                         });
//                         setStateSB(() {}); // update UI inside Dialog

//                         if (!_validate) Navigator.of(context).pop(true);
//                       },
//                     ),
//                   ],
//                 ));
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: _isLoading
//           ? AppBar(
//               title: const Text('Результаты обработки'),
//               automaticallyImplyLeading: !_isLoading,
//             )
//           : null,
//       floatingActionButton: !_isLoading
//           ? ExpandableFab(
//               type: ExpandableFabType.side,
//               openButtonBuilder: RotateFloatingActionButtonBuilder(
//                 child: const Icon(Icons.image),
//                 fabSize: ExpandableFabSize.regular,
//                 shape: const CircleBorder(),
//               ),
//               closeButtonBuilder: FloatingActionButtonBuilder(
//                 size: 56,
//                 builder: (BuildContext context, void Function()? onPressed,
//                     Animation<double> progress) {
//                   return FloatingActionButton(
//                     onPressed: onPressed,
//                     child: const Icon(Icons.close_outlined),
//                   );
//                 },
//               ),
//               children: [
//                 FloatingActionButton(
//                     heroTag: null,
//                     child: const Icon(Icons.save),
//                     onPressed: () async {
//                       String path = tempPathSource;
//                       switch (ind) {
//                         case 0:
//                           // path = widget.image;
//                           path = tempPathSource;
//                           imgName.text = "source";
//                           break;
//                         case 1:
//                           path = tempPathSeams;
//                           imgName.text = "allSeams";
//                           break;
//                         case 2:
//                           path = tempPathCrack;
//                           imgName.text = "crack";
//                           break;
//                       }

//                       bool? checkChoice = await _dialogBuilder(context);

//                       // print(checkChoice);
//                       // print(imgName.text);
//                       // print(selectedValue);
//                       // print(path);

//                       if (checkChoice == true) {
//                         // if (selectedValue == ".png") {
//                         // final image = imageConverter
//                         //     .decodeImage(File(path).readAsBytesSync())!;

//                         // final thumbnail = imageConverter.copyResize(image,
//                         //     width: image.width, height: image.height);

//                         // String dir = pathPackage.dirname(File(path).path);

//                         // // Save the thumbnail as a PNG.
//                         // File("test.png").writeAsBytesSync(
//                         //     imageConverter.encodePng(thumbnail));

//                         // print(File("test.png").path);
//                         // }
//                         try {
//                           String dir = pathPackage.dirname(File(path).path);
//                           String newPath = pathPackage.join(
//                               dir, imgName.text + selectedValue);

//                           if (newPath != path) File(path).renameSync(newPath);

//                           await GallerySaver.saveImage(newPath,
//                                   albumName: "BuildingDamageFinder")
//                               .then((value) {
//                             showMessage(value);

//                             if (newPath != path) {
//                               switch (ind) {
//                                 case 0:
//                                   File(newPath).renameSync(tempPathSource);

//                                   // tempPathSource = newPath;
//                                   break;
//                                 case 1:
//                                   File(newPath).renameSync(tempPathSeams);

//                                   // tempPathSeams = newPath;
//                                   // imgName.text = "allSeams";
//                                   break;
//                                 case 2:
//                                   File(newPath).renameSync(tempPathCrack);

//                                   // tempPathCrack = newPath;
//                                   // imgName.text = "crack";
//                                   break;
//                               }
//                             }
//                           });
//                         } catch (err) {
//                           Fluttertoast.showToast(
//                               msg: "Ошибка при сохранении",
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.SNACKBAR,
//                               timeInSecForIosWeb: 1,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                               fontSize: 14.0);
//                         }
//                       }
//                     }),
//                 FloatingActionButton(
//                   heroTag: null,
//                   child: const Icon(Icons.share),
//                   onPressed: () async {
//                     String path = widget.image;
//                     switch (ind) {
//                       case 0:
//                         path = tempPathSource;
//                         break;
//                       case 1:
//                         path = tempPathSeams;
//                         break;
//                       case 2:
//                         path = tempPathCrack;
//                         break;
//                     }
//                     await Share.shareFiles([path],
//                         text: 'Приложение «BuildingDamageFinder»');
//                   },
//                 ),
//               ],
//             )
//           : null,
//       floatingActionButtonLocation: ExpandableFab.location,
//       bottomNavigationBar: CustomBottomNavBar(
//           bottomAppBar: BottomAppBar(
//         padding: const EdgeInsets.all(10),
//         child: !_isLoading
//             ? FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.contain,
//                 child: AutoSizeText(
//                   'Процентная доля разрушений швов: $res%',
//                   maxLines: 1,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               )
//             : null,
//       )),
//       body: !_isLoading
//           ? DefaultTabController(
//               initialIndex: 1,
//               length: 3,
//               child: Builder(builder: (BuildContext context) {
//                 return Scaffold(
//                     // backgroundColor: Colors.transparent,
//                     appBar: AppBar(
//                       actions: [
//                         IconButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => SettingsChangePage(
//                                           img: widget.image,
//                                           isFromResultPage: true,
//                                         )));
//                           },
//                           icon: const Icon(Icons.settings),
//                         ),
//                       ],
//                       bottom: const TabBar(
//                         // isScrollable: true, // here
//                         tabs: [
//                           Tab(
//                               icon: Icon(Icons.image_outlined),
//                               child: Text('Исходное')),
//                           Tab(
//                               icon: Icon(Icons.image_search_outlined),
//                               child: Text('Швы')),
//                           Tab(
//                               icon: Icon(Icons.broken_image_outlined),
//                               child: Text('Дефекты')),
//                         ],
//                       ),
//                       title: const FittedBox(
//                         alignment: Alignment.centerLeft,
//                         fit: BoxFit.contain,
//                         child: AutoSizeText(
//                           'Результаты обработки',
//                           maxLines: 1,
//                         ),
//                       ),
//                     ),
//                     body: SafeArea(
//                         bottom: false,
//                         child: NotificationListener(
//                             onNotification: (scrollNotification) {
//                               if (scrollNotification is ScrollEndNotification) {
//                                 ind = DefaultTabController.of(context).index;
//                                 // print(ind);
//                               }
//                               return false;
//                             },
//                             child: Column(children: <Widget>[
//                               Expanded(
//                                 child: TabBarView(
//                                   physics: params.isNotSwipeTabView
//                                       ? const NeverScrollableScrollPhysics()
//                                       : null,
//                                   children: [
//                                     PhotoView(
//                                       imageProvider:
//                                           FileImage(File(widget.image)),
//                                       backgroundDecoration: BoxDecoration(
//                                           color: Theme.of(context)
//                                               .scaffoldBackgroundColor),
//                                     ),
//                                     // imgSource,
//                                     PhotoView(
//                                       imageProvider:
//                                           FileImage(File(tempPathSeams)),
//                                       backgroundDecoration: BoxDecoration(
//                                           color: Theme.of(context)
//                                               .scaffoldBackgroundColor),
//                                     ),
//                                     // imgSeams,
//                                     PhotoView(
//                                       imageProvider:
//                                           FileImage(File(tempPathCrack)),
//                                       backgroundDecoration: BoxDecoration(
//                                           color: Theme.of(context)
//                                               .scaffoldBackgroundColor),
//                                     ),
//                                     // imgCrack,
//                                   ],
//                                 ),
//                               ),
//                             ]))));
//               }))
//           : const Center(
//               child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                   CircularProgressIndicator(
//                     semanticsLabel: 'Выполняется обработка...',
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Выполняется обработка...',
//                     // style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ])),
//       extendBody: true,
//     );
//   }
// }

// void readSettings() async {
//   paramsData = await SharedPreferences.getInstance();
//   if (paramsData.getDouble('contrast') != null) {
//     params.contrast = paramsData.getDouble('contrast') ?? params.contrast;
//     params.contrastDamage =
//         paramsData.getDouble('contrastDamage') ?? params.contrastDamage;
//     params.blockSizeThreshold =
//         paramsData.getInt('blockSizeThreshold') ?? params.blockSizeThreshold;
//     params.gaussianBlockSize =
//         paramsData.getInt('gaussianBlockSize') ?? params.gaussianBlockSize;
//     params.minLengthLine =
//         paramsData.getInt('minLengthLine') ?? params.minLengthLine;
//     params.epsilonVertical =
//         paramsData.getInt('epsilonVertical') ?? params.epsilonVertical;
//     params.epsilonHorizontal =
//         paramsData.getInt('epsilonHorizontal') ?? params.epsilonHorizontal;
//     params.minCountVerticalLine = paramsData.getInt('minCountVerticalLine') ??
//         params.minCountVerticalLine;
//     params.minCountHorizontalLine =
//         paramsData.getInt('minCountHorizontalLine') ??
//             params.minCountHorizontalLine;
//     params.isNotSwipeTabView =
//         paramsData.getBool('isNotSwipeTabView') ?? params.isNotSwipeTabView;
//   } else {
//     paramsData.setDouble('contrast', params.contrast);
//     paramsData.setDouble('contrastDamage', params.contrastDamage);
//     paramsData.setInt('blockSizeThreshold', params.blockSizeThreshold);
//     paramsData.setInt('gaussianBlockSize', params.gaussianBlockSize);
//     paramsData.setInt('minLengthLine', params.minLengthLine);
//     paramsData.setInt('epsilonVertical', params.epsilonVertical);
//     paramsData.setInt('epsilonHorizontal', params.epsilonHorizontal);
//     paramsData.setInt('minCountVerticalLine', params.minCountVerticalLine);
//     paramsData.setInt('minCountHorizontalLine', params.minCountHorizontalLine);

//     paramsData.setBool('isNotSwipeTabView', params.isNotSwipeTabView);
//   }
// }
