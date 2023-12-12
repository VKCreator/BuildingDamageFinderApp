import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'dart:ffi';
// import 'dart:io' as io;

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:share/share.dart';
import 'package:path/path.dart' as pathPackage;
import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:path_provider/path_provider.dart';

import 'custom_bottom_nav_bar.dart';
import 'settings_change_page.dart';
import 'custom_settings.dart';
import 'cropper_page.dart';
import 'helper_page.dart';

// For temporary storage of images
// late Directory tempDir;

String tempPathSeams = '${tempDir.path}/allSeams.jpg';
String tempPathCrack = '${tempDir.path}/crack.jpg';
String tempPathSource = '${tempDir.path}/source.jpg';

// Data for C++ proccesing
class ProcessImageArguments {
  final String inputPath;
  final String tempPathSource;
  final String tempPathSeams;
  final String tempPathCrack;
  int res; // percent
  final dynamic port;
  ParamsDefault params;

  ProcessImageArguments(this.inputPath, this.tempPathSource, this.tempPathSeams,
      this.tempPathCrack, this.res, this.params, this.port);
}

// FFI C++
final dylib = Platform.isAndroid
    ? DynamicLibrary.open("libOpenCV_ffi.so")
    : DynamicLibrary.process();

final _processImage = dylib.lookupFunction<
    Int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
        Pointer<ResParams>),
    int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>,
        Pointer<ResParams>)>('buildHelper');

late Pointer<ResParams> p;

void processImage(ProcessImageArguments args) {
  Pointer<ResParams> p = calloc<ResParams>();

  p.ref.contrast = args.params.contrast;
  p.ref.contrastDamage = args.params.contrastDamage;
  p.ref.blockSizeThreshold = args.params.blockSizeThreshold;
  p.ref.gaussianBlockSize = args.params.gaussianBlockSize;
  p.ref.epsilonHorizontal = args.params.epsilonHorizontal;
  p.ref.epsilonVertical = args.params.epsilonVertical;
  p.ref.minLengthLine = args.params.minLengthLine;
  p.ref.minCountHorizontalLine = args.params.minCountHorizontalLine;
  p.ref.minCountVerticalLine = args.params.minCountVerticalLine;

  args.port.send(_processImage(
      args.inputPath.toNativeUtf8(),
      args.tempPathSource.toNativeUtf8(),
      args.tempPathSeams.toNativeUtf8(),
      args.tempPathCrack.toNativeUtf8(),
      p));

  calloc.free(p);
}

