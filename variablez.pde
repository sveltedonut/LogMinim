float leftMax = 0;
float rightMax = 0;
float mixMax = 0;
float rightAvg = 0;
float leftAvg = 0;
float mixAvg = 0;
int lMaxFreq = 0;
int rMaxFreq = 0;
int mMaxFreq = 0;
float[] lm = new float[4];
float[] rm = new float[4];
int[] lmf = new int[4];
int[] rmf = new int[4];

float[] left = new float[432];
float[] right = new float[432];

int backH = 0;
int backS = 0;
int backB = 0;
int tempBackH = 0;
int tempBackS = 0;
int tempBackB = 0;
int backChange = 1;
int backTime = backChange;
int backFlow = 127;

int menuOn;
boolean pause = false;
boolean serialOn = false;

int scrollPos = 0;
