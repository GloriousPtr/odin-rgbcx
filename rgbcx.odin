package rgbcx

import "core:c"

foreign import rgbcx "rgbcx.lib"

/*
Instructions:

The library MUST be initialized by calling this function at least once before using any encoder or decoder functions:

init :: proc(mode: bc1_approx_mode = .BC1Ideal)

This function manipulates global state, so it is not thread safe.
You can call it multiple times to change the global BC1 approximation mode.
Important: BC1/3 textures encoded using non-ideal BC1 approximation modes should only be sampled on parts from that vendor.
If you encode for AMD, average error on AMD parts will go down, but average error on NVidia parts will go up and vice versa.
If in doubt, encode in ideal BC1 mode.

Call these functions to encode BC1-5:
encode_bc1 :: proc(level: c.uint32_t, pDst: rawptr, pPixels: ^c.uint8_t, allow_3color: c.bool, use_transparent_texels_for_black: c.bool)
encode_bc3 :: proc(level: c.uint32_t, pDst: rawptr, pPixels: ^c.uint8_t)
encode_bc4 :: proc(pDst: rawptr, pPixels: ^c.uint8_t, stride: c.uint32_t = 4)
encode_bc5 :: proc(pDst: rawptr, pPixels: ^c.uint8_t, chan0: c.uint32_t = 0, chan1: c.uint32_t = 1, stride: c.uint32_t = 4)

- level ranges from MIN_LEVEL to MAX_LEVEL. The higher the level, the slower the encoder goes, but the higher the average quality.
levels [0,4] are fast and compete against stb_dxt (default and HIGHQUAL). The remaining levels compete against squish/NVTT/icbc and icbc HQ.
If in doubt just use level 10, set allow_3color to true and use_transparent_texels_for_black to false, and adjust as needed.

- pDst is a pointer to the 8-byte (BC1/4) or 16-byte (BC3/5) destination block.

- pPixels is a pointer to the 32-bpp pixels, in either RGBX or RGBA format (R is first in memory).
Alpha is always ignored by encode_bc1().

- allow_3color: If true the encoder will use 3-color blocks. This flag is ignored unless level is >= 5 (because lower levels compete against stb_dxt and it doesn't support 3-color blocks).
Do not enable on BC3-5 textures. 3-color block usage slows down encoding.

- use_transparent_texels_for_black: If true the encoder will use 3-color block transparent black pixels to code very dark or black texels. Your engine/shader MUST ignore the sampled
alpha value for textures encoded in this mode. This is how NVidia's classic "nvdxt" encoder (used by many original Xbox titles) used to work by default on DXT1C textures. It increases
average quality substantially (because dark texels/black are very common) and is highly recommended.
Do not enable on BC3-5 textures.

- stride is the source pixel stride, in bytes. It's typically 4.

- chan0 and chan1 are the source channels. Typically they will be 0 and 1.

All encoding and decoding functions are threade-safe.
*/

bc1_approx_mode :: enum c.int {
	BC1Ideal        = 0, // The default mode. No rounding for 4-color colors 2,3. My older tools/compressors use this mode. This matches the D3D10 docs on BC1.
	BC1NVidia       = 1, // NVidia GPU mode.
	BC1AMD          = 2, // AMD GPU mode.
	BC1IdealRound4  = 3, // This mode matches AMD Compressonator's output. It rounds 4-color colors 2,3 (not 3-color color 2). This matches the D3D9 docs on DXT1.
}

@(default_calling_convention = "c", link_prefix="rgbcx_")
foreign rgbcx {
	/*
	init MUST be called once before using the BC1 encoder.
	This function may be called multiple times to change the BC1 approximation mode.
	This function initializes global state, so don't call it while other threads inside the encoder.
	Important: If you encode textures for a specific vendor's GPU's, beware that using that texture data on other GPU's may result in ugly artifacts.
	Encode to cBC1Ideal unless you know the texture data will only be deployed or used on a specific vendor's GPU.
	*/
	init :: proc(mode: bc1_approx_mode = .BC1Ideal) ---

	/*
	Encodes a 4x4 block of RGBX (X=ignored) pixels to BC1 format.
	This is the simplified interface for BC1 encoding, which accepts a level parameter and converts that to the best overall flags.
	The pixels are in RGBA format, where R is first in memory. The BC1 encoder completely ignores the alpha channel (i.e. there is no punchthrough alpha support).
	This is the recommended function to use for BC1 encoding, becuase it configures the encoder for you in the best possible way (on average).
	Note that the 3 color modes won't be used at all until level 5 or higher.
	No transparency supported, however if you set use_transparent_texels_for_black to true the encocer will use transparent selectors on very dark/black texels to reduce MSE.
	*/
	encode_bc1 :: proc(level: c.uint32_t, pDst: rawptr, pPixels: ^c.uint8_t, allow_3color: c.bool, use_transparent_texels_for_black: c.bool) ---

	/*
	Encodes a 4x4 block of RGBA pixels to BC3 format.
	There are two encode_bc3() functions.
	The first is the recommended function, which accepts a level parameter.
	The second is a low-level version that allows fine control over BC1 encoding.
	*/
	encode_bc3 :: proc(level: c.uint32_t, pDst: rawptr, pPixels: ^c.uint8_t) ---

	/*
	Encodes a single channel to BC4.
	stride is the source pixel stride in bytes.
	*/
	encode_bc4 :: proc(pDst: rawptr, pPixels: ^c.uint8_t, stride: c.uint32_t = 4) ---

	/*
	Encodes two channels to BC5.
	chan0/chan1 control which channels, stride is the source pixel stride in bytes.
	*/
	encode_bc5 :: proc(pDst: rawptr, pPixels: ^c.uint8_t, chan0: c.uint32_t = 0, chan1: c.uint32_t = 1, stride: c.uint32_t = 4) ---
}
