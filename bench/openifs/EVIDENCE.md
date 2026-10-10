# OpenIFS Evidence

This record preserves the accepted 52-body checkpoint and its measured limits. A routine body is one original subroutine or function. The forecast still uses Fortran for other routines. Band21 work after this checkpoint is recorded separately until its complete forecast comparison passes.

## Source

The frozen OpenIFS 48.1.1 source includes scientific code, headers, build descriptions and bundled components. Its manifest identifies 4,071 files under `../ecmwf-openifs/ifs-source`. A SHA256 hash identifies exact file bytes. Agreement checks below compare the bytes themselves.

| Source record | SHA256 |
| --- | --- |
| Complete source manifest | `bb3f7faa9c5da617b28d2f6608e1ebeb805388f03413c57ec7dd827adbc8ecfd` |
| Original routine inventory | `5f70a9e3c67c452d8fec36859af9b079448e2f83b1ccc344a9192a96234b3711` |

The inventory contains 5,238 original routine bodies, including 341 internal routines and 413 disabled-feature stubs. There are 4,825 non-stub bodies. The audited main forecast phase has 711 bodies, with 51 matched accepted replacements and 660 remaining bodies. The public count is 52 because VERDER was accepted on small cases outside this phase. The 306 remaining local-calculation bodies and 207 weather or forcing bodies are overlapping subsets, not additional totals. These counts do not prove all branches, external numerical dependencies or an exact denominator for a fully rewritten model.

## Build

The strict reference was built with GNU 12.3 through Cray wrappers for Neoverse V2 on job 7122219 at nid010373. It exited successfully. All 3,675 Fortran compilation commands were checked. The primary flags were `-O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math`. Separate multiply and add operations retain their specified rounding.

| Build artifact | SHA256 |
| --- | --- |
| Complete configuration | `dfce70f1a69f974299a0f04825fec94f16cf6c543973e780bc24581385942fe9` |
| ifsMASTER.DP executable | `ab1c8a3b0e7e00ab28c1cae005613e4b7d2e5eba0c9af50aa658c7c574adf91e` |
| libarpifs.DP.so | `8e4966877c735976f1e9356bc551294bbfc15c565ecdf1dc7db4cf814012b07b` |
| libsurf.DP.so | `64ca400710af685a009a4806b259ff9df6b59ba9444dbc63359785588b2d12e1` |
| libwam.DP.so | `1d2055058ccbd807db8b1b367d4a41677e02c9e23aeae50101071ffdf2ffbfe7` |
| libtrans_dp.so | `f56e9886a2f6116c4b6d4fdd75bd2b262f8a744fe20dda89af328b4fb3f8f0ef` |
| libalgor.DP.so | `0f75c1b2343da37ce8da1ada06124a340b603344706a9b54c5f93e7ae9b2c7ed` |
| libifsaux.DP.so | `e6263081b9fd130fe450848e7f35b138a7793a7a4631038f325d15a4ce614f05` |
| libfiat.so | `0290e259b31395dd1429a348044d21be9580a14e327785aec6d623a7a226b57b` |

The seven scientific libraries passed the recorded instruction audit, with zero forbidden fused operations or approximate reciprocal and square-root instructions. External numerical libraries were not fully audited, so this is not acceptance of the complete external reference. The vertical reference uses an ordered private matrix sum with separate products and additions. It changes that declared baseline arithmetic and does not replace BLAS globally.

```bash
cmake --build .runtime/openifs/strict-build --target ifsMASTER.DP --parallel 48
```

The complete configure command and custom flag file remain in the retained build record indexed below.

## Pressure Math

Both forecast paths use the same pressure exponential and logarithm library. Its Arm optimized-routines v26.01 source commit is `649ccc8411e7c4862965710f25c570d854a1483f`. A unit in the last place, or ULP, is the spacing between adjacent floating-point values. Independent Decimal calculations used 110 and 220 significant digits. The measured errors satisfy the one-ULP limit on this corpus, without proving a global error bound.

| Function | Cases | Largest observed error in ULP |
| --- | ---: | ---: |
| exp | 10428 | 0.5021398984635665 |
| log | 10421 | 0.5011559174093192 |

The audit covers 407 instructions, finds zero forbidden instructions and verifies a floating-point control register value of zero. This sets the recorded rounding and gradual-underflow mode. The whole external mathematics library remains unaccepted.

