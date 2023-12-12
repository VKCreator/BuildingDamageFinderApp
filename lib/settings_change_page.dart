import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:marquee/marquee.dart';

import 'custom_settings.dart';
import 'result_page.dart';
import 'helper_page.dart';

class SettingsChangePage extends StatefulWidget {
  const SettingsChangePage(
      {Key? key, required this.img, required this.isFromResultPage})
      : super(key: key);

  final String img;
  final bool isFromResultPage;

  @override
  SettingsChangePageState createState() => SettingsChangePageState();
}

class SettingsChangePageState extends State<SettingsChangePage> {
  @override
  void initState() {
    super.initState();
    checkParams();
  }

  void checkParams() async {
    readSettings().then((value) => {setState(() {})});
    // !!!!
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close)),
          title: const FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
            child: AutoSizeText(
              'Режим настройки параметров',
              maxLines: 1,
            ),
          ),
          // const Text('Режим настройки параметров',
          // style: TextStyle(fontSize: 17)),
          actions: [
            IconButton(
              onPressed: () async {
                paramsData = await SharedPreferences.getInstance();

                paramsData.setDouble('contrast', params.contrast);
                paramsData.setDouble('contrastDamage', params.contrastDamage);
                paramsData.setInt(
                    'blockSizeThreshold', params.blockSizeThreshold);
                paramsData.setInt(
                    'gaussianBlockSize', params.gaussianBlockSize);
                paramsData.setInt('minLengthLine', params.minLengthLine);
                paramsData.setInt('epsilonVertical', params.epsilonVertical);
                paramsData.setInt(
                    'epsilonHorizontal', params.epsilonHorizontal);
                paramsData.setInt(
                    'minCountVerticalLine', params.minCountVerticalLine);
                paramsData.setInt(
                    'minCountHorizontalLine', params.minCountHorizontalLine);

                // params.isNotSwipeTabView = selected;
                paramsData.setBool(
                    'isNotSwipeTabView', params.isNotSwipeTabView);

                if (!context.mounted) return;
                if (widget.isFromResultPage) {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(image: widget.img),
                      ));
                } else {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(image: widget.img),
                      ));
                }
              },
              icon: const Icon(Icons.check),
            ),
          ],
          // leading: BackButton(onPressed: () {
          //   Navigator.pop(context);
          // })
        ),
        body: Scrollbar(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.contrast,
                  min: 1,
                  max: 15,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Контраст изображения (исходное)',
                    helperText: "По умолчанию: 1",
                  ),
                  onChanged: (value) {
                    params.contrast = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.contrastDamage,
                  min: 4,
                  max: 15,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Контраст изображения (разрушения)',
                    helperText: "По умолчанию: 4",
                  ),
                  onChanged: (value) {
                    params.contrastDamage = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.blockSizeThreshold.toDouble(),
                  min: 5,
                  max: 15,
                  step: 2,
                  decoration: const InputDecoration(
                    labelText: 'Размер окрестности для порогового знач.',
                    helperText: "По умолчанию: 11",
                  ),
                  onChanged: (value) {
                    params.blockSizeThreshold = value.toInt();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.gaussianBlockSize.toDouble(),
                  min: 9,
                  max: 25,
                  step: 2,
                  decoration: const InputDecoration(
                    labelText: 'Гауссовский размер ядра',
                    helperText: "По умолчанию: 11",
                  ),
                  onChanged: (value) {
                    params.gaussianBlockSize = value.toInt();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.minLengthLine.toDouble(),
                  min: 50,
                  max: 200,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Минимальный размер линии',
                    helperText: "По умолчанию: 100",
                  ),
                  onChanged: (value) {
                    params.minLengthLine = value.toInt();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.epsilonVertical.toDouble(),
                  min: 15,
                  max: 100,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Окрестность вертикального шва',
                    helperText: "По умолчанию: 20",
                  ),
                  onChanged: (value) {
                    params.epsilonVertical = value.toInt();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.epsilonHorizontal.toDouble(),
                  min: 15,
                  max: 100,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Окрестность горизонтального шва',
                    helperText: "По умолчанию: 20",
                  ),
                  onChanged: (value) {
                    params.epsilonHorizontal = value.toInt();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.minCountVerticalLine.toDouble(),
                  min: 1,
                  max: 100,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Мин. количество вертик. линий в шве',
                    helperText: "По умолчанию: 10",
                  ),
                  onChanged: (value) {
                    params.minCountVerticalLine = value.toInt();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SpinBox(
                  value: params.minCountHorizontalLine.toDouble(),
                  min: 1,
                  max: 100,
                  step: 1,
                  decoration: const InputDecoration(
                    labelText: 'Мин. количество горизонт. линий в шве',
                    helperText: "По умолчанию: 20",
                  ),
                  onChanged: (value) {
                    params.minCountHorizontalLine = value.toInt();
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: SwitchListTile(
                    // activeColor: Colors.amber,
                    title: const Text(
                        'Отключить смахивание (swipe) в просмотре результатов'),
                    value: params.isNotSwipeTabView,
                    onChanged: (bool? value) {
                      setState(() {
                        params.isNotSwipeTabView = value!;
                      });
                    },
                  )),
              TextButton(
                // icon: Icon(Icons.help),
                child: const Text(
                  'Помощь',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelperPage(),
                      ));
                },
              ),
            ],
          ),
        ));
  }
}
