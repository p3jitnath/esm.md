# Soil Water Recovery Contract

Revision 1 freezes complete SRFWINC from [Soil Water And Drainage](../../../../../formulations/openifs/surface/soil_water_increment.md), WI-1 and WI-2. A diagnostic is a value saved to explain a calculation. This routine recovers the water state, completes every layer flux and writes the supplied diagnostics. It does not supply the preceding soil diffusion solve.

## Ordered Arithmetic

FP64 stores each real number in sixty-four bits. RN means one operation rounded to the nearest FP64 value, with an even final bit at an exact halfway point. Require the floating-point control register, FPCR, to equal zero. Preserve signed zeros and gradual underflow, with separate division, multiplication, addition and subtraction.

Set a=RN(1/RSIMP), b=RN(a−1) and c=RN(RHOH2O/PTMST). For each land cell and layer, write PWSA=RN(PWSADIF−RN(b×PWSAM1M)). Above the bottom layer, set d=RN(PWSADIF_current−PWSADIF_next), e=RN(c×PCFW), e=RN(e×d) and PSAWGFL=RN(PSAWGFL+e). Preserve incoming bottom drainage. Sea cells copy PWSAM1M to PWSA and write positive zero to PSAWGFL.

Copy the top-layer flux to PWFSD. If the diagnostic descriptor has a nonzero total extent, copy every active layer flux to PDHWLS field eight and write RN(PDHWLS_bottom_field6−PSAWGFL_bottom) to field six. Preserve every other owner bit. The source declares PSAWGFL as output, but its complete calculation reads the incoming gravity flux, which is therefore required by this contract. The unused RDAW alias and reciprocal-density temporary do not supply numerical output.

## Interface And Storage

The application binary interface, or ABI, defines argument addresses and registers that a routine must preserve. Thirteen addresses supply KIDIA, KFDIA, KLEVS, PTMST, PWSAM1M, PWSADIF, PSAWGFL, PCFW, TSOIL, PWSA, PWFSD, LDLAND and PDHWLS. The first eight arrive in x0 through x7, followed by five eight-byte addresses on the entry stack. Integer and logical scalars occupy four bytes, while FP64 values occupy eight.

TSOIL has 2416 bytes, and RSIMP is at byte 144. Reuse the unchanged reviewed object size, with the new scalar offset confirmed by a layout probe. Water density comes from __yos_thf_MOD_rhoh2o. This routine does not read the soil array descriptors in TSOIL.

Arrays use GNU assumed-shape descriptors. The base address is at byte zero, and each dimension records element stride, lower bound and upper bound at bytes forty, forty-eight and fifty-six, with twenty-four bytes between dimensions. Logical land entries use four-byte elements, while other arrays use eight-byte elements. Their dummy indices start at one, regardless of supplied lower bounds. Use signed strides from the first logical element.

Require 1≤C≤4096 columns, 1≤KLEVS≤512 layers, 1≤KIDIA≤C and KIDIA−1≤KFDIA≤C. The empty interval performs no writes. All active inputs, gravity fluxes and intermediates are finite. PTMST and water density are positive, and 0<RSIMP≤1. The recovered water is a preliminary state. It can be below zero or above the saturation limit before the immediately following SRFWNG water correction. Check the physical water bounds after that correction, while checking recovery and flux balances here. Nonnegative diffusion factors preserve the physical flux direction. Input and output owners are disjoint, naturally aligned and large enough for their descriptors. If diagnostic storage is present, it contains at least the requested soil layers and eight fields.

Preserve x18, x19 through x30, the required low halves of v8 through v15, FPCR and sixteen-byte stack alignment. Canonical bytes contain complete PWSA, PSAWGFL, PWFSD and PDHWLS owners, including gaps and inactive cells, in their supplied storage order. Each owner is little-endian, and zero differing bytes is the acceptance limit.

## Acceptance

The complete original source passed thirty-six protected calls and 253,904 returned owner bytes before direct assembly emission. Independent high-precision checks cover weighted-state recovery, the direction and amount of diffusion, top flux, bottom drainage and every diagnostic field. The cases cover partial and empty intervals, one and maximum layers, maximum columns, mixed land and sea, absent diagnostics, signed strides, gaps, signed zeros and subnormal values. The native routine passed the same thirty-six protected calls with zero differing bytes and 69,236 physical relations. Four complete paired calls compared another 7,792 bytes with zero differences and 466 high-precision relations, together with 140 relations inside the relay. Native register preservation, read-only inputs and descriptor bounds passed. One actual preliminary-state call passed another 9,408 complete owner bytes and 1,224 independent relations on each of the original, native and paired routes. Four land cells had negative preliminary water, which is handled by the following correction. No speed improvement is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfwinc_mod::srfwinc | 2,150 | 20,227,200 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