| Artifact or upstream source | SHA256 |
| --- | --- |
| Pressure mathematics library | `ec54bd97ec32ef0c68fa5c79102eda6781e74d2469a23c448c89f9db3ad31ed1` |
| Independent verifier | `be5994ccb0e29a52e10f626420d3de3476f93c6669288cc7098171101cdff197` |
| Instruction audit | `9f63f26ebd15eae6542212c4e9f2a9b50df02668349ba40bbb88351c128aa219` |
| Floating-point control helper | `8f3c3c95b5dfbb970006191fdd45c6f977d00f85307fa9e91d76af984ab2dc3f` |
| Floating-point control helper source | `2d884a9e649d0ed03248b50daa0df028c6c35c8926a2004a6e649f0fe8696ffc` |
| math/exp.c | `219b5f666c84864e80ef5ef33bc5453b4702ea74fc5cbf997c3dfacdcf5738cf` |
| math/exp_data.c | `a5e84677e7693c7d22195f86faac5fdc6f92bff7ea2e54c0e7888203a78ffc24` |
| math/log.c | `10e3774a72279c75d3842bc651a9d81e8fe31f9717caac736a603170ed509530` |
| math/log_data.c | `327cf1819870930486eecb5491c68d5887a712b954e5ec82f3f70bfd9e46fdd3` |
| math/math_err.c | `202a5f0b4983da16567bf707b8da02f9c1aa84bfaf1e9e2931009153b4a86676` |
| math/math_config.h | `9a3ee029ba2b58444fafb51427bf0dc390d117f26115cd5a7033a5cc03042881` |
| math/include/test_defs.h | `006c4acb9cb4dd604cd00c6a94004a52552d056a4bfca7f568566cbb9e83ad4d` |
| math/include/test_sig.h | `48813d3c0d556a0c7993bd0682413eb4acb086ed6518b8a45e5450b03dfe62ca` |
| LICENSE | `650afbf29f214451e02241adc42534e82c9d6ae2b38e2444b92b5a1ffcaf9346` |

```bash
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DHAVE_FAST_FMA=0 -DHAVE_FAST_ROUND=0 -DWANT_ERRNO=1 -I .runtime/openifs/arm-math-source/math -I .runtime/openifs/arm-math-source/math/include .runtime/openifs/arm-math-source/math/exp.c .runtime/openifs/arm-math-source/math/exp_data.c .runtime/openifs/arm-math-source/math/log.c .runtime/openifs/arm-math-source/math/log_data.c .runtime/openifs/arm-math-source/math/math_err.c -Wl,-z,defs -Wl,-Bsymbolic-functions -lm -o .runtime/openifs/strict-math/libpressure-math.so
```

## Forecast

The accepted coarse forecast uses 2,048 grid points, 19 atmospheric levels, four soil levels and five snow levels. It starts at 12 UTC on 15 October 2004 and ends at 12 UTC on 16 October 2004. There are 25 physical advances and 26 iteration labels. Job 7207705 on nid011311 used one process, one thread, CPU 4 and local memory placement. The observed verification loads were `[1.01123046875, 1.0556640625, 0.7509765625]`. This was verification, not comparative timing.

All 50 paired routine streams contain 7,595,504,008 compared output bytes with zero differences. Every paired call starts from the same complete incoming storage, including unused bits. All ten saved forecast files contain 618,140 bytes and match directly with zero differences. No output bits were rounded, masked or normalised.

| Saved file | Bytes | SHA256 |
| --- | ---: | --- |
| `ICMSHepc8+000000` | 39040 | `738cad2b219446b25351b4e8729c02d64292421e4ec22ebd4483946081230b67` |
| `ICMSHepc8+000006` | 39040 | `8535631113507addf65eea73d701c22c39b366813fc453c93d0ce4d62760ee82` |
| `ICMSHepc8+000012` | 39040 | `124579ca1e33d9df6a42b162a49b7a87ed645c8488d7d09e9206aa8a37a30e88` |
| `ICMSHepc8+000018` | 39040 | `3e6846a39db2b36213794740a198c41de31d8d3ce06db30845d3070ebb753710` |
| `ICMSHepc8+000024` | 39040 | `b66c56f7031687479bfc9215be956cbe5c3886250a792896be12d8577f76aa2c` |
| `ICMUAepc8+000000` | 84588 | `7521976080d1c0aa1607b86637063a63fcae4850c23188e49624f86c55e80dd3` |
| `ICMUAepc8+000006` | 84588 | `7c3757a42d8c35225f56b582edcb838e966a96afdc2ea013a62149b00c5b49b6` |
| `ICMUAepc8+000012` | 84588 | `563545a34ebb6dd892f2ec882941db5d1f6eab976230a916d05ef4929b8064e4` |
| `ICMUAepc8+000018` | 84588 | `851a0f949127a2595a80c1d2e96f54885f38e3ce3c3346d25dbff14df982341e` |
| `ICMUAepc8+000024` | 84588 | `969189c3efec23d3699f5011b1117e130bd8292f530ed492c546856345d69238` |

