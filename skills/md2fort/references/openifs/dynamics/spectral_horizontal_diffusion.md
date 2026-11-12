# Spectral Horizontal Diffusion Contract

The [basic formulation](../../../../../formulations/openifs/dynamics/spectral_horizontal_diffusion.md) gives the physical equations.

This contract covers the complete selected SPCHOR stage from arpifs/adiab/spchor.F90. The genuine input call uses 19 local levels, degree limit 21, 22 local orders and 506 real and imaginary coefficients. It selects hydrostatic, non-stretched diffusion with LM0DAMP false, active temperature transport, no additional diffusion, no sponge, inactive diagnostics and no stochastic or nudging calculations. Reject other controls before mutation. The source-only packet and original qualification remain separate from the direct native solver.

A coefficient describes one spherical wave. Degree n counts spatial variation and order m counts longitudinal variation. Vorticity and divergence have units of inverse seconds, temperature has units of kelvin, logarithmic surface pressure is dimensionless, and diffusion rates have units of inverse seconds. RCORDIT has units of kelvin, as shown by SURCORDI. That setup records a separate consistency limit for alternative vertical coordinates; this stage treats its correction as a supplied input.

## Ordered Complete Update

Use h=abs(TDT) in seconds. For each local order m greater than zero, visit degrees n from m through NSMAX. Use NASM0(m)+2*(n-m) and its next index as the real and imaginary pair. Process both wind fields at every local level first, then temperature at every local level. KSTA and KEND do not limit these assignments. Freeze the full range KSTA=1 and KEND=(NSMAX+1)*(NSMAX+2), with every mapped pair inside the actual field owners. Preserve every order-zero coefficient and every other owner byte, including complete pressure, constituent and diagnostic carriers.

FP64 is a 64-bit floating-point number. R means one FP64 rounding to nearest, with ties to even. For each wind component x and supplied rate d, form p=R(h*d), q=R(1+p), then x_plus=R(x/q). For temperature at local level j, use global level ILEV0+j, where ILEV0=NPTRLL(MYSETV)-1. Read the earlier pressure coefficient P and correction C. Form a=R(C*P), b=R(a*h), f=R(b*d_T), u=R(T+f), v=R(h*d_T), q=R(1+v), then T_plus=R(u/q). Keep all products, sums and divisions separate. Shared identical denominator values may be reused across the pair. Forbid fused operations, contraction, reassociation, approximate division and reduced precision.

For d greater than or equal to zero, wind magnitude and quadratic wave energy cannot increase. Temperature relaxes toward C*P and stays between its original value and that target within its rounding budget. Check those properties independently at 120-digit precision. The genuine original passes 70,224 such relations and exact ordered returns across 234,872 complete data bytes, with zero differences. Every untouched owner byte and all actual consumed indices pass.

## Storage, Bounds And ABI

The application binary interface (ABI) defines argument passing and register duties. The entry has 19 ordinary pointers. The first four give geometry, model, first column and last column; the other 15 point to assumed-shape descriptors. Rank is the number of indices needed to identify an element. Twelve have rank two, two have rank three and one has rank one. Full fields store level first, then spectral coefficient, then constituent where present. The actual inactive fields and diagnostics have one-cell capacities. Retain all 50 captured owners and their aliases; drivers supply no missing stage.

The supported direct route permits one through 256 local levels, degree limits zero through 256, the complete unique order set zero through NSMAX, and the full spectral interval above. Require dense level and column storage, with each column stride equal to the stored row capacity, the captured lower-bound convention, active magnitudes below 2^128 and nonnegative rates in that range, retaining signed zeros and subnormals. Four such multiplied factors stay below 2^512, so the source's intermediate products stay finite. Validate all computed pairs, level indices, coefficient tables and pressure storage before output writes. The active input and output owners must meet the captured independent-carrier layout; preserve all inactive aliases. Narrower intervals remain outside this first contract.

Preserve x18, x19 through x29, the link register and the low 64 bits of d8 through d15. Keep the stack aligned to 16 bytes. Use FPCR zero, preserve gradual underflow and signed zeros, and compare fresh and incoming sticky FPSR plus errno. The native body owns every selected calculation and has no numerical child. Source-only GSTATS logging is not a numerical stage and supplies no calculation to the native route.

Accept zero differing bytes across every complete returned data owner, unchanged complete input records and carriers, protected buffer bounds, matching floating-point state and errno, and seeded saved registers. Normal-call and exact saved-file evidence are recorded below. Whole-forecast physics and autonomous execution remain separate requirements.

## Original Profiling Status

The original source calls GSTATS twice to record timing. Its logger can add the inexact flag because it calculates elapsed time. That flag belongs to profiling and is excluded from the numerical reference only inside each actual logger call. Before calling the original logger, preserve the incoming numerical FPSR and record the logger's fresh flags separately. Require its fresh flags to contain only inexact, with unchanged FPCR and errno, then restore every incoming numerical flag immediately at that logger return. Do not clear a flag after the complete parent.

Record the full original return status and the isolated original numerical status separately. The normal paired report reconstructs the full original sticky flags from the qualified actual logger events and compares fresh numerical status with the native return. Focused checks also compare an untouched full original call against that reconstructed status. The native assembly performs no Fortran profiling call and returns its own numerical flags, combined with incoming caller flags. This reference-status revision changes no physical equation, ordered calculation, magnitude limit or output byte.

## Accepted Forecast Calls

The complete stage passes 25 genuine native calls and 5,871,800 complete returned bytes with zero differences. Independent diffusion checks pass 1,755,600 relations. All ten saved files agree across 618,140 bytes. The native body owns every selected calculation and makes no Fortran numerical or profiling call. Other forecast stages remain in Fortran.
