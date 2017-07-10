#!/usr/bin/env sh

FILE=$1

value() {
    KEY=$1; grep -m 1 ^$KEY= $FILE | cut -d= -f2
}

round() {
    echo "r=$1; scale=0; r/1" | bc -l
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
DEFAULT_UNSHARP_MASK_AMOUNT=275
UNSHARP_MASK_AMOUNT_STEP=25
VIBRANCE=15
WIDTH=1600
HEIGHT=1200

AUTHOR='Alexey Kopeikin <kopeikin88@gmail.com>'

DEFAULT_IMPULSE_DENOISING=60
IMPULSE_DENOISING_STEP=5
DEFAULT_DENOISING_LUMA=15
DENOISING_LUMA_STEP=7.5
DEFAULT_DENOISING_LUMA_DETAIL=45
DENOISING_LUMA_DETAIL_STEP=5
DEFAULT_DENOISING_CHROMA=40
DENOISING_CHROMA_STEP=10

DEFAULT_CONTRAST=1
CONTRAST_STEP=0.05

ISO_THRESHOLD=800

STEP_COUNT=`echo "l($ISO/100)/l(2)" | bc -l`

RANK=`echo "6.5 - $STEP_COUNT" | bc -l`; RANK=`round $RANK`

if [ $RANK -le 2 ]; then
    STEP_COUNT=4
fi

UNSHARP_MASK_AMOUNT=`echo "$DEFAULT_UNSHARP_MASK_AMOUNT - $UNSHARP_MASK_AMOUNT_STEP * $STEP_COUNT" | bc -l`; UNSHARP_MASK_AMOUNT=`round $UNSHARP_MASK_AMOUNT`

IMPULSE_DENOISING=`echo "$DEFAULT_IMPULSE_DENOISING + $IMPULSE_DENOISING_STEP * $STEP_COUNT" | bc -l`; IMPULSE_DENOISING=`round $IMPULSE_DENOISING`
DENOISING_LUMA=`echo "$DEFAULT_DENOISING_LUMA + $DENOISING_LUMA_STEP * $STEP_COUNT" | bc -l`
DENOISING_LUMA_DETAIL=`echo "$DEFAULT_DENOISING_LUMA_DETAIL + $DENOISING_LUMA_DETAIL_STEP * $STEP_COUNT" | bc -l`
DENOISING_CHROMA=`echo "$DEFAULT_DENOISING_CHROMA + $DENOISING_CHROMA_STEP * $STEP_COUNT" | bc -l`

LEVEL0_CONTRAST=`echo "$DEFAULT_CONTRAST - 2.5 * $CONTRAST_STEP * ($STEP_COUNT - 1)" | bc -l`
LEVEL1_CONTRAST=`echo "$DEFAULT_CONTRAST - 1.5 * $CONTRAST_STEP * ($STEP_COUNT - 1)" | bc -l`
LEVEL2_CONTRAST=`echo "$DEFAULT_CONTRAST - 0.5 * $CONTRAST_STEP * ($STEP_COUNT - 1)" | bc -l`
LEVEL3_CONTRAST=`echo "$DEFAULT_CONTRAST + 0.5 * $CONTRAST_STEP * ($STEP_COUNT - 1)" | bc -l`
LEVEL4_CONTRAST=`echo "$DEFAULT_CONTRAST + 1.5 * $CONTRAST_STEP * ($STEP_COUNT - 1)" | bc -l`

if [ $ISO -ge $ISO_THRESHOLD ]; then
    DEMOSAICING_METHOD=igv
else
    DEMOSAICING_METHOD=amaze
fi

cat > $OUTPUT_FILE <<END_OF_TEMPLATE
[General]
Rank=$RANK
ColorLabel=0
InTrash=false

[Exposure]
Auto=true
Clip=0.02
Compensation=0
Brightness=0
Contrast=0
Saturation=0
Black=0
HighlightCompr=0
HighlightComprThreshold=33
ShadowCompr=50
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
Method=ChannelMixer
Auto=false
ComplementaryColors=true
Setting=RGB-Rel
Filter=None
MixerRed=33
MixerOrange=33
MixerYellow=33
MixerGreen=33
MixerCyan=33
MixerBlue=33
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
Chromaticity=0
AvoidColorShift=false
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
EdgedetectionRadius=1.9
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
PSThreshold=0;75;
ProtectSkins=true
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
Temperature=6200
Green=1
Equal=1

[Color appearance]
Enabled=false
Degree=90
AutoDegree=true
Surround=Average
AdaptLum=16
Badpixsl=0
Model=RawT
Algorithm=No
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
Threshold=13
HueCurve=1;0.167;0;0.35;0.35;0.347;0;0.35;0.35;0.514;0;0.35;0.35;0.669;0;0.35;0.35;0.829;0.978;0.35;0.35;0.991;0;0.35;0.35;

[Directional Pyramid Denoising]
Enabled=true
Enhance=true
Median=true
Luma=$DENOISING_LUMA
Ldetail=$DENOISING_LUMA_DETAIL
Chroma=$DENOISING_CHROMA
Method=Lab
SMethod=shalbi
MedMethod=soft
RGBMethod=soft
MethodMed=Lab
Redchro=0
Bluechro=0
Gamma=1.7
Passes=1
LCurve=0;

[EPD]
Enabled=false
Strength=0.25
EdgeStopping=1.4
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
Radius=40

[Crop]
Enabled=false
X=0
Y=0
W=4048
H=3032
FixedRatio=true
Ratio=4:3
Orientation=Landscape
Guide=Frame

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
Strength=0.67
CenterX=0
CenterY=0

[PCVignette]
Enabled=false
Strength=0.33
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
Scale=1
AppliesTo=Cropped area
Method=Lanczos
DataSpecified=3
Width=$WIDTH
Height=$HEIGHT

[Color Management]
InputProfile=(cameraICC)
ToneCurve=false
BlendCMSMatrix=false
DCPIlluminant=0
WorkingProfile=ProPhoto
OutputProfile=RT_sRGB
Gammafree=default
Freegamma=false
GammaValue=2.22
GammaSlope=4.5

[Directional Pyramid Equalizer]
Enabled=true
Gamutlab=false
Mult0=$LEVEL0_CONTRAST
Mult1=$LEVEL1_CONTRAST
Mult2=$LEVEL2_CONTRAST
Mult3=$LEVEL3_CONTRAST
Mult4=$LEVEL4_CONTRAST
Threshold=0.2
Skinprotect=0
Hueskin=-5;25;170;120;

[HSV Equalizer]
HCurve=0;
SCurve=0;
VCurve=0;

[Film Simulation]
Enabled=false
ClutFilename=
Strength=100

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
OpacityCurve=1;0;0.3;0.35;0;0.25;0.8;0.35;0.35;0.7;0.8;0.35;0.35;1;0.3;0;0;
ColorCurve=1;0.05;0.62;0.25;0.25;0.585;0.11;0.25;0.25;
SatProtectionThreshold=30
SaturatedOpacity=80
Strength=50
HighlightsColorSaturation=60;80;
ShadowsColorSaturation=80;208;
ClCurve=3;0;0;0.35;0.65;1;1;
Cl2Curve=3;0;0;0.35;0.65;1;1;

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
HotPixelFilter=true
DeadPixelFilter=false
HotDeadPixelThresh=40
PreExposure=1
PrePreserv=0

[RAW Bayer]
Method=$DEMOSAICING_METHOD
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

[Exif]
Artist=$AUTHOR
Copyright=#delete
Exif=#delete
ImageDescription=$CAMERA + $LENS
Make=#delete
Model=#delete
END_OF_TEMPLATE