VERDER has no genuine forecast visit. GPRCP includes 11,696 genuine model calls and 2,150 explicitly marked CTVTOT reference calls. VERDISINT covers 21,559 genuine private-integral calls. The forecast exercises filter copy or skip paths, while their weighted paths were checked on small cases. LAITRI supports flags 0 to 3 and excludes its minus-one conservation branch. LASCAW_CLO supports 14 configurations and excludes 1 and 9. LASCAW_VINTW supports 56 configurations and excludes 2, 3, 18, 19, 34, 35, 50 and 51.

The independent actual vertical geometry checks use limits of 1e-11 for a constant field and 1e-6 for a quartic field. The complete matrix and reciprocal bits are checked. Other intermediate forecast stages are not all captured. Independent physics for the whole model and whole-forecast comparative timing remain unfinished.

| Accepted local review | Bytes | SHA256 |
| --- | ---: | --- |
| `.runtime/openifs/runs/strict-shortwave17-combined-reviewed-7207705/t21/direct-comparison.json` | 83064 | `deebdc301ec10de1a66405771db794f7a03f7669a7af274994fbe0275c6b066e` |
| `.runtime/openifs/srtm_taumol17_7207705/parent-review/root-parent52-complete-actual-runtime-independent-peer-qualified-acceptance-r1.json` | 3709 | `e79497e3e1fbff78d2cd99606b0c32c222e288a4ec717ccc0038f2e8ef33f4ca` |
| `.runtime/openifs/verdisint/forecast-reviewed-7189435/results.json` | — | `e68d90c10e874ff0b63bb67417624cde24f0b32185ab2981a042f2e56ffbe4ce` |

## State Capture

An earlier 51-body checkpoint, commit `212dbb626ee2b52031cfa79449fc8fe07edfa43d`, captured 29 selected execution boundaries and 755 items per boundary. Each complete archive contains 598,372,890 bytes. Its full comparison covers 43,848 regions and finds 239,956 differing bytes across 35,427 changed floating-point cell records. Complete captured-state identity therefore fails at that checkpoint.

Each of the initial ENTRY and READY0 boundaries has 119,519 differing bytes in 17,592 cells. The source allocates this storage before assigning some values. Each of the later 27 boundaries has 34 differing bytes in nine padding cells beyond the eight active rows in the last block. Padding means allocated space outside the active grid. Later active-grid bytes match, and all ten saved files match. Every padding and initial bit remains in the failed complete comparison. Restart and printing code can read complete allocations, so this result does not prove these bytes are never read.

| Captured archive | Bytes | SHA256 |
| --- | ---: | --- |
| `.runtime/openifs/runs/strict-prognostic-radiation-original-r1-7207705/t21/whole-prognostic-raw.bin` | 598372890 | `f42bcac025b7143b86b4abc79ebf075d8ec44b93d25dbbc9084a4d05f56142a6` |
| `.runtime/openifs/runs/strict-prognostic-radiation-native51-r1-7207705/t21/whole-prognostic-raw.bin` | 598372890 | `4c7e68db85fd8f7778cabdcc36326c6670d41587ae476e111c24ed8b548897e7` |
| `.runtime/openifs/prognostic-state-capture-7207705/persistent-radiation-implementation-r1/parent-review/root-independent-complete598MB-pair-parse43848-regions35427-changed-cells-and-allten-saved-files-review.json` | 10290 | `96d7b2280ff4e487839fcaad3c26f2280aa60350f63c341db72fa5f6f0eef59d` |

Saved-file agreement, later active-grid agreement and selected source tracing do not establish complete process-state identity or independent physics for the whole forecast.

## Local Reproduction

The original 335 published files are retained locally under `.runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826` and excluded from Git. This includes comparison implementations, drivers, capture helpers, numerical checks and exact command records. The direct numerical solver remains assembly. No driver supplies an omitted numerical stage.

Use a quiet compute node in an exclusive allocation. Preserve the recorded affinity, local memory placement, one-process and one-thread settings, input bytes, strict libraries and arithmetic. Create a fresh case and review the current allocation and artifact bindings before any new run. The following historical commands identify the accepted execution and are not permission to repeat it with an expired allocation.

`.runtime/openifs/srtm_taumol17_7207705/parent52-single-forecast-proposal-r2/exact-single-parent52-forecast-command.sh` has 392 bytes and SHA256 `0dc4a597e61570812a63097ccb40ff5e1a89d2fe881702612adf5cb9e4aa3420`.

```bash
srun --jobid=7207705 --overlap --exact -N1 -n1 -c5 --cpu-bind=map_cpu:4 --mem-bind=local --mpi=cray_shasta bash -lc 'set -euo pipefail
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
ulimit -c 0
cd /lus/lfs1aip2/projects/u6yq/users/p3jitnath/esm.md
.runtime/python/bin/python .runtime/openifs/srtm_taumol17_7207705/parent52-single-forecast-proposal-r2/launch-one-parent52-forecast.py'
```

`.runtime/openifs/srtm_taumol17_7207705/parent52-single-forecast-proposal-r2/exact-single-parent52-checker-command.sh` has 373 bytes and SHA256 `647491771af44fce0e24127149c575b118598d77cbc3e32fce4847be3fc0fb6b`.

```bash
srun --jobid=7207705 --overlap --exact -N1 -n1 -c5 --cpu-bind=map_cpu:4 --mem-bind=local bash -lc 'set -euo pipefail
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
ulimit -c 0
cd /lus/lfs1aip2/projects/u6yq/users/p3jitnath/esm.md
.runtime/python/bin/python .runtime/openifs/srtm_taumol17_7207705/parent52-single-forecast-proposal-r2/check-one-parent52-forecast.py'
```

The canonical baseline is `.runtime/openifs/runs/strict-vertical-fortran-7189435/t21/test_fc`. The accepted mixed forecast archive is `.runtime/openifs/runs/strict-shortwave17-combined-reviewed-7207705/t21/test_fc`. Full generation provenance, build recipes, failures and routine-specific reproduction commands remain in the locally retained records below. The Markdown solver contracts retain their equations, ordered arithmetic, application binary interface, storage bounds and supported cases.

## Routine Records

The [verification table](README.md) gives each routine’s critical cases, captured calls and compared bytes. The records below retain input, source and implementation hashes, machine-instruction and register checks, scientific limits and actual commands. The application binary interface, or ABI, defines argument, register and memory rules. Grouped routines explain why the accepted 52 bodies have 50 forecast streams.

Each record below is a complete retained JSON file, not a new published data file. Paths are relative to `.runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs`. Its hash preserves all original claims and detailed artifact bindings without copying the raw record into this document.

