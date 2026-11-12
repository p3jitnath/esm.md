# Physics Time Controls And Cloud Levels

The selected SUPHY2 setup defines the physics time step, observing heights and cloud-transition levels. SUPHMF calls it after SUPHY1. This direct implementation supports the actual ECMWF branch, 19 atmospheric layers and the first uppercase empty NAMPHY2 group. It preserves the original model and all source literal values. Formatted diagnostic printing remains outside this numerical interface.

The Arm application binary interface, or ABI, is `int md2asm_initialize_physics_time_controls(text, length, output, capacity, inputs)`, using x0 through x4. The output is one 160-byte TPHY2 record. The input record has 40 bytes and the following layout.

| Byte offset | Input | Required value or extent |
| --- | --- | --- |
| 0, 8 | VALH pointer and byte capacity | 20 FP64 coefficients, at least 160 bytes |
| 16, 24 | VBH pointer and byte capacity | 20 FP64 coefficients, at least 160 bytes |
| 32 | NFLEVG, int32 | 19 layers |
| 36 | LECMWF, logical32 | One |

VALH and VBH are dimensionless hybrid-coordinate coefficients at layer boundaries zero through 19. Every value must be finite and between zero and one, with either signed zero allowed. Production receives their live bases from Geometry descriptors at offsets 16 and 80. Archived coefficient files are verification inputs only. Each declared range is mapped and must not wrap. The output, input record and arrays are eight-byte aligned. The output must be disjoint from every input. Text contains one through 262,144 bytes and capacity is at least 160. FPCR, the floating-point control register, must be zero.

The parent validates the complete interface and empty input group before changing the output. It returns zero on success and two on an atomic refusal. Its only call outside this source is the existing bounded empty-group reader. It uses an 80-byte stack frame, preserves x18 and all ABI saved registers, and keeps the stack sixteen-byte aligned. It preserves errno and the incoming floating-point controls. Arithmetic adds its natural exception flags. No allocation, original OpenIFS callable, module state, type table or numerical fallback is used.

The raw leaf entry is `void md2asm_set_physics_time_controls_raw(output, VALH, VBH)` in x0 through x2. Its caller must already satisfy the validated parent contract. Both entries assign all 160 output bytes. The two transition indices occupy bytes zero and four. Seventeen FP64 values begin at byte eight in the original TPHY2 order, followed by four false logical values at bytes 144 through 159.

The physics step TSPHY is one second at this source stage. The source also sets HCLP to 1,500 m, screen heights HTCLS and HVCLS to 2 m and 10 m, WMO cloud heights HWMOHIGH and HWMOLOW to 5,000 m and 2,500 m, and HTKERAF to 20 m. Its dimensionless cloud thresholds HTSHM and HTSML are 0.450 and 0.785. All remaining switches and empirical gust constants retain their original defaults.

For each layer j from one through 19, add VALH(j) to VBH(j), add VALH(j−1), add VBH(j−1), then multiply by 0.5. Each operation rounds separately in FP64. The last layer with a result at most HTSHM becomes NTSHM, and the last with a result at most HTSML becomes NTSML. Each index starts at zero. Threshold ties qualify. There is no contraction or reassociation. SUPHY2 supplies the live TSPHY consumed by the separately checked SUCLDP setup.

Four complete genuine source cases compare 640 bytes with zero differences. They cover the live coordinates, each threshold tie and a grid with no qualifying layer. The live grid gives NTSHM=10 and NTSML=14. Independent decimal layer classification and known transition cases give 32 physical and ordering checks. All native ABI masks are zero, FPCR and FPSR agree exactly at the source boundary, inputs remain unchanged and output guards remain intact. Five atomic refusals and one complete output ending at a protected page pass.

Original formatted diagnostics clear errno to zero and the original reference uses x18. The raw assembly preserves incoming errno and x18. These declared service differences do not change any numerical output. An independent source, layout and ABI review passes without rerunning the gate. A static assembly entry writes all 160 exact bytes with no undefined symbols or dynamic dependencies. Enclosing final MODEL integration and a complete autonomous forecast remain separate work.
