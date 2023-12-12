// От Python отличается keys-окрестностью, а также не реализовано деление прямоугольников найденных разрушений

#include "buildingdamagefinderl.h"

BuildingDamageFinderL::BuildingDamageFinderL()
{
    this->originalImage.data = NULL;

    setDefaultValuesParametersForDetectAllSeamsBuilding();
    setDefaultValuesParametersDetectDamageSeamsBuilding();
}

cv::Mat BuildingDamageFinderL::readImage(std::string pathToImage)
{
    return cv::imread(pathToImage); // cyrillic - ok
}


bool BuildingDamageFinderL::setImage(cv::Mat image)
{
    if (!image.empty())
    {
        this->originalImage = image.clone();
        clearParameters();

        setImageWithDetectAllSeamsBuilding(); // 1
        setImageWithDetectDamageSeamsBuilding(); // 2
        isChanged = false;
        return true;
    }

    this->originalImage.data = NULL;
    return false;
}

int BuildingDamageFinderL::getAreaAllSeams()
{
    return areaSeams;
}

int BuildingDamageFinderL::getAreaDamageSeams()
{
    return areaDamage;
}

int BuildingDamageFinderL::getPercentDamageSeamsBuilding()
{

    if (!originalImage.empty())
    {
        int res;
        if (areaSeams == 0 )
            res = 0;
        else
            res = int((double)areaDamage / areaSeams * 100);

        // round
        // std::string str = std::to_string (res);
        // str.erase ( str.find_last_not_of('0') + 1, std::string::npos );
        // str.erase ( str.find_last_not_of('.') + 1, std::string::npos );

        return res;
    }
    return 0;
}

