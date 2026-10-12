# Transport Equation Terms Contract

The [basic formulation](../../../../../formulations/openifs/dynamics/transport_equation_terms.md) gives the physical idea.

This contract covers the complete selected LATTEX caller in arpifs/adiab/lattex.F90. It prepares wind and temperature terms for transport from an earlier location and adds the current constituent state to the transport buffer. The forecast supplies tendencies and controls the call order. This is one forecast stage, so its checks do not certify complete forecast physics.

The genuine input packet uses 24 columns, 19 levels, two time levels, finite-element vertical coordinates, three-point wind and temperature transport, hydrostatic variables, ordinary wind components and inactive diagnostics. Reuse complete accepted LATTEX_DNT for wind and temperature. In this first selected contract, reject three time levels, non-hydrostatic variables, complete Coriolis geometry, Cartesian wind conversion, predictor-corrector controls, spline-transform constituents, split constituent interpolation and active diagnostics before mutation. TNT and the other branches remain separate requirements.

## Physical Meaning

The supplied half time step h and time coefficients b and b_j have units of seconds. Wind u and v has units of metres per second, temperature has units of kelvin, and constituents retain their supplied field units. Coriolis parameter f has units of inverse seconds, wind tendencies have units of metres per second squared, and temperature tendency has units of kelvin per second. Surface geopotential O has units of square metres per second squared; its horizontal derivatives have units of metres per second squared.

The supplied vertical correction arrays r_F and r_H have units of kelvin, as shown by their setup in SURCORDI. Define $`c=RCMSLP0/(RD\,RTSUR)`$, where RCMSLP0 is dimensionless, RD is the dry-air gas constant in square metres per second squared per kelvin, and RTSUR is reference temperature in kelvin. Thus c r_F O is a temperature. Treat the correction arrays as frozen inputs. SURCORDI records a separate consistency limit for alternative vertical constructions; this caller does not certify that setup.

Independently check that Coriolis acceleration does no instantaneous work, $`u(fv)+v(-fu)=0`$. Check each prepared wind source against its separate forcing and rotation contributions. Check the temperature source against the horizontal and vertical change of the supplied orographic correction and the supplied temperature tendency. Check the conversion between corrected and physical temperature using the child's returned fields, allowing the separate rounding of the two operations.

## Ordered Arithmetic

R means one FP64 rounding to nearest, with ties to even. Every product, sum, difference and division has its own rounding. Forbid fused operations, contraction, reassociation, approximate arithmetic and reduced precision. Use FPCR zero and preserve signed zeros, gradual underflow, incoming status and errno.

First form $`c=R(RCMSLP0/R(RD\,RTSUR))`$. Retain the source's two unused scalar preparations $`R(2/R(RG\,RA))`$ and $`R(R(2\,ROMEGA)/RG)`$, because they can affect status even when their branch is inactive.

Prepare the wind linear terms R(b G_u) and R(b G_v) in PB2. Form $`m_u=R(h\,a_u)`$ and $`m_v=R(h\,a_v)`$, then add R(R(h f)v) to m_u and subtract R(R(h f)u) from m_v. Select the wind extrapolation flag from the original PESGP/PESGM comparison and call the complete accepted DNT child once for each component.

Prepare R(b_j G_T) in PB2. For finite elements, multiply the supplied level pressure transport by reciprocal layer thickness. Form each horizontal temperature term from left to right as h,c,r_F,u,O_x and h,c,r_F,v,O_y, then add the terms. Add R(h a_T), then add the left-to-right product h,c,R(r_H(k)-r_H(k-1)),w,O. Call the complete accepted DNT child for temperature with the original temperature extrapolation flag.

After that child, subtract the left-to-right product r_F,c,O from its final temperature and add that ordered product to its transport buffer. For each advected constituent, in increasing field order, add its current field to the corresponding PB1 level view with one rounding. The selected route has no special moisture-convergence copy and RINTOPT equals one. Preserve all unused fields, padding and inactive columns.

## Interface And Acceptance

The original entry has 42 ordinary pointers and no hidden length. Their exact order is recorded in the source and capture_original_equation_terms.c. Preserve x18, x19 through x29, the link register and the low 64 bits of d8 through d15; keep the stack aligned to 16 bytes. All selected calculations must be direct AArch64 assembly, with the accepted direct DNT child and storage services as its dependencies. The driver supplies no numerical stage.

Full-level arrays use NPROMA by NFLEVG cells in Fortran order, with columns first. Hydrostatic inactive owners use NPROMNH by NFLEVG, where NPROMNH is one. The inactive diagnostic owner uses one by one spatial storage and its complete field count. PB1 and PB2 have their own complete caller field counts; their transported views retain NFLSA through NFLEN padding. Read actual caller capacities rather than larger nominal dummy shapes.

The closed genuine R18 graph has 55 owners: 42 ordinary arguments; the vertical flag record; both correction arrays; complete Coriolis and orography block records and their data; RD, RG, RA, ROMEGA, RTSUR; and the step counter. Preserve aliases in source clones, rebase consumed pointers only, and retain complete input records.

Before emission, qualify the original parent through independent Coriolis work, source additions, temperature conversion, constituent additions and finite active fields. Reuse accepted DNT science and bounds, observing original child stages only inside this parent. The genuine original passes 8,208 accepted exact affine child relations and 6,840 independent 120-digit parent relations, with 196,512 complete returned bytes and zero differences. Then require zero differing complete returned bytes, unchanged complete inputs, protected bounds, matching status and errno, FPCR zero, and seeded preserved registers. The root's positive actual-call and saved-file gate supplies routine credit.

The accepted private DNT body is linked with a unique hidden name. Its text bytes are identical to the accepted object. A direct assembly wrapper forwards all 27 arguments, preserves the platform register and counts each completed body return. The original DNT observation uses a separate count and runs only inside the source parent stage.

## Accepted Forecast Calls

The complete parent passes 2,150 genuine native calls and 422,500,800 returned bytes with zero differences. Each call owns three complete direct DNT stages. Independent checks pass 14,592,000 physical relations. All ten saved files agree across 618,140 bytes. The complete forecast still contains other Fortran stages.

Compile the unchanged [DNT source](../../../../../src/openifs/dynamics/lattex_dnt.S) with ORIGINAL_SYMBOL set to md2asm_lattex_dnt_body_7259755, then link that object with this parent. This changes the private name and preserves every accepted child instruction.
