# Spherical Interpolation Halo Setup

A halo is the extra band of grid cells needed when moving air reaches beyond a region's normal boundary. This stage uses the source trajectory speed, time step and Earth radius to find the required number of latitude rows. It then revises the speed limits to use that complete band. The calculations follow section 2.2.2 of `arpifs/setup/susc2b.F90`, followed by its `CVER='SL'` assignment before SLCSET. This is the spherical halo stage, rather than the complete SUSC2B routine.

## Live Inputs And Order

The caller first produces the selected SUDYN interpolation controls and its two trajectory speed limits. The owned SUCT0, parallel-configuration and physical-constant producers must already have completed. The source SUSC2B caller prepares the SUSLB maps before this halo stage, then calls SLCSET to construct the halo's storage. SLCSET derives its own first and last extended latitude indices from the live halo width.

The Earth radius RA is in metres, the time step TSTEP is in seconds and VMAX1 and VMAX2 are in metres per second. RPI is the stored value of pi. The grid stretch RSTRET and the grid counts are dimensionless. The selected path is a global spherical grid with semi-Lagrangian transport and two time levels. The caller supplies the already produced Earth constants through their actual owned scalar addresses. Production uses `__yomcst_MOD_ra` and `__yomcst_MOD_rpi`, which name offsets 104 and 0 in the owned physical-constant record. It reads TSTEP directly from MODEL and RSTRET directly from Geometry.

The supported physical input domain uses those frozen Earth constants, a grid stretch from one eighth through eight, positive initial speed limits no greater than 1000 m/s, and either a zero time step or a time step from 1 through 86,400 s. The latitude count is from 2 through 65,536 and NDGSUR is from 1 through 1024. The caller must satisfy these physical bounds. The entry also checks the pointer, capacity, selected branch, finite-value and source angular-distance conditions before it stores output. A request whose angular distance exceeds half of pi is refused, preserving the original source limit.

## Interfaces And Storage

The Arm application binary interface defines the argument registers and the registers a function must preserve. Both entries are leaf functions, which means they make no other function call. They use no stack frame, preserve x18 and all saved general and floating-point registers, and allocate no memory. FPCR, the floating-point control register, must be zero on entry. A successful call returns 0 in w0. An invalid or unsupported input returns 2 before any output changes.

| Entry | Arguments In Register Order | Result |
| --- | --- | --- |
| `md2asm_initialize_selected_spherical_halo_controls` | x0 controls address, x1 controls capacity, x2 owned LELAM address | Write the selected two-word control record. |
| `md2asm_initialize_spherical_interpolation_halo` | x0 Geometry address, x1 Geometry capacity, x2 MODEL address, x3 MODEL capacity, x4 RA address, x5 RPI address, x6 controls address, x7 controls capacity | Write the halo metadata and revised speed limits in MODEL. |

Geometry must have at least 17,096 readable bytes, and MODEL must have at least 4,275,088 readable and writable bytes. Their addresses and the two FP64 scalar addresses must have 8-byte alignment. Each scalar has exactly 8 readable bytes. The control record has at least 8 bytes and 4-byte alignment. Its first 32-bit integer is LELAM, which must be zero for the spherical path. Its second integer is LSLONDEM, which enables communication of requested interpolation values. It must be zero or one. Borrowed inputs must be disjoint from the bytes written by these entries, and every declared address range must remain mapped for the call.

The small control producer reads LELAM from the owned SUCT0 namespace and explicitly writes LSLONDEM as one. This is the SUMP0 source assignment at line 111. It is not inferred from static zero storage. The prerequisite is successful admission by the existing first-NAMPAR1 reader. That reader rejects an unsupported LSLONDEM override, so the selected input retains the source default. The control record remains caller-owned and needs no release.

| Record | Source Member | Byte Offset | Effect |
| --- | --- | ---: | --- |
| Geometry | NDGLG | 4872 | Read the global latitude count. |
| Geometry | NDGSUR | 4884 | Read the interpolation boundary width. |
| Geometry | RSTRET | 7512 | Read the grid stretch. |
| MODEL | TSTEP | 1359528 | Read the time step. |
| MODEL | LTWOTL and LSLAG | 1564156 and 1564160 | Require the selected two-time-level transport path. |
| MODEL | VMAX1 and VMAX2 | 1566928 and 1566936 | Read and revise the two speed limits. |
| MODEL | YRSL.CVER | 1573768 | Store the two characters `SL`. |
| MODEL | YRSL.LSLONDEM | 1574800 | Copy the owned on-demand control. |
| MODEL | YRSL.NSLWIDE | 1575132 | Store the derived halo width. |

## Ordered Calculations

The trajectory multiplier is one for the selected two-time-level path. The code multiplies VMAX2 by that multiplier, then by TSTEP, then by RSTRET, and divides by RA. Each FP64 operation rounds separately. It compares this angle with one half of RPI. It then multiplies the angle by NDGLG plus one half, divides by RPI and takes CEILING. CEILING selects the smallest integer that is at least as large as its input. The halo width is that integer plus NDGSUR minus one, including the original final subtraction.

Before revising the speeds, the code divides the old VMAX1 by the old VMAX2. It multiplies the integer row count by RPI and divides by NDGLG plus one half. For a nonzero time step, it multiplies that angle by RA and divides by the separately rounded product of the trajectory multiplier, TSTEP and RSTRET. The result becomes VMAX2. It multiplies the saved speed ratio by the new VMAX2 and takes the smaller value of that product and 250 m/s for VMAX1. A positive or negative zero time step preserves both incoming speed bit patterns. The code uses no fused operations or approximate arithmetic.

Only the two 8-byte speeds, the two-character CVER value and the two 4-byte SL control members may change. Those fields total 26 bytes. Geometry, the scalar inputs, the control record and every other MODEL byte remain unchanged. The native stage has no operating-system, file-format, original OpenIFS or other external call.

## Verification Scope

The separate reference compiles the original computational assignment segment with genuine MODEL and Geometry declarations. Informational WRITE statements are omitted so that numerical status is captured before text formatting. The original abort branch is converted to a reference return for this isolated boundary. This does not claim a complete original SUSC2B comparison. Production contains only the directly written assembly.

Eight profiles compare 34,200,704 complete MODEL bytes and 136,768 complete Geometry bytes with zero differences. They cover the actual initial-entry scalar inputs, both source speed choices, positive and negative zero time steps, a CEILING tie and its two neighbours, a changed grid stretch and the 250 m/s speed cap. Immediate FPCR, FPSR and errno agree, and both source and native register checks return zero. A further selected call preserves incoming cumulative numerical flags. Thirty-two exact-rational physical checks verify the angle covered by the band, the one-row excess bound and the revised speed relation, with an explicit allowance for FP64 rounding. Thirteen critical refusals preserve all input and output bytes, and guarded scalar ends prove that RA and RPI use exactly their declared readable extent. These are component checks. Complete forecast and saved-output acceptance remain pending.
