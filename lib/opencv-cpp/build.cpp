#include "buildingdamagefinderl.h"
#include <opencv2/opencv.hpp>
#include <memory>

using namespace cv;

// struct ResParams
// {
//    double contrast;
//    double contrastDamage;
//    int blockSizeThreshold;
//    int gaussianBlockSize;
//    int minLengthLine;
//    int epsilonVertical;
//    int epsilonHorizontal;
//    int minCountVerticalLine;
//    int minCountHorizontalLine;
// };

int buildHelper(char* path, char* savePathSource, char* savePathSeams, char* savePathCrack, ResParams* p) 
{
    BuildingDamageFinderL finder;
    Mat img = imread(path);

    finder.setParametersForDetectDamageSeamsBuilding(p->contrastDamage);
    finder.setParametersForDetectAllSeamsBuilding(p->contrast, p->blockSizeThreshold, p->minLengthLine, p->epsilonVertical, p->epsilonHorizontal, p->minCountVerticalLine,  p->minCountHorizontalLine, p->gaussianBlockSize);

    finder.setImage(img);

    Mat tempSeams = finder.getImageWithDetectAllSeamsBuilding();
    Mat tempCrack = finder.getImageWithDetectDamageSeamsBuilding();

    imwrite(savePathSeams, tempSeams);
    imwrite(savePathCrack, tempCrack);
    imwrite(savePathSource, img);

    return finder.getPercentDamageSeamsBuilding();
}