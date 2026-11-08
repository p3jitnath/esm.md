# Selected Nudging and Climate Startup Controls

This component owns the complete selected SUNUD, SUMCC and SUTRAJP output state. Nudging is a relaxation of model values toward supplied observations, while coupling exchanges values with another model. Both remain disabled in the selected live input. NAMNUD and NAMMCC are empty. The component checks their actual first uppercase groups with the accepted bounded empty-group reader, then applies all selected source stores. No original OpenIFS module, object, method table, callable or constructed-state packet is a production input.

The parent ABI is `int md2asm_initialize_selected_inactive_startup_controls(text, bytes, records)`, with arguments in x0 through x2. Text has one through 262144 mapped bytes. The 128-byte record table contains eight address/capacity pairs: writable nudging namespace 1824, writable TMCC 7584, writable NG3NH95 int32 four bytes, retained NBITSEXPR int32 four bytes, read-only TARPHY 88, read-only TEPHY 448, read-only NFRCO int32 four bytes and read-only LR2D int32 four bytes. The table and the four large records align to eight bytes; the four small int32 views align to four bytes. Each complete consumed range must be mapped and must not wrap. All eight records are pairwise disjoint; writable records cannot intersect text or the table. Return zero means success and two means unsupported input before mutation. FPCR must be zero. All callee-saved registers, x18, the stack pointer, FPCR, FPSR and errno are preserved. There is no allocation or floating-point arithmetic.

The source SU0YOMA order is SUTRAJP, SUNUD, then SUMCC after SURIP and SU0PHY. LR2D must be false, as supplied by the owned SUCT0 namespace, so the source call to SUMCC is active. The live TARPHY LMSE at byte four and TEPHY LESICE at byte 48 are canonical int32 logical values, zero or one. They come from the owned complete SU0PHY producer. Both values are supported. NFRCO is the named int32 value produced by owned SUCT0; it is zero in the actual case. SUMCC reads it only if LMCCEC is enabled, which the selected empty group leaves false. The NBITSEXPR view retains every incoming bit because LCOUPINFOUT is false. These views identify upstream and retained source state even when the selected branch does not change it.

The 1824-byte nudging namespace is explicit assembly storage because YOMNUD contains separate module variables. It follows declaration order: seven int32 counts and indices at zero through 27, eighteen int32 logical switches at 28 through 99, four retained alignment bytes, all 200 FP64 XNUVERT values at 104 and fifteen FP64 coefficients at 1704. JPMXLE is the source dimension constant 200, although the selected model has nineteen active levels. Every XNUVERT entry becomes one and every coefficient becomes positive zero. All nudging switches and both total-field counts become false or zero. NFNUDG is zero, NFRNUDG is 999, NTNUDG is one, NSPNU1 is 998 and NSPNU2 is 999. The source LMSE reset and final LNUDST/LNUDG expressions give the same disabled result for either supported LMSE value. Unused YOMNUD allocatable arrays are outside SUNUD's written state and remain absent from this disabled route.

TMCC has 7584 bytes in the genuine source declaration. Typed queries identify every scalar and each of its eleven allocatable descriptors without using an original type object in production. A separate owned declaration-default child first checks that all eleven descriptor data words are null, so it cannot discard a live owner. It applies all 59 source-declared scalar and character defaults and leaves every other byte unchanged. The defaults include false LNEMOSICOUP, true LFIRSTUPD and LNEMOATMFLDS, the partial-coupling constants and filename, inactive coupling identifiers and null owners. Source-unwritten descriptor metadata is retained; it must not be read while the corresponding owner is null. Fresh zero storage supplies the ordinary initial preimage, and retained bytes stay undefined until a later source producer writes them.

The declaration child ABI is `int md2asm_initialize_climate_declaration_defaults(record, capacity)`, using x0 and x1. Its aligned, nonwrapping record has at least 7584 mapped bytes and starts with all descriptor data words null. It returns zero or two before mutation and preserves the required register, floating-point and error state. It needs no heap or release because every owner remains null. Its public literals come directly from yommcc.F90 declarations; typed metadata supplies only offsets and widths, not a captured record image.