| Local record | Bytes | SHA256 |
| --- | ---: | --- |
| `build.json` | 5168 | `d4867f5166847d0f0e13bd5069ea2f225b6eb69f603ea2e0ad23aca0b3d7c78f` |
| `dynamics/cpqtuv.json` | 9145 | `1c761a8636d99ca55b067175576f5bad1eec782c1d54aadd1a97cfd620f8c6a5` |
| `dynamics/ctvtot.json` | 5556 | `60718f3e37c48098256b718d836ca51d6164a74a32effeaaf19b24ad985261be` |
| `dynamics/gp_spv.json` | 4034 | `4bfcdb5d740c50d96b03b8b99b1f82ac3cd54f6b3326cae0e9a0855c3f996f39` |
| `dynamics/gpgeo.json` | 4532 | `0bac6b8112d542a4e317facdb0c4899beae6ef898ce5f2b1b751c0b3cea6c2f6` |
| `dynamics/gpgrgeo.json` | 6450 | `c49bc21faf13e5fb1d8b01f1ed92914c8e4216c4e79e9e7c6401d132ee2795b2` |
| `dynamics/gpgrp.json` | 3797 | `bce524c558c735afb7e8087b5f242291bf16adb9cc25c3973e6b693409bb87c4` |
| `dynamics/gpgrxyb.json` | 5026 | `12411832456a61851d27b8bf0c2a2b82f669416e9009cf5f583e6fffe34eda39` |
| `dynamics/gphpre.json` | 5638 | `30ad229b3c63f5e9a155a2231ef045878d050336f7bb71c3093f2e7e8eb97860` |
| `dynamics/gpmktend.json` | 3926 | `8cd81ed340776f0f933bf31965c985986e92984bb923d36f1cd5890ef84422d3` |
| `dynamics/gppwc.json` | 2729 | `b7e1d998e3db87ab248b5fff8f8a071b439e369ec2c4dbd7fb49b14029135e3d` |
| `dynamics/gprcp.json` | 4271 | `333a715a1265241dcc17acbda0a6bdd95cf25a118efc82f4225088142e6352e8` |
| `dynamics/gprt.json` | 3350 | `af1c70ac994dc446febc6005964e4d520cae7591b041f05a9fe1657271208aab` |
| `dynamics/laiddi.json` | 11678 | `b5a300502a760289c1815a40078869d250c02786631fb215799daea88490ceb6` |
| `dynamics/laitli.json` | 11067 | `55f9d2359c66a9f110c37ae8521598c80e4eed7f623b269f08881ada5d07ba15` |
| `dynamics/laitri.json` | 13484 | `85e098ae19e59e6b88c65eb9aca86c71db92168713dcd777c15ebcc42c4e8d0b` |
| `dynamics/laminmaxint.json` | 7204 | `f102b09e1ec36c32f2a67ff134548f193990442a2c202fb7c7d4fce5c2a6e4dc` |
| `dynamics/lascaw_cla.json` | 8461 | `2c405418e0359a625cfffed52ee1db4cbf5af8f37d92b2fd699cbf7d2cef3995` |
| `dynamics/lascaw_clo.json` | 9957 | `01d6069335e9cc017e37a338e6a3045f41f45c3eed1c26c17eb977497bcbfb88` |
| `dynamics/lascaw_vintw.json` | 11696 | `3f37b8c18876187d5c5ba9af551cb4b2c0a663fbdab2dff341653bbf23ccce77` |
| `dynamics/sigam.json` | 8086 | `d1839c244feb9a5daf01309c80416c0f24403a2fda5286ff1fc728a180dae242` |
| `dynamics/simplico.json` | 7380 | `440929b448eba18b060cf9fc7b98c70eb0a30689b7da6bed564cbfaac8170bf2` |
| `dynamics/sitnu.json` | 5739 | `8cdbe55229e367811f895ca8a8567c97ab663dd2758786b22b4d3fc38d4a5c7f` |
| `dynamics/spcimpfinit.json` | 9310 | `ed5ac908c396c14c40a6fbef7cff1fcf42e0075c0e07881393f860127a46e301` |
| `dynamics/spcimpfpost.json` | 7953 | `8e51c54b04a62266745631f9692e1b0783259bc500eb53896d025aace66ddfa8` |
| `dynamics/spcimpfsolve.json` | 9485 | `81d5c82a8b1d2b305bc70ca6fe24c9b07f6794d36c87c49a46cdb813529a672c` |
| `dynamics/spfilt.json` | 22817 | `51185fd14eab1192ec9337b3cc9d6562a015b3a6c2e8091019a34fb57c4a94a0` |
| `dynamics/time_filter.json` | 5062 | `1e349ad4952c2e6e04e8b9c968e03311748c15cb08fb5458940848f11aa544e1` |
| `dynamics/verdisint.json` | 16776 | `bdde3eecd07a51d215a1d9f400d9b319097aaecaaa6e7706b04f18d2c138f4db` |
| `dynamics/wind_tendency.json` | 4585 | `6a799583ad2776402310c643d2056b91d4ae8c2e460b5b07821b57d1076a7011` |
| `forecast.json` | 57176 | `7ccf28cc6b5fa45f83872ff9a49e27c0230070850e2e7a7cd832ec8833e40477` |
| `physics/calc_ice_optics_fu_lw.json` | 6443 | `5d38d19074318001216b9c0675b03fb8e4da29d7064679a9db47dabc5f7d2c9a` |
| `physics/calc_ice_optics_fu_sw.json` | 5658 | `4f9d898d674d1959bc651763ab62efbd6d3bbdb318cfa5a95d2860a3d7fdc73c` |
| `physics/calc_liq_optics_socrates.json` | 11223 | `2c3d4c2261192f0443183953088b96a1d13c9a9f3966e30c4233e287e164c3ee` |
| `physics/cubidiag.json` | 18431 | `087479a7bfa0c87087d6236ba0fc52a4ce828d3d4364beb0733e7c07daa046b5` |
| `physics/delta_eddington_scat_od.json` | 9294 | `8e7690cbeaeb40486ddc8dea1c09d4d374f16ffc3936853dce85ee36488d649b` |
| `physics/gpaddslphy.json` | 4195 | `593735d0d4ecb900afcef5cd55d1915d6ce30ac9bde968806509cd8abb3803ab` |
| `physics/gptco3.json` | 4385 | `1189337f5666a230af93659fab6a5c26dfa6c0dee58f255be90a98dd48d23a7e` |
| `physics/rrtm_prepare_gases.json` | 23529 | `3eea6c947062b9bd99862732e8d69ac35128bfbe26d8697bf29025a043e816d9` |
| `physics/srtm_taumol16.json` | 8834 | `237cf0a90f740c67587769ed5bb37e0d97ad4d6fa8418b3a296f75dfef854c6f` |
| `physics/srtm_taumol17.json` | 5783 | `a074e2bdf5874f0b94ade88b8fbe8ad2b9ba824132071c41755bd24d0721e898` |
| `physics/srtm_taumol18.json` | 10381 | `51a47a44edecad75679bebdd1ed0a233a4babcbdf009bfa6c0fc5e2260791a6c` |
| `physics/srtm_taumol19.json` | 10207 | `77bf7cb3d03f9cf1419d8bafcb801429dd38e66c09824aa5fb1c592ecf18c263` |
| `physics/srtm_taumol20.json` | 5906 | `d9709421a77310b2d715f9be0148767bc9c0d085a8e506ac76117404f0926ae3` |
| `physics/srtm_taumol23.json` | 7782 | `91cfeac5e8ca98ef5abf0e6174d02b1584b64c0f8e4899071db254abe7444a26` |
| `physics/srtm_taumol25.json` | 9051 | `ab83623c93e4495c850c447576fe7f48b7bf807f1b30a0832b71b4a509c4523d` |
| `physics/srtm_taumol26.json` | 23268 | `523c956dff92290c3ce5f5684a531ba2ad622a2b204f3fd8e64673cd1d1613aa` |
| `physics/srtm_taumol27.json` | 9682 | `9bdee7149caa561234b216a1bd27c50d1ad1e9fad3d4b737db724ba0f288ebf6` |
| `physics/srtm_taumol28.json` | 6560 | `ed73dca4e2b9d27e5c6a6a49ce1b4e55997948c6e276c844ffa917d64f2319b9` |
| `physics/srtm_taumol29.json` | 6164 | `da0b4fb132d9a74685bf28d622ed6bc5860309bb2e94409856258624dc5301b4` |
| `pressure_math.json` | 3478 | `3510fed62b6ee854032ba8790989ec5246964f4f401440feb6d12d311f3920a9` |
| `routines.json` | 26954 | `66331ec53562d998bc7b8cd37512456ec0edba4d47eb0d955207dc80ede8c752` |
| `source.json` | 673 | `290729a73b455a9bfd0719735c075d53aad861748ae572e8070d51dd5f1eb7b0` |
| `state_capture.json` | 5851 | `cc9f699de249b496e9374263f1108514cdbc5ecf3a2ddae828e55bbb932288a8` |
| `surface/cpspe.json` | 3141 | `4853d700165f01151e9208fabdb11dee03ae388a44ff8b8a41cd4b1f6cf01445` |

