include make.inc

# Build directory for intermediate files
BUILD_DIR = build

BASE_SOURCES=\
	EasyWave.cpp \
	ewGpuNode.sycl.cpp \
	cOgrd.cpp \
	cOkadaEarthquake.cpp \
	cOkadaFault.cpp \
	cSphere.cpp \
	ewGrid.cpp \
	ewOut2D.cpp \
	ewParam.cpp \
	ewPOIs.cpp \
	ewSource.cpp \
	ewStep.cpp \
	okada.cpp \
	utilits.cpp

CXXFLAGS += -Wall -Wextra

ifeq ($(strip $(INLINE_KERNELS)),)
EXTRA_SOURCES=ewKernels.sycl.cpp
endif

SOURCES=$(EXTRA_SOURCES) $(BASE_SOURCES)
OBJECTS=$(patsubst %.cpp,$(BUILD_DIR)/%.o,$(SOURCES))

# Pattern rule for compiling .cpp to .o in build directory
$(BUILD_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

easywave-sycl: $(OBJECTS)
	$(CXX) $(CXXFLAGS) $^ $(LDLIBS) -o $@

.PHONY: clean

clean:
	rm -rf $(BUILD_DIR) easywave-sycl