void BuildingDamageFinderL::setImageWithDetectAllSeamsBuilding()
{

    cv::Mat imHough = originalImage.clone();
    cv::Mat imgProcess = originalImage.clone();


    cv::convertScaleAbs(originalImage, imgProcess, contrastAlpha, 0);

    cv::cvtColor(imgProcess, imgProcess, cv::COLOR_BGR2GRAY);

    // Вывести отдельный параметр (для разного качества изображений - был 9,9)
    cv::GaussianBlur(imgProcess, imgProcess, cv::Size(gaussianBlock, gaussianBlock), cv::BORDER_DEFAULT);

    cv::Mat thAllSeams;
    cv::adaptiveThreshold(imgProcess, thAllSeams, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV, blockSizeForAdaptiveThreshold, 2);


    cv::Mat kernel = cv::Mat::ones(5,7,CV_8U);
    cv::Mat closing;
    cv::morphologyEx(thAllSeams, closing, cv::MORPH_CLOSE, kernel);

    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(closing, lines, 1, CV_PI / 180, 100, minLineLength, 25);

    // cv::Mat lineImageMask = cv::Mat::zeros(originalImage.rows,originalImage.cols,CV_8U);

    int count_lines = 0;
    areaSeams = 0;

    bool flagCont = false;
    for( size_t i = 0; i < lines.size(); i++ )
    {
        cv::Vec4i l = lines[i];
        double checkAngle = abs(atan2(l[3] - l[1], l[2] - l[0]) * 180.0 / CV_PI); // угол в градусах

        flagCont = false;
        for (int var = 0; var < excludeAreas.size(); ++var)
        {
            if (excludeAreas[var].contains(cv::Point(l[0], l[1])) && excludeAreas[var].contains(cv::Point(l[2], l[3])))
            {
                flagCont = true;
                break;
            }

        }


        if (!flagCont) {
        if (checkAngle >= 88 && checkAngle <= 90.5) // вертикальная линия
        {
            cv::line(imHough, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,255,0), 1, cv::LINE_AA); // LINE_AA
//            cv::line(lineImageMask, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255,255,255), 5);
            count_lines++;


            bool flag = false;

            for (auto& entry: verticalGroupLines)
            {
                auto key = entry.first;

                if (key >= (l[0] - epsilonVertical) && key <= (l[0] + epsilonVertical))
                {
                    verticalGroupLines[key]['x'].push_back(l[0]);
                    verticalGroupLines[key]['x'].push_back(l[2]);
                    verticalGroupLines[key]['y'].push_back(l[1]);
                    verticalGroupLines[key]['y'].push_back(l[3]);
                    flag = true;
                    break;
                }
            }
            if(!flag)
            {
                verticalGroupLines[l[0]]['x'].push_back(l[0]);
                verticalGroupLines[l[0]]['x'].push_back(l[2]);
                verticalGroupLines[l[0]]['y'].push_back(l[1]);
                verticalGroupLines[l[0]]['y'].push_back(l[3]);
            }
        }

        if (checkAngle >= 0 && checkAngle <= 2.5) // горизонтальная линия
        {
            cv::line(imHough, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,255,0), 1, cv::LINE_AA); // LINE_AA
//            cv::line(lineImageMask, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255,255,255), 5, cv::LINE_AA);
            count_lines++;

            bool flag = false;
            for (auto& entry: horizontalGroupLines)
            {
                auto key = entry.first;

                if (key >= (l[1] - epsilonHorizontal) && key <= (l[1] + epsilonHorizontal))
                {
                    horizontalGroupLines[key]['x'].push_back(l[0]);
                    horizontalGroupLines[key]['x'].push_back(l[2]);
                    horizontalGroupLines[key]['y'].push_back(l[1]);
                    horizontalGroupLines[key]['y'].push_back(l[3]);
                    flag = true;
                    break;
                }
//                if (flag)
//                    break;
            }

            if(!flag)
            {
                horizontalGroupLines[l[1]]['x'].push_back(l[0]);
                horizontalGroupLines[l[1]]['x'].push_back(l[2]);
                horizontalGroupLines[l[1]]['y'].push_back(l[1]);
                horizontalGroupLines[l[1]]['y'].push_back(l[3]);
            }
        }
    }
   }

   // build rectangles
    for (auto& entry : verticalGroupLines)
    {
      if (entry.second['x'].size() >= (minCountVerticalLinesInOneGroup * 2))
      {

          int left = *min_element(entry.second['x'].begin(), entry.second['x'].end());
          int top = *min_element(entry.second['y'].begin(), entry.second['y'].end());
          int right = *max_element(entry.second['x'].begin(), entry.second['x'].end());
          int bottom = *max_element(entry.second['y'].begin(), entry.second['y'].end());

          // cv::rectangle(imHough, cv::Point(left, top), cv::Point(right, bottom), cv::Scalar(0, 255, 255), -1);

          verticalRects.push_back(cv::Rect(left, top, right - left, bottom - top));
         // areaSeams += verticalRects[verticalRects.size() - 1].area();
      }
    }

    for (auto& entry : horizontalGroupLines)
    {
      if (entry.second['x'].size() >= (minCountHorizontalLinesInOneGroup * 2))
      {
          int left = *min_element(entry.second['x'].begin(), entry.second['x'].end());
          int top = *min_element(entry.second['y'].begin(), entry.second['y'].end());
          int right = *max_element(entry.second['x'].begin(), entry.second['x'].end());
          int bottom = *max_element(entry.second['y'].begin(), entry.second['y'].end());
          // cv::rectangle(imHough, cv::Point(left, top), cv::Point(right, bottom), cv::Scalar(0, 255, 255), -1);

          horizontalRects.push_back(cv::Rect(left, top, right - left, bottom - top));
         // areaSeams += horizontalRects[horizontalRects.size() - 1].area();
      }
    }

    // merge rectangles

    bool isMerge = false;
    int size = verticalRects.size();
    int i = 0, j = 0;

    while (i < size) 
    {
        j = i + 1;
        while (j < size)
        {
            if ((verticalRects[i] & verticalRects[j]).area() > 0) 
            {
                verticalRects[i] = (verticalRects[i] | verticalRects[j]);
                verticalRects[j] = cv::Rect(0, 0, 0, 0);
                isMerge = true;
            }
            j++;
        }

        if (!isMerge)
            i++;

        isMerge = false;
    }

    isMerge = false;
    size = horizontalRects.size();
    i = 0;
    j = 0;

    while (i < size) 
    {
        j = i + 1;
        while (j < size)
        {
            if ((horizontalRects[i] & horizontalRects[j]).area() > 0) 
            {
                horizontalRects[i] = (horizontalRects[i] | horizontalRects[j]);
                horizontalRects[j] = cv::Rect(0, 0, 0, 0);
                isMerge = true;
            }
            j++;
        }

        if (!isMerge)
            i++;

        isMerge = false;
    }

    // split rectangles

    bool flag = false;
    std::vector<std::vector<int>> relationVerticalRectsWithExcludeAreas;
    for( size_t i = 0; i < verticalRects.size(); i++ )
    {
        flag = false;
        std::vector<int> tmp;
        relationVerticalRectsWithExcludeAreas.push_back(tmp);
        for( size_t j = 0; j < excludeAreas.size(); j++ )
        {
            cv::Rect intersected = (verticalRects[i] & excludeAreas[j]);
            if (intersected.area() > 0 && verticalRects[i].width == intersected.width) // verticalRects[i].width == intersected.width
            {
                relationVerticalRectsWithExcludeAreas[i].push_back(j);
                flag = true;
            }
        }
        if (!flag)
        {
            // отрицательный процент
            verticalRectsFinal.push_back(verticalRects[i]);
            cv::rectangle(imHough, cv::Point(verticalRects[i].x, verticalRects[i].y), cv::Point(verticalRects[i].x + verticalRects[i].width, verticalRects[i].y + verticalRects[i].height), cv::Scalar(0, 255, 255), -1);
        }
    }


    flag = false;
    std::vector<std::vector<int>> relationHorizontalRectsWithExcludeAreas;
    for( size_t i = 0; i < horizontalRects.size(); i++ )
    {
        flag = false;
        std::vector<int> tmp;
        relationHorizontalRectsWithExcludeAreas.push_back(tmp);
        for( size_t j = 0; j < excludeAreas.size(); j++ )
        {
            cv::Rect intersected = (horizontalRects[i] & excludeAreas[j]);
            if (intersected.area() > 0  && horizontalRects[i].height == intersected.height)
            {
                relationHorizontalRectsWithExcludeAreas[i].push_back(j);
                flag = true;
            }
        }
        if (!flag)
        {
            cv::rectangle(imHough, cv::Point(horizontalRects[i].x, horizontalRects[i].y), cv::Point(horizontalRects[i].x + horizontalRects[i].width, horizontalRects[i].y + horizontalRects[i].height), cv::Scalar(0, 255, 255), -1);
            horizontalRectsFinal.push_back(horizontalRects[i]);
        }
    }

    std::vector<cv::Rect> nextPartsVerticalRects;
    std::map<int,std::vector<cv::Rect>> currentPartsVerticalRects;

    for (int j = 0; j < verticalRects.size(); j++)
    {

        for( size_t i = 0; i < relationVerticalRectsWithExcludeAreas[j].size(); i++ )
        {
            if (i == 0)
            {
            cv::Rect intersected = (verticalRects[j] & excludeAreas[relationVerticalRectsWithExcludeAreas[j][i]]);
            currentPartsVerticalRects[j].push_back(cv::Rect(verticalRects[j].x, verticalRects[j].y, intersected.width, abs(intersected.y - verticalRects[j].y)));
            //cv::rectangle(imHough, cv::Point(prevPartsVerticalRects[0].x, prevPartsVerticalRects[0].y), cv::Point(prevPartsVerticalRects[0].x + prevPartsVerticalRects[0].width, prevPartsVerticalRects[0].y + prevPartsVerticalRects[0].height), cv::Scalar(0, 255, 255), -1);
            currentPartsVerticalRects[j].push_back(cv::Rect(verticalRects[j].x, intersected.y + intersected.height, verticalRects[j].width, abs(verticalRects[j].height - intersected.height - currentPartsVerticalRects[j][0].height)));
            //cv::rectangle(imHough, cv::Point(prevPartsVerticalRects[1].x, prevPartsVerticalRects[1].y), cv::Point(prevPartsVerticalRects[1].x + prevPartsVerticalRects[1].width, prevPartsVerticalRects[1].y + prevPartsVerticalRects[1].height), cv::Scalar(0, 255, 255), -1);
            }
            else
            {
                for (int var = 0; var < currentPartsVerticalRects[j].size(); ++var)
                {
                    cv::Rect intersected = (currentPartsVerticalRects[j][var] & excludeAreas[relationVerticalRectsWithExcludeAreas[j][i]]);

                    if (intersected.area() > 0)
                    {
                        nextPartsVerticalRects.push_back(cv::Rect(currentPartsVerticalRects[j][var].x, currentPartsVerticalRects[j][var].y, intersected.width, abs(intersected.y - currentPartsVerticalRects[j][var].y)));
                        nextPartsVerticalRects.push_back(cv::Rect(currentPartsVerticalRects[j][var].x, intersected.y + intersected.height, currentPartsVerticalRects[j][var].width, abs(currentPartsVerticalRects[j][var].height - intersected.height - nextPartsVerticalRects[nextPartsVerticalRects.size() - 1].height)));
                    }
                    else
                    {
                        nextPartsVerticalRects.push_back(currentPartsVerticalRects[j][var]);
                    }
                }


                currentPartsVerticalRects[j] = nextPartsVerticalRects;
                nextPartsVerticalRects.clear();

            }
        }
    }


    for (int j = 0; j < verticalRects.size(); ++j)
    {
        if (currentPartsVerticalRects.count(j) != 0) {
            for (int var = 0; var < currentPartsVerticalRects[j].size(); ++var)
            {
                verticalRectsFinal.push_back(currentPartsVerticalRects[j][var]);
                cv::rectangle(imHough, cv::Point(currentPartsVerticalRects[j][var].x, currentPartsVerticalRects[j][var].y), cv::Point(currentPartsVerticalRects[j][var].x + currentPartsVerticalRects[j][var].width, currentPartsVerticalRects[j][var].y + currentPartsVerticalRects[j][var].height), cv::Scalar(0, 255, 255), -1);
            }
        }
   }

    std::vector<cv::Rect> nextPartsHorizontalRects;
    std::map<int,std::vector<cv::Rect>> currentPartsHorizontalRects;

    for (int j = 0; j < horizontalRects.size(); j++)
    {

        for( size_t i = 0; i < relationHorizontalRectsWithExcludeAreas[j].size(); i++ )
        {
            if (i == 0)
            {
            cv::Rect intersected = (horizontalRects[j] & excludeAreas[relationHorizontalRectsWithExcludeAreas[j][i]]);
            currentPartsHorizontalRects[j].push_back(cv::Rect(horizontalRects[j].x, horizontalRects[j].y,  abs(intersected.x - horizontalRects[j].x), horizontalRects[j].height));
            //cv::rectangle(imHough, cv::Point(prevPartsVerticalRects[0].x, prevPartsVerticalRects[0].y), cv::Point(prevPartsVerticalRects[0].x + prevPartsVerticalRects[0].width, prevPartsVerticalRects[0].y + prevPartsVerticalRects[0].height), cv::Scalar(0, 255, 255), -1);
            currentPartsHorizontalRects[j].push_back(cv::Rect(intersected.x + intersected.width, horizontalRects[j].y, abs(horizontalRects[j].width - intersected.width - currentPartsHorizontalRects[j][0].width), horizontalRects[j].height));
            //cv::rectangle(imHough, cv::Point(prevPartsVerticalRects[1].x, prevPartsVerticalRects[1].y), cv::Point(prevPartsVerticalRects[1].x + prevPartsVerticalRects[1].width, prevPartsVerticalRects[1].y + prevPartsVerticalRects[1].height), cv::Scalar(0, 255, 255), -1);
            }
            else
            {
                for (int var = 0; var < currentPartsHorizontalRects[j].size(); ++var)
                {
                    cv::Rect intersected = (currentPartsHorizontalRects[j][var] & excludeAreas[relationHorizontalRectsWithExcludeAreas[j][i]]);

                    if (intersected.area() > 0)
                    {
                        nextPartsHorizontalRects.push_back(cv::Rect(currentPartsHorizontalRects[j][var].x, currentPartsHorizontalRects[j][var].y, abs(intersected.x - currentPartsHorizontalRects[j][var].x), currentPartsHorizontalRects[j][var].height));
                        // nextPartsHorizontalRects.push_back(cv::Rect(currentPartsHorizontalRects[j][var].x, intersected.y + intersected.height, currentPartsHorizontalRects[j][var].width, abs(currentPartsHorizontalRects[j][var].height - intersected.height - nextPartsHorizontalRects[nextPartsHorizontalRects.size() - 1].height)));
                        nextPartsHorizontalRects.push_back(cv::Rect(intersected.x + intersected.width, currentPartsHorizontalRects[j][var].y, abs(currentPartsHorizontalRects[j][var].width - intersected.width - nextPartsHorizontalRects[nextPartsHorizontalRects.size() - 1].width), currentPartsHorizontalRects[j][var].height));

                    }
                    else
                    {
                        nextPartsHorizontalRects.push_back(currentPartsHorizontalRects[j][var]);
                    }
                }


                currentPartsHorizontalRects[j] = nextPartsHorizontalRects;
                nextPartsHorizontalRects.clear();

            }
        }
    }


    for (int j = 0; j < horizontalRects.size(); ++j)
    {
        if (currentPartsHorizontalRects.count(j) != 0) {
            for (int var = 0; var < currentPartsHorizontalRects[j].size(); ++var)
            {
                horizontalRectsFinal.push_back(currentPartsHorizontalRects[j][var]);
                cv::rectangle(imHough, cv::Point(currentPartsHorizontalRects[j][var].x, currentPartsHorizontalRects[j][var].y), cv::Point(currentPartsHorizontalRects[j][var].x + currentPartsHorizontalRects[j][var].width, currentPartsHorizontalRects[j][var].y + currentPartsHorizontalRects[j][var].height), cv::Scalar(0, 255, 255), -1);
            }
        }
   }


    for (auto& rectV : verticalRectsFinal)
    {

        areaSeams += rectV.area();
    }

    for (auto& rectH : horizontalRectsFinal)
    {

        areaSeams += rectH.area();
    }


    for (auto& rectV : verticalRectsFinal)
    {
        for (auto& rectH : horizontalRectsFinal)
        {
            if ((rectV & rectH).area() > 0)
            {
                areaSeams -= (rectV & rectH).area();
            }
        }
    }

    imageWithAllSeams = imHough.clone();

