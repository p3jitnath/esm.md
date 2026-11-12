# Operational serial grid maps

This assembly child implements the complete map calculation after `SUALMP2` in the original `SUMP` routine. It fills the level, latitude, global-point, processor and blocked-point maps for the supported global grid. The older `serial_partition_maps.S` parent remains unchanged. The preceding inquiries, spectral distribution, storage allocation and complete operational `SUMP` caller remain unfinished.

The application binary interface (ABI) is `int md2asm_initialize_operational_serial_grid_maps(void *geometry, const int32_t settings[7])`. The arguments use x0 and x1, and w0 returns zero on success, one if the private workspace allocation fails, or two if a checked input condition fails. Geometry contains 17,096 mapped bytes and is eight-byte aligned. Settings is four-byte aligned and contains NPRTRV, NPRTRW, NPRTRNS, the north/south and east/west region counts, process rank and process count. All seven values are one on this serial route. The caller owns the complete Geometry record, all 34 partition arrays and the borrowed PL array, which gives the number of points on each latitude row. Their complete spans must be mapped, aligned and disjoint.

The supported dimensions are 137 levels, truncation 1279, 2,560 latitude rows, at most 5,136 points on a row and 6,599,680 active grid points. NPROMA is 17, so 388,217 blocks contain the active points and nine padding cells. Local rows span 1:2560. The input query fields have NFRSTLOFF and NPTRFLOFF zero, NFRSTLAT and NPTRFRSTLAT one, NLSTLAT 2560 and NPTRLL starting at one. NSTA and NONL have canonical rank-two int32 descriptors with bounds −1:2562 by 1:1. On active rows, NSTA is one and NONL equals PL. The borrowed PL descriptor has bounds −1:2562. Active row lengths must be positive, at most 5,136, and sum to 6,599,680. Halo cells outside the active rows retain their incoming bytes.

A descriptor stores an array address, element size, strides and index bounds. The following eight output descriptors keep their complete metadata and addresses. All arrays contain int32 words, each four bytes. The first index of a blocked array varies fastest, so consecutive groups of 17 points form its blocks.

| Output | Descriptor byte offset in Geometry | Shape | Complete bytes |
| --- | ---: | --- | ---: |
| MYLEVS | 5960 | 137 | 548 |
| MYLATS | 7144 | 2560 | 10,240 |
| NGLOBALINDEX | 6648 | 6,599,680 | 26,398,720 |
| NGLOBALAT | 6712 | 6,599,680 | 26,398,720 |
| NGLOBALPROC | 6776 | 6,599,680 | 26,398,720 |
| NLOCALINDEX | 6840 | 6,599,680 | 26,398,720 |
| NLATGPP | 6904 | 17 by 388,217 | 26,398,756 |
| NLONGPP | 6992 | 17 by 388,217 | 26,398,756 |

The eight outputs contain 158,403,180 bytes. The child preserves every Geometry byte, the other 26 partition payloads and the complete borrowed PL array. It allocates one private rectangular `IGLOBAL(5136,2560)` workspace of 52,592,640 bytes, zeros every cell and fills active cells in increasing row and longitude order. The map loops retain the original integer relations and source order. Global indices increase across the ragged rows, processor indices are one, and the inverse local map returns the corresponding point index. Both blocked maps are first filled with −99999, which remains in the final nine cells. The complete rectangular workspace padding is defined zero. No source before-image supplies production calculations.

All byte extents and address products use 64-bit arithmetic. The frame contains 256 bytes and keeps the stack aligned to 16 bytes. The child preserves x18, the ABI saved registers, FPCR, FPSR and errno. Allocation failure occurs before any output write, and every acquired workspace is released. The original fatal check for a contradictory final block count remains; the checked point sum excludes that condition from supported inputs. The only external services are public `malloc`, `free` and errno access. No original OpenIFS or Fortran routine supplies a production stage.

Two genuine source profiles pass 316,806,360 complete output bytes and 634,052,656 checked bytes with zero differences, including all read-only owners, records, guards and the two refusal controls. The reference calls the unchanged original SUMP prefix only to produce explicit component inputs, then captures the region before and after its complete calculation. The two allocation patterns are 0x5b and 0xa7. Natural region-entry and region-exit status is FPCR zero, incoming FPSR zero or 24, and errno 777. Four native ABI observations are zero. A private workspace failure and a truncation-1278 refusal preserve all caller bytes. Independent integer checks pass 79,201,592 public-map relations and 26,296,320 complete rectangular-workspace relations. Source and pure-native verification run in separate bounded processes; the native process maps no OpenIFS or Fortran library.

The reference prefix retains its explicit NMSMAX value zero, which this child does not read or change. This result does not qualify the operational allocation prefix, full SUMP composition, complete Geometry initialization or a forecast. The separately qualified storage and stream children retain their own input contracts.
