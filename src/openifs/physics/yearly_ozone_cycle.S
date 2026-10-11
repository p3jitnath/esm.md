/* Direct complete yearly ozone cycle.
 * Physics formulations/openifs/physics/yearly_ozone_cycle.md O3-SEAS revision 1.
 * Contract skills/md2asm/references/openifs/physics/suecozo.md.
 * Original climatology constants (C) ECMWF, Apache-2.0.
 * x0 immutable phase radians, x1 complete TEOZOC record.
 */
.text
.p2align 4
.global md2asm_yearly_ozone_cycle
.type md2asm_yearly_ozone_cycle,%function
md2asm_yearly_ozone_cycle:
    mrs x9,fpcr
    cbnz x9,.Lozone_bad
    cbz x0,.Lozone_bad
    cbz x1,.Lozone_bad
    tst x0,#7
    b.ne .Lozone_bad
    tst x1,#7
    b.ne .Lozone_bad
    adds x9,x0,#8
    b.cs .Lozone_bad
    ldr x10,=33008
    adds x10,x1,x10
    b.cs .Lozone_bad
    add x10,x1,#200
    add x11,x1,#776
    cmp x0,x11
    b.hs .Lozone_disjoint
    cmp x9,x10
    b.hi .Lozone_bad
.Lozone_disjoint:
    ldr x9,[x0]
    and x9,x9,#0x7fffffffffffffff
    ldr x10,=0x4130000000000000
    cmp x9,x10
    b.hi .Lozone_bad
    sub sp,sp,#112
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x29,x30,[sp,#32]
    stp d8,d9,[sp,#48]
    stp d10,d11,[sp,#64]
    stp d12,d13,[sp,#80]
    str x18,[sp,#96]
    mov x29,sp
    mov x19,x1
    mov x20,x0
    ldr d0,[x20]
    bl md2asm_cos_original_rounding
    fmov d8,d0
    ldr d0,[x20]
    bl md2asm_sin_original_rounding
    fmov d9,d0
    fmul d10,d8,d8
    fmul d0,d9,d9
    fsub d10,d10,d0
    fmov d12,#2.0
    fmul d11,d12,d9
    fmul d11,d11,d8
    adr x20,.Lozone_coefficients
    add x21,x19,#200
    mov x22,#72
.Lozone_coefficient:
    ldp d0,d1,[x20,#0]
    ldp d2,d3,[x20,#16]
    ldr d4,[x20,#32]
    fmul d1,d1,d8
    fmul d2,d2,d9
    fadd d1,d1,d2
    fmul d3,d3,d10
    fadd d1,d1,d3
    fmul d4,d4,d11
    fadd d1,d1,d4
    fmul d1,d12,d1
    fadd d0,d0,d1
    str d0,[x21],#8
    add x20,x20,#40
    subs x22,x22,#1
    b.ne .Lozone_coefficient
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x29,x30,[sp,#32]
    ldp d8,d9,[sp,#48]
    ldp d10,d11,[sp,#64]
    ldp d12,d13,[sp,#80]
    ldr x18,[sp,#96]
    add sp,sp,#112
    ret
.size md2asm_yearly_ozone_cycle,.-md2asm_yearly_ozone_cycle
.Lozone_bad:
    brk #0x31a
    b .Lozone_bad
.ltorg
.section .rodata
.p2align 3
.Lozone_coefficients:
    .quad 0x3faec80c73abc947, 0x3f129604b9a3245d, 0x3f4c15e03c155a04, 0xbf3214d57a1a7851, 0xbf2322f2734f82f5 /* QC 1 */
    .quad 0x3f5eeaa6d2674081, 0x3ed4ad8c14cbbf06, 0x3f6947cfa26a22b4, 0xbf3239be67af3bc2, 0x3f366d29cf0662f1 /* QC 2 */
    .quad 0x3f7e59f2ba9d1f60, 0x3f466094954dda7e, 0x3f4e6e80105b97d6, 0xbf1c7ebbc7c1cb11, 0xbf02808b2ac0f3d1 /* QC 3 */
    .quad 0x3f504d551d68c693, 0x3f28dd46979405dc, 0x3f3243cf62a94284, 0xbf25677051a1b344, 0x3f2779994911c1c9 /* QC 4 */
    .quad 0xbf575d13d74d594f, 0x3f12f14958e472b1, 0x3f27ef0a0e76bb48, 0xbf030413b5ea5d2b, 0xbf2920627616dd92 /* QC 5 */
    .quad 0xbf2b287a728ce556, 0xbf32655d51eaae5f, 0xbf1a5f26d7045e34, 0xbf063d841a008739, 0xbefad29437042325 /* QC 6 */
    .quad 0xbf403bb766333ac0, 0x3f0a0e9eff342826, 0x3f1ca049b70336ec, 0x3ed95ac4f28dd18f, 0x3f11299e0914fc91 /* QC 7 */
    .quad 0x3ee0aecedff776ef, 0xbf26fa1788b2c189, 0xbf2097fdb827235a, 0xbef1db74b0561e9b, 0x3f10c7a36d2cff12 /* QC 8 */
    .quad 0xbf38413f65709d21, 0xbf148f5923ddaac1, 0x3f0c2a2d25272be9, 0x3f07eb0343ac522e, 0x3f0949522e760a1d /* QC 9 */
    .quad 0x3f059466d4cb48e9, 0xbf259d2036d72ca2, 0xbf1f24887584e75b, 0xbee529070a60562c, 0x3eddb66317c12b9e /* QC 10 */
    .quad 0xbf05d37be883b785, 0xbf1b2f306f339482, 0xbf01390d67c78f76, 0x3efbec6faa5ce056, 0x3efe5b34d9fc6038 /* QC 11 */
    .quad 0xbf3338c1e86d3c43, 0xbf0952b75cf8ff5b, 0xbef2b234452c0415, 0xbef2ba41dac0d649, 0xbef05e47082740e2 /* QC 12 */
    .quad 0x3ef6961987658f7c, 0xbf10868af40f5be9, 0xbec9511b0bdb3bb7, 0x3ef040bfe3b03e21, 0x3eab71b51ee73e16 /* QC 13 */
    .quad 0xbf32abd42ec0ddab, 0xbf1cd5f99c38b04b, 0xbf16d482cea6ec93, 0xbeaea6e7be734b5a, 0x3ee58f087112bcc6 /* QC 14 */
    .quad 0xbf2506218230c748, 0xbf14d87f3290201e, 0xbf16d32b35b8c98b, 0x3ef8df49fcf93a69, 0xbee0143074ce1964 /* QC 15 */
    .quad 0xbf1ba1463645366b, 0x3eebcee885e5dd95, 0x3f16a1821b4db946, 0x3eb27476ca61b882, 0xbed23b8e42f0b7db /* QC 16 */
    .quad 0x3f404c7e5dd3f0ad, 0x3efb40a3334b5bf4, 0x3f0281e2c3af16d9, 0x3ef81b54c5293f69, 0x3ede96cc9349a6f1 /* QC 17 */
    .quad 0x3f1b724c4db66c38, 0x3ee4d0fb0d5a8f20, 0x3f097f0213ab837c, 0x3ed38a902b1fad33, 0xbed80de8cbdbe112 /* QC 18 */
    .quad 0x3f15d178831e82f8, 0xbee3647200b49707, 0x3ed06dd8c2f1a414, 0x3ec4535a5648f31f, 0x3ee06ffe846ea8ef /* QC 19 */
    .quad 0x3f32d5c599d2a47d, 0xbecd894a387fc5aa, 0xbf010cc2b1150b55, 0x3edeb4dd281feae8, 0xbec89a91cd589f0f /* QC 20 */
    .quad 0x3f2178ce47f70f96, 0xbef2aa26af9731e0, 0xbe89fc0b9bedf15b, 0x3ee290619dbaf79e, 0x3eceeb9fee13e6b4 /* QC 21 */
    .quad 0x3f3b97353b4b2fa9, 0x3f109a011d8c57e8, 0xbf1720580f35a803, 0xbf0348872d5b57ea, 0xbed3204341733ce4 /* QS 1 */
    .quad 0xbf4f6d8391199857, 0x3f1e03f705857aff, 0x3f2193a63a91cc46, 0xbef74495305359ef, 0xbf0bbecd5abc392c /* QS 2 */
    .quad 0x3f326c134e915d8b, 0x3f1f3f60681fa40a, 0x3f003a09e7098ef5, 0xbf0481415e193ae5, 0xbeea419fb28d5b73 /* QS 3 */
    .quad 0xbf2d953c3cc730ac, 0x3f09de4d7db73aea, 0x3f15930f3bdd25e0, 0xbf070ee54b1de091, 0x3ef3660e51d25aab /* QS 4 */
    .quad 0xbf2673dfcbad121c, 0x3efc4d12ad56bacd, 0x3efcadb5b0509544, 0xbee7f310d9412463, 0xbef7d589b4ca21a2 /* QS 5 */
    .quad 0xbf372fc76de83ae7, 0x3f035094c2f02a1f, 0x3ef1f8fbd4cd215b, 0xbee320ccb1d27e1a, 0x3edb7b280bda203f /* QS 6 */
    .quad 0x3f1cb46bacf74470, 0xbec417392c9c6b30, 0xbf18a8427ed59e02, 0xbef5163cad5a6bb1, 0x3eedd24deb1a6aba /* QS 7 */
    .quad 0xbf3cc532a497fa5d, 0x3ef571814c9bba05, 0x3ef40c7c652b52ea, 0x3e9f9d6fb61d1247, 0xbedb73a3e6a48f41 /* QS 8 */
    .quad 0xbed78252ab1da582, 0xbf16c3bbd70636a6, 0xbf0c5271110f46f0, 0xbecfaac0328a96c7, 0x3eaad63accbf11cc /* QS 9 */
    .quad 0x3f235f58552bab7f, 0x3f0bcae1bb1b747b, 0x3f02b8ea41d2b341, 0x3ed03715fcfda848, 0x3efdd4fd1cf6b0cc /* QS 10 */
    .quad 0x3f32abd42ec0ddab, 0xbed183f223af98c6, 0x3f046e770113506a, 0x3ef92a737110e454, 0x3efa2ed5558770f8 /* QS 11 */
    .quad 0x3f367a95c853c148, 0x3f0582f410b38177, 0x3f07865975e80e9d, 0x3ef56c22e8e32de2, 0x3efdd24deb1a6aba /* QS 12 */
    .quad 0x3f159f239c3c612f, 0x3efd2e8f099db88d, 0x3f00249058275e69, 0xbebe9a0535852e39, 0x3e99ded6ee167c21 /* QS 13 */
    .quad 0x3f22e68c91735a6b, 0x3ef2645b9f381419, 0x3f00c1993cfd616a, 0xbed74744622fa001, 0xbeef2f453cf5ffa1 /* QS 14 */
    .quad 0xbeecd5f99c38b04b, 0x3ee7677ab882e8d3, 0xbec40ea226a857c5, 0x3ec5059811d18611, 0x3ec0642edc3f0e3b /* QS 15 */
    .quad 0x40a8bc0000000000, 0xc041400000000000, 0x404a147ae147ae14, 0xc0632ccccccccccd, 0x4022851eb851eb85 /* HC 1 */
    .quad 0x4055a851eb851eb8, 0x406ad9999999999a, 0x406429999999999a, 0xc034f33333333333, 0xc0221c28f5c28f5c /* HC 2 */
    .quad 0x408d60cccccccccd, 0x4040e147ae147ae1, 0x40406b851eb851ec, 0xc059266666666666, 0x4015d70a3d70a3d7 /* HC 3 */
    .quad 0x4033fd70a3d70a3d, 0x4050566666666666, 0xc0532ccccccccccd, 0xc01d8a3d70a3d70a, 0xc01e6978d4fdf3b6 /* HC 4 */
    .quad 0xc076100000000000, 0xc02f47ae147ae148, 0xc023189374bc6a7f, 0x4014cfdf3b645a1d, 0xc040a51eb851eb85 /* HC 5 */
    .quad 0xc0408e147ae147ae, 0xc0455d70a3d70a3d, 0x4030147ae147ae14, 0x3fee305532617c1c, 0xc024f5c28f5c28f6 /* HC 6 */
    .quad 0xc04883d70a3d70a4, 0x40231b22d0e56042, 0x402475c28f5c28f6, 0xbfd868db8bac710d, 0x4022a7ef9db22d0e /* HC 7 */
    .quad 0xbfd9b22d0e560419, 0xc01296872b020c4a, 0xc025cccccccccccd, 0xc009666666666666, 0x40126353f7ced917 /* HC 8 */
    .quad 0xc02aa8f5c28f5c29, 0xc01884189374bc6a, 0x4005fbe76c8b4396, 0x400aed916872b021, 0x400e9db22d0e5604 /* HC 9 */
    .quad 0x4016b33333333333, 0xc01ae872b020c49c, 0xc00ec49ba5e353f8, 0x3fd59e83e425aee6, 0xc0099ba5e353f7cf /* HC 10 */
    .quad 0x401ce24dd2f1a9fc, 0xc01b0b4395810625, 0xc0108a3d70a3d70a, 0x3fd189374bc6a7f0, 0x3ffb53f7ced91687 /* HC 11 */
    .quad 0xc03e028f5c28f5c3, 0xc003bc6a7ef9db23, 0x3ff4147ae147ae14, 0xc0055a1cac083127, 0xbff8c49ba5e353f8 /* HC 12 */
    .quad 0x401e47ae147ae148, 0xc00172b020c49ba6, 0xbfa0e6afcce1c582, 0x3feb0be0ded288ce, 0xbfe1089a02752546 /* HC 13 */
    .quad 0xc026d70a3d70a3d7, 0xc01571a9fbe76c8b, 0xc015178d4fdf3b64, 0x3fd6631f8a0902de, 0x40084fdf3b645a1d /* HC 14 */
    .quad 0xc02b4ccccccccccd, 0xc00328f5c28f5c29, 0xc01cfced916872b0, 0x400189374bc6a7f0, 0x3fe25e353f7ced91 /* HC 15 */
    .quad 0xc02e0a3d70a3d70a, 0x3fe30be0ded288ce, 0x402bbd70a3d70a3d, 0xbfd9c0ebedfa43fe, 0x3fc15182a9930be1 /* HC 16 */
    .quad 0x40488e147ae147ae, 0x4000d916872b020c, 0x4010bc6a7ef9db23, 0x3ff8b4395810624e, 0xc002d4fdf3b645a2 /* HC 17 */
    .quad 0x402c800000000000, 0xbff5df3b645a1cac, 0x4019fae147ae147b, 0xbfdd5cfaacd9e83e, 0x3fd20902de00d1b7 /* HC 18 */
    .quad 0x4021f74bc6a7ef9e, 0xc002cac083126e98, 0x40078d4fdf3b645a, 0x3fe664c2f837b4a2, 0x3ff1ced916872b02 /* HC 19 */
    .quad 0x403ea3d70a3d70a4, 0x3fd69ad42c3c9eed, 0xbfff26e978d4fdf4, 0x3fe40aa64c2f837b, 0xbffe4189374bc6a8 /* HC 20 */
    .quad 0x4030ee147ae147ae, 0xc0095a1cac083127, 0x3ff21cac083126e9, 0x3ff3a5e353f7ced9, 0xbfd3ac710cb295ea /* HC 21 */
    .quad 0x404527ae147ae148, 0x400fd0e560418937, 0xc033ae147ae147ae, 0xc00cb4395810624e, 0xc003916872b020c5 /* HS 1 */
    .quad 0xc0527a3d70a3d70a, 0x401420c49ba5e354, 0x4027d70a3d70a3d7, 0x3fca92a305532618, 0x4010cbc6a7ef9db2 /* HS 2 */
    .quad 0x402975c28f5c28f6, 0x4018e76c8b439581, 0xbff31a9fbe76c8b4, 0xc000b4395810624e, 0xc004916872b020c5 /* HS 3 */
    .quad 0x4034dc28f5c28f5c, 0xbfd7333333333333, 0x3ff15810624dd2f2, 0xc010a2d0e5604189, 0x40206353f7ced917 /* HS 4 */
    .quad 0xc02ff0a3d70a3d71, 0xbff5f7ced916872b, 0x4007916872b020c5, 0x3fccb923a29c779a, 0x3fdaeb1c432ca57a /* HS 5 */
    .quad 0xc041f47ae147ae14, 0x4012666666666666, 0x40050a3d70a3d70a, 0xbfe8cd9e83e425af, 0x400ed916872b020c /* HS 6 */
    .quad 0x40252e147ae147ae, 0x40113f7ced916873, 0xc0291eb851eb851f, 0xc005fdf3b645a1cb, 0x3ff28b4395810625 /* HS 7 */
    .quad 0xc03bca3d70a3d70a, 0x40070e5604189375, 0x3ff651eb851eb852, 0x3fe72617c1bda512, 0x4004604189374bc7 /* HS 8 */
    .quad 0xc01bb126e978d4fe, 0xc019676c8b439581, 0xc001c6a7ef9db22d, 0x3fdc189374bc6a7f, 0xbff50624dd2f1aa0 /* HS 9 */
    .quad 0x402bf0a3d70a3d71, 0x4016ec8b43958106, 0x401374bc6a7ef9db, 0xbfc5119ce075f6fd, 0x4002a5e353f7ced9 /* HS 10 */
    .quad 0x4037deb851eb851f, 0xc004978d4fdf3b64, 0x4019cccccccccccd, 0x3ffb333333333333, 0x3ff24dd2f1a9fbe7 /* HS 11 */
    .quad 0x403cd47ae147ae14, 0x3fd4b4395810624e, 0x401645a1cac08312, 0x3ff0bc6a7ef9db23, 0xbfdc36113404ea4b /* HS 12 */
    .quad 0x40214083126e978d, 0x400672b020c49ba6, 0x40152b020c49ba5e, 0xbfe923a29c779a6b, 0xbfe5c01a36e2eb1c /* HS 13 */
    .quad 0x403011eb851eb852, 0x3fea068db8bac711, 0x4013810624dd2f1b, 0xbffa4dd2f1a9fbe7, 0xc004c8b439581062 /* HS 14 */
    .quad 0xc0056872b020c49c, 0x40004189374bc6a8, 0xbfe840b780346dc6, 0x3fd0f27bb2fec56d, 0x3feca64c2f837b4a /* HS 15 */
.section .note.GNU-stack,"",%progbits
