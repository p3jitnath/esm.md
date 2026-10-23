# Source-Ordered Operational Model Initialisation

This parent joins the accepted model storage, initial-file loading, terrain calculation, temperature conversion and initial spectral norms. A spectral norm measures the size of a field represented by spherical waves. The selected configuration is the supplied 9 km grid with 137 layers and four MPI processes. MPI is the public interface for communication between processes. Full physics setup, time steps and forecast output remain separate work.

The [assembly source](../../../../../src/openifs/input/source_ordered_operational_model_initialization.S) uses the accepted [loaded-model storage](loaded_operational_model_composition.md), [live interpolation halo](../dynamics/spherical_interpolation_halo.md), [terrain](../setup/distributed_operational_orography_initialization.md), [temperature conversion](operational_virtual_temperature_conversion.md) and [distributed norms](../dynamics/distributed_spectral_norms.md). Production uses direct assembly children and public libraries. The original OpenIFS norm routine appears only in the separate verification process.

## Interface and Ownership

`md2asm_create_initialized_operational_model` receives seven address arguments in registers x0 through x6. All byte counts below are exact. The caller supplies valid, aligned, nonwrapping buffers and retains borrowed storage through release.

| Argument | Buffer and meaning |
| --- | --- |
| x0 | Borrowed 9,968-byte startup record |
| x1 | Borrowed 1,872-byte sidecar, which names the same final Geometry and partition |
| x2, x3, x4 | Separate spectral, surface and upper-air file paths, each terminated by a zero byte |
| x5 | Borrowed 120-byte table of addresses for fifteen distinct caller-owned model alias slots |
| x6 | Caller-owned, eight-byte output slot, initially zero |

Records and address slots require eight-byte alignment. File paths follow the accepted readers' bounds. Model alias slots retain their existing loaded-model contract. The returned 64-byte owner is aligned to at least eight bytes and has the following layout.

| Byte offset | Stored value |
| --- | --- |
| 0 | Owned 800-byte model-storage record |
| 8 | Ownership bits, with 1 for the halo and 2 for terrain |
| 16 | Borrowed final Geometry address |
| 24 | Owned 5,615,952-byte norm-result buffer |
| 32, 40, 48 | Owned FP64 accumulated norm values |
| 56 | Fixed creation marker used by release |

The source's three accumulated norm values start in its zero-filled ELF storage. ELF is the executable file format. Their owned initial representation is therefore positive zero. The norm controls are six source-produced int32 values, 0, 0, 0, 0, 4 and 0. The terrain-norm switch remains separate from the earlier successful terrain-input flag.

## Stage Order and Release

Construct model storage and configuration, apply trajectory controls, then create the live halo. Allocate saved work, main motion fields and spectral storage in the accepted order. Load spectral input and calculate terrain before loading the surface state. Load upper-air input, convert spectral temperature, allocate next-time work, then calculate initial norms. The local upper-air decoder runs once per process in increasing rank order, with collective status agreement after each visit. This bounds its temporary storage while preserving each process's inputs and calculations.

Return zero publishes the complete owner. Returned nonzero status leaves the output slot zero and releases acquired owners. The processes agree local admission and allocation errors before the next stage. Terrain or temperature-conversion failure calls the public MPI abort service because another process may already be inside that child's collective transform. The parent has a 256-byte, 16-byte-aligned stack frame, preserves x18 and saved Arm registers, and requires FPCR zero. Natural numerical flags and the library error indicator remain observable.

`md2asm_release_initialized_operational_model` receives the address of the output slot. It releases norms, terrain and halo before model storage, frees the 64-byte owner and clears the slot. Its frame is 96 bytes. The caller releases Geometry and startup afterwards. An empty owned slot succeeds.

## Accepted Check and Limits

The four-process joined check passes 22,463,904 newly compared norm and persistent-state bytes with zero differences after temperature conversion. It passes 681 independent numerical relations, forty ABI observations, one-process admission and allocation failures, guards and complete release of 1,166,026 tracked allocations. FPCR, numerical flags and the library error indicator match naturally. Accepted large child input banks were reused without replay. Source norm results at this new input boundary were saved once.

The joined component process ended successfully within its explicit 1,200-second bound. Its conservative named-buffer envelope was 410.22 GB, with one active upper-air decoder. Each process had a 224 GiB address-space limit and the combined resident-memory cutoff was 420 GiB. These bounds cover this initialization join and exclude later persistent grid work and physics storage. They are not a forecast runtime or a complete-forecast memory admission. The supplied climate-input temperature limit in [README](../../../../../README.md#notes) remains unchanged.
