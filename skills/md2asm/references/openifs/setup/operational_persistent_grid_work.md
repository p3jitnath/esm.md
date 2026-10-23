# Persistent Grid Work Storage

GP_MODEL_HEAP2 keeps four work arrays between time steps. Work arrays hold intermediate values for later calculations. This owner preserves the original array shapes and leaves their numerical payloads undefined until the first source write. It does not change a physical equation.

`md2asm_create_operational_grid_work(G,G_capacity,MODEL,MODEL_capacity,output_slot)` uses x0 through x4. G and MODEL contain 20,400 and 4,275,088 mapped bytes. Output is an eight-byte slot containing zero. All ranges are eight-byte aligned, disjoint and nonwrapping. Live scalar producers must have supplied the selected dimensions before this call. A positive NASLB1 count does not by itself create the transport map that later calculations need.

The selected dimensions are 17 columns, 137 layers, 97,055 blocks, 12 work fields and transport field counts 3,337 and 1,097. NASLB1 is the first transport buffer's leading extent, from 1 through 2,000,000. Actual process maps require 1,744,925 or 1,783,837. Read these values from G bytes 5144, 5224 and 5160, and MODEL bytes 1570608, 1574784, 1573016 and 1573320. These source counts are signed 32-bit integers. NASLB1_TRUE occupies the next four bytes after NASLB1 and stays unread and unchanged. Extend only the loaded NASLB1 value into the 64-bit work-record slot.

| Owner | Element type and shape | Bytes |
| --- | --- | --- |
| IL0 | 32-bit integer, 17 by 137 by 4 by 97,055 | 3,616,657,520 |
| ZLSCAW | FP64, 17 by 137 by 12 by 97,055 | 21,699,945,120 |
| SLBUF1 | FP64, NASLB1 by 3,337 | 26,696 times NASLB1 |
| SLBUF2 | FP64, 17 by 1,097 by 97,055 | 14,479,829,560 |

IL0's third lower bound is zero. Other lower bounds are one. A separate 128-byte record borrows G and MODEL at bytes 0 and 8. Pointer/byte-count pairs start at 16, 32, 48 and 64 in table order. Four 32-bit shape words start at 80, followed by NASLB1 at 96, the two transport counts at 104 and 108, the four-bit acquired-owner mask at 112 and a zero reserved word at 120. Publish this record only after all payload allocations succeed. Retain the same live shape through the loop, and reconstruct the owner before using a different shape.

Return 0 on success, 1 after allocation failure and reverse cleanup, or 2 before allocation on interface refusal. `md2asm_release_operational_grid_work(output_slot)` frees the four payloads in reverse order, frees the record and clears the slot. Empty release succeeds. G and MODEL stay borrowed. Constructor and release frames have 160 and 96 bytes, aligned to 16. Both preserve x18, saved registers and floating-point control FPCR. FPCR is zero on construction. Natural flags and the system error value remain visible. Only public malloc and free remain external.

Typed source declarations confirm all shapes and byte extents. Four valid extent cases, exact defined record words, address relations, complete input preservation, guards, atomic refusals and every partial-allocation failure pass. Source and native allocation status agree. No full forecast or complete live transport-map acceptance follows.
