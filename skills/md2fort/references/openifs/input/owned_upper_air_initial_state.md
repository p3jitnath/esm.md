# Owned Upper-Air Initial State

Revision 1 creates the complete selected grid-point storage and loads the original upper-air initial file without an OpenIFS harness or Fortran service. It composes the qualified TGFL constructor, upper-air reader and placement stage. It adds no physical equation. TGFL stores humidity, cloud quantities and other transported fields in eight slots. The selected array has 24 rows per block, 19 vertical levels, eight fields and 86 blocks, with 2,048 physical horizontal points. Its complete GFL owner contains 2,509,824 bytes.

## Interface And Storage

The interface is int md2asm_create_loaded_upper_air_state(path, configuration, output). Registers x0, x1 and x2 carry a readable C path, a borrowed caller-owned 1,359,136-byte field-configuration namespace and a writable eight-byte output-pointer slot. The configuration and output are eight-byte aligned and all complete consumed ranges are mapped, nonwrapping and disjoint. The path ends within 4,096 bytes and is disjoint from both ranges. The configuration remains unchanged and outlives the returned context. This utility only stores its address through TGFL and does not read or initialise its field maps. Each later consumer still requires its configuration producer to finish those maps.

The selected constructor uses the explicit seven-word controls 24, 19, 86, 8, 2, 0 and 0. It owns the complete 1,104-byte context and all four source allocations, including GFLSLP and two allocated empty owners. It leaves every numerical payload byte incoming where the original allocator does. The returned pointer selects the source-compatible 1,096-byte TGFL record at the start of the context. Its qualified paired release is md2asm_release_gridpoint_field_context. The caller must not use a released context.

## Canonical Incoming Padding

The final block contains eight physical rows and sixteen unused rows. The existing loader copies fields 1, 2, 3 and 6 at physical points, clears complete fields 4, 5, 7 and 8 and preserves the copied fields' unused rows. The retained genuine SUGRIDUG before/after files establish that all 9,728 preserved padding bytes are positive zero. Original SUSC2C allocation does not promise this value, and no selected ZERO_YOMGFL call is required by this composition.

This parent therefore defines exactly those incoming padding ranges as positive zero before file placement. It changes no physical preimage word and does not fill GFLSLP or the two empty owners. There are 76 ranges, each 128 bytes. Their first byte offsets from GFL are 2,480,704 plus 3,648 times the zero-based field index plus 192 times the zero-based level index. Field indices are 0, 1, 2 and 5, while levels run from 0 through 18. The final range ends before byte 2,509,824. This is a matched incoming-storage rule, not a change to returned output bytes. The accepted loader retains its original complete placement and padding semantics.

## Execution And Errors

Validate all caller ranges and require FPCR zero before construction. Create the owned TGFL context, set only the declared incoming padding, then invoke the unchanged direct upper-air loader on its complete GFL allocation. Publish the output pointer only after complete success. Any child failure releases every acquired owner and leaves the caller's output slot unchanged. Return zero for success, one for invalid arguments or mode, 16 plus a constructor error, or 32 plus a loader error. The output record and all retained numerical bytes are never rounded or repaired.

The parent uses an 80-byte stack aligned to sixteen bytes and preserves x18, x19 through x29 and v8 through v15. It performs integer address calculations and zero stores only. The qualified children preserve FPCR, FPSR and errno, so the parent preserves them too. Its only callees are the three direct assembly constructor, loader and release entries. Production dependencies are their declared libc services and ecCodes C file decoding, with no original module data, type table, callable or numerical fallback. No full SUGRIDUG or autonomous-forecast credit is claimed.

## Acceptance

Require complete GFL-byte agreement with the retained genuine source return and reuse the independent decoder/physical and placement checks. Verify the new incoming-padding stage under a distinct allocation preimage, including a failed file read before any placement. Check the other complete owners, borrowed configuration, guards, immediate ABI/status and failure cleanup. Inspect a pure standalone process and the complete external-library boundary, then obtain independent source/ABI review. No model run or timing is needed for unchanged numerical children.

## Completed Checkpoint

Three genuine source cases match all 7,529,472 GFL bytes, preserve 1,882,374 bytes in the other owners and leave 4,077,408 borrowed-configuration bytes unchanged. Thirteen immediate ABI and status calls have zero native failure masks. Two failed reads prove that only the declared 9,728 incoming padding bytes change before placement. One constructor failure cleans up, four invalid inputs reject before mutation and 864 allocation-guard bytes remain intact. Independent source and ABI review passes. The complete [standalone input program](standalone_initial_bootstrap.md) also writes all three owners exactly without an OpenIFS or Fortran production dependency.
