import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

late Directory tempDir;

final class ParamsDefault {
  double contrast = 1;
  double contrastDamage = 4;
  int blockSizeThreshold = 11;
  int gaussianBlockSize = 11;
  int minLengthLine = 100;
  int epsilonVertical = 20;
  int epsilonHorizontal = 20;
  int minCountVerticalLine = 10;
  int minCountHorizontalLine = 20;
  bool isNotSwipeTabView = true;
}

final ParamsDefault params = ParamsDefault();
late SharedPreferences paramsData;

Future<void> readSettings() async {
  paramsData = await SharedPreferences.getInstance();
  if (paramsData.getDouble('contrast') != null) {
    params.contrast = paramsData.getDouble('contrast') ?? params.contrast;
    params.contrastDamage =
        paramsData.getDouble('contrastDamage') ?? params.contrastDamage;
    params.blockSizeThreshold =
        paramsData.getInt('blockSizeThreshold') ?? params.blockSizeThreshold;
    params.gaussianBlockSize =
        paramsData.getInt('gaussianBlockSize') ?? params.gaussianBlockSize;
    params.minLengthLine =
        paramsData.getInt('minLengthLine') ?? params.minLengthLine;
    params.epsilonVertical =
        paramsData.getInt('epsilonVertical') ?? params.epsilonVertical;
    params.epsilonHorizontal =
        paramsData.getInt('epsilonHorizontal') ?? params.epsilonHorizontal;
    params.minCountVerticalLine = paramsData.getInt('minCountVerticalLine') ??
        params.minCountVerticalLine;
    params.minCountHorizontalLine =
        paramsData.getInt('minCountHorizontalLine') ??
            params.minCountHorizontalLine;
    params.isNotSwipeTabView =
        paramsData.getBool('isNotSwipeTabView') ?? params.isNotSwipeTabView;
  } else {
    paramsData.setDouble('contrast', params.contrast);
    paramsData.setDouble('contrastDamage', params.contrastDamage);
    paramsData.setInt('blockSizeThreshold', params.blockSizeThreshold);
    paramsData.setInt('gaussianBlockSize', params.gaussianBlockSize);
    paramsData.setInt('minLengthLine', params.minLengthLine);
    paramsData.setInt('epsilonVertical', params.epsilonVertical);
    paramsData.setInt('epsilonHorizontal', params.epsilonHorizontal);
    paramsData.setInt('minCountVerticalLine', params.minCountVerticalLine);
    paramsData.setInt('minCountHorizontalLine', params.minCountHorizontalLine);

    paramsData.setBool('isNotSwipeTabView', params.isNotSwipeTabView);
  }
}
