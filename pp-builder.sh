#/usr/bin/env bash

FILE=$1

value() {
    KEY=$1; grep -m 1 ^$KEY= $FILE | cut -d= -f2
}

if [ $# -gt 1 ]; then
    DEFAULT_PP=$2
    FNUMBER=$3
    EXPOSURE=$4
    FOCAL_LENGTH=$5
    ISO=$6
    LENS=$7
    CAMERA=$8
    OUTPUT_FILE=$FILE.pp3
else
    DEFAULT_PP=`value DefaultProcParams`
    FNUMBER=`value FNumber`
    EXPOSURE=`value Shutter`
    FOCAL_LENGTH=`value FocalLength`
    ISO=`value ISO`
    LENS=`value Lens`
    CAMERA="`value Make` `value Model`"
    OUTPUT_FILE=`value OutputProfileFileName`
fi

CLARITY=20
UNSHARP_MASK_RADIUS=0.8
UNSHARP_MASK_AMOUNT=250
VIBRANCE=25
WIDTH=1600
HEIGHT=1200

DEFAULT_IMPULSE_DENOISING=60
DEFAULT_DENOISING_LUMA=25
DEFAULT_DENOISING_CHROMA=10
DENOISING_STEP=5

DEFAULT_CONTRAST=1
CONTRAST_STEP=0.025

IMPULSE_DENOISING=`echo "r = $DEFAULT_IMPULSE_DENOISING + $DENOISING_STEP * l($ISO/100)/l(2); scale=0; r/1" | bc -l`
DENOISING_LUMA=`echo "$DEFAULT_DENOISING_LUMA + $DENOISING_STEP * l($ISO/100)/l(2)" | bc -l`
DENOISING_CHROMA=`echo "$DEFAULT_DENOISING_CHROMA + $DENOISING_STEP * l($ISO/100)/l(2)" | bc -l`

LEVEL0_CONTRAST=`echo "$DEFAULT_CONTRAST + 4 * $CONTRAST_STEP * l($ISO/200)/l(2)" | bc -l`
LEVEL1_CONTRAST=`echo "$DEFAULT_CONTRAST + 3 * $CONTRAST_STEP * l($ISO/200)/l(2)" | bc -l`
LEVEL2_CONTRAST=`echo "$DEFAULT_CONTRAST + 2 * $CONTRAST_STEP * l($ISO/200)/l(2)" | bc -l`
LEVEL3_CONTRAST=`echo "$DEFAULT_CONTRAST + $CONTRAST_STEP * l($ISO/200)/l(2)" | bc -l`

cat > $OUTPUT_FILE <<END_OF_TEMPLATE
[General]
Rank=0
ColorLabel=0
InTrash=false

[Exposure]
Auto=true
Clip=0
Compensation=0.35999999999999999
Brightness=1
Contrast=25
Saturation=0
Black=0
HighlightCompr=41
HighlightComprThreshold=33
ShadowCompr=0
CurveMode=Standard
CurveMode2=Standard
Curve=0;
Curve2=0;

[HLRecovery]
Enabled=false
Method=Blend

[Channel Mixer]
Red=100;0;0;
Green=0;100;0;
Blue=0;0;100;

[Black & White]
Enabled=false
Method=Desaturation
Auto=false
ComplementaryColors=true
Setting=NormalContrast
Filter=None
MixerRed=43
MixerOrange=33
MixerYellow=33
MixerGreen=33
MixerCyan=33
MixerBlue=30
MixerMagenta=33
MixerPurple=33
GammaRed=0
GammaGreen=0
GammaBlue=0
Algorithm=SP
LuminanceCurve=0;
BeforeCurveMode=Standard
AfterCurveMode=Standard
BeforeCurve=0;
AfterCurve=0;

[Luminance Curve]
Brightness=0
Contrast=0
Chromaticity=5
AvoidColorShift=true
RedAndSkinTonesProtection=0
LCredsk=true
LCurve=0;
aCurve=0;
bCurve=0;
ccCurve=0;
chCurve=0;
lhCurve=0;
hhCurve=0;
LcCurve=0;
ClCurve=0;

[Sharpening]
Enabled=true
Method=usm
Radius=$UNSHARP_MASK_RADIUS
Amount=$UNSHARP_MASK_AMOUNT
Threshold=20;80;2000;1200;
OnlyEdges=false
EdgedetectionRadius=1.8999999999999999
EdgeTolerance=1800
HalocontrolEnabled=false
HalocontrolAmount=85
DeconvRadius=0.75
DeconvAmount=75
DeconvDamping=20
DeconvIterations=30

[Vibrance]
Enabled=true
Pastels=$VIBRANCE
Saturated=$VIBRANCE
PSThreshold=0;0;
ProtectSkins=false
AvoidColorShift=true
PastSatTog=true
SkinTonesCurve=0;

[SharpenEdge]
Enabled=false
Passes=2
Strength=50
ThreeChannels=false

[SharpenMicro]
Enabled=false
Matrix=false
Strength=20
Uniformity=50

[White Balance]
Setting=Camera
Temperature=6345
Green=1.006
Equal=1

[Color appearance]
Enabled=false
Degree=90
AutoDegree=true
Surround=Average
AdaptLum=16
Badpixsl=0
Model=RawT
Algorithm=JC
J-Light=0
Q-Bright=0
C-Chroma=0
S-Chroma=0
M-Chroma=0
J-Contrast=0
Q-Contrast=0
H-Hue=0
RSTProtection=0
AdaptScene=2000
AutoAdapscen=true
SurrSource=false
Gamut=true
Datacie=false
Tonecie=false
CurveMode=Lightness
CurveMode2=Lightness
CurveMode3=Chroma
Curve=0;
Curve2=0;
Curve3=0;

[Impulse Denoising]
Enabled=true
Threshold=$IMPULSE_DENOISING

[Defringing]
Enabled=false
Radius=2
Threshold=12
HueCurve=1;0.16666666699999999;0;0.34999999999999998;0.34999999999999998;0.34699999999999998;0;0.34999999999999998;0.34999999999999998;0.51366742600000004;0;0.34999999999999998;0.34999999999999998;0.66894457100000004;0;0.34999999999999998;0.34999999999999998;0.82877752459999998;0.97835991;0.34999999999999998;0.34999999999999998;0.99088838270000001;0;0.34999999999999998;0.34999999999999998;

[Directional Pyramid Denoising]
Enabled=true
Enhance=false
Median=true
Luma=$DENOISING_LUMA
Ldetail=50
Chroma=$DENOISING_CHROMA
Method=RGB
MedMethod=soft
RGBMethod=soft
MethodMed=Lonly
Redchro=0
Bluechro=0
Gamma=2
Passes=1

[EPD]
Enabled=false
Strength=0.25
EdgeStopping=1.3999999999999999
Scale=1
ReweightingIterates=0

[Shadows & Highlights]
Enabled=true
HighQuality=true
Highlights=0
HighlightTonalWidth=80
Shadows=0
ShadowTonalWidth=80
LocalContrast=$CLARITY
Radius=30

[Crop]
Enabled=false
X=0
Y=0
W=4048
H=3032
FixedRatio=false
Ratio=3:2
Orientation=Landscape
Guide=None

[Coarse Transformation]
Rotate=0
HorizontalFlip=false
VerticalFlip=false

[Common Properties for Transformations]
AutoFill=true

[Rotation]
Degree=0

[Distortion]
Amount=0

[LensProfile]
LCPFile=
UseDistortion=true
UseVignette=true
UseCA=true

[Perspective]
Horizontal=0
Vertical=0

[Gradient]
Enabled=false
Degree=0
Feather=25
Strength=0.59999999999999998
CenterX=0
CenterY=0

[PCVignette]
Enabled=false
Strength=0.59999999999999998
Feather=50
Roundness=50

[CACorrection]
Red=0
Blue=0

[Vignetting Correction]
Amount=0
Radius=50
Strength=1
CenterX=0
CenterY=0

[Resize]
Enabled=true
Scale=0.29999999999999999
AppliesTo=Cropped area
Method=Lanczos
DataSpecified=3
Width=$WIDTH
Height=$HEIGHT

[Color Management]
InputProfile=(camera)
ToneCurve=false
BlendCMSMatrix=true
DCPIlluminant=0
WorkingProfile=sRGB
OutputProfile=No ICM: sRGB output
Gammafree=default
Freegamma=false
GammaValue=2.2200000000000002
GammaSlope=4.5

[Directional Pyramid Equalizer]
Enabled=true
Gamutlab=false
Mult0=$LEVEL0_CONTRAST
Mult1=$LEVEL1_CONTRAST
Mult2=$LEVEL2_CONTRAST
Mult3=$LEVEL3_CONTRAST
Mult4=0.20000000000000001
Threshold=0.20000000000000001
Skinprotect=0
Hueskin=-5;25;170;120;

[HSV Equalizer]
HCurve=0;
SCurve=0;
VCurve=0;

[RGB Curves]
LumaMode=false
rCurve=0;
gCurve=0;
bCurve=0;

[ColorToning]
Enabled=false
Method=Lab
Lumamode=true
Twocolor=Std
Redlow=0
Greenlow=0
Bluelow=0
Satlow=0
Balance=0
Sathigh=0
Redmed=0
Greenmed=0
Bluemed=0
Redhigh=0
Greenhigh=0
Bluehigh=0
Autosat=true
OpacityCurve=1;0;0.29999999999999999;0.34999999999999998;0;0.25;0.80000000000000004;0.34999999999999998;0.34999999999999998;0.69999999999999996;0.80000000000000004;0.34999999999999998;0.34999999999999998;1;0.29999999999999999;0;0;
ColorCurve=1;0.050000000000000003;0.62;0.25;0.25;0.58499999999999996;0.11;0.25;0.25;
SatProtectionThreshold=80
SaturatedOpacity=30
Strengthprotection=50
HighlightsColorSaturation=60;80;
ShadowsColorSaturation=80;208;
ClCurve=3;0;0;0.34999999999999998;0.65000000000000002;1;1;
Cl2Curve=3;0;0;0.34999999999999998;0.65000000000000002;1;1;

[RAW]
DarkFrame=
DarkFrameAuto=false
FlatFieldFile=
FlatFieldAutoSelect=false
FlatFieldBlurRadius=32
FlatFieldBlurType=Area Flatfield
FlatFieldAutoClipControl=false
FlatFieldClipControl=false
CA=true
CARed=0
CABlue=0
HotDeadPixels=false
HotDeadPixelThresh=40
PreExposure=1
PrePreserv=0

[RAW Bayer]
Method=amaze
CcSteps=0
PreBlack0=0
PreBlack1=0
PreBlack2=0
PreBlack3=0
PreTwoGreen=true
LineDenoise=0
GreenEqThreshold=0
DCBIterations=2
DCBEnhance=false
LMMSEIterations=2

[RAW X-Trans]
Method=3-pass (best)
CcSteps=0
PreBlackRed=0
PreBlackGreen=0
PreBlackBlue=0
END_OF_TEMPLATE
