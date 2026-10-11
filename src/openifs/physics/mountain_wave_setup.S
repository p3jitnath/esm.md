// Physics input formulations/openifs/physics/mountain_wave_setup.md.
// Complete separately rounded column calculations and source level decisions.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL md2asm_gwsetup
#endif
.macro READ reg,arg,delta=0
 ldr x9,[x28,#(160+8*\arg)]
 sub x10,x24,#1
 .if \delta != 0
 add x10,x10,#\delta
 .endif
 madd x10,x10,x20,x19
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro WRITE reg,arg
 ldr x9,[x28,#(160+8*\arg)]
 sub x10,x24,#1
 madd x10,x10,x20,x19
 str \reg,[x9,x10,lsl #3]
.endm
.macro SCALAR reg,arg
 ldr x9,[x28,#(160+8*\arg)]
 ldr \reg,[x9,x19,lsl #3]
.endm
.macro STORE reg,arg
 ldr x9,[x28,#(160+8*\arg)]
 str \reg,[x9,x19,lsl #3]
.endm
.macro INDEX reg,arg
 ldr x9,[x28,#(160+8*\arg)]
 ldr \reg,[x9,x19,lsl #2]
.endm
.macro IWRITE reg,arg
 ldr x9,[x28,#(160+8*\arg)]
 str \reg,[x9,x19,lsl #2]
.endm
.macro CONST reg,name
 adr x11,.K\name
 ldr \reg,[x11]
.endm
.macro PICK multiplier,slot
 ldr x0,[x28,#288]
 add x0,x0,x19,lsl #3
 lsl x1,x20,#3
 mov w2,w21
 ldr w3,[x28,#452]
 SCALAR d0,17
 CONST d1,\multiplier
 fmul d0,d0,d1
 ldr d1,[x28,#536]
 bl .Lheight
 ldr x9,[x28,#432]
 add x9,x9,x19,lsl #4
 str w0,[x9,#\slot]
.endm
.text
.p2align 2
.global ORIGINAL_SYMBOL
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
 sub sp,sp,#896
 stp x29,x30,[sp,#0]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 mov x29,sp
 mov x28,sp
 stp x0,x1,[sp,#160]
 stp x2,x3,[sp,#176]
 stp x4,x5,[sp,#192]
 stp x6,x7,[sp,#208]
 add x9,sp,#896
 mov x10,#0
.Lcapture:
 ldr x11,[x9,x10,lsl #3]
 add x12,x28,#224
 str x11,[x12,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#25
 b.lt .Lcapture
 mrs x9,fpcr
 cbnz x9,.Lbad
 // The complete ABI owner sizes are checked before fields are read.
 mov x12,#0
.Laddress:
 add x9,x28,#160
 ldr x10,[x9,x12,lsl #3]
 cbz x10,.Lbad
 cmp x12,#1
 b.lt .Lreal_address
 cmp x12,#10
 b.le .Lint_address
.Lreal_address:
 tst x10,#7
 b.ne .Lbad
 b .Laddress_next
.Lint_address:
 tst x10,#3
 b.ne .Lbad
.Laddress_next:
 add x12,x12,#1
 cmp x12,#33
 b.lt .Laddress
 ldr x9,[x28,#184]
 ldrsw x20,[x9]
 ldr x9,[x28,#192]
 ldrsw x21,[x9]
 cmp x20,#1
 b.lt .Lbad
 cmp x20,#4096
 b.gt .Lbad
 cmp x21,#6
 b.lt .Lbad
 cmp x21,#512
 b.gt .Lbad
 ldr x9,[x28,#168]
 ldrsw x22,[x9]
 ldr x9,[x28,#176]
 ldrsw x23,[x9]
 cmp x22,#1
 b.lt .Lbad
 add x10,x20,#1
 cmp x22,x10
 b.gt .Lbad
 cmp x23,#0
 b.lt .Lbad
 cmp x23,x20
 b.gt .Lbad
 sub x22,x22,#1
 sub x23,x23,#1
 ldr x9,[x28,#160]
 ldr w10,[x9]
 cmp w10,#1
 b.lt .Lbad
 cmp w10,w21
 b.gt .Lbad
 str w10,[x28,#448]
 mov w10,#3
 udiv w10,w21,w10
 str w10,[x28,#452]
 ldr w11,[x28,#448]
 cmp w11,w10
 b.lt .Lbad
 ldr d14,[x9,#16]
 ldr d15,[x9,#24]
 ldr d11,[x9,#48]
 ldr d12,[x9,#56]
 ldr d13,[x9,#64]
 fcmp d14,#0.0
 b.le .Lbad
 CONST d0,million
 fcmp d14,d0
 b.hi .Lbad
 fcmp d15,#0.0
 b.le .Lbad
 fcmp d15,d0
 b.hi .Lbad
 fcmp d11,#0.0
 b.le .Lbad
 fcmp d11,d0
 b.hi .Lbad
 CONST d0,min_stability
 fcmp d11,d0
 b.lt .Lbad
 CONST d0,min_safeguard
 fcmp d12,d0
 b.lt .Lbad
 fcmp d13,d0
 b.lt .Lbad
 fmov d0,#1.0
 fcmp d12,d0
 b.hi .Lbad
 CONST d0,thousand
 fcmp d13,d0
 b.hi .Lbad
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 ldr d8,[x9]
 adrp x9,:got:__yomcst_MOD_rd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 ldr d9,[x9]
 adrp x9,:got:__yomcst_MOD_rcpd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rcpd]
 ldr d10,[x9]
 CONST d0,min_gravity
 fcmp d8,d0
 b.lt .Lbad
 CONST d0,thousand
 fcmp d8,d0
 b.hi .Lbad
 fmov d0,#1.0
 fcmp d9,d0
 b.lt .Lbad
 CONST d0,gas_cap
 fcmp d9,d0
 b.hi .Lbad
 fcmp d10,d9
 b.le .Lbad
 CONST d0,million
 fcmp d10,d0
 b.hi .Lbad
 fmov d0,#1.0
 fdiv d0,d0,d9
 str d0,[x28,#520]
 fmul d0,d8,d8
 fdiv d0,d0,d10
 str d0,[x28,#528]
 fadd d0,d8,d8
 fmov d1,#1.0
 fdiv d0,d1,d0
 str d0,[x28,#536]
 // Size codes are 0=scalar integer,1=column integer,2=column real,
 // 3=full field,4=half field,96=configuration.
 mov x12,#0
.Lowner_sizes:
 adr x9,.Lsize_codes
 ldr w10,[x9,x12,lsl #2]
 cmp w10,#96
 b.eq .Lsize_config
 cbz w10,.Lsize_scalar
 cmp w10,#1
 b.eq .Lsize_integer
 cmp w10,#2
 b.eq .Lsize_column
 mov x10,x21
 cmp w10,#4
 // Read the original code again because the extent now uses x10.
 ldr w11,[x9,x12,lsl #2]
 cmp w11,#4
 cinc x10,x10,eq
 mul x10,x10,x20
 lsl x10,x10,#3
 b .Lsize_store
.Lsize_config:mov x10,#96
 b .Lsize_store
.Lsize_scalar:mov x10,#4
 b .Lsize_store
.Lsize_integer:lsl x10,x20,#2
 b .Lsize_store
.Lsize_column:lsl x10,x20,#3
.Lsize_store:
 add x9,x28,#608
 str x10,[x9,x12,lsl #3]
 add x12,x12,#1
 cmp x12,#33
 b.lt .Lowner_sizes
 // Every complete output is distinct from all other declared owners.
 mov x12,#0
.Loutput_owner:
 adr x9,.Loutputs
 ldr w13,[x9,x12,lsl #2]
 add x9,x28,#160
 ldr x14,[x9,x13,lsl #3]
 add x10,x28,#608
 ldr x15,[x10,x13,lsl #3]
 add x15,x14,x15
 cmp x15,x14
 b.lo .Lbad
 mov x16,#0
.Lseparation:
 cmp x16,x13
 b.eq .Lseparation_next
 ldr x17,[x9,x16,lsl #3]
 ldr x11,[x10,x16,lsl #3]
 add x11,x17,x11
 cmp x11,x17
 b.lo .Lbad
 cmp x14,x11
 b.hs .Lseparation_next
 cmp x17,x15
 b.lo .Lbad
.Lseparation_next:
 add x16,x16,#1
 cmp x16,#33
 b.lt .Lseparation
 add x12,x12,#1
 cmp x12,#19
 b.lt .Loutput_owner
 lsl x0,x20,#4
 mov x9,#24
 madd x0,x21,x9,x0
 bl malloc
 cbz x0,.Lbad
 str x0,[x28,#432]
 add x25,x0,x20,lsl #4
 add x26,x25,x21,lsl #3
 add x27,x26,x21,lsl #3
 // Complete active-input and derived interval admission precedes output.
 mov x19,x22
 cmp x19,x23
 b.gt .Ldone
.Ladmit:
 SCALAR d0,28
 fcmp d0,#0.0
 b.lt .Lbad
 fmov d1,#1.0
 fcmp d0,d1
 b.hi .Lbad
 INDEX w9,5
 cmp w9,#1
 b.hi .Lbad
 cbz w9,.Lmasked_indices
 SCALAR d0,17
 fcmp d0,#0.0
 b.lt .Lbad
 CONST d1,height_cap
 fcmp d0,d1
 b.hi .Lbad
 SCALAR d0,27
 fabs d0,d0
 CONST d1,two_pi
 fcmp d0,d1
 b.hi .Lbad
 mov x24,#1
.Latmosphere:
 READ d0,15
 CONST d1,temp_low
 fcmp d0,d1
 b.lt .Lbad
 CONST d1,temp_high
 fcmp d0,d1
 b.hi .Lbad
 READ d0,13
 fabs d0,d0
 CONST d1,thousand
 fcmp d0,d1
 b.hi .Lbad
 READ d0,14
 fabs d0,d0
 fcmp d0,d1
 b.hi .Lbad
 READ d0,16
 fabs d1,d0
 CONST d2,geo_cap
 fcmp d1,d2
 b.hi .Lbad
 cmp x24,#1
 b.eq .Lgeometry_ready
 READ d1,16,-1
 fcmp d0,d1
 b.gt .Lbad
.Lgeometry_ready:
 READ d0,12
 CONST d3,pressure_min
 fcmp d0,d3
 b.lt .Lbad
 CONST d3,pressure_cap
 fcmp d0,d3
 b.hi .Lbad
 READ d1,11
 fcmp d1,#0.0
 b.lt .Lbad
 READ d2,11,1
 fcmp d2,d3
 b.hi .Lbad
 fcmp d2,d1
 b.le .Lbad
 fcmp d0,d1
 b.lt .Lbad
 fcmp d0,d2
 b.gt .Lbad
 cmp x24,#1
 b.eq .Lpressure_ready
 READ d3,12,-1
 fcmp d0,d3
 b.le .Lbad
.Lpressure_ready:
 add x24,x24,#1
 cmp x24,x21
 b.le .Latmosphere
 PICK four,0
 PICK three,4
 PICK two,8
 PICK one,12
 ldr x9,[x28,#432]
 add x9,x9,x19,lsl #4
 ldr w10,[x28,#448]
 ldr w11,[x9,#0]
 cmp w11,w10
 csel w11,w11,w10,le
 str w11,[x9,#0]
 ldr w11,[x9,#8]
 cmp w11,w10
 csel w11,w11,w10,le
 str w11,[x9,#8]
 ldr w12,[x9,#12]
 cmp w11,w10
 csel w12,w21,w12,eq
 cmp w11,w12
 cinc w12,w12,eq
 cmp w11,#1
 b.lt .Lbad
 cmp w12,w11
 b.le .Lbad
 cmp w12,w21
 b.gt .Lbad
 str w12,[x9,#12]
 b .Ladmit_next
.Lmasked_indices:
 ldr x9,[x28,#432]
 add x9,x9,x19,lsl #4
 ldr w10,[x28,#448]
 cmp w21,w10
 csel w10,w21,w10,le
 str w10,[x9,#0]
 str w21,[x9,#4]
 str w10,[x9,#8]
 str w21,[x9,#12]
.Ladmit_next:
 add x19,x19,#1
 cmp x19,x23
 b.le .Ladmit
 mov x19,x22
.Lcolumn:
 IWRITE w21,6
 IWRITE w21,8
 mov w11,#1
 IWRITE w11,7
 ldr x9,[x28,#432]
 add x9,x9,x19,lsl #4
 ldp w10,w11,[x9,#0]
 IWRITE w10,9
 IWRITE w11,10
 ldr x9,[x28,#432]
 add x9,x9,x19,lsl #4
 ldp w10,w11,[x9,#8]
 str w10,[x28,#456]
 str w11,[x28,#460]
 SCALAR d0,28
 fmax d0,d0,d12
 STORE d0,28
 fmov d0,xzr
 STORE d0,25
 STORE d0,26
 STORE d0,29
 CONST d1,initial_ri
 mov x24,#1
.Linitial_fields:
 WRITE d0,18
 WRITE d1,19
 WRITE d0,20
 WRITE d0,21
 WRITE d0,22
 WRITE d0,23
 cmp x24,x21
 b.gt .Linitial_next
 WRITE d0,24
.Linitial_next:
 add x24,x24,#1
 add x10,x21,#1
 cmp x24,x10
 b.le .Linitial_fields
 INDEX w9,5
 cbz w9,.Lnext_column
 // Density, stability, pressure difference and stability root.
 mov x24,x21
.Ldensity:
 READ d0,12
 READ d1,12,-1
 fsub d4,d0,d1
 sub x10,x24,#1
 str d4,[x25,x10,lsl #3]
 READ d2,15
 READ d3,15,-1
 fadd d5,d2,d3
 READ d0,11
 fadd d0,d0,d0
 ldr d1,[x28,#520]
 fmul d0,d0,d1
 fdiv d0,d0,d5
 WRITE d0,18
 fmul d1,d10,d0
 fsub d2,d2,d3
 fmul d1,d1,d2
 fdiv d1,d1,d4
 fmov d2,#1.0
 fsub d1,d2,d1
 ldr d0,[x28,#528]
 fadd d0,d0,d0
 fdiv d0,d0,d5
 fmul d0,d0,d1
 fmax d0,d0,d11
 WRITE d0,20
 fsqrt d0,d0
 sub x10,x24,#1
 str d0,[x26,x10,lsl #3]
 sub x24,x24,#1
 cmp x24,#2
 b.ge .Ldensity
 // Pressure-weighted mean stability and density, ascending levels.
 ldr w24,[x28,#456]
 add x24,x24,#1
 fmov d5,xzr
 fmov d6,xzr
.Lmeans:
 READ d2,15
 READ d3,15,-1
 READ d1,18
 sub x10,x24,#1
 ldr d4,[x25,x10,lsl #3]
 fmul d0,d10,d1
 fsub d7,d2,d3
 fmul d0,d0,d7
 fdiv d0,d0,d4
 fmov d7,#1.0
 fsub d0,d7,d0
 ldr d7,[x28,#528]
 fdiv d7,d7,d2
 fmul d0,d7,d0
 fmul d0,d0,d4
 fadd d5,d5,d0
 fmax d5,d5,d11
 READ d0,11
 fadd d0,d0,d0
 fmul d0,d0,d4
 ldr d7,[x28,#520]
 fmul d0,d0,d7
 fadd d2,d2,d3
 fdiv d0,d0,d2
 fadd d6,d6,d0
 add x24,x24,#1
 ldr w10,[x28,#460]
 cmp x24,x10
 b.le .Lmeans
 ldr w24,[x28,#460]
 READ d0,12
 ldr w24,[x28,#456]
 READ d1,12
 fsub d0,d0,d1
 fdiv d5,d5,d0
 fdiv d6,d6,d0
 add x24,x21,#1
 WRITE d5,20
 WRITE d6,18
 // Low wind uses the source decreasing-level sum.
 fmov d5,xzr
 fmov d6,xzr
 mov x24,x21
.Llow_wind:
 ldr w10,[x28,#456]
 cmp x24,x10
 b.lt .Llow_skip
 ldr w10,[x28,#460]
 cmp x24,x10
 b.gt .Llow_skip
 READ d0,11,1
 READ d1,11
 fsub d0,d0,d1
 READ d1,13
 READ d2,14
 fmul d1,d1,d0
 fmul d2,d2,d0
 fadd d5,d5,d1
 fadd d6,d6,d2
.Llow_skip:
 sub x24,x24,#1
 ldr w10,[x28,#452]
 cmp x24,x10
 b.ge .Llow_wind
 ldr w24,[x28,#460]
 READ d0,11,1
 ldr w24,[x28,#456]
 READ d1,11
 fsub d0,d0,d1
 fdiv d5,d5,d0
 fdiv d6,d6,d0
 STORE d5,25
 STORE d6,26
 fmul d0,d5,d5
 fmul d1,d6,d6
 fadd d0,d0,d1
 fsqrt d0,d0
 fmax d0,d0,d13
 str d0,[x28,#464]
 add x24,x21,#1
 WRITE d0,22
 // Rotate the mountain factor relative to the regularised low wind.
 SCALAR d0,25
 SCALAR d1,26
 fcmp d0,d13
 b.ge .Llow_direction
 fneg d2,d13
 fcmp d0,d2
 b.lt .Llow_direction
 fadd d2,d13,d13
 fadd d0,d0,d2
.Llow_direction:
 fdiv d0,d1,d0
 bl md2asm_atan_original_rounding
 SCALAR d1,27
 fsub d0,d1,d0
 WRITE d0,23
 str d0,[x28,#488]
 SCALAR d0,28
 fmul d2,d0,d0
 CONST d1,blinear
 fmul d1,d1,d0
 fmov d3,#1.0
 fsub d1,d3,d1
 CONST d3,bquadratic
 fmul d3,d3,d2
 fsub d1,d1,d3
 str d1,[x28,#472]
 CONST d1,clinear
 fmul d1,d1,d0
 CONST d3,cquadratic
 fmul d3,d3,d2
 fadd d1,d1,d3
 str d1,[x28,#480]
 ldr d0,[x28,#488]
 bl md2asm_sin_original_rounding
 str d0,[x28,#496]
 fmul d0,d0,d0
 ldr d1,[x28,#472]
 ldr d2,[x28,#480]
 fsub d2,d1,d2
 fmul d0,d2,d0
 fsub d0,d1,d0
 STORE d0,30
 ldr d0,[x28,#488]
 bl md2asm_cos_original_rounding
 ldr d1,[x28,#472]
 ldr d2,[x28,#480]
 fsub d1,d1,d2
 ldr d2,[x28,#496]
 fmul d1,d1,d2
 fmul d0,d1,d0
 STORE d0,31
 SCALAR d1,30
 fmul d1,d1,d1
 fmul d0,d0,d0
 fadd d0,d1,d0
 fsqrt d0,d0
 STORE d0,32
 // Full-level projection in the mountain-stress plane.
 mov x24,#1
.Lfull_projection:
 READ d0,13
 READ d1,14
 SCALAR d2,25
 SCALAR d3,26
 fmul d4,d2,d0
 fmul d5,d3,d1
 fadd d4,d4,d5
 fneg d5,d3
 fmul d5,d5,d0
 fmul d0,d2,d1
 fadd d5,d5,d0
 SCALAR d0,30
 SCALAR d1,31
 fmul d4,d4,d0
 fmul d5,d5,d1
 fadd d4,d4,d5
 ldr d0,[x28,#464]
 SCALAR d1,32
 fmul d0,d0,d1
 fdiv d4,d4,d0
 sub x10,x24,#1
 str d4,[x27,x10,lsl #3]
 add x24,x24,#1
 cmp x24,x21
 b.le .Lfull_projection
 // Interpolated half-level projection and last critical-level update.
 mov x24,#2
.Lhalf_projection:
 READ d0,12
 READ d1,12,-1
 fsub d2,d0,d1
 READ d3,11
 fsub d4,d3,d1
 sub x10,x24,#1
 ldr d5,[x27,x10,lsl #3]
 fmul d4,d4,d5
 fsub d5,d0,d3
 sub x10,x24,#2
 ldr d6,[x27,x10,lsl #3]
 fmul d5,d5,d6
 fadd d4,d4,d5
 fdiv d4,d4,d2
 fcmp d4,d13
 b.ge .Lhalf_store
 fmov d4,d13
 ldr w10,[x28,#460]
 cmp x24,x10
 b.gt .Lhalf_store
 IWRITE w24,7
.Lhalf_store:
 WRITE d4,22
 add x24,x24,#1
 cmp x24,x21
 b.le .Lhalf_projection
 // Richardson numbers from the same ordered projected shear.
 mov x24,#2
.Lrichardson:
 sub x10,x24,#1
 ldr d0,[x27,x10,lsl #3]
 sub x10,x24,#2
 ldr d1,[x27,x10,lsl #3]
 fsub d0,d0,d1
 fabs d0,d0
 fmax d0,d0,d13
 READ d1,18
 fmul d1,d8,d1
 fmul d1,d1,d0
 sub x10,x24,#1
 ldr d2,[x25,x10,lsl #3]
 fdiv d2,d2,d1
 fmul d2,d2,d2
 READ d3,20
 fmul d2,d3,d2
 fmax d2,d2,d15
 WRITE d2,19
 add x24,x24,#1
 cmp x24,x21
 b.le .Lrichardson
 // Increasing height integral with a first lower-half contribution.
 mov x24,#2
.Lblocking:
 INDEX w11,10
 cmp x24,x11
 b.lt .Lblocking_next
 cset w11,eq
 str w11,[x28,#584]
 bl .Lspeed
 str d0,[x28,#504]
 ldr w11,[x28,#584]
 cbz w11,.Lfull_block_layer
 READ d2,11,1
 READ d3,12
 fsub d2,d2,d3
 ldr d0,[x26,x24,lsl #3]
 READ d1,18,1
 fdiv d0,d0,d1
 b .Lblock_increment
.Lfull_block_layer:
 READ d2,11,1
 READ d3,11
 fsub d2,d2,d3
 bl .Lstability_ratio
.Lblock_increment:
 fdiv d2,d2,d8
 fmul d0,d2,d0
 ldr d1,[x28,#504]
 fdiv d0,d0,d1
 SCALAR d1,29
 fadd d0,d1,d0
 STORE d0,29
 fcmp d1,d14
 b.gt .Lblocking_next
 fcmp d0,d14
 b.le .Lblocking_next
 INDEX w11,8
 cmp w11,w21
 b.ne .Lblocking_next
 IWRITE w24,8
.Lblocking_next:
 add x24,x24,#1
 cmp x24,x21
 b.lt .Lblocking
 // Separate decreasing mixing-height integral.
 fmov d0,xzr
 str d0,[x28,#552]
 sub x24,x21,#1
.Lmixing:
 INDEX w11,8
 cmp x24,x11
 b.ge .Lmixing_next
 bl .Lspeed
 str d0,[x28,#504]
 READ d2,11,1
 READ d3,11
 fsub d2,d2,d3
 bl .Lstability_ratio
 fdiv d2,d2,d8
 fmul d0,d2,d0
 ldr d1,[x28,#504]
 fdiv d0,d0,d1
 ldr d1,[x28,#552]
 fadd d0,d1,d0
 str d0,[x28,#552]
 fmov d2,#1.5
 fcmp d1,d2
 b.gt .Lmixing_next
 fcmp d0,d2
 b.le .Lmixing_next
 INDEX w11,6
 cmp w11,w21
 b.ne .Lmixing_next
 IWRITE w24,6
.Lmixing_next:
 sub x24,x24,#1
 cmp x24,#2
 b.ge .Lmixing
 INDEX w11,6
 INDEX w12,9
 cmp w11,w12
 csel w11,w11,w12,le
 IWRITE w11,6
 // Wind direction and vertical leakiness below the blocking face.
 ldr w24,[x28,#452]
.Lleakiness:
 INDEX w11,8
 cmp x24,x11
 b.lt .Lleakiness_next
 READ d0,13
 READ d1,14
 fcmp d0,d13
 b.ge .Llayer_direction
 fneg d2,d13
 fcmp d0,d2
 b.lt .Llayer_direction
 fadd d2,d13,d13
 fadd d0,d0,d2
.Llayer_direction:
 fdiv d0,d1,d0
 bl md2asm_atan_original_rounding
 SCALAR d1,27
 fsub d0,d1,d0
 WRITE d0,23
 str w24,[x28,#576]
 INDEX w24,8
 READ d0,16
 READ d1,16,-1
 fadd d0,d0,d1
 fmov d1,#2.0
 fdiv d0,d0,d1
 fmov d1,#1.0
 fmax d2,d0,d1
 ldr w24,[x28,#576]
 READ d0,16
 fmax d3,d0,d1
 SCALAR d0,17
 fmul d0,d0,d8
 fmax d4,d0,d1
 fsub d2,d2,d3
 fadd d3,d3,d4
 fdiv d0,d2,d3
 fsqrt d0,d0
 WRITE d0,24
.Lleakiness_next:
 add x24,x24,#1
 cmp x24,x21
 b.le .Lleakiness
.Lnext_column:
 add x19,x19,#1
 cmp x19,x23
 b.le .Lcolumn
.Ldone:
 ldr x0,[x28,#432]
 bl free
 mov sp,x28
 ldp d8,d9,[sp,#96]
 ldp d10,d11,[sp,#112]
 ldp d12,d13,[sp,#128]
 ldp d14,d15,[sp,#144]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp,#0]
 add sp,sp,#896
 ret
.Lbad:
 mov sp,x28
 bl abort
 brk #0
// Source pressure-height crossing, with a carried next-level flag.
.Lheight:
 mov w4,w2
 mov w5,#0
.Lheight_loop:
 sub w7,w2,#1
 mul x8,x7,x1
 add x8,x0,x8
 ldr d2,[x8]
 sub x8,x8,x1
 ldr d3,[x8]
 fadd d2,d2,d3
 fmul d2,d2,d1
 fcmp d2,d0
 cset w6,gt
 cmp w6,w5
 csel w4,w2,w4,ne
 mov w5,w6
 sub w2,w2,#1
 cmp w2,w3
 b.ge .Lheight_loop
 mov w0,w4
 ret
// Ordered full-layer stability-to-density mean, leaves pressure width d2.
.Lstability_ratio:
 ldr d0,[x26,x24,lsl #3]
 READ d1,18,1
 fdiv d0,d0,d1
 sub x10,x24,#1
 ldr d3,[x26,x10,lsl #3]
 READ d1,18
 fdiv d3,d3,d1
 fadd d0,d0,d3
 fmov d1,#2.0
 fdiv d0,d0,d1
 ret
// Wind component along the low wind, with the source speed safeguard.
.Lspeed:
 SCALAR d0,25
 SCALAR d1,26
 READ d2,13
 READ d3,14
 fmul d0,d0,d2
 fmul d1,d1,d3
 fadd d0,d0,d1
 ldr d1,[x28,#464]
 fdiv d0,d0,d1
 fabs d0,d0
 fmax d0,d0,d13
 ret
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Loutputs:.word 6,7,8,9,10,18,19,20,21,22,23,24,25,26,28,29,30,31,32
.Lsize_codes:.word 96,0,0,0,0,1,1,1,1,1,1,4,3,3,3,3,3,2,4,4,4,4,4,4,3,2,2,2,2,2,2,2,2
.p2align 3
.Kone:.quad 0x3ff0000000000000
.Ktwo:.quad 0x4000000000000000
.Kthree:.quad 0x4008000000000000
.Kfour:.quad 0x4010000000000000
.Kmillion:.quad 0x412e848000000000
.Kmin_stability:.quad 0x39b4484bfeebc2a0
.Kmin_safeguard:.quad 0x3d719799812dea11
.Kmin_gravity:.quad 0x3eb0c6f7a0b5ed8d
.Kthousand:.quad 0x408f400000000000
.Kgas_cap:.quad 0x40f86a0000000000
.Kheight_cap:.quad 0x416312d000000000
.Ktwo_pi:.quad 0x401921fb54442d18
.Ktemp_low:.quad 0x4059000000000000
.Ktemp_high:.quad 0x407f400000000000
.Kgeo_cap:.quad 0x41cdcd6500000000
.Kpressure_min:.quad 0x3f50624dd2f1a9fc
.Kpressure_cap:.quad 0x4197d78400000000
.Kinitial_ri:.quad 0x40c3878000000000
.Kblinear:.quad 0x3fc70a3d70a3d70a
.Kbquadratic:.quad 0x3fa47ae147ae147b
.Kclinear:.quad 0x3fdeb851eb851eb8
.Kcquadratic:.quad 0x3fd3333333333333
.section .note.GNU-stack,"",%progbits
