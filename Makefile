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

.PHONY: ebm
ebm: $(BUILD)/libeb_fortran_vanilla.so $(BUILD)/libeb_fortran.so $(BUILD)/libeb_assembly.so $(BUILD)/libfp_env.so $(BUILD)/libcounters.so

$(BUILD)/libeb_fortran_vanilla.so: src/budyko_sellers/vanilla.f90 Makefile | $(BUILD)
	$(FC) $(BASE_FFLAGS) -J$(BUILD) -shared $< -o $@

$(BUILD)/libeb_fortran.so: src/budyko_sellers/solver.f90 Makefile | $(BUILD)
	$(FC) $(EBM_FFLAGS) -J$(BUILD) -shared -fopt-info-vec-optimized=$(BUILD)/ebm-vector.txt $< -o $@

$(BUILD)/libeb_assembly.so: src/budyko_sellers/solver.S Makefile | $(BUILD)
	$(CC) $(ASFLAGS) -shared $< -o $@
