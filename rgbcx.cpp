#define RGBCX_IMPLEMENTATION
#include "rgbcx.h"

extern "C" {
	void rgbcx_init(rgbcx::bc1_approx_mode mode) {
		rgbcx::init(mode);
	}
	
	void rgbcx_encode_bc1(uint32_t level, void* pDst, const uint8_t* pPixels, bool allow_3color, bool use_transparent_texels_for_black) {
		rgbcx::encode_bc1(level, pDst, pPixels, allow_3color, use_transparent_texels_for_black);
	}
	
	void rgbcx_encode_bc3(uint32_t level, void* pDst, const uint8_t* pPixels) {
		rgbcx::encode_bc3(level, pDst, pPixels);
	}
	
	void rgbcx_encode_bc4(void* pDst, const uint8_t* pPixels, uint32_t stride) {
		rgbcx::encode_bc4(pDst, pPixels, stride);
	}
	
	void rgbcx_encode_bc5(void* pDst, const uint8_t* pPixels, uint32_t chan0, uint32_t chan1, uint32_t stride) {
		rgbcx::encode_bc5(pDst, pPixels, chan0, chan1, stride);
	}
}