## Timing

Only the routine measurements below support speed claims here. Each workload has 12 accepted repetitions. Complete timed outputs and inputs were checked outside the timer. The table gives median time and observed minimum to maximum in nanoseconds. SD is standard deviation, a measure of repeat variation. MAD is median absolute deviation. Speedup is control time divided by selected assembly time.

| Routine and workload | Control median [min, max] ns | Assembly median [min, max] ns | Variation control / assembly ns | Speedup |
| --- | ---: | ---: | ---: | ---: |
| Gas preparation 0 | 3325.625 [3321.125, 3366.750] | 2071.562 [2069.250, 2089.500] | SD 13.319 / 5.151 | 1.606 |
| Gas preparation 1 | 3341.938 [3224.750, 3371.375] | 2071.000 [2067.625, 2088.750] | SD 38.484 / 6.472 | 1.614 |
| Gas preparation 2 | 3335.062 [3206.375, 3354.250] | 2068.688 [2065.250, 2074.375] | SD 50.744 / 2.855 | 1.610 |
| Gas preparation 3 | 3317.500 [3299.750, 3336.000] | 2068.875 [2064.625, 2142.375] | SD 8.803 / 21.082 | 1.603 |
| Band26 record 0 | 817.905 [813.197, 832.667] | 170.497 [152.147, 174.578] | SD 7.585 / 8.625 | 4.797 |
| Band26 record 256 | 818.427 [813.476, 833.993] | 169.868 [155.690, 173.822] | SD 7.193 / 7.831 | 4.818 |
| Band26 record 3072 | 818.082 [814.216, 831.876] | 170.389 [155.878, 174.033] | SD 4.597 / 7.522 | 4.801 |
| Band26 record 6144 | 817.951 [813.570, 833.753] | 170.851 [152.121, 174.017] | SD 6.408 / 7.687 | 4.788 |
| matrix single point | 168.596 [163.865, 181.692] | 184.877 [163.772, 186.572] | MAD 4.611 / 1.619 | 0.912 |
| matrix boundary block | 1201.910 [1196.287, 1220.610] | 412.846 [410.676, 422.520] | MAD 2.729 / 0.926 | 2.911 |
| matrix forecast block | 3684.891 [3667.978, 3699.271] | 1212.169 [1211.109, 1227.610] | MAD 11.285 / 0.825 | 3.040 |
| matrix larger block | 76374.261 [75894.261, 76836.174] | 26709.565 [26537.739, 27353.043] | MAD 86.957 / 109.217 | 2.859 |
| integral single point | 170.849 [168.752, 185.177] | 171.598 [170.276, 193.521] | MAD 0.986 / 1.292 | 0.996 |
| integral boundary block | 1306.912 [1298.683, 1335.517] | 418.489 [417.934, 421.801] | MAD 5.196 / 0.181 | 3.123 |
| integral forecast block | 3683.004 [3666.082, 3692.253] | 1218.468 [1213.026, 1228.312] | MAD 4.729 / 0.833 | 3.023 |
| integral larger block | 77376.000 [77128.960, 89600.000] | 25890.560 [25872.640, 25967.360] | MAD 79.360 / 15.360 | 2.989 |

