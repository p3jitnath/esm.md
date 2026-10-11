/* Direct surface heat and water balance.
 * Physics input: formulations/openifs/surface/surface_skin_energy.md.
 * Numerical and ABI contract: skills/md2asm/references/openifs/surface/surfseb_ctl.md.
 * The caller supplies 48 addresses and complete GNU array owners.
 */
#ifndef SURFSEB_CTL_SYMBOL
#define SURFSEB_CTL_SYMBOL __surfseb_ctl_mod_MOD_surfseb_ctl
#endif
.arch armv8-a
.text
.p2align 4
.global SURFSEB_CTL_SYMBOL
.type SURFSEB_CTL_SYMBOL,%function
SURFSEB_CTL_SYMBOL:
stp x29,x30,[sp,#-256]!
stp x18,x19,[sp,#16]
stp x20,x21,[sp,#32]
stp x22,x23,[sp,#48]
stp x24,x25,[sp,#64]
stp x26,x27,[sp,#80]
stp x28,x29,[sp,#96]
stp d8,d9,[sp,#128]
stp d10,d11,[sp,#144]
stp d12,d13,[sp,#160]
stp d14,d15,[sp,#176]
mov x29,sp
sub sp,sp,#2048
mov x19,sp
stp x0,x1,[x19]
stp x2,x3,[x19,#16]
stp x4,x5,[x19,#32]
stp x6,x7,[x19,#48]
ldr x9,[x29,#256]
str x9,[x19,#64]
ldr x9,[x29,#264]
str x9,[x19,#72]
ldr x9,[x29,#272]
str x9,[x19,#80]
ldr x9,[x29,#280]
str x9,[x19,#88]
ldr x9,[x29,#288]
str x9,[x19,#96]
ldr x9,[x29,#296]
str x9,[x19,#104]
ldr x9,[x29,#304]
str x9,[x19,#112]
ldr x9,[x29,#312]
str x9,[x19,#120]
ldr x9,[x29,#320]
str x9,[x19,#128]
ldr x9,[x29,#328]
str x9,[x19,#136]
ldr x9,[x29,#336]
str x9,[x19,#144]
ldr x9,[x29,#344]
str x9,[x19,#152]
ldr x9,[x29,#352]
str x9,[x19,#160]
ldr x9,[x29,#360]
str x9,[x19,#168]
ldr x9,[x29,#368]
str x9,[x19,#176]
ldr x9,[x29,#376]
str x9,[x19,#184]
ldr x9,[x29,#384]
str x9,[x19,#192]
ldr x9,[x29,#392]
str x9,[x19,#200]
ldr x9,[x29,#400]
str x9,[x19,#208]
ldr x9,[x29,#408]
str x9,[x19,#216]
ldr x9,[x29,#416]
str x9,[x19,#224]
ldr x9,[x29,#424]
str x9,[x19,#232]
ldr x9,[x29,#432]
str x9,[x19,#240]
ldr x9,[x29,#440]
str x9,[x19,#248]
ldr x9,[x29,#448]
str x9,[x19,#256]
ldr x9,[x29,#456]
str x9,[x19,#264]
ldr x9,[x29,#464]
str x9,[x19,#272]
ldr x9,[x29,#472]
str x9,[x19,#280]
ldr x9,[x29,#480]
str x9,[x19,#288]
ldr x9,[x29,#488]
str x9,[x19,#296]
ldr x9,[x29,#496]
str x9,[x19,#304]
ldr x9,[x29,#504]
str x9,[x19,#312]
ldr x9,[x29,#512]
str x9,[x19,#320]
ldr x9,[x29,#520]
str x9,[x19,#328]
ldr x9,[x29,#528]
str x9,[x19,#336]
ldr x9,[x29,#536]
str x9,[x19,#344]
ldr x9,[x29,#544]
str x9,[x19,#352]
ldr x9,[x29,#552]
str x9,[x19,#360]
ldr x9,[x29,#560]
str x9,[x19,#368]
ldr x9,[x29,#568]
str x9,[x19,#376]
mrs x9,fpcr
cbnz x9,.Lbad
ldr x9,[x19,#0]
ldrsw x24,[x9]
ldr x9,[x19,#8]
ldrsw x25,[x9]
ldr x9,[x19,#16]
ldrsw x22,[x9]
ldr x9,[x19,#24]
ldrsw x23,[x9]
cmp x22,#1
b.lt .Lbad
cmp x22,#4096
b.gt .Lbad
cmp x23,#1
b.lt .Lbad
cmp x23,#10
b.gt .Lbad
cmp x24,#1
b.lt .Lbad
add x9,x22,#1
cmp x24,x9
b.gt .Lbad
cmp x25,#0
b.lt .Lbad
cmp x25,x22
b.gt .Lbad
ldr x9,[x19,#56]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#64]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#72]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#80]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#88]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#96]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#104]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#112]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#120]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#128]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#136]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#144]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#152]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#160]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#168]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#176]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#184]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#192]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#200]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#208]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#216]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#224]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#232]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#240]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#296]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#304]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#312]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#320]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#328]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#336]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#344]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#352]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#2
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x10,[x9,#64]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#80]
ldr x11,[x9,#72]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x23
b.lt .Lbad
ldr x9,[x19,#360]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
ldr x9,[x19,#368]
cbz x9,.Lbad
ldr x10,[x9]
cbz x10,.Lbad
ldr x10,[x9,#16]
cmp x10,#8
b.ne .Lbad
ldrb w10,[x9,#28]
cmp w10,#1
b.ne .Lbad
ldrb w10,[x9,#29]
cmp w10,#3
b.ne .Lbad
ldr x10,[x9,#40]
cmp x10,#0
b.le .Lbad
ldr x10,[x9,#56]
ldr x11,[x9,#48]
sub x10,x10,x11
add x10,x10,#1
cmp x10,x22
b.lt .Lbad
cmp x24,x25
b.gt .Lreturn
ldr x9,[x19,#248]
ldr d8,[x9,#80]
ldr d9,[x9,#72]
ldr d10,[x9,#56]
ldr d11,[x9,#96]
adrp x9,:got:__yos_thf_MOD_rvtmp2
ldr x9,[x9,:got_lo12:__yos_thf_MOD_rvtmp2]
ldr d12,[x9]
ldr x9,[x19,#256]
ldr w10,[x9,#0]
cmp w10,#0
cset w27,ne
ldr w10,[x9,#4]
cmp w10,#0
cset w10,ne
orr w27,w27,w10,lsl#1
sub x20,x24,#1
.Lcolumn:
ldr x9, [x19, #168]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d0,[x10]
ldr x9,[x19,#272]
ldr d1,[x9,#192]
fcmp d0,d1
cset w28,gt
tbz w27,#0,.Lradiation_ratio
ldr x9, [x19, #192]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d0,[x10]
ldr d1, .LC0
fmul d0,d1,d0
fmul d0,d0,d11
ldr x9, [x19, #184]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d1,[x10]
fmul d2,d1,d1
fmul d2,d2,d1
fmul d13,d0,d2
b .Lradiation_done
.Lradiation_ratio:
ldr x9, [x19, #176]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d0,[x10]
ldr x9, [x19, #184]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d1,[x10]
fdiv d0,d0,d1
ldr d1, .LC1
fmul d13,d1,d0
.Lradiation_done:
fmov d16,xzr
fmov d17,xzr
fmov d18,xzr
fmov d19,xzr
fmov d20,xzr
fmov d21,xzr
mov x21,#0
.Lcoefficients:
add x26,x19,#384
add x26,x26,x21,lsl#3
ldr x9, [x19, #64]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d0,[x10]
ldr x9, [x19, #56]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d1,[x10]
fdiv d2,d0,d1
str d2,[x26,#720]
ldr x9, [x19, #88]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d3,[x10]
fneg d4,d3
ldr x9, [x19, #96]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d5,[x10]
ldr x9, [x19, #104]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d22,[x10]
fmul d5,d5,d22
ldr x9, [x19, #96]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d6,[x10]
fneg d6,d6
ldr x9, [x19, #112]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d22,[x10]
fmul d6,d6,d22
ldr x9, [x19, #80]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d22,[x10]
fmul d6,d6,d22
fmul d6,d6,d2
ldr x9, [x19, #96]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d7,[x10]
fneg d7,d7
ldr x9, [x19, #112]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d22,[x10]
fmul d7,d7,d22
ldr x9, [x19, #80]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d22,[x10]
fmul d22,d22,d0
ldr x9, [x19, #72]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d23,[x10]
fsub d22,d23,d22
fmul d7,d7,d22
fmov d14,d9
cmp x21,#1
b.eq .Lice1
cmp x21,#4
b.eq .Lice1
cmp x21,#8
b.ne .Lphase1
cbz w28,.Lphase1
.Lice1:
fmov d14,d10
.Lphase1:
fmul d15,d8,d0
fmul d15,d15,d12
fsub d15,d14,d15
ldr x9, [x19, #144]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d22,[x10]
str d22,[x26,#800]
fsub d23,d13,d22
fmul d23,d23,d2
fadd d23,d23,d4
fmul d24,d15,d6
fadd d23,d23,d24
ldr d24, .LC2
fdiv d24,d24,d23
fneg d25,d3
fmul d25,d25,d24
fneg d26,d15
fmul d26,d26,d5
fmul d26,d26,d24
ldr x9,[x19,#264]
add x9,x9,#352
ldr x10,[x9]
ldr x11,[x9,#40]
ldr x12,[x9,#48]
mov x13,#0
cmp x21,#2
b.eq .Ltransmission_low
cmp x21,#3
b.eq .Ltransmission_low
cmp x21,#5
b.eq .Ltransmission_high
cmp x21,#6
b.eq .Ltransmission_high
b .Ltransmission_none
.Ltransmission_low:
mov x13,#1
b .Ltransmission_load
.Ltransmission_high:
mov x13,#3
.Ltransmission_load:
sub x13,x13,x12
mul x13,x13,x11
ldr d23,[x10,x13,lsl#3]
ldr d28, .LC2
fsub d23,d28,d23
b .Ltransmission_done
.Ltransmission_none:
ldr d23, .LC2
.Ltransmission_done:
ldr x9, [x19, #120]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d27,[x10]
fneg d27,d27
fmul d27,d27,d23
ldr x9, [x19, #176]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d23,[x10]
fsub d27,d27,d23
ldr x9, [x19, #184]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d23,[x10]
fmul d23,d13,d23
fadd d27,d27,d23
fmul d23,d15,d7
fsub d27,d27,d23
ldr x9, [x19, #136]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d23,[x10]
fmul d23,d22,d23
fsub d27,d27,d23
fmul d27,d27,d24
str d25,[x26,#0]
str d26,[x26,#80]
str d27,[x26,#160]
fmul d28,d4,d25
fadd d28,d3,d28
fmul d29,d4,d26
fmul d30,d4,d27
fmul d31,d6,d25
fmul d0,d6,d26
fadd d0,d5,d0
fmul d1,d6,d27
fadd d1,d1,d7
str d28,[x26,#240]
str d29,[x26,#320]
str d30,[x26,#400]
str d31,[x26,#480]
str d0,[x26,#560]
str d1,[x26,#640]
ldr x9, [x19, #128]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d2,[x10]
fmul d3,d2,d28
fadd d16,d16,d3
fmul d3,d2,d29
fadd d17,d17,d3
fmul d3,d2,d30
fadd d18,d18,d3
fmul d3,d2,d31
fadd d19,d19,d3
fmul d3,d2,d0
fadd d20,d20,d3
fmul d3,d2,d1
fadd d21,d21,d3
add x21,x21,#1
cmp x21,x23
b.lt .Lcoefficients
ldr x9, [x19, #200]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d22,[x10]
ldr x9, [x19, #208]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d23,[x10]
ldr x9, [x19, #216]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d24,[x10]
ldr x9, [x19, #224]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d25,[x10]
ldr d26, .LC2
fmul d0,d22,d16
fsub d0,d26,d0
fmul d1,d24,d17
fmul d2,d23,d16
fmul d6,d25,d17
fadd d2,d2,d6
fadd d2,d2,d18
fmul d3,d24,d20
fsub d3,d26,d3
fmul d4,d22,d19
fmul d5,d23,d19
fmul d6,d25,d20
fadd d5,d5,d6
fadd d5,d5,d21
fmul d6,d0,d3
fmul d7,d1,d4
fsub d6,d6,d7
fdiv d7,d26,d6
fmul d14,d2,d4
fmul d6,d0,d5
fadd d14,d14,d6
fmul d14,d14,d7
fmul d15,d1,d5
fmul d6,d2,d3
fadd d15,d15,d6
fmul d15,d15,d7
fmul d22,d22,d15
fadd d22,d22,d23
fmul d23,d24,d14
fadd d23,d23,d25
ldr x9, [x19, #360]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
str d22,[x10]
ldr x9, [x19, #368]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
str d23,[x10]
fmov d24,xzr
mov x21,#0
.Loutputs:
add x26,x19,#384
add x26,x26,x21,lsl#3
ldr d4,[x26,#0]
ldr d5,[x26,#80]
ldr d6,[x26,#160]
fmul d0,d4,d22
fmul d4,d5,d23
fadd d0,d0,d4
fadd d0,d0,d6
ldr d4,[x26,#240]
ldr d5,[x26,#320]
ldr d6,[x26,#400]
fmul d1,d4,d22
fmul d4,d5,d23
fadd d1,d1,d4
fadd d1,d1,d6
ldr d4,[x26,#480]
ldr d5,[x26,#560]
ldr d6,[x26,#640]
fmul d2,d4,d22
fmul d4,d5,d23
fadd d2,d2,d4
fadd d2,d2,d6
ldr x9, [x19, #312]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d0,[x10]
ldr x9, [x19, #296]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d1,[x10]
ldr x9, [x19, #304]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d2,[x10]
ldr d4,[x26,#720]
fmul d3,d0,d4
ldr x9, [x19, #320]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d3,[x10]
ldr x9, [x19, #64]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d4,[x10]
fmul d4,d8,d4
fmul d4,d4,d12
fmul d4,d4,d2
fsub d4,d1,d4
ldr x9, [x19, #328]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d4,[x10]
fmov d14,d9
cmp x21,#1
b.eq .Lice2
cmp x21,#4
b.eq .Lice2
cmp x21,#8
b.ne .Lphase2
cbz w28,.Lphase2
.Lice2:
fmov d14,d10
.Lphase2:
fmul d5,d14,d2
ldr x9, [x19, #336]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d5,[x10]
ldr x9, [x19, #176]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d4,[x10]
ldr x9, [x19, #184]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d5,[x10]
fsub d6,d3,d5
fmul d6,d13,d6
fadd d6,d4,d6
ldr x9, [x19, #344]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d6,[x10]
ldr d4,[x26,#800]
ldr x9, [x19, #136]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d5,[x10]
fsub d7,d3,d5
fmul d7,d4,d7
ldr x9, [x19, #352]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d7,[x10]
ldr x9, [x19, #128]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d4,[x10]
fmul d4,d4,d3
fadd d24,d24,d4
add x21,x21,#1
cmp x21,x23
b.lt .Loutputs
tbz w27,#1,.Lnext_column
ldr x9, [x19, #192]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d0,[x10]
ldr d1, .LC0
fmul d0,d1,d0
fmul d0,d0,d11
fmul d1,d24,d24
fmul d1,d1,d24
fmul d13,d0,d1
mov x21,#0
.Lcentred:
ldr x9, [x19, #320]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
ldr d0,[x10]
ldr x9, [x19, #176]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr d1,[x10]
fsub d0,d0,d24
fmul d0,d13,d0
fadd d0,d1,d0
ldr x9, [x19, #344]
ldr x10, [x9]
ldr x11, [x9, #40]
lsl x11,x11,#3
madd x10,x20,x11,x10
ldr x11,[x9,#64]
lsl x11,x11,#3
madd x10,x21,x11,x10
str d0,[x10]
add x21,x21,#1
cmp x21,x23
b.lt .Lcentred
.Lnext_column:
add x20,x20,#1
cmp x20,x25
b.lt .Lcolumn
.Lreturn:
mov sp,x29
ldp d8,d9,[sp,#128]
ldp d10,d11,[sp,#144]
ldp d12,d13,[sp,#160]
ldp d14,d15,[sp,#176]
ldp x18,x19,[sp,#16]
ldp x20,x21,[sp,#32]
ldp x22,x23,[sp,#48]
ldp x24,x25,[sp,#64]
ldp x26,x27,[sp,#80]
ldp x28,x29,[sp,#96]
ldp x29,x30,[sp],#256
ret
.Lbad:
brk #47
.size SURFSEB_CTL_SYMBOL,.-SURFSEB_CTL_SYMBOL
.section .rodata
.p2align 3
.LC0:
.quad 0xc010000000000000
.LC1:
.quad 0x4010000000000000
.LC2:
.quad 0x3ff0000000000000
.section .note.GNU-stack,"",%progbits
