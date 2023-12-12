#ifndef BUILDINGDAMAGEFINDERL_H
#define BUILDINGDAMAGEFINDERL_H

#include "opencv2/imgproc.hpp"
#include "opencv2/videoio.hpp"
#include "opencv2/highgui.hpp"
#include <string>
#include <iostream>
#include <algorithm>
#include <map>

class BuildingDamageFinderL
{
public:
    BuildingDamageFinderL();
    ~BuildingDamageFinderL();

    /** @brief
     * Return a string.
     * Format Template: "Fact of destruction(+/-) Percentage of destruction"
     * Example 1: "+ 33.4%", Example 2: "- 0%"
     * On error, an string-error is returned.
    */
    int getPercentDamageSeamsBuilding();

    /** @brief
     * The function returns an image with detected seams in the image as a matrix.
     * If no image is set, then an empty image is returned ( Mat::data==NULL ).
    */
    cv::Mat getImageWithDetectAllSeamsBuilding();

    /** @brief
     * The function returns an image with detected seams in the image as a matrix.
     * If no image is set, then an empty image is returned ( Mat::data==NULL ).
    */
    cv::Mat getImageWithDetectDamageSeamsBuilding();

    /// * Loads an image from a file.
    /// * The function loads an image from the specified file and returns it.
    /// * If the image cannot be read (because of missing file, improper permissions, unsupported or invalid format),
    /// * the function returns an empty matrix ( Mat::data==NULL ).
    cv::Mat readImage(std::string pathToImage);

    /** @brief
    The function sets the image passed to the function.
    The result of the installation is returned as a boolean value.
    */
    bool setImage(cv::Mat image);

    int getAreaAllSeams();
    int getAreaDamageSeams();


    /** @brief
     * Values:
     * contrastAlpha - Simple contrast control [1.0 - 15.0]
     * blockSizeForAdaptiveThreshold - [5 - 15] ONLY ODD (5, 7, 9, 11)!!!
     * minLineLength - [50 - 100]
     * epsilonVertical - [15 - 50]
     * epsilonHorizontal - [15 - 50]
     * minCountVerticalLinesInOneGroup - [1 - 50]
     * minCountHorizontalLinesInOneGroup - [1 - 50]
     * gaussianBlock - [9 - 25] ONLY ODD
     *
     * Default:
     * contrastAlpha = 1
     * blockSizeForAdaptiveThreshold = 11
     * minLineLength = 100
     * epsilonVertical = 20
     * epsilonHorizontal = 30
     * minCountVerticalLinesInOneGroup = 10
     * minCountHorizontalLinesInOneGroup = 20
     * gaussianBlock = 9
    */
    void setParametersForDetectAllSeamsBuilding(double contrastAlpha, int blockSizeForAdaptiveThreshold, int minLineLength, int epsilonVertical, int epsilonHorizontal, int minCountVerticalLinesInOneGroup, int minCountHorizontalLinesInOneGroup, int gaussianBlock);

    /** @brief
     * Values:
     * contrastAlphaDamage - Simple contrast control [4.0 - 15.0]
     *
     * Default:
     * contrastAlphaDamage = 4
     * If you want to detect serious damage, then increase the contrast of the image.
    */
    void setParametersForDetectDamageSeamsBuilding(double contrastAlphaDamage);

    /** @brief
     * The function takes as input a vector of rectangles.
     * Each rectangle is an excluded area from the study (pipes, windows), etc.
     *
    */
    void setExcludeAreas(std::vector<cv::Rect>);

private:
    void setImageWithDetectAllSeamsBuilding();
    void setImageWithDetectDamageSeamsBuilding();
    void setDefaultValuesParametersForDetectAllSeamsBuilding();
    void setDefaultValuesParametersDetectDamageSeamsBuilding();

    void clearParameters();

private:
    cv::Mat originalImage;
    cv::Mat imageWithAllSeams;
    cv::Mat imageWithDestroySeams;

    using GroupLines = std::map<int, std::map<int, std::vector<int>>>;
    GroupLines verticalGroupLines;
    GroupLines horizontalGroupLines;

    using RectVector = std::vector<cv::Rect>;
    RectVector verticalRects;
    RectVector horizontalRects;
    RectVector verticalRectsFinal;
    RectVector horizontalRectsFinal;
    RectVector verticalRectsDamage;
    RectVector horizontalRectsDamage;

    int areaSeams = 0;
    int areaDamage = 0;

//    bool isSetDefaultParameters = true;

    double contrastAlpha;
    int blockSizeForAdaptiveThreshold;
    int minLineLength;
    int epsilonVertical;
    int epsilonHorizontal;
    int minCountVerticalLinesInOneGroup;
    int minCountHorizontalLinesInOneGroup;
    int gaussianBlock;

    double contrastAlphaDamage;
    bool isChanged = false;


    std::vector<cv::Rect> excludeAreas;

    bool checker = false;
};

#endif // BUILDINGDAMAGEFINDERL_H