//    cv::Mat thMaskLine;
//    cv::threshold(lineoriginalImageMask, thMaskLine, 0, 255, cv::THRESH_OTSU | cv::THRESH_BINARY_INV);

//    countPixelsAllSeams = cv::countNonZero(lineImageMask);

//    int allAreaPix2 = areaoriginalImage - cv::countNonZero(thMaskLine);


   // cv::imwrite("allSeams2.png", imageWithAllSeams);

}

void BuildingDamageFinderL::setImageWithDetectDamageSeamsBuilding()
{

//  double areaoriginalImage = originalImage.rows * originalImage.cols;

    cv::Mat imHoughBad = originalImage.clone();

    cv::Mat imgProcessBad;
    cv::convertScaleAbs(originalImage, imgProcessBad, contrastAlphaDamage, 0);
    cv::cvtColor(imgProcessBad, imgProcessBad, cv::COLOR_BGR2GRAY);

    cv::Mat thBadSeams;
    cv::adaptiveThreshold(imgProcessBad, thBadSeams, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV, 11, 2);

    cv::Mat kernel = cv::Mat::ones(5,7,CV_8U);
    cv::Mat closing;
    cv::morphologyEx(thBadSeams, closing, cv::MORPH_CLOSE, kernel);

    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(closing, lines, 1, CV_PI / 180, 100, 10, 10);

    cv::Mat lineImageMask = cv::Mat::zeros(originalImage.rows,originalImage.cols,CV_8U);

    int count_lines = 0;
    std::vector<cv::Vec4i> damageLinesH;
    std::vector<cv::Vec4i> damageLinesV;

    areaDamage = 0;

    std::map<int, std::vector<cv::Vec4i>> horizontalGroupLinesDamage;
    std::map<int, std::vector<cv::Vec4i>> verticalGroupLinesDamage;


    bool flagCont = false;
    for( size_t i = 0; i < lines.size(); i++ )
    {
        cv::Vec4i l = lines[i]; // thickness
        double checkAngle = abs(atan2(l[3] - l[1], l[2] - l[0]) * 180.0 / CV_PI);

        cv::Point minPoint;
        cv::Point maxPoint;

        flagCont = false;
        for (int var = 0; var < excludeAreas.size(); ++var)
        {
            if (excludeAreas[var].contains(cv::Point(l[0], l[1])) && excludeAreas[var].contains(cv::Point(l[2], l[3])))
            {
                flagCont = true;
                break;
            }

        }
        if (!flagCont)
        {
            if (checkAngle >= 88 && checkAngle <= 90.5)
            {

                    if (l[1] > l[3])
                    {
                        minPoint.x = l[2];
                        minPoint.y = l[3];
                        maxPoint.x = l[0];
                        maxPoint.y = l[1];

                    }
                    else
                    {
                        minPoint.x = l[0];
                        minPoint.y = l[1];
                        maxPoint.x = l[2];
                        maxPoint.y = l[3];
                    }

                    l = cv::Vec4i{minPoint.x, minPoint.y, maxPoint.x, maxPoint.y};
                    for (auto& rect: verticalRectsFinal)
                    {
                        if ((rect.contains(cv::Point(l[0], l[1])) || rect.contains(cv::Point(l[2], l[3])))) // &&
                        {
                            verticalGroupLinesDamage[rect.x].push_back(l);
                            break;
                        }
                    }

                    cv::line(imHoughBad, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,255,0), 1, cv::LINE_AA); // LINE_AA
    //                cv::line(lineImageMask, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255,255,255), 1, cv::LINE_AA);
                    count_lines++;
            }


            if (checkAngle >= 0 && checkAngle <= 2.5)
            {
                    if (l[0] > l[2])
                    {
                        minPoint.x = l[2];
                        minPoint.y = l[3];
                        maxPoint.x = l[0];
                        maxPoint.y = l[1];

                    }
                    else
                    {
                        minPoint.x = l[0];
                        minPoint.y = l[1];
                        maxPoint.x = l[2];
                        maxPoint.y = l[3];
                    }

                    l = cv::Vec4i{minPoint.x, minPoint.y, maxPoint.x, maxPoint.y};

                    for (auto& rect: horizontalRectsFinal)
                    {
                        if ((rect.contains(cv::Point(l[0], l[1])) || rect.contains(cv::Point(l[2], l[3]))))
                        {
                            horizontalGroupLinesDamage[rect.y].push_back(l);
                            break;
                        }

                    }
                    cv::line(imHoughBad, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,255,0), 1, cv::LINE_AA); // LINE_AA
    //                cv::line(lineImageMask, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255,255,255), 1, cv::LINE_AA);
                    count_lines++;

            }
        }
    }
    // Объединяем вертикальные линии
    for (auto& entry: verticalGroupLinesDamage)
    {
        auto key = entry.first;
//       if (horizontalGroupLinesDamage[key].size() >=  average)
        for (int i = 0; i < verticalGroupLinesDamage[key].size(); ++i)
        {
            bool flag = false;
            for (int j = 0; j < verticalGroupLinesDamage[key].size(); ++j)
            {
                if (i != j )
                {
                    if (verticalGroupLinesDamage[key][j] != cv::Vec4i{0,0,0,0})
                    {
                        if (verticalGroupLinesDamage[key][i][1] <= verticalGroupLinesDamage[key][j][1] && verticalGroupLinesDamage[key][i][3] >= verticalGroupLinesDamage[key][j][3])
                        {
    //                        horizontalGroupLinesDamage[key][i] = horizontalGroupLinesDamage[key][j];
                            verticalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
    //                        flag = true;
                        }
                        else if (verticalGroupLinesDamage[key][i][1] >= verticalGroupLinesDamage[key][j][1] && verticalGroupLinesDamage[key][i][3] <= verticalGroupLinesDamage[key][j][3])
                        {
                            verticalGroupLinesDamage[key][i] = verticalGroupLinesDamage[key][j];
                            verticalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
                            flag = true;
                        }
                        else if (verticalGroupLinesDamage[key][i][3] <= verticalGroupLinesDamage[key][j][3] && verticalGroupLinesDamage[key][j][1] >= verticalGroupLinesDamage[key][i][1] &&  verticalGroupLinesDamage[key][j][1] <= verticalGroupLinesDamage[key][i][3])
                        {
                           verticalGroupLinesDamage[key][i][3] = verticalGroupLinesDamage[key][j][3];
    //                       verticalGroupLinesDamage[key][i][3] = verticalGroupLinesDamage[key][j][3];

                           verticalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
                           flag = true;
                        }
                        else if (verticalGroupLinesDamage[key][i][1] >= verticalGroupLinesDamage[key][j][1] && verticalGroupLinesDamage[key][j][3] >= verticalGroupLinesDamage[key][i][1] &&  verticalGroupLinesDamage[key][j][3] <= verticalGroupLinesDamage[key][i][3])
                        {
    //                        verticalGroupLinesDamage[key][i][0] = verticalGroupLinesDamage[key][j][0];
                            verticalGroupLinesDamage[key][i][1] = verticalGroupLinesDamage[key][j][1];

                            verticalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
                            flag = true;
                        }

                    }
                }

            }
            if (flag)
            {
                i--;
            }
        }
   }

    // Объединяем горизонтальные линии
    for (auto& entry: horizontalGroupLinesDamage)
    {
        auto key = entry.first;
//       if (horizontalGroupLinesDamage[key].size() >=  average)
        for (int i = 0; i < horizontalGroupLinesDamage[key].size(); ++i)
        {
            bool flag = false;
            for (int j = 0; j < horizontalGroupLinesDamage[key].size(); ++j)
            {
                if (i != j )
                {
                    if (horizontalGroupLinesDamage[key][j] != cv::Vec4i{0,0,0,0})
                    {
                        if (horizontalGroupLinesDamage[key][i][0] <= horizontalGroupLinesDamage[key][j][0] && horizontalGroupLinesDamage[key][i][2] >= horizontalGroupLinesDamage[key][j][2])
                        {
    //                        horizontalGroupLinesDamage[key][i] = horizontalGroupLinesDamage[key][j];
                            horizontalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
    //                        flag = true;
                        }
                        else if (horizontalGroupLinesDamage[key][i][0] >= horizontalGroupLinesDamage[key][j][0] && horizontalGroupLinesDamage[key][i][2] <= horizontalGroupLinesDamage[key][j][2])
                        {
                            horizontalGroupLinesDamage[key][i] = horizontalGroupLinesDamage[key][j];
                            horizontalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
                            flag = true;
                        }
                        else if (horizontalGroupLinesDamage[key][i][2] <= horizontalGroupLinesDamage[key][j][2] && horizontalGroupLinesDamage[key][j][0] >= horizontalGroupLinesDamage[key][i][0] &&  horizontalGroupLinesDamage[key][j][0] <= horizontalGroupLinesDamage[key][i][2])
                        {
                           horizontalGroupLinesDamage[key][i][2] = horizontalGroupLinesDamage[key][j][2];
    //                       horizontalGroupLinesDamage[key][i][3] = horizontalGroupLinesDamage[key][j][3];

                           horizontalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
                           flag = true;
                        }
                        else if (horizontalGroupLinesDamage[key][i][0] >= horizontalGroupLinesDamage[key][j][0] && horizontalGroupLinesDamage[key][j][2] >= horizontalGroupLinesDamage[key][i][0] &&  horizontalGroupLinesDamage[key][j][2] <= horizontalGroupLinesDamage[key][i][2])
                        {
                            horizontalGroupLinesDamage[key][i][0] = horizontalGroupLinesDamage[key][j][0];
    //                        horizontalGroupLinesDamage[key][i][1] = horizontalGroupLinesDamage[key][j][1];

                            horizontalGroupLinesDamage[key][j] = cv::Vec4i{0,0,0,0};
                            flag = true;
                        }

                    }
                }
            }
            if (flag)
            {
                i--;
            }
        }
   }


    // Чертим прямоугольники
    srand(time(NULL));

    for (auto& entry: verticalGroupLinesDamage)
    {
            auto key = entry.first;
       // cv::Scalar color = cv::Scalar(rand() % 256, rand() % 256, rand() % 256);
            cv::Scalar color = cv::Scalar(255, 191, 0);
            for (int i = 0; i < verticalGroupLinesDamage[key].size(); ++i )
            {
                auto l = verticalGroupLinesDamage[key][i];
                if (l != cv::Vec4i{0, 0, 0, 0})
                    for (auto& rectV : verticalRectsFinal)
                    {
//                        if ((rectV.x >= (l[0] - epsilonV) && rectV.x <= (l[0]+ epsilonV)) || (rectV.x >= (l[2]-epsilonV) && rectV.x <= (l[2]+ epsilonV)))
                       if (rectV.contains(cv::Point(l[0], l[1])) || rectV.contains(cv::Point(l[2], l[3]))) // не попадает
                        {
                            int left = rectV.x;
                            int top = std::min(l[1], l[3]);
                            int right = rectV.x + rectV.width;
                            int bottom = std::max(l[1], l[3]);

                            cv::rectangle(imHoughBad, cv::Point(left, top), cv::Point(right, bottom), color, -1);
                            verticalRectsDamage.push_back(cv::Rect(left, top, right - left, bottom - top));
                            areaDamage += verticalRectsDamage[verticalRectsDamage.size() - 1].area();
                            break;
                        }
                    }
            }
    }

    for (auto& entry: horizontalGroupLinesDamage)
    {
        auto key = entry.first;
        cv::Scalar color = cv::Scalar(255, 191, 0);
       // cv::Scalar color = cv::Scalar(rand() % 256, rand() % 256, rand() % 256);
//        if (horizontalGroupLinesDamage[key].size() >=  average)
            for (int i = 0; i < horizontalGroupLinesDamage[key].size(); ++i )
            {
                auto l = horizontalGroupLinesDamage[key][i];
                if (l != cv::Vec4i{0, 0, 0, 0})
                    for (auto& rectH : horizontalRectsFinal)
                    {
//                        if ((rectH.y >= (l[1] - epsilonH) && rectH.y <= (l[1]+ epsilonH)) || (rectH.y >= (l[3]-epsilonH) && rectH.y <= (l[3]+ epsilonH)))
                        if (rectH.contains(cv::Point(l[0], l[1])) || rectH.contains(cv::Point(l[2], l[3])))
                        {
                            int left = std::min(l[0], l[2]);
                            int top = rectH.y;
                            int right = std::max(l[0], l[2]);
                            int bottom = rectH.y + rectH.height;

                            cv::rectangle(imHoughBad, cv::Point(left, top), cv::Point(right, bottom), color, -1);
                            horizontalRectsDamage.push_back(cv::Rect(left, top, right - left, bottom - top));
                            areaDamage += horizontalRectsDamage[horizontalRectsDamage.size() - 1].area();
                            break;
                        }
                    }
            }
    }

    // Вычитаем пересечения
    for (int i = 0; i < verticalRectsDamage.size(); ++i)
    {
        for (int j = 0; j < horizontalRectsDamage.size(); ++j)
        {
            auto area = (verticalRectsDamage[i] & horizontalRectsDamage[j]).area();
            if (area > 0)
            {
                areaDamage -= area;
            }
        }
    }

//    cv::Mat thMaskLine;
//    cv::threshold(lineoriginalImageMask, thMaskLine, 0, 255, cv::THRESH_OTSU | cv::THRESH_BINARY_INV);

//        int allAreaPix = cv::countNonZero(lineoriginalImageMask);
//    int allAreaPix2 = areaoriginalImage - cv::countNonZero(thMaskLine);
//    countPixelsDamageSeams = cv::countNonZero(lineImageMask);
    imageWithDestroySeams =  imHoughBad;

    // cv::imwrite("badSeamsBAD.png", imageWithDestroySeams);
}

void BuildingDamageFinderL::clearParameters()
{
    areaSeams = 0;
    areaDamage = 0;
    verticalGroupLines.clear();
    horizontalGroupLines.clear();

    verticalRects.clear();
    horizontalRects.clear();
    verticalRectsDamage.clear();
    horizontalRectsDamage.clear();
    verticalRectsFinal.clear();
    horizontalRectsFinal.clear();
}

void BuildingDamageFinderL::setDefaultValuesParametersForDetectAllSeamsBuilding()
{
    contrastAlpha = 1;
    blockSizeForAdaptiveThreshold = 11;
    minLineLength = 100;
    epsilonVertical = 30;
    epsilonHorizontal = 30;
    minCountVerticalLinesInOneGroup = 5;
    minCountHorizontalLinesInOneGroup = 20;
    gaussianBlock = 0;
}

