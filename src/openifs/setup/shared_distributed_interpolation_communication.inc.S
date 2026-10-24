/* Source interfaces, bounds and source-order scope: skills/md2asm/references/openifs/radiation/live_radiation_second_interpolation.md. */
.arch armv8.2-a
.text
.p2align 4
.global MD2ASM_COMM_ENTRY
.type MD2ASM_COMM_ENTRY,%function
MD2ASM_COMM_ENTRY:
 sub sp,sp,#2048
 stp x29,x30,[sp,#64]
 stp x19,x20,[sp,#80]
 stp x21,x22,[sp,#96]
 stp x23,x24,[sp,#112]
 stp x25,x26,[sp,#128]
 stp x27,x28,[sp,#144]
 str x18,[sp,#160]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,#0
 mov x23,#0
 mov x24,#0
 str xzr,[sp,#512]
 str xzr,[sp,#520]
 str xzr,[sp,#528]
 str xzr,[sp,#536]
 str xzr,[sp,#608]
 str xzr,[sp,#616]
 str wzr,[sp,#648]
 str wzr,[sp,#644]
 ldr w9,[x19,#1016]
 movz w10,#0xd41d
 movk w10,#0x64,lsl#16
 cmp w9,w10
 b.hi .Lr_abort
 ldr w9,[x21,#4]
 str w9,[sp,#764]
 ldr x9,[x21,#32]
 str x9,[sp,#768]
 ldr x9,[x21,#40]
 str x9,[sp,#776]
 ldr x9,[x20,#6088]
 str x9,[sp,#704]
 ldr x9,[x20,#6176]
 str x9,[sp,#712]
 ldr x9,[x20,#7640]
 add x9,x9,#4
 str x9,[sp,#720]
 ldr x9,[x20,#6264]
 str x9,[sp,#728]
 ldr x9,[x20,#6456]
 str x9,[sp,#736]
 ldr x9,[x20,#6520]
 str x9,[sp,#744]
 ldr x9,[x20,#6152]
 str w9,[sp,#752]
 ldr w9,[x19,#1720]
 str w9,[sp,#756]
 ldr w9,[x19,#1668]
 str w9,[sp,#760]
 ldr w9,[x19,#1724]
 ldr w10,[x19,#1348]
 sub w9,w9,w10
 ldr w11,[x19,#1656]
 cmp w9,w11
 csel w9,w9,w11,ge
 ldr w11,[sp,#756]
 sub w9,w9,w11
 neg w10,w10
 cmp w9,w10
 csel w25,w9,w10,ge
 ldr w9,[x19,#1728]
 ldr w10,[x19,#1352]
 add w9,w9,w10
 ldr w11,[x19,#1660]
 cmp w9,w11
 csel w9,w9,w11,le
 ldr w11,[sp,#756]
 sub w9,w9,w11
 ldr w11,[sp,#760]
 add w11,w11,w10
 cmp w9,w11
 csel w26,w9,w11,le
 ldr w0,[x19,#1016]
 uxtw x0,w0
 lsl x0,x0,#2
 bl malloc
 mov x22,x0
 cmp x0,#0
 cset w0,eq
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Lr_exit_status
 mov x0,x22
 mov w1,#255
 ldr w2,[x19,#1016]
 lsl x2,x2,#2
 bl memset
 mov w9,#2
 str w9,[sp,#688]
 /* Source processor ownership for every actual halo column. */
 mov w27,w25
.Lr_map_row:
 bl .Lr_row_values
 str w9,[sp,#796]
 str w10,[sp,#800]
 str w11,[sp,#804]
 str w12,[sp,#784]
 mov w13,w12
 cmp w13,#1
 b.ge .Lr_fold_south
 mov w14,#1
 sub w13,w14,w13
 b .Lr_fold_ready
.Lr_fold_south:
#ifdef MD2ASM_RO
 ldr w14,[x19,#1648]
#else
 mov w14,#2560
#endif
 cmp w13,w14
 b.le .Lr_fold_ready
#ifdef MD2ASM_RO
 ldr w14,[x19,#1648]
 lsl w14,w14,#1
 add w14,w14,#1
#else
 mov w14,#5121
#endif
 sub w13,w14,w13
.Lr_fold_ready:
 str w13,[sp,#788]
 mov w28,w9
 add w14,w9,w10
 str w14,[sp,#812]
.Lr_map_point:
 ldr w14,[sp,#812]
 cmp w28,w14
 b.ge .Lr_map_row_next
 ldr w12,[sp,#784]
 bl .Lr_canonical_longitude
 str w13,[sp,#808]
 mov w14,#-1
 str w14,[sp,#816]
 mov w14,#0
.Lr_map_region:
 ldr x9,[sp,#736]
 ldr w10,[x9,w14,uxtw#2]
 ldr x9,[sp,#744]
 ldr w11,[x9,w14,uxtw#2]
 ldr w12,[sp,#788]
 cmp w12,w10
 b.lt .Lr_map_region_next
 cmp w12,w11
 b.gt .Lr_map_region_next
 ldr x9,[sp,#728]
 ldr w11,[x9,w14,uxtw#2]
 sub w12,w12,w10
 add w12,w12,w11
 add w12,w12,#1
 ldr x9,[sp,#768]
 ldr w15,[x9,w14,uxtw#2]
 mov w16,#0
.Lr_map_column:
 ldr w9,[sp,#752]
 madd w9,w16,w9,w12
 ldr x10,[sp,#704]
 ldr w10,[x10,w9,uxtw#2]
 ldr x11,[sp,#712]
 ldr w11,[x11,w9,uxtw#2]
 ldr w13,[sp,#808]
 cmp w13,w10
 b.lt .Lr_map_column_next
 add w11,w11,w10
 cmp w13,w11
 b.ge .Lr_map_column_next
 lsl w9,w14,#1
 add w9,w9,w16
 ldr x10,[sp,#776]
 ldr w10,[x10,w9,uxtw#2]
 str w10,[sp,#816]
.Lr_map_column_next:
 add w16,w16,#1
 cmp w16,w15
 b.lo .Lr_map_column
.Lr_map_region_next:
 add w14,w14,#1
 cmp w14,#3
 b.lo .Lr_map_region
 ldr w9,[sp,#816]
 sub w10,w9,#1
 cmp w10,#3
 b.hi .Lr_abort
 ldr w10,[sp,#796]
 ldr w11,[sp,#804]
 sub w10,w28,w10
 add w10,w10,w11
 str w9,[x22,w10,uxtw#2]
 add w28,w28,#1
 b .Lr_map_point
.Lr_map_row_next:
 add w27,w27,#1
 cmp w27,w26
 b.le .Lr_map_row
 mov w9,#3
 str w9,[sp,#688]
 /* Count the source request lists without changing their final order. */
 mov w27,w25
 mov w17,#0
.Lr_count_row:
 bl .Lr_row_values
 mov w28,w9
 add w10,w10,w9
.Lr_count_point:
 cmp w28,w10
 b.ge .Lr_count_next_row
 sub w12,w28,w9
 add w12,w12,w11
 ldr w13,[x22,w12,uxtw#2]
 ldr w12,[sp,#764]
 cmp w13,w12
 b.eq .Lr_count_point_next
 sub w13,w13,#1
 add x14,sp,#512
 ldr w15,[x14,w13,uxtw#2]
 add w15,w15,#1
 str w15,[x14,w13,uxtw#2]
 add w17,w17,#1
.Lr_count_point_next:
 add w28,w28,#1
 b .Lr_count_point
.Lr_count_next_row:
 add w27,w27,#1
 cmp w27,w26
 b.le .Lr_count_row
 str w17,[sp,#632]
 /* Four rank-one descriptors for the unchanged nonblocking count exchange. */
 mov w9,#1
 str w9,[sp,#544]
 str w9,[sp,#548]
 str w9,[sp,#552]
 str w9,[sp,#556]
 add x0,sp,#256
 add x1,sp,#512
 mov x2,#4
 bl .Lr_descriptor
 add x0,sp,#320
 add x1,sp,#544
 mov x2,#4
 bl .Lr_descriptor
 add x0,sp,#384
 add x1,sp,#528
 mov x2,#4
 bl .Lr_descriptor
 mov w9,#5
 str w9,[sp,#660]
 mov w9,#2401
 str w9,[sp,#656]
 add x0,sp,#256
 add x1,sp,#320
 add x2,sp,#384
 mov x3,x1
 mov x4,#0
 mov x5,#0
 add x6,sp,#660
 mov x7,#0
 str xzr,[sp]
 add x9,sp,#624
 str x9,[sp,#8]
 adr x9,.Lr_count_string
 str x9,[sp,#16]
 mov x9,#(.Lr_count_string_end-.Lr_count_string)
 str x9,[sp,#24]
 bl __mpl_alltoallv_mod_MOD_mpl_alltoallv_integer
 mov w9,#1
 str w9,[sp,#648]
 /* Private incoming capacity is reserved before sends, so failure can unwind. */
 ldr w0,[sp,#632]
 uxtw x0,w0
 lsl x0,x0,#3
 bl malloc
 mov x23,x0
 movz x0,#0x83a0
 movk x0,#0xc9a,lsl#16
 bl malloc
 mov x24,x0
 cmp x23,#0
 cset w0,eq
 cmp x24,#0
 cset w9,eq
 orr w0,w0,w9
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Lr_pending_failure
 /* Stable source order: rank, latitude, then longitude. */
 mov w9,#0
 str w9,[sp,#664]
 mov x28,#0
 str x28,[sp,#824]
.Lr_sort_rank:
 ldr w9,[sp,#664]
 add w9,w9,#1
 ldr w10,[sp,#764]
 cmp w9,w10
 b.eq .Lr_sort_rank_next
 mov w27,w25
.Lr_sort_row:
 bl .Lr_row_values
 str w9,[sp,#796]
 str w10,[sp,#800]
 str w11,[sp,#804]
 str w12,[sp,#784]
 mov w28,w9
 add w14,w9,w10
 str w14,[sp,#812]
.Lr_sort_point:
 ldr w14,[sp,#812]
 cmp w28,w14
 b.ge .Lr_sort_row_next
 ldr w9,[sp,#796]
 ldr w10,[sp,#804]
 sub w9,w28,w9
 add w9,w9,w10
 ldr w9,[x22,w9,uxtw#2]
 ldr w10,[sp,#664]
 add w10,w10,#1
 cmp w9,w10
 b.ne .Lr_sort_point_next
 ldr w12,[sp,#784]
 bl .Lr_canonical_longitude
 ldr x9,[sp,#824]
 add x10,x23,x9,lsl#3
 stp w12,w13,[x10]
 add x9,x9,#1
 str x9,[sp,#824]
.Lr_sort_point_next:
 add w28,w28,#1
 b .Lr_sort_point
.Lr_sort_row_next:
 add w27,w27,#1
 cmp w27,w26
 b.le .Lr_sort_row
.Lr_sort_rank_next:
 ldr w9,[sp,#664]
 add w9,w9,#1
 str w9,[sp,#664]
 cmp w9,#4
 b.lo .Lr_sort_rank
 ldr x9,[sp,#824]
 ldr w10,[sp,#632]
 cmp x9,x10
 b.ne .Lr_abort
 mov w9,#4
 str w9,[sp,#688]
 /* Send each source request section in ascending rank order. */
 str wzr,[sp,#628]
 str wzr,[sp,#664]
 str wzr,[sp,#668]
.Lr_send_rank:
 ldr w27,[sp,#664]
 add x9,sp,#512
 ldr w28,[x9,w27,uxtw#2]
 cbz w28,.Lr_send_next
 ldr w9,[sp,#668]
 add x1,x23,x9,lsl#3
 add x0,sp,#256
 lsl w2,w28,#1
 bl .Lr_descriptor
 add w9,w27,#1
 str w9,[sp,#652]
 add x0,sp,#256
 add x1,sp,#652
 add x2,sp,#656
 mov x3,#0
 add x4,sp,#660
 mov x5,#0
 ldr w9,[sp,#628]
 add x6,sp,#608
 add x6,x6,x9,lsl#2
 adr x7,.Lr_send_string
 mov x9,#(.Lr_send_string_end-.Lr_send_string)
 str x9,[sp]
 bl __mpl_send_mod_MOD_mpl_send_int
 ldr w9,[sp,#628]
 add w9,w9,#1
 str w9,[sp,#628]
 ldr w9,[sp,#668]
 add w9,w9,w28
 str w9,[sp,#668]
.Lr_send_next:
 add w27,w27,#1
 str w27,[sp,#664]
 cmp w27,#4
 b.lo .Lr_send_rank
 bl .Lr_wait_counts
 mov w9,#5
 str w9,[sp,#688]
 /* The incoming buffer is bounded by four source global halo capacities. */
 add x9,sp,#528
 mov w10,#0
 mov w11,#0
.Lr_incoming_count:
 ldr w12,[x9,w10,uxtw#2]
 movz w13,#0xd41d
 movk w13,#0x64,lsl#16
 cmp w12,w13
 b.hi .Lr_abort
 add w11,w11,w12
 add w10,w10,#1
 cmp w10,#4
 b.lo .Lr_incoming_count
 str w11,[sp,#636]
 str wzr,[sp,#664]
 str wzr,[sp,#668]
.Lr_recv_rank:
 ldr w27,[sp,#664]
 add x9,sp,#528
 ldr w28,[x9,w27,uxtw#2]
 cbz w28,.Lr_recv_next
 ldr w9,[sp,#668]
 add x1,x24,x9,lsl#3
 add x0,sp,#256
 lsl w2,w28,#1
 bl .Lr_descriptor
 add w9,w27,#1
 str w9,[sp,#652]
 add x0,sp,#256
 add x1,sp,#652
 add x2,sp,#656
 mov x3,#0
 mov x4,#0
 mov x5,#0
 mov x6,#0
 mov x7,#0
 stp xzr,xzr,[sp]
 adr x9,.Lr_recv_string
 str x9,[sp,#16]
 mov x9,#(.Lr_recv_string_end-.Lr_recv_string)
 str x9,[sp,#24]
 bl __mpl_recv_mod_MOD_mpl_recv_int
 ldr w9,[sp,#668]
 add w9,w9,w28
 str w9,[sp,#668]
.Lr_recv_next:
 add w27,w27,#1
 str w27,[sp,#664]
 cmp w27,#4
 b.lo .Lr_recv_rank
 add x0,sp,#448
 add x1,sp,#608
 ldr w2,[sp,#628]
 bl .Lr_descriptor
 add x0,sp,#448
 mov x1,#0
 mov x2,#0
 mov x3,#0
 adr x4,.Lr_wait_send_string
 mov x5,#(.Lr_wait_send_string_end-.Lr_wait_send_string)
 bl __mpl_wait_mod_MOD_mpl_waits
 /* Source prefix arrays preserve empty-rank transitions. */
 add x9,sp,#560
 add x10,sp,#584
 add x11,sp,#512
 add x12,sp,#528
 mov w13,#1
 mov w14,#1
 mov w15,#0
 mov w16,#0
 str w13,[x9]
 str w14,[x10]
.Lr_prefix:
 ldr w17,[x11,w15,uxtw#2]
 add w13,w13,w17
 ldr w0,[x12,w15,uxtw#2]
 add w14,w14,w0
 orr w17,w17,w0
 cmp w17,#0
 cinc w16,w16,ne
 add w15,w15,#1
 str w13,[x9,w15,uxtw#2]
 str w14,[x10,w15,uxtw#2]
 cmp w15,#4
 b.lo .Lr_prefix
 str w16,[sp,#640]
 str w16,[x19,#1336]
 sub w13,w13,#1
 sub w14,w14,#1
 str w13,[x19,#1340]
 str w14,[x19,#1344]
 /* All five persistent source owners are allocated before publication. */
 add x0,x19,#864
 mov x1,#1
 uxtw x2,w16
 bl .Lr_alloc1
 cbnz w0,.Lr_owned_failure
 add x0,x19,#800
 mov x1,#1
 ldr w2,[sp,#640]
 add w2,w2,#1
 bl .Lr_alloc1
 cbnz w0,.Lr_owned_failure
 add x0,x19,#736
 mov x1,#1
 ldr w2,[sp,#640]
 add w2,w2,#1
 bl .Lr_alloc1
 cbnz w0,.Lr_owned_failure
 add x0,x19,#608
 mov x1,#1
 ldr w2,[sp,#636]
 bl .Lr_alloc1
 cbnz w0,.Lr_owned_failure
 add x0,x19,#672
 mov x1,#1
 ldr w2,[sp,#632]
 bl .Lr_alloc1
 cbnz w0,.Lr_owned_failure
 mov w0,#0
 b .Lr_owners_agree
.Lr_owned_failure:
 mov w0,#1
.Lr_owners_agree:
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Lr_exit_status
 /* Compact communication list and source pointer transitions. */
 mov w27,#0
 mov w28,#0
.Lr_comm_rank:
 add x9,sp,#512
 ldr w10,[x9,w27,uxtw#2]
 add x9,sp,#528
 ldr w11,[x9,w27,uxtw#2]
 orr w10,w10,w11
 cbz w10,.Lr_comm_next
 ldr x9,[x19,#864]
 add w10,w27,#1
 str w10,[x9,w28,uxtw#2]
 add x9,sp,#560
 ldr w10,[x9,w27,uxtw#2]
 add w11,w27,#1
 ldr w11,[x9,w11,uxtw#2]
 ldr x9,[x19,#800]
 str w10,[x9,w28,uxtw#2]
 add w12,w28,#1
 str w11,[x9,w12,uxtw#2]
 add x9,sp,#584
 ldr w10,[x9,w27,uxtw#2]
 add w11,w27,#1
 ldr w11,[x9,w11,uxtw#2]
 ldr x9,[x19,#736]
 str w10,[x9,w28,uxtw#2]
 str w11,[x9,w12,uxtw#2]
 add w28,w28,#1
.Lr_comm_next:
 add w27,w27,#1
 cmp w27,#4
 b.lo .Lr_comm_rank
 /* Sender positions use folded physical latitudes. */
 mov w27,#0
.Lr_send_positions:
 ldr w9,[sp,#636]
 cmp w27,w9
 b.hs .Lr_recv_positions_start
 add x9,x24,x27,lsl#3
 ldp w12,w28,[x9]
 cmp w12,#1
 b.ge .Lr_send_fold_south
 mov w9,#1
 sub w12,w9,w12
 b .Lr_send_fold_ready
.Lr_send_fold_south:
#ifdef MD2ASM_RO
 ldr w9,[x19,#1648]
#else
 mov w9,#2560
#endif
 cmp w12,w9
 b.le .Lr_send_fold_ready
#ifdef MD2ASM_RO
 ldr w9,[x19,#1648]
 lsl w9,w9,#1
 add w9,w9,#1
#else
 mov w9,#5121
#endif
 sub w12,w9,w12
.Lr_send_fold_ready:
 ldr w9,[sp,#756]
 sub w12,w12,w9
 ldr x9,[x19,#8]
 ldr x10,[x19,#56]
 sub w12,w12,w10
 ldr w11,[x9,w12,sxtw#2]
 ldr x9,[x19,#136]
 ldr w10,[x9,w12,sxtw#2]
 add w10,w10,w28
 sub w10,w10,w11
 add w10,w10,#1
 ldr x9,[x19,#608]
 str w10,[x9,w27,uxtw#2]
 add w27,w27,#1
 b .Lr_send_positions
.Lr_recv_positions_start:
 mov w27,#0
.Lr_recv_positions:
 ldr w9,[sp,#632]
 cmp w27,w9
 b.hs .Lr_final_reduce
 add x9,x23,x27,lsl#3
 ldp w12,w28,[x9]
 ldr x9,[sp,#720]
 ldr w13,[x9,w12,sxtw#2]
 ldr w9,[sp,#756]
 sub w12,w12,w9
 ldr x9,[x19,#8]
 ldr x10,[x19,#56]
 sub w12,w12,w10
 ldr w11,[x9,w12,sxtw#2]
 ldr x9,[x19,#136]
 ldr w10,[x9,w12,sxtw#2]
 sub w11,w28,w11
 add w11,w11,w13
 sdiv w9,w11,w13
 msub w11,w9,w13,w11
 add w11,w11,w10
 add w11,w11,#1
 ldr x9,[x19,#672]
 str w11,[x9,w27,uxtw#2]
 add w27,w27,#1
 b .Lr_recv_positions
.Lr_final_reduce:
 add x0,sp,#640
 adr x1,.Lr_max
 add x2,sp,#644
 mov x3,#0
 mov x4,#0
 adr x5,.Lr_reduce_string
 mov x6,#3
 mov x7,#(.Lr_reduce_string_end-.Lr_reduce_string)
 bl __mpl_allreduce_mod_MOD_mpl_allreduce_int_scalar
 mov w0,#0
 b .Lr_exit_status
.Lr_pending_failure:
 str w0,[sp,#644]
 bl .Lr_wait_counts
 ldr w0,[sp,#644]
.Lr_exit_status:
 str w0,[sp,#644]
 mov x0,x22
 bl free
 mov x0,x23
 bl free
 mov x0,x24
 bl free
 ldr w0,[sp,#644]
 ldp x19,x20,[sp,#80]
 ldp x21,x22,[sp,#96]
 ldp x23,x24,[sp,#112]
 ldp x25,x26,[sp,#128]
 ldp x27,x28,[sp,#144]
 ldr x18,[sp,#160]
 ldp x29,x30,[sp,#64]
 add sp,sp,#2048
 ret
.Lr_abort:
 adr x0,.Lr_debug
 ldr w1,[sp,#764]
 ldr w2,[sp,#688]
 mov w3,w27
 mov w4,w28
 ldr w5,[sp,#816]
 ldr w6,[sp,#784]
 ldr w7,[sp,#788]
 bl printf
 mov x0,#0
 bl fflush
 mov w0,#3
 bl fortran_mpi_abort
 brk #0
.size MD2ASM_COMM_ENTRY,.-MD2ASM_COMM_ENTRY
/* Local row metadata, without changing saved registers or the count accumulator. */
.Lr_row_values:
 ldr x9,[x19,#56]
 sub w12,w27,w9
 ldr x9,[x19,#8]
 ldr w9,[x9,w12,sxtw#2]
 ldr x10,[x19,#72]
 ldr w10,[x10,w12,sxtw#2]
 ldr x11,[x19,#136]
 ldr w11,[x11,w12,sxtw#2]
 ldr w12,[sp,#756]
 add w12,w12,w27
 ret
.Lr_canonical_longitude:
 ldr x9,[sp,#720]
 ldr w13,[x9,w12,sxtw#2]
 sub w14,w28,#1
 add w14,w14,w13
 sdiv w15,w14,w13
 msub w13,w15,w13,w14
 add w13,w13,#1
 ret
.Lr_descriptor:
 stp xzr,xzr,[x0]
 stp xzr,xzr,[x0,#16]
 stp xzr,xzr,[x0,#32]
 stp xzr,xzr,[x0,#48]
 str x1,[x0]
 mov x9,#-1
 str x9,[x0,#8]
 mov x9,#4
 str x9,[x0,#16]
 str x9,[x0,#32]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[x0,#24]
 mov x9,#1
 str x9,[x0,#40]
 str x9,[x0,#48]
 str x2,[x0,#56]
 ret
.Lr_wait_counts:
 stp x18,x30,[sp,#-32]!
 add x0,sp,#656
 mov x1,#0
 mov x2,#0
 mov x3,#0
 adr x4,.Lr_wait_count_string
 mov x5,#(.Lr_wait_count_string_end-.Lr_wait_count_string)
 bl __mpl_wait_mod_MOD_mpl_wait1
 str wzr,[sp,#680]
 ldp x18,x30,[sp],#32
 ret
.Lr_alloc1:
 stp x0,x1,[sp,#-48]!
 stp x2,x30,[sp,#16]
 sub x0,x2,x1
 add x0,x0,#1
 lsl x0,x0,#2
 bl malloc
 cbz x0,.Lr_alloc_bad
 ldp x9,x10,[sp]
 ldr x11,[sp,#16]
 str x0,[x9]
 neg x12,x10
 str x12,[x9,#8]
 mov x12,#4
 str x12,[x9,#16]
 str x12,[x9,#32]
 mov x12,#0x101
 lsl x12,x12,#32
 str x12,[x9,#24]
 mov x12,#1
 str x12,[x9,#40]
 stp x10,x11,[x9,#48]
 mov w0,#0
 b .Lr_alloc_done
.Lr_alloc_bad:
 mov w0,#1
.Lr_alloc_done:
 ldr x30,[sp,#24]
 add sp,sp,#48
 ret
.section .rodata
.Lr_count_string: .ascii "SLRSET_IPCNTR"
.Lr_count_string_end:
.Lr_send_string: .ascii "SLRSET: IRLSTLAT, IRLSTLON"
.Lr_send_string_end:
.Lr_recv_string: .ascii "SLRSET: ISLSTLAT, ISLSTLON"
.Lr_recv_string_end:
.Lr_wait_count_string: .ascii "SLRSET: WAITALL"
.Lr_wait_count_string_end:
.Lr_wait_send_string: .ascii "SLRSET: SENDING HALO ICOMBUF"
.Lr_wait_send_string_end:
.Lr_reduce_string: .ascii "SLRSET:ISLPROCSMX"
.Lr_reduce_string_end:
.Lr_debug: .asciz "HALO_ABORT rank%d stage%d row%d lon%d pc%d global%d fold%d\n"
.Lr_max: .ascii "MAX"
.section .note.GNU-stack,"",%progbits
