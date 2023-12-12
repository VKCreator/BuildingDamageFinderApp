import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HelperPage extends StatelessWidget {
  const HelperPage({super.key});

  _launchURL() async {
    Uri url = Uri.parse(
        'https://www.researchgate.net/publication/374076571_Programmnoe_obespecenie_dla_avtomatizirovannogo_obnaruzenia_i_ocenki_razrusenij_soedinitelnyh_svov_zdanijSoftware_for_automated_detection_and_assessment_of_building_seam_failures?_sg%5B0%5D=Z6Lstw5ob39fs3v0it7j4cjtBSyJMRWnsRUCsYUlhY1gGhbLetBYQgrhdVkksqv4VBU9dKdXERJUpeceD5D2hEITk55CMspluxqlq86j.GZBFtqd9efKugd_-U1Zk51vSRhTBQy-7q9nck--QkJ-TXPLrXUh0838BjkNooCIswdYJEUQN0Av-FkLpuqx7MA&_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6Il9kaXJlY3QiLCJwYWdlIjoicHJvZmlsZSIsInByZXZpb3VzUGFnZSI6InByb2ZpbGUiLCJwb3NpdGlvbiI6InBhZ2VDb250ZW50In19');

    try {
      await launchUrl(url);
    } catch (err) {
      Fluttertoast.showToast(
          msg: "Ссылка недоступна.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red[200],
          textColor: Colors.white,
          fontSize: 12.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Помощь')),
        body: Scrollbar(
            child: ListView(children: [
          const SizedBox(
            height: 5,
          ),
          const HeaderLine(header: "Порядок работы"),
          const TextLine(
              text:
                  "1. Загрузите изображение фасада здания или сфотографируйте объект.",
              icon: Icons.add_photo_alternate),
          const TextLine(
              text:
                  "2. Выберите область обследования здания на изображении в режиме обрезки.",
              icon: Icons.crop),
          const TextLine(
              text:
                  "3. Настройте параметры обработки (описание ниже) или воспользуйтесь значениями по умолчанию.",
              icon: Icons.settings),
          const SizedBox(
            height: 5,
          ),
          const HeaderLine(header: "Описание параметров"),
          const TextLine(
              text:
                  "1. Контраст изображения (исходное) [1-15]: изменяет контраст исходного изображения при обработке. Необходим для выделения межпанельных швов здания на изображениях с пониженной яркостью.",
              icon: Icons.contrast),
          const TextLine(
              text:
                  "2. Контраст изображения (разрушения) [4-15]: при увеличении значения данного параметра исключаются «ложные» (небольшие) разрушения швов. Позволяет корректировать обнаружение разрушений.",
              icon: Icons.contrast),
          const TextLine(
              text:
                  "3. Размер окрестности для порогового значения [5-15]: используется для расширения окрестности обнаружения межпанельных швов.",
              icon: Icons.square),
          const TextLine(
              text:
                  "4. Гауссовский размер ядра [9-25]: размытие изображения, уменьшение шумов. Позволяет убрать лишние детали на изображении.",
              icon: Icons.blur_circular),
          const TextLine(
              text:
                  "5. Минимальный размер линии [50-100]: изменяет количество обнаруживаемых зелёных линий (см. анализ выходных данных).",
              icon: Icons.line_style),
          const TextLine(
              text:
                  "6. Окрестность вертикального (горизонтального) шва [15-100]: изменяет группировку зелёных линий, позволяет объединить линии в группы для обнаружения межпанельного шва.",
              icon: Icons.crop_square),
          const TextLine(
              text:
                  "7. Минимальное количество вертикальных (горизонтальных) линий в шве [1-100]: позволяет искать межпанельные швы здания на изображениях разного размера. Для небольших фрагментов изображения, как правило, данный параметр уменьшают.",
              icon: Icons.line_style),
          const SizedBox(
            height: 5,
          ),
          const HeaderLine(header: "Анализ выходных данных"),
          const TextLine(
              text:
                  "1. Вкладка «Исходное»: просмотр изображения для обработки.",
              icon: Icons.image),
          const TextLine(
              text:
                  "2. Вкладка «Швы»: просмотр изображения с обнаруженными швами. Обозначения: желтый шов - подтвержденный шов здания (учитываются в расчётах процентной доли); зелёные линии - возможные швы, в расчётах не учитываются, при корректировке параметров можно объединить зеленые линии в швы.",
              icon: Icons.image_search),
          const TextLine(
              text:
                  "3. Вкладка «Дефекты»: просмотр изображения с обнаруженными разрушениями швов. Обозначения: голубой шов - подтвержденное разрушение шва здания (учитываются в расчётах процентной доли); зелёные линии - возможные разрушения, в расчётах не учитываются, при корректировке параметров можно объединить зеленые линии в разрушение при условии, что шов, на котором обнаружены разрушения, выделен желтым прямоугольником во вкладке «Швы». ",
              icon: Icons.broken_image_rounded),
          const SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: _launchURL,
            child: const Text(
              'Программа для ЭВМ',
              textAlign: TextAlign.center,
              style: TextStyle(
                // fontSize: 30,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ])));
  }
}

class HeaderLine extends StatelessWidget {
  const HeaderLine({
    super.key,
    required this.header,
  });

  final String header;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        child: Text(
          header,
          style: const TextStyle(fontWeight: FontWeight.bold),
          softWrap: true,
        ));
  }
}

class TextLine extends StatelessWidget {
  const TextLine({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              text,
              style: const TextStyle(),
              softWrap: true,
            )),
          ],
        ));
  }
}
