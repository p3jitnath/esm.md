FC = gfortran
CC = gcc
SW_CPU ?= neoverse-v2
BUILD := bench/.build
SOLVER := src/shallow_water/solver
BASE_FFLAGS := -O3 -mcpu=$(SW_CPU) -msve-vector-bits=128 -fPIC -fno-fast-math -ffp-contract=off -fprotect-parens
FFLAGS := $(BASE_FFLAGS) --param=max-unswitch-insns=600 -fopenmp-simd
EBM_FFLAGS := $(FFLAGS) -funroll-loops -finline-limit=1000
ASFLAGS := -O3 -mcpu=$(SW_CPU) -fPIC

.PHONY: all clean
all: $(BUILD)/libsw_fortran_vanilla.so $(BUILD)/libsw_fortran.so $(BUILD)/libsw_assembly.so $(BUILD)/libfp_env.so $(BUILD)/libroofline.so $(BUILD)/libcounters.so

$(BUILD):
	mkdir -p $@

$(BUILD)/libsw_fortran.so: $(SOLVER).f90 Makefile | $(BUILD)
	rm -f $(BUILD)/fortran-vector.txt
	$(FC) $(FFLAGS) -J$(BUILD) -shared -fopt-info-vec-optimized=$(BUILD)/fortran-vector.txt $< -o $@

$(BUILD)/libsw_fortran_vanilla.so: src/shallow_water/vanilla.f90 Makefile | $(BUILD)
	rm -f $(BUILD)/fortran-vanilla-vector.txt
	$(FC) $(BASE_FFLAGS) -J$(BUILD) -shared -fopt-info-vec-optimized=$(BUILD)/fortran-vanilla-vector.txt $< -o $@

$(BUILD)/libfp_env.so: bench/fp_env.S Makefile | $(BUILD)
	$(CC) $(ASFLAGS) -shared $< -o $@

$(BUILD)/libsw_assembly.so: $(SOLVER).S Makefile | $(BUILD)
	$(CC) $(ASFLAGS) -shared $< -o $@

$(BUILD)/libroofline.so: bench/roofline.S Makefile | $(BUILD)
	$(CC) $(ASFLAGS) -shared $< -o $@

$(BUILD)/libcounters.so: bench/counters.c Makefile | $(BUILD)
	$(CC) -O2 -mcpu=$(SW_CPU) -fPIC -std=c11 -Wall -Wextra -shared $< -o $@

clean:
	rm -rf $(BUILD)

# GPU assembly is assembled directly; the driver contains only host CUDA calls.
GPU_SDK ?= /opt/nvidia/hpc_sdk/Linux_aarch64/24.11
CUDA_HOME ?= $(GPU_SDK)/cuda
PTXAS ?= $(CUDA_HOME)/bin/ptxas
NVFORTRAN ?= $(GPU_SDK)/compilers/bin/nvfortran
CXX ?= g++
GPU_BUILD := $(BUILD)/gpu
GPU_FFLAGS := -O3 -cuda -gpu=cc90,nofma,noflushz,nordc,keep,cuda12.6 -Kieee

.PHONY: gpu gpu-reference
gpu: $(GPU_BUILD)/libdriver.so $(GPU_BUILD)/sw_assembly.cubin $(GPU_BUILD)/eb_assembly.cubin $(GPU_BUILD)/sw_fortran_vanilla.cubin $(GPU_BUILD)/eb_fortran_vanilla.cubin $(GPU_BUILD)/sw_fortran.cubin $(GPU_BUILD)/eb_fortran.cubin
gpu-reference: $(BUILD)/libsw_fortran_vanilla.so $(BUILD)/libeb_fortran_vanilla.so $(BUILD)/libfp_env.so

$(GPU_BUILD):
	mkdir -p $@

$(GPU_BUILD)/libdriver.so: bench/gpu/driver.cpp Makefile | $(GPU_BUILD)
	$(CXX) -O2 -std=c++17 -fPIC -Wall -Wextra -shared -I$(CUDA_HOME)/include $< -L$(CUDA_HOME)/lib64/stubs -lcuda -o $@

$(GPU_BUILD)/sw_assembly.cubin: src/shallow_water/gpu/solver.ptx Makefile | $(GPU_BUILD)
	$(PTXAS) -arch=sm_90 --fmad=false -v $< -o $@ 2>$(GPU_BUILD)/sw_assembly-build.txt

$(GPU_BUILD)/eb_assembly.cubin: src/budyko_sellers/gpu/solver.ptx Makefile | $(GPU_BUILD)
	$(PTXAS) -arch=sm_90 --fmad=false -v $< -o $@ 2>$(GPU_BUILD)/eb_assembly-build.txt

$(GPU_BUILD)/%_fortran_vanilla.cubin: Makefile | $(GPU_BUILD)
	mkdir -p $(GPU_BUILD)/$*_fortran_vanilla
	cd $(GPU_BUILD)/$*_fortran_vanilla && $(NVFORTRAN) $(GPU_FFLAGS) -c ../../../../src/$(if $(filter sw,$*),shallow_water,budyko_sellers)/gpu/vanilla.cuf -o vanilla.o >build.txt 2>&1
	cp $(GPU_BUILD)/$*_fortran_vanilla/vanilla.n001.cubin $@

$(GPU_BUILD)/%_fortran.cubin: Makefile | $(GPU_BUILD)
	mkdir -p $(GPU_BUILD)/$*_fortran
	cd $(GPU_BUILD)/$*_fortran && $(NVFORTRAN) $(GPU_FFLAGS) -c ../../../../src/$(if $(filter sw,$*),shallow_water,budyko_sellers)/gpu/solver.cuf -o solver.o >build.txt 2>&1
	cp $(GPU_BUILD)/$*_fortran/solver.n001.cubin $@

$(GPU_BUILD)/sw_fortran_vanilla.cubin: src/shallow_water/gpu/vanilla.cuf
$(GPU_BUILD)/eb_fortran_vanilla.cubin: src/budyko_sellers/gpu/vanilla.cuf
$(GPU_BUILD)/sw_fortran.cubin: src/shallow_water/gpu/solver.cuf
$(GPU_BUILD)/eb_fortran.cubin: src/budyko_sellers/gpu/solver.cuf

.PHONY: ebm
ebm: $(BUILD)/libeb_fortran_vanilla.so $(BUILD)/libeb_fortran.so $(BUILD)/libeb_assembly.so $(BUILD)/libfp_env.so $(BUILD)/libcounters.so

$(BUILD)/libeb_fortran_vanilla.so: src/budyko_sellers/vanilla.f90 Makefile | $(BUILD)
	$(FC) $(BASE_FFLAGS) -J$(BUILD) -shared $< -o $@

$(BUILD)/libeb_fortran.so: src/budyko_sellers/solver.f90 Makefile | $(BUILD)
	$(FC) $(EBM_FFLAGS) -J$(BUILD) -shared -fopt-info-vec-optimized=$(BUILD)/ebm-vector.txt $< -o $@

$(BUILD)/libeb_assembly.so: src/budyko_sellers/solver.S Makefile | $(BUILD)
	$(CC) $(ASFLAGS) -shared $< -o $@
