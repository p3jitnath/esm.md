/* Contract skills/md2asm/references/openifs/setup/fresh_model_trajectory_metadata.md.
 * Original MTRAJ fresh metadata without field allocation.
 * TGMV1560 and TGFL1096 preserve all undefined nonbase words.
 * x0 mapped fresh record and x1 capacity. Return0 or atomic2. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_fresh_model_trajectory
.type md2asm_initialize_fresh_model_trajectory,%function
md2asm_initialize_fresh_model_trajectory:
 cbz x0,.Lmtraj_bad
 tst x0,#7
 b.ne .Lmtraj_bad
 cmp x1,#2656
 b.lo .Lmtraj_bad
 adds x2,x0,#2656
 b.cs .Lmtraj_bad
 str xzr,[x0,#0]
 str xzr,[x0,#136]
 str xzr,[x0,#248]
 str xzr,[x0,#384]
 str xzr,[x0,#496]
 str xzr,[x0,#632]
 str xzr,[x0,#744]
 str xzr,[x0,#880]
 str xzr,[x0,#1560]
 str xzr,[x0,#1696]
 str xzr,[x0,#1832]
 str xzr,[x0,#1968]
 str xzr,[x0,#2104]
 str xzr,[x0,#2240]
 str xzr,[x0,#2376]
 str xzr,[x0,#2512]
 str xzr,[x0,#2648]
 mov w0,#0
 ret
.Lmtraj_bad:
 mov w0,#2
 ret
.size md2asm_initialize_fresh_model_trajectory,.-md2asm_initialize_fresh_model_trajectory
.section .note.GNU-stack,"",%progbits
