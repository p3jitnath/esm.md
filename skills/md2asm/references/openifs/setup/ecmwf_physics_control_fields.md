# Selected Physics Control Fields

Three small assembly entries preserve the original minimum sea-ice fraction and composition switches. All use integer instructions so an unchanged floating-point value keeps all its bits, including either signed zero. These are source assignments, rather than new physical equations.

`md2asm_minimum_surface_ice_fraction_fields` takes a writable FP64 address in `x0`, a dynamic-sea-ice boolean in `w1` and a one-way-coupling boolean in `w2`. The value must be finite and lie between minus one and one. Each boolean is zero or one. A negative value becomes 0.005 when dynamic sea ice is active without one-way coupling, or 0.02 otherwise. Nonnegative values and negative zero remain unchanged. The eight-byte span must be aligned, mapped and nonwrapping.

`md2asm_initialize_selected_composition_aerosol_flags` takes an eight-byte output pair, its capacity, three live 32-bit composition counts and their capacity in `x0` through `x3`. The counts are `NCHEM`, `NGHG` and `NAERO`, in that order. This selected interface requires all three to be zero, matching the original inactive `NAMCOMPO` read. It writes the original `SUGFL1` false assignments for `LAERNITRATE` and `LAERSOA`. The output and twelve-byte input spans must be mapped, disjoint, nonwrapping and aligned to eight and four bytes respectively.

`md2asm_initialize_ecmwf_physics_runtime_inputs` takes a writable 32-byte runtime record and its capacity in `x0` and `x1`. It writes the source-selected false `LSCMEC` and `LVDFTRAJ` flags at bytes zero and four. The original build leaves roughness controls in zero-initialised static storage, so this selected platform policy supplies false `LROUGH` at byte eight and zero FP64 `REXTZ0M` and `REXTZ0H` at bytes 16 and 24. Bytes 12 through 15 are padding and remain unchanged. The complete record must be eight-byte aligned, mapped and nonwrapping. Two incoming runtime patterns and the enclosing source comparison qualify this producer.

All entries return zero on success or two on refusal. Refusal makes no write. They preserve `x18`, all callee-saved registers, stack alignment, FPCR, FPSR and errno. They allocate no storage and call no external service.

Nineteen genuine source-assignment cases match all 152 output bytes, including negative values, positive values and both signed zeros. All 38 source and direct ABI calls pass, and seven refusal cases preserve their outputs. Unchanged numerical child checks are reused. These assignments do not establish a complete forecast.
