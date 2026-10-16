/* Source declaration defaults and mandatory unallocated data words. */
.section .rodata
.p2align 3
.Lmodel_default_rows:
 .word 40,4
 .quad 0 /* NLAT */
 .word 44,4
 .quad 0 /* NLON */
 .word 48,4
 .quad 0 /* NFPHTYP */
 .word 52,4
 .quad 1 /* NFPTTYP */
 .word 56,8
 .quad 0 /* FPMUCEN */
 .word 64,8
 .quad 0 /* FPLOCEN */
 .word 72,8
 .quad 0 /* FPSTRET */
 .word 80,8
 .quad 0 /* NFPRGRI null data word */
 .word 144,8
 .quad 0 /* NFPMEN null data word */
 .word 208,8
 .quad 0 /* FPMU null data word */
 .word 272,8
 .quad 0 /* RDELY */
 .word 280,8
 .quad 0 /* RDELX */
 .word 288,4
 .quad 0 /* NFPRLX */
 .word 292,4
 .quad 0 /* NFPRUX */
 .word 296,4
 .quad 0 /* NFPRLY */
 .word 300,4
 .quad 0 /* NFPRUY */
 .word 304,4
 .quad 0 /* NFPGUX */
 .word 308,4
 .quad 0 /* NFPLUX */
 .word 312,4
 .quad 0 /* NFPBWX */
 .word 316,4
 .quad 0 /* NFPBWY */
 .word 320,8
 .quad 0 /* RLATC */
 .word 328,8
 .quad 0 /* RLONC */
 .word 336,8
 .quad 0 /* FPLON0 */
 .word 344,8
 .quad 0 /* FPLAT0 */
 .word 352,4
 .quad 0 /* LFPMRT */
 .word 356,4
 .quad 0 /* LFPMAP */
 .word 360,8
 .quad 0 /* FPLX */
 .word 368,8
 .quad 0 /* FPLY */
 .word 376,4
 .quad 0 /* NFPBZONL */
 .word 380,4
 .quad 0 /* NFPBZONG */
 .word 384,4
 .quad 1 /* NFPEDOM */
 .word 388,4
 .quad 0 /* NFPMAX */
 .word 392,4
 .quad 0 /* NMFPMAX */
 .word 396,4
 .quad 0 /* NFPNOEXTZL */
 .word 400,4
 .quad 0 /* NFPNOEXTZG */
 .word 436,4
 .quad 0 /* NFPDIST */
 .word 440,4
 .quad 0 /* NFPRESOL */
 .word 444,4
 .quad 0 /* NSPEC2 */
 .word 448,4
 .quad 0 /* NSPEC2G */
 .word 452,4
 .quad 0 /* NGPTOT */
 .word 456,4
 .quad 0 /* NGPTOTX */
 .word 460,4
 .quad 0 /* NFPSIZEG */
 .word 464,4
 .quad 0 /* NFPSIZEG_DEP */
.Lmodel_default_rows_end:
.p2align 3
.Lmodel_spaces:.quad 0x2020202020202020
.Lmodel_constants:
 .quad 0x4066800000000000
 .quad 0x3d19000000000000
 .quad 0x3d83880000000000
