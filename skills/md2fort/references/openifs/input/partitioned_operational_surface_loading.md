# Partitioned Operational Surface Loading

This assembly loads the selected surface fields into the part of the 9 km grid owned by one process. It retains the accepted [decoder and selection](operational_surface_field_selection.md), [physical conversion](operational_initial_surface_state_loading.md) and [surface field mapping](operational_surface_state_placement.md). Their units, constants and ordered arithmetic remain unchanged. The new placement uses integer addresses and preserves every stored value bit.

## Live Partition And Owners

The read-only table contains six pairs of unsigned 64-bit words, each giving an output address and byte capacity. Append the same 32-byte [partition record](partitioned_operational_upper_air_loading.md) used by upper-air loading, making 128 bytes in total. The appended words give local point count $`N`$, map address, map capacity and block count $`B=\lceil N/17\rceil`$. Each signed 32-bit map entry is a one-based packed global point in 1 through 6,599,680. The upstream partition supplies unique points and complete distributed coverage. Placement accepts any valid local order.

| Owner | Meaning | Planes In Each Block | Required Bytes |
| --- | --- | ---: | --- |
| `SP_SB` | Soil | 24 | $`136\times24B`$ |
| `SP_SL` | Lake | 14 | $`136\times14B`$ |
| `SP_SG` | Snow | 50 | $`136\times50B`$ |
| `SP_RR` | Skin reservoir | 4 | $`136\times4B`$ |
| `SD_VF` | Fixed surface properties | 38 | $`136\times38B`$ |
| `SD_WS` | Waves | 3 | $`136\times3B`$ |

A plane stores one field within one block. Each block has 17 positions, and each value occupies eight bytes. Copy only active local points into selected planes. Padding, unselected planes, both default-only wave planes and capacity beyond the required span retain arbitrary incoming bytes. Keep the live partition owner until loading ends.

For zero-based local point $`p`$, read global word $`\operatorname{map}[p]-1`$ from the selected source plane. If its destination plane is $`r`$ and its owner has $`P`$ planes, write destination word

```math
(p\bmod17)+17\left(r+P\left\lfloor p/17\right\rfloor\right).
```

The 50 ordinary and 25 snow source planes retain their global shape and accepted order. No physical arithmetic changes in this placement.

## Assembly Interfaces

The application binary interface, or ABI, defines argument order and saved registers. `md2asm_place_partitioned_operational_surface_fields(field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes, table, table_bytes)` uses x0 through x7. The two immutable value arrays require 2,639,872,000 and 1,319,936,000 bytes. Parameters contains the unchanged 55 signed 32-bit identifiers in 220 bytes. Local count is 1 through 6,599,680. Every map index, identifier, complete output span and overlap is checked before the first output store.

The table, values and six destinations align to eight bytes. The map and identifiers align to four. Every consumed span is mapped and nonwrapping. Output owners are pairwise disjoint and disjoint from all immutable inputs. Return 0 succeeds, 1 refuses a buffer or shape, 2 refuses an identifier and 3 refuses a map index. The 112-byte frame preserves required integer registers. The only call is a private integer plane-copy helper. x18, vector registers, FPCR, FPSR and `errno` remain unchanged.

`md2asm_load_partitioned_operational_surface_state(path, configuration2304, configuration_capacity, table128, table_capacity, parameters220, parameter_capacity)` uses x0 through x6. Require FPCR zero. The readable zero-terminated path names `ICMGGacflINIT`. Configuration comes from live physical producers. The unchanged parent allocates one 8,236,403,880-byte temporary buffer, decodes all 81 records, selects 75 planes, applies accepted physical conversions, places local fields and releases the buffer.

The complete loader retains its 176-byte aligned frame and [existing error codes and status rules](operational_initial_surface_state_loading.md#ordered-calls-and-errors). Only its entry name, minimum table size and placement call change. Failed calls preserve the six model arrays. Production uses direct assembly and public ecCodes and C services. No original OpenIFS routine or saved reference field supplies a production stage.

## Acceptance And Limits

Ten small cases cover 1, 17, 18, 34 and 37 points, reordered maps, global endpoints, two arbitrary preimages and raw special value bits. All 325,584 complete output bytes agree. Eighteen placement ABI calls pass, including eight protected-output refusals. The integer routine also preserves a nondefault FPCR and incoming flags.

Four complete actual-file checks use the accepted distributed maps. All 7,022,123,360 owner bytes agree with retained genuine original physical conversion results and an independent traversal of local points. Of these bytes, 3,959,808,000 are selected values and 3,062,315,360 retain their incoming state. All 877,765,420 independent word relations pass. Eight complete-loader ABI calls check success and the changed table-size refusal on every process. Natural success status is FPCR 0, FPSR 16 and `errno` 777. Refusals preserve incoming 0, 24 and 777. Input protection, guards, padding and every acquired temporary release pass.

The unchanged decoder, selection, physical conversion and parent failure checks are reused. These are input-component checks, with no complete forecast or performance claim. Local source, interface, provider, input and result records remain under `.runtime/`.
