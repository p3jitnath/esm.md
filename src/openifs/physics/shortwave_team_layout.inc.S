/* Private shortwave worker interface. Counters are modulo 2^64.
 * x28 points to one 192-byte record, aligned to 64 bytes.
 * x0..x7 and eight caller-stack slots retain the original 16-address ABI.
 * Only argument 15 points to the worker's private flux-record clone.
 * The original first/last-column scalar pointers and every input pitch remain.
 * A private bridge receives its worker-record address in x0.
 * Metadata only. This file emits no numerical instructions or storage. */
#ifndef MD2ASM_SHORTWAVE_TEAM_LAYOUT
#define MD2ASM_SHORTWAVE_TEAM_LAYOUT
#define SW_TEAM_REQUESTED 8
#define SW_COUNTER_FAST 0
#define SW_COUNTER_WIDE 8
#define SW_COUNTER_EXP 16
#define SW_COUNTER_PREFIX_BYTES 64
#define SW_WORK_BEGIN 64
#define SW_WORK_END 72
#define SW_WORK_SCRATCH 80
#define SW_WORK_FLUX 88
#define SW_WORK_NUMERICAL_FPSR 96
#define SW_WORK_FINAL_ERRNO 104
#define SW_WORK_ERRNO_POINTER 112
#define SW_WORK_ENTRY_FPCR 120
#define SW_WORK_ENTRY_FPSR 128
#define SW_WORK_ENTRY_ERRNO 136
#define SW_WORK_SEEN 144
#define SW_WORK_ACTUAL_TEAM 152
#define SW_WORK_THREAD_INDEX 160
#define SW_WORK_CONTROLLER 168
#define SW_WORK_ARGUMENTS 176
#define SW_WORK_RESERVED 184
#define SW_WORK_BYTES 192
#define SW_CONTROLLER_ARGUMENTS 0
#define SW_CONTROLLER_FIRST 128
#define SW_CONTROLLER_LAST 136
#define SW_CONTROLLER_FULL_COLUMNS 144
#define SW_CONTROLLER_SAMPLES 152
#define SW_CONTROLLER_LAYERS 160
#define SW_CONTROLLER_ENTRY_FPCR 168
#define SW_CONTROLLER_ENTRY_FPSR 176
#define SW_CONTROLLER_ERRNO_POINTER 184
#define SW_CONTROLLER_ENTRY_ERRNO 192
#define SW_CONTROLLER_ACTUAL_TEAM 200
#define SW_CONTROLLER_BAD_TEAM 208
#define SW_CONTROLLER_ALLOCATED_WORKERS 216
#define SW_CONTROLLER_FAST_TOTAL 224
#define SW_CONTROLLER_WIDE_TOTAL 232
#define SW_CONTROLLER_EXP_TOTAL 240
#define SW_CONTROLLER_REQUIRED_TEAM 248
#define SW_CONTROLLER_WORKERS 256
#define SW_CONTROLLER_BYTES 2048
#define SW_PARENT_FRAME_BYTES 1536
#define SW_PARENT_SAVED_CONTEXT 136
#define SW_PARENT_PRIVATE_DELTA_FLAG 1012
#define SW_SELECTED_COLUMNS 8
#define SW_SELECTED_LAYERS 19
#define SW_SELECTED_SAMPLES 112
#define SW_SELECTED_BANDS 14
#define SW_PAYLOAD_SCRATCH_BYTES 248648
#define SW_PAYLOAD_FLUX_OFFSET 248656
#define SW_PAYLOAD_FLUX_BYTES 3360
#define SW_PAYLOAD_OUTPUTS_OFFSET 252016
#define SW_PAYLOAD_OUTPUT_BYTES 36416
#define SW_PAYLOAD_BYTES 288432
#define SW_PRIVATE_PARENT md2asm_sw_private_parent_payload
#define SW_PRIVATE_BRIDGE md2asm_sw_private_invoke
#define SW_PRIVATE_REFLECT md2asm_sw_private_reflect
#define SW_PRIVATE_GENERATOR md2asm_sw_private_cloud_generator
#endif
