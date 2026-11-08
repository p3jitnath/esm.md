# Surface Constant and Lake Parameter Family

This component owns the complete SUSCST, SUSTHF, SUVEXCS and SUSFLAKE bodies called by SUSURF_CTL, in their source-relative order. SUSCST supplies physical constants for the surface. SUSTHF derives liquid-water and ice saturation coefficients. SUVEXCS builds the stable Richardson-number table for turbulent exchange. SUSFLAKE supplies the lake-model constants and optical bands. This family has no allocation, original object, method table, original module storage or constructed-state packet in production. It does not replace the uncompleted SUSURF caller or its soil, vegetation and urban families.

The parent ABI is `int md2asm_initialize_surface_constant_family(controls, records)`, with arguments in x0 and x1. The read-only controls have 24 mapped bytes with eight-byte alignment: FP64 RCORIOI at zero, FP64 RPLRG at eight, canonical int32 LEFLAKE at sixteen and four raw constructor-preimage bytes at twenty. RCORIOI supports positive zero, negative zero, one half, one and two. RPLRG supports one half, one and two. The actual case uses the live owned SUDYNCORE RCORIOI and RPLRG equal to one, plus the live complete SU0PHY LEFLAKE. The final four control bytes are an arbitrary owned memory preimage, not a physical parameter.

The read-only 64-byte record table has four address/capacity pairs: writable genuine TCST 128, explicit YOS_THF namespace 72, explicit YOS_EXCS namespace 944 and genuine TFLAKE 856. All records align to eight bytes and have complete mapped nonwrapping ranges. Every output is disjoint from each other output, the controls and table. FPCR is zero. Return zero means success, while two means unsupported before any mutation or floating-point change. The parent and children preserve x18, all AArch64 callee-saved registers, stack alignment, FPCR and errno. FPSR retains source arithmetic events. Capacities above the stated extents do not increase access.

Typed genuine source queries fix every TCST and TFLAKE member, and the three ROPTICPAR_MEDIUM member offsets. The two explicit module namespaces follow their source declaration order. YOS_THF holds its nine FP64 scalars. YOS_EXCS holds 101 FP64 RITBL entries followed by seventeen FP64 scalars. All 128 TCST, 72 thermal and 944 stability bytes are written. TFLAKE contains 41 FP64 scalars, five 104-byte optical records and one int32 logical. Its final four alignment bytes retain incoming values.

Each optical record contains NBAND_OPTIC int32 at zero, four padding bytes at four, six FP64 fractions at eight and six FP64 extinction coefficients at fifty-six. The strict GNU SUSFLAKE body constructs each 104-byte value in the same temporary and copies all 104 bytes to the destination. Its four temporary padding bytes are source-undefined and therefore become the same arbitrary preimage in all five destination records. Production constructs its own temporary representation from named source literals and the explicit four-byte owned preimage, then copies those bytes through every optical assignment. The padding has no physical meaning and must not be interpreted by physics. A verifier-only adapter prepares those same four temporary bytes before the genuine call, with no post-return rewriting or masking. It preserves every supported preimage bit. This records the actual construction lifetime instead of inventing a source-defined padding value.

Keep the ordered source FP64 operations for the astronomical times, gravity, radiation constant, gas constants, heat capacities, latent heat difference and thermal saturation coefficients. RPI is the source-folded two times ASIN one. Integer powers use the accepted physical-constant source route with separate products. Literal-only lake expressions use their correctly rounded source values. The zero-Coriolis branch keeps a day of 86400 seconds and sets angular rotation positive zero. Preserve signed zeros and all source arithmetic flags. No contraction, reassociation, approximate arithmetic or reduced precision is allowed.

The stability child reuses the accepted SUVDFS Newton instruction sequence because the SUVEXCS source has the same defining functions, iteration split and assignments. It changes only namespace addresses and omits the uncalled spline continuation. It retains the previous table point as its initial estimate, five iterations when the target Richardson number is below one half and three otherwise. Its three final Louis-formulation constants are each five. Reuse the accepted independent table-physics evidence and add a complete genuine SUVEXCS byte comparison for the new namespace and boundary. Do not repeat the unchanged spline checks.

