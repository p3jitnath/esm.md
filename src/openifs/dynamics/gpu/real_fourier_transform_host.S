// GPU contract: skills/md2fort-gpu/references/openifs/dynamics/real_fourier_transform.md.
// Complete direct FFT992 and its contained RPASSF and QPASSF.
// Physics: formulations/openifs/dynamics/real_fourier_transform.md.
// Contract: skills/md2fort/references/openifs/dynamics/real_fourier_transform.md.
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
 b md2asm_gpu_r23_fft992_phase_host
.size md2asm_fft992,.-md2asm_fft992
.p2align 4
.global md2asm_fft992_rpassf
.type md2asm_fft992_rpassf, %function
md2asm_fft992_rpassf:
 b md2asm_gpu_r23_fft992_rpassf_phase_host
.size md2asm_fft992_rpassf,.-md2asm_fft992_rpassf
.p2align 4
.global md2asm_fft992_qpassf
.type md2asm_fft992_qpassf, %function
md2asm_fft992_qpassf:
 b md2asm_gpu_r23_fft992_qpassf_phase_host
.size md2asm_fft992_qpassf,.-md2asm_fft992_qpassf
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

// Contract: skills/md2fort-gpu/references/openifs/dynamics/real_fourier_transform.md.
.arch armv8-a
.text
.p2align 4
.macro r23_fft992_service target
 bl \target
 ldr x18,[x28,#144]
.endm
.global md2asm_gpu_r23_fft992_phase_host
.type md2asm_gpu_r23_fft992_phase_host,%function
md2asm_gpu_r23_fft992_phase_host:
 sub sp,sp,#2048
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 stp x16,x17,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 stp x28,x29,[sp,#224]
 str x30,[sp,#240]
 stp q0,q1,[sp,#256]
 stp q2,q3,[sp,#288]
 stp q4,q5,[sp,#320]
 stp q6,q7,[sp,#352]
 stp q8,q9,[sp,#384]
 stp q10,q11,[sp,#416]
 stp q12,q13,[sp,#448]
 stp q14,q15,[sp,#480]
 stp q16,q17,[sp,#512]
 stp q18,q19,[sp,#544]
 stp q20,q21,[sp,#576]
 stp q22,q23,[sp,#608]
 stp q24,q25,[sp,#640]
 stp q26,q27,[sp,#672]
 stp q28,q29,[sp,#704]
 stp q30,q31,[sp,#736]
 mrs x9,fpcr
 mrs x10,fpsr
 mrs x11,nzcv
 str x9,[sp,#768]
 str x10,[sp,#776]
 str x11,[sp,#784]
 mov x28,sp
 cbnz x9,.Lr23_fft992_fatal
 r23_fft992_service __errno_location
 str x0,[x28,#792]
 ldr w9,[x0]
 str w9,[x28,#800]
 r23_fft992_service omp_in_parallel
 cbnz w0,.Lr23_fft992_fatal
 r23_fft992_service md2asm_openifs_gpu_prepare
 cbnz w0,.Lr23_fft992_fatal
 add x19,x28,#832
 mov x9,#0
.Lr23_fft992_zero:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#32
 b.lo .Lr23_fft992_zero
 ldr x9,[x28,#0]
 str x9,[x19,#0]
 ldr x9,[x28,#8]
 str x9,[x19,#8]
 ldr x9,[x28,#16]
 str x9,[x19,#16]
 ldr x9,[x28,#24]
 str x9,[x19,#24]
 ldr x9,[x28,#32]
 str x9,[x19,#32]
 ldr x9,[x28,#40]
 str x9,[x19,#40]
 ldr x9,[x28,#48]
 str x9,[x19,#48]
 ldr x9,[x28,#56]
 str x9,[x19,#56]
// Integer-only selection of independent interleaved fields.
 ldr x9,[x19,#0]
 cbz x9,.Lfft_lot_serial
 tst x9,#7
 b.ne .Lfft_lot_serial
 adds x10,x9,#8
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#8]
 cbz x9,.Lfft_lot_serial
 tst x9,#7
 b.ne .Lfft_lot_serial
 adds x10,x9,#8
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#16]
 cbz x9,.Lfft_lot_serial
 tst x9,#3
 b.ne .Lfft_lot_serial
 adds x10,x9,#4
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#24]
 cbz x9,.Lfft_lot_serial
 tst x9,#3
 b.ne .Lfft_lot_serial
 adds x10,x9,#4
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#32]
 cbz x9,.Lfft_lot_serial
 tst x9,#3
 b.ne .Lfft_lot_serial
 adds x10,x9,#4
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#40]
 cbz x9,.Lfft_lot_serial
 tst x9,#3
 b.ne .Lfft_lot_serial
 adds x10,x9,#4
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#48]
 cbz x9,.Lfft_lot_serial
 tst x9,#3
 b.ne .Lfft_lot_serial
 adds x10,x9,#4
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#56]
 cbz x9,.Lfft_lot_serial
 tst x9,#3
 b.ne .Lfft_lot_serial
 adds x10,x9,#4
 b.cs .Lfft_lot_serial
 tbnz x10,#63,.Lfft_lot_serial
 ldr x9,[x19,#48]
 ldrsw x22,[x9]
 cmp x22,#2
 b.lt .Lfft_lot_serial
 ldr x9,[x19,#24]
 ldrsw x10,[x9]
 cmp x10,x22
 b.ne .Lfft_lot_serial
 ldr x9,[x19,#32]
 ldrsw x10,[x9]
 cmp x10,#1
 b.ne .Lfft_lot_serial
 ldr x9,[x19,#40]
 ldrsw x23,[x9]
 cmp x23,#0
 b.le .Lfft_lot_serial
 ldr x9,[x19,#56]
 ldr w10,[x9]
 cmp w10,#1
 b.eq .Lfft_lot_sign_ok
 cmn w10,#1
 b.ne .Lfft_lot_serial
.Lfft_lot_sign_ok:
 add x9,x23,#2
 mul x24,x9,x22
 mov x10,#0x7fffffff
 cmp x24,x10
 b.hi .Lfft_lot_serial
 lsl x24,x24,#3
 ldr x20,[x19]
 adds x25,x20,x24
 b.cs .Lfft_lot_serial
 tbnz x25,#63,.Lfft_lot_serial
 adrp x26,md2asm_fft992_calls
 add x26,x26,:lo12:md2asm_fft992_calls
 add x27,x26,#24
 cmp x20,x27
 b.hs .Lfft_lot_a_count_ok
 cmp x26,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_a_count_ok:
 ldr x4,[x19,#8]
 lsl x5,x23,#3
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_1
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_1:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_1
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_1:
 ldr x4,[x19,#16]
 mov x5,#40
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_2
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_2:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_2
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_2:
 ldr x4,[x19,#24]
 mov x5,#4
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_3
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_3:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_3
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_3:
 ldr x4,[x19,#32]
 mov x5,#4
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_4
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_4:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_4
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_4:
 ldr x4,[x19,#40]
 mov x5,#4
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_5
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_5:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_5
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_5:
 ldr x4,[x19,#48]
 mov x5,#4
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_6
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_6:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_6
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_6:
 ldr x4,[x19,#56]
 mov x5,#4
 adds x5,x4,x5
 b.cs .Lfft_lot_serial
 tbnz x5,#63,.Lfft_lot_serial
 cmp x20,x5
 b.hs .Lfft_lot_ro_a_7
 cmp x4,x25
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_a_7:
 cmp x26,x5
 b.hs .Lfft_lot_ro_c_7
 cmp x4,x27
 b.lo .Lfft_lot_serial
.Lfft_lot_ro_c_7:
 ldr x4,[x19,#16]
 ldr w5,[x4]
 cmp w5,#1
 b.lt .Lfft_lot_serial
 cmp w5,#9
 b.gt .Lfft_lot_serial
 mov x6,#1
 mov w7,#0
.Lfft_lot_factors:
 add x8,x4,#4
 ldr w9,[x8,w7,uxtw #2]
 cmp w9,#8
 b.eq .Lfft_lot_factor8
 cmp w9,#2
 b.lt .Lfft_lot_serial
 cmp w9,#6
 b.gt .Lfft_lot_serial
 b .Lfft_lot_factor_ok
.Lfft_lot_factor8:
 add w10,w7,#1
 cmp w10,w5
 b.ne .Lfft_lot_serial
.Lfft_lot_factor_ok:
 mul x6,x6,x9
 cmp x6,x23
 b.hi .Lfft_lot_serial
 add w7,w7,#1
 cmp w7,w5
 b.lo .Lfft_lot_factors
 cmp x6,x23
 b.ne .Lfft_lot_serial
 mov x9,#32
 cmp x22,x9
 csel x9,x22,x9,lo
 str w9,[x19,#100]
 add x10,x23,#1
 lsl x10,x10,#3
 add x10,x10,#79
 and x10,x10,#-16
 add x10,x10,#4096
 add x10,x10,#64
 str x10,[x19,#104]
.Lfft_lot_serial:
 ldr w9,[x19,#100]
 cbz w9,.Lfft_lot_serial_alloc
 ldr x10,[x19,#104]
 mul x9,x9,x10
 b .Lfft_lot_alloc_ready
.Lfft_lot_serial_alloc:
 ldr x9,[x28,#40]
 ldrsw x9,[x9]
 ldr x10,[x28,#48]
 ldrsw x10,[x10]
 mul x9,x9,x10
 add x9,x9,#1
 lsl x9,x9,#3
 add x9,x9,#79
 and x9,x9,#-16
 add x9,x9,#4096
.Lfft_lot_alloc_ready:
 sub sp,sp,x9
 mov x10,sp
 str x10,[x19,#80]
 str x9,[x19,#88]
 mov x10,sp
.Lr23_fft992_touch:
 str xzr,[x10]
 add x10,x10,#4096
 cmp x10,x28
 b.lo .Lr23_fft992_touch
 mov x9,x28
 str x9,[x19,#64]
 adrp x9,md2asm_fft992_calls
 add x9,x9,:lo12:md2asm_fft992_calls
 str x9,[x19,#72]
 mov w9,#0
 str w9,[x19,#96]
 add x21,x28,#960
 add x20,x28,#976
 mov w14,#1
 str w14,[x20,#4]
 ldr w14,[x28,#776]
 str w14,[x20,#8]
 add x16,x28,#1040
 str x16,[x20,#48]
 mov x15,#32
 str x15,[x20,#56]
 mov x14,#128
 str x14,[x16]
 mov x14,#16
 str x14,[x16,#8]
 ldr x14,[x19,#88]
 str x14,[x16,#16]
 mov x14,#24
 str x14,[x16,#24]
 add x17,x28,#1072
 stp x19,x21,[x17]
 ldr x9,[x28,#768]
 ldr x10,[x28,#776]
 msr fpcr,x9
 msr fpsr,x10
 ldr x9,[x28,#792]
 ldr w10,[x28,#800]
 str w10,[x9]
 ldr w9,[x19,#100]
 cbz w9,.Lfft_lot_serial_entry
 adrp x0,.Lfft_lot_parallel_entry
 add x0,x0,:lo12:.Lfft_lot_parallel_entry
 b .Lfft_lot_entry_ready
.Lfft_lot_serial_entry:
 adrp x0,.Lr23_fft992_entry
 add x0,x0,:lo12:.Lr23_fft992_entry
.Lfft_lot_entry_ready:
 add x1,x28,#1072
 mov x2,x20
 mov w3,#1
 ldr w4,[x19,#100]
 cmp w4,#0
 csinc w4,w4,wzr,ne
 mov w5,#0
 r23_fft992_service md2asm_openifs_gpu_launch
 cbnz w0,.Lr23_fft992_fatal
 ldr w9,[x20]
 cbnz w9,.Lr23_fft992_fatal
 ldr w9,[x21]
 str w9,[x28,#1088]
 ldr x9,[x28,#768]
 msr fpcr,x9
 ldr x9,[x28,#776]
 ldr w10,[x20,#8]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x9,[x28,#792]
 ldr w10,[x28,#800]
 ldr w11,[x21,#12]
 cbz w11,.Lr23_fft992_errno_ready
 ldr w10,[x21,#8]
.Lr23_fft992_errno_ready:
 str w10,[x9]
 ldr x9,[x28,#784]
 msr nzcv,x9
 mov sp,x28
 ldp q0,q1,[sp,#256]
 ldp q2,q3,[sp,#288]
 ldp q4,q5,[sp,#320]
 ldp q6,q7,[sp,#352]
 ldp q8,q9,[sp,#384]
 ldp q10,q11,[sp,#416]
 ldp q12,q13,[sp,#448]
 ldp q14,q15,[sp,#480]
 ldp q16,q17,[sp,#512]
 ldp q18,q19,[sp,#544]
 ldp q20,q21,[sp,#576]
 ldp q22,q23,[sp,#608]
 ldp q24,q25,[sp,#640]
 ldp q26,q27,[sp,#672]
 ldp q28,q29,[sp,#704]
 ldp q30,q31,[sp,#736]
 ldp x0,x1,[sp,#0]
 ldp x2,x3,[sp,#16]
 ldp x4,x5,[sp,#32]
 ldp x6,x7,[sp,#48]
 ldp x8,x9,[sp,#64]
 ldp x10,x11,[sp,#80]
 ldp x12,x13,[sp,#96]
 ldp x14,x15,[sp,#112]
 ldp x16,x17,[sp,#128]
 ldp x18,x19,[sp,#144]
 ldp x20,x21,[sp,#160]
 ldp x22,x23,[sp,#176]
 ldp x24,x25,[sp,#192]
 ldp x26,x27,[sp,#208]
 ldp x28,x29,[sp,#224]
 ldr x30,[sp,#240]
 add sp,sp,#2048
 ret
.Lr23_fft992_fatal:
 bl abort
 brk #0
.size md2asm_gpu_r23_fft992_phase_host,.-md2asm_gpu_r23_fft992_phase_host
.section .rodata
.Lr23_fft992_entry:.asciz "md2asm_gpu_r23_fft992"
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2fort-gpu/references/openifs/dynamics/real_fourier_transform.md.
.arch armv8-a
.text
.p2align 4
.macro r23_fft992_rpassf_service target
 bl \target
 ldr x18,[x28,#144]
.endm
.global md2asm_gpu_r23_fft992_rpassf_phase_host
.type md2asm_gpu_r23_fft992_rpassf_phase_host,%function
md2asm_gpu_r23_fft992_rpassf_phase_host:
 sub sp,sp,#2048
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 stp x16,x17,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 stp x28,x29,[sp,#224]
 str x30,[sp,#240]
 stp q0,q1,[sp,#256]
 stp q2,q3,[sp,#288]
 stp q4,q5,[sp,#320]
 stp q6,q7,[sp,#352]
 stp q8,q9,[sp,#384]
 stp q10,q11,[sp,#416]
 stp q12,q13,[sp,#448]
 stp q14,q15,[sp,#480]
 stp q16,q17,[sp,#512]
 stp q18,q19,[sp,#544]
 stp q20,q21,[sp,#576]
 stp q22,q23,[sp,#608]
 stp q24,q25,[sp,#640]
 stp q26,q27,[sp,#672]
 stp q28,q29,[sp,#704]
 stp q30,q31,[sp,#736]
 mrs x9,fpcr
 mrs x10,fpsr
 mrs x11,nzcv
 str x9,[sp,#768]
 str x10,[sp,#776]
 str x11,[sp,#784]
 mov x28,sp
 cbnz x9,.Lr23_fft992_rpassf_fatal
 r23_fft992_rpassf_service __errno_location
 str x0,[x28,#792]
 ldr w9,[x0]
 str w9,[x28,#800]
 r23_fft992_rpassf_service omp_in_parallel
 cbnz w0,.Lr23_fft992_rpassf_fatal
 r23_fft992_rpassf_service md2asm_openifs_gpu_prepare
 cbnz w0,.Lr23_fft992_rpassf_fatal
 add x19,x28,#832
 mov x9,#0
.Lr23_fft992_rpassf_zero:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#32
 b.lo .Lr23_fft992_rpassf_zero
 ldr x9,[x28,#0]
 str x9,[x19,#0]
 ldr x9,[x28,#8]
 str x9,[x19,#8]
 ldr x9,[x28,#16]
 str x9,[x19,#16]
 ldr x9,[x28,#24]
 str x9,[x19,#24]
 ldr x9,[x28,#32]
 str x9,[x19,#32]
 ldr x9,[x28,#40]
 str x9,[x19,#40]
 ldr x9,[x28,#48]
 str x9,[x19,#48]
 ldr x9,[x28,#56]
 str x9,[x19,#56]
 mov x9,#2112
 sub sp,sp,x9
 mov x10,sp
 str x10,[x19,#80]
 str x9,[x19,#88]
 mov x10,sp
.Lr23_fft992_rpassf_touch:
 str xzr,[x10]
 add x10,x10,#4096
 cmp x10,x28
 b.lo .Lr23_fft992_rpassf_touch
 sub x9,x28,#64
 add x10,x28,#2048
 ldp x11,x12,[x10,#0]
 stp x11,x12,[x9,#0]
 ldp x11,x12,[x10,#16]
 stp x11,x12,[x9,#16]
 ldp x11,x12,[x10,#32]
 stp x11,x12,[x9,#32]
 ldp x11,x12,[x10,#48]
 stp x11,x12,[x9,#48]
 str x9,[x19,#64]
 adrp x9,md2asm_fft992_calls
 add x9,x9,:lo12:md2asm_fft992_calls
 str x9,[x19,#72]
 mov w9,#1
 str w9,[x19,#96]
 add x21,x28,#960
 add x20,x28,#976
 mov w14,#1
 str w14,[x20,#4]
 ldr w14,[x28,#776]
 str w14,[x20,#8]
 add x16,x28,#1040
 str x16,[x20,#48]
 mov x15,#32
 str x15,[x20,#56]
 mov x14,#128
 str x14,[x16]
 mov x14,#16
 str x14,[x16,#8]
 ldr x14,[x19,#88]
 str x14,[x16,#16]
 mov x14,#24
 str x14,[x16,#24]
 add x17,x28,#1072
 stp x19,x21,[x17]
 ldr x9,[x28,#768]
 ldr x10,[x28,#776]
 msr fpcr,x9
 msr fpsr,x10
 ldr x9,[x28,#792]
 ldr w10,[x28,#800]
 str w10,[x9]
 adrp x0,.Lr23_fft992_rpassf_entry
 add x0,x0,:lo12:.Lr23_fft992_rpassf_entry
 add x1,x28,#1072
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 r23_fft992_rpassf_service md2asm_openifs_gpu_launch
 cbnz w0,.Lr23_fft992_rpassf_fatal
 ldr w9,[x20]
 cbnz w9,.Lr23_fft992_rpassf_fatal
 ldr w9,[x21]
 str w9,[x28,#1088]
 ldr x9,[x28,#768]
 msr fpcr,x9
 ldr x9,[x28,#776]
 ldr w10,[x20,#8]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x9,[x28,#792]
 ldr w10,[x28,#800]
 ldr w11,[x21,#12]
 cbz w11,.Lr23_fft992_rpassf_errno_ready
 ldr w10,[x21,#8]
.Lr23_fft992_rpassf_errno_ready:
 str w10,[x9]
 ldr x9,[x28,#784]
 msr nzcv,x9
 mov sp,x28
 ldp q0,q1,[sp,#256]
 ldp q2,q3,[sp,#288]
 ldp q4,q5,[sp,#320]
 ldp q6,q7,[sp,#352]
 ldp q8,q9,[sp,#384]
 ldp q10,q11,[sp,#416]
 ldp q12,q13,[sp,#448]
 ldp q14,q15,[sp,#480]
 ldp q16,q17,[sp,#512]
 ldp q18,q19,[sp,#544]
 ldp q20,q21,[sp,#576]
 ldp q22,q23,[sp,#608]
 ldp q24,q25,[sp,#640]
 ldp q26,q27,[sp,#672]
 ldp q28,q29,[sp,#704]
 ldp q30,q31,[sp,#736]
 ldp x0,x1,[sp,#0]
 ldp x2,x3,[sp,#16]
 ldp x4,x5,[sp,#32]
 ldp x6,x7,[sp,#48]
 ldp x8,x9,[sp,#64]
 ldp x10,x11,[sp,#80]
 ldp x12,x13,[sp,#96]
 ldp x14,x15,[sp,#112]
 ldp x16,x17,[sp,#128]
 ldp x18,x19,[sp,#144]
 ldp x20,x21,[sp,#160]
 ldp x22,x23,[sp,#176]
 ldp x24,x25,[sp,#192]
 ldp x26,x27,[sp,#208]
 ldp x28,x29,[sp,#224]
 ldr x30,[sp,#240]
 add sp,sp,#2048
 ret
.Lr23_fft992_rpassf_fatal:
 bl abort
 brk #0
.size md2asm_gpu_r23_fft992_rpassf_phase_host,.-md2asm_gpu_r23_fft992_rpassf_phase_host
.section .rodata
.Lr23_fft992_rpassf_entry:.asciz "md2asm_gpu_r23_fft992_rpassf"
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2fort-gpu/references/openifs/dynamics/real_fourier_transform.md.
.arch armv8-a
.text
.p2align 4
.macro r23_fft992_qpassf_service target
 bl \target
 ldr x18,[x28,#144]
.endm
.global md2asm_gpu_r23_fft992_qpassf_phase_host
.type md2asm_gpu_r23_fft992_qpassf_phase_host,%function
md2asm_gpu_r23_fft992_qpassf_phase_host:
 sub sp,sp,#2048
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 stp x16,x17,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 stp x28,x29,[sp,#224]
 str x30,[sp,#240]
 stp q0,q1,[sp,#256]
 stp q2,q3,[sp,#288]
 stp q4,q5,[sp,#320]
 stp q6,q7,[sp,#352]
 stp q8,q9,[sp,#384]
 stp q10,q11,[sp,#416]
 stp q12,q13,[sp,#448]
 stp q14,q15,[sp,#480]
 stp q16,q17,[sp,#512]
 stp q18,q19,[sp,#544]
 stp q20,q21,[sp,#576]
 stp q22,q23,[sp,#608]
 stp q24,q25,[sp,#640]
 stp q26,q27,[sp,#672]
 stp q28,q29,[sp,#704]
 stp q30,q31,[sp,#736]
 mrs x9,fpcr
 mrs x10,fpsr
 mrs x11,nzcv
 str x9,[sp,#768]
 str x10,[sp,#776]
 str x11,[sp,#784]
 mov x28,sp
 cbnz x9,.Lr23_fft992_qpassf_fatal
 r23_fft992_qpassf_service __errno_location
 str x0,[x28,#792]
 ldr w9,[x0]
 str w9,[x28,#800]
 r23_fft992_qpassf_service omp_in_parallel
 cbnz w0,.Lr23_fft992_qpassf_fatal
 r23_fft992_qpassf_service md2asm_openifs_gpu_prepare
 cbnz w0,.Lr23_fft992_qpassf_fatal
 add x19,x28,#832
 mov x9,#0
.Lr23_fft992_qpassf_zero:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#32
 b.lo .Lr23_fft992_qpassf_zero
 ldr x9,[x28,#0]
 str x9,[x19,#0]
 ldr x9,[x28,#8]
 str x9,[x19,#8]
 ldr x9,[x28,#16]
 str x9,[x19,#16]
 ldr x9,[x28,#24]
 str x9,[x19,#24]
 ldr x9,[x28,#32]
 str x9,[x19,#32]
 ldr x9,[x28,#40]
 str x9,[x19,#40]
 ldr x9,[x28,#48]
 str x9,[x19,#48]
 ldr x9,[x28,#56]
 str x9,[x19,#56]
 mov x9,#2112
 sub sp,sp,x9
 mov x10,sp
 str x10,[x19,#80]
 str x9,[x19,#88]
 mov x10,sp
.Lr23_fft992_qpassf_touch:
 str xzr,[x10]
 add x10,x10,#4096
 cmp x10,x28
 b.lo .Lr23_fft992_qpassf_touch
 sub x9,x28,#64
 add x10,x28,#2048
 ldp x11,x12,[x10,#0]
 stp x11,x12,[x9,#0]
 ldp x11,x12,[x10,#16]
 stp x11,x12,[x9,#16]
 ldp x11,x12,[x10,#32]
 stp x11,x12,[x9,#32]
 ldp x11,x12,[x10,#48]
 stp x11,x12,[x9,#48]
 str x9,[x19,#64]
 adrp x9,md2asm_fft992_calls
 add x9,x9,:lo12:md2asm_fft992_calls
 str x9,[x19,#72]
 mov w9,#2
 str w9,[x19,#96]
 add x21,x28,#960
 add x20,x28,#976
 mov w14,#1
 str w14,[x20,#4]
 ldr w14,[x28,#776]
 str w14,[x20,#8]
 add x16,x28,#1040
 str x16,[x20,#48]
 mov x15,#32
 str x15,[x20,#56]
 mov x14,#128
 str x14,[x16]
 mov x14,#16
 str x14,[x16,#8]
 ldr x14,[x19,#88]
 str x14,[x16,#16]
 mov x14,#24
 str x14,[x16,#24]
 add x17,x28,#1072
 stp x19,x21,[x17]
 ldr x9,[x28,#768]
 ldr x10,[x28,#776]
 msr fpcr,x9
 msr fpsr,x10
 ldr x9,[x28,#792]
 ldr w10,[x28,#800]
 str w10,[x9]
 adrp x0,.Lr23_fft992_qpassf_entry
 add x0,x0,:lo12:.Lr23_fft992_qpassf_entry
 add x1,x28,#1072
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 r23_fft992_qpassf_service md2asm_openifs_gpu_launch
 cbnz w0,.Lr23_fft992_qpassf_fatal
 ldr w9,[x20]
 cbnz w9,.Lr23_fft992_qpassf_fatal
 ldr w9,[x21]
 str w9,[x28,#1088]
 ldr x9,[x28,#768]
 msr fpcr,x9
 ldr x9,[x28,#776]
 ldr w10,[x20,#8]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x9,[x28,#792]
 ldr w10,[x28,#800]
 ldr w11,[x21,#12]
 cbz w11,.Lr23_fft992_qpassf_errno_ready
 ldr w10,[x21,#8]
.Lr23_fft992_qpassf_errno_ready:
 str w10,[x9]
 ldr x9,[x28,#784]
 msr nzcv,x9
 mov sp,x28
 ldp q0,q1,[sp,#256]
 ldp q2,q3,[sp,#288]
 ldp q4,q5,[sp,#320]
 ldp q6,q7,[sp,#352]
 ldp q8,q9,[sp,#384]
 ldp q10,q11,[sp,#416]
 ldp q12,q13,[sp,#448]
 ldp q14,q15,[sp,#480]
 ldp q16,q17,[sp,#512]
 ldp q18,q19,[sp,#544]
 ldp q20,q21,[sp,#576]
 ldp q22,q23,[sp,#608]
 ldp q24,q25,[sp,#640]
 ldp q26,q27,[sp,#672]
 ldp q28,q29,[sp,#704]
 ldp q30,q31,[sp,#736]
 ldp x0,x1,[sp,#0]
 ldp x2,x3,[sp,#16]
 ldp x4,x5,[sp,#32]
 ldp x6,x7,[sp,#48]
 ldp x8,x9,[sp,#64]
 ldp x10,x11,[sp,#80]
 ldp x12,x13,[sp,#96]
 ldp x14,x15,[sp,#112]
 ldp x16,x17,[sp,#128]
 ldp x18,x19,[sp,#144]
 ldp x20,x21,[sp,#160]
 ldp x22,x23,[sp,#176]
 ldp x24,x25,[sp,#192]
 ldp x26,x27,[sp,#208]
 ldp x28,x29,[sp,#224]
 ldr x30,[sp,#240]
 add sp,sp,#2048
 ret
.Lr23_fft992_qpassf_fatal:
 bl abort
 brk #0
.size md2asm_gpu_r23_fft992_qpassf_phase_host,.-md2asm_gpu_r23_fft992_qpassf_phase_host
.section .rodata
.Lr23_fft992_qpassf_entry:.asciz "md2asm_gpu_r23_fft992_qpassf"
.section .note.GNU-stack,"",%progbits

.section .rodata
.Lfft_lot_parallel_entry:.asciz "md2asm_gpu_fft992_LOT_parallel"
.section .note.GNU-stack,"",%progbits