After declared defaults, selected SUMCC applies the uncoupled source defaults and final guards. LMCCIEC stays true, N923 becomes zero, NOACOMM two, NFRCPL 999999, NSSTICEOP nine and NNEMO3DLEVS twenty. The source resets inactive NEMO output, dynamic sea-ice and all LIM temperature/thickness exchange switches in source order. Declaration-defined fields which SUMCC leaves unwritten retain their owned defaults. All remaining TMCC fields retain incoming bytes. The complete TARPHY and TEPHY inputs remain unchanged. SUTRAJP writes NG3NH95 equal to nine; its source says this old trajectory count is unused in the selected forecast.

Verification uses complete genuine SUNUD, SUMCC and SUTRAJP calls as separate controls. The ordinary TMCC preimage comes from a fresh genuine declared record only in verification. Additional retained-byte cases prepare matched source declarations before the genuine call, never by masking returned state. Production constructs declarations from named source literals. One joint gate compares complete record bytes, all source-written nudging state, read-only inputs, immediate ABI/status and disabled-mode identities. It also checks empty-group selection, owner rejection, protected bounds and a standalone assembly dependency boundary. No forecast or performance run belongs to this checkpoint.

The assembly parent uses a 112-byte stack frame. Both its owned declaration child and the accepted empty-group child are integer leaves with no stack frame, so the maximum private stack use is 112 bytes. The external closure contains only `md2asm_require_empty_physics_group`, defined by the accepted [empty namelist reader](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/empty_physics_namelists.S). No language runtime, heap service or original model routine is needed. The source listing and tracing calls are outside this state producer; the genuine reference retains them and records their immediate status. Production diagnostic reporting is a separate component.

All offsets below count bytes from the start of the stated record. Integers and logical values use signed 32-bit storage, and each FP64 value uses eight bytes. A logical value is zero for false or one for true. The following table fixes the packed nudging namespace; the source module has separate variables, so this owned layout does not depend on an original module address.

| Nudging member | Offset | Bytes | Final value |
| --- | ---: | ---: | --- |
| `NFNUDG` | 0 | 4 | 0 |
| `NFRNUDG` | 4 | 4 | 999 |
| `NTNUDG` | 8 | 4 | 1 |
| `NTOTFNUDG3` | 12 | 4 | 0 |
| `NTOTFNUDG2` | 16 | 4 | 0 |
| `NSPNU1` | 20 | 4 | 998 |
| `NSPNU2` | 24 | 4 | 999 |
| `LNUDG` | 28 | 4 | false |
| `LNUDDI` | 32 | 4 | false |
| `LNUDLP` | 36 | 4 | false |
| `LNUDRM` | 40 | 4 | false |
| `LNUDSD` | 44 | 4 | false |
| `LNUDSH` | 48 | 4 | false |
| `LNUDSM` | 52 | 4 | false |
| `LNUDST` | 56 | 4 | false |
| `LNUDSV` | 60 | 4 | false |
| `LNUDTE` | 64 | 4 | false |
| `LNUDVO` | 68 | 4 | false |
| `LNDRIV` | 72 | 4 | false |
| `LNUDTG` | 76 | 4 | false |
| `LNUDQG` | 80 | 4 | false |
| `LNUDUG` | 84 | 4 | false |
| `LNUDVG` | 88 | 4 | false |
| `LNUDPG` | 92 | 4 | false |
| `LWNUDG` | 96 | 4 | false |
| `XNUVERT` | 104 | 1600 | one at each of 200 entries |
| `XNUDDI` | 1704 | 8 | positive zero |
| `XNUDLP` | 1712 | 8 | positive zero |
| `XNUDRM` | 1720 | 8 | positive zero |
| `XNUDSD` | 1728 | 8 | positive zero |
| `XNUDSH` | 1736 | 8 | positive zero |
| `XNUDSM` | 1744 | 8 | positive zero |
| `XNUDST` | 1752 | 8 | positive zero |
| `XNUDSV` | 1760 | 8 | positive zero |
| `XNUDTE` | 1768 | 8 | positive zero |
| `XNUDVO` | 1776 | 8 | positive zero |
| `XNUDTG` | 1784 | 8 | positive zero |
| `XNUDQG` | 1792 | 8 | positive zero |
| `XNUDUG` | 1800 | 8 | positive zero |
| `XNUDVG` | 1808 | 8 | positive zero |
| `XNUDPG` | 1816 | 8 | positive zero |