One joint gate compares complete genuine source records, natural immediate status, independent physical relations and retained padding. It covers the actual live scale case, zero rotation, scaled gravity, the lake switch and arbitrary constructor preimages. One static assembly entry checks the 2000-byte stream and owned scalar aliases without OpenIFS libraries. Use a small set of meaningful parent boundary checks for the new controls and ranges. The raw children require valid disjoint buffers and do not repeat the parent validation. Production source must be assembly emitted directly from these source equations and named literals; compiler output and captured record images are excluded.

The [direct source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/surface_constant_family.S) contains the guarded parent and four raw children. The child ABIs are `md2asm_initialize_surface_fundamental_constants(x0=TCST128,x1=controls24)`, `md2asm_initialize_surface_saturation_constants(x0=thermal72,x1=TCST128)`, `md2asm_initialize_surface_stability_constants(x0=stability944)` and `md2asm_initialize_lake_parameter_constants(x0=TFLAKE856,x1=controls24)`. They return zero and require the valid ranges, disjoint storage and FPCR already checked by the parent. They do not repeat validation. The parent uses a 64-byte frame; every child is a leaf with no stack frame, external call or heap use. All floating-point work uses caller-saved d0 through d7 and d16 through d31, leaving d8 through d15 unchanged. The production object has no undefined symbol.

The separate [owned namespace](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/owned_surface_constant_namespace.S) has 2000 bytes. Its four views begin at offsets zero, 128, 200 and 1144. It exports all nine YOS_THF and eighteen YOS_EXCS GNU-compatible source symbols as aliases into its own storage, including the 101-element table. A caller using those symbols must pass these same four views to the parent before a consumer runs. A call with other explicit buffers does not update the static aliases. The aliases are absent from the reference and native verification libraries, so they cannot replace genuine reference variables during comparison.

TCST stores physical constants: temperatures are in kelvin, a day is in seconds, angular rotation is in radians per second, gravity is in metres per second squared, gas constants and heat capacities are in joules per kilogram per kelvin, latent heats are in joules per kilogram and pressure is in pascals. Its universal gas constant R instead uses joules per mole per kelvin. RSIGMA is the Stefan–Boltzmann radiation constant in watts per square metre per kelvin to the fourth power. The source's 100000 Pa atmosphere reference is retained. RCORIOI, RPLRG and every mode switch are dimensionless. The following table fixes the genuine TCST layout.

| TCST member | Offset | Bytes |
| --- | ---: | ---: |
| `RTT` | 0 | 8 |
| `RPI` | 8 | 8 |
| `RDAY` | 16 | 8 |
| `R` | 24 | 8 |
| `RD` | 32 | 8 |
| `RV` | 40 | 8 |
| `RETV` | 48 | 8 |
| `RLSTT` | 56 | 8 |
| `RLMLT` | 64 | 8 |
| `RLVTT` | 72 | 8 |
| `RCPD` | 80 | 8 |
| `RCPV` | 88 | 8 |
| `RSIGMA` | 96 | 8 |
| `RG` | 104 | 8 |
| `RATM` | 112 | 8 |
| `ROMEGA` | 120 | 8 |

The following thermal namespace follows YOS_THF declaration order. RHOH2O is liquid-water density in kilograms per cubic metre. The dimensionless RVTMP2 coefficient is positive zero because this source neglects the moisture dependence of heat capacity. The remaining coefficients define the source saturation-pressure expressions for liquid water and ice. The R5 coefficients keep the rounded difference between the triple-point temperature and their corresponding R4 temperature before multiplication by R3.

| Thermal member | Offset | Bytes |
| --- | ---: | ---: |
| `RHOH2O` | 0 | 8 |
| `RVTMP2` | 8 | 8 |
| `R2ES` | 16 | 8 |
| `R3LES` | 24 | 8 |
| `R3IES` | 32 | 8 |
| `R4LES` | 40 | 8 |
| `R4IES` | 48 | 8 |
| `R5LES` | 56 | 8 |
| `R5IES` | 64 | 8 |

