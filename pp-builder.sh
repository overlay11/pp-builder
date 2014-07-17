#/usr/bin/env bash

FILE=$1
DEFAULT_PP=$2
FNUMBER=$3
EXPOSURE=$4
FOCAL_LENGTH=$5
ISO=$6
LENS=$7
CAMERA=$8

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

IMPULSE_DENOISING=`echo "r = $DEFAULT_IMPULSE_DENOISING + $DENOISING_STEP * l($ISO/100)/l(2); scale=0; r/1" | bc -l`
DENOISING_LUMA=`echo "$DEFAULT_DENOISING_LUMA + $DENOISING_STEP * l($ISO/100)/l(2)" | bc -l`
DENOISING_CHROMA=`echo "$DEFAULT_DENOISING_CHROMA + $DENOISING_STEP * l($ISO/100)/l(2)" | bc -l`

cat > $FILE.pp3 <<END_OF_TEMPLATE
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

[Channel Mixer]
Red=100;0;0;
Green=0;100;0;
Blue=0;0;100;

[Luminance Curve]
Brightness=0
Contrast=0
Chromaticity=5
AvoidColorShift=true
RedAndSkinTonesProtection=0
BWtoning=false
LCredsk=true
LCurve=0;
aCurve=0;
bCurve=0;
ccCurve=0;
chCurve=0;
LcCurve=0;

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

[Color appearance]
Enabled=false
Degree=90
AutoDegree=true
Surround=Average
AdaptLum=16
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
Threshold=25

[Directional Pyramid Denoising]
Enabled=true
Luma=$DENOISING_LUMA
Ldetail=50
Chroma=$DENOISING_CHROMA
Method=RGB
Redchro=0
Bluechro=0
Gamma=2

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

[CACorrection]
Red=0
Blue=0

[Vignetting Correction]
Amount=0
Radius=50
Strength=1
CenterX=0
CenterY=0

[HLRecovery]
Enabled=false
Method=Blend

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
PreferredProfile=true
WorkingProfile=sRGB
OutputProfile=No ICM: sRGB output
Gammafree=default
Freegamma=false
GammaValue=2.2200000000000002
GammaSlope=4.5

[Directional Pyramid Equalizer]
Enabled=false
Mult0=1
Mult1=1
Mult2=1
Mult3=1
Mult4=0.20000000000000001

[HSV Equalizer]
HCurve=0;
SCurve=0;
VCurve=0;

[RGB Curves]
LumaMode=false
rCurve=0;
gCurve=0;
bCurve=0;

[RAW]
DarkFrame=
DarkFrameAuto=false
FlatFieldFile=
FlatFieldAutoSelect=false
FlatFieldBlurRadius=32
FlatFieldBlurType=Area Flatfield
CA=true
CARed=0
CABlue=0
HotDeadPixels=false
HotDeadPixelThresh=40
LineDenoise=0
GreenEqThreshold=0
CcSteps=0
Method=amaze
DCBIterations=2
DCBEnhance=false
LMMSEIterations=2
PreExposure=1
PrePreserv=0
PreBlackzero=0
PreBlackone=0
PreBlacktwo=0
PreBlackthree=0
PreTwoGreen=true
END_OF_TEMPLATE
