.Ldispatch_first:
ldr x8,[x0]
cbnz x8,1f
mov x0,#0
ret
1:
ldr x9,[x0,#8]
ldrb w10,[x0,#28]
ldr x11,[x0,#40]
ldr x12,[x0,#48]
madd x9,x11,x12,x9
cmp w10,#1
b.eq .Ldispatch_first_done
ldr x11,[x0,#64]
ldr x12,[x0,#72]
cmp x1,#0
csel x12,x12,x1,eq
madd x9,x11,x12,x9
cmp w10,#2
b.eq .Ldispatch_first_done
ldr x11,[x0,#88]
ldr x12,[x0,#96]
cmp x2,#0
csel x12,x12,x2,eq
madd x9,x11,x12,x9
cmp w10,#3
b.eq .Ldispatch_first_done
ldr x11,[x0,#112]
ldr x12,[x0,#120]
madd x9,x11,x12,x9
.Ldispatch_first_done:
ldr x11,[x0,#32]
madd x0,x9,x11,x8
ret
