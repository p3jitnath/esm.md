/* Contract skills/md2asm/references/openifs/input/streaming_runtime_spectral_loading.md.
 * Private bit-preserving scatter into an uncommitted spectral preimage.
 * x0 is the validated128-byte context, x1 is one decoded global row,
 * and x2 is its zero-based source record index. Only x0 through x17 change.
 * Stack, saved registers, FPCR/FPSR and errno remain unchanged.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_scatter_streaming_runtime_spectral_record
.hidden md2asm_scatter_streaming_runtime_spectral_record
.type md2asm_scatter_streaming_runtime_spectral_record,%function
md2asm_scatter_streaming_runtime_spectral_record:
 cbz x2,.Lss_surface_first
 ldr x3,[x0,#88]
 mov x4,#3
 madd x3,x3,x4,xzr
 add x3,x3,#1
 cmp x2,x3
 b.eq .Lss_surface_last
 ldr x3,[x0,#16]
 cbz x3,.Lss_done
 sub x4,x2,#1
 mov x5,#3
 udiv x6,x4,x5
 msub x7,x6,x5,x4
 add x6,x6,#1
 ldr x8,[x0,#72]
 mov x4,#0
.Lss_find_level:
 ldr w5,[x8,x4,lsl#2]
 cmp x5,x6
 b.eq .Lss_volume
 b.hi .Lss_done
 add x4,x4,#1
 cmp x4,x3
 b.lo .Lss_find_level
 b .Lss_done
.Lss_volume:
 ldr x6,[x0]
 ldr x8,[x0,#24]
 mul x7,x7,x8
 mul x7,x7,x3
 add x7,x7,x4
 add x6,x6,x7,lsl#3
 lsl x3,x3,#3
 b .Lss_waves
.Lss_surface_first:
 mov x7,#0
 b .Lss_surface
.Lss_surface_last:
 mov x7,#1
.Lss_surface:
 ldr x3,[x0,#32]
 cbz x3,.Lss_done
 ldr x6,[x0,#8]
 ldr x8,[x0,#24]
 mul x7,x7,x8
 add x6,x6,x7,lsl#3
 mov x3,#8
.Lss_waves:
 ldr x7,[x0,#40]
 cbz x7,.Lss_done
 ldr x8,[x0,#48]
 ldr x9,[x0,#56]
 ldr x10,[x0,#64]
 ldr x11,[x0,#80]
 add x11,x11,#1
 mov x4,#0
.Lss_wave:
 ldr w5,[x8,x4,lsl#2]
 ldr w12,[x9,x5,lsl#2]
 sub x12,x12,#1
 madd x12,x12,x3,x6
 ldr w13,[x10,x5,lsl#2]
 sub x13,x13,#1
 add x13,x1,x13,lsl#3
 sub x14,x11,x5
 lsl x14,x14,#1
.Lss_word:
 ldr x15,[x13],#8
 str x15,[x12]
 add x12,x12,x3
 subs x14,x14,#1
 b.ne .Lss_word
 add x4,x4,#1
 cmp x4,x7
 b.lo .Lss_wave
.Lss_done:
 ret
.size md2asm_scatter_streaming_runtime_spectral_record,.-md2asm_scatter_streaming_runtime_spectral_record
.section .note.GNU-stack,"",%progbits
