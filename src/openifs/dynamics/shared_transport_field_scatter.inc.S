.Lscatter_field:
 mov x10,#0
.Lscatter_row:
 mul x11,x10,x24
 ldrsw x12,[x23,x11]
 sub x12,x12,#1
 madd x12,x28,x25,x12
 ldr x13,[x19,x10,lsl #3]
 str x13,[x20,x12,lsl #3]
 add x10,x10,#1
 cmp x10,x22
 b.lo .Lscatter_row
#ifdef MD2ASM_RUNTIME_SCATTER
 add x19,x19,x26
#else
 add x19,x19,#192
#endif
 add x28,x28,#1
#ifdef MD2ASM_RUNTIME_SCATTER
 cmp x28,x27
#else
 cmp x28,#463
#endif
 b.lo .Lscatter_field
