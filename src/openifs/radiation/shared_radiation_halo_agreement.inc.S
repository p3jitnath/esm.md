.Lhalo_agree:
 str x30,[sp,#136]
 mrs x8,fpcr
 mrs x9,fpsr
 stp x8,x9,[sp,#144]
 ldr w9,[x28]
 str w9,[sp,#160]
 add x0,sp,#128
 add x1,sp,#132
 mov w2,#1
 ldr w3,=0x4c000405
 ldr w4,=0x58000001
 ldr w5,=0x44000000
 bl MPI_Allreduce
 cbnz w0,.Lhalo_abort
 ldp x8,x9,[sp,#144]
 msr fpcr,x8
 msr fpsr,x9
 ldr w9,[sp,#160]
 str w9,[x28]
 ldr x30,[sp,#136]
 ret
.Lhalo_abort:
 bl abort
 brk #0
.ltorg