void BuildingDamageFinderL::setDefaultValuesParametersDetectDamageSeamsBuilding()
{
    contrastAlphaDamage = 4;
}

void BuildingDamageFinderL::setExcludeAreas(std::vector<cv::Rect> a)
{
    this->excludeAreas = a;
    isChanged = true;
}

void BuildingDamageFinderL::setParametersForDetectAllSeamsBuilding(double contrastAlpha, int blockSizeForAdaptiveThreshold, int minLineLength, int epsilonVertical, int epsilonHorizontal, int minCountVerticalLinesInOneGroup, int minCountHorizontalLinesInOneGroup, int gaussianBlock)
{
    this->contrastAlpha = contrastAlpha;
    this->blockSizeForAdaptiveThreshold = blockSizeForAdaptiveThreshold;
    this->minLineLength = minLineLength;
    this->epsilonVertical = epsilonVertical;
    this->epsilonHorizontal = epsilonHorizontal;
    this->minCountVerticalLinesInOneGroup = minCountVerticalLinesInOneGroup;
    this->minCountHorizontalLinesInOneGroup = minCountHorizontalLinesInOneGroup;
    this->gaussianBlock = gaussianBlock;
    isChanged = true;
}

void BuildingDamageFinderL::setParametersForDetectDamageSeamsBuilding(double contrastAlphaDamage)
{
    this->contrastAlphaDamage = contrastAlphaDamage;

    areaDamage = 0;
    verticalRectsDamage.clear();
    horizontalRectsDamage.clear();
    isChanged = true;
}

cv::Mat BuildingDamageFinderL::getImageWithDetectAllSeamsBuilding()
{
    if (!originalImage.empty())
    {
        if (isChanged)
        {
            clearParameters();
            setImageWithDetectAllSeamsBuilding(); // 1
            setImageWithDetectDamageSeamsBuilding(); // 2
            isChanged = false;
        }

        return imageWithAllSeams;
    }

    return originalImage;
}

cv::Mat BuildingDamageFinderL::getImageWithDetectDamageSeamsBuilding()
{
    if (!originalImage.empty())
    {
        if (isChanged)
        {
            clearParameters();
            setImageWithDetectAllSeamsBuilding(); // 1
            setImageWithDetectDamageSeamsBuilding(); // 2
            isChanged = false;
        }
        return imageWithDestroySeams;
    }

    return originalImage;
}

BuildingDamageFinderL::~BuildingDamageFinderL()
{

}


