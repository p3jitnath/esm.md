# Complete Vertical Coordinate Setup on the GPU

The [scientific contract](../../../../md2fort/references/openifs/setup/vertical_coordinate_setup.md) defines the unchanged nineteen-layer model and its arguments. This setup prepares the pressure coefficients for an atmospheric column. Coefficient A has units of pascals, coefficient B has no units, and the reference pressure is 101,325 Pa. An owner is a complete allocated buffer whose bounds remain valid throughout a call.

The Arm parent keeps its allocations, array descriptions, coefficient copies, file overrides, default-coefficient child, hybrid-coordinate child and release path. Two complete numerical spans run on the GPU. The first checks the original endpoints and retains their early rejection order. The second retains forty ordered subtract, absolute-value and compare groups, repeats the endpoint checks and divides all twenty A coefficients by the reference pressure. Every floating-point operation rounds separately to nearest with ties to even. Signed zeros and gradual underflow are preserved.

The GPU entry uses one block, one thread and no dynamic shared memory. Mode zero consumes only the input A and B owners. Mode one also consumes the model owners and requires the original copied coefficient values and exact reference-pressure word. Every consumed owner is eight-byte aligned and fully bounded. Writable owners are disjoint from the other declared owners. The two copied-input arrays each have 201 words, with their first twenty words consumed. Geometry has 17,096 bytes. The model addresses and output pointers must match their declared owners before any numerical write.

| Input byte offset | Contents |
| --- | --- |
| 0 | Mode, zero or one |
| 8, 16 | Input A and B addresses |
| 24, 32 | Geometry and output-table addresses |
| 40, 48 | Complete copied-input addresses DVALH and DVBH |
| 56, 64, 72 | Model coefficient-owner addresses VAH, VALH and VBH |
| 80 | Reference-pressure address |
| 88 through 127 | Zero reserved bytes |

The [shared GPU calling rules](../gpu_call_context.md) define the address vector and context. The vector contains the 128-byte input address and a 64-byte completion address. Its 16-byte bounds record contains those two capacities. Completion holds the error at byte zero, the original endpoint rejection at byte four, newly raised numerical flags at byte eight and Arm integer comparison flags at byte twelve. Bytes sixteen, twenty-four and thirty-two hold the final D0, D1 and D2 register words. Byte forty states whether the original code writes D2. All remaining completion bytes are zero.

The application binary interface, or ABI, fixes the registers that a call preserves. Both private host phases save all general and complete vector registers, integer comparison flags, floating-point controls and status, x18 and the system error indicator. They retain their aligned 2,048-byte frame until GPU completion. They apply only the original live register writes, retain the original zero upper vector halves and combine the newly raised numerical flags with incoming status. The first insertion also preserves the link register before the original parent creates its frame.

Three complete constructor cases match every saved owner, external output, model byte, numerical status and release observation. Five raw value cases, fourteen prewrite refusals, all five native helper-return sites and an independent complete source review pass. The existing pressure-normalisation and hybrid-pressure checks remain applicable. The original pointer-identity encoding is reused, while every other metadata bit and complete owner byte remains unchanged. Detailed records stay local. These checks add no new routine credit, complete GPU forecast or timing result.