base class ResParams extends Struct {
  @Double()
  external double contrast;
  @Double()
  external double contrastDamage;
  @Int()
  external int blockSizeThreshold;
  @Int()
  external int gaussianBlockSize;
  @Int()
  external int minLengthLine;
  @Int()
  external int epsilonVertical;
  @Int()
  external int epsilonHorizontal;
  @Int()
  external int minCountVerticalLine;
  @Int()
  external int minCountHorizontalLine;
}

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key, required this.image}) : super(key: key);
  final String image;

  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  bool _isLoading = true;
  String selectedValue = ".jpg";
  bool _validate = false;

  final dynamic port = ReceivePort();
  late dynamic isolate = null;

  final ImagePicker _picker = ImagePicker();

  late Image imgSeams = Image.asset('assets/img/default.jpg');
  late Image imgCrack = Image.asset('assets/img/default.jpg');
  late Image imgSource = Image.asset('assets/img/default.jpg');

  late int res = 0;
  late int ind = 1;

  var imgName = TextEditingController();

  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(
      value: ".jpg",
      child: Text(".jpg"),
    ),
    // const DropdownMenuItem(value: ".png", child: Text(".png"))
  ];

  Future<void> takeImageAndProcess() async {
    setState(() {
      _isLoading = true;
    });

    // widget.port = ReceivePort();
    final args = ProcessImageArguments(widget.image, tempPathSource,
        tempPathSeams, tempPathCrack, 0, params, port.sendPort);

    // Spawning an isolate
    isolate = await Isolate.spawn<ProcessImageArguments>(
      processImage,
      args,
      onError: port.sendPort,
      onExit: port.sendPort,
    );

    // Listening for messages on port
    port.listen((_) {
      res = _;
      imgSource = Image.file(File(args.inputPath));
      imgCrack = Image.file(key: UniqueKey(), File(args.tempPathCrack));
      imgSeams = Image.file(key: UniqueKey(), File(args.tempPathSeams));

      port.close();
      isolate.kill();
      _isLoading = false;

      setState(() {});
      imageCache.clear();
      imageCache.clearLiveImages();
    });
  }

  @override
  void dispose() {
    if (_isLoading) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
    port.close();

    if (isolate != null) isolate.kill();

    imgName.dispose();

    super.dispose();
  }

  @override
  void initState() {
    takeImageAndProcess();

    super.initState();
  }

  void showMessage(value) {
    String mess;
    MaterialColor color;

    mess = "Изображение сохранено в галерее.";
    color = Colors.green;
    if (!value) {
      mess = "Изображение не сохранено в галерее.";
      color = Colors.red;
    }

    Fluttertoast.showToast(
        msg: mess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  Future<bool?> _dialogBuilder(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setStateSB) => AlertDialog(
                  title: const Text('Сохранение изображения'),
                  content: Row(children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: imgName,
                        maxLength: 25,
                        decoration: InputDecoration(
                          labelText: 'Название',
                          errorText: _validate ? "Пустое поле" : null,
                        ),
                        onChanged: (value) {
                          if (_validate) {
                            setState(() {
                              _validate = false;
                            });
                            setStateSB(() {}); // update UI inside Dialog
                          }
                        },
                      ),
                    ),
                    // SizedBox(
                    //   width: 8.0,
                    // ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                          onChanged: null,
                          icon: const Visibility(
                              visible: false,
                              child: Icon(Icons.arrow_downward)),
                          value: selectedValue,
                          // style: TextStyle(color: Colors.red),
                          // onChanged: (String? newValue) {
                          //   setState(() {
                          //     selectedValue = newValue!;
                          //   });
                          //   setStateSB(() {}); // update UI inside Dialog
                          // },
                          items: menuItems),
                    )
                  ]),
                  actions: <Widget>[
                    IconButton(
                      color: Colors.red,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    IconButton(
                      color: Colors.green,
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          _validate = imgName.text.isEmpty;
                        });
                        setStateSB(() {}); // update UI inside Dialog

                        if (!_validate) Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _isLoading
          ? AppBar(
              title: const Text('Результаты обработки'),
              automaticallyImplyLeading: !_isLoading,
            )
          : null,
      floatingActionButton: !_isLoading
          ? ExpandableFab(
              type: ExpandableFabType.side,
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const Icon(Icons.save_alt_outlined),
                fabSize: ExpandableFabSize.regular,
                shape: const CircleBorder(),
              ),
              closeButtonBuilder: FloatingActionButtonBuilder(
                size: 56,
                builder: (BuildContext context, void Function()? onPressed,
                    Animation<double> progress) {
                  return FloatingActionButton(
                    onPressed: onPressed,
                    child: const Icon(Icons.close_outlined),
                  );
                },
              ),
              children: [
                FloatingActionButton(
                    heroTag: null,
                    child: const Icon(Icons.save),
                    onPressed: () async {
                      String path = tempPathSource;
                      switch (ind) {
                        case 0:
                          // path = widget.image;
                          path = tempPathSource;
                          imgName.text = "source";
                          break;
                        case 1:
                          path = tempPathSeams;
                          imgName.text = "allSeams";
                          break;
                        case 2:
                          path = tempPathCrack;
                          imgName.text = "crack";
                          break;
                      }

                      bool? checkChoice = await _dialogBuilder(context);

                      // print(checkChoice);
                      // print(imgName.text);
                      // print(selectedValue);
                      // print(path);

                      if (checkChoice == true) {
                        // if (selectedValue == ".png") {
                        // final image = imageConverter
                        //     .decodeImage(File(path).readAsBytesSync())!;

                        // final thumbnail = imageConverter.copyResize(image,
                        //     width: image.width, height: image.height);

                        // String dir = pathPackage.dirname(File(path).path);

                        // // Save the thumbnail as a PNG.
                        // File("test.png").writeAsBytesSync(
                        //     imageConverter.encodePng(thumbnail));

                        // print(File("test.png").path);
                        // }
                        try {
                          String dir = pathPackage.dirname(File(path).path);
                          String newPath = pathPackage.join(
                              dir, imgName.text + selectedValue);

                          if (newPath != path) File(path).renameSync(newPath);

                          /* var rootPath = '/storage/emulated/0/Pictures';
                          final Directory _pictDir = Directory(rootPath);

                          await _pictDir.exists().then(
                            (isExist) async {
                              if (isExist) {
                                String pictAlbumDir = pathPackage.join(
                                    rootPath, "BuildingDamageFinder");

                                await Directory(pictAlbumDir).exists().then();
                              }
                            },
                          );

                          var imageList = _photoDir.listSync().length;
                          print(imageList);*/

                          await GallerySaver.saveImage(
                            newPath,
                            albumName: "BuildingDamageFinder",
                          ).then((value) {
                            showMessage(value);

                            if (newPath != path) {
                              switch (ind) {
                                case 0:
                                  File(newPath).renameSync(tempPathSource);

                                  // tempPathSource = newPath;
                                  break;
                                case 1:
                                  File(newPath).renameSync(tempPathSeams);

                                  // tempPathSeams = newPath;
                                  // imgName.text = "allSeams";
                                  break;
                                case 2:
                                  File(newPath).renameSync(tempPathCrack);

                                  // tempPathCrack = newPath;
                                  // imgName.text = "crack";
                                  break;
                              }
                            }
                          });
                        } catch (err) {
                          Fluttertoast.showToast(
                              msg: "Ошибка при сохранении",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.SNACKBAR,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 14.0);
                        }
                      }
                    }),
                FloatingActionButton(
                  heroTag: null,
                  child: const Icon(Icons.share),
                  onPressed: () async {
                    String path = widget.image;
                    switch (ind) {
                      case 0:
                        path = tempPathSource;
                        break;
                      case 1:
                        path = tempPathSeams;
                        break;
                      case 2:
                        path = tempPathCrack;
                        break;
                    }
                    await Share.shareFiles([path],
                        text: 'Приложение «BuildingDamageFinder»');
                  },
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: ExpandableFab.location,
      bottomNavigationBar: CustomBottomNavBar(
          bottomAppBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        child: !_isLoading
            ? FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.contain,
                child: AutoSizeText(
                  'Процентная доля разрушений швов: $res%',
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
      )),
      body: !_isLoading
          ? DefaultTabController(
              initialIndex: 1,
              length: 3,
              child: Builder(builder: (BuildContext context) {
                return Scaffold(
                    // backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      actions: [
                        IconButton(
                          visualDensity: const VisualDensity(
                              horizontal: -4.0, vertical: -4.0),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsChangePage(
                                          img: widget.image,
                                          isFromResultPage: true,
                                        )));
                          },
                          icon: const Icon(Icons.settings),
                        ),
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          itemBuilder: (ctx) => [
                            _buildPopupMenuItem(
                              'Галерея',
                              Icons.image_outlined,
                              !(Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.black
                                  : Colors.white,
                              () async {
                                final imageFile = await _picker.pickImage(
                                    source: ImageSource.gallery);

                                final imagePath = imageFile?.path ?? "none";

                                if (imageFile == null) return;

                                if (!context.mounted) return;

                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                // Navigator.pop(context);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CropperPage(imagePath: imagePath)));
                              },
                            ),
                            _buildPopupMenuItem(
                              'Камера',
                              Icons.camera,
                              !(Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.black
                                  : Colors.white,
                              () async {
                                late dynamic image;
                                try {
                                  image = await _picker.pickImage(
                                      source: ImageSource.camera);
                                } on PlatformException {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Разрешите приложению доступ к камере.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red[200],
                                      textColor: Colors.white,
                                      fontSize: 12.0);
                                  return;
                                }

                                final imagePath = image?.path ?? "none";

                                if (image == null) return;

                                if (!context.mounted) return;

                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CropperPage(imagePath: imagePath)));
                              },
                            ),
                            _buildPopupMenuItem(
                              'Помощь',
                              Icons.help,
                              !(Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.black
                                  : Colors.white,
                              () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HelperPage()));
                              },
                            ),
                          ],
                        )
                      ],
                      bottom: const TabBar(
                        // isScrollable: true, // here
                        tabs: [
                          Tab(
                            icon: Icon(Icons.image_outlined),
                            child: AutoSizeText(
                              'Исходное',
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tab(
                            icon: Icon(Icons.image_search_outlined),
                            child: AutoSizeText(
                              'Швы',
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Tab(
                            icon: Icon(Icons.broken_image_outlined),
                            child: AutoSizeText(
                              'Дефекты',
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      title: const FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.contain,
                        child: AutoSizeText(
                          'Результаты обработки',
                          maxLines: 1,
                        ),
                      ),
                    ),
                    body: SafeArea(
                        bottom: false,
                        child: NotificationListener(
                            onNotification: (scrollNotification) {
                              if (scrollNotification is ScrollEndNotification) {
                                ind = DefaultTabController.of(context).index;
                                // print(ind);
                              }
                              return false;
                            },
                            child: Column(children: <Widget>[
                              Expanded(
                                child: TabBarView(
                                  physics: params.isNotSwipeTabView
                                      ? const NeverScrollableScrollPhysics()
                                      : null,
                                  children: [
                                    PhotoView(
                                      imageProvider:
                                          FileImage(File(widget.image)),
                                      backgroundDecoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                    ),
                                    // imgSource,
                                    PhotoView(
                                      imageProvider:
                                          FileImage(File(tempPathSeams)),
                                      backgroundDecoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                    ),
                                    // imgSeams,
                                    PhotoView(
                                      imageProvider:
                                          FileImage(File(tempPathCrack)),
                                      backgroundDecoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                    ),
                                    // imgCrack,
                                  ],
                                ),
                              ),
                            ]))));
              }))
          : const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircularProgressIndicator(
                    semanticsLabel: 'Выполняется обработка...',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Выполняется обработка...',
                    // style: Theme.of(context).textTheme.titleLarge,
                  ),
                ])),
      extendBody: true,
    );
  }
}

PopupMenuItem _buildPopupMenuItem(
    String title, IconData iconData, Color color, VoidCallback onTap) {
  return PopupMenuItem(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(iconData, color: color),
        const SizedBox(
          width: 5,
        ),
        Text(title),
      ],
    ),
    onTap: () async {
      onTap();
    },
  );
}
