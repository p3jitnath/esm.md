// Contract: skills/md2asm/references/openifs/support/surface_parameter_lookup.md.
// x0 names an eight-byte handle word. Return its live owned surface pointer.
// The one-model leaf reads MODEL.TEPHY.YSURF and preserves status and x18.
.arch armv8.2-a
.text
.p2align 4
.global __yos_surf_MOD_get_surf
.type __yos_surf_MOD_get_surf,%function
__yos_surf_MOD_get_surf:
 cbz x0,.Lsurface_lookup_bad
 tst x0,#7
 b.ne .Lsurface_lookup_bad
 adds x9,x0,#8
 b.cs .Lsurface_lookup_bad
 adrp x10,md2asm_owned_initial_model_owner
 ldr x10,[x10,:lo12:md2asm_owned_initial_model_owner]
 cbz x10,.Lsurface_lookup_bad
 movz x11,#(1578328 & 65535)
 movk x11,#(1578328 >> 16),lsl#16
 ldr x10,[x10,x11]
 cbz x10,.Lsurface_lookup_bad
 ldr x9,[x0]
 cmp x9,x10
 b.ne .Lsurface_lookup_bad
 mov x0,x10
 ret
.Lsurface_lookup_bad:
 b abort
.size __yos_surf_MOD_get_surf,.-__yos_surf_MOD_get_surf
.section .note.GNU-stack,"",%progbits