The stability namespace uses dimensionless quantities. The Richardson number compares buoyancy and velocity shear. The table returns height divided by the Obukhov length, a length scale for surface turbulence. Its first entry is zero. Later entries use the previous result as their starting estimate, with five source iterations below a Richardson number of 0.5 and three otherwise. The table solves $`Ri=\eta(1+4\eta)^2/(1+5\eta)^2`$ with the accepted fixed finite-difference Newton sequence. The three Louis constants are added after the final table value. No spline array or spline arithmetic belongs to SUVEXCS.

| Stability member | Offset | Bytes |
| --- | ---: | ---: |
| `RITBL` | 0 | 808 |
| `DRITBL` | 808 | 8 |
| `RIMAX` | 816 | 8 |
| `RCHBA` | 824 | 8 |
| `RCHBB` | 832 | 8 |
| `RCHBC` | 840 | 8 |
| `RCHBD` | 848 | 8 |
| `RCHB23A` | 856 | 8 |
| `RCHBBCD` | 864 | 8 |
| `RCHBCD` | 872 | 8 |
| `RCHETA` | 880 | 8 |
| `RCHETB` | 888 | 8 |
| `RCHBHDL` | 896 | 8 |
| `RCDHALF` | 904 | 8 |
| `RCDHPI2` | 912 | 8 |
| `RLPBB` | 920 | 8 |
| `RLPCC` | 928 | 8 |
| `RLPDD` | 936 | 8 |

The lake record below follows the genuine TFLAKE declaration. RC and RPHI coefficients control the shapes of the lake temperature profiles and their mixing response. RH and RU limits keep layer depths, ice and snow thicknesses, and friction velocity above their source minima. The RTPL values are the source water and ice material constants; their gravity and freezing point are 9.81 metres per second squared and 273.15 K, which remain separate from the atmospheric TCST values. RC_SMALL_FLK is exactly 100 times FP64 machine epsilon. The five optical records contain dimensionless radiation fractions and positive extinction coefficients in inverse metres. All six declared bands are written, including unused bands with zero fraction and extinction 10000000000 per metre. No value is changed to merge these separate source definitions.

| TFLAKE member | Offset | Bytes |
| --- | ---: | ---: |
| `RC_CBL_1` | 0 | 8 |
| `RC_CBL_2` | 8 | 8 |
| `RC_SBL_ZM_N` | 16 | 8 |
| `RC_SBL_ZM_S` | 24 | 8 |
| `RC_SBL_ZM_I` | 32 | 8 |
| `RC_RELAX_H` | 40 | 8 |
| `RC_RELAX_C` | 48 | 8 |
| `RC_T_MIN` | 56 | 8 |
| `RC_T_MAX` | 64 | 8 |
| `RPHI_T_PR0_1` | 72 | 8 |
| `RPHI_T_PR0_2` | 80 | 8 |
| `RC_TT_1` | 88 | 8 |
| `RC_TT_2` | 96 | 8 |
| `RC_B1` | 104 | 8 |
| `RC_B2` | 112 | 8 |
| `RC_S_LIN` | 120 | 8 |
| `RPHI_S_PR0_LIN` | 128 | 8 |
| `RC_I_LIN` | 136 | 8 |
| `RPHI_I_PR0_LIN` | 144 | 8 |
| `RPHI_I_PR1_LIN` | 152 | 8 |
| `RPHI_I_AST_MR` | 160 | 8 |
| `RC_I_MR` | 168 | 8 |
| `RH_ICE_MAX` | 176 | 8 |
| `RH_SNOW_MIN_FLK` | 184 | 8 |
| `RH_ICE_MIN_FLK` | 192 | 8 |
| `RH_ML_MIN_FLK` | 200 | 8 |
| `RH_ML_MAX_FLK` | 208 | 8 |
| `RU_STAR_MIN_FLK` | 216 | 8 |
| `RC_SMALL_FLK` | 224 | 8 |
| `RTPL_GRAV` | 232 | 8 |
| `RTPL_T_R` | 240 | 8 |
| `RTPL_T_F` | 248 | 8 |
| `RTPL_A_T` | 256 | 8 |
| `RTPL_RHO_W_R` | 264 | 8 |
| `RTPL_RHO_I` | 272 | 8 |
| `RTPL_L_F` | 280 | 8 |
| `RTPL_C_W` | 288 | 8 |
| `RTPL_C_I` | 296 | 8 |
| `RTPL_KAPPA_W` | 304 | 8 |
| `RTPL_KAPPA_I` | 312 | 8 |
| `RTPSF_L_EVAP` | 320 | 8 |
| `ROPTICPAR_WATER_REF` | 328 | 104 |
| `ROPTICPAR_WATER_TRANS` | 432 | 104 |
| `ROPTICPAR_WHITEICE_REF` | 536 | 104 |
| `ROPTICPAR_BLUEICE_REF` | 640 | 104 |
| `ROPTICPAR_ICE_OPAQUE` | 744 | 104 |
| `LEFLAKE` | 848 | 4 |

