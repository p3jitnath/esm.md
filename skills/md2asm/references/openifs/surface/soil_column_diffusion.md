# Soil Column Diffusion Contract

Revision 1 freezes complete SRFWDIF_MOD::SRFWDIF from [Diffusion Between Soil Layers](../../../../../formulations/openifs/surface/soil_column_diffusion.md), WD-1 and WD-2. The numerical method first removes the lower neighbour from each equation, then solves the layers from bottom to top. This is a tridiagonal solve, because each equation uses only one layer and its two neighbours.

## Ordered Update

FP64 stores each real number in sixty-four bits. RN means one operation rounded to the nearest FP64 value, with an even final bit at an exact halfway point. Require the floating-point control register, FPCR, to equal zero. Preserve signed zeros, gradual underflow and every separate operation. The factors are supplied inputs. This routine does not compute the preceding diffusion factors or the following recovered state.

Set a=RN(1/RSIMP) and set each active land output b=RN(RN(a×PWSAM1M)+PRHSW). At the top, set q=RN(1/PCDZ), p=RN(PCFW×q), h=RN(1/RN(1+p)), E=RN(h×p) and u=RN(h×b). Keep the top PCFW as the previous diffusion factor.

At each middle layer, set q=RN(1/PCDZ), f=RN(previous_PCFW×q), p=RN(PCFW×q) and t=RN(1−previous_E). Set t=RN(f×t), t=RN(1+t), t=RN(t+p), h=RN(1/t) and E=RN(h×p). Set t=RN(f×previous_u), t=RN(b+t) and u=RN(h×t). At the bottom, use the same denominator and updated u without saving E. Finally, move upwards and write u=RN(u+RN(E×next_u)).

## Interface And Storage

The application binary interface, or ABI, defines argument addresses and registers that a routine must preserve. Eleven addresses supply KIDIA, KFDIA, KLON, KLEVS, PWSAM1M, PCFW, PRHSW, PCDZ, YDSOIL, PWSADIF and LDLAND. The first eight arrive in x0 through x7. The three remaining addresses occupy eight bytes each on the entry stack. Integer and logical values occupy four bytes, and real values occupy eight.

Arrays use GNU assumed-shape descriptors. The base address is at byte zero. Each dimension records element stride, lower bound and upper bound at bytes forty, forty-eight and fifty-six, with twenty-four bytes between dimensions. Logical land flags use four-byte elements. Other arrays use eight-byte elements. Dummy indices start at one, and signed strides start from the first logical element. YDSOIL is the unchanged reviewed 2416-byte TSOIL object, with RSIMP at byte 144.

Require 1≤KLON≤4096, 2≤KLEVS≤512, 1≤KIDIA≤KLON and KIDIA−1≤KFDIA≤KLON. The original one-layer route reads an absent previous layer, so a one-layer call is rejected before writes. Require finite consumed values, 0<RSIMP≤1, positive PCDZ, nonnegative PCFW and finite intermediates. Input and output owners are disjoint and naturally aligned. Land and array descriptors cover the declared dimensions. Sea cells, inactive cells and storage gaps preserve their incoming output bytes.

A fixed 128-byte frame preserves x19 through x30 and d8 through d9. A further sixteen-byte-aligned scratch area holds at most 512 elimination coefficients. Complete PWSADIF owner bytes use their supplied little-endian storage order, including gaps. The acceptance limit is zero differing bytes. No driver supplies a missing numerical stage.

## Acceptance

Before assembly emission, the complete unchanged source passed forty protected calls and 143,488 returned owner bytes. Independent checks cover each layer balance, the full column balance, the nonnegative maximum principle and constant or uncoupled limits. Cases include two and maximum layers, maximum columns, partial and empty intervals, land and sea, signed strides, gaps, signed zeros and subnormal values. The native routine passed the same forty protected calls and 143,488 bytes with zero differences and 87,512 independent relations. Four complete paired calls compared another 888 bytes with zero differences, ninety-two high-precision relations and 57 relay relations. The one-layer rejection passed before any of 4,096 shared output bytes changed. Inputs, descriptors, bounds, preserved registers and FPCR passed. No speed improvement is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfwdif_mod::srfwdif | 6,450 | 4,953,600 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
