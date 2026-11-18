# Instructions for the PASC27 study branch

Publication code and data cover the shallow-water and energy-balance study. Keep the model formulations and numerical specifications together under formulations/sw/ and formulations/ebm/. Keep shared specifications in formulations/general/ and active solvers in src/. Follow the [writing convention](standards/ASD-STE100-CONV.md) and record comparable inputs, arithmetic order, units and verification limits.

The [source manifest](reproduction/source_manifest.json) identifies the frozen snapshots used for the measured comparisons. Record subsequent code changes separately so they can be distinguished from the measured revisions. Build and diagnostic output belong in .scratch/. Verify the stated physics and complete outputs before taking comparative timings on a quiet, exclusive allocation.
