// extern "C" __attribute__((visibility("default"))) __attribute__((used))
struct ResParams
{
   double contrast;
   double contrastDamage;
   int blockSizeThreshold;
   int gaussianBlockSize;
   int minLengthLine;
   int epsilonVertical;
   int epsilonHorizontal;
   int minCountVerticalLine;
   int minCountHorizontalLine;
};

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int buildHelper(char*, char*, char*, char*, ResParams*);

#include "buildingdamagefinderl.cpp"
#include "build.cpp"