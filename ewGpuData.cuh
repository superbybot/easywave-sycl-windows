#ifndef EW_GPUDATA_CUH
#define EW_GPUDATA_CUH

#if defined(__CUDACC__)
#ifndef DEVICE_FUNCTION
#define DEVICE_FUNCTION __device__
#define HOST_FUNCTION __host__
#endif
namespace easywave {
    using quad_int_t = int4;
}
#else
#include "easywave.h"
#endif

#undef idx

class Params {
public:
	int mTime;
	int nI;
	int nJ;
	int iMin;
	int iMax;
	int jMin;
	int jMax;
	float sshArrivalThreshold;
	float sshZeroThreshold;
	float sshClipThreshold;

	/* pitch / sizeof(float) */
	size_t pI;
	size_t lpad;
};

class KernelData {
public:
	/* 2-dim */
	float *d;
	float *h;
	float *hMax;
	float *fM;
	float *fN;
	float *cR1;
	float *cR2;
	float *cR4;
	float *tArr;

	/* 1-dim */
	float *cR6;
	float *cB1;
	float *cB2;
	float *cB3;
	float *cB4;

	Params params;

	easywave::quad_int_t *g_MinMax;

	DEVICE_FUNCTION int le( int ij ) { return ij - params.pI; }
	DEVICE_FUNCTION int ri( int ij ) { return ij + params.pI; }
	DEVICE_FUNCTION int up( int ij ) { return ij + 1; }
	DEVICE_FUNCTION int dn( int ij ) { return ij - 1; }
	DEVICE_FUNCTION HOST_FUNCTION int idx( int i, int j ) { return (j-1) + (i-1) * params.pI + params.lpad; }
};

#endif // EW_GPUDATA_CUH
