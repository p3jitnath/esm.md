#include "../../support/gpu/preserved_weather_calls.inc.S"
// Complete direct FFT992 and its contained RPASSF and QPASSF.
// Physics: formulations/openifs/dynamics/real_fourier_transform.md.
// Contract: skills/md2asm/references/openifs/dynamics/real_fourier_transform.md.
// Original source: OpenIFS 48.1.1 contrib/ectrans/src/trans/algor/fft992.F90.
// Parent ABI: x0=A, x1=TRIGS, x2=IFAX, x3=INC, x4=JUMP, x5=N, x6=LOT, x7=ISIGN.
// Each argument is a pointer; integers are signed 32-bit and fields are FP64.
// A has (N+1)*INC+(LOT-1)*JUMP+1 words; TRIGS has N words and IFAX has ten integers.
// Field words need 8-byte alignment; integer words need 4-byte alignment.
// Child ABI: x0=A, x1=B, x2=C, x3=D, x4=TRIGS, x5=INC1, x6=INC2, x7=INC3.
// Stack child pointers at offsets 0, 8, 16, 24, 32, 40, 48 name INC4,LOT,N,IFAC,LA,IERR,LIPL.
// The child views overlap only as recorded in the parent; all writes stay in the complete owners.
// Each fixed frame is 2048 bytes; parent scratch has N*LOT+1 words plus 64 outgoing-argument bytes.
// Entries preserve x18, x19 through x29, d8 through d15, stack alignment, FPCR and errno.
// x0 through x17, d0 through d7 and d16 through d31 are temporary registers.
// Stored square-root constants retain canonical rounded bits; runtime reciprocal uses separate FDIV.
// The parent and both contained passes own each numerical stage.
// Single-thread call counters identify actual parent and contained-pass execution.
// Source statement numbers identify the reviewed ordered equations.
.arch armv8-a
.text
.p2align 4
.global md2asm_fft992
.type md2asm_fft992, %function
md2asm_fft992:
    sub sp, sp, #2048
    stp x29, x30, [sp]
    str x18, [sp, #16]
    mov x29, sp
    str x0, [x29, #128]
    str x1, [x29, #136]
    str x2, [x29, #144]
    str x3, [x29, #152]
    str x4, [x29, #160]
    str x5, [x29, #168]
    str x6, [x29, #176]
    str x7, [x29, #184]
    ldr x9, [x29, #152]
    ldrsw x9, [x9]
    str x9, [x29, #208]
    ldr x9, [x29, #160]
    ldrsw x9, [x9]
    str x9, [x29, #224]
    ldr x9, [x29, #168]
    ldrsw x9, [x9]
    str x9, [x29, #200]
    ldr x9, [x29, #176]
    ldrsw x9, [x9]
    str x9, [x29, #256]
    ldr x9, [x29, #184]
    ldrsw x9, [x9]
    str x9, [x29, #288]
    adrp x16, md2asm_fft992_calls
    add x16, x16, :lo12:md2asm_fft992_calls
    ldr x9, [x16]
    add x9, x9, #1
    str x9, [x16]
    ldrsw x9, [x29, #200]
    ldrsw x10, [x29, #256]
    mul x9, x9, x10
    mov x10, #1
    add x9, x9, x10
    lsl x9, x9, #3
    add x9, x9, #79
    and x9, x9, #-16
    sub sp, sp, x9
    add x9, sp, #64
    str x9, [x29, #384]
// Original source line 190: NFAX=IFAX(1)
    mov x9, #1
    ldr x16, [x29, #144]
    sub x9, x9, #1
    ldrsw x10, [x16, x9, lsl #2]
    str w10, [x29, #280]
// Original source line 191: IF (ISIGN.EQ.+1) THEN
    ldrsw x10, [x29, #288]
    mov x9, #1
    cmp x10, x9
    cset x10, eq
    cbz x10, .Lmd2asm_fft992_if_false_2
// Original source line 196: I=1
    mov x10, #1
    str w10, [x29, #296]
// Original source line 199: DO J=1,LOT
    mov x10, #1
    str w10, [x29, #232]
    ldrsw x10, [x29, #256]
    str x10, [x29, #392]
    mov x10, #1
    str x10, [x29, #400]
.Lmd2asm_fft992_do_4:
    ldrsw x10, [x29, #232]
    ldr x9, [x29, #392]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_5
// Original source line 200: A(I+INC)=0.5_JPRB*A(I)
    adrp x16, .Lfft_constant_0
    ldr d0, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #296]
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #296]
    ldrsw x10, [x29, #208]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 201: I=I+JUMP
    ldrsw x9, [x29, #296]
    ldrsw x10, [x29, #224]
    add x9, x9, x10
    str w9, [x29, #296]
// Original source line 202: ENDDO
    ldrsw x9, [x29, #232]
    ldr x10, [x29, #400]
    add x9, x9, x10
    str x9, [x29, #232]
    b .Lmd2asm_fft992_do_4
.Lmd2asm_fft992_do_done_5:
// Original source line 203: IF (MOD(N,2).EQ.0) THEN
    ldrsw x10, [x29, #200]
    mov x9, #2
    sdiv x11, x10, x9
    msub x10, x11, x9, x10
    mov x9, #0
    cmp x10, x9
    cset x10, eq
    cbz x10, .Lmd2asm_fft992_if_false_6
// Original source line 204: I=N*INC+1
    ldrsw x10, [x29, #200]
    ldrsw x9, [x29, #208]
    mul x10, x10, x9
    mov x9, #1
    add x10, x10, x9
    str w10, [x29, #296]
// Original source line 207: DO J=1,LOT
    mov x10, #1
    str w10, [x29, #232]
    ldrsw x10, [x29, #256]
    str x10, [x29, #408]
    mov x10, #1
    str x10, [x29, #416]
.Lmd2asm_fft992_do_8:
    ldrsw x10, [x29, #232]
    ldr x9, [x29, #408]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_9
// Original source line 208: A(I)=0.5_JPRB*A(I)
    adrp x16, .Lfft_constant_0
    ldr d0, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #296]
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #296]
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 209: I=I+JUMP
    ldrsw x9, [x29, #296]
    ldrsw x10, [x29, #224]
    add x9, x9, x10
    str w9, [x29, #296]
// Original source line 210: ENDDO
    ldrsw x9, [x29, #232]
    ldr x10, [x29, #416]
    add x9, x9, x10
    str x9, [x29, #232]
    b .Lmd2asm_fft992_do_8
.Lmd2asm_fft992_do_done_9:
// Original source line 211: ENDIF
.Lmd2asm_fft992_if_false_6:
.Lmd2asm_fft992_if_end_7:
// Original source line 213: IA=INC+1
    ldrsw x10, [x29, #208]
    mov x9, #1
    add x10, x10, x9
    str w10, [x29, #304]
// Original source line 214: LA=1
    mov x10, #1
    str w10, [x29, #272]
// Original source line 215: IGO=+1
    mov x10, #1
    str w10, [x29, #336]
// Original source line 217: DO K=1,NFAX
    mov x10, #1
    str w10, [x29, #264]
    ldrsw x10, [x29, #280]
    str x10, [x29, #424]
    mov x10, #1
    str x10, [x29, #432]
.Lmd2asm_fft992_do_10:
    ldrsw x10, [x29, #264]
    ldr x9, [x29, #424]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_11
// Original source line 218: IFAC=IFAX(K+1)
    ldrsw x9, [x29, #264]
    mov x10, #1
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    ldrsw x10, [x16, x9, lsl #2]
    str w10, [x29, #328]
// Original source line 219: IERR=-1
    mov x10, #1
    neg x10, x10
    str w10, [x29, #320]
// Original source line 220: IF (K.EQ.NFAX.AND.NFAX.GT.2.AND.IGO.EQ.+1) THEN
    ldrsw x10, [x29, #264]
    ldrsw x9, [x29, #280]
    cmp x10, x9
    cset x10, eq
    ldrsw x9, [x29, #280]
    mov x11, #2
    cmp x9, x11
    cset x9, gt
    and x10, x10, x9
    ldrsw x9, [x29, #336]
    mov x11, #1
    cmp x9, x11
    cset x9, eq
    and x10, x10, x9
    cbz x10, .Lmd2asm_fft992_if_false_12
// Original source line 221: LIPL=.TRUE.
    mov x10, #1
    str w10, [x29, #376]
// Original source line 222: ELSE
    b .Lmd2asm_fft992_if_end_13
.Lmd2asm_fft992_if_false_12:
// Original source line 223: LIPL=.FALSE.
    mov x10, #0
    str w10, [x29, #376]
// Original source line 224: ENDIF
.Lmd2asm_fft992_if_end_13:
// Original source line 225: IF (INC.EQ.1.AND.JUMP.LT.(2*N).AND.K.GT.1.AND.K.LT.(NFAX-MOD(NFAX,2))) THEN
    ldrsw x10, [x29, #208]
    mov x9, #1
    cmp x10, x9
    cset x10, eq
    ldrsw x9, [x29, #224]
    mov x11, #2
    ldrsw x12, [x29, #200]
    mul x11, x11, x12
    cmp x9, x11
    cset x9, lt
    and x10, x10, x9
    ldrsw x9, [x29, #264]
    mov x11, #1
    cmp x9, x11
    cset x9, gt
    and x10, x10, x9
    ldrsw x9, [x29, #264]
    ldrsw x11, [x29, #280]
    ldrsw x12, [x29, #280]
    mov x13, #2
    sdiv x14, x12, x13
    msub x12, x14, x13, x12
    sub x11, x11, x12
    cmp x9, x11
    cset x9, lt
    and x10, x10, x9
    cbz x10, .Lmd2asm_fft992_if_false_14
// Original source line 227: INCA=LOT
    ldrsw x10, [x29, #256]
    str w10, [x29, #352]
// Original source line 228: JUMPA=1
    mov x10, #1
    str w10, [x29, #248]
// Original source line 229: ELSE
    b .Lmd2asm_fft992_if_end_15
.Lmd2asm_fft992_if_false_14:
// Original source line 230: INCA=INC
    ldrsw x10, [x29, #208]
    str w10, [x29, #352]
// Original source line 231: JUMPA=JUMP
    ldrsw x10, [x29, #224]
    str w10, [x29, #248]
// Original source line 232: ENDIF
.Lmd2asm_fft992_if_end_15:
// Original source line 233: IF (IGO.EQ.+1) THEN
    ldrsw x10, [x29, #336]
    mov x9, #1
    cmp x10, x9
    cset x10, eq
    cbz x10, .Lmd2asm_fft992_if_false_16
// Original source line 235: CALL RPASSF(A(IA),A(IA+LA*INCA),WORK(1),WORK(IFAC*LA*LOT+1),TRIGS,INCA,LOT,JUMPA,1,LOT,N,IFAC,LA,IERR,LIPL)
    ldrsw x10, [x29, #304]
    sub x10, x10, #1
    ldr x16, [x29, #128]
    add x10, x16, x10, lsl #3
    mov x0, x10
    ldrsw x10, [x29, #304]
    ldrsw x9, [x29, #272]
    ldrsw x11, [x29, #352]
    mul x9, x9, x11
    add x10, x10, x9
    sub x10, x10, #1
    ldr x16, [x29, #128]
    add x10, x16, x10, lsl #3
    mov x1, x10
    mov x10, #1
    sub x10, x10, #1
    ldr x16, [x29, #384]
    add x10, x16, x10, lsl #3
    mov x2, x10
    ldrsw x10, [x29, #328]
    ldrsw x9, [x29, #272]
    mul x10, x10, x9
    ldrsw x9, [x29, #256]
    mul x10, x10, x9
    mov x9, #1
    add x10, x10, x9
    sub x10, x10, #1
    ldr x16, [x29, #384]
    add x10, x16, x10, lsl #3
    mov x3, x10
    ldr x10, [x29, #136]
    mov x4, x10
    add x10, x29, #352
    mov x5, x10
    add x10, x29, #256
    mov x6, x10
    add x10, x29, #248
    mov x7, x10
    mov x10, #1
    str x10, [x29, #440]
    add x10, x29, #440
    str x10, [sp, #0]
    add x10, x29, #256
    str x10, [sp, #8]
    add x10, x29, #200
    str x10, [sp, #16]
    add x10, x29, #328
    str x10, [sp, #24]
    add x10, x29, #272
    str x10, [sp, #32]
    add x10, x29, #320
    str x10, [sp, #40]
    add x10, x29, #376
    str x10, [sp, #48]
    bl md2asm_fft992_rpassf
// Original source line 237: ELSE
    b .Lmd2asm_fft992_if_end_17
.Lmd2asm_fft992_if_false_16:
// Original source line 239: CALL RPASSF(WORK(1),WORK(LA*LOT+1),A(IA),A(IA+IFAC*LA*INCA),TRIGS,LOT,INCA,1,JUMPA,LOT,N,IFAC,LA,IERR,LIPL)
    mov x10, #1
    sub x10, x10, #1
    ldr x16, [x29, #384]
    add x10, x16, x10, lsl #3
    mov x0, x10
    ldrsw x10, [x29, #272]
    ldrsw x9, [x29, #256]
    mul x10, x10, x9
    mov x9, #1
    add x10, x10, x9
    sub x10, x10, #1
    ldr x16, [x29, #384]
    add x10, x16, x10, lsl #3
    mov x1, x10
    ldrsw x10, [x29, #304]
    sub x10, x10, #1
    ldr x16, [x29, #128]
    add x10, x16, x10, lsl #3
    mov x2, x10
    ldrsw x10, [x29, #304]
    ldrsw x9, [x29, #328]
    ldrsw x11, [x29, #272]
    mul x9, x9, x11
    ldrsw x11, [x29, #352]
    mul x9, x9, x11
    add x10, x10, x9
    sub x10, x10, #1
    ldr x16, [x29, #128]
    add x10, x16, x10, lsl #3
    mov x3, x10
    ldr x10, [x29, #136]
    mov x4, x10
    add x10, x29, #256
    mov x5, x10
    add x10, x29, #352
    mov x6, x10
    mov x10, #1
    str x10, [x29, #440]
    add x10, x29, #440
    mov x7, x10
    add x10, x29, #248
    str x10, [sp, #0]
    add x10, x29, #256
    str x10, [sp, #8]
    add x10, x29, #200
    str x10, [sp, #16]
    add x10, x29, #328
    str x10, [sp, #24]
    add x10, x29, #272
    str x10, [sp, #32]
    add x10, x29, #320
    str x10, [sp, #40]
    add x10, x29, #376
    str x10, [sp, #48]
    bl md2asm_fft992_rpassf
// Original source line 241: ENDIF
.Lmd2asm_fft992_if_end_17:
// Original source line 242: IF (IERR.NE.0) THEN
    ldrsw x10, [x29, #320]
    mov x9, #0
    cmp x10, x9
    cset x10, ne
    cbz x10, .Lmd2asm_fft992_if_false_18
// Original source line 246: RETURN
    b .Lmd2asm_fft992_return_1
// Original source line 247: ENDIF
.Lmd2asm_fft992_if_false_18:
.Lmd2asm_fft992_if_end_19:
// Original source line 248: LA=IFAC*LA
    ldrsw x10, [x29, #328]
    ldrsw x9, [x29, #272]
    mul x10, x10, x9
    str w10, [x29, #272]
// Original source line 249: IGO=-IGO
    ldrsw x10, [x29, #336]
    neg x10, x10
    str w10, [x29, #336]
// Original source line 250: IA=1
    mov x10, #1
    str w10, [x29, #304]
// Original source line 251: ENDDO
    ldrsw x10, [x29, #264]
    ldr x9, [x29, #432]
    add x10, x10, x9
    str x10, [x29, #264]
    b .Lmd2asm_fft992_do_10
.Lmd2asm_fft992_do_done_11:
// Original source line 255: IF (NFAX.EQ.1) THEN
    ldrsw x9, [x29, #280]
    mov x10, #1
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_if_false_20
// Original source line 256: IBASE=1
    mov x9, #1
    str w9, [x29, #312]
// Original source line 257: JBASE=1
    mov x9, #1
    str w9, [x29, #216]
// Original source line 258: DO JJ=1,N
    mov x9, #1
    str w9, [x29, #240]
    ldrsw x9, [x29, #200]
    str x9, [x29, #448]
    mov x9, #1
    str x9, [x29, #456]
.Lmd2asm_fft992_do_22:
    ldrsw x9, [x29, #240]
    ldr x10, [x29, #448]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_do_done_23
// Original source line 259: I=IBASE
    ldrsw x10, [x29, #312]
    str w10, [x29, #296]
// Original source line 260: J=JBASE
    ldrsw x10, [x29, #216]
    str w10, [x29, #232]
// Original source line 261: DO II=1,LOT
    mov x10, #1
    str w10, [x29, #344]
    ldrsw x10, [x29, #256]
    str x10, [x29, #464]
    mov x10, #1
    str x10, [x29, #472]
.Lmd2asm_fft992_do_24:
    ldrsw x10, [x29, #344]
    ldr x9, [x29, #464]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_25
// Original source line 262: A(J)=WORK(I)
    ldrsw x9, [x29, #296]
    ldr x16, [x29, #384]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #232]
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 263: I=I+1
    ldrsw x9, [x29, #296]
    mov x10, #1
    add x9, x9, x10
    str w9, [x29, #296]
// Original source line 264: J=J+JUMP
    ldrsw x9, [x29, #232]
    ldrsw x10, [x29, #224]
    add x9, x9, x10
    str w9, [x29, #232]
// Original source line 265: ENDDO
    ldrsw x9, [x29, #344]
    ldr x10, [x29, #472]
    add x9, x9, x10
    str x9, [x29, #344]
    b .Lmd2asm_fft992_do_24
.Lmd2asm_fft992_do_done_25:
// Original source line 266: IBASE=IBASE+LOT
    ldrsw x10, [x29, #312]
    ldrsw x9, [x29, #256]
    add x10, x10, x9
    str w10, [x29, #312]
// Original source line 267: JBASE=JBASE+INC
    ldrsw x10, [x29, #216]
    ldrsw x9, [x29, #208]
    add x10, x10, x9
    str w10, [x29, #216]
// Original source line 268: ENDDO
    ldrsw x10, [x29, #240]
    ldr x9, [x29, #456]
    add x10, x10, x9
    str x10, [x29, #240]
    b .Lmd2asm_fft992_do_22
.Lmd2asm_fft992_do_done_23:
// Original source line 269: ENDIF
.Lmd2asm_fft992_if_false_20:
.Lmd2asm_fft992_if_end_21:
// Original source line 273: IX=N*INC+1
    ldrsw x9, [x29, #200]
    ldrsw x10, [x29, #208]
    mul x9, x9, x10
    mov x10, #1
    add x9, x9, x10
    str w9, [x29, #360]
// Original source line 276: DO J=1,LOT
    mov x9, #1
    str w9, [x29, #232]
    ldrsw x9, [x29, #256]
    str x9, [x29, #480]
    mov x9, #1
    str x9, [x29, #488]
.Lmd2asm_fft992_do_26:
    ldrsw x9, [x29, #232]
    ldr x10, [x29, #480]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_do_done_27
// Original source line 277: A(IX)=0.0_JPRB
    adrp x16, .Lfft_constant_1
    ldr d0, [x16, :lo12:.Lfft_constant_1]
    ldrsw x10, [x29, #360]
    ldr x16, [x29, #128]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 278: A(IX+INC)=0.0_JPRB
    adrp x16, .Lfft_constant_1
    ldr d0, [x16, :lo12:.Lfft_constant_1]
    ldrsw x10, [x29, #360]
    ldrsw x9, [x29, #208]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 279: IX=IX+JUMP
    ldrsw x10, [x29, #360]
    ldrsw x9, [x29, #224]
    add x10, x10, x9
    str w10, [x29, #360]
// Original source line 280: ENDDO
    ldrsw x10, [x29, #232]
    ldr x9, [x29, #488]
    add x10, x10, x9
    str x10, [x29, #232]
    b .Lmd2asm_fft992_do_26
.Lmd2asm_fft992_do_done_27:
// Original source line 282: ELSEIF (ISIGN.EQ.-1) THEN
    b .Lmd2asm_fft992_if_end_3
.Lmd2asm_fft992_if_false_2:
    ldrsw x9, [x29, #288]
    mov x10, #1
    neg x10, x10
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_elseif_false_28
// Original source line 286: IA=1
    mov x9, #1
    str w9, [x29, #304]
// Original source line 287: LA=N
    ldrsw x9, [x29, #200]
    str w9, [x29, #272]
// Original source line 288: IGO=+1
    mov x9, #1
    str w9, [x29, #336]
// Original source line 290: DO K=1,NFAX
    mov x9, #1
    str w9, [x29, #264]
    ldrsw x9, [x29, #280]
    str x9, [x29, #496]
    mov x9, #1
    str x9, [x29, #504]
.Lmd2asm_fft992_do_29:
    ldrsw x9, [x29, #264]
    ldr x10, [x29, #496]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_do_done_30
// Original source line 291: IFAC=IFAX(NFAX+2-K)
    ldrsw x10, [x29, #280]
    mov x9, #2
    add x10, x10, x9
    ldrsw x9, [x29, #264]
    sub x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    ldrsw x9, [x16, x10, lsl #2]
    str w9, [x29, #328]
// Original source line 292: LA=LA/IFAC
    ldrsw x9, [x29, #272]
    ldrsw x10, [x29, #328]
    sdiv x9, x9, x10
    str w9, [x29, #272]
// Original source line 293: IERR=-1
    mov x9, #1
    neg x9, x9
    str w9, [x29, #320]
// Original source line 294: IF (K.EQ.1.AND.NFAX.GT.2.AND.MOD(NFAX,2).EQ.1) THEN
    ldrsw x9, [x29, #264]
    mov x10, #1
    cmp x9, x10
    cset x9, eq
    ldrsw x10, [x29, #280]
    mov x11, #2
    cmp x10, x11
    cset x10, gt
    and x9, x9, x10
    ldrsw x10, [x29, #280]
    mov x11, #2
    sdiv x12, x10, x11
    msub x10, x12, x11, x10
    mov x11, #1
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    cbz x9, .Lmd2asm_fft992_if_false_31
// Original source line 295: LIPL=.TRUE.
    mov x9, #1
    str w9, [x29, #376]
// Original source line 296: ELSE
    b .Lmd2asm_fft992_if_end_32
.Lmd2asm_fft992_if_false_31:
// Original source line 297: LIPL=.FALSE.
    mov x9, #0
    str w9, [x29, #376]
// Original source line 298: ENDIF
.Lmd2asm_fft992_if_end_32:
// Original source line 299: IF (INC.EQ.1.AND.JUMP.LT.(2*N).AND.K.GT.(1+MOD(NFAX,2)).AND.K.LT.NFAX) THEN
    ldrsw x9, [x29, #208]
    mov x10, #1
    cmp x9, x10
    cset x9, eq
    ldrsw x10, [x29, #224]
    mov x11, #2
    ldrsw x12, [x29, #200]
    mul x11, x11, x12
    cmp x10, x11
    cset x10, lt
    and x9, x9, x10
    ldrsw x10, [x29, #264]
    mov x11, #1
    ldrsw x12, [x29, #280]
    mov x13, #2
    sdiv x14, x12, x13
    msub x12, x14, x13, x12
    add x11, x11, x12
    cmp x10, x11
    cset x10, gt
    and x9, x9, x10
    ldrsw x10, [x29, #264]
    ldrsw x11, [x29, #280]
    cmp x10, x11
    cset x10, lt
    and x9, x9, x10
    cbz x9, .Lmd2asm_fft992_if_false_33
// Original source line 301: INCA=LOT
    ldrsw x9, [x29, #256]
    str w9, [x29, #352]
// Original source line 302: JUMPA=1
    mov x9, #1
    str w9, [x29, #248]
// Original source line 303: ELSE
    b .Lmd2asm_fft992_if_end_34
.Lmd2asm_fft992_if_false_33:
// Original source line 304: INCA=INC
    ldrsw x9, [x29, #208]
    str w9, [x29, #352]
// Original source line 305: JUMPA=JUMP
    ldrsw x9, [x29, #224]
    str w9, [x29, #248]
// Original source line 306: ENDIF
.Lmd2asm_fft992_if_end_34:
// Original source line 307: IF (IGO.EQ.+1) THEN
    ldrsw x9, [x29, #336]
    mov x10, #1
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_if_false_35
// Original source line 309: CALL QPASSF(A(IA),A(IA+IFAC*LA*INCA),WORK(1),WORK(LA*LOT+1),TRIGS,INCA,LOT,JUMPA,1,LOT,N,IFAC,LA,IERR,LIPL)
    ldrsw x9, [x29, #304]
    sub x9, x9, #1
    ldr x16, [x29, #128]
    add x9, x16, x9, lsl #3
    mov x0, x9
    ldrsw x9, [x29, #304]
    ldrsw x10, [x29, #328]
    ldrsw x11, [x29, #272]
    mul x10, x10, x11
    ldrsw x11, [x29, #352]
    mul x10, x10, x11
    add x9, x9, x10
    sub x9, x9, #1
    ldr x16, [x29, #128]
    add x9, x16, x9, lsl #3
    mov x1, x9
    mov x9, #1
    sub x9, x9, #1
    ldr x16, [x29, #384]
    add x9, x16, x9, lsl #3
    mov x2, x9
    ldrsw x9, [x29, #272]
    ldrsw x10, [x29, #256]
    mul x9, x9, x10
    mov x10, #1
    add x9, x9, x10
    sub x9, x9, #1
    ldr x16, [x29, #384]
    add x9, x16, x9, lsl #3
    mov x3, x9
    ldr x9, [x29, #136]
    mov x4, x9
    add x9, x29, #352
    mov x5, x9
    add x9, x29, #256
    mov x6, x9
    add x9, x29, #248
    mov x7, x9
    mov x9, #1
    str x9, [x29, #440]
    add x9, x29, #440
    str x9, [sp, #0]
    add x9, x29, #256
    str x9, [sp, #8]
    add x9, x29, #200
    str x9, [sp, #16]
    add x9, x29, #328
    str x9, [sp, #24]
    add x9, x29, #272
    str x9, [sp, #32]
    add x9, x29, #320
    str x9, [sp, #40]
    add x9, x29, #376
    str x9, [sp, #48]
    bl md2asm_fft992_qpassf
// Original source line 311: ELSE
    b .Lmd2asm_fft992_if_end_36
.Lmd2asm_fft992_if_false_35:
// Original source line 313: CALL QPASSF(WORK(1),WORK(IFAC*LA*LOT+1),A(IA),A(IA+LA*INCA),TRIGS,LOT,INCA,1,JUMPA,LOT,N,IFAC,LA,IERR,LIPL)
    mov x9, #1
    sub x9, x9, #1
    ldr x16, [x29, #384]
    add x9, x16, x9, lsl #3
    mov x0, x9
    ldrsw x9, [x29, #328]
    ldrsw x10, [x29, #272]
    mul x9, x9, x10
    ldrsw x10, [x29, #256]
    mul x9, x9, x10
    mov x10, #1
    add x9, x9, x10
    sub x9, x9, #1
    ldr x16, [x29, #384]
    add x9, x16, x9, lsl #3
    mov x1, x9
    ldrsw x9, [x29, #304]
    sub x9, x9, #1
    ldr x16, [x29, #128]
    add x9, x16, x9, lsl #3
    mov x2, x9
    ldrsw x9, [x29, #304]
    ldrsw x10, [x29, #272]
    ldrsw x11, [x29, #352]
    mul x10, x10, x11
    add x9, x9, x10
    sub x9, x9, #1
    ldr x16, [x29, #128]
    add x9, x16, x9, lsl #3
    mov x3, x9
    ldr x9, [x29, #136]
    mov x4, x9
    add x9, x29, #256
    mov x5, x9
    add x9, x29, #352
    mov x6, x9
    mov x9, #1
    str x9, [x29, #440]
    add x9, x29, #440
    mov x7, x9
    add x9, x29, #248
    str x9, [sp, #0]
    add x9, x29, #256
    str x9, [sp, #8]
    add x9, x29, #200
    str x9, [sp, #16]
    add x9, x29, #328
    str x9, [sp, #24]
    add x9, x29, #272
    str x9, [sp, #32]
    add x9, x29, #320
    str x9, [sp, #40]
    add x9, x29, #376
    str x9, [sp, #48]
    bl md2asm_fft992_qpassf
// Original source line 315: ENDIF
.Lmd2asm_fft992_if_end_36:
// Original source line 316: IF (IERR.NE.0) THEN
    ldrsw x9, [x29, #320]
    mov x10, #0
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_if_false_37
// Original source line 320: RETURN
    b .Lmd2asm_fft992_return_1
// Original source line 321: ENDIF
.Lmd2asm_fft992_if_false_37:
.Lmd2asm_fft992_if_end_38:
// Original source line 322: IF (LIPL) THEN
    ldrsw x9, [x29, #376]
    cbz x9, .Lmd2asm_fft992_if_false_39
// Original source line 323: IA=1
    mov x9, #1
    str w9, [x29, #304]
// Original source line 324: ELSE
    b .Lmd2asm_fft992_if_end_40
.Lmd2asm_fft992_if_false_39:
// Original source line 325: IGO=-IGO
    ldrsw x9, [x29, #336]
    neg x9, x9
    str w9, [x29, #336]
// Original source line 326: IA=INC+1
    ldrsw x9, [x29, #208]
    mov x10, #1
    add x9, x9, x10
    str w9, [x29, #304]
// Original source line 327: ENDIF
.Lmd2asm_fft992_if_end_40:
// Original source line 328: ENDDO
    ldrsw x9, [x29, #264]
    ldr x10, [x29, #504]
    add x9, x9, x10
    str x9, [x29, #264]
    b .Lmd2asm_fft992_do_29
.Lmd2asm_fft992_do_done_30:
// Original source line 332: IF (NFAX.EQ.1) THEN
    ldrsw x10, [x29, #280]
    mov x9, #1
    cmp x10, x9
    cset x10, eq
    cbz x10, .Lmd2asm_fft992_if_false_41
// Original source line 333: IBASE=1
    mov x10, #1
    str w10, [x29, #312]
// Original source line 334: JBASE=INC+1
    ldrsw x10, [x29, #208]
    mov x9, #1
    add x10, x10, x9
    str w10, [x29, #216]
// Original source line 335: DO JJ=1,N
    mov x10, #1
    str w10, [x29, #240]
    ldrsw x10, [x29, #200]
    str x10, [x29, #512]
    mov x10, #1
    str x10, [x29, #520]
.Lmd2asm_fft992_do_43:
    ldrsw x10, [x29, #240]
    ldr x9, [x29, #512]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_44
// Original source line 336: I=IBASE
    ldrsw x9, [x29, #312]
    str w9, [x29, #296]
// Original source line 337: J=JBASE
    ldrsw x9, [x29, #216]
    str w9, [x29, #232]
// Original source line 338: DO II=1,LOT
    mov x9, #1
    str w9, [x29, #344]
    ldrsw x9, [x29, #256]
    str x9, [x29, #528]
    mov x9, #1
    str x9, [x29, #536]
.Lmd2asm_fft992_do_45:
    ldrsw x9, [x29, #344]
    ldr x10, [x29, #528]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_do_done_46
// Original source line 339: A(J)=WORK(I)
    ldrsw x10, [x29, #296]
    ldr x16, [x29, #384]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #232]
    ldr x16, [x29, #128]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 340: I=I+1
    ldrsw x10, [x29, #296]
    mov x9, #1
    add x10, x10, x9
    str w10, [x29, #296]
// Original source line 341: J=J+JUMP
    ldrsw x10, [x29, #232]
    ldrsw x9, [x29, #224]
    add x10, x10, x9
    str w10, [x29, #232]
// Original source line 342: ENDDO
    ldrsw x10, [x29, #344]
    ldr x9, [x29, #536]
    add x10, x10, x9
    str x10, [x29, #344]
    b .Lmd2asm_fft992_do_45
.Lmd2asm_fft992_do_done_46:
// Original source line 343: IBASE=IBASE+LOT
    ldrsw x9, [x29, #312]
    ldrsw x10, [x29, #256]
    add x9, x9, x10
    str w9, [x29, #312]
// Original source line 344: JBASE=JBASE+INC
    ldrsw x9, [x29, #216]
    ldrsw x10, [x29, #208]
    add x9, x9, x10
    str w9, [x29, #216]
// Original source line 345: ENDDO
    ldrsw x9, [x29, #240]
    ldr x10, [x29, #520]
    add x9, x9, x10
    str x9, [x29, #240]
    b .Lmd2asm_fft992_do_43
.Lmd2asm_fft992_do_done_44:
// Original source line 346: ENDIF
.Lmd2asm_fft992_if_false_41:
.Lmd2asm_fft992_if_end_42:
// Original source line 350: IX=1
    mov x10, #1
    str w10, [x29, #360]
// Original source line 353: DO J=1,LOT
    mov x10, #1
    str w10, [x29, #232]
    ldrsw x10, [x29, #256]
    str x10, [x29, #544]
    mov x10, #1
    str x10, [x29, #552]
.Lmd2asm_fft992_do_47:
    ldrsw x10, [x29, #232]
    ldr x9, [x29, #544]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_48
// Original source line 354: A(IX)=A(IX+INC)
    ldrsw x9, [x29, #360]
    ldrsw x10, [x29, #208]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #360]
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 355: A(IX+INC)=0.0_JPRB
    adrp x16, .Lfft_constant_1
    ldr d0, [x16, :lo12:.Lfft_constant_1]
    ldrsw x9, [x29, #360]
    ldrsw x10, [x29, #208]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 356: IX=IX+JUMP
    ldrsw x9, [x29, #360]
    ldrsw x10, [x29, #224]
    add x9, x9, x10
    str w9, [x29, #360]
// Original source line 357: ENDDO
    ldrsw x9, [x29, #232]
    ldr x10, [x29, #552]
    add x9, x9, x10
    str x9, [x29, #232]
    b .Lmd2asm_fft992_do_47
.Lmd2asm_fft992_do_done_48:
// Original source line 358: IF (MOD(N,2).EQ.0) THEN
    ldrsw x10, [x29, #200]
    mov x9, #2
    sdiv x11, x10, x9
    msub x10, x11, x9, x10
    mov x9, #0
    cmp x10, x9
    cset x10, eq
    cbz x10, .Lmd2asm_fft992_if_false_49
// Original source line 359: IX=(N+1)*INC+1
    ldrsw x10, [x29, #200]
    mov x9, #1
    add x10, x10, x9
    ldrsw x9, [x29, #208]
    mul x10, x10, x9
    mov x9, #1
    add x10, x10, x9
    str w10, [x29, #360]
// Original source line 360: DO J=1,LOT
    mov x10, #1
    str w10, [x29, #232]
    ldrsw x10, [x29, #256]
    str x10, [x29, #560]
    mov x10, #1
    str x10, [x29, #568]
.Lmd2asm_fft992_do_51:
    ldrsw x10, [x29, #232]
    ldr x9, [x29, #560]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_do_done_52
// Original source line 361: A(IX)=0.0_JPRB
    adrp x16, .Lfft_constant_1
    ldr d0, [x16, :lo12:.Lfft_constant_1]
    ldrsw x9, [x29, #360]
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 362: IX=IX+JUMP
    ldrsw x9, [x29, #360]
    ldrsw x10, [x29, #224]
    add x9, x9, x10
    str w9, [x29, #360]
// Original source line 363: ENDDO
    ldrsw x9, [x29, #232]
    ldr x10, [x29, #568]
    add x9, x9, x10
    str x9, [x29, #232]
    b .Lmd2asm_fft992_do_51
.Lmd2asm_fft992_do_done_52:
// Original source line 364: ENDIF
.Lmd2asm_fft992_if_false_49:
.Lmd2asm_fft992_if_end_50:
// Original source line 366: ENDIF
.Lmd2asm_fft992_elseif_false_28:
.Lmd2asm_fft992_if_end_3:
.Lmd2asm_fft992_return_1:
    mov sp, x29
    ldr x18, [sp, #16]
    ldp x29, x30, [sp]
    add sp, sp, #2048
    ret
.size md2asm_fft992, .-md2asm_fft992
.p2align 4
.global md2asm_fft992_rpassf
.type md2asm_fft992_rpassf, %function
md2asm_fft992_rpassf:
    sub sp, sp, #2048
    stp x29, x30, [sp]
    str x18, [sp, #16]
    mov x29, sp
    str x0, [x29, #128]
    str x1, [x29, #136]
    str x2, [x29, #144]
    str x3, [x29, #152]
    str x4, [x29, #160]
    str x5, [x29, #168]
    str x6, [x29, #176]
    str x7, [x29, #184]
    ldr x9, [x29, #2048]
    str x9, [x29, #192]
    ldr x9, [x29, #2056]
    str x9, [x29, #200]
    ldr x9, [x29, #2064]
    str x9, [x29, #208]
    ldr x9, [x29, #2072]
    str x9, [x29, #216]
    ldr x9, [x29, #2080]
    str x9, [x29, #224]
    ldr x9, [x29, #2088]
    str x9, [x29, #232]
    ldr x9, [x29, #2096]
    str x9, [x29, #240]
    ldr x9, [x29, #168]
    ldrsw x9, [x9]
    str x9, [x29, #544]
    ldr x9, [x29, #176]
    ldrsw x9, [x9]
    str x9, [x29, #552]
    ldr x9, [x29, #184]
    ldrsw x9, [x9]
    str x9, [x29, #560]
    ldr x9, [x29, #192]
    ldrsw x9, [x9]
    str x9, [x29, #568]
    ldr x9, [x29, #200]
    ldrsw x9, [x9]
    str x9, [x29, #576]
    ldr x9, [x29, #208]
    ldrsw x9, [x9]
    str x9, [x29, #248]
    ldr x9, [x29, #216]
    ldrsw x9, [x9]
    str x9, [x29, #584]
    ldr x9, [x29, #224]
    ldrsw x9, [x9]
    str x9, [x29, #592]
    ldr x9, [x29, #232]
    ldrsw x9, [x9]
    str x9, [x29, #536]
    ldr x9, [x29, #240]
    ldrsw x9, [x9]
    str x9, [x29, #880]
    adrp x16, md2asm_fft992_rpassf_calls
    add x16, x16, :lo12:md2asm_fft992_rpassf_calls
    ldr x9, [x16]
    add x9, x9, #1
    str x9, [x16]
    adrp x16, .Lfft_constant_2
    ldr d0, [x16, :lo12:.Lfft_constant_2]
    str d0, [x29, #400]
    adrp x16, .Lfft_constant_3
    ldr d0, [x16, :lo12:.Lfft_constant_3]
    str d0, [x29, #424]
    adrp x16, .Lfft_constant_4
    ldr d0, [x16, :lo12:.Lfft_constant_4]
    str d0, [x29, #464]
    adrp x16, .Lfft_constant_5
    ldr d0, [x16, :lo12:.Lfft_constant_5]
    str d0, [x29, #416]
// Original source line 443: M=N/IFAC
    ldrsw x9, [x29, #248]
    ldrsw x10, [x29, #584]
    sdiv x9, x9, x10
    str w9, [x29, #872]
// Original source line 444: IINK=LA*INC1
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #544]
    mul x9, x9, x10
    str w9, [x29, #608]
// Original source line 445: JINK=LA*INC2
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #552]
    mul x9, x9, x10
    str w9, [x29, #792]
// Original source line 446: JUMP=(IFAC-1)*JINK
    ldrsw x9, [x29, #584]
    mov x10, #1
    sub x9, x9, x10
    ldrsw x10, [x29, #792]
    mul x9, x9, x10
    str w9, [x29, #800]
// Original source line 447: KSTOP=(N-IFAC)/(2*IFAC)
    ldrsw x9, [x29, #248]
    ldrsw x10, [x29, #584]
    sub x9, x9, x10
    mov x10, #2
    ldrsw x11, [x29, #584]
    mul x10, x10, x11
    sdiv x9, x9, x10
    str w9, [x29, #856]
// Original source line 449: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 450: JBASE=0
    mov x9, #0
    str w9, [x29, #736]
// Original source line 451: IBAD=0
    mov x9, #0
    str w9, [x29, #664]
// Original source line 455: IF (INC1.EQ.LOT.AND.INC2.EQ.LOT.AND.INC3.EQ.1.AND.INC4.EQ.1) THEN
    ldrsw x9, [x29, #544]
    ldrsw x10, [x29, #576]
    cmp x9, x10
    cset x9, eq
    ldrsw x10, [x29, #552]
    ldrsw x11, [x29, #576]
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    ldrsw x10, [x29, #560]
    mov x11, #1
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    ldrsw x10, [x29, #568]
    mov x11, #1
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_54
// Original source line 456: ILA=1
    mov x9, #1
    str w9, [x29, #632]
// Original source line 457: ILOT=LA*LOT
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #576]
    mul x9, x9, x10
    str w9, [x29, #624]
// Original source line 458: INC21=LA*LOT
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #576]
    mul x9, x9, x10
    str w9, [x29, #600]
// Original source line 459: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_55
.Lmd2asm_fft992_rpassf_if_false_54:
// Original source line 460: ILA=LA
    ldrsw x9, [x29, #592]
    str w9, [x29, #632]
// Original source line 461: ILOT=LOT
    ldrsw x9, [x29, #576]
    str w9, [x29, #624]
// Original source line 462: INC21=INC2
    ldrsw x9, [x29, #552]
    str w9, [x29, #600]
// Original source line 463: ENDIF
.Lmd2asm_fft992_rpassf_if_end_55:
// Original source line 465: IF (IFAC.EQ.2) THEN
    ldrsw x9, [x29, #584]
    mov x10, #2
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_56
// Original source line 469: 200 CONTINUE
// Original source line 470: IA=1
    mov x9, #1
    str w9, [x29, #648]
// Original source line 471: IB=IA+(2*M-LA)*INC1
    ldrsw x9, [x29, #648]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #592]
    sub x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 472: JA=1
    mov x9, #1
    str w9, [x29, #720]
// Original source line 473: JB=JA+JINK
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #728]
// Original source line 475: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_58
// Original source line 477: DO 220 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #888]
    mov x9, #1
    str x9, [x29, #896]
.Lmd2asm_fft992_rpassf_do_60:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #888]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_61
// Original source line 478: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 479: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 482: DO 210 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #904]
    mov x10, #1
    str x10, [x29, #912]
.Lmd2asm_fft992_rpassf_do_62:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #904]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_63
// Original source line 483: C(JA+J)=A(IA+I)+A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 484: C(JB+J)=A(IA+I)-A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 485: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 486: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 487: 210 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #912]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_62
.Lmd2asm_fft992_rpassf_do_done_63:
// Original source line 488: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 489: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 490: 220 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #896]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_60
.Lmd2asm_fft992_rpassf_do_done_61:
// Original source line 491: IA=IA+IINK
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #648]
// Original source line 492: IINK=2*IINK
    mov x9, #2
    ldrsw x10, [x29, #608]
    mul x9, x9, x10
    str w9, [x29, #608]
// Original source line 493: IB=IB-IINK
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #656]
// Original source line 494: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 495: JBASE=JBASE+JUMP
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #800]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 496: JUMP=2*JUMP+JINK
    mov x9, #2
    ldrsw x10, [x29, #800]
    mul x9, x9, x10
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 498: IF (IA.LT.IB) THEN
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #656]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_64
// Original source line 499: DO 250 K=LA,KSTOP,LA
    ldrsw x9, [x29, #592]
    str w9, [x29, #808]
    ldrsw x9, [x29, #856]
    str x9, [x29, #920]
    ldrsw x9, [x29, #592]
    str x9, [x29, #928]
.Lmd2asm_fft992_rpassf_do_66:
    ldrsw x9, [x29, #808]
    ldr x10, [x29, #920]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_67
// Original source line 500: KB=K+K
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #808]
    add x10, x10, x9
    str w10, [x29, #816]
// Original source line 501: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #816]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #320]
// Original source line 502: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #816]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #360]
// Original source line 503: IBASE=0
    mov x10, #0
    str w10, [x29, #672]
// Original source line 504: DO 240 L=1,ILA
    mov x10, #1
    str w10, [x29, #864]
    ldrsw x10, [x29, #632]
    str x10, [x29, #936]
    mov x10, #1
    str x10, [x29, #944]
.Lmd2asm_fft992_rpassf_do_68:
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #936]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_69
// Original source line 505: I=IBASE
    ldrsw x9, [x29, #672]
    str w9, [x29, #640]
// Original source line 506: J=JBASE
    ldrsw x9, [x29, #736]
    str w9, [x29, #712]
// Original source line 509: DO 230 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #616]
    ldrsw x9, [x29, #624]
    str x9, [x29, #952]
    mov x9, #1
    str x9, [x29, #960]
.Lmd2asm_fft992_rpassf_do_70:
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #952]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_71
// Original source line 510: C(JA+J)=A(IA+I)+A(IB+I)
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 511: D(JA+J)=B(IA+I)-B(IB+I)
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 512: C(JB+J)=C1*(A(IA+I)-A(IB+I))-S1*(B(IA+I)+B(IB+I))
    ldr d0, [x29, #320]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #360]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 513: D(JB+J)=S1*(A(IA+I)-A(IB+I))+C1*(B(IA+I)+B(IB+I))
    ldr d0, [x29, #360]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #320]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 514: I=I+INC3
    ldrsw x10, [x29, #640]
    ldrsw x9, [x29, #560]
    add x10, x10, x9
    str w10, [x29, #640]
// Original source line 515: J=J+INC4
    ldrsw x10, [x29, #712]
    ldrsw x9, [x29, #568]
    add x10, x10, x9
    str w10, [x29, #712]
// Original source line 516: 230 CONTINUE
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #960]
    add x10, x10, x9
    str x10, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_70
.Lmd2asm_fft992_rpassf_do_done_71:
// Original source line 517: IBASE=IBASE+INC1
    ldrsw x9, [x29, #672]
    ldrsw x10, [x29, #544]
    add x9, x9, x10
    str w9, [x29, #672]
// Original source line 518: JBASE=JBASE+INC21
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #600]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 519: 240 CONTINUE
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #944]
    add x9, x9, x10
    str x9, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_68
.Lmd2asm_fft992_rpassf_do_done_69:
// Original source line 520: IA=IA+IINK
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #648]
// Original source line 521: IB=IB-IINK
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #656]
// Original source line 522: JBASE=JBASE+JUMP
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #800]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 523: 250 CONTINUE
    ldrsw x10, [x29, #808]
    ldr x9, [x29, #928]
    add x10, x10, x9
    str x10, [x29, #808]
    b .Lmd2asm_fft992_rpassf_do_66
.Lmd2asm_fft992_rpassf_do_done_67:
// Original source line 524: ENDIF
.Lmd2asm_fft992_rpassf_if_false_64:
.Lmd2asm_fft992_rpassf_if_end_65:
// Original source line 526: IF (IA.EQ.IB) THEN
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #656]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_72
// Original source line 527: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 528: DO 280 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #968]
    mov x9, #1
    str x9, [x29, #976]
.Lmd2asm_fft992_rpassf_do_74:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #968]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_75
// Original source line 529: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 530: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 533: DO 270 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #984]
    mov x10, #1
    str x10, [x29, #992]
.Lmd2asm_fft992_rpassf_do_76:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #984]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_77
// Original source line 534: C(JA+J)=A(IA+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 535: C(JB+J)=-B(IA+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 536: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 537: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 538: 270 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #992]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_76
.Lmd2asm_fft992_rpassf_do_done_77:
// Original source line 539: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 540: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 541: 280 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #976]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_74
.Lmd2asm_fft992_rpassf_do_done_75:
// Original source line 542: ENDIF
.Lmd2asm_fft992_rpassf_if_false_72:
.Lmd2asm_fft992_rpassf_if_end_73:
// Original source line 544: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_59
.Lmd2asm_fft992_rpassf_if_false_58:
// Original source line 545: IF (LIPL) THEN
    ldrsw x9, [x29, #880]
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_78
// Original source line 546: DO 294 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1000]
    mov x9, #1
    str x9, [x29, #1008]
.Lmd2asm_fft992_rpassf_do_80:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1000]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_81
// Original source line 547: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 549: DO 292 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1016]
    mov x10, #1
    str x10, [x29, #1024]
.Lmd2asm_fft992_rpassf_do_82:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1016]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_83
// Original source line 550: T1=2.0*(A(IA+I)-A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #480]
// Original source line 551: A(IA+I)=2.0_JPRB*(A(IA+I)+A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 552: A(IB+I)=T1
    ldr d0, [x29, #480]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 553: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 554: 292 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1024]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_82
.Lmd2asm_fft992_rpassf_do_done_83:
// Original source line 555: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 556: 294 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1008]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_80
.Lmd2asm_fft992_rpassf_do_done_81:
// Original source line 557: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_79
.Lmd2asm_fft992_rpassf_if_false_78:
// Original source line 558: DO 298 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1032]
    mov x9, #1
    str x9, [x29, #1040]
.Lmd2asm_fft992_rpassf_do_84:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1032]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_85
// Original source line 559: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 560: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 563: DO 296 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1048]
    mov x10, #1
    str x10, [x29, #1056]
.Lmd2asm_fft992_rpassf_do_86:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1048]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_87
// Original source line 564: C(JA+J)=2.0_JPRB*(A(IA+I)+A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 565: C(JB+J)=2.0_JPRB*(A(IA+I)-A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 566: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 567: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 568: 296 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1056]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_86
.Lmd2asm_fft992_rpassf_do_done_87:
// Original source line 569: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 570: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 571: 298 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1040]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_84
.Lmd2asm_fft992_rpassf_do_done_85:
// Original source line 572: ENDIF
.Lmd2asm_fft992_rpassf_if_end_79:
// Original source line 573: ENDIF
.Lmd2asm_fft992_rpassf_if_end_59:
// Original source line 575: ELSEIF (IFAC.EQ.3) THEN
    b .Lmd2asm_fft992_rpassf_if_end_57
.Lmd2asm_fft992_rpassf_if_false_56:
    ldrsw x9, [x29, #584]
    mov x10, #3
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_elseif_false_88
// Original source line 579: 300 CONTINUE
// Original source line 580: IA=1
    mov x9, #1
    str w9, [x29, #648]
// Original source line 581: IB=IA+(2*M-LA)*INC1
    ldrsw x9, [x29, #648]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #592]
    sub x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 582: IC=IB
    ldrsw x9, [x29, #656]
    str w9, [x29, #680]
// Original source line 583: JA=1
    mov x9, #1
    str w9, [x29, #720]
// Original source line 584: JB=JA+JINK
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #728]
// Original source line 585: JC=JB+JINK
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 587: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_89
// Original source line 589: DO 320 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1064]
    mov x9, #1
    str x9, [x29, #1072]
.Lmd2asm_fft992_rpassf_do_91:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1064]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_92
// Original source line 590: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 591: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 594: DO 310 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1080]
    mov x10, #1
    str x10, [x29, #1088]
.Lmd2asm_fft992_rpassf_do_93:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1080]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_94
// Original source line 595: C(JA+J)=A(IA+I)+A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 596: C(JB+J)=(A(IA+I)-0.5_JPRB*A(IB+I))-(SIN60*(B(IB+I)))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 597: C(JC+J)=(A(IA+I)-0.5_JPRB*A(IB+I))+(SIN60*(B(IB+I)))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 598: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 599: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 600: 310 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1088]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_93
.Lmd2asm_fft992_rpassf_do_done_94:
// Original source line 601: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 602: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 603: 320 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1072]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_91
.Lmd2asm_fft992_rpassf_do_done_92:
// Original source line 604: IA=IA+IINK
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #648]
// Original source line 605: IINK=2*IINK
    mov x9, #2
    ldrsw x10, [x29, #608]
    mul x9, x9, x10
    str w9, [x29, #608]
// Original source line 606: IB=IB+IINK
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 607: IC=IC-IINK
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #680]
// Original source line 608: JBASE=JBASE+JUMP
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #800]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 609: JUMP=2*JUMP+JINK
    mov x9, #2
    ldrsw x10, [x29, #800]
    mul x9, x9, x10
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 611: IF (IA.LT.IC) THEN
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #680]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_95
// Original source line 612: DO 350 K=LA,KSTOP,LA
    ldrsw x9, [x29, #592]
    str w9, [x29, #808]
    ldrsw x9, [x29, #856]
    str x9, [x29, #1096]
    ldrsw x9, [x29, #592]
    str x9, [x29, #1104]
.Lmd2asm_fft992_rpassf_do_97:
    ldrsw x9, [x29, #808]
    ldr x10, [x29, #1096]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_98
// Original source line 613: KB=K+K
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #808]
    add x10, x10, x9
    str w10, [x29, #816]
// Original source line 614: KC=KB+KB
    ldrsw x10, [x29, #816]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #824]
// Original source line 615: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #816]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #320]
// Original source line 616: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #816]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #360]
// Original source line 617: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #824]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #328]
// Original source line 618: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #824]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #368]
// Original source line 619: IBASE=0
    mov x10, #0
    str w10, [x29, #672]
// Original source line 620: DO 340 L=1,ILA
    mov x10, #1
    str w10, [x29, #864]
    ldrsw x10, [x29, #632]
    str x10, [x29, #1112]
    mov x10, #1
    str x10, [x29, #1120]
.Lmd2asm_fft992_rpassf_do_99:
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1112]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_100
// Original source line 621: I=IBASE
    ldrsw x9, [x29, #672]
    str w9, [x29, #640]
// Original source line 622: J=JBASE
    ldrsw x9, [x29, #736]
    str w9, [x29, #712]
// Original source line 625: DO 330 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #616]
    ldrsw x9, [x29, #624]
    str x9, [x29, #1128]
    mov x9, #1
    str x9, [x29, #1136]
.Lmd2asm_fft992_rpassf_do_101:
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1128]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_102
// Original source line 626: C(JA+J)=A(IA+I)+(A(IB+I)+A(IC+I))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 627: D(JA+J)=B(IA+I)+(B(IB+I)-B(IC+I))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 628: C(JB+J)=C1*((A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I)))-(SIN60*(B(IB+I)+B(IC+I))))-S1*((B(IA+I)-0.5_JPRB*(B(IB+I)-B(IC+I)))+(SIN60*(A(IB+I)-A(IC+I))))
    ldr d0, [x29, #320]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #360]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d3, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldr d3, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 633: D(JB+J)=S1*((A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I)))-(SIN60*(B(IB+I)+B(IC+I))))+C1*((B(IA+I)-0.5_JPRB*(B(IB+I)-B(IC+I)))+(SIN60*(A(IB+I)-A(IC+I))))
    ldr d0, [x29, #360]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #320]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d3, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldr d3, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 638: C(JC+J)=C2*((A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I)))+(SIN60*(B(IB+I)+B(IC+I))))-S2*((B(IA+I)-0.5_JPRB*(B(IB+I)-B(IC+I)))-(SIN60*(A(IB+I)-A(IC+I))))
    ldr d0, [x29, #328]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #368]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d3, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldr d3, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 643: D(JC+J)=S2*((A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I)))+(SIN60*(B(IB+I)+B(IC+I))))+C2*((B(IA+I)-0.5_JPRB*(B(IB+I)-B(IC+I)))-(SIN60*(A(IB+I)-A(IC+I))))
    ldr d0, [x29, #368]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #328]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d3, [x16, :lo12:.Lfft_constant_0]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldr d3, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d5, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d4,d4,d5 // fsub d4, d4, d5
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 648: I=I+INC3
    ldrsw x10, [x29, #640]
    ldrsw x9, [x29, #560]
    add x10, x10, x9
    str w10, [x29, #640]
// Original source line 649: J=J+INC4
    ldrsw x10, [x29, #712]
    ldrsw x9, [x29, #568]
    add x10, x10, x9
    str w10, [x29, #712]
// Original source line 650: 330 CONTINUE
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1136]
    add x10, x10, x9
    str x10, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_101
.Lmd2asm_fft992_rpassf_do_done_102:
// Original source line 651: IBASE=IBASE+INC1
    ldrsw x9, [x29, #672]
    ldrsw x10, [x29, #544]
    add x9, x9, x10
    str w9, [x29, #672]
// Original source line 652: JBASE=JBASE+INC21
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #600]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 653: 340 CONTINUE
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1120]
    add x9, x9, x10
    str x9, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_99
.Lmd2asm_fft992_rpassf_do_done_100:
// Original source line 654: IA=IA+IINK
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #648]
// Original source line 655: IB=IB+IINK
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #656]
// Original source line 656: IC=IC-IINK
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #680]
// Original source line 657: JBASE=JBASE+JUMP
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #800]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 658: 350 CONTINUE
    ldrsw x10, [x29, #808]
    ldr x9, [x29, #1104]
    add x10, x10, x9
    str x10, [x29, #808]
    b .Lmd2asm_fft992_rpassf_do_97
.Lmd2asm_fft992_rpassf_do_done_98:
// Original source line 659: ENDIF
.Lmd2asm_fft992_rpassf_if_false_95:
.Lmd2asm_fft992_rpassf_if_end_96:
// Original source line 661: IF (IA.EQ.IC) THEN
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #680]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_103
// Original source line 662: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 663: DO 380 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1144]
    mov x9, #1
    str x9, [x29, #1152]
.Lmd2asm_fft992_rpassf_do_105:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1144]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_106
// Original source line 664: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 665: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 668: DO 370 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1160]
    mov x10, #1
    str x10, [x29, #1168]
.Lmd2asm_fft992_rpassf_do_107:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1160]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_108
// Original source line 669: C(JA+J)=A(IA+I)+A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 670: C(JB+J)=(0.5_JPRB*A(IA+I)-A(IB+I))-(SIN60*B(IA+I))
    adrp x16, .Lfft_constant_0
    ldr d0, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 671: C(JC+J)=-(0.5_JPRB*A(IA+I)-A(IB+I))-(SIN60*B(IA+I))
    adrp x16, .Lfft_constant_0
    ldr d0, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 672: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 673: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 674: 370 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1168]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_107
.Lmd2asm_fft992_rpassf_do_done_108:
// Original source line 675: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 676: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 677: 380 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1152]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_105
.Lmd2asm_fft992_rpassf_do_done_106:
// Original source line 678: ENDIF
.Lmd2asm_fft992_rpassf_if_false_103:
.Lmd2asm_fft992_rpassf_if_end_104:
// Original source line 680: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_90
.Lmd2asm_fft992_rpassf_if_false_89:
// Original source line 681: SSIN60=2.0*SIN60
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldr d1, [x29, #416]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #448]
// Original source line 682: IF (LIPL) THEN
    ldrsw x9, [x29, #880]
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_109
// Original source line 683: DO 394 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1176]
    mov x9, #1
    str x9, [x29, #1184]
.Lmd2asm_fft992_rpassf_do_111:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1176]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_112
// Original source line 684: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 686: DO 392 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1192]
    mov x10, #1
    str x10, [x29, #1200]
.Lmd2asm_fft992_rpassf_do_113:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1192]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_114
// Original source line 687: T1=(2.0_JPRB*A(IA+I)-A(IB+I))-(SSIN60*B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #480]
// Original source line 688: T2=(2.0_JPRB*A(IA+I)-A(IB+I))+(SSIN60*B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #488]
// Original source line 689: A(IA+I)=2.0_JPRB*(A(IA+I)+A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 690: A(IB+I)=T1
    ldr d0, [x29, #480]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 691: B(IB+I)=T2
    ldr d0, [x29, #488]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 692: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 693: 392 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1200]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_113
.Lmd2asm_fft992_rpassf_do_done_114:
// Original source line 694: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 695: 394 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1184]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_111
.Lmd2asm_fft992_rpassf_do_done_112:
// Original source line 696: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_110
.Lmd2asm_fft992_rpassf_if_false_109:
// Original source line 697: DO 398 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1208]
    mov x9, #1
    str x9, [x29, #1216]
.Lmd2asm_fft992_rpassf_do_115:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1208]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_116
// Original source line 698: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 699: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 702: DO 396 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1224]
    mov x10, #1
    str x10, [x29, #1232]
.Lmd2asm_fft992_rpassf_do_117:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1224]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_118
// Original source line 703: C(JA+J)=2.0_JPRB*(A(IA+I)+A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 704: C(JB+J)=(2.0_JPRB*A(IA+I)-A(IB+I))-(SSIN60*B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 705: C(JC+J)=(2.0_JPRB*A(IA+I)-A(IB+I))+(SSIN60*B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 706: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 707: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 708: 396 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1232]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_117
.Lmd2asm_fft992_rpassf_do_done_118:
// Original source line 709: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 710: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 711: 398 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1216]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_115
.Lmd2asm_fft992_rpassf_do_done_116:
// Original source line 712: ENDIF
.Lmd2asm_fft992_rpassf_if_end_110:
// Original source line 713: ENDIF
.Lmd2asm_fft992_rpassf_if_end_90:
// Original source line 715: ELSEIF (IFAC.EQ.4) THEN
    b .Lmd2asm_fft992_rpassf_if_end_57
.Lmd2asm_fft992_rpassf_elseif_false_88:
    ldrsw x9, [x29, #584]
    mov x10, #4
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_elseif_false_119
// Original source line 719: 400 CONTINUE
// Original source line 720: IA=1
    mov x9, #1
    str w9, [x29, #648]
// Original source line 721: IB=IA+(2*M-LA)*INC1
    ldrsw x9, [x29, #648]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #592]
    sub x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 722: IC=IB+2*M*INC1
    ldrsw x9, [x29, #656]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #680]
// Original source line 723: ID=IB
    ldrsw x9, [x29, #656]
    str w9, [x29, #688]
// Original source line 724: JA=1
    mov x9, #1
    str w9, [x29, #720]
// Original source line 725: JB=JA+JINK
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #728]
// Original source line 726: JC=JB+JINK
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 727: JD=JC+JINK
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #752]
// Original source line 729: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_120
// Original source line 731: DO 420 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1240]
    mov x9, #1
    str x9, [x29, #1248]
.Lmd2asm_fft992_rpassf_do_122:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1240]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_123
// Original source line 732: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 733: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 736: DO 410 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1256]
    mov x10, #1
    str x10, [x29, #1264]
.Lmd2asm_fft992_rpassf_do_124:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1256]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_125
// Original source line 737: C(JA+J)=(A(IA+I)+A(IC+I))+A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 738: C(JB+J)=(A(IA+I)-A(IC+I))-B(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 739: C(JC+J)=(A(IA+I)+A(IC+I))-A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 740: C(JD+J)=(A(IA+I)-A(IC+I))+B(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 741: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 742: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 743: 410 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1264]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_124
.Lmd2asm_fft992_rpassf_do_done_125:
// Original source line 744: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 745: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 746: 420 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1248]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_122
.Lmd2asm_fft992_rpassf_do_done_123:
// Original source line 747: IA=IA+IINK
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #648]
// Original source line 748: IINK=2*IINK
    mov x9, #2
    ldrsw x10, [x29, #608]
    mul x9, x9, x10
    str w9, [x29, #608]
// Original source line 749: IB=IB+IINK
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 750: IC=IC-IINK
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #680]
// Original source line 751: ID=ID-IINK
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #688]
// Original source line 752: JBASE=JBASE+JUMP
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #800]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 753: JUMP=2*JUMP+JINK
    mov x9, #2
    ldrsw x10, [x29, #800]
    mul x9, x9, x10
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 755: IF (IB.LT.IC) THEN
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #680]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_126
// Original source line 756: DO 450 K=LA,KSTOP,LA
    ldrsw x9, [x29, #592]
    str w9, [x29, #808]
    ldrsw x9, [x29, #856]
    str x9, [x29, #1272]
    ldrsw x9, [x29, #592]
    str x9, [x29, #1280]
.Lmd2asm_fft992_rpassf_do_128:
    ldrsw x9, [x29, #808]
    ldr x10, [x29, #1272]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_129
// Original source line 757: KB=K+K
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #808]
    add x10, x10, x9
    str w10, [x29, #816]
// Original source line 758: KC=KB+KB
    ldrsw x10, [x29, #816]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #824]
// Original source line 759: KD=KC+KB
    ldrsw x10, [x29, #824]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #832]
// Original source line 760: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #816]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #320]
// Original source line 761: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #816]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #360]
// Original source line 762: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #824]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #328]
// Original source line 763: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #824]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #368]
// Original source line 764: C3=TRIGS(KD+1)
    ldrsw x10, [x29, #832]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #336]
// Original source line 765: S3=TRIGS(KD+2)
    ldrsw x10, [x29, #832]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #376]
// Original source line 766: IBASE=0
    mov x10, #0
    str w10, [x29, #672]
// Original source line 767: DO 440 L=1,ILA
    mov x10, #1
    str w10, [x29, #864]
    ldrsw x10, [x29, #632]
    str x10, [x29, #1288]
    mov x10, #1
    str x10, [x29, #1296]
.Lmd2asm_fft992_rpassf_do_130:
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1288]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_131
// Original source line 768: I=IBASE
    ldrsw x9, [x29, #672]
    str w9, [x29, #640]
// Original source line 769: J=JBASE
    ldrsw x9, [x29, #736]
    str w9, [x29, #712]
// Original source line 772: DO 430 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #616]
    ldrsw x9, [x29, #624]
    str x9, [x29, #1304]
    mov x9, #1
    str x9, [x29, #1312]
.Lmd2asm_fft992_rpassf_do_132:
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1304]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_133
// Original source line 773: C(JA+J)=(A(IA+I)+A(IC+I))+(A(IB+I)+A(ID+I))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 774: D(JA+J)=(B(IA+I)-B(IC+I))+(B(IB+I)-B(ID+I))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 775: C(JC+J)=C2*((A(IA+I)+A(IC+I))-(A(IB+I)+A(ID+I)))-S2*((B(IA+I)-B(IC+I))-(B(IB+I)-B(ID+I)))
    ldr d0, [x29, #328]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #368]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 778: D(JC+J)=S2*((A(IA+I)+A(IC+I))-(A(IB+I)+A(ID+I)))+C2*((B(IA+I)-B(IC+I))-(B(IB+I)-B(ID+I)))
    ldr d0, [x29, #368]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #328]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 781: C(JB+J)=C1*((A(IA+I)-A(IC+I))-(B(IB+I)+B(ID+I)))-S1*((B(IA+I)+B(IC+I))+(A(IB+I)-A(ID+I)))
    ldr d0, [x29, #320]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #360]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 784: D(JB+J)=S1*((A(IA+I)-A(IC+I))-(B(IB+I)+B(ID+I)))+C1*((B(IA+I)+B(IC+I))+(A(IB+I)-A(ID+I)))
    ldr d0, [x29, #360]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #320]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 787: C(JD+J)=C3*((A(IA+I)-A(IC+I))+(B(IB+I)+B(ID+I)))-S3*((B(IA+I)+B(IC+I))-(A(IB+I)-A(ID+I)))
    ldr d0, [x29, #336]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #376]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 790: D(JD+J)=S3*((A(IA+I)-A(IC+I))+(B(IB+I)+B(ID+I)))+C3*((B(IA+I)+B(IC+I))-(A(IB+I)-A(ID+I)))
    ldr d0, [x29, #376]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #336]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 793: I=I+INC3
    ldrsw x10, [x29, #640]
    ldrsw x9, [x29, #560]
    add x10, x10, x9
    str w10, [x29, #640]
// Original source line 794: J=J+INC4
    ldrsw x10, [x29, #712]
    ldrsw x9, [x29, #568]
    add x10, x10, x9
    str w10, [x29, #712]
// Original source line 795: 430 CONTINUE
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1312]
    add x10, x10, x9
    str x10, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_132
.Lmd2asm_fft992_rpassf_do_done_133:
// Original source line 796: IBASE=IBASE+INC1
    ldrsw x9, [x29, #672]
    ldrsw x10, [x29, #544]
    add x9, x9, x10
    str w9, [x29, #672]
// Original source line 797: JBASE=JBASE+INC21
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #600]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 798: 440 CONTINUE
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1296]
    add x9, x9, x10
    str x9, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_130
.Lmd2asm_fft992_rpassf_do_done_131:
// Original source line 799: IA=IA+IINK
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #648]
// Original source line 800: IB=IB+IINK
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #656]
// Original source line 801: IC=IC-IINK
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #680]
// Original source line 802: ID=ID-IINK
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #688]
// Original source line 803: JBASE=JBASE+JUMP
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #800]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 804: 450 CONTINUE
    ldrsw x10, [x29, #808]
    ldr x9, [x29, #1280]
    add x10, x10, x9
    str x10, [x29, #808]
    b .Lmd2asm_fft992_rpassf_do_128
.Lmd2asm_fft992_rpassf_do_done_129:
// Original source line 805: ENDIF
.Lmd2asm_fft992_rpassf_if_false_126:
.Lmd2asm_fft992_rpassf_if_end_127:
// Original source line 807: IF (IB.EQ.IC) THEN
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #680]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_134
// Original source line 808: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 809: SIN45=SQRT(0.5_JPRB)
    adrp x16, .Lfft_constant_7
    ldr d0, [x16, :lo12:.Lfft_constant_7]
    str d0, [x29, #408]
// Original source line 810: DO 480 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1320]
    mov x9, #1
    str x9, [x29, #1328]
.Lmd2asm_fft992_rpassf_do_136:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1320]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_137
// Original source line 811: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 812: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 815: DO 470 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1336]
    mov x10, #1
    str x10, [x29, #1344]
.Lmd2asm_fft992_rpassf_do_138:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1336]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_139
// Original source line 816: C(JA+J)=A(IA+I)+A(IB+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 817: C(JB+J)=SIN45*((A(IA+I)-A(IB+I))-(B(IA+I)+B(IB+I)))
    ldr d0, [x29, #408]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 818: C(JC+J)=B(IB+I)-B(IA+I)
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 819: C(JD+J)=-SIN45*((A(IA+I)-A(IB+I))+(B(IA+I)+B(IB+I)))
    ldr d0, [x29, #408]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 820: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 821: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 822: 470 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1344]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_138
.Lmd2asm_fft992_rpassf_do_done_139:
// Original source line 823: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 824: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 825: 480 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1328]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_136
.Lmd2asm_fft992_rpassf_do_done_137:
// Original source line 826: ENDIF
.Lmd2asm_fft992_rpassf_if_false_134:
.Lmd2asm_fft992_rpassf_if_end_135:
// Original source line 828: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_121
.Lmd2asm_fft992_rpassf_if_false_120:
// Original source line 829: IF (LIPL) THEN
    ldrsw x9, [x29, #880]
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_140
// Original source line 830: DO 494 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1352]
    mov x9, #1
    str x9, [x29, #1360]
.Lmd2asm_fft992_rpassf_do_142:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1352]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_143
// Original source line 831: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 833: DO 492 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1368]
    mov x10, #1
    str x10, [x29, #1376]
.Lmd2asm_fft992_rpassf_do_144:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1368]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_145
// Original source line 834: T1=2.0_JPRB*((A(IA+I)-A(IC+I))-B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #480]
// Original source line 835: T2=2.0_JPRB*((A(IA+I)+A(IC+I))-A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #488]
// Original source line 836: T3=2.0_JPRB*((A(IA+I)-A(IC+I))+B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #496]
// Original source line 837: A(IA+I)=2.0_JPRB*((A(IA+I)+A(IC+I))+A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 838: A(IB+I)=T1
    ldr d0, [x29, #480]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 839: B(IB+I)=T2
    ldr d0, [x29, #488]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 840: A(IC+I)=T3
    ldr d0, [x29, #496]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 841: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 842: 492 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1376]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_144
.Lmd2asm_fft992_rpassf_do_done_145:
// Original source line 843: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 844: 494 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1360]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_142
.Lmd2asm_fft992_rpassf_do_done_143:
// Original source line 845: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_141
.Lmd2asm_fft992_rpassf_if_false_140:
// Original source line 846: DO 498 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1384]
    mov x9, #1
    str x9, [x29, #1392]
.Lmd2asm_fft992_rpassf_do_146:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1384]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_147
// Original source line 847: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 848: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 851: DO 496 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1400]
    mov x10, #1
    str x10, [x29, #1408]
.Lmd2asm_fft992_rpassf_do_148:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1400]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_149
// Original source line 852: C(JA+J)=2.0_JPRB*((A(IA+I)+A(IC+I))+A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 853: C(JB+J)=2.0_JPRB*((A(IA+I)-A(IC+I))-B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 854: C(JC+J)=2.0_JPRB*((A(IA+I)+A(IC+I))-A(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 855: C(JD+J)=2.0_JPRB*((A(IA+I)-A(IC+I))+B(IB+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 856: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 857: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 858: 496 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1408]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_148
.Lmd2asm_fft992_rpassf_do_done_149:
// Original source line 859: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 860: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 861: 498 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1392]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_146
.Lmd2asm_fft992_rpassf_do_done_147:
// Original source line 862: ENDIF
.Lmd2asm_fft992_rpassf_if_end_141:
// Original source line 863: ENDIF
.Lmd2asm_fft992_rpassf_if_end_121:
// Original source line 865: ELSEIF (IFAC.EQ.5) THEN
    b .Lmd2asm_fft992_rpassf_if_end_57
.Lmd2asm_fft992_rpassf_elseif_false_119:
    ldrsw x9, [x29, #584]
    mov x10, #5
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_elseif_false_150
// Original source line 869: 500 CONTINUE
// Original source line 870: IA=1
    mov x9, #1
    str w9, [x29, #648]
// Original source line 871: IB=IA+(2*M-LA)*INC1
    ldrsw x9, [x29, #648]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #592]
    sub x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 872: IC=IB+2*M*INC1
    ldrsw x9, [x29, #656]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #680]
// Original source line 873: ID=IC
    ldrsw x9, [x29, #680]
    str w9, [x29, #688]
// Original source line 874: IE=IB
    ldrsw x9, [x29, #656]
    str w9, [x29, #696]
// Original source line 875: JA=1
    mov x9, #1
    str w9, [x29, #720]
// Original source line 876: JB=JA+JINK
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #728]
// Original source line 877: JC=JB+JINK
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 878: JD=JC+JINK
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #752]
// Original source line 879: JE=JD+JINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 881: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_151
// Original source line 883: DO 520 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1416]
    mov x9, #1
    str x9, [x29, #1424]
.Lmd2asm_fft992_rpassf_do_153:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1416]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_154
// Original source line 884: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 885: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 888: DO 510 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1432]
    mov x10, #1
    str x10, [x29, #1440]
.Lmd2asm_fft992_rpassf_do_155:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1432]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_156
// Original source line 889: C(JA+J)=A(IA+I)+(A(IB+I)+A(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 890: C(JB+J)=((A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))+QRT5*(A(IB+I)-A(IC+I)))-(SIN72*B(IB+I)+SIN36*B(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #424]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #400]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 892: C(JC+J)=((A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))-QRT5*(A(IB+I)-A(IC+I)))-(SIN36*B(IB+I)-SIN72*B(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #400]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #424]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 894: C(JD+J)=((A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))-QRT5*(A(IB+I)-A(IC+I)))+(SIN36*B(IB+I)-SIN72*B(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #400]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #424]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 896: C(JE+J)=((A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))+QRT5*(A(IB+I)-A(IC+I)))+(SIN72*B(IB+I)+SIN36*B(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #424]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #400]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 898: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 899: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 900: 510 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1440]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_155
.Lmd2asm_fft992_rpassf_do_done_156:
// Original source line 901: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 902: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 903: 520 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1424]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_153
.Lmd2asm_fft992_rpassf_do_done_154:
// Original source line 904: IA=IA+IINK
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #648]
// Original source line 905: IINK=2*IINK
    mov x9, #2
    ldrsw x10, [x29, #608]
    mul x9, x9, x10
    str w9, [x29, #608]
// Original source line 906: IB=IB+IINK
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 907: IC=IC+IINK
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #680]
// Original source line 908: ID=ID-IINK
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #688]
// Original source line 909: IE=IE-IINK
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #696]
// Original source line 910: JBASE=JBASE+JUMP
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #800]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 911: JUMP=2*JUMP+JINK
    mov x9, #2
    ldrsw x10, [x29, #800]
    mul x9, x9, x10
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 913: IF (IB.LT.ID) THEN
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #688]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_157
// Original source line 914: DO 550 K=LA,KSTOP,LA
    ldrsw x9, [x29, #592]
    str w9, [x29, #808]
    ldrsw x9, [x29, #856]
    str x9, [x29, #1448]
    ldrsw x9, [x29, #592]
    str x9, [x29, #1456]
.Lmd2asm_fft992_rpassf_do_159:
    ldrsw x9, [x29, #808]
    ldr x10, [x29, #1448]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_160
// Original source line 915: KB=K+K
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #808]
    add x10, x10, x9
    str w10, [x29, #816]
// Original source line 916: KC=KB+KB
    ldrsw x10, [x29, #816]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #824]
// Original source line 917: KD=KC+KB
    ldrsw x10, [x29, #824]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #832]
// Original source line 918: KE=KD+KB
    ldrsw x10, [x29, #832]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #840]
// Original source line 919: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #816]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #320]
// Original source line 920: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #816]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #360]
// Original source line 921: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #824]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #328]
// Original source line 922: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #824]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #368]
// Original source line 923: C3=TRIGS(KD+1)
    ldrsw x10, [x29, #832]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #336]
// Original source line 924: S3=TRIGS(KD+2)
    ldrsw x10, [x29, #832]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #376]
// Original source line 925: C4=TRIGS(KE+1)
    ldrsw x10, [x29, #840]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #344]
// Original source line 926: S4=TRIGS(KE+2)
    ldrsw x10, [x29, #840]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #384]
// Original source line 927: IBASE=0
    mov x10, #0
    str w10, [x29, #672]
// Original source line 928: DO 540 L=1,ILA
    mov x10, #1
    str w10, [x29, #864]
    ldrsw x10, [x29, #632]
    str x10, [x29, #1464]
    mov x10, #1
    str x10, [x29, #1472]
.Lmd2asm_fft992_rpassf_do_161:
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1464]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_162
// Original source line 929: I=IBASE
    ldrsw x9, [x29, #672]
    str w9, [x29, #640]
// Original source line 930: J=JBASE
    ldrsw x9, [x29, #736]
    str w9, [x29, #712]
// Original source line 933: DO 530 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #616]
    ldrsw x9, [x29, #624]
    str x9, [x29, #1480]
    mov x9, #1
    str x9, [x29, #1488]
.Lmd2asm_fft992_rpassf_do_163:
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1480]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_164
// Original source line 935: A10=(A(IA+I)-0.25_JPRB*((A(IB+I)+A(IE+I))+(A(IC+I)+A(ID+I))))+QRT5*((A(IB+I)+A(IE+I))-(A(IC+I)+A(ID+I)))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #256]
// Original source line 937: A20=(A(IA+I)-0.25_JPRB*((A(IB+I)+A(IE+I))+(A(IC+I)+A(ID+I))))-QRT5*((A(IB+I)+A(IE+I))-(A(IC+I)+A(ID+I)))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #272]
// Original source line 939: B10=(B(IA+I)-0.25_JPRB*((B(IB+I)-B(IE+I))+(B(IC+I)-B(ID+I))))+QRT5*((B(IB+I)-B(IE+I))-(B(IC+I)-B(ID+I)))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #288]
// Original source line 941: B20=(B(IA+I)-0.25_JPRB*((B(IB+I)-B(IE+I))+(B(IC+I)-B(ID+I))))-QRT5*((B(IB+I)-B(IE+I))-(B(IC+I)-B(ID+I)))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #464]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #304]
// Original source line 943: A11=SIN72*(B(IB+I)+B(IE+I))+SIN36*(B(IC+I)+B(ID+I))
    ldr d0, [x29, #424]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #400]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 944: A21=SIN36*(B(IB+I)+B(IE+I))-SIN72*(B(IC+I)+B(ID+I))
    ldr d0, [x29, #400]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #424]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 945: B11=SIN72*(A(IB+I)-A(IE+I))+SIN36*(A(IC+I)-A(ID+I))
    ldr d0, [x29, #424]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #400]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #296]
// Original source line 946: B21=SIN36*(A(IB+I)-A(IE+I))-SIN72*(A(IC+I)-A(ID+I))
    ldr d0, [x29, #400]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #424]
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #312]
// Original source line 948: C(JA+J)=A(IA+I)+((A(IB+I)+A(IE+I))+(A(IC+I)+A(ID+I)))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 949: D(JA+J)=B(IA+I)+((B(IB+I)-B(IE+I))+(B(IC+I)-B(ID+I)))
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 950: C(JB+J)=C1*(A10-A11)-S1*(B10+B11)
    ldr d0, [x29, #320]
    ldr d1, [x29, #256]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #360]
    ldr d2, [x29, #288]
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 951: D(JB+J)=S1*(A10-A11)+C1*(B10+B11)
    ldr d0, [x29, #360]
    ldr d1, [x29, #256]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #320]
    ldr d2, [x29, #288]
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 952: C(JE+J)=C4*(A10+A11)-S4*(B10-B11)
    ldr d0, [x29, #344]
    ldr d1, [x29, #256]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #384]
    ldr d2, [x29, #288]
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 953: D(JE+J)=S4*(A10+A11)+C4*(B10-B11)
    ldr d0, [x29, #384]
    ldr d1, [x29, #256]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #344]
    ldr d2, [x29, #288]
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 954: C(JC+J)=C2*(A20-A21)-S2*(B20+B21)
    ldr d0, [x29, #328]
    ldr d1, [x29, #272]
    ldr d2, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #368]
    ldr d2, [x29, #304]
    ldr d3, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 955: D(JC+J)=S2*(A20-A21)+C2*(B20+B21)
    ldr d0, [x29, #368]
    ldr d1, [x29, #272]
    ldr d2, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #328]
    ldr d2, [x29, #304]
    ldr d3, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 956: C(JD+J)=C3*(A20+A21)-S3*(B20-B21)
    ldr d0, [x29, #336]
    ldr d1, [x29, #272]
    ldr d2, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #376]
    ldr d2, [x29, #304]
    ldr d3, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 957: D(JD+J)=S3*(A20+A21)+C3*(B20-B21)
    ldr d0, [x29, #376]
    ldr d1, [x29, #272]
    ldr d2, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #336]
    ldr d2, [x29, #304]
    ldr d3, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 959: I=I+INC3
    ldrsw x10, [x29, #640]
    ldrsw x9, [x29, #560]
    add x10, x10, x9
    str w10, [x29, #640]
// Original source line 960: J=J+INC4
    ldrsw x10, [x29, #712]
    ldrsw x9, [x29, #568]
    add x10, x10, x9
    str w10, [x29, #712]
// Original source line 961: 530 CONTINUE
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1488]
    add x10, x10, x9
    str x10, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_163
.Lmd2asm_fft992_rpassf_do_done_164:
// Original source line 962: IBASE=IBASE+INC1
    ldrsw x9, [x29, #672]
    ldrsw x10, [x29, #544]
    add x9, x9, x10
    str w9, [x29, #672]
// Original source line 963: JBASE=JBASE+INC21
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #600]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 964: 540 CONTINUE
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1472]
    add x9, x9, x10
    str x9, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_161
.Lmd2asm_fft992_rpassf_do_done_162:
// Original source line 965: IA=IA+IINK
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #648]
// Original source line 966: IB=IB+IINK
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #656]
// Original source line 967: IC=IC+IINK
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #680]
// Original source line 968: ID=ID-IINK
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #688]
// Original source line 969: IE=IE-IINK
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #696]
// Original source line 970: JBASE=JBASE+JUMP
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #800]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 971: 550 CONTINUE
    ldrsw x10, [x29, #808]
    ldr x9, [x29, #1456]
    add x10, x10, x9
    str x10, [x29, #808]
    b .Lmd2asm_fft992_rpassf_do_159
.Lmd2asm_fft992_rpassf_do_done_160:
// Original source line 972: ENDIF
.Lmd2asm_fft992_rpassf_if_false_157:
.Lmd2asm_fft992_rpassf_if_end_158:
// Original source line 974: IF (IB.EQ.ID) THEN
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #688]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_165
// Original source line 975: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 976: DO 580 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1496]
    mov x9, #1
    str x9, [x29, #1504]
.Lmd2asm_fft992_rpassf_do_167:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1496]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_168
// Original source line 977: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 978: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 981: DO 570 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1512]
    mov x10, #1
    str x10, [x29, #1520]
.Lmd2asm_fft992_rpassf_do_169:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1512]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_170
// Original source line 982: C(JA+J)=(A(IA+I)+A(IB+I))+A(IC+I)
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 983: C(JB+J)=(QRT5*(A(IA+I)-A(IB+I))+(0.25_JPRB*(A(IA+I)+A(IB+I))-A(IC+I)))-(SIN36*B(IA+I)+SIN72*B(IB+I))
    ldr d0, [x29, #464]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #400]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #424]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 986: C(JE+J)=-(QRT5*(A(IA+I)-A(IB+I))+(0.25_JPRB*(A(IA+I)+A(IB+I))-A(IC+I)))-(SIN36*B(IA+I)+SIN72*B(IB+I))
    ldr d0, [x29, #464]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #400]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #424]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 989: C(JC+J)=(QRT5*(A(IA+I)-A(IB+I))-(0.25_JPRB*(A(IA+I)+A(IB+I))-A(IC+I)))-(SIN72*B(IA+I)-SIN36*B(IB+I))
    ldr d0, [x29, #464]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #424]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #400]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 992: C(JD+J)=-(QRT5*(A(IA+I)-A(IB+I))-(0.25_JPRB*(A(IA+I)+A(IB+I))-A(IC+I)))-(SIN72*B(IA+I)-SIN36*B(IB+I))
    ldr d0, [x29, #464]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #424]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #400]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 995: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 996: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 997: 570 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1520]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_169
.Lmd2asm_fft992_rpassf_do_done_170:
// Original source line 998: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 999: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1000: 580 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1504]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_167
.Lmd2asm_fft992_rpassf_do_done_168:
// Original source line 1001: ENDIF
.Lmd2asm_fft992_rpassf_if_false_165:
.Lmd2asm_fft992_rpassf_if_end_166:
// Original source line 1003: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_152
.Lmd2asm_fft992_rpassf_if_false_151:
// Original source line 1004: QQRT5=2.0*QRT5
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldr d1, [x29, #464]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #472]
// Original source line 1005: SSIN36=2.0*SIN36
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldr d1, [x29, #400]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #432]
// Original source line 1006: SSIN72=2.0*SIN72
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #456]
// Original source line 1007: IF (LIPL) THEN
    ldrsw x9, [x29, #880]
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_171
// Original source line 1008: DO 594 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1528]
    mov x9, #1
    str x9, [x29, #1536]
.Lmd2asm_fft992_rpassf_do_173:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1528]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_174
// Original source line 1009: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1011: DO 592 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1544]
    mov x10, #1
    str x10, [x29, #1552]
.Lmd2asm_fft992_rpassf_do_175:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1544]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_176
// Original source line 1012: T1=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))+QQRT5*(A(IB+I)-A(IC+I)))-(SSIN72*B(IB+I)+SSIN36*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #432]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #480]
// Original source line 1014: T2=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))-QQRT5*(A(IB+I)-A(IC+I)))-(SSIN36*B(IB+I)-SSIN72*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #432]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #456]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #488]
// Original source line 1016: T3=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))-QQRT5*(A(IB+I)-A(IC+I)))+(SSIN36*B(IB+I)-SSIN72*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #432]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #456]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #496]
// Original source line 1018: T4=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))+QQRT5*(A(IB+I)-A(IC+I)))+(SSIN72*B(IB+I)+SSIN36*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #432]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #504]
// Original source line 1020: A(IA+I)=2.0_JPRB*(A(IA+I)+(A(IB+I)+A(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1021: A(IB+I)=T1
    ldr d0, [x29, #480]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1022: B(IB+I)=T2
    ldr d0, [x29, #488]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1023: A(IC+I)=T3
    ldr d0, [x29, #496]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1024: B(IC+I)=T4
    ldr d0, [x29, #504]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1025: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1026: 592 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1552]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_175
.Lmd2asm_fft992_rpassf_do_done_176:
// Original source line 1027: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1028: 594 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1536]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_173
.Lmd2asm_fft992_rpassf_do_done_174:
// Original source line 1029: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_172
.Lmd2asm_fft992_rpassf_if_false_171:
// Original source line 1030: DO 598 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1560]
    mov x9, #1
    str x9, [x29, #1568]
.Lmd2asm_fft992_rpassf_do_177:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1560]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_178
// Original source line 1031: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1032: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 1035: DO 596 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1576]
    mov x10, #1
    str x10, [x29, #1584]
.Lmd2asm_fft992_rpassf_do_179:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1576]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_180
// Original source line 1036: C(JA+J)=2.0_JPRB*(A(IA+I)+(A(IB+I)+A(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1037: C(JB+J)=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))+QQRT5*(A(IB+I)-A(IC+I)))-(SSIN72*B(IB+I)+SSIN36*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #432]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1039: C(JC+J)=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))-QQRT5*(A(IB+I)-A(IC+I)))-(SSIN36*B(IB+I)-SSIN72*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #432]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #456]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1041: C(JD+J)=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))-QQRT5*(A(IB+I)-A(IC+I)))+(SSIN36*B(IB+I)-SSIN72*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #432]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #456]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1043: C(JE+J)=(2.0_JPRB*(A(IA+I)-0.25_JPRB*(A(IB+I)+A(IC+I)))+QQRT5*(A(IB+I)-A(IC+I)))+(SSIN72*B(IB+I)+SSIN36*B(IC+I))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #432]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1045: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1046: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 1047: 596 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1584]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_179
.Lmd2asm_fft992_rpassf_do_done_180:
// Original source line 1048: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1049: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1050: 598 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1568]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_177
.Lmd2asm_fft992_rpassf_do_done_178:
// Original source line 1051: ENDIF
.Lmd2asm_fft992_rpassf_if_end_172:
// Original source line 1052: ENDIF
.Lmd2asm_fft992_rpassf_if_end_152:
// Original source line 1054: ELSEIF (IFAC.EQ.6) THEN
    b .Lmd2asm_fft992_rpassf_if_end_57
.Lmd2asm_fft992_rpassf_elseif_false_150:
    ldrsw x9, [x29, #584]
    mov x10, #6
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_elseif_false_181
// Original source line 1058: 600 CONTINUE
// Original source line 1059: IA=1
    mov x9, #1
    str w9, [x29, #648]
// Original source line 1060: IB=IA+(2*M-LA)*INC1
    ldrsw x9, [x29, #648]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #592]
    sub x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 1061: IC=IB+2*M*INC1
    ldrsw x9, [x29, #656]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #680]
// Original source line 1062: ID=IC+2*M*INC1
    ldrsw x9, [x29, #680]
    mov x10, #2
    ldrsw x11, [x29, #872]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #688]
// Original source line 1063: IE=IC
    ldrsw x9, [x29, #680]
    str w9, [x29, #696]
// Original source line 1064: IF=IB
    ldrsw x9, [x29, #656]
    str w9, [x29, #704]
// Original source line 1065: JA=1
    mov x9, #1
    str w9, [x29, #720]
// Original source line 1066: JB=JA+JINK
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #728]
// Original source line 1067: JC=JB+JINK
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1068: JD=JC+JINK
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #752]
// Original source line 1069: JE=JD+JINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 1070: JF=JE+JINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #768]
// Original source line 1072: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_182
// Original source line 1074: DO 620 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1592]
    mov x9, #1
    str x9, [x29, #1600]
.Lmd2asm_fft992_rpassf_do_184:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1592]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_185
// Original source line 1075: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1076: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 1079: DO 610 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1608]
    mov x10, #1
    str x10, [x29, #1616]
.Lmd2asm_fft992_rpassf_do_186:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1608]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_187
// Original source line 1080: C(JA+J)=(A(IA+I)+A(ID+I))+(A(IB+I)+A(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1081: C(JD+J)=(A(IA+I)-A(ID+I))-(A(IB+I)-A(IC+I))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1082: C(JB+J)=((A(IA+I)-A(ID+I))+0.5_JPRB*(A(IB+I)-A(IC+I)))-(SIN60*(B(IB+I)+B(IC+I)))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1084: C(JF+J)=((A(IA+I)-A(ID+I))+0.5_JPRB*(A(IB+I)-A(IC+I)))+(SIN60*(B(IB+I)+B(IC+I)))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #768]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1086: C(JC+J)=((A(IA+I)+A(ID+I))-0.5_JPRB*(A(IB+I)+A(IC+I)))-(SIN60*(B(IB+I)-B(IC+I)))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1088: C(JE+J)=((A(IA+I)+A(ID+I))-0.5_JPRB*(A(IB+I)+A(IC+I)))+(SIN60*(B(IB+I)-B(IC+I)))
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #416]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1090: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1091: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 1092: 610 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1616]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_186
.Lmd2asm_fft992_rpassf_do_done_187:
// Original source line 1093: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1094: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1095: 620 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1600]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_184
.Lmd2asm_fft992_rpassf_do_done_185:
// Original source line 1096: IA=IA+IINK
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #648]
// Original source line 1097: IINK=2*IINK
    mov x9, #2
    ldrsw x10, [x29, #608]
    mul x9, x9, x10
    str w9, [x29, #608]
// Original source line 1098: IB=IB+IINK
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 1099: IC=IC+IINK
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #608]
    add x9, x9, x10
    str w9, [x29, #680]
// Original source line 1100: ID=ID-IINK
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #688]
// Original source line 1101: IE=IE-IINK
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #696]
// Original source line 1102: IF=IF-IINK
    ldrsw x9, [x29, #704]
    ldrsw x10, [x29, #608]
    sub x9, x9, x10
    str w9, [x29, #704]
// Original source line 1103: JBASE=JBASE+JUMP
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #800]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 1104: JUMP=2*JUMP+JINK
    mov x9, #2
    ldrsw x10, [x29, #800]
    mul x9, x9, x10
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 1106: IF (IC.LT.ID) THEN
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #688]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_188
// Original source line 1107: DO 650 K=LA,KSTOP,LA
    ldrsw x9, [x29, #592]
    str w9, [x29, #808]
    ldrsw x9, [x29, #856]
    str x9, [x29, #1624]
    ldrsw x9, [x29, #592]
    str x9, [x29, #1632]
.Lmd2asm_fft992_rpassf_do_190:
    ldrsw x9, [x29, #808]
    ldr x10, [x29, #1624]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_191
// Original source line 1108: KB=K+K
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #808]
    add x10, x10, x9
    str w10, [x29, #816]
// Original source line 1109: KC=KB+KB
    ldrsw x10, [x29, #816]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #824]
// Original source line 1110: KD=KC+KB
    ldrsw x10, [x29, #824]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #832]
// Original source line 1111: KE=KD+KB
    ldrsw x10, [x29, #832]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #840]
// Original source line 1112: KF=KE+KB
    ldrsw x10, [x29, #840]
    ldrsw x9, [x29, #816]
    add x10, x10, x9
    str w10, [x29, #848]
// Original source line 1113: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #816]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #320]
// Original source line 1114: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #816]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #360]
// Original source line 1115: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #824]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #328]
// Original source line 1116: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #824]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #368]
// Original source line 1117: C3=TRIGS(KD+1)
    ldrsw x10, [x29, #832]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #336]
// Original source line 1118: S3=TRIGS(KD+2)
    ldrsw x10, [x29, #832]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #376]
// Original source line 1119: C4=TRIGS(KE+1)
    ldrsw x10, [x29, #840]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #344]
// Original source line 1120: S4=TRIGS(KE+2)
    ldrsw x10, [x29, #840]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #384]
// Original source line 1121: C5=TRIGS(KF+1)
    ldrsw x10, [x29, #848]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #352]
// Original source line 1122: S5=TRIGS(KF+2)
    ldrsw x10, [x29, #848]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #392]
// Original source line 1123: IBASE=0
    mov x10, #0
    str w10, [x29, #672]
// Original source line 1124: DO 640 L=1,ILA
    mov x10, #1
    str w10, [x29, #864]
    ldrsw x10, [x29, #632]
    str x10, [x29, #1640]
    mov x10, #1
    str x10, [x29, #1648]
.Lmd2asm_fft992_rpassf_do_192:
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1640]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_193
// Original source line 1125: I=IBASE
    ldrsw x9, [x29, #672]
    str w9, [x29, #640]
// Original source line 1126: J=JBASE
    ldrsw x9, [x29, #736]
    str w9, [x29, #712]
// Original source line 1129: DO 630 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #616]
    ldrsw x9, [x29, #624]
    str x9, [x29, #1656]
    mov x9, #1
    str x9, [x29, #1664]
.Lmd2asm_fft992_rpassf_do_194:
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1656]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_195
// Original source line 1131: A11= (A(IE+I)+A(IB+I))+(A(IC+I)+A(IF+I))
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1132: A20=(A(IA+I)+A(ID+I))-0.5_JPRB*A11
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #272]
// Original source line 1133: A21=SIN60*((A(IE+I)+A(IB+I))-(A(IC+I)+A(IF+I)))
    ldr d0, [x29, #416]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #280]
// Original source line 1134: B11= (B(IB+I)-B(IE+I))+(B(IC+I)-B(IF+I))
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #296]
// Original source line 1135: B20=(B(IA+I)-B(ID+I))-0.5_JPRB*B11
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #304]
// Original source line 1136: B21=SIN60*((B(IB+I)-B(IE+I))-(B(IC+I)-B(IF+I)))
    ldr d0, [x29, #416]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #312]
// Original source line 1138: C(JA+J)=(A(IA+I)+A(ID+I))+A11
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1139: D(JA+J)=(B(IA+I)-B(ID+I))+B11
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #720]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1140: C(JC+J)=C2*(A20-B21)-S2*(B20+A21)
    ldr d0, [x29, #328]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #368]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1141: D(JC+J)=S2*(A20-B21)+C2*(B20+A21)
    ldr d0, [x29, #368]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #328]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1142: C(JE+J)=C4*(A20+B21)-S4*(B20-A21)
    ldr d0, [x29, #344]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #384]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1143: D(JE+J)=S4*(A20+B21)+C4*(B20-A21)
    ldr d0, [x29, #384]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #344]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1145: A11=(A(IE+I)-A(IB+I))+(A(IC+I)-A(IF+I))
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1146: B11=(B(IE+I)+B(IB+I))-(B(IC+I)+B(IF+I))
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #296]
// Original source line 1147: A20=(A(IA+I)-A(ID+I))-0.5_JPRB*A11
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #272]
// Original source line 1148: A21=SIN60*((A(IE+I)-A(IB+I))-(A(IC+I)-A(IF+I)))
    ldr d0, [x29, #416]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #280]
// Original source line 1149: B20=(B(IA+I)+B(ID+I))+0.5_JPRB*B11
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #304]
// Original source line 1150: B21=SIN60*((B(IE+I)+B(IB+I))+(B(IC+I)+B(IF+I)))
    ldr d0, [x29, #416]
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #312]
// Original source line 1152: C(JD+J)=C3*((A(IA+I)-A(ID+I))+A11)-S3*((B(IA+I)+B(ID+I))-B11)
    ldr d0, [x29, #336]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #376]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1154: D(JD+J)=S3*((A(IA+I)-A(ID+I))+A11)+C3*((B(IA+I)+B(ID+I))-B11)
    ldr d0, [x29, #376]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #336]
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #640]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1156: C(JB+J)=C1*(A20-B21)-S1*(B20-A21)
    ldr d0, [x29, #320]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #360]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1157: D(JB+J)=S1*(A20-B21)+C1*(B20-A21)
    ldr d0, [x29, #360]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #320]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #728]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1158: C(JF+J)=C5*(A20+B21)-S5*(B20+A21)
    ldr d0, [x29, #352]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #392]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #768]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1159: D(JF+J)=S5*(A20+B21)+C5*(B20+A21)
    ldr d0, [x29, #392]
    ldr d1, [x29, #272]
    ldr d2, [x29, #312]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #352]
    ldr d2, [x29, #304]
    ldr d3, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #768]
    ldrsw x9, [x29, #712]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1161: I=I+INC3
    ldrsw x10, [x29, #640]
    ldrsw x9, [x29, #560]
    add x10, x10, x9
    str w10, [x29, #640]
// Original source line 1162: J=J+INC4
    ldrsw x10, [x29, #712]
    ldrsw x9, [x29, #568]
    add x10, x10, x9
    str w10, [x29, #712]
// Original source line 1163: 630 CONTINUE
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1664]
    add x10, x10, x9
    str x10, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_194
.Lmd2asm_fft992_rpassf_do_done_195:
// Original source line 1164: IBASE=IBASE+INC1
    ldrsw x9, [x29, #672]
    ldrsw x10, [x29, #544]
    add x9, x9, x10
    str w9, [x29, #672]
// Original source line 1165: JBASE=JBASE+INC21
    ldrsw x9, [x29, #736]
    ldrsw x10, [x29, #600]
    add x9, x9, x10
    str w9, [x29, #736]
// Original source line 1166: 640 CONTINUE
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1648]
    add x9, x9, x10
    str x9, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_192
.Lmd2asm_fft992_rpassf_do_done_193:
// Original source line 1167: IA=IA+IINK
    ldrsw x10, [x29, #648]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #648]
// Original source line 1168: IB=IB+IINK
    ldrsw x10, [x29, #656]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #656]
// Original source line 1169: IC=IC+IINK
    ldrsw x10, [x29, #680]
    ldrsw x9, [x29, #608]
    add x10, x10, x9
    str w10, [x29, #680]
// Original source line 1170: ID=ID-IINK
    ldrsw x10, [x29, #688]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #688]
// Original source line 1171: IE=IE-IINK
    ldrsw x10, [x29, #696]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #696]
// Original source line 1172: IF=IF-IINK
    ldrsw x10, [x29, #704]
    ldrsw x9, [x29, #608]
    sub x10, x10, x9
    str w10, [x29, #704]
// Original source line 1173: JBASE=JBASE+JUMP
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #800]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1174: 650 CONTINUE
    ldrsw x10, [x29, #808]
    ldr x9, [x29, #1632]
    add x10, x10, x9
    str x10, [x29, #808]
    b .Lmd2asm_fft992_rpassf_do_190
.Lmd2asm_fft992_rpassf_do_done_191:
// Original source line 1175: ENDIF
.Lmd2asm_fft992_rpassf_if_false_188:
.Lmd2asm_fft992_rpassf_if_end_189:
// Original source line 1177: IF (IC.EQ.ID) THEN
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #688]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_196
// Original source line 1178: IBASE=0
    mov x9, #0
    str w9, [x29, #672]
// Original source line 1179: DO 680 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1672]
    mov x9, #1
    str x9, [x29, #1680]
.Lmd2asm_fft992_rpassf_do_198:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1672]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_199
// Original source line 1180: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1181: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 1184: DO 670 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1688]
    mov x10, #1
    str x10, [x29, #1696]
.Lmd2asm_fft992_rpassf_do_200:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1688]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_201
// Original source line 1185: C(JA+J)=A(IB+I)+(A(IA+I)+A(IC+I))
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1186: C(JD+J)=B(IB+I)-(B(IA+I)+B(IC+I))
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1187: C(JB+J)=(SIN60*(A(IA+I)-A(IC+I)))-(0.5_JPRB*(B(IA+I)+B(IC+I))+B(IB+I))
    ldr d0, [x29, #416]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1189: C(JF+J)=-(SIN60*(A(IA+I)-A(IC+I)))-(0.5_JPRB*(B(IA+I)+B(IC+I))+B(IB+I))
    ldr d0, [x29, #416]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #768]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1191: C(JC+J)=SIN60*(B(IC+I)-B(IA+I))+(0.5_JPRB*(A(IA+I)+A(IC+I))-A(IB+I))
    ldr d0, [x29, #416]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1193: C(JE+J)=SIN60*(B(IC+I)-B(IA+I))-(0.5_JPRB*(A(IA+I)+A(IC+I))-A(IB+I))
    ldr d0, [x29, #416]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1195: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1196: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 1197: 670 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1696]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_200
.Lmd2asm_fft992_rpassf_do_done_201:
// Original source line 1198: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1199: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1200: 680 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1680]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_198
.Lmd2asm_fft992_rpassf_do_done_199:
// Original source line 1201: ENDIF
.Lmd2asm_fft992_rpassf_if_false_196:
.Lmd2asm_fft992_rpassf_if_end_197:
// Original source line 1203: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_183
.Lmd2asm_fft992_rpassf_if_false_182:
// Original source line 1204: SSIN60=2.0_JPRB*SIN60
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldr d1, [x29, #416]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #448]
// Original source line 1205: IF (LIPL) THEN
    ldrsw x9, [x29, #880]
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_202
// Original source line 1206: DO 694 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1704]
    mov x9, #1
    str x9, [x29, #1712]
.Lmd2asm_fft992_rpassf_do_204:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1704]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_205
// Original source line 1207: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1209: DO 692 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1720]
    mov x10, #1
    str x10, [x29, #1728]
.Lmd2asm_fft992_rpassf_do_206:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1720]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_207
// Original source line 1210: T1=(2.0_JPRB*(A(IA+I)-A(ID+I))+(A(IB+I)-A(IC+I)))-(SSIN60*(B(IB+I)+B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #480]
// Original source line 1212: T5=(2.0_JPRB*(A(IA+I)-A(ID+I))+(A(IB+I)-A(IC+I)))+(SSIN60*(B(IB+I)+B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #512]
// Original source line 1214: T2=(2.0_JPRB*(A(IA+I)+A(ID+I))-(A(IB+I)+A(IC+I)))-(SSIN60*(B(IB+I)-B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #488]
// Original source line 1216: T4=(2.0_JPRB*(A(IA+I)+A(ID+I))-(A(IB+I)+A(IC+I)))+(SSIN60*(B(IB+I)-B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #504]
// Original source line 1218: T3=(2.0_JPRB*(A(IA+I)-A(ID+I)))-(2.0_JPRB*(A(IB+I)-A(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_6
    ldr d1, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #496]
// Original source line 1219: A(IA+I)=(2.0_JPRB*(A(IA+I)+A(ID+I)))+(2.0_JPRB*(A(IB+I)+A(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_6
    ldr d1, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1221: A(IB+I)=T1
    ldr d0, [x29, #480]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1222: B(IB+I)=T2
    ldr d0, [x29, #488]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1223: A(IC+I)=T3
    ldr d0, [x29, #496]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1224: B(IC+I)=T4
    ldr d0, [x29, #504]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1225: A(ID+I)=T5
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1226: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1227: 692 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1728]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_206
.Lmd2asm_fft992_rpassf_do_done_207:
// Original source line 1228: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1229: 694 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1712]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_204
.Lmd2asm_fft992_rpassf_do_done_205:
// Original source line 1230: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_203
.Lmd2asm_fft992_rpassf_if_false_202:
// Original source line 1231: DO 698 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1736]
    mov x9, #1
    str x9, [x29, #1744]
.Lmd2asm_fft992_rpassf_do_208:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1736]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_209
// Original source line 1232: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1233: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 1236: DO 696 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1752]
    mov x10, #1
    str x10, [x29, #1760]
.Lmd2asm_fft992_rpassf_do_210:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1752]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_211
// Original source line 1237: C(JA+J)=(2.0_JPRB*(A(IA+I)+A(ID+I)))+(2.0_JPRB*(A(IB+I)+A(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_6
    ldr d1, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1239: C(JD+J)=(2.0_JPRB*(A(IA+I)-A(ID+I)))-(2.0_JPRB*(A(IB+I)-A(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    adrp x16, .Lfft_constant_6
    ldr d1, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1241: C(JB+J)=(2.0_JPRB*(A(IA+I)-A(ID+I))+(A(IB+I)-A(IC+I)))-(SSIN60*(B(IB+I)+B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1243: C(JF+J)=(2.0_JPRB*(A(IA+I)-A(ID+I))+(A(IB+I)-A(IC+I)))+(SSIN60*(B(IB+I)+B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #768]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1245: C(JC+J)=(2.0_JPRB*(A(IA+I)+A(ID+I))-(A(IB+I)+A(IC+I)))-(SSIN60*(B(IB+I)-B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1247: C(JE+J)=(2.0_JPRB*(A(IA+I)+A(ID+I))-(A(IB+I)+A(IC+I)))+(SSIN60*(B(IB+I)-B(IC+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1249: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1250: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 1251: 696 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1760]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_210
.Lmd2asm_fft992_rpassf_do_done_211:
// Original source line 1252: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1253: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1254: 698 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1744]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_208
.Lmd2asm_fft992_rpassf_do_done_209:
// Original source line 1255: ENDIF
.Lmd2asm_fft992_rpassf_if_end_203:
// Original source line 1256: ENDIF
.Lmd2asm_fft992_rpassf_if_end_183:
// Original source line 1258: ELSEIF (IFAC.EQ.8) THEN
    b .Lmd2asm_fft992_rpassf_if_end_57
.Lmd2asm_fft992_rpassf_elseif_false_181:
    ldrsw x9, [x29, #584]
    mov x10, #8
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_rpassf_elseif_false_212
// Original source line 1262: 800 CONTINUE
// Original source line 1263: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #592]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_213
// Original source line 1264: IBAD=3
    mov x9, #3
    str w9, [x29, #664]
// Original source line 1265: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_214
.Lmd2asm_fft992_rpassf_if_false_213:
// Original source line 1266: IA=1
    mov x9, #1
    str w9, [x29, #648]
// Original source line 1267: IB=IA+LA*INC1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #592]
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #656]
// Original source line 1268: IC=IB+2*LA*INC1
    ldrsw x9, [x29, #656]
    mov x10, #2
    ldrsw x11, [x29, #592]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #680]
// Original source line 1269: ID=IC+2*LA*INC1
    ldrsw x9, [x29, #680]
    mov x10, #2
    ldrsw x11, [x29, #592]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #688]
// Original source line 1270: IE=ID+2*LA*INC1
    ldrsw x9, [x29, #688]
    mov x10, #2
    ldrsw x11, [x29, #592]
    mul x10, x10, x11
    ldrsw x11, [x29, #544]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #696]
// Original source line 1271: JA=1
    mov x9, #1
    str w9, [x29, #720]
// Original source line 1272: JB=JA+JINK
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #728]
// Original source line 1273: JC=JB+JINK
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1274: JD=JC+JINK
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #752]
// Original source line 1275: JE=JD+JINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 1276: JF=JE+JINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #768]
// Original source line 1277: JG=JF+JINK
    ldrsw x9, [x29, #768]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1278: JH=JG+JINK
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #792]
    add x9, x9, x10
    str w9, [x29, #784]
// Original source line 1279: SSIN45=SQRT(2.0_JPRB)
    adrp x16, .Lfft_constant_9
    ldr d0, [x16, :lo12:.Lfft_constant_9]
    str d0, [x29, #440]
// Original source line 1281: IF (LIPL) THEN
    ldrsw x9, [x29, #880]
    cbz x9, .Lmd2asm_fft992_rpassf_if_false_215
// Original source line 1282: DO 820 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1768]
    mov x9, #1
    str x9, [x29, #1776]
.Lmd2asm_fft992_rpassf_do_217:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1768]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_218
// Original source line 1283: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1285: DO 810 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1784]
    mov x10, #1
    str x10, [x29, #1792]
.Lmd2asm_fft992_rpassf_do_219:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1784]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_220
// Original source line 1286: T2=2.0_JPRB*(((A(IA+I)+A(IE+I))-A(IC+I))-(B(IB+I)-B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #488]
// Original source line 1287: T6=2.0_JPRB*(((A(IA+I)+A(IE+I))-A(IC+I))+(B(IB+I)-B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #520]
// Original source line 1288: T1=2.0_JPRB*((A(IA+I)-A(IE+I))-B(IC+I))+SSIN45*((A(IB+I)-A(ID+I))-(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #480]
// Original source line 1290: T5=2.0_JPRB*((A(IA+I)-A(IE+I))-B(IC+I))-SSIN45*((A(IB+I)-A(ID+I))-(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #512]
// Original source line 1292: T3=2.0_JPRB*((A(IA+I)-A(IE+I))+B(IC+I))-SSIN45*((A(IB+I)-A(ID+I))+(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #496]
// Original source line 1294: T7=2.0_JPRB*((A(IA+I)-A(IE+I))+B(IC+I))+SSIN45*((A(IB+I)-A(ID+I))+(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #528]
// Original source line 1296: T4=2.0_JPRB*(((A(IA+I)+A(IE+I))+A(IC+I))-(A(IB+I)+A(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #504]
// Original source line 1297: A(IA+I)=2.0_JPRB*(((A(IA+I)+A(IE+I))+A(IC+I))+(A(IB+I)+A(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1298: A(IB+I)=T1
    ldr d0, [x29, #480]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1299: B(IB+I)=T2
    ldr d0, [x29, #488]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1300: A(IC+I)=T3
    ldr d0, [x29, #496]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1301: B(IC+I)=T4
    ldr d0, [x29, #504]
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1302: A(ID+I)=T5
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1303: B(ID+I)=T6
    ldr d0, [x29, #520]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1304: A(IE+I)=T7
    ldr d0, [x29, #528]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1305: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1306: 810 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1792]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_219
.Lmd2asm_fft992_rpassf_do_done_220:
// Original source line 1307: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1308: 820 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1776]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_217
.Lmd2asm_fft992_rpassf_do_done_218:
// Original source line 1309: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_216
.Lmd2asm_fft992_rpassf_if_false_215:
// Original source line 1310: DO 840 L=1,ILA
    mov x9, #1
    str w9, [x29, #864]
    ldrsw x9, [x29, #632]
    str x9, [x29, #1800]
    mov x9, #1
    str x9, [x29, #1808]
.Lmd2asm_fft992_rpassf_do_221:
    ldrsw x9, [x29, #864]
    ldr x10, [x29, #1800]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_rpassf_do_done_222
// Original source line 1311: I=IBASE
    ldrsw x10, [x29, #672]
    str w10, [x29, #640]
// Original source line 1312: J=JBASE
    ldrsw x10, [x29, #736]
    str w10, [x29, #712]
// Original source line 1315: DO 830 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #616]
    ldrsw x10, [x29, #624]
    str x10, [x29, #1816]
    mov x10, #1
    str x10, [x29, #1824]
.Lmd2asm_fft992_rpassf_do_223:
    ldrsw x10, [x29, #616]
    ldr x9, [x29, #1816]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_rpassf_do_done_224
// Original source line 1316: C(JA+J)=2.0_JPRB*(((A(IA+I)+A(IE+I))+A(IC+I))+(A(IB+I)+A(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #720]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1317: C(JE+J)=2.0_JPRB*(((A(IA+I)+A(IE+I))+A(IC+I))-(A(IB+I)+A(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1318: C(JC+J)=2.0_JPRB*(((A(IA+I)+A(IE+I))-A(IC+I))-(B(IB+I)-B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1319: C(JG+J)=2.0_JPRB*(((A(IA+I)+A(IE+I))-A(IC+I))+(B(IB+I)-B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1320: C(JB+J)=2.0_JPRB*((A(IA+I)-A(IE+I))-B(IC+I))+SSIN45*((A(IB+I)-A(ID+I))-(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #728]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1322: C(JF+J)=2.0_JPRB*((A(IA+I)-A(IE+I))-B(IC+I))-SSIN45*((A(IB+I)-A(ID+I))-(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #768]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1324: C(JD+J)=2.0_JPRB*((A(IA+I)-A(IE+I))+B(IC+I))-SSIN45*((A(IB+I)-A(ID+I))+(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1326: C(JH+J)=2.0_JPRB*((A(IA+I)-A(IE+I))+B(IC+I))+SSIN45*((A(IB+I)-A(ID+I))+(B(IB+I)+B(ID+I)))
    adrp x16, .Lfft_constant_6
    ldr d0, [x16, :lo12:.Lfft_constant_6]
    ldrsw x9, [x29, #648]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #696]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #680]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #656]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #688]
    ldrsw x10, [x29, #640]
    add x9, x9, x10
    ldr x16, [x29, #136]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #712]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1328: I=I+INC3
    ldrsw x9, [x29, #640]
    ldrsw x10, [x29, #560]
    add x9, x9, x10
    str w9, [x29, #640]
// Original source line 1329: J=J+INC4
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #568]
    add x9, x9, x10
    str w9, [x29, #712]
// Original source line 1330: 830 CONTINUE
    ldrsw x9, [x29, #616]
    ldr x10, [x29, #1824]
    add x9, x9, x10
    str x9, [x29, #616]
    b .Lmd2asm_fft992_rpassf_do_223
.Lmd2asm_fft992_rpassf_do_done_224:
// Original source line 1331: IBASE=IBASE+INC1
    ldrsw x10, [x29, #672]
    ldrsw x9, [x29, #544]
    add x10, x10, x9
    str w10, [x29, #672]
// Original source line 1332: JBASE=JBASE+INC21
    ldrsw x10, [x29, #736]
    ldrsw x9, [x29, #600]
    add x10, x10, x9
    str w10, [x29, #736]
// Original source line 1333: 840 CONTINUE
    ldrsw x10, [x29, #864]
    ldr x9, [x29, #1808]
    add x10, x10, x9
    str x10, [x29, #864]
    b .Lmd2asm_fft992_rpassf_do_221
.Lmd2asm_fft992_rpassf_do_done_222:
// Original source line 1334: ENDIF
.Lmd2asm_fft992_rpassf_if_end_216:
// Original source line 1336: ENDIF
.Lmd2asm_fft992_rpassf_if_end_214:
// Original source line 1338: ELSE
    b .Lmd2asm_fft992_rpassf_if_end_57
.Lmd2asm_fft992_rpassf_elseif_false_212:
// Original source line 1340: IBAD=2
    mov x9, #2
    str w9, [x29, #664]
// Original source line 1342: ENDIF
.Lmd2asm_fft992_rpassf_if_end_57:
// Original source line 1346: 900 CONTINUE
// Original source line 1347: IERR=IBAD
    ldrsw x9, [x29, #664]
    str w9, [x29, #536]
    ldr x16, [x29, #232]
    str w9, [x16]
.Lmd2asm_fft992_rpassf_return_53:
    mov sp, x29
    ldr x18, [sp, #16]
    ldp x29, x30, [sp]
    add sp, sp, #2048
    ret
.size md2asm_fft992_rpassf, .-md2asm_fft992_rpassf
.p2align 4
.global md2asm_fft992_qpassf
.type md2asm_fft992_qpassf, %function
md2asm_fft992_qpassf:
    sub sp, sp, #2048
    stp x29, x30, [sp]
    str x18, [sp, #16]
    mov x29, sp
    str x0, [x29, #128]
    str x1, [x29, #136]
    str x2, [x29, #144]
    str x3, [x29, #152]
    str x4, [x29, #160]
    str x5, [x29, #168]
    str x6, [x29, #176]
    str x7, [x29, #184]
    ldr x9, [x29, #2048]
    str x9, [x29, #192]
    ldr x9, [x29, #2056]
    str x9, [x29, #200]
    ldr x9, [x29, #2064]
    str x9, [x29, #208]
    ldr x9, [x29, #2072]
    str x9, [x29, #216]
    ldr x9, [x29, #2080]
    str x9, [x29, #224]
    ldr x9, [x29, #2088]
    str x9, [x29, #232]
    ldr x9, [x29, #2096]
    str x9, [x29, #240]
    ldr x9, [x29, #168]
    ldrsw x9, [x9]
    str x9, [x29, #664]
    ldr x9, [x29, #176]
    ldrsw x9, [x9]
    str x9, [x29, #672]
    ldr x9, [x29, #184]
    ldrsw x9, [x9]
    str x9, [x29, #680]
    ldr x9, [x29, #192]
    ldrsw x9, [x9]
    str x9, [x29, #688]
    ldr x9, [x29, #200]
    ldrsw x9, [x9]
    str x9, [x29, #696]
    ldr x9, [x29, #208]
    ldrsw x9, [x9]
    str x9, [x29, #248]
    ldr x9, [x29, #216]
    ldrsw x9, [x9]
    str x9, [x29, #704]
    ldr x9, [x29, #224]
    ldrsw x9, [x9]
    str x9, [x29, #712]
    ldr x9, [x29, #232]
    ldrsw x9, [x9]
    str x9, [x29, #656]
    ldr x9, [x29, #240]
    ldrsw x9, [x9]
    str x9, [x29, #1000]
    adrp x16, md2asm_fft992_qpassf_calls
    add x16, x16, :lo12:md2asm_fft992_qpassf_calls
    ldr x9, [x16]
    add x9, x9, #1
    str x9, [x16]
    adrp x16, .Lfft_constant_2
    ldr d0, [x16, :lo12:.Lfft_constant_2]
    str d0, [x29, #584]
    adrp x16, .Lfft_constant_3
    ldr d0, [x16, :lo12:.Lfft_constant_3]
    str d0, [x29, #608]
    adrp x16, .Lfft_constant_4
    ldr d0, [x16, :lo12:.Lfft_constant_4]
    str d0, [x29, #576]
    adrp x16, .Lfft_constant_5
    ldr d0, [x16, :lo12:.Lfft_constant_5]
    str d0, [x29, #600]
// Original source line 1418: M=N/IFAC
    ldrsw x9, [x29, #248]
    ldrsw x10, [x29, #704]
    sdiv x9, x9, x10
    str w9, [x29, #992]
// Original source line 1419: IINK=LA*INC1
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #664]
    mul x9, x9, x10
    str w9, [x29, #720]
// Original source line 1420: JINK=LA*INC2
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #672]
    mul x9, x9, x10
    str w9, [x29, #920]
// Original source line 1421: IJUMP=(IFAC-1)*IINK
    ldrsw x9, [x29, #704]
    mov x10, #1
    sub x9, x9, x10
    ldrsw x10, [x29, #720]
    mul x9, x9, x10
    str w9, [x29, #832]
// Original source line 1422: KSTOP=(N-IFAC)/(2*IFAC)
    ldrsw x9, [x29, #248]
    ldrsw x10, [x29, #704]
    sub x9, x9, x10
    mov x10, #2
    ldrsw x11, [x29, #704]
    mul x10, x10, x11
    sdiv x9, x9, x10
    str w9, [x29, #976]
// Original source line 1424: IBASE=0
    mov x9, #0
    str w9, [x29, #776]
// Original source line 1425: JBASE=0
    mov x9, #0
    str w9, [x29, #904]
// Original source line 1426: IBAD=0
    mov x9, #0
    str w9, [x29, #768]
// Original source line 1430: IF (INC1.EQ.LOT.AND.INC2.EQ.LOT.AND.INC3.EQ.1.AND.INC4.EQ.1) THEN
    ldrsw x9, [x29, #664]
    ldrsw x10, [x29, #696]
    cmp x9, x10
    cset x9, eq
    ldrsw x10, [x29, #672]
    ldrsw x11, [x29, #696]
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    ldrsw x10, [x29, #680]
    mov x11, #1
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    ldrsw x10, [x29, #688]
    mov x11, #1
    cmp x10, x11
    cset x10, eq
    and x9, x9, x10
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_226
// Original source line 1431: ILA=1
    mov x9, #1
    str w9, [x29, #840]
// Original source line 1432: ILOT=LA*LOT
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #696]
    mul x9, x9, x10
    str w9, [x29, #736]
// Original source line 1433: INC11=LA*LOT
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #696]
    mul x9, x9, x10
    str w9, [x29, #848]
// Original source line 1434: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_227
.Lmd2asm_fft992_qpassf_if_false_226:
// Original source line 1435: ILA=LA
    ldrsw x9, [x29, #712]
    str w9, [x29, #840]
// Original source line 1436: ILOT=LOT
    ldrsw x9, [x29, #696]
    str w9, [x29, #736]
// Original source line 1437: INC11=INC1
    ldrsw x9, [x29, #664]
    str w9, [x29, #848]
// Original source line 1438: ENDIF
.Lmd2asm_fft992_qpassf_if_end_227:
// Original source line 1441: IF (IFAC.EQ.2) THEN
    ldrsw x9, [x29, #704]
    mov x10, #2
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_228
// Original source line 1445: 200 CONTINUE
// Original source line 1446: IA=1
    mov x9, #1
    str w9, [x29, #752]
// Original source line 1447: IB=IA+IINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 1448: JA=1
    mov x9, #1
    str w9, [x29, #864]
// Original source line 1449: JB=JA+(2*M-LA)*INC2
    ldrsw x9, [x29, #864]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #712]
    sub x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1451: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #992]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_230
// Original source line 1453: DO 220 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1008]
    mov x9, #1
    str x9, [x29, #1016]
.Lmd2asm_fft992_qpassf_do_232:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1008]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_233
// Original source line 1454: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1455: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1458: DO 210 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1024]
    mov x10, #1
    str x10, [x29, #1032]
.Lmd2asm_fft992_qpassf_do_234:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1024]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_235
// Original source line 1459: C(JA+J)=A(IA+I)+A(IB+I)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1460: C(JB+J)=A(IA+I)-A(IB+I)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1461: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1462: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1463: 210 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1032]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_234
.Lmd2asm_fft992_qpassf_do_done_235:
// Original source line 1464: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1465: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1466: 220 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1016]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_232
.Lmd2asm_fft992_qpassf_do_done_233:
// Original source line 1467: JA=JA+JINK
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #864]
// Original source line 1468: JINK=2*JINK
    mov x9, #2
    ldrsw x10, [x29, #920]
    mul x9, x9, x10
    str w9, [x29, #920]
// Original source line 1469: JB=JB-JINK
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #872]
// Original source line 1470: IBASE=IBASE+IJUMP
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #832]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1471: IJUMP=2*IJUMP+IINK
    mov x9, #2
    ldrsw x10, [x29, #832]
    mul x9, x9, x10
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #832]
// Original source line 1473: IF (JA.LT.JB) THEN
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_236
// Original source line 1474: DO 250 K=LA,KSTOP,LA
    ldrsw x9, [x29, #712]
    str w9, [x29, #928]
    ldrsw x9, [x29, #976]
    str x9, [x29, #1040]
    ldrsw x9, [x29, #712]
    str x9, [x29, #1048]
.Lmd2asm_fft992_qpassf_do_238:
    ldrsw x9, [x29, #928]
    ldr x10, [x29, #1040]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_239
// Original source line 1475: KB=K+K
    ldrsw x10, [x29, #928]
    ldrsw x9, [x29, #928]
    add x10, x10, x9
    str w10, [x29, #936]
// Original source line 1476: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #936]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #432]
// Original source line 1477: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #936]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #472]
// Original source line 1478: JBASE=0
    mov x10, #0
    str w10, [x29, #904]
// Original source line 1479: DO 240 L=1,ILA
    mov x10, #1
    str w10, [x29, #984]
    ldrsw x10, [x29, #840]
    str x10, [x29, #1056]
    mov x10, #1
    str x10, [x29, #1064]
.Lmd2asm_fft992_qpassf_do_240:
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1056]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_241
// Original source line 1480: I=IBASE
    ldrsw x9, [x29, #776]
    str w9, [x29, #744]
// Original source line 1481: J=JBASE
    ldrsw x9, [x29, #904]
    str w9, [x29, #856]
// Original source line 1484: DO 230 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #728]
    ldrsw x9, [x29, #736]
    str x9, [x29, #1072]
    mov x9, #1
    str x9, [x29, #1080]
.Lmd2asm_fft992_qpassf_do_242:
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1072]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_243
// Original source line 1485: C(JA+J)=A(IA+I)+(C1*A(IB+I)+S1*B(IB+I))
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1486: C(JB+J)=A(IA+I)-(C1*A(IB+I)+S1*B(IB+I))
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1487: D(JA+J)=(C1*B(IB+I)-S1*A(IB+I))+B(IA+I)
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1488: D(JB+J)=(C1*B(IB+I)-S1*A(IB+I))-B(IA+I)
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1489: I=I+INC3
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #680]
    add x10, x10, x9
    str w10, [x29, #744]
// Original source line 1490: J=J+INC4
    ldrsw x10, [x29, #856]
    ldrsw x9, [x29, #688]
    add x10, x10, x9
    str w10, [x29, #856]
// Original source line 1491: 230 CONTINUE
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1080]
    add x10, x10, x9
    str x10, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_242
.Lmd2asm_fft992_qpassf_do_done_243:
// Original source line 1492: IBASE=IBASE+INC11
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #848]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1493: JBASE=JBASE+INC2
    ldrsw x9, [x29, #904]
    ldrsw x10, [x29, #672]
    add x9, x9, x10
    str w9, [x29, #904]
// Original source line 1494: 240 CONTINUE
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1064]
    add x9, x9, x10
    str x9, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_240
.Lmd2asm_fft992_qpassf_do_done_241:
// Original source line 1495: IBASE=IBASE+IJUMP
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #832]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1496: JA=JA+JINK
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #864]
// Original source line 1497: JB=JB-JINK
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #872]
// Original source line 1498: 250 CONTINUE
    ldrsw x10, [x29, #928]
    ldr x9, [x29, #1048]
    add x10, x10, x9
    str x10, [x29, #928]
    b .Lmd2asm_fft992_qpassf_do_238
.Lmd2asm_fft992_qpassf_do_done_239:
// Original source line 1499: ENDIF
.Lmd2asm_fft992_qpassf_if_false_236:
.Lmd2asm_fft992_qpassf_if_end_237:
// Original source line 1501: IF (JA.EQ.JB) THEN
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #872]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_244
// Original source line 1502: JBASE=0
    mov x9, #0
    str w9, [x29, #904]
// Original source line 1503: DO 280 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1088]
    mov x9, #1
    str x9, [x29, #1096]
.Lmd2asm_fft992_qpassf_do_246:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1088]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_247
// Original source line 1504: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1505: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1508: DO 270 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1104]
    mov x10, #1
    str x10, [x29, #1112]
.Lmd2asm_fft992_qpassf_do_248:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1104]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_249
// Original source line 1509: C(JA+J)=A(IA+I)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1510: D(JA+J)=-A(IB+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1511: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1512: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1513: 270 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1112]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_248
.Lmd2asm_fft992_qpassf_do_done_249:
// Original source line 1514: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1515: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1516: 280 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1096]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_246
.Lmd2asm_fft992_qpassf_do_done_247:
// Original source line 1517: ENDIF
.Lmd2asm_fft992_qpassf_if_false_244:
.Lmd2asm_fft992_qpassf_if_end_245:
// Original source line 1519: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_231
.Lmd2asm_fft992_qpassf_if_false_230:
// Original source line 1520: Z=1.0_JPRB/REAL(N,KIND=JPRB)
    adrp x16, .Lfft_constant_10
    ldr d0, [x16, :lo12:.Lfft_constant_10]
    ldrsw x9, [x29, #248]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1, x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x29, #568]
// Original source line 1521: IF (LIPL) THEN
    ldrsw x9, [x29, #1000]
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_250
// Original source line 1522: DO 294 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1120]
    mov x9, #1
    str x9, [x29, #1128]
.Lmd2asm_fft992_qpassf_do_252:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1120]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_253
// Original source line 1523: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1526: DO 292 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1136]
    mov x10, #1
    str x10, [x29, #1144]
.Lmd2asm_fft992_qpassf_do_254:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1136]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_255
// Original source line 1527: T1=Z*(A(IA+I)-A(IB+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #512]
// Original source line 1528: A(IA+I)=Z*(A(IA+I)+A(IB+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1529: A(IB+I)=T1
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1530: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1531: 292 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1144]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_254
.Lmd2asm_fft992_qpassf_do_done_255:
// Original source line 1532: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1533: 294 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1128]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_252
.Lmd2asm_fft992_qpassf_do_done_253:
// Original source line 1534: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_251
.Lmd2asm_fft992_qpassf_if_false_250:
// Original source line 1535: DO 298 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1152]
    mov x9, #1
    str x9, [x29, #1160]
.Lmd2asm_fft992_qpassf_do_256:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1152]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_257
// Original source line 1536: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1537: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1540: DO 296 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1168]
    mov x10, #1
    str x10, [x29, #1176]
.Lmd2asm_fft992_qpassf_do_258:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1168]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_259
// Original source line 1541: C(JA+J)=Z*(A(IA+I)+A(IB+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1542: C(JB+J)=Z*(A(IA+I)-A(IB+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1543: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1544: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1545: 296 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1176]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_258
.Lmd2asm_fft992_qpassf_do_done_259:
// Original source line 1546: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1547: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1548: 298 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1160]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_256
.Lmd2asm_fft992_qpassf_do_done_257:
// Original source line 1549: ENDIF
.Lmd2asm_fft992_qpassf_if_end_251:
// Original source line 1550: ENDIF
.Lmd2asm_fft992_qpassf_if_end_231:
// Original source line 1552: ELSEIF (IFAC.EQ.3) THEN
    b .Lmd2asm_fft992_qpassf_if_end_229
.Lmd2asm_fft992_qpassf_if_false_228:
    ldrsw x9, [x29, #704]
    mov x10, #3
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_elseif_false_260
// Original source line 1556: 300 CONTINUE
// Original source line 1557: IA=1
    mov x9, #1
    str w9, [x29, #752]
// Original source line 1558: IB=IA+IINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 1559: IC=IB+IINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #784]
// Original source line 1560: JA=1
    mov x9, #1
    str w9, [x29, #864]
// Original source line 1561: JB=JA+(2*M-LA)*INC2
    ldrsw x9, [x29, #864]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #712]
    sub x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1562: JC=JB
    ldrsw x9, [x29, #872]
    str w9, [x29, #880]
// Original source line 1564: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #992]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_261
// Original source line 1566: DO 320 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1184]
    mov x9, #1
    str x9, [x29, #1192]
.Lmd2asm_fft992_qpassf_do_263:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1184]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_264
// Original source line 1567: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1568: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1571: DO 310 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1200]
    mov x10, #1
    str x10, [x29, #1208]
.Lmd2asm_fft992_qpassf_do_265:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1200]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_266
// Original source line 1572: C(JA+J)=A(IA+I)+(A(IB+I)+A(IC+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1573: C(JB+J)=A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1574: D(JB+J)=SIN60*(A(IC+I)-A(IB+I))
    ldr d0, [x29, #600]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1575: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1576: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1577: 310 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1208]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_265
.Lmd2asm_fft992_qpassf_do_done_266:
// Original source line 1578: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1579: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1580: 320 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1192]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_263
.Lmd2asm_fft992_qpassf_do_done_264:
// Original source line 1581: JA=JA+JINK
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #864]
// Original source line 1582: JINK=2*JINK
    mov x9, #2
    ldrsw x10, [x29, #920]
    mul x9, x9, x10
    str w9, [x29, #920]
// Original source line 1583: JB=JB+JINK
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1584: JC=JC-JINK
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #880]
// Original source line 1585: IBASE=IBASE+IJUMP
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #832]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1586: IJUMP=2*IJUMP+IINK
    mov x9, #2
    ldrsw x10, [x29, #832]
    mul x9, x9, x10
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #832]
// Original source line 1588: IF (JA.LT.JC) THEN
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #880]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_267
// Original source line 1589: DO 350 K=LA,KSTOP,LA
    ldrsw x9, [x29, #712]
    str w9, [x29, #928]
    ldrsw x9, [x29, #976]
    str x9, [x29, #1216]
    ldrsw x9, [x29, #712]
    str x9, [x29, #1224]
.Lmd2asm_fft992_qpassf_do_269:
    ldrsw x9, [x29, #928]
    ldr x10, [x29, #1216]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_270
// Original source line 1590: KB=K+K
    ldrsw x10, [x29, #928]
    ldrsw x9, [x29, #928]
    add x10, x10, x9
    str w10, [x29, #936]
// Original source line 1591: KC=KB+KB
    ldrsw x10, [x29, #936]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #944]
// Original source line 1592: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #936]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #432]
// Original source line 1593: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #936]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #472]
// Original source line 1594: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #944]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #440]
// Original source line 1595: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #944]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #480]
// Original source line 1596: JBASE=0
    mov x10, #0
    str w10, [x29, #904]
// Original source line 1597: DO 340 L=1,ILA
    mov x10, #1
    str w10, [x29, #984]
    ldrsw x10, [x29, #840]
    str x10, [x29, #1232]
    mov x10, #1
    str x10, [x29, #1240]
.Lmd2asm_fft992_qpassf_do_271:
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1232]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_272
// Original source line 1598: I=IBASE
    ldrsw x9, [x29, #776]
    str w9, [x29, #744]
// Original source line 1599: J=JBASE
    ldrsw x9, [x29, #904]
    str w9, [x29, #856]
// Original source line 1602: DO 330 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #728]
    ldrsw x9, [x29, #736]
    str x9, [x29, #1248]
    mov x9, #1
    str x9, [x29, #1256]
.Lmd2asm_fft992_qpassf_do_273:
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1248]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_274
// Original source line 1603: A1=(C1*A(IB+I)+S1*B(IB+I))+(C2*A(IC+I)+S2*B(IC+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1604: B1=(C1*B(IB+I)-S1*A(IB+I))+(C2*B(IC+I)-S2*A(IC+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #352]
// Original source line 1605: A2=A(IA+I)-0.5_JPRB*A1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #272]
// Original source line 1606: B2=B(IA+I)-0.5_JPRB*B1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #352]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #360]
// Original source line 1607: A3=SIN60*((C1*A(IB+I)+S1*B(IB+I))-(C2*A(IC+I)+S2*B(IC+I)))
    ldr d0, [x29, #600]
    ldr d1, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldr d2, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
    ldr d3, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #280]
// Original source line 1608: B3=SIN60*((C1*B(IB+I)-S1*A(IB+I))-(C2*B(IC+I)-S2*A(IC+I)))
    ldr d0, [x29, #600]
    ldr d1, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
    ldr d3, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d4, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d3,d3,d4 // fmul d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #368]
// Original source line 1609: C(JA+J)=A(IA+I)+A1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1610: D(JA+J)=B(IA+I)+B1
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #352]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1611: C(JB+J)=A2+B3
    ldr d0, [x29, #272]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1612: D(JB+J)=B2-A3
    ldr d0, [x29, #360]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1613: C(JC+J)=A2-B3
    ldr d0, [x29, #272]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1614: D(JC+J)=-(B2+A3)
    ldr d0, [x29, #360]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1615: I=I+INC3
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #680]
    add x10, x10, x9
    str w10, [x29, #744]
// Original source line 1616: J=J+INC4
    ldrsw x10, [x29, #856]
    ldrsw x9, [x29, #688]
    add x10, x10, x9
    str w10, [x29, #856]
// Original source line 1617: 330 CONTINUE
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1256]
    add x10, x10, x9
    str x10, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_273
.Lmd2asm_fft992_qpassf_do_done_274:
// Original source line 1618: IBASE=IBASE+INC11
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #848]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1619: JBASE=JBASE+INC2
    ldrsw x9, [x29, #904]
    ldrsw x10, [x29, #672]
    add x9, x9, x10
    str w9, [x29, #904]
// Original source line 1620: 340 CONTINUE
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1240]
    add x9, x9, x10
    str x9, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_271
.Lmd2asm_fft992_qpassf_do_done_272:
// Original source line 1621: IBASE=IBASE+IJUMP
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #832]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1622: JA=JA+JINK
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #864]
// Original source line 1623: JB=JB+JINK
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #872]
// Original source line 1624: JC=JC-JINK
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #880]
// Original source line 1625: 350 CONTINUE
    ldrsw x10, [x29, #928]
    ldr x9, [x29, #1224]
    add x10, x10, x9
    str x10, [x29, #928]
    b .Lmd2asm_fft992_qpassf_do_269
.Lmd2asm_fft992_qpassf_do_done_270:
// Original source line 1626: ENDIF
.Lmd2asm_fft992_qpassf_if_false_267:
.Lmd2asm_fft992_qpassf_if_end_268:
// Original source line 1628: IF (JA.EQ.JC) THEN
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #880]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_275
// Original source line 1629: JBASE=0
    mov x9, #0
    str w9, [x29, #904]
// Original source line 1630: DO 380 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1264]
    mov x9, #1
    str x9, [x29, #1272]
.Lmd2asm_fft992_qpassf_do_277:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1264]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_278
// Original source line 1631: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1632: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1635: DO 370 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1280]
    mov x10, #1
    str x10, [x29, #1288]
.Lmd2asm_fft992_qpassf_do_279:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1280]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_280
// Original source line 1636: C(JA+J)=A(IA+I)+0.5_JPRB*(A(IB+I)-A(IC+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1637: D(JA+J)=-SIN60*(A(IB+I)+A(IC+I))
    ldr d0, [x29, #600]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1638: C(JB+J)=A(IA+I)-(A(IB+I)-A(IC+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1639: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1640: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1641: 370 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1288]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_279
.Lmd2asm_fft992_qpassf_do_done_280:
// Original source line 1642: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1643: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1644: 380 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1272]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_277
.Lmd2asm_fft992_qpassf_do_done_278:
// Original source line 1645: ENDIF
.Lmd2asm_fft992_qpassf_if_false_275:
.Lmd2asm_fft992_qpassf_if_end_276:
// Original source line 1647: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_262
.Lmd2asm_fft992_qpassf_if_false_261:
// Original source line 1648: Z=1.0_JPRB/REAL(N,KIND=JPRB)
    adrp x16, .Lfft_constant_10
    ldr d0, [x16, :lo12:.Lfft_constant_10]
    ldrsw x9, [x29, #248]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1, x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x29, #568]
// Original source line 1649: ZSIN60=Z*SIN60
    ldr d0, [x29, #568]
    ldr d1, [x29, #600]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #640]
// Original source line 1650: IF (LIPL) THEN
    ldrsw x9, [x29, #1000]
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_281
// Original source line 1651: DO 394 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1296]
    mov x9, #1
    str x9, [x29, #1304]
.Lmd2asm_fft992_qpassf_do_283:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1296]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_284
// Original source line 1652: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1655: DO 392 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1312]
    mov x10, #1
    str x10, [x29, #1320]
.Lmd2asm_fft992_qpassf_do_285:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1312]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_286
// Original source line 1656: T1=Z*(A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #512]
// Original source line 1657: T2=ZSIN60*(A(IC+I)-A(IB+I))
    ldr d0, [x29, #640]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #520]
// Original source line 1658: A(IA+I)=Z*(A(IA+I)+(A(IB+I)+A(IC+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1659: A(IB+I)=T1
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1660: A(IC+I)=T2
    ldr d0, [x29, #520]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1661: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1662: 392 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1320]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_285
.Lmd2asm_fft992_qpassf_do_done_286:
// Original source line 1663: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1664: 394 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1304]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_283
.Lmd2asm_fft992_qpassf_do_done_284:
// Original source line 1665: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_282
.Lmd2asm_fft992_qpassf_if_false_281:
// Original source line 1666: DO 398 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1328]
    mov x9, #1
    str x9, [x29, #1336]
.Lmd2asm_fft992_qpassf_do_287:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1328]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_288
// Original source line 1667: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1668: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1671: DO 396 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1344]
    mov x10, #1
    str x10, [x29, #1352]
.Lmd2asm_fft992_qpassf_do_289:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1344]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_290
// Original source line 1672: C(JA+J)=Z*(A(IA+I)+(A(IB+I)+A(IC+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1673: C(JB+J)=Z*(A(IA+I)-0.5_JPRB*(A(IB+I)+A(IC+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1674: D(JB+J)=ZSIN60*(A(IC+I)-A(IB+I))
    ldr d0, [x29, #640]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1675: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1676: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1677: 396 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1352]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_289
.Lmd2asm_fft992_qpassf_do_done_290:
// Original source line 1678: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1679: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1680: 398 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1336]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_287
.Lmd2asm_fft992_qpassf_do_done_288:
// Original source line 1681: ENDIF
.Lmd2asm_fft992_qpassf_if_end_282:
// Original source line 1682: ENDIF
.Lmd2asm_fft992_qpassf_if_end_262:
// Original source line 1684: ELSEIF (IFAC.EQ.4) THEN
    b .Lmd2asm_fft992_qpassf_if_end_229
.Lmd2asm_fft992_qpassf_elseif_false_260:
    ldrsw x9, [x29, #704]
    mov x10, #4
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_elseif_false_291
// Original source line 1688: 400 CONTINUE
// Original source line 1689: IA=1
    mov x9, #1
    str w9, [x29, #752]
// Original source line 1690: IB=IA+IINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 1691: IC=IB+IINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #784]
// Original source line 1692: ID=IC+IINK
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #792]
// Original source line 1693: JA=1
    mov x9, #1
    str w9, [x29, #864]
// Original source line 1694: JB=JA+(2*M-LA)*INC2
    ldrsw x9, [x29, #864]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #712]
    sub x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1695: JC=JB+2*M*INC2
    ldrsw x9, [x29, #872]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #880]
// Original source line 1696: JD=JB
    ldrsw x9, [x29, #872]
    str w9, [x29, #888]
// Original source line 1698: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #992]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_292
// Original source line 1700: DO 420 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1360]
    mov x9, #1
    str x9, [x29, #1368]
.Lmd2asm_fft992_qpassf_do_294:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1360]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_295
// Original source line 1701: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1702: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1705: DO 410 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1376]
    mov x10, #1
    str x10, [x29, #1384]
.Lmd2asm_fft992_qpassf_do_296:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1376]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_297
// Original source line 1706: C(JA+J)=(A(IA+I)+A(IC+I))+(A(IB+I)+A(ID+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1707: C(JC+J)=(A(IA+I)+A(IC+I))-(A(IB+I)+A(ID+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1708: C(JB+J)=A(IA+I)-A(IC+I)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1709: D(JB+J)=A(ID+I)-A(IB+I)
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1710: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1711: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1712: 410 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1384]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_296
.Lmd2asm_fft992_qpassf_do_done_297:
// Original source line 1713: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1714: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1715: 420 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1368]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_294
.Lmd2asm_fft992_qpassf_do_done_295:
// Original source line 1716: JA=JA+JINK
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #864]
// Original source line 1717: JINK=2*JINK
    mov x9, #2
    ldrsw x10, [x29, #920]
    mul x9, x9, x10
    str w9, [x29, #920]
// Original source line 1718: JB=JB+JINK
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1719: JC=JC-JINK
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #880]
// Original source line 1720: JD=JD-JINK
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #888]
// Original source line 1721: IBASE=IBASE+IJUMP
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #832]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1722: IJUMP=2*IJUMP+IINK
    mov x9, #2
    ldrsw x10, [x29, #832]
    mul x9, x9, x10
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #832]
// Original source line 1724: IF (JB.LT.JC) THEN
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #880]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_298
// Original source line 1725: DO 450 K=LA,KSTOP,LA
    ldrsw x9, [x29, #712]
    str w9, [x29, #928]
    ldrsw x9, [x29, #976]
    str x9, [x29, #1392]
    ldrsw x9, [x29, #712]
    str x9, [x29, #1400]
.Lmd2asm_fft992_qpassf_do_300:
    ldrsw x9, [x29, #928]
    ldr x10, [x29, #1392]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_301
// Original source line 1726: KB=K+K
    ldrsw x10, [x29, #928]
    ldrsw x9, [x29, #928]
    add x10, x10, x9
    str w10, [x29, #936]
// Original source line 1727: KC=KB+KB
    ldrsw x10, [x29, #936]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #944]
// Original source line 1728: KD=KC+KB
    ldrsw x10, [x29, #944]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #952]
// Original source line 1729: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #936]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #432]
// Original source line 1730: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #936]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #472]
// Original source line 1731: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #944]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #440]
// Original source line 1732: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #944]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #480]
// Original source line 1733: C3=TRIGS(KD+1)
    ldrsw x10, [x29, #952]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #448]
// Original source line 1734: S3=TRIGS(KD+2)
    ldrsw x10, [x29, #952]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #488]
// Original source line 1735: JBASE=0
    mov x10, #0
    str w10, [x29, #904]
// Original source line 1736: DO 440 L=1,ILA
    mov x10, #1
    str w10, [x29, #984]
    ldrsw x10, [x29, #840]
    str x10, [x29, #1408]
    mov x10, #1
    str x10, [x29, #1416]
.Lmd2asm_fft992_qpassf_do_302:
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1408]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_303
// Original source line 1737: I=IBASE
    ldrsw x9, [x29, #776]
    str w9, [x29, #744]
// Original source line 1738: J=JBASE
    ldrsw x9, [x29, #904]
    str w9, [x29, #856]
// Original source line 1741: DO 430 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #728]
    ldrsw x9, [x29, #736]
    str x9, [x29, #1424]
    mov x9, #1
    str x9, [x29, #1432]
.Lmd2asm_fft992_qpassf_do_304:
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1424]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_305
// Original source line 1742: A0=A(IA+I)+(C2*A(IC+I)+S2*B(IC+I))
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #256]
// Original source line 1743: A2=A(IA+I)-(C2*A(IC+I)+S2*B(IC+I))
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #272]
// Original source line 1744: A1=(C1*A(IB+I)+S1*B(IB+I))+(C3*A(ID+I)+S3*B(ID+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1745: A3=(C1*A(IB+I)+S1*B(IB+I))-(C3*A(ID+I)+S3*B(ID+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 1746: B0=B(IA+I)+(C2*B(IC+I)-S2*A(IC+I))
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #344]
// Original source line 1747: B2=B(IA+I)-(C2*B(IC+I)-S2*A(IC+I))
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #360]
// Original source line 1748: B1=(C1*B(IB+I)-S1*A(IB+I))+(C3*B(ID+I)-S3*A(ID+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #352]
// Original source line 1749: B3=(C1*B(IB+I)-S1*A(IB+I))-(C3*B(ID+I)-S3*A(ID+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #368]
// Original source line 1750: C(JA+J)=A0+A1
    ldr d0, [x29, #256]
    ldr d1, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1751: C(JC+J)=A0-A1
    ldr d0, [x29, #256]
    ldr d1, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1752: D(JA+J)=B0+B1
    ldr d0, [x29, #344]
    ldr d1, [x29, #352]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1753: D(JC+J)=B1-B0
    ldr d0, [x29, #352]
    ldr d1, [x29, #344]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1754: C(JB+J)=A2+B3
    ldr d0, [x29, #272]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1755: C(JD+J)=A2-B3
    ldr d0, [x29, #272]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1756: D(JB+J)=B2-A3
    ldr d0, [x29, #360]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1757: D(JD+J)=-(B2+A3)
    ldr d0, [x29, #360]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1758: I=I+INC3
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #680]
    add x10, x10, x9
    str w10, [x29, #744]
// Original source line 1759: J=J+INC4
    ldrsw x10, [x29, #856]
    ldrsw x9, [x29, #688]
    add x10, x10, x9
    str w10, [x29, #856]
// Original source line 1760: 430 CONTINUE
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1432]
    add x10, x10, x9
    str x10, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_304
.Lmd2asm_fft992_qpassf_do_done_305:
// Original source line 1761: IBASE=IBASE+INC11
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #848]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1762: JBASE=JBASE+INC2
    ldrsw x9, [x29, #904]
    ldrsw x10, [x29, #672]
    add x9, x9, x10
    str w9, [x29, #904]
// Original source line 1763: 440 CONTINUE
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1416]
    add x9, x9, x10
    str x9, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_302
.Lmd2asm_fft992_qpassf_do_done_303:
// Original source line 1764: IBASE=IBASE+IJUMP
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #832]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1765: JA=JA+JINK
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #864]
// Original source line 1766: JB=JB+JINK
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #872]
// Original source line 1767: JC=JC-JINK
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #880]
// Original source line 1768: JD=JD-JINK
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #888]
// Original source line 1769: 450 CONTINUE
    ldrsw x10, [x29, #928]
    ldr x9, [x29, #1400]
    add x10, x10, x9
    str x10, [x29, #928]
    b .Lmd2asm_fft992_qpassf_do_300
.Lmd2asm_fft992_qpassf_do_done_301:
// Original source line 1770: ENDIF
.Lmd2asm_fft992_qpassf_if_false_298:
.Lmd2asm_fft992_qpassf_if_end_299:
// Original source line 1772: IF (JB.EQ.JC) THEN
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #880]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_306
// Original source line 1773: SIN45=SQRT(0.5_JPRB)
    adrp x16, .Lfft_constant_7
    ldr d0, [x16, :lo12:.Lfft_constant_7]
    str d0, [x29, #592]
// Original source line 1774: JBASE=0
    mov x9, #0
    str w9, [x29, #904]
// Original source line 1775: DO 480 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1440]
    mov x9, #1
    str x9, [x29, #1448]
.Lmd2asm_fft992_qpassf_do_308:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1440]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_309
// Original source line 1776: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1777: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1780: DO 470 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1456]
    mov x10, #1
    str x10, [x29, #1464]
.Lmd2asm_fft992_qpassf_do_310:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1456]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_311
// Original source line 1781: C(JA+J)=A(IA+I)+SIN45*(A(IB+I)-A(ID+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldr d1, [x29, #592]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1782: C(JB+J)=A(IA+I)-SIN45*(A(IB+I)-A(ID+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldr d1, [x29, #592]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1783: D(JA+J)=-A(IC+I)-SIN45*(A(IB+I)+A(ID+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #592]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1784: D(JB+J)=A(IC+I)-SIN45*(A(IB+I)+A(ID+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldr d1, [x29, #592]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1785: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1786: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1787: 470 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1464]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_310
.Lmd2asm_fft992_qpassf_do_done_311:
// Original source line 1788: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1789: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1790: 480 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1448]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_308
.Lmd2asm_fft992_qpassf_do_done_309:
// Original source line 1791: ENDIF
.Lmd2asm_fft992_qpassf_if_false_306:
.Lmd2asm_fft992_qpassf_if_end_307:
// Original source line 1793: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_293
.Lmd2asm_fft992_qpassf_if_false_292:
// Original source line 1794: Z=1.0_JPRB/REAL(N,KIND=JPRB)
    adrp x16, .Lfft_constant_10
    ldr d0, [x16, :lo12:.Lfft_constant_10]
    ldrsw x9, [x29, #248]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1, x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x29, #568]
// Original source line 1795: IF (LIPL) THEN
    ldrsw x9, [x29, #1000]
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_312
// Original source line 1796: DO 494 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1472]
    mov x9, #1
    str x9, [x29, #1480]
.Lmd2asm_fft992_qpassf_do_314:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1472]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_315
// Original source line 1797: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1800: DO 492 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1488]
    mov x10, #1
    str x10, [x29, #1496]
.Lmd2asm_fft992_qpassf_do_316:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1488]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_317
// Original source line 1801: T1=Z*(A(IA+I)-A(IC+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #512]
// Original source line 1802: T3=Z*(A(ID+I)-A(IB+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #528]
// Original source line 1803: T2=Z*((A(IA+I)+A(IC+I))-(A(IB+I)+A(ID+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #520]
// Original source line 1804: A(IA+I)=Z*((A(IA+I)+A(IC+I))+(A(IB+I)+A(ID+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1805: A(IB+I)=T1
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1806: A(IC+I)=T2
    ldr d0, [x29, #520]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1807: A(ID+I)=T3
    ldr d0, [x29, #528]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1808: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1809: 492 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1496]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_316
.Lmd2asm_fft992_qpassf_do_done_317:
// Original source line 1810: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1811: 494 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1480]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_314
.Lmd2asm_fft992_qpassf_do_done_315:
// Original source line 1812: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_313
.Lmd2asm_fft992_qpassf_if_false_312:
// Original source line 1813: DO 498 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1504]
    mov x9, #1
    str x9, [x29, #1512]
.Lmd2asm_fft992_qpassf_do_318:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1504]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_319
// Original source line 1814: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1815: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1818: DO 496 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1520]
    mov x10, #1
    str x10, [x29, #1528]
.Lmd2asm_fft992_qpassf_do_320:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1520]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_321
// Original source line 1819: C(JA+J)=Z*((A(IA+I)+A(IC+I))+(A(IB+I)+A(ID+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1820: C(JC+J)=Z*((A(IA+I)+A(IC+I))-(A(IB+I)+A(ID+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1821: C(JB+J)=Z*(A(IA+I)-A(IC+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1822: D(JB+J)=Z*(A(ID+I)-A(IB+I))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1823: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1824: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1825: 496 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1528]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_320
.Lmd2asm_fft992_qpassf_do_done_321:
// Original source line 1826: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1827: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1828: 498 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1512]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_318
.Lmd2asm_fft992_qpassf_do_done_319:
// Original source line 1829: ENDIF
.Lmd2asm_fft992_qpassf_if_end_313:
// Original source line 1830: ENDIF
.Lmd2asm_fft992_qpassf_if_end_293:
// Original source line 1832: ELSEIF (IFAC.EQ.5) THEN
    b .Lmd2asm_fft992_qpassf_if_end_229
.Lmd2asm_fft992_qpassf_elseif_false_291:
    ldrsw x9, [x29, #704]
    mov x10, #5
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_elseif_false_322
// Original source line 1836: 500 CONTINUE
// Original source line 1837: IA=1
    mov x9, #1
    str w9, [x29, #752]
// Original source line 1838: IB=IA+IINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 1839: IC=IB+IINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #784]
// Original source line 1840: ID=IC+IINK
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #792]
// Original source line 1841: IE=ID+IINK
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 1842: JA=1
    mov x9, #1
    str w9, [x29, #864]
// Original source line 1843: JB=JA+(2*M-LA)*INC2
    ldrsw x9, [x29, #864]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #712]
    sub x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1844: JC=JB+2*M*INC2
    ldrsw x9, [x29, #872]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #880]
// Original source line 1845: JD=JC
    ldrsw x9, [x29, #880]
    str w9, [x29, #888]
// Original source line 1846: JE=JB
    ldrsw x9, [x29, #872]
    str w9, [x29, #896]
// Original source line 1848: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #992]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_323
// Original source line 1850: DO 520 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1536]
    mov x9, #1
    str x9, [x29, #1544]
.Lmd2asm_fft992_qpassf_do_325:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1536]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_326
// Original source line 1851: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1852: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1855: DO 510 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1552]
    mov x10, #1
    str x10, [x29, #1560]
.Lmd2asm_fft992_qpassf_do_327:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1552]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_328
// Original source line 1856: A1=A(IB+I)+A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1857: A3=A(IB+I)-A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 1858: A2=A(IC+I)+A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #272]
// Original source line 1859: A4=A(IC+I)-A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #288]
// Original source line 1860: A5=A(IA+I)-0.25_JPRB*(A1+A2)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldr d2, [x29, #264]
    ldr d3, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #296]
// Original source line 1861: A6=QRT5*(A1-A2)
    ldr d0, [x29, #576]
    ldr d1, [x29, #264]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #304]
// Original source line 1862: C(JA+J)=A(IA+I)+(A1+A2)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldr d1, [x29, #264]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1863: C(JB+J)=A5+A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1864: C(JC+J)=A5-A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1865: D(JB+J)=-SIN72*A3-SIN36*A4
    ldr d0, [x29, #608]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #584]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1866: D(JC+J)=-SIN36*A3+SIN72*A4
    ldr d0, [x29, #584]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #608]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1867: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1868: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1869: 510 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1560]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_327
.Lmd2asm_fft992_qpassf_do_done_328:
// Original source line 1870: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1871: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1872: 520 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1544]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_325
.Lmd2asm_fft992_qpassf_do_done_326:
// Original source line 1873: JA=JA+JINK
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #864]
// Original source line 1874: JINK=2*JINK
    mov x9, #2
    ldrsw x10, [x29, #920]
    mul x9, x9, x10
    str w9, [x29, #920]
// Original source line 1875: JB=JB+JINK
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 1876: JC=JC+JINK
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #880]
// Original source line 1877: JD=JD-JINK
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #888]
// Original source line 1878: JE=JE-JINK
    ldrsw x9, [x29, #896]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #896]
// Original source line 1879: IBASE=IBASE+IJUMP
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #832]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1880: IJUMP=2*IJUMP+IINK
    mov x9, #2
    ldrsw x10, [x29, #832]
    mul x9, x9, x10
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #832]
// Original source line 1882: IF (JB.LT.JD) THEN
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #888]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_329
// Original source line 1883: DO 550 K=LA,KSTOP,LA
    ldrsw x9, [x29, #712]
    str w9, [x29, #928]
    ldrsw x9, [x29, #976]
    str x9, [x29, #1568]
    ldrsw x9, [x29, #712]
    str x9, [x29, #1576]
.Lmd2asm_fft992_qpassf_do_331:
    ldrsw x9, [x29, #928]
    ldr x10, [x29, #1568]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_332
// Original source line 1884: KB=K+K
    ldrsw x10, [x29, #928]
    ldrsw x9, [x29, #928]
    add x10, x10, x9
    str w10, [x29, #936]
// Original source line 1885: KC=KB+KB
    ldrsw x10, [x29, #936]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #944]
// Original source line 1886: KD=KC+KB
    ldrsw x10, [x29, #944]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #952]
// Original source line 1887: KE=KD+KB
    ldrsw x10, [x29, #952]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #960]
// Original source line 1888: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #936]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #432]
// Original source line 1889: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #936]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #472]
// Original source line 1890: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #944]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #440]
// Original source line 1891: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #944]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #480]
// Original source line 1892: C3=TRIGS(KD+1)
    ldrsw x10, [x29, #952]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #448]
// Original source line 1893: S3=TRIGS(KD+2)
    ldrsw x10, [x29, #952]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #488]
// Original source line 1894: C4=TRIGS(KE+1)
    ldrsw x10, [x29, #960]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #456]
// Original source line 1895: S4=TRIGS(KE+2)
    ldrsw x10, [x29, #960]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #496]
// Original source line 1896: JBASE=0
    mov x10, #0
    str w10, [x29, #904]
// Original source line 1897: DO 540 L=1,ILA
    mov x10, #1
    str w10, [x29, #984]
    ldrsw x10, [x29, #840]
    str x10, [x29, #1584]
    mov x10, #1
    str x10, [x29, #1592]
.Lmd2asm_fft992_qpassf_do_333:
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1584]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_334
// Original source line 1898: I=IBASE
    ldrsw x9, [x29, #776]
    str w9, [x29, #744]
// Original source line 1899: J=JBASE
    ldrsw x9, [x29, #904]
    str w9, [x29, #856]
// Original source line 1902: DO 530 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #728]
    ldrsw x9, [x29, #736]
    str x9, [x29, #1600]
    mov x9, #1
    str x9, [x29, #1608]
.Lmd2asm_fft992_qpassf_do_335:
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1600]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_336
// Original source line 1903: A1=(C1*A(IB+I)+S1*B(IB+I))+(C4*A(IE+I)+S4*B(IE+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #496]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1904: A3=(C1*A(IB+I)+S1*B(IB+I))-(C4*A(IE+I)+S4*B(IE+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #496]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 1905: A2=(C2*A(IC+I)+S2*B(IC+I))+(C3*A(ID+I)+S3*B(ID+I))
    ldr d0, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #272]
// Original source line 1906: A4=(C2*A(IC+I)+S2*B(IC+I))-(C3*A(ID+I)+S3*B(ID+I))
    ldr d0, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #288]
// Original source line 1907: B1=(C1*B(IB+I)-S1*A(IB+I))+(C4*B(IE+I)-S4*A(IE+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #496]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #352]
// Original source line 1908: B3=(C1*B(IB+I)-S1*A(IB+I))-(C4*B(IE+I)-S4*A(IE+I))
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #456]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #496]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #368]
// Original source line 1909: B2=(C2*B(IC+I)-S2*A(IC+I))+(C3*B(ID+I)-S3*A(ID+I))
    ldr d0, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #360]
// Original source line 1910: B4=(C2*B(IC+I)-S2*A(IC+I))-(C3*B(ID+I)-S3*A(ID+I))
    ldr d0, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
    ldr d2, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d3, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #376]
// Original source line 1911: A5=A(IA+I)-0.25_JPRB*(A1+A2)
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldr d2, [x29, #264]
    ldr d3, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #296]
// Original source line 1912: A6=QRT5*(A1-A2)
    ldr d0, [x29, #576]
    ldr d1, [x29, #264]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #304]
// Original source line 1913: B5=B(IA+I)-0.25_JPRB*(B1+B2)
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldr d2, [x29, #352]
    ldr d3, [x29, #360]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #384]
// Original source line 1914: B6=QRT5*(B1-B2)
    ldr d0, [x29, #576]
    ldr d1, [x29, #352]
    ldr d2, [x29, #360]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #392]
// Original source line 1915: A10=A5+A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #312]
// Original source line 1916: A20=A5-A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #328]
// Original source line 1917: B10=B5+B6
    ldr d0, [x29, #384]
    ldr d1, [x29, #392]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #400]
// Original source line 1918: B20=B5-B6
    ldr d0, [x29, #384]
    ldr d1, [x29, #392]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #416]
// Original source line 1919: A11=SIN72*B3+SIN36*B4
    ldr d0, [x29, #608]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #584]
    ldr d2, [x29, #376]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 1920: A21=SIN36*B3-SIN72*B4
    ldr d0, [x29, #584]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #608]
    ldr d2, [x29, #376]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #336]
// Original source line 1921: B11=SIN72*A3+SIN36*A4
    ldr d0, [x29, #608]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #584]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #408]
// Original source line 1922: B21=SIN36*A3-SIN72*A4
    ldr d0, [x29, #584]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #608]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #424]
// Original source line 1923: C(JA+J)=A(IA+I)+(A1+A2)
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #264]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1924: C(JB+J)=A10+A11
    ldr d0, [x29, #312]
    ldr d1, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1925: C(JE+J)=A10-A11
    ldr d0, [x29, #312]
    ldr d1, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #896]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1926: C(JC+J)=A20+A21
    ldr d0, [x29, #328]
    ldr d1, [x29, #336]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1927: C(JD+J)=A20-A21
    ldr d0, [x29, #328]
    ldr d1, [x29, #336]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1928: D(JA+J)=B(IA+I)+(B1+B2)
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #352]
    ldr d2, [x29, #360]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1929: D(JB+J)=B10-B11
    ldr d0, [x29, #400]
    ldr d1, [x29, #408]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1930: D(JE+J)=-(B10+B11)
    ldr d0, [x29, #400]
    ldr d1, [x29, #408]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x10, [x29, #896]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1931: D(JC+J)=B20-B21
    ldr d0, [x29, #416]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1932: D(JD+J)=-(B20+B21)
    ldr d0, [x29, #416]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 1933: I=I+INC3
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #680]
    add x10, x10, x9
    str w10, [x29, #744]
// Original source line 1934: J=J+INC4
    ldrsw x10, [x29, #856]
    ldrsw x9, [x29, #688]
    add x10, x10, x9
    str w10, [x29, #856]
// Original source line 1935: 530 CONTINUE
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1608]
    add x10, x10, x9
    str x10, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_335
.Lmd2asm_fft992_qpassf_do_done_336:
// Original source line 1936: IBASE=IBASE+INC11
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #848]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 1937: JBASE=JBASE+INC2
    ldrsw x9, [x29, #904]
    ldrsw x10, [x29, #672]
    add x9, x9, x10
    str w9, [x29, #904]
// Original source line 1938: 540 CONTINUE
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1592]
    add x9, x9, x10
    str x9, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_333
.Lmd2asm_fft992_qpassf_do_done_334:
// Original source line 1939: IBASE=IBASE+IJUMP
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #832]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1940: JA=JA+JINK
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #864]
// Original source line 1941: JB=JB+JINK
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #872]
// Original source line 1942: JC=JC+JINK
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #880]
// Original source line 1943: JD=JD-JINK
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #888]
// Original source line 1944: JE=JE-JINK
    ldrsw x10, [x29, #896]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #896]
// Original source line 1945: 550 CONTINUE
    ldrsw x10, [x29, #928]
    ldr x9, [x29, #1576]
    add x10, x10, x9
    str x10, [x29, #928]
    b .Lmd2asm_fft992_qpassf_do_331
.Lmd2asm_fft992_qpassf_do_done_332:
// Original source line 1946: ENDIF
.Lmd2asm_fft992_qpassf_if_false_329:
.Lmd2asm_fft992_qpassf_if_end_330:
// Original source line 1948: IF (JB.EQ.JD) THEN
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #888]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_337
// Original source line 1949: JBASE=0
    mov x9, #0
    str w9, [x29, #904]
// Original source line 1950: DO 580 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1616]
    mov x9, #1
    str x9, [x29, #1624]
.Lmd2asm_fft992_qpassf_do_339:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1616]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_340
// Original source line 1951: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1952: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 1955: DO 570 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1632]
    mov x10, #1
    str x10, [x29, #1640]
.Lmd2asm_fft992_qpassf_do_341:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1632]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_342
// Original source line 1956: A1=A(IB+I)+A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1957: A3=A(IB+I)-A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 1958: A2=A(IC+I)+A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #272]
// Original source line 1959: A4=A(IC+I)-A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #288]
// Original source line 1960: A5=A(IA+I)+0.25_JPRB*(A3-A4)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d1, [x16, :lo12:.Lfft_constant_8]
    ldr d2, [x29, #280]
    ldr d3, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #296]
// Original source line 1961: A6=QRT5*(A3+A4)
    ldr d0, [x29, #576]
    ldr d1, [x29, #280]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #304]
// Original source line 1962: C(JA+J)=A5+A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1963: C(JB+J)=A5-A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1964: C(JC+J)=A(IA+I)-(A3-A4)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldr d1, [x29, #280]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1965: D(JA+J)=-SIN36*A1-SIN72*A2
    ldr d0, [x29, #584]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #608]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1966: D(JB+J)=-SIN72*A1+SIN36*A2
    ldr d0, [x29, #608]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #584]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1967: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1968: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 1969: 570 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1640]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_341
.Lmd2asm_fft992_qpassf_do_done_342:
// Original source line 1970: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 1971: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 1972: 580 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1624]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_339
.Lmd2asm_fft992_qpassf_do_done_340:
// Original source line 1973: ENDIF
.Lmd2asm_fft992_qpassf_if_false_337:
.Lmd2asm_fft992_qpassf_if_end_338:
// Original source line 1975: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_324
.Lmd2asm_fft992_qpassf_if_false_323:
// Original source line 1976: Z=1.0_JPRB/REAL(N,KIND=JPRB)
    adrp x16, .Lfft_constant_10
    ldr d0, [x16, :lo12:.Lfft_constant_10]
    ldrsw x9, [x29, #248]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1, x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x29, #568]
// Original source line 1977: ZQRT5=Z*QRT5
    ldr d0, [x29, #568]
    ldr d1, [x29, #576]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #616]
// Original source line 1978: ZSIN36=Z*SIN36
    ldr d0, [x29, #568]
    ldr d1, [x29, #584]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #624]
// Original source line 1979: ZSIN72=Z*SIN72
    ldr d0, [x29, #568]
    ldr d1, [x29, #608]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #648]
// Original source line 1980: IF (LIPL) THEN
    ldrsw x9, [x29, #1000]
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_343
// Original source line 1981: DO 594 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1648]
    mov x9, #1
    str x9, [x29, #1656]
.Lmd2asm_fft992_qpassf_do_345:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1648]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_346
// Original source line 1982: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 1985: DO 592 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1664]
    mov x10, #1
    str x10, [x29, #1672]
.Lmd2asm_fft992_qpassf_do_347:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1664]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_348
// Original source line 1986: A1=A(IB+I)+A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 1987: A3=A(IB+I)-A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 1988: A2=A(IC+I)+A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #272]
// Original source line 1989: A4=A(IC+I)-A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #288]
// Original source line 1990: A5=Z*(A(IA+I)-0.25_JPRB*(A1+A2))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldr d3, [x29, #264]
    ldr d4, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #296]
// Original source line 1991: A6=ZQRT5*(A1-A2)
    ldr d0, [x29, #616]
    ldr d1, [x29, #264]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #304]
// Original source line 1992: A(IA+I)=Z*(A(IA+I)+(A1+A2))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldr d2, [x29, #264]
    ldr d3, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1993: A(IB+I)=A5+A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1994: A(ID+I)=A5-A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1995: A(IC+I)=-ZSIN72*A3-ZSIN36*A4
    ldr d0, [x29, #648]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #624]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1996: A(IE+I)=-ZSIN36*A3+ZSIN72*A4
    ldr d0, [x29, #624]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #648]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 1997: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 1998: 592 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1672]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_347
.Lmd2asm_fft992_qpassf_do_done_348:
// Original source line 1999: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2000: 594 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1656]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_345
.Lmd2asm_fft992_qpassf_do_done_346:
// Original source line 2001: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_344
.Lmd2asm_fft992_qpassf_if_false_343:
// Original source line 2002: DO 598 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1680]
    mov x9, #1
    str x9, [x29, #1688]
.Lmd2asm_fft992_qpassf_do_349:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1680]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_350
// Original source line 2003: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2004: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 2007: DO 596 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1696]
    mov x10, #1
    str x10, [x29, #1704]
.Lmd2asm_fft992_qpassf_do_351:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1696]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_352
// Original source line 2008: A1=A(IB+I)+A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 2009: A3=A(IB+I)-A(IE+I)
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #280]
// Original source line 2010: A2=A(IC+I)+A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #272]
// Original source line 2011: A4=A(IC+I)-A(ID+I)
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #288]
// Original source line 2012: A5=Z*(A(IA+I)-0.25_JPRB*(A1+A2))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_8
    ldr d2, [x16, :lo12:.Lfft_constant_8]
    ldr d3, [x29, #264]
    ldr d4, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #296]
// Original source line 2013: A6=ZQRT5*(A1-A2)
    ldr d0, [x29, #616]
    ldr d1, [x29, #264]
    ldr d2, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #304]
// Original source line 2014: C(JA+J)=Z*(A(IA+I)+(A1+A2))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldr d2, [x29, #264]
    ldr d3, [x29, #272]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2015: C(JB+J)=A5+A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2016: C(JC+J)=A5-A6
    ldr d0, [x29, #296]
    ldr d1, [x29, #304]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2017: D(JB+J)=-ZSIN72*A3-ZSIN36*A4
    ldr d0, [x29, #648]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #624]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2018: D(JC+J)=-ZSIN36*A3+ZSIN72*A4
    ldr d0, [x29, #624]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #648]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2019: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2020: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 2021: 596 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1704]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_351
.Lmd2asm_fft992_qpassf_do_done_352:
// Original source line 2022: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2023: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 2024: 598 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1688]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_349
.Lmd2asm_fft992_qpassf_do_done_350:
// Original source line 2025: ENDIF
.Lmd2asm_fft992_qpassf_if_end_344:
// Original source line 2026: ENDIF
.Lmd2asm_fft992_qpassf_if_end_324:
// Original source line 2028: ELSEIF (IFAC.EQ.6) THEN
    b .Lmd2asm_fft992_qpassf_if_end_229
.Lmd2asm_fft992_qpassf_elseif_false_322:
    ldrsw x9, [x29, #704]
    mov x10, #6
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_elseif_false_353
// Original source line 2032: 600 CONTINUE
// Original source line 2033: IA=1
    mov x9, #1
    str w9, [x29, #752]
// Original source line 2034: IB=IA+IINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 2035: IC=IB+IINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #784]
// Original source line 2036: ID=IC+IINK
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #792]
// Original source line 2037: IE=ID+IINK
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 2038: IF=IE+IINK
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #808]
// Original source line 2039: JA=1
    mov x9, #1
    str w9, [x29, #864]
// Original source line 2040: JB=JA+(2*M-LA)*INC2
    ldrsw x9, [x29, #864]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #712]
    sub x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 2041: JC=JB+2*M*INC2
    ldrsw x9, [x29, #872]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #880]
// Original source line 2042: JD=JC+2*M*INC2
    ldrsw x9, [x29, #880]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #888]
// Original source line 2043: JE=JC
    ldrsw x9, [x29, #880]
    str w9, [x29, #896]
// Original source line 2044: JF=JB
    ldrsw x9, [x29, #872]
    str w9, [x29, #912]
// Original source line 2046: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #992]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_354
// Original source line 2048: DO 620 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1712]
    mov x9, #1
    str x9, [x29, #1720]
.Lmd2asm_fft992_qpassf_do_356:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1712]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_357
// Original source line 2049: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2050: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 2053: DO 610 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1728]
    mov x10, #1
    str x10, [x29, #1736]
.Lmd2asm_fft992_qpassf_do_358:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1728]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_359
// Original source line 2054: A11=(A(IC+I)+A(IF+I))+(A(IB+I)+A(IE+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2055: C(JA+J)=(A(IA+I)+A(ID+I))+A11
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2056: C(JC+J)=(A(IA+I)+A(ID+I)-0.5_JPRB*A11)
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2057: D(JC+J)=SIN60*((A(IC+I)+A(IF+I))-(A(IB+I)+A(IE+I)))
    ldr d0, [x29, #600]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2058: A11=(A(IC+I)-A(IF+I))+(A(IE+I)-A(IB+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2059: C(JB+J)=(A(IA+I)-A(ID+I))-0.5_JPRB*A11
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2060: D(JB+J)=SIN60*((A(IE+I)-A(IB+I))-(A(IC+I)-A(IF+I)))
    ldr d0, [x29, #600]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2061: C(JD+J)=(A(IA+I)-A(ID+I))+A11
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2062: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2063: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 2064: 610 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1736]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_358
.Lmd2asm_fft992_qpassf_do_done_359:
// Original source line 2065: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2066: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 2067: 620 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1720]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_356
.Lmd2asm_fft992_qpassf_do_done_357:
// Original source line 2068: JA=JA+JINK
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #864]
// Original source line 2069: JINK=2*JINK
    mov x9, #2
    ldrsw x10, [x29, #920]
    mul x9, x9, x10
    str w9, [x29, #920]
// Original source line 2070: JB=JB+JINK
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 2071: JC=JC+JINK
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #920]
    add x9, x9, x10
    str w9, [x29, #880]
// Original source line 2072: JD=JD-JINK
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #888]
// Original source line 2073: JE=JE-JINK
    ldrsw x9, [x29, #896]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #896]
// Original source line 2074: JF=JF-JINK
    ldrsw x9, [x29, #912]
    ldrsw x10, [x29, #920]
    sub x9, x9, x10
    str w9, [x29, #912]
// Original source line 2075: IBASE=IBASE+IJUMP
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #832]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 2076: IJUMP=2*IJUMP+IINK
    mov x9, #2
    ldrsw x10, [x29, #832]
    mul x9, x9, x10
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #832]
// Original source line 2078: IF (JC.LT.JD) THEN
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #888]
    cmp x9, x10
    cset x9, lt
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_360
// Original source line 2079: DO 650 K=LA,KSTOP,LA
    ldrsw x9, [x29, #712]
    str w9, [x29, #928]
    ldrsw x9, [x29, #976]
    str x9, [x29, #1744]
    ldrsw x9, [x29, #712]
    str x9, [x29, #1752]
.Lmd2asm_fft992_qpassf_do_362:
    ldrsw x9, [x29, #928]
    ldr x10, [x29, #1744]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_363
// Original source line 2080: KB=K+K
    ldrsw x10, [x29, #928]
    ldrsw x9, [x29, #928]
    add x10, x10, x9
    str w10, [x29, #936]
// Original source line 2081: KC=KB+KB
    ldrsw x10, [x29, #936]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #944]
// Original source line 2082: KD=KC+KB
    ldrsw x10, [x29, #944]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #952]
// Original source line 2083: KE=KD+KB
    ldrsw x10, [x29, #952]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #960]
// Original source line 2084: KF=KE+KB
    ldrsw x10, [x29, #960]
    ldrsw x9, [x29, #936]
    add x10, x10, x9
    str w10, [x29, #968]
// Original source line 2085: C1=TRIGS(KB+1)
    ldrsw x10, [x29, #936]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #432]
// Original source line 2086: S1=TRIGS(KB+2)
    ldrsw x10, [x29, #936]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #472]
// Original source line 2087: C2=TRIGS(KC+1)
    ldrsw x10, [x29, #944]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #440]
// Original source line 2088: S2=TRIGS(KC+2)
    ldrsw x10, [x29, #944]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #480]
// Original source line 2089: C3=TRIGS(KD+1)
    ldrsw x10, [x29, #952]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #448]
// Original source line 2090: S3=TRIGS(KD+2)
    ldrsw x10, [x29, #952]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #488]
// Original source line 2091: C4=TRIGS(KE+1)
    ldrsw x10, [x29, #960]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #456]
// Original source line 2092: S4=TRIGS(KE+2)
    ldrsw x10, [x29, #960]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #496]
// Original source line 2093: C5=TRIGS(KF+1)
    ldrsw x10, [x29, #968]
    mov x9, #1
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #464]
// Original source line 2094: S5=TRIGS(KF+2)
    ldrsw x10, [x29, #968]
    mov x9, #2
    add x10, x10, x9
    ldr x16, [x29, #160]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    str d0, [x29, #504]
// Original source line 2095: JBASE=0
    mov x10, #0
    str w10, [x29, #904]
// Original source line 2096: DO 640 L=1,ILA
    mov x10, #1
    str w10, [x29, #984]
    ldrsw x10, [x29, #840]
    str x10, [x29, #1760]
    mov x10, #1
    str x10, [x29, #1768]
.Lmd2asm_fft992_qpassf_do_364:
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1760]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_365
// Original source line 2097: I=IBASE
    ldrsw x9, [x29, #776]
    str w9, [x29, #744]
// Original source line 2098: J=JBASE
    ldrsw x9, [x29, #904]
    str w9, [x29, #856]
// Original source line 2101: DO 630 IJK=1,ILOT
    mov x9, #1
    str w9, [x29, #728]
    ldrsw x9, [x29, #736]
    str x9, [x29, #1776]
    mov x9, #1
    str x9, [x29, #1784]
.Lmd2asm_fft992_qpassf_do_366:
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1776]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_367
// Original source line 2102: A1=C1*A(IB+I)+S1*B(IB+I)
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #264]
// Original source line 2103: B1=C1*B(IB+I)-S1*A(IB+I)
    ldr d0, [x29, #432]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #472]
    ldrsw x10, [x29, #760]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #352]
// Original source line 2104: A2=C2*A(IC+I)+S2*B(IC+I)
    ldr d0, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #272]
// Original source line 2105: B2=C2*B(IC+I)-S2*A(IC+I)
    ldr d0, [x29, #440]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #480]
    ldrsw x10, [x29, #784]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #360]
// Original source line 2106: A3=C3*A(ID+I)+S3*B(ID+I)
    ldr d0, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #280]
// Original source line 2107: B3=C3*B(ID+I)-S3*A(ID+I)
    ldr d0, [x29, #448]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #488]
    ldrsw x10, [x29, #792]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #368]
// Original source line 2108: A4=C4*A(IE+I)+S4*B(IE+I)
    ldr d0, [x29, #456]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #496]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #288]
// Original source line 2109: B4=C4*B(IE+I)-S4*A(IE+I)
    ldr d0, [x29, #456]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #496]
    ldrsw x10, [x29, #800]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #376]
// Original source line 2110: A5=C5*A(IF+I)+S5*B(IF+I)
    ldr d0, [x29, #464]
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #504]
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #296]
// Original source line 2111: B5=C5*B(IF+I)-S5*A(IF+I)
    ldr d0, [x29, #464]
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #504]
    ldrsw x10, [x29, #808]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #384]
// Original source line 2112: A11=(A2+A5)+(A1+A4)
    ldr d0, [x29, #272]
    ldr d1, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #264]
    ldr d2, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2113: A20=(A(IA+I)+A3)-0.5_JPRB*A11
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #328]
// Original source line 2114: A21=SIN60*((A2+A5)-(A1+A4))
    ldr d0, [x29, #600]
    ldr d1, [x29, #272]
    ldr d2, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldr d2, [x29, #264]
    ldr d3, [x29, #288]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #336]
// Original source line 2115: B11=(B2+B5)+(B1+B4)
    ldr d0, [x29, #360]
    ldr d1, [x29, #384]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #352]
    ldr d2, [x29, #376]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #408]
// Original source line 2116: B20=(B(IA+I)+B3)-0.5_JPRB*B11
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #408]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #416]
// Original source line 2117: B21=SIN60*((B2+B5)-(B1+B4))
    ldr d0, [x29, #600]
    ldr d1, [x29, #360]
    ldr d2, [x29, #384]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldr d2, [x29, #352]
    ldr d3, [x29, #376]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #424]
// Original source line 2118: C(JA+J)=(A(IA+I)+A3)+A11
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2119: D(JA+J)=(B(IA+I)+B3)+B11
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #368]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #408]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2120: C(JC+J)=A20-B21
    ldr d0, [x29, #328]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2121: D(JC+J)=A21+B20
    ldr d0, [x29, #336]
    ldr d1, [x29, #416]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2122: C(JE+J)=A20+B21
    ldr d0, [x29, #328]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #896]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2123: D(JE+J)=A21-B20
    ldr d0, [x29, #336]
    ldr d1, [x29, #416]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #896]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2124: A11=(A2-A5)+(A4-A1)
    ldr d0, [x29, #272]
    ldr d1, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #288]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2125: A20=(A(IA+I)-A3)-0.5_JPRB*A11
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d0, [x16, x10, lsl #3]
    ldr d1, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #328]
// Original source line 2126: A21=SIN60*((A4-A1)-(A2-A5))
    ldr d0, [x29, #600]
    ldr d1, [x29, #288]
    ldr d2, [x29, #264]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #272]
    ldr d3, [x29, #296]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #336]
// Original source line 2127: B11=(B5-B2)-(B4-B1)
    ldr d0, [x29, #384]
    ldr d1, [x29, #360]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldr d1, [x29, #376]
    ldr d2, [x29, #352]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #408]
// Original source line 2128: B20=(B3-B(IA+I))-0.5_JPRB*B11
    ldr d0, [x29, #368]
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldr d2, [x29, #408]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #416]
// Original source line 2129: B21=SIN60*((B5-B2)+(B4-B1))
    ldr d0, [x29, #600]
    ldr d1, [x29, #384]
    ldr d2, [x29, #360]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #376]
    ldr d3, [x29, #352]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #424]
// Original source line 2130: C(JB+J)=A20-B21
    ldr d0, [x29, #328]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2131: D(JB+J)=A21-B20
    ldr d0, [x29, #336]
    ldr d1, [x29, #416]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2132: C(JD+J)=A11+(A(IA+I)-A3)
    ldr d0, [x29, #320]
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #128]
    sub x10, x10, #1
    ldr d1, [x16, x10, lsl #3]
    ldr d2, [x29, #280]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2133: D(JD+J)=B11+(B3-B(IA+I))
    ldr d0, [x29, #408]
    ldr d1, [x29, #368]
    ldrsw x10, [x29, #752]
    ldrsw x9, [x29, #744]
    add x10, x10, x9
    ldr x16, [x29, #136]
    sub x10, x10, #1
    ldr d2, [x16, x10, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2134: C(JF+J)=A20+B21
    ldr d0, [x29, #328]
    ldr d1, [x29, #424]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #912]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #144]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2135: D(JF+J)=A21+B20
    ldr d0, [x29, #336]
    ldr d1, [x29, #416]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x10, [x29, #912]
    ldrsw x9, [x29, #856]
    add x10, x10, x9
    ldr x16, [x29, #152]
    sub x10, x10, #1
    str d0, [x16, x10, lsl #3]
// Original source line 2136: I=I+INC3
    ldrsw x10, [x29, #744]
    ldrsw x9, [x29, #680]
    add x10, x10, x9
    str w10, [x29, #744]
// Original source line 2137: J=J+INC4
    ldrsw x10, [x29, #856]
    ldrsw x9, [x29, #688]
    add x10, x10, x9
    str w10, [x29, #856]
// Original source line 2138: 630 CONTINUE
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1784]
    add x10, x10, x9
    str x10, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_366
.Lmd2asm_fft992_qpassf_do_done_367:
// Original source line 2139: IBASE=IBASE+INC11
    ldrsw x9, [x29, #776]
    ldrsw x10, [x29, #848]
    add x9, x9, x10
    str w9, [x29, #776]
// Original source line 2140: JBASE=JBASE+INC2
    ldrsw x9, [x29, #904]
    ldrsw x10, [x29, #672]
    add x9, x9, x10
    str w9, [x29, #904]
// Original source line 2141: 640 CONTINUE
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1768]
    add x9, x9, x10
    str x9, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_364
.Lmd2asm_fft992_qpassf_do_done_365:
// Original source line 2142: IBASE=IBASE+IJUMP
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #832]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2143: JA=JA+JINK
    ldrsw x10, [x29, #864]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #864]
// Original source line 2144: JB=JB+JINK
    ldrsw x10, [x29, #872]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #872]
// Original source line 2145: JC=JC+JINK
    ldrsw x10, [x29, #880]
    ldrsw x9, [x29, #920]
    add x10, x10, x9
    str w10, [x29, #880]
// Original source line 2146: JD=JD-JINK
    ldrsw x10, [x29, #888]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #888]
// Original source line 2147: JE=JE-JINK
    ldrsw x10, [x29, #896]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #896]
// Original source line 2148: JF=JF-JINK
    ldrsw x10, [x29, #912]
    ldrsw x9, [x29, #920]
    sub x10, x10, x9
    str w10, [x29, #912]
// Original source line 2149: 650 CONTINUE
    ldrsw x10, [x29, #928]
    ldr x9, [x29, #1752]
    add x10, x10, x9
    str x10, [x29, #928]
    b .Lmd2asm_fft992_qpassf_do_362
.Lmd2asm_fft992_qpassf_do_done_363:
// Original source line 2150: ENDIF
.Lmd2asm_fft992_qpassf_if_false_360:
.Lmd2asm_fft992_qpassf_if_end_361:
// Original source line 2152: IF (JC.EQ.JD) THEN
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #888]
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_368
// Original source line 2153: JBASE=0
    mov x9, #0
    str w9, [x29, #904]
// Original source line 2154: DO 680 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1792]
    mov x9, #1
    str x9, [x29, #1800]
.Lmd2asm_fft992_qpassf_do_370:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1792]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_371
// Original source line 2155: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2156: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 2159: DO 670 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1808]
    mov x10, #1
    str x10, [x29, #1816]
.Lmd2asm_fft992_qpassf_do_372:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1808]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_373
// Original source line 2160: C(JA+J)=(A(IA+I)+0.5_JPRB*(A(IC+I)-A(IE+I)))+SIN60*(A(IB+I)-A(IF+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #600]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2162: D(JA+J)=-(A(ID+I)+0.5_JPRB*(A(IB+I)+A(IF+I)))-SIN60*(A(IC+I)+A(IE+I))
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #600]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2164: C(JB+J)=A(IA+I)-(A(IC+I)-A(IE+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2165: D(JB+J)=A(ID+I)-(A(IB+I)+A(IF+I))
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2166: C(JC+J)=(A(IA+I)+0.5_JPRB*(A(IC+I)-A(IE+I)))-SIN60*(A(IB+I)-A(IF+I))
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldr d1, [x29, #600]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2168: D(JC+J)=-(A(ID+I)+0.5_JPRB*(A(IB+I)+A(IF+I)))+SIN60*(A(IC+I)+A(IE+I))
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    adrp x16, .Lfft_constant_0
    ldr d1, [x16, :lo12:.Lfft_constant_0]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,15,d0,d0 // fneg d0, d0
    ldr d1, [x29, #600]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2170: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2171: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 2172: 670 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1816]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_372
.Lmd2asm_fft992_qpassf_do_done_373:
// Original source line 2173: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2174: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 2175: 680 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1800]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_370
.Lmd2asm_fft992_qpassf_do_done_371:
// Original source line 2176: ENDIF
.Lmd2asm_fft992_qpassf_if_false_368:
.Lmd2asm_fft992_qpassf_if_end_369:
// Original source line 2178: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_355
.Lmd2asm_fft992_qpassf_if_false_354:
// Original source line 2179: Z=1.0_JPRB/REAL(N,KIND=JPRB)
    adrp x16, .Lfft_constant_10
    ldr d0, [x16, :lo12:.Lfft_constant_10]
    ldrsw x9, [x29, #248]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1, x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x29, #568]
// Original source line 2180: ZSIN60=Z*SIN60
    ldr d0, [x29, #568]
    ldr d1, [x29, #600]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #640]
// Original source line 2181: IF (LIPL) THEN
    ldrsw x9, [x29, #1000]
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_374
// Original source line 2182: DO 694 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1824]
    mov x9, #1
    str x9, [x29, #1832]
.Lmd2asm_fft992_qpassf_do_376:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1824]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_377
// Original source line 2183: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2186: DO 692 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1840]
    mov x10, #1
    str x10, [x29, #1848]
.Lmd2asm_fft992_qpassf_do_378:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1840]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_379
// Original source line 2187: A11=(A(IC+I)-A(IF+I))+(A(IE+I)-A(IB+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2188: T1=Z*((A(IA+I)-A(ID+I))-0.5_JPRB*A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldr d3, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #512]
// Original source line 2189: T5=Z*((A(IA+I)-A(ID+I))+A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #544]
// Original source line 2190: T2=ZSIN60*((A(IE+I)-A(IB+I))-(A(IC+I)-A(IF+I)))
    ldr d0, [x29, #640]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #520]
// Original source line 2191: T4=ZSIN60*((A(IC+I)+A(IF+I))-(A(IB+I)+A(IE+I)))
    ldr d0, [x29, #640]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #536]
// Original source line 2192: A11=(A(IC+I)+A(IF+I))+(A(IB+I)+A(IE+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2193: T3=Z*((A(IA+I)+A(ID+I))-0.5_JPRB*A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldr d3, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #528]
// Original source line 2194: A(IA+I)=Z*((A(IA+I)+A(ID+I))+A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2195: A(IB+I)=T1
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2196: A(IC+I)=T2
    ldr d0, [x29, #520]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2197: A(ID+I)=T3
    ldr d0, [x29, #528]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2198: A(IE+I)=T4
    ldr d0, [x29, #536]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2199: A(IF+I)=T5
    ldr d0, [x29, #544]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2200: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2201: 692 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1848]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_378
.Lmd2asm_fft992_qpassf_do_done_379:
// Original source line 2202: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2203: 694 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1832]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_376
.Lmd2asm_fft992_qpassf_do_done_377:
// Original source line 2204: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_375
.Lmd2asm_fft992_qpassf_if_false_374:
// Original source line 2205: DO 698 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1856]
    mov x9, #1
    str x9, [x29, #1864]
.Lmd2asm_fft992_qpassf_do_380:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1856]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_381
// Original source line 2206: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2207: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 2210: DO 696 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1872]
    mov x10, #1
    str x10, [x29, #1880]
.Lmd2asm_fft992_qpassf_do_382:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1872]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_383
// Original source line 2211: A11=(A(IC+I)+A(IF+I))+(A(IB+I)+A(IE+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2212: C(JA+J)=Z*((A(IA+I)+A(ID+I))+A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2213: C(JC+J)=Z*((A(IA+I)+A(ID+I))-0.5_JPRB*A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldr d3, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2214: D(JC+J)=ZSIN60*((A(IC+I)+A(IF+I))-(A(IB+I)+A(IE+I)))
    ldr d0, [x29, #640]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2215: A11=(A(IC+I)-A(IF+I))+(A(IE+I)-A(IB+I))
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d0, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #320]
// Original source line 2216: C(JB+J)=Z*((A(IA+I)-A(ID+I))-0.5_JPRB*A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    adrp x16, .Lfft_constant_0
    ldr d2, [x16, :lo12:.Lfft_constant_0]
    ldr d3, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d2,d2,d3 // fmul d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2217: D(JB+J)=ZSIN60*((A(IE+I)-A(IB+I))-(A(IC+I)-A(IF+I)))
    ldr d0, [x29, #640]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2218: C(JD+J)=Z*((A(IA+I)-A(ID+I))+A11)
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldr d2, [x29, #320]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2219: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2220: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 2221: 696 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1880]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_382
.Lmd2asm_fft992_qpassf_do_done_383:
// Original source line 2222: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2223: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 2224: 698 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1864]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_380
.Lmd2asm_fft992_qpassf_do_done_381:
// Original source line 2225: ENDIF
.Lmd2asm_fft992_qpassf_if_end_375:
// Original source line 2226: ENDIF
.Lmd2asm_fft992_qpassf_if_end_355:
// Original source line 2228: ELSEIF (IFAC.EQ.8) THEN
    b .Lmd2asm_fft992_qpassf_if_end_229
.Lmd2asm_fft992_qpassf_elseif_false_353:
    ldrsw x9, [x29, #704]
    mov x10, #8
    cmp x9, x10
    cset x9, eq
    cbz x9, .Lmd2asm_fft992_qpassf_elseif_false_384
// Original source line 2232: 800 CONTINUE
// Original source line 2233: IF (LA.NE.M) THEN
    ldrsw x9, [x29, #712]
    ldrsw x10, [x29, #992]
    cmp x9, x10
    cset x9, ne
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_385
// Original source line 2234: IBAD=3
    mov x9, #3
    str w9, [x29, #768]
// Original source line 2235: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_386
.Lmd2asm_fft992_qpassf_if_false_385:
// Original source line 2236: IA=1
    mov x9, #1
    str w9, [x29, #752]
// Original source line 2237: IB=IA+IINK
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #760]
// Original source line 2238: IC=IB+IINK
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #784]
// Original source line 2239: ID=IC+IINK
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #792]
// Original source line 2240: IE=ID+IINK
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #800]
// Original source line 2241: IF=IE+IINK
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #808]
// Original source line 2242: IG=IF+IINK
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #816]
// Original source line 2243: IH=IG+IINK
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #720]
    add x9, x9, x10
    str w9, [x29, #824]
// Original source line 2244: JA=1
    mov x9, #1
    str w9, [x29, #864]
// Original source line 2245: JB=JA+LA*INC2
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #712]
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #872]
// Original source line 2246: JC=JB+2*M*INC2
    ldrsw x9, [x29, #872]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #880]
// Original source line 2247: JD=JC+2*M*INC2
    ldrsw x9, [x29, #880]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #888]
// Original source line 2248: JE=JD+2*M*INC2
    ldrsw x9, [x29, #888]
    mov x10, #2
    ldrsw x11, [x29, #992]
    mul x10, x10, x11
    ldrsw x11, [x29, #672]
    mul x10, x10, x11
    add x9, x9, x10
    str w9, [x29, #896]
// Original source line 2249: Z=1.0_JPRB/REAL(N,KIND=JPRB)
    adrp x16, .Lfft_constant_10
    ldr d0, [x16, :lo12:.Lfft_constant_10]
    ldrsw x9, [x29, #248]
 md2asm_gpu_upper_operation md2asm_gpu_startup_integer_cell_host,17,d1,x9 // scvtf d1, x9
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0, d0, d1
    str d0, [x29, #568]
// Original source line 2250: ZSIN45=Z*SQRT(0.5_JPRB)
    ldr d0, [x29, #568]
    adrp x16, .Lfft_constant_7
    ldr d1, [x16, :lo12:.Lfft_constant_7]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #632]
// Original source line 2252: IF (LIPL) THEN
    ldrsw x9, [x29, #1000]
    cbz x9, .Lmd2asm_fft992_qpassf_if_false_387
// Original source line 2253: DO 820 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1888]
    mov x9, #1
    str x9, [x29, #1896]
.Lmd2asm_fft992_qpassf_do_389:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1888]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_390
// Original source line 2254: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2257: DO 810 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1904]
    mov x10, #1
    str x10, [x29, #1912]
.Lmd2asm_fft992_qpassf_do_391:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1904]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_392
// Original source line 2258: T3=Z*((A(IA+I)+A(IE+I))-(A(IC+I)+A(IG+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #528]
// Original source line 2259: T4=Z*((A(ID+I)+A(IH+I))-(A(IB+I)+A(IF+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #536]
// Original source line 2260: T1=Z*(A(IA+I)-A(IE+I))+ZSIN45*((A(IH+I)-A(ID+I))-(A(IF+I)-A(IB+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #512]
// Original source line 2262: T5=Z*(A(IA+I)-A(IE+I))-ZSIN45*((A(IH+I)-A(ID+I))-(A(IF+I)-A(IB+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #544]
// Original source line 2264: T2=ZSIN45*((A(IH+I)-A(ID+I))+(A(IF+I)-A(IB+I)))+Z*(A(IG+I)-A(IC+I))
    ldr d0, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #568]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    str d0, [x29, #520]
// Original source line 2266: T6=ZSIN45*((A(IH+I)-A(ID+I))+(A(IF+I)-A(IB+I)))-Z*(A(IG+I)-A(IC+I))
    ldr d0, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #568]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    str d0, [x29, #552]
// Original source line 2268: T7=Z*(((A(IA+I)+A(IE+I))+(A(IC+I)+A(IG+I)))-((A(ID+I)+A(IH+I))+(A(IB+I)+A(IF+I))))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    str d0, [x29, #560]
// Original source line 2270: A(IA+I)=Z*(((A(IA+I)+A(IE+I))+(A(IC+I)+A(IG+I)))+((A(ID+I)+A(IH+I))+(A(IB+I)+A(IF+I))))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2272: A(IB+I)=T1
    ldr d0, [x29, #512]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2273: A(IC+I)=T2
    ldr d0, [x29, #520]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2274: A(ID+I)=T3
    ldr d0, [x29, #528]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2275: A(IE+I)=T4
    ldr d0, [x29, #536]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2276: A(IF+I)=T5
    ldr d0, [x29, #544]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2277: A(IG+I)=T6
    ldr d0, [x29, #552]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2278: A(IH+I)=T7
    ldr d0, [x29, #560]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2279: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2280: 810 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1912]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_391
.Lmd2asm_fft992_qpassf_do_done_392:
// Original source line 2281: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2282: 820 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1896]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_389
.Lmd2asm_fft992_qpassf_do_done_390:
// Original source line 2283: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_388
.Lmd2asm_fft992_qpassf_if_false_387:
// Original source line 2284: DO 840 L=1,ILA
    mov x9, #1
    str w9, [x29, #984]
    ldrsw x9, [x29, #840]
    str x9, [x29, #1920]
    mov x9, #1
    str x9, [x29, #1928]
.Lmd2asm_fft992_qpassf_do_393:
    ldrsw x9, [x29, #984]
    ldr x10, [x29, #1920]
    cmp x9, x10
    b.gt .Lmd2asm_fft992_qpassf_do_done_394
// Original source line 2285: I=IBASE
    ldrsw x10, [x29, #776]
    str w10, [x29, #744]
// Original source line 2286: J=JBASE
    ldrsw x10, [x29, #904]
    str w10, [x29, #856]
// Original source line 2289: DO 830 IJK=1,ILOT
    mov x10, #1
    str w10, [x29, #728]
    ldrsw x10, [x29, #736]
    str x10, [x29, #1936]
    mov x10, #1
    str x10, [x29, #1944]
.Lmd2asm_fft992_qpassf_do_395:
    ldrsw x10, [x29, #728]
    ldr x9, [x29, #1936]
    cmp x10, x9
    b.gt .Lmd2asm_fft992_qpassf_do_done_396
// Original source line 2290: C(JA+J)=Z*(((A(IA+I)+A(IE+I))+(A(IC+I)+A(IG+I)))+((A(ID+I)+A(IH+I))+(A(IB+I)+A(IF+I))))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #864]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2292: C(JE+J)=Z*(((A(IA+I)+A(IE+I))+(A(IC+I)+A(IG+I)))-((A(ID+I)+A(IH+I))+(A(IB+I)+A(IF+I))))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d3,d3,d4 // fadd d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #896]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2294: C(JC+J)=Z*((A(IA+I)+A(IE+I))-(A(IC+I)+A(IG+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2295: D(JC+J)=Z*((A(ID+I)+A(IH+I))-(A(IB+I)+A(IF+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d2,d2,d3 // fadd d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldrsw x9, [x29, #880]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2296: C(JB+J)=Z*(A(IA+I)-A(IE+I))+ZSIN45*((A(IH+I)-A(ID+I))-(A(IF+I)-A(IB+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2298: C(JD+J)=Z*(A(IA+I)-A(IE+I))-ZSIN45*((A(IH+I)-A(ID+I))-(A(IF+I)-A(IB+I)))
    ldr d0, [x29, #568]
    ldrsw x9, [x29, #752]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #800]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d4, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d3,d3,d4 // fsub d3, d3, d4
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #144]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2300: D(JB+J)=ZSIN45*((A(IH+I)-A(ID+I))+(A(IF+I)-A(IB+I)))+Z*(A(IG+I)-A(IC+I))
    ldr d0, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #568]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0, d0, d1
    ldrsw x9, [x29, #872]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2302: D(JD+J)=ZSIN45*((A(IH+I)-A(ID+I))+(A(IF+I)-A(IB+I)))-Z*(A(IG+I)-A(IC+I))
    ldr d0, [x29, #632]
    ldrsw x9, [x29, #824]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d1, [x16, x9, lsl #3]
    ldrsw x9, [x29, #792]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d1,d1,d2 // fsub d1, d1, d2
    ldrsw x9, [x29, #808]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #760]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d1,d1,d2 // fadd d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d0,d1 // fmul d0, d0, d1
    ldr d1, [x29, #568]
    ldrsw x9, [x29, #816]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d2, [x16, x9, lsl #3]
    ldrsw x9, [x29, #784]
    ldrsw x10, [x29, #744]
    add x9, x9, x10
    ldr x16, [x29, #128]
    sub x9, x9, #1
    ldr d3, [x16, x9, lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d2,d2,d3 // fsub d2, d2, d3
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d1,d1,d2 // fmul d1, d1, d2
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,1,d0,d0,d1 // fsub d0, d0, d1
    ldrsw x9, [x29, #888]
    ldrsw x10, [x29, #856]
    add x9, x9, x10
    ldr x16, [x29, #152]
    sub x9, x9, #1
    str d0, [x16, x9, lsl #3]
// Original source line 2304: I=I+INC3
    ldrsw x9, [x29, #744]
    ldrsw x10, [x29, #680]
    add x9, x9, x10
    str w9, [x29, #744]
// Original source line 2305: J=J+INC4
    ldrsw x9, [x29, #856]
    ldrsw x10, [x29, #688]
    add x9, x9, x10
    str w9, [x29, #856]
// Original source line 2306: 830 CONTINUE
    ldrsw x9, [x29, #728]
    ldr x10, [x29, #1944]
    add x9, x9, x10
    str x9, [x29, #728]
    b .Lmd2asm_fft992_qpassf_do_395
.Lmd2asm_fft992_qpassf_do_done_396:
// Original source line 2307: IBASE=IBASE+INC11
    ldrsw x10, [x29, #776]
    ldrsw x9, [x29, #848]
    add x10, x10, x9
    str w10, [x29, #776]
// Original source line 2308: JBASE=JBASE+INC2
    ldrsw x10, [x29, #904]
    ldrsw x9, [x29, #672]
    add x10, x10, x9
    str w10, [x29, #904]
// Original source line 2309: 840 CONTINUE
    ldrsw x10, [x29, #984]
    ldr x9, [x29, #1928]
    add x10, x10, x9
    str x10, [x29, #984]
    b .Lmd2asm_fft992_qpassf_do_393
.Lmd2asm_fft992_qpassf_do_done_394:
// Original source line 2310: ENDIF
.Lmd2asm_fft992_qpassf_if_end_388:
// Original source line 2312: ENDIF
.Lmd2asm_fft992_qpassf_if_end_386:
// Original source line 2314: ELSE
    b .Lmd2asm_fft992_qpassf_if_end_229
.Lmd2asm_fft992_qpassf_elseif_false_384:
// Original source line 2316: IBAD=2
    mov x9, #2
    str w9, [x29, #768]
// Original source line 2318: ENDIF
.Lmd2asm_fft992_qpassf_if_end_229:
// Original source line 2322: 900 CONTINUE
// Original source line 2323: IERR=IBAD
    ldrsw x9, [x29, #768]
    str w9, [x29, #656]
    ldr x16, [x29, #232]
    str w9, [x16]
.Lmd2asm_fft992_qpassf_return_225:
    mov sp, x29
    ldr x18, [sp, #16]
    ldp x29, x30, [sp]
    add sp, sp, #2048
    ret
.size md2asm_fft992_qpassf, .-md2asm_fft992_qpassf
.section .rodata
.p2align 3
.Lfft_constant_0:
    .quad 0x3fe0000000000000
.Lfft_constant_1:
    .quad 0x0000000000000000
.Lfft_constant_2:
    .quad 0x3fe2cf2304755a5d
.Lfft_constant_3:
    .quad 0x3fee6f0e13445503
.Lfft_constant_4:
    .quad 0x3fe1e3779b97f4a4
.Lfft_constant_5:
    .quad 0x3febb67ae8584c9c
.Lfft_constant_6:
    .quad 0x4000000000000000
.Lfft_constant_7:
    .quad 0x3fe6a09e667f3bcd
.Lfft_constant_8:
    .quad 0x3fd0000000000000
.Lfft_constant_9:
    .quad 0x3ff6a09e667f3bcd
.Lfft_constant_10:
    .quad 0x3ff0000000000000
.data
.p2align 3
.global md2asm_fft992_calls
.protected md2asm_fft992_calls
md2asm_fft992_calls:
    .quad 0
.global md2asm_fft992_rpassf_calls
.protected md2asm_fft992_rpassf_calls
md2asm_fft992_rpassf_calls:
    .quad 0
.global md2asm_fft992_qpassf_calls
.protected md2asm_fft992_qpassf_calls
md2asm_fft992_qpassf_calls:
    .quad 0
.protected md2asm_fft992_rpassf
.protected md2asm_fft992_qpassf
.section .note.GNU-stack,"",%progbits
