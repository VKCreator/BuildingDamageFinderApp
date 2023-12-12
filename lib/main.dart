import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// import 'package:permission_handler/permission_handler.dart';
// import 'package:simple_permissions/simple_permissions.dart';

import 'start_page.dart';
import 'custom_settings.dart';

// Start an app
void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  getTemporaryDirectory().then((dir) => tempDir = dir);

  // getApplicationDocumentsDirectory().then((dir) => tempDir = dir);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //         statusBarBrightness: Brightness.light) // Or Brightness.dark
  //     );

  // var mySystemTheme =
  //     SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.red);
  // SystemChrome.setSystemUIOverlayStyle(mySystemTheme);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => {runApp(const MyApp())});
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildingDamageFinderApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // appBarTheme: AppBarTheme(
          //   systemOverlayStyle: SystemUiOverlayStyle(
          //     // Status bar color
          //     statusBarColor: Colors.white,

          //     systemNavigationBarColor: Colors.white, // Navigation bar
          //     // statusBarColor: Colors.amber,
          //     // Status bar brightness (optional)
          //     statusBarIconBrightness:
          //         Brightness.dark, // For Android (dark icons)
          //   ),
          // ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(255, 125, 235, 128),
            foregroundColor: Colors.black,
          ),
          brightness: Brightness.light,
          primarySwatch: Colors.amber,
          bottomAppBarTheme: const BottomAppBarTheme(
            color: Colors.amber,
            elevation: 4,
            height: 50.0,
            // shape: CircularNotchedRectangle(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber))),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                  iconColor: MaterialStateProperty.all(Colors.black),
                  foregroundColor: MaterialStateProperty.all(Colors.black))),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.amber;
              }
              return Colors.white;
            }),
          ),
          cardTheme: const CardTheme(color: Colors.amber)),
      darkTheme: ThemeData(
        // appBarTheme: AppBarTheme(
        //   systemOverlayStyle: SystemUiOverlayStyle(
        //     // Status bar color
        //     statusBarColor: Colors.black,
        //     systemNavigationBarColor: Colors.black, // Navigation bar

        //     // Status bar brightness (optional)
        //     statusBarIconBrightness:
        //         Brightness.light, // For Android (dark icons)
        //   ),
        // ),
        // useMaterial3: false,
        brightness: Brightness.dark,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.teal[300]))),
        bottomAppBarTheme: const BottomAppBarTheme(
          height: 50.0,
          // shape: CircularNotchedRectangle(),
        ),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                iconColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.white))),
        // switchTheme: SwitchThemeData(),
        // inputDecorationTheme: InputDecorationTheme(
        //   counterStyle: TextStyle(color: Colors.blue),
        //   labelStyle: TextStyle(color: Colors.blue),
        //   border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
        //   focusedBorder: OutlineInputBorder(
        //       borderSide: BorderSide(width: 1, color: Colors.teal[300]!)),
        //   // activeIndicatorBorder: BorderSide(color: Colors.teal[300]!)
        // ),
        // textSelectionTheme: TextSelectionThemeData(
        //     selectionColor: Colors.teal[300]!,
        //     cursorColor: Colors.teal[300]!,
        //     selectionHandleColor: Colors.teal[300]!),
      ),
      themeMode: ThemeMode.system,
      home: StartPage(),
    );
  }
}
