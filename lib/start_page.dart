import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

import 'custom_settings.dart';
import 'cropper_page.dart';
import 'helper_page.dart';
import './source_button.dart';
import './filled_card.dart';

class StartPage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  StartPage({super.key}) {
    readSettings().then((value) => {FlutterNativeSplash.remove()});

    // FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BuildingDamageFinderApp'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  const FilledCardExample(),
                  const SizedBox(
                    height: 15,
                  ),
                  SourceButton(
                      icon: Icons.image,
                      semantic: "Открыть галерею",
                      label: "Галерея",
                      onPressed: () async {
                        final imageFile = await _picker.pickImage(
                            source: ImageSource.gallery);

                        final imagePath = imageFile?.path ?? "none";

                        if (imageFile == null) return;

                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CropperPage(imagePath: imagePath)));
                      }),
                  const SizedBox(
                    height: 30,
                  ),
                  SourceButton(
                      icon: Icons.camera,
                      semantic: "Сделать фото",
                      label: "Камера",
                      onPressed: () async {
                        // запрет на доступ к камере
                        late dynamic image;
                        try {
                          image = await _picker.pickImage(
                              source: ImageSource.camera);
                        } on PlatformException {
                          Fluttertoast.showToast(
                              msg: "Разрешите приложению доступ к камере.",
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CropperPage(imagePath: imagePath)));
                      }),
                  const SizedBox(
                    height: 30,
                  ),
                  SourceButton(
                      icon: Icons.help,
                      semantic: "Открыть помощь",
                      label: "Помощь",
                      onPressed: () async {
                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HelperPage()));
                      }),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