The optical values are explicit source constructors. Reference water uses one band with fraction one and extinction three per metre. Transparent water uses fractions 0.10 and 0.90 with extinction two and 0.20 per metre. White ice, blue ice and opaque ice each use one band with fraction one and extinction 17.1, 8.4 and 10000000 per metre respectively. The four constructor-preimage bytes are copied without interpretation at each nested byte offset four. Their values remain undefined for physics even though the raw verification stream records them. The final TFLAKE bytes 852 through 855 keep their incoming preimage. The standalone's zero constructor preimage is an owned fixture choice and is not a source-defined padding default.

The retained genuine source gate makes twenty body calls in one five-profile batch. It compares all 10000 returned bytes with zero differences and checks immediate ABI and processor status before serialization. The profiles cover the selected live scale values, zero and negative-zero rotation, half and double scale factors, either lake switch, nonzero output preimages and constructor words 00000000, 01234567, fedcba98, ffffffff and 80000000. The native ABI mask is zero; the genuine source's known x18 mask is two. All source and native calls preserve FPCR zero and errno 777, and agree on FPSR sixteen or twenty-four. No returned bytes or status bits are masked.

The verifier-only lake adapter prepares the original temporary preimage before the actual SUSFLAKE body. A bounded inspection identifies its 948-byte strict GNU function: its frame is 176 bytes, its constructor begins at stack byte 72 and the undefined padding is at stack bytes 76 through 79. The adapter owns a 176-byte scratch range, stores the four incoming preimage bytes there, releases that scratch and immediately calls the genuine body. This gives that body the same temporary preimage before it writes and copies its constructors. It does not replace a numerical stage or rewrite returned state. The exact function bytes, source versions and actual library provider remain in the local receipt.

The new physical checks use 100-digit decimal arithmetic for the radiation constant, gas constants, rotation and saturation coefficients. Their largest relative difference is 1.69e−16. They also check heat-capacity and latent-heat relations, optical fraction sums, positive attenuation, material densities, temperature bounds and layer-depth limits. The accepted Newton instruction text is unchanged after reversing only its relocated DRITBL offset and private labels, so the accepted independent table-equation and monotonicity checks are reused. The new complete genuine SUVEXCS comparison qualifies the relocated output namespace; no unchanged spline check is repeated.

Twenty-four unsupported parent cases leave controls, table and records unchanged, including signalling NaN controls which are rejected with integer checks before floating-point work. Six protected ranges put each of the four records, the controls and the table immediately before an inaccessible page. The standalone assembly entry writes all 2000 bytes from its owned namespace, agrees with the matched-preimage genuine stream, and runs with PATH as its only environment variable. It has no dynamic section or undefined symbol. All twenty-seven module aliases have the expected owned address and width. A zero-call provider check resolves all four genuine functions and twenty-seven genuine module variables to the strict reference library; no original provider is present in production.

The source definitions are `surf/module/suscst_mod.F90`, `susthf_mod.F90`, `suvexcs_mod.F90`, `susflake_mod.F90`, their YOS declarations and `surf/function/fcsvdfs.h`. This is a complete four-child parameter family. The remaining SUSURF_CTL radiation, soil, vegetation, surface exchange and urban stages, its outer allocation and the selected parent stores remain caller work. No full SUSURF or forecast completion is claimed, and no performance run is part of this checkpoint.