Gas preparation compares selected paired-column assembly with the strict Fortran source on job 7207705, nid011311, CPU 8 and local memory. Each rotation makes 256 complete calls per variant after warm-up. There are 144 accepted whole-call rows and 15 rejected rows. The complete-call gain is 1.60 to 1.61. The matched division and copy reference fraction is about 0.681. These costs overlap and are not a proved hardware or DRAM bound.

Band26 compares an eight-cell assembly schedule with the strong Fortran O3 control on job 7207705, nid011311 and CPU 8. Each of 12 rotations makes 200,000 complete calls per sample on the same buffers. The four gains are 4.79 to 4.82. The empirical memory-instruction rate fractions are about 0.939 to 0.996. This is a matched instruction reference, not a measured DRAM limit or proof of global optimality.

The matrix and vertical-integral rows compare an eight-point schedule with the earlier scalar assembly helper, not Fortran. Job 7189435 on nid010825 used CPU 8, local first-touch memory, warm-up and 12 repetitions. Forecast-block gains are 3.040 for the matrix and 3.023 for the integral. The matched hot-cache non-fused reference is 25.3077044813 GFLOP/s. The forecast matrix reaches 16.63133842189703 GFLOP/s, or 0.6571650318647398 of that reference. A GFLOP/s is one billion floating-point operations per second. The single-point rows show their full observed results. These routine gains do not establish a whole-forecast speedup.

Unrounded repeat values, rejected measurements and complete timing protocols remain in the indexed gas, Band26 and VERDISINT records. Diagnostic forecast profiles guide the weather work order, but are separate from these accepted matched measurements.