The four nudging bytes at offsets 100 through 103 retain incoming values. The following table gives every TMCC field with a declaration default or a selected SUMCC store. The named declaration is applied before the selected source body. A blank declaration cell means that the source declaration does not set that scalar; a blank SUMCC cell means that the body leaves the declared or incoming scalar unchanged. The ordered assembly rows retain repeated source resets even where the final value is the same.

| TMCC member | Offset | Bytes | Declaration | Final SUMCC store |
| --- | ---: | ---: | --- | --- |
| `N923` | 0 | 4 |  | 0 |
| `NOACOMM` | 6080 | 4 |  | 2 |
| `NSSTICEOP` | 6084 | 4 |  | 9 |
| `LFIRSTUPD` | 6736 | 4 | .TRUE. |  |
| `LCURR` | 6740 | 4 |  | false |
| `LGELATO` | 6744 | 4 |  | false |
| `LMCC01_MSE` | 6748 | 4 |  | false |
| `LMCC01` | 6752 | 4 |  | false |
| `LMCC02` | 6756 | 4 |  | false |
| `LMCC03` | 6760 | 4 |  | false |
| `LMCC04` | 6764 | 4 |  | false |
| `LMCC05` | 6768 | 4 |  | false |
| `LMCCEC` | 6776 | 4 |  | false |
| `LMCCIEC` | 6780 | 4 |  | true |
| `LMCCIEC_COMPO` | 6784 | 4 |  | false |
| `LMCCICEIC` | 6788 | 4 |  | false |
| `LMCCDYNSEAICE` | 6792 | 4 |  | false |
| `LNEMOCOUP` | 6796 | 4 |  | false |
| `LNEMOFLUXNC` | 6800 | 4 |  | false |
| `LNEMOOUTGRB` | 6804 | 4 |  | false |
| `LCOUPINFOUT` | 6808 | 4 |  | false |
| `LNEMO1WAY` | 6812 | 4 |  | false |
| `LNEMOIFSLOG` | 6816 | 4 |  | false |
| `LNEMOSSTFREEZ` | 6820 | 4 |  | false |
| `LNEMOGRIBFLDS` | 6824 | 4 |  | false |
| `LNEMOGRIBMASK` | 6828 | 4 |  | false |
| `L2DECV2NEMO` | 6832 | 4 |  | false |
| `LMULTIYR` | 6836 | 4 |  | false |
| `LMCC_COMPO` | 6840 | 4 |  | false |
| `NFRCPL` | 6844 | 4 |  | 999999 |
| `LNEMOLIMGET` | 6848 | 4 | .TRUE. | false |
| `LNEMOLIMPUT` | 6852 | 4 | .TRUE. | false |
| `LNEMOLIMALB` | 6856 | 4 | .FALSE. | false |
| `LNEMOLIMTEMP` | 6860 | 4 | .FALSE. | false |
| `LNEMOLIMTLVL` | 6864 | 4 | .FALSE. | false |
| `LNEMOLIMTHK` | 6868 | 4 | .FALSE. | false |
| `LNEMOSICOUP` | 6872 | 4 | .FALSE. |  |
| `LNEMOATMFLDS` | 6876 | 4 | .TRUE. |  |
| `LNEMOOCEICEMIX` | 6880 | 4 | .FALSE. |  |
| `LNEMOQNSICEFILT` | 6884 | 4 | .FALSE. |  |
| `LNEMOACCUMFLUX` | 6888 | 4 | .TRUE. |  |
| `LNEMOGRIB3D` | 6892 | 4 |  | false |
| `NNEMO3DLEVS` | 6896 | 4 |  | 20 |
| `LNEMOPARTCOUP` | 7056 | 4 | .FALSE. |  |
| `LNEMOPARTMASK` | 7060 | 4 | .FALSE. |  |
| `LNEMOPARTMASKFILE` | 7064 | 4 | .FALSE. |  |
| `RNPARTRAMPSTART` | 7072 | 8 | 5.0_JPRB |  |
| `RNPARTRAMPLEN` | 7080 | 8 | 4.0_JPRB |  |
| `RNPARTLAT` | 7088 | 8 | 20.0_JPRB |  |
| `RNPARTLATSPREAD` | 7096 | 8 | 5.0_JPRB |  |
| `CDNPARTMASKFILE` | 7232 | 128 | 'partialmask.grib' |  |
| `CPLNG_ACTIVE` | 7424 | 4 | .FALSE. |  |
| `CPLNG_NUM_FIELDS` | 7428 | 4 | 0 |  |
| `IP_A_SST` | 7432 | 4 | -1 |  |
| `IP_A_ICE_FRAC` | 7436 | 4 | -1 |  |
| `IP_A_CURR_U` | 7440 | 4 | -1 |  |
| `IP_A_CURR_V` | 7444 | 4 | -1 |  |
| `IP_A_TAUX_OCE` | 7448 | 4 | -1 |  |
| `IP_A_TAUY_OCE` | 7452 | 4 | -1 |  |
| `IP_A_TAUX_ICE` | 7456 | 4 | -1 |  |
| `IP_A_TAUY_ICE` | 7460 | 4 | -1 |  |
| `IP_A_QS_MIX` | 7464 | 4 | -1 |  |
| `IP_A_QNS_MIX` | 7468 | 4 | -1 |  |
| `IP_A_QS_OCE` | 7472 | 4 | -1 |  |
| `IP_A_QNS_OCE` | 7476 | 4 | -1 |  |
| `IP_A_QS_ICE` | 7480 | 4 | -1 |  |
| `IP_A_QNS_ICE` | 7484 | 4 | -1 |  |
| `IP_A_PRECIP_LIQUID` | 7488 | 4 | -1 |  |
| `IP_A_PRECIP_SOLID` | 7492 | 4 | -1 |  |
| `IP_A_EVAP_TOTAL` | 7496 | 4 | -1 |  |
| `IP_A_EVAP_ICE` | 7500 | 4 | -1 |  |
| `IP_A_DQNS_DT` | 7504 | 4 | -1 |  |
| `IP_A_RUNOFF` | 7508 | 4 | -1 |  |
| `IP_A_TOTAL_CC` | 7512 | 4 | -1 |  |
| `IP_A_LOW_CC` | 7516 | 4 | -1 |  |
| `IP_A_ICE_TEMP` | 7520 | 4 | -1 |  |
| `IP_A_ICE_ALBEDO` | 7524 | 4 | -1 |  |
| `IP_A_ICE_THICKNESS` | 7528 | 4 | -1 |  |
| `IP_A_SNOW_THICKNESS` | 7532 | 4 | -1 |  |
| `IP_A_ICE_TEMP_LVLS` | 7536 | 4 | -1 |  |
| `IP_A_TAUX` | 7540 | 4 | -1 |  |
| `IP_A_TAUY` | 7544 | 4 | -1 |  |
| `IP_A_QS` | 7548 | 4 | -1 |  |
| `IP_A_QNS` | 7552 | 4 | -1 |  |
| `IP_A_WATER` | 7556 | 4 | -1 |  |
| `IP_A_SST_ATM` | 7560 | 4 | -1 |  |
| `IP_A_TSK_ATM` | 7564 | 4 | -1 |  |
| `IP_A_IST_ATM` | 7568 | 4 | -1 |  |
| `IP_A_2DECV_SKT` | 7572 | 4 | -1 |  |
| `LCOUPSIM` | 7576 | 4 | .FALSE. |  |

The partial-coupling filename contains `partialmask.grib` followed by spaces to its declared length of 128 bytes. The eleven descriptor data words below must be null on entry and remain null. A descriptor is the runtime metadata for an allocated array; with a null data word, no array is present. The remaining descriptor bytes are source-unwritten metadata. They retain incoming bits and must not be used while the owner is null.

| TMCC array owner | Descriptor offset | Descriptor bytes |
| --- | ---: | ---: |
| `CLIMRCO2` | 6088 | 112 |
| `CLIMRAER` | 6200 | 112 |
| `CLIMRCOMPO` | 6312 | 112 |
| `ZLAKE` | 6424 | 112 |
| `OCEANBC` | 6536 | 88 |
| `CLIMR` | 6624 | 112 |
| `RNEMOLVLS` | 6904 | 64 |
| `RNEMOMASK` | 6968 | 88 |
| `PARTSST0` | 7104 | 64 |
| `PARTMASK` | 7168 | 64 |
| `CPLNG_FLD` | 7360 | 64 |

These operations write 588 distinct TMCC bytes and retain the other 6996 bytes. Retained values include unused climatology arrays and indices, LMCC06, descriptor metadata and alignment gaps. Their values remain undefined before a later source producer writes them. Fresh zero storage is an allowed ordinary preimage, but a zero byte must not be treated as a source-defined default for these members. This component does not release arrays because it creates none and rejects a live incoming owner.

The selected empty NAMNUD and NAMMCC groups are checked independently from the beginning of the live input, matching the rewind in POSNAME. An uppercase exact group name must be the first nonblank marker within source columns one through ten. Only whitespace and comments are accepted before its terminating slash. The first matching group controls the result; a later duplicate does not enable an unsupported mode. Nonempty groups, LR2D true, noncanonical consumed logical values, live owners, invalid sizes, overlaps, address wrapping and a nonzero FPCR return two before mutation.

The retained critical gate compares three complete genuine source cases with 28,248 output bytes and zero differing bytes. These cover ordinary zero storage, two patterned retained preimages, either LMSE value, either LESICE value, leading empty groups, comments and later duplicates. A separate 7,584-byte comparison checks the owned declaration child against a fresh genuine TMCC declaration. Forty-eight independent disabled-mode relations check the weights, positive-zero coefficients, counts, coupling switches, default constants and inactive identifiers. Nine genuine source calls and four accepted native calls have immediate status observations. Native ABI masks are zero and FPCR, incoming FPSR and errno are retained. Genuine SUNUD and SUMCC change errno from 777 to zero through their input/output services and have the known x18 mask two; genuine SUTRAJP preserves it. No returned bytes or status values are masked.

Forty-six unsupported cases return before mutation, and ten protected ranges put every consumed record, the table and the text directly before an inaccessible page. The raw standalone entry starts with its own storage and explicit LMSE false, LESICE true, NFRCO zero and LR2D false inputs, reads live text and writes 9,416 bytes identical to the retained genuine record stream. It runs with PATH as its only environment setting, has no dynamic section and has no undefined symbols. Original provider bindings are checked without another model call; the three reference calls resolve to the genuine strict OpenIFS library. No forecast or performance claim is made.

The source definitions are `arpifs/setup/sutrajp.F90`, `sunud.F90`, `sumcc.F90`, their call order in `su0yoma.F90`, and the declarations in `arpifs/module/yomnud.F90` and `yommcc.F90`. The accepted upstream SUCT0 and complete SU0PHY producers supply LR2D, NFRCO, LMSE and LESICE. The retained NBITSEXPR view belongs to the output configuration; its later producer remains an explicit integration input. This component owns the selected written state and its declaration defaults. It does not enable nudging, two-dimensional mode or coupled ocean execution.
