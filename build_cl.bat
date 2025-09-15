cl /Ox /GL /arch:AVX2 /c rgbcx.cpp /Fo:rgbcx.obj
lib /OUT:rgbcx.lib rgbcx.obj
del rgbcx.obj
PAUSE