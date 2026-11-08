# Poster Figure Data

The active performance figures draw the generated Fortran implementation labelled esm.md. Each point is the median complete-cell-update rate from twelve accepted runs. A complete update advances both time stages and every model field. The whiskers show the observed minimum and maximum rate, which describe the runs rather than a confidence interval. Horizontal axes use a logarithmic scale, so each major tick is a tenfold change in rate.

The CPU category uses one Neoverse V2 core, while the GPU category uses one NVIDIA GH200. CPU wall-clock timing and GPU event timing cover their declared complete update sequences, with setup, compilation, transfers, output and verification outside the measured intervals. These rates describe the stated hardware and workloads.

The results-current.json snapshot retains the per-repeat observations, source-record hashes, hardware identities and accepted output-agreement status. Reference observations remain for checking the original paired timing record. The active plotting script selects only the generated Fortran rates. Running plot_performance.py needs this local snapshot and the poster font/style assets. Running prepare_results.py imports fresh accepted raw timing records and requires the local project research archive, whose detailed process and resource records remain outside publication.

The historical subfolder holds the earlier language-control cohort. Its six-control figures keep the original tuned and unchanged Fortran, Julia and compiled-Python rates separate from the new measurements. The historical raw source record is preserved for provenance. The physical-model binary inputs and outputs in this data folder belong to the accepted scientific illustrations, whose colour scales and values are unchanged.
