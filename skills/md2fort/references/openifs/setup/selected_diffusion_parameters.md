# Selected Vertical Diffusion Parameters

Revision 1 constructs the complete selected TVDF record from SUVDF. Vertical diffusion exchanges momentum, heat and water between neighbouring atmospheric layers. These parameters set its mixing length and time integration. Production uses live configuration text and caller-owned storage, with no original MODEL, module variable, procedure table, returned parameter packet or OpenIFS callable.

The ABI is int md2asm_initialize_selected_diffusion_parameters(text, bytes, output, capacity). Registers x0 through x3 contain immutable live configuration bytes, their length, a writable eight-byte-aligned record and its capacity. Length is one through 262,144 bytes and capacity is at least 72 bytes. Both complete consumed spans must be mapped and nonwrapping. The output span is disjoint from the text. It may contain any incoming bytes. Return zero on success or two before mutation for unsupported input or FPCR other than zero. The caller owns the record and no release is needed.

The first supported uppercase NAMVDF and NAMDYNCORE groups must both be empty. An opening marker is the first nonblank token within the first ten source columns. Whitespace and comments beginning with an exclamation mark are accepted; slash closes the group. Lowercase names do not replace the actual uppercase group, following POSNAM literal matching. Assignments and unsupported syntax are rejected before any output changes. The empty NAMDYNCORE group establishes source default RUSPLRG equal to one and RPLRG equal to one divided by RUSPLRG. This component owns that consumed scalar relation only and does not claim the remaining SUDYNCORE outputs.

TVDF occupies 72 bytes. RLAM at byte zero receives 150 divided by RPLRG, in metres. RVDIFTS at byte eight receives 1.5, the time-step weighting factor. LWDS at byte sixteen receives false, selecting the original time integration. REPS1WDS, REPS2WDS and RETAWDS at bytes twenty-four, thirty-two and forty hold the alternative time-integration coefficients. RTOFDALPHA at byte forty-eight receives 24, a dimensionless numerical control. REISTHSC at byte fifty-six receives five kelvin, the inversion-strength threshold for stratocumulus. NSUBST at byte sixty-four receives one substep. Source-unwritten padding at bytes twenty through twenty-three and sixty-eight through seventy-one retains its incoming bytes.

The following dimensionless coefficients define the alternative time integration. Evaluate each ordinary arithmetic operation in FP64 with ties to even, preserving the written parentheses and left-to-right sums.

```math
a=\sqrt{2},\qquad b=1+1/a,\qquad c=\sqrt{1\,(a-1)+0.5}.
```

```math
\mathrm{REPS1WDS}=b\,((1+1/a)+c),\qquad\mathrm{REPS2WDS}=b\,((1+1/a)-c),\qquad\mathrm{RETAWDS}=b\,(1+1).
```

The frozen strict compiler folds these input-independent equations to constant stores. Assembly stores words derived from those equations and independently checked against the complete source. It retains the runtime source division for RLAM. No captured final record supplies these words, and the original numerical status remains explicit.

The component preserves x18, all saved integer and vector registers, FPCR, FPSR and errno in the selected exact-division case. It uses a 48-byte, sixteen-byte-aligned stack frame and performs no allocation or external call. The live-text validator is an integer-only child. Independent high-precision coefficient identities, complete genuine SUVDF output bytes under distinct incoming patterns, immediate status, guards and before-mutation rejects are required. The original namelist and logging services remain verification-only, and their immediate arithmetic flags, errno and x18 are reported separately. A pure assembly executable must own its record and input text. No forecast or timing is needed for this parameter stage.

## Recorded Result

Three complete genuine SUVDF calls agree in all 216 TVDF bytes, including the eight incoming padding bytes per case. They cover the actual file, a lowercase duplicate before the real uppercase group, comments within the selected group and distinct incoming patterns and flags. The source constructs RPLRG through a genuine SUDYNCORE call before the SUVDF observation boundary. The native producer passes each immediate ABI and status check and preserves the selected arithmetic flags and errno. Original numeric formatting adds the inexact flag and clears errno, while its runtime route changes x18; these service differences are recorded without changing or masking either result.

The combined parameter check passes twelve independent coefficient and physical-parameter relations. Twenty-two diffusion input rejections preserve every output byte, and three valid text cases terminate at a protected memory page, including a final readable slash and a marker in column ten. Complete caller guards remain intact. A pure assembly entry constructs this record and TECND, then reproduces all 88 combined bytes with no shared library or undefined symbol. The source provider check resolves all three genuine SUDYNCORE, SUVDF and SUCOND slots without another numerical call. No forecast or timing was run.
