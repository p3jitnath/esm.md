# Semi-Lagrangian Wind Preparation

The [physical input](../../../../../formulations/openifs/trajectories/wind_for_parcel_trajectories.md) gives the wind components and units. This calculation prepares wind for the parcel trajectory on the supplied coarse global grid. Horizontal wind is in metres per second. Eta is a dimensionless vertical coordinate, and its rate is in inverse seconds. The existing physical model is unchanged. Arithmetic revision 3 replaces only the elementary hyperbolic tangent with a separately frozen route that uses pairs of 64-bit floating-point (FP64) values.

A pointer is the address of a stored object or array. The interface has the original 19 pointers, with KST and KPROF selecting inclusive rows, KIBL selecting one of 86 blocks, and 24 rows and 19 levels per full block. The last block has eight active rows. The grid-state array `GMV` has 18 fields. The work arrays `PB1` and `PB2` have 463 and 153 columns. The genuine selected controls enable finite elements, two time levels, the horizontal and vertical prediction equations below, two filtered levels, Cartesian preparation and saved vertical history. The inactive alternatives are outside this selected contract and reject before any output mutation.

In the prediction equations, $`w`$ is the eta rate. Let subscripts $`0`$ and $`9`$ select current and previous wind, while $`p`$ selects predicted wind. The filter constants are $`S=10^{14}\,\mathrm{s}^2`$ and $`O=10^{-14}\,\mathrm{s}^{-2}`$. The hyperbolic tangent $`\tanh`$ is a smooth function bounded between minus one and one. The dimensionless weight $`\alpha`$ lies between zero and one.

```math
u_p=2u_0-u_9, \qquad v_p=2v_0-v_9,
```

```math
\alpha=\tfrac12[1-\tanh(-S(w_0w_9+O))], \qquad
w_p=w_0+\alpha(w_0-w_9).
```

The filtered formula applies to the first two levels at positive steps. Other levels use $`w_p=2w_0-w_9`$. At the initial step, use current wind. For level $`j`$, $`F_j`$ is the supplied full-level pressure flux in pascals per second and $`r_j`$ is reciprocal pressure depth in inverse pascals.

```math
w_{0,j}=F_j(\eta_j-\eta_{j-1})r_j.
```

For each active cell, subtract successive eta nodes, multiply that difference by the supplied full-level continuity flux, then multiply by reciprocal layer pressure depth. This produces the current eta rate. At step 0, copy current horizontal wind and eta rate. At later steps, predict horizontal wind as twice current minus previous. On levels 1 and 2, compute the argument as minus the filter scale times the rounded sum of current-times-previous eta rate and filter offset. Compute the weight as half of one minus the new tangent, then the vertical prediction as current plus weight times current-minus-previous. On other levels use twice current minus previous. At step 0, set the saved vertical-history array `PWRL9` to positive zero. At positive steps, save the previous eta rate there before replacing its GMV field with the current rate.

Both horizontal pairs then use the supplied latitude and longitude factors. Write z as north wind times cosine latitude. Write x as minus east wind times sine longitude, minus the separately rounded north-times-cosine-longitude-times-sine-latitude product. Write y as east-times-cosine-longitude minus north-times-sine-longitude-times-sine-latitude. Keep the original east and north values until all three components are complete. Do not normalise the supplied factors.

All arithmetic uses ordered FP64 with round-to-nearest, ties to even and gradual underflow. Each written addition, subtraction, multiplication and division rounds separately. No fused operation, reassociation, approximate operation, quad fallback or high-level primary numerical stage is allowed. An output spacing is the gap between neighbouring FP64 values near the mathematical result. The new tangent must remain within one output spacing of the real function on every consumed input, preserve signed zero and lie in [-1,1].

An owner is a complete backing buffer. Aliases are different views that share the same stored bytes. An array descriptor records an array’s shape, strides and data address. Ordinary typed objects and all full numerical owners retain their actual captured bytes. Captured overlap groups retain exact aliases and offsets. Rebind only declared source geometry pointers, full block records, their four coordinate descriptors, the eta-node descriptor and GMV descriptor for private source clones. Readonly inputs retain every byte, including inactive values. Outputs are complete GMV, PB1, PB2, saved eta-rate, alpha and counter owners. The filter weight $`\alpha`$ is a temporary value used for vertical prediction. The separate work array `PALPHA` holds positive zeros under the selected settings. Reset counters only on the two filtered levels at positive steps. Preserve inactive rows, other fields, other blocks, unused counters and every declared metadata byte.

The application binary interface (ABI) is the calling rule for registers and memory. It passes the first eight pointers in x0 through x7 and the remaining eleven on the stack. Preserve x18, x19 through x29, the link register and the low 64 bits of d8 through d15. Stack alignment is 16 bytes. Source-only bridges isolate the original source x18 obligation. The direct primary owns every selected numerical stage. External DR_HOOK is profiling only and must preserve normal caller status through its original entry and exit calls.

Acceptance requires the independently verified four genuine packets and critical boundaries, complete source/native output and readonly byte equality, alias and guard checks, fresh FPCR/FPSR/errno and raw ABI agreement, positive parent and elementary counts, and the full native forecast comparison against the separately reviewed revised source. Isolated source science disables external profiling because no MPI context exists. Normal forecast acceptance must use the real profiling route. No agreement with changed old-vendor output bits or global correct-rounding proof is claimed.

The complete direct parent passes 2,150 forecast calls and 23,201,050,000 complete buffer bytes with zero differences. This total includes both input and returned buffers. All ten saved files match the separately reviewed wind and unfused-transform reference across 618,140 bytes. The original vendor tangent and saved outputs remain local. This revised reference is explicit, because its saved output differs from the previous reference.
