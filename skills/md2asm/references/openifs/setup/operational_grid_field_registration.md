# Operational Grid-Field Registration

This assembly constructs nine grid-field descriptions for the 137-layer operational case. A description records a field's name, storage position and calculation options. It does not contain the field's weather values. The reference is the original OpenIFS `SUGFL2` and `SUGFL3`. This checkpoint accepts their raw registration boundary with explicit profiles, rather than complete model setup or a forecast.

## Inputs and Interface

The application binary interface (ABI) defines how a function receives arguments and preserves registers. The main entry is `md2asm_register_operational_grid_fields`. Its six arguments use Arm registers x0 through x5.

| Argument | Size or value | Meaning |
| --- | --- | --- |
| x0 | 1,359,136 bytes | Fresh, zero-filled grid-field record |
| x1 | 2,304 bytes | Nine complete 256-byte input profiles |
| x2 | 520 bytes | Accepted owned physical-constant record |
| w3 | 137 | Number of vertical layers |
| w4 | 0 | Number of supplementary layers |
| x5 | 8 bytes | Two returned dynamics switches |

Every buffer must be mapped, have eight-byte alignment and have a complete address range that does not wrap. Writable output must not overlap another input or output. Profiles and constants remain unchanged. The two returned switches are false. The main function uses a 2,688-byte stack frame, preserves x18 and all required saved registers, and keeps the stack aligned to 16 bytes.

Use the accepted [profile defaults](selected_grid_field_profile_defaults.md), with the ozone profile's `LGP` switch set to true. `LGP` selects a grid-point field. Both snow and rain retain input request 1. Profile order is humidity, liquid water, ice water, snow, rain, cloud fraction, ozone and the two non-orographic gravity-wave fields. Gravity waves transfer momentum through the atmosphere. Complete production of these profiles from the operational configuration remains a separate parent checkpoint.

## Registration and Calculation Order

The component array has 2,163 embedded records. Initialise and reset every record through the accepted children before registering the nine active components. Preserve complete profile copies, source-defined defaults, inactive component bytes and all 61 field associations. No new physical equation is introduced.

| Component | Source name | Parameter code | Field identifier | Advection position | Physics position |
| --- | --- | --- | --- | --- | --- |
| 1 | Humidity | 133 | 47 | 2 | 2 |
| 2 | Liquid water | 246 | 49 | 4 | None |
| 3 | Ice water | 247 | 50 | 5 | None |
| 4 | Snow | 76 | 56 | 6 | None |
| 5 | Rain | 75 | 57 | 7 | None |
| 6 | Cloud fraction | 248 | 51 | 3 | 3 |
| 7 | Ozone | 203 | 48 | 1 | 1 |
| 8 | Gravity-wave tendency 1 | 228134 | -1 | None | None |
| 9 | Gravity-wave tendency 2 | 228136 | -1 | None | None |

Registration follows component order. Attribute assignment follows the original order of ozone, humidity, cloud fraction, liquid water, ice water, snow, rain and the two gravity-wave fields. An advection position identifies a field in the transport calculation. Its displacement is 137 times (its position minus one). The first five components form the mass-correction list. The ozone association points to component 7, and the two-element gravity-wave view starts at component 8. Other inactive associations retain their original targets.

The source retains exact 16-character names, including the leading space in ` OZONE          `. Named fields total seven, active fields total nine and physics fields total three. Each component retains its original backward link, constants, flags and optional-argument values. The first five components use the water family, cloud fraction and ozone use the other named-field family, and the last two use the gravity-wave family.

## Child Interfaces and Returns

The new definition child `md2asm_define_operational_grid_field_component` receives the grid-field record in x0, one embedded 368-byte component in x1, a 112-byte definition plan in x2 and family 0, 1 or 2 in w3. Its plan follows [the existing definition layout](field_component_definition.md).

The association child `md2asm_bind_operational_grid_field_aliases` receives the grid-field record in x0. Its complete association layout follows [the existing association contract](grid_field_aliases.md), with the two active targets stated above.

The attribute child `md2asm_set_operational_grid_field_attributes` receives the record in x0, one embedded component in x1, a 64-byte plan in x2, 137 layers in w3, zero supplementary layers in w4 and named-field or gravity-wave family 0 or 1 in w5. Its plan follows [the existing attribute layout](field_component_attributes.md). These three children use no stack frame and preserve the declared ABI and numerical status.

Return 0 means success. Return 2 rejects unsupported input before public mutation. Return 3 reports an unexpected child refusal after construction has started, so the caller must discard that record. The production graph calls only accepted direct assembly children. It uses no original OpenIFS routine, global storage, allocator or Fortran runtime. Existing eight-field entries remain unchanged.

## Accepted Evidence and Limits

Two separate reference and assembly processes used the same safely reserved record address. Both complete field records and switch outputs matched, for 2,718,288 equal bytes. The check also covered 366 independent field relations, 5,848,448 guard and outside-output bytes, immutable inputs, and six native ABI and status observations. Four refusals covered a wrong layer count, inactive ozone, a late invalid profile and a nonfresh output record.

The accepted physical-constant producer ran before each registration under incoming floating-point flags 0 or 24. Complete flags returned naturally as 16 or 24, with the error indicator unchanged. The original source's platform-register exception is recorded separately. Resolve shared-library symbols before seeding ABI observations. Local records retain the initial unaccepted check and the corrected transport setup. The assembly calculations did not change during acceptance.

Independent physical evidence for unchanged component defaults, reset, constants and interpolation-name children is reused. This result does not qualify operational configuration parsing, profile production, field storage, initial-value placement, complete startup or a forecast. Detailed build, interface and acceptance records remain local under `.runtime/`.
