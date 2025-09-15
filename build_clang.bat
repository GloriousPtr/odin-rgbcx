clang -O3 -march=haswell -mavx2 -mfma -c rgbcx.cpp -o rgbcx.obj
lib /OUT:rgbcx.lib rgbcx.obj
del rgbcx.obj
PAUSE