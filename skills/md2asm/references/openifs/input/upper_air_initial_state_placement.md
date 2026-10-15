# Upper-Air Initial State Placement

This helper places decoded upper-air records in the original coarse model's grid-field buffer. It changes storage only. The [upper-air reader](initial_upper_air_field_reader.md) supplies the 76 records and preserves their values. This helper uses integer loads and stores, so it preserves every 64-bit value without clipping or arithmetic.

## Frozen Source And Fields

The selected original assignment is SUGRIDUG, lines 243–264 of arpifs/setup/sugridug.F90. The setup uses one process, 2,048 physical points, 19 vertical levels, eight fields and 86 blocks of 24 stored rows. The last block has eight physical rows. The input order is humidity at levels 1–19, then liquid water, ice and cloud fraction at each level. These fields use parameters 133, 246, 247 and 248.

| Model slot | Field | Update |
| --- | --- | --- |
| 1 | Specific humidity | Copy parameter 133 |
| 2 | Cloud liquid water | Copy parameter 246 |
| 3 | Cloud ice | Copy parameter 247 |
| 4 | Snow | Write positive zero |
| 5 | Rain | Write positive zero |
| 6 | Cloud fraction | Copy parameter 248 |
| 7–8 | Model diagnostic fields | Write positive zero |

Specific humidity and cloud condensates give each substance’s mass per unit mass of moist air, in kg/kg. Cloud fraction is dimensionless. This placement performs no physical update or change of units.

## Interface And Bounds

The application binary interface, or ABI, defines how arguments and registers pass data. The C-compatible entry is int md2asm_place_initial_upper_air_fields(values, values_bytes, metadata, metadata_bytes, gfl, gfl_bytes). Arguments x0 through x5 contain the six words in this order. Values and metadata are read-only. The complete gfl buffer is both an input and an output.

| Buffer | Representation | Minimum bytes |
| --- | --- | --- |
| values | 76 records of 2,048 consecutive 64-bit values | 1,245,184 |
| metadata | 76 rows of three signed 64-bit labels | 1,824 |
| gfl | Original Fortran shape (24, 19, 8, 86) | 2,509,824 |

Each pointer must be nonnull and aligned to eight bytes. The consumed address ranges must not wrap. The gfl range must be disjoint from both input ranges. The two immutable inputs may overlap. The caller must supply valid storage for every consumed byte. Capacity beyond the fixed extents remains untouched.

Each metadata row must contain the expected parameter, its level from 1 through 19, and the value count 2,048. All buffer and metadata checks finish before any output write. Return 0 means success, 1 means an invalid buffer or overlapping output, and 2 means unexpected metadata. Rejection preserves the entire output.

The leaf routine has no stack, child call or floating-point instruction. It preserves x18 through x30 and every vector register. FPCR is the floating-point control register, and FPSR stores floating-point status. Both remain unchanged for any incoming value, as does the library error indicator errno. Registers x0 through x17 and integer condition flags are scratch.

## Storage Map And Padding

Use zero-based indices. Let $`r`$ be the stored row, $`l`$ the level, $`s`$ the field slot and $`b`$ the block. Their ranges are 0–23, 0–18, 0–7 and 0–85. The point number p and target word w are

```math
p = 24b+r, \qquad w=r+24\bigl(l+19(s+8b)\bigr).
```

The raw record numbers for humidity, liquid, ice and cloud fraction are

```math
k_q=l, \quad k_l=19+3l, \quad k_i=20+3l, \quad k_c=21+3l.
```

For an active row, the input word is $`2048k+p`$. The four copies write 1,245,184 bytes. The zero assignments cover every stored row of slots 4, 5, 7 and 8, including their final padding, and write 1,254,912 bytes. The 9,728 padding bytes in copied fields remain exactly as supplied by the caller.

SUSC2C allocates GFL without assigning its values. ZERO_YOMGFL can clear this allocation, but its only named caller is the separate module procedure FIELDS_MOD:FIELDS_ZEROS. No call to that procedure is present in the selected setup and control route. The inherited FIELDS_BASE zero method is a different procedure. This helper therefore accepts and preserves an explicit complete incoming buffer. It does not assume its padding is zero. Full forecast setup must still supply a frozen complete starting buffer.

## Acceptance

The independent metadata-driven Fortran reference and direct assembly agree across all 2,509,824 bytes. Twelve critical cases pass, covering original data, distinct bit patterns, preserved padding, buffer bounds, metadata, shared inputs and rejection before output changes. Three seeded native ABI cases pass, and floating-point controls, status and errno remain unchanged. This isolated helper does not establish a complete autonomous forecast. Existing weather-routine counts remain unchanged.
