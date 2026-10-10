# Weather Work Queue

This ordered queue contains exactly 206 unique original routine bodies with local weather or forcing calculations in the audited T21 main forecast phase, a coarse global forecast configuration. It is the queue at the accepted 53-body checkpoint. The 659 remaining main-phase bodies and 305 remaining local-calculation bodies are overlapping larger sets. These counts do not establish every branch, external dependency or an exact denominator for a complete assembly forecast.

Band 21 has passed its complete assembly and forecast checks. Next close adding_ica_sw, whose complete original calls are captured. Its separate full physics check reached the 15-minute execution limit and is not accepted. Continue through high-impact radiation transport and cloud sampling, radiation coefficients, atmospheric physics, dynamics, surface support and spectral transforms. Develop calculation children before callers when they share numerical dependencies. The deferred wind routine retains its original accuracy blocker.

Historical diagnostic profiles and source call dependencies guide this order. They are not accepted comparative forecast timings. MCICA, the radiation calculation through randomly sampled cloud columns, has self-time that includes two-stream child work whose hook is disabled, so it does not measure the parent body alone. Full byte agreement and independent physics remain required at each completed forecast batch.

| Theme | Bodies |
| --- | ---: |
| Radiation | 35 |
| Weather support | 88 |
| Atmospheric physics | 50 |
| Dynamics | 20 |
| Spectral transforms | 13 |

The current private source queue is `.agents/weather-routine-queue-7207705.tsv`, with 206 entries, 30,273 bytes and SHA256 `46c6aabf67a4ae16e35fa21a0edbd4e146199a76e9880de31b8bc634ac3600d4`. The historical 207-entry queue is retained at `.agents/weather-routine-queue-7207705-at52.tsv`. Removing only `srtm_taumol21` preserves every other identifier and its relative order. Each source path below is relative to the real upstream root `/lus/lfs1aip2/projects/u6yq/users/p3jitnath/ecmwf-openifs/ifs-source/`. Prefix that root to obtain the complete original filename. All 206 rows preserve the other exact routine identifiers, themes, original source paths and relative order.

| Order | Theme | Routine | Original source | Status |
| ---: | --- | --- | --- | --- |
| 1 | Weather support | `radiation_adding_ica_sw::adding_ica_sw` | `radiation/module/radiation_adding_ica_sw.F90` | original capture accepted, assembly pending |
| 2 | Weather support | `random_numbers_mix::uniform_distribution` | `algor/module/random_numbers_mix.F90` | remaining |
| 3 | Weather support | `random_numbers_mix::initialize_random_numbers` | `algor/module/random_numbers_mix.F90` | remaining |
| 4 | Weather support | `radiation_cloud_cover::cum_cloud_cover_exp_ran` | `radiation/module/radiation_cloud_cover.F90` | remaining |
| 5 | Weather support | `radiation_pdf_sampler::sample_from_pdf` | `radiation/module/radiation_pdf_sampler.F90` | remaining |
| 6 | Weather support | `radiation_cloud_generator::generate_column_exp_ran` | `radiation/module/radiation_cloud_generator.F90` | remaining |
| 7 | Weather support | `radiation_cloud_generator::cloud_generator` | `radiation/module/radiation_cloud_generator.F90` | remaining |
| 8 | Weather support | `radiation_two_stream::calc_reflectance_transmittance_sw` | `radiation/module/radiation_two_stream.F90` | remaining |
| 9 | Weather support | `radiation_two_stream::calc_two_stream_gammas_sw` | `radiation/module/radiation_two_stream.F90` | remaining |
| 10 | Weather support | `radiation_mcica_sw::solver_mcica_sw` | `radiation/module/radiation_mcica_sw.F90` | remaining |
| 11 | Weather support | `radiation_adding_ica_lw::fast_adding_ica_lw` | `radiation/module/radiation_adding_ica_lw.F90` | remaining |
| 12 | Weather support | `radiation_adding_ica_lw::calc_fluxes_no_scattering_lw` | `radiation/module/radiation_adding_ica_lw.F90` | remaining |
| 13 | Weather support | `radiation_lw_derivatives::calc_lw_derivatives_ica` | `radiation/module/radiation_lw_derivatives.F90` | remaining |
| 14 | Weather support | `radiation_lw_derivatives::modify_lw_derivatives_ica` | `radiation/module/radiation_lw_derivatives.F90` | remaining |
| 15 | Weather support | `radiation_two_stream::calc_no_scattering_transmittance_lw` | `radiation/module/radiation_two_stream.F90` | remaining |
| 16 | Weather support | `radiation_two_stream::calc_reflectance_transmittance_lw` | `radiation/module/radiation_two_stream.F90` | remaining |
| 17 | Weather support | `radiation_two_stream::calc_two_stream_gammas_lw` | `radiation/module/radiation_two_stream.F90` | remaining |
| 18 | Weather support | `radiation_mcica_lw::solver_mcica_lw` | `radiation/module/radiation_mcica_lw.F90` | remaining |
| 19 | Weather support | `radiation_aerosol_optics::add_aerosol_optics` | `radiation/module/radiation_aerosol_optics.F90` | remaining |
| 20 | Weather support | `radiation_ifs_rrtm::gas_optics` | `radiation/module/radiation_ifs_rrtm.F90` | remaining |
| 21 | Weather support | `radiation_cloud_optics::cloud_optics` | `radiation/module/radiation_cloud_optics.F90` | remaining |
| 22 | Weather support | `radiation_ifs_rrtm::planck_function_atmos` | `radiation/module/radiation_ifs_rrtm.F90` | remaining |
| 23 | Radiation | `radiation_scheme` | `arpifs/phys_radi/radiation_scheme.F90` | remaining |
| 24 | Weather support | `radiation_flux::calc_surface_spectral` | `radiation/module/radiation_flux.F90` | remaining |
| 25 | Weather support | `radiation_cloud::set_overlap_param` | `radiation/module/radiation_cloud.F90` | remaining |
| 26 | Weather support | `radiation_single_level::get_albedos` | `radiation/module/radiation_single_level.F90` | remaining |
| 27 | Weather support | `radiation_ifs_rrtm::planck_function_surf` | `radiation/module/radiation_ifs_rrtm.F90` | remaining |
| 28 | Weather support | `radiation_cloud::crop_cloud_fraction` | `radiation/module/radiation_cloud.F90` | remaining |
| 29 | Weather support | `radiation_thermodynamics::get_layer_mass` | `radiation/module/radiation_thermodynamics.F90` | remaining |
| 30 | Weather support | `radiation_aerosol_optics::delta_eddington_extensive` | `radiation/module/radiation_aerosol_optics.F90` | remaining |
| 31 | Weather support | `radiation_flux::indexed_sum` | `radiation/module/radiation_flux.F90` | remaining |
| 32 | Weather support | `radiation_gas::get_gas` | `radiation/module/radiation_gas.F90` | remaining |
| 33 | Weather support | `radiation_gas::set_units_gas` | `radiation/module/radiation_gas.F90` | remaining |
| 34 | Radiation | `radghg::interp_gas` | `arpifs/phys_radi/radghg.F90` | remaining |
| 35 | Radiation | `radghg` | `arpifs/phys_radi/radghg.F90` | remaining |
| 36 | Radiation | `srtm_taumol24` | `arpifs/phys_radi/srtm_taumol24.F90` | remaining |
| 37 | Radiation | `srtm_taumol22` | `arpifs/phys_radi/srtm_taumol22.F90` | remaining |
| 38 | Radiation | `srtm_gas_optical_depth` | `arpifs/phys_radi/srtm_gas_optical_depth.F90` | remaining |
| 39 | Radiation | `rrtm_taumol3` | `arpifs/phys_radi/rrtm_taumol3.F90` | remaining |
| 40 | Radiation | `rrtm_taumol5` | `arpifs/phys_radi/rrtm_taumol5.F90` | remaining |
| 41 | Radiation | `radintg` | `arpifs/phys_radi/radintg.F90` | remaining |
| 42 | Radiation | `rrtm_taumol9` | `arpifs/phys_radi/rrtm_taumol9.F90` | remaining |
| 43 | Radiation | `rrtm_taumol7` | `arpifs/phys_radi/rrtm_taumol7.F90` | remaining |
| 44 | Radiation | `rrtm_taumol4` | `arpifs/phys_radi/rrtm_taumol4.F90` | remaining |
| 45 | Radiation | `radact` | `arpifs/phys_radi/radact.F90` | remaining |
| 46 | Radiation | `rrtm_taumol13` | `arpifs/phys_radi/rrtm_taumol13.F90` | remaining |
| 47 | Radiation | `rrtm_taumol12` | `arpifs/phys_radi/rrtm_taumol12.F90` | remaining |
| 48 | Radiation | `rrtm_taumol8` | `arpifs/phys_radi/rrtm_taumol8.F90` | remaining |
| 49 | Radiation | `radozc` | `arpifs/phys_radi/radozc.F90` | remaining |
| 50 | Radiation | `rrtm_setcoef_140gp` | `arpifs/phys_radi/rrtm_setcoef_140gp.F90` | remaining |
| 51 | Radiation | `rrtm_taumol1` | `arpifs/phys_radi/rrtm_taumol1.F90` | remaining |
| 52 | Radiation | `rrtm_taumol2` | `arpifs/phys_radi/rrtm_taumol2.F90` | remaining |
| 53 | Radiation | `rrtm_taumol11` | `arpifs/phys_radi/rrtm_taumol11.F90` | remaining |
| 54 | Radiation | `rrtm_taumol6` | `arpifs/phys_radi/rrtm_taumol6.F90` | remaining |
| 55 | Radiation | `rrtm_taumol16` | `arpifs/phys_radi/rrtm_taumol16.F90` | remaining |
| 56 | Radiation | `rrtm_taumol15` | `arpifs/phys_radi/rrtm_taumol15.F90` | remaining |
| 57 | Radiation | `srtm_setcoef` | `arpifs/phys_radi/srtm_setcoef.F90` | remaining |
| 58 | Radiation | `rrtm_taumol10` | `arpifs/phys_radi/rrtm_taumol10.F90` | remaining |
| 59 | Radiation | `radheatn` | `arpifs/phys_radi/radheatn.F90` | remaining |
| 60 | Radiation | `rrtm_taumol14` | `arpifs/phys_radi/rrtm_taumol14.F90` | remaining |
| 61 | Radiation | `radcfg` | `arpifs/phys_radi/radcfg.F90` | remaining |
| 62 | Radiation | `radpar` | `arpifs/phys_radi/radpar.F90` | remaining |
| 63 | Atmospheric physics | `cloud_supersatcheck` | `arpifs/phys_ec/cloud_supersatcheck.F90` | remaining |
| 64 | Atmospheric physics | `cloudsc` | `arpifs/phys_ec/cloudsc.F90` | remaining |
| 65 | Atmospheric physics | `cloud_satadj::qsatmixadj` | `arpifs/phys_ec/cloud_satadj.F90` | remaining |
| 66 | Atmospheric physics | `cloud_satadj` | `arpifs/phys_ec/cloud_satadj.F90` | remaining |
| 67 | Atmospheric physics | `cuinin` | `arpifs/phys_ec/cuinin.F90` | remaining |
| 68 | Atmospheric physics | `cubasen` | `arpifs/phys_ec/cubasen.F90` | remaining |
| 69 | Atmospheric physics | `satur` | `arpifs/phys_ec/satur.F90` | remaining |
| 70 | Atmospheric physics | `callpar` | `arpifs/phys_ec/callpar.F90` | remaining |
| 71 | Atmospheric physics | `cuascn` | `arpifs/phys_ec/cuascn.F90` | remaining |
| 72 | Atmospheric physics | `cuflxn` | `arpifs/phys_ec/cuflxn.F90` | remaining |
| 73 | Atmospheric physics | `cudtdqn` | `arpifs/phys_ec/cudtdqn.F90` | remaining |
| 74 | Atmospheric physics | `cududv` | `arpifs/phys_ec/cududv.F90` | remaining |
| 75 | Atmospheric physics | `cuddrafn` | `arpifs/phys_ec/cuddrafn.F90` | remaining |
| 76 | Atmospheric physics | `cudlfsn` | `arpifs/phys_ec/cudlfsn.F90` | remaining |
| 77 | Atmospheric physics | `cumastrn` | `arpifs/phys_ec/cumastrn.F90` | remaining |
| 78 | Atmospheric physics | `gwdrag_wms` | `arpifs/phys_ec/gwdrag_wms.F90` | remaining |
| 79 | Atmospheric physics | `ec_phys` | `arpifs/phys_ec/ec_phys.F90` | remaining |
| 80 | Atmospheric physics | `cldpp` | `arpifs/phys_ec/cldpp.F90` | remaining |
| 81 | Atmospheric physics | `vdfexcu` | `arpifs/phys_ec/vdfexcu.F90` | remaining |
| 82 | Atmospheric physics | `vdftofdc` | `arpifs/phys_ec/vdftofdc.F90` | remaining |
| 83 | Atmospheric physics | `vdfhghtn` | `arpifs/phys_ec/vdfhghtn.F90` | remaining |
| 84 | Atmospheric physics | `vdfdifh` | `arpifs/phys_ec/vdfdifh.F90` | remaining |
| 85 | Atmospheric physics | `vdfdifm` | `arpifs/phys_ec/vdfdifm.F90` | remaining |
| 86 | Atmospheric physics | `vdfincr` | `arpifs/phys_ec/vdfincr.F90` | remaining |
| 87 | Atmospheric physics | `vdfdpbl` | `arpifs/phys_ec/vdfdpbl.F90` | remaining |
| 88 | Atmospheric physics | `vdfmain` | `arpifs/phys_ec/vdfmain.F90` | remaining |
| 89 | Atmospheric physics | `state_update` | `arpifs/phys_ec/state_update.F90` | remaining |
| 90 | Atmospheric physics | `gwsetup` | `arpifs/phys_ec/gwsetup.F90` | remaining |
| 91 | Atmospheric physics | `cucalln` | `arpifs/phys_ec/cucalln.F90` | remaining |
| 92 | Atmospheric physics | `state_increment` | `arpifs/phys_ec/state_increment.F90` | remaining |
| 93 | Atmospheric physics | `vdfouter` | `arpifs/phys_ec/vdfouter.F90` | remaining |
| 94 | Atmospheric physics | `sltend` | `arpifs/phys_ec/sltend.F90` | remaining |
| 95 | Atmospheric physics | `cubasmcn` | `arpifs/phys_ec/cubasmcn.F90` | remaining |
| 96 | Atmospheric physics | `gwdrag` | `arpifs/phys_ec/gwdrag.F90` | remaining |
| 97 | Atmospheric physics | `methox` | `arpifs/phys_ec/methox.F90` | remaining |
| 98 | Atmospheric physics | `cos_sza` | `arpifs/phys_ec/cos_sza.F90` | remaining |
| 99 | Atmospheric physics | `cuentr` | `arpifs/phys_ec/cuentr.F90` | remaining |
| 100 | Atmospheric physics | `gwprofil` | `arpifs/phys_ec/gwprofil.F90` | remaining |
| 101 | Atmospheric physics | `qnegat` | `arpifs/phys_ec/qnegat.F90` | remaining |
| 102 | Atmospheric physics | `gwdragwms_layer` | `arpifs/phys_ec/gwdragwms_layer.F90` | remaining |
| 103 | Atmospheric physics | `update_fields` | `arpifs/phys_ec/update_fields.F90` | remaining |
| 104 | Atmospheric physics | `surfrad_layer` | `arpifs/phys_ec/surfrad_layer.F90` | remaining |
| 105 | Atmospheric physics | `updecaec` | `arpifs/phys_ec/updecaec.F90` | remaining |
| 106 | Atmospheric physics | `cuccdia` | `arpifs/phys_ec/cuccdia.F90` | remaining |
| 107 | Atmospheric physics | `ec_phys_lslphy` | `arpifs/phys_ec/ec_phys_lslphy.F90` | remaining |
| 108 | Atmospheric physics | `upd_ghgclim` | `arpifs/phys_ec/upd_ghgclim.F90` | remaining |
| 109 | Atmospheric physics | `su_aerv` | `arpifs/phys_ec/su_aerv.F90` | remaining |
| 110 | Atmospheric physics | `cuadjtq` | `arpifs/phys_ec/cuadjtq.F90` | remaining |
| 111 | Atmospheric physics | `upd_ghgclim::interp_gas` | `arpifs/phys_ec/upd_ghgclim.F90` | remaining |
| 112 | Atmospheric physics | `updecaec::update_arr_2d` | `arpifs/phys_ec/updecaec.F90` | remaining |
| 113 | Weather support | `laitri_weno` | `arpifs/interpol/laitri_weno.F90` | remaining |
| 114 | Weather support | `laitriqm3d` | `arpifs/interpol/laitriqm3d.F90` | remaining |
| 115 | Dynamics | `larcina` | `arpifs/adiab/larcina.F90` | remaining |
| 116 | Dynamics | `larmes_xyz` | `arpifs/adiab/larmes_xyz.F90` | remaining |
| 117 | Weather support | `lascaw` | `arpifs/interpol/lascaw.F90` | remaining |
| 118 | Dynamics | `cpg` | `arpifs/adiab/cpg.F90` | remaining |
| 119 | Dynamics | `cpg_gp_hyd` | `arpifs/adiab/cpg_gp_hyd.F90` | remaining |
| 120 | Dynamics | `lattex` | `arpifs/adiab/lattex.F90` | remaining |
| 121 | Dynamics | `lapineb` | `arpifs/adiab/lapineb.F90` | remaining |
| 122 | Dynamics | `cpg_gp` | `arpifs/adiab/cpg_gp.F90` | remaining |
| 123 | Weather support | `gp_model` | `arpifs/control/gp_model.F90` | remaining |
| 124 | Dynamics | `lattex_dnt` | `arpifs/adiab/lattex_dnt.F90` | remaining |
| 125 | Dynamics | `cpglag` | `arpifs/adiab/cpglag.F90` | remaining |
| 126 | Dynamics | `gpinislb` | `arpifs/adiab/gpinislb.F90` | remaining |
| 127 | Dynamics | `gpcty` | `arpifs/adiab/gpcty.F90` | remaining |
| 128 | Dynamics | `larcinb` | `arpifs/adiab/larcinb.F90` | remaining |
| 129 | Dynamics | `lattes` | `arpifs/adiab/lattes.F90` | remaining |
| 130 | Dynamics | `lassie` | `arpifs/adiab/lassie.F90` | remaining |
| 131 | Dynamics | `gprcp::accumulate` | `arpifs/adiab/gprcp.F90` | remaining |
| 132 | Dynamics | `lapinea` | `arpifs/adiab/lapinea.F90` | remaining |
| 133 | Weather support | `legtri` | `arpifs/transform/legtri.F90` | remaining |
| 134 | Dynamics | `lasure` | `arpifs/adiab/lasure.F90` | remaining |
| 135 | Weather support | `cnt4` | `arpifs/control/cnt4.F90` | remaining |
| 136 | Weather support | `slextpol` | `arpifs/interpol/slextpol.F90` | remaining |
| 137 | Dynamics | `spchor` | `arpifs/adiab/spchor.F90` | remaining |
| 138 | Dynamics | `spcsi` | `arpifs/adiab/spcsi.F90` | remaining |
| 139 | Weather support | `stepo` | `arpifs/control/stepo.F90` | remaining |
| 140 | Weather support | `vexcs_mod::vexcs` | `surf/module/vexcs_mod.F90` | remaining |
| 141 | Weather support | `farquhar_mod::arrhenius_fn` | `surf/module/farquhar_mod.F90` | remaining |
| 142 | Weather support | `farquhar_mod::arrhenius_modified_fn` | `surf/module/farquhar_mod.F90` | remaining |
| 143 | Weather support | `farquhar_mod::farquhar` | `surf/module/farquhar_mod.F90` | remaining |
| 144 | Weather support | `surfexcdriver_ctl_mod::surfexcdriver_ctl` | `surf/module/surfexcdriver_ctl_mod.F90` | remaining |
| 145 | Weather support | `surfrad_ctl_mod::surfrad_ctl` | `surf/module/surfrad_ctl_mod.F90` | remaining |
| 146 | Weather support | `vsurf_mod::vsurf` | `surf/module/vsurf_mod.F90` | remaining |
| 147 | Weather support | `surfseb_ctl_mod::surfseb_ctl` | `surf/module/surfseb_ctl_mod.F90` | remaining |
| 148 | Weather support | `surftstp_ctl_mod::surftstp_ctl` | `surf/module/surftstp_ctl_mod.F90` | remaining |
| 149 | Weather support | `vupdz0_mod::vupdz0` | `surf/module/vupdz0_mod.F90` | remaining |
| 150 | Weather support | `cotworestress_mod::cotworestress` | `surf/module/cotworestress_mod.F90` | remaining |
| 151 | Weather support | `srfwexc_vg_mod::srfwexc_vg` | `surf/module/srfwexc_vg_mod.F90` | remaining |
| 152 | Radiation | `liquid_effective_radius` | `arpifs/phys_radi/liquid_effective_radius.F90` | remaining |
| 153 | Radiation | `ice_effective_radius` | `arpifs/phys_radi/ice_effective_radius.F90` | remaining |
| 154 | Weather support | `canalb_mod::canalb` | `surf/module/canalb_mod.F90` | remaining |
| 155 | Weather support | `srfsn_driver_mod::srfsn_driver` | `surf/module/srfsn_driver_mod.F90` | remaining |
| 156 | Weather support | `srft_mod::srft` | `surf/module/srft_mod.F90` | remaining |
| 157 | Weather support | `srfcotwo_mod::srfcotwo` | `surf/module/srfcotwo_mod.F90` | remaining |
| 158 | Weather support | `surfbc_ctl_mod::surfbc_ctl` | `surf/module/surfbc_ctl_mod.F90` | remaining |
| 159 | Weather support | `surfpp_ctl_mod::surfpp_ctl` | `surf/module/surfpp_ctl_mod.F90` | remaining |
| 160 | Weather support | `srfsn_regrid_mod::srfsn_regrid` | `surf/module/srfsn_regrid_mod.F90` | remaining |
| 161 | Weather support | `vevap_mod::vevap` | `surf/module/vevap_mod.F90` | remaining |
| 162 | Weather support | `srfsn_webal_mod::trisolver` | `surf/module/srfsn_webal_mod.F90` | remaining |
| 163 | Weather support | `srfsn_webal_mod::srfsn_webal` | `surf/module/srfsn_webal_mod.F90` | remaining |
| 164 | Weather support | `voskin_mod::voskin` | `surf/module/voskin_mod.F90` | remaining |
| 165 | Radiation | `cloud_overlap_decorr_len` | `arpifs/phys_radi/cloud_overlap_decorr_len.F90` | remaining |
| 166 | Weather support | `srfsn_ssrabs_mod::srfsn_ssrabs` | `surf/module/srfsn_ssrabs_mod.F90` | remaining |
| 167 | Weather support | `srfwdif_mod::srfwdif` | `surf/module/srfwdif_mod.F90` | remaining |
| 168 | Weather support | `vlamsk_mod::vlamsk` | `surf/module/vlamsk_mod.F90` | remaining |
| 169 | Weather support | `srfi_mod::srfi` | `surf/module/srfi_mod.F90` | remaining |
| 170 | Weather support | `srfwl_mod::srfwl` | `surf/module/srfwl_mod.F90` | remaining |
| 171 | Weather support | `flake_driver_mod::flake_driver` | `surf/module/flake_driver_mod.F90` | remaining |
| 172 | Weather support | `flakeene_mod::flakeene` | `surf/module/flakeene_mod.F90` | remaining |
| 173 | Weather support | `srfrcg_mod::srfrcg` | `surf/module/srfrcg_mod.F90` | remaining |
| 174 | Weather support | `srfsn_vgrid_mod::srfsn_vgrid` | `surf/module/srfsn_vgrid_mod.F90` | remaining |
| 175 | Weather support | `flakerad_mod::flakerad` | `surf/module/flakerad_mod.F90` | remaining |
| 176 | Weather support | `srfsn_asn_mod::srfsn_asn` | `surf/module/srfsn_asn_mod.F90` | remaining |
| 177 | Weather support | `srfwinc_mod::srfwinc` | `surf/module/srfwinc_mod.F90` | remaining |
| 178 | Weather support | `srfwng_mod::srfwng` | `surf/module/srfwng_mod.F90` | remaining |
| 179 | Weather support | `surfws_ctl_mod::surfws_ctl` | `surf/module/surfws_ctl_mod.F90` | remaining |
| 180 | Weather support | `surfws_init_sl_mod::surfws_init_sl` | `surf/module/surfws_init_sl_mod.F90` | remaining |
| 181 | Radiation | `suecozo` | `arpifs/phys_radi/suecozo.F90` | remaining |
| 182 | Weather support | `surfws_fgprof_mod::surfws_fgprof` | `surf/module/surfws_fgprof.F90` | remaining |
| 183 | Weather support | `surfws_massadj_mod::surfws_massadj` | `surf/module/surfws_massadj_mod.F90` | remaining |
| 184 | Radiation | `updecozc` | `arpifs/phys_radi/updecozc.F90` | remaining |
| 185 | Weather support | `updrgas` | `arpifs/climate/updrgas.F90` | remaining |
| 186 | Weather support | `updrgas::get_year` | `arpifs/climate/updrgas.F90` | remaining |
| 187 | Weather support | `updtim` | `arpifs/utility/updtim.F90` | remaining |
| 188 | Weather support | `yomghgtimeseries::get_ghg_concentrations` | `arpifs/module/yomghgtimeseries.F90` | remaining |
| 189 | Weather support | `yomsolarirradiance::get_solar_irradiance` | `arpifs/module/yomsolarirradiance.F90` | remaining |
| 190 | Weather support | `srfsn_rsn_mod::srfsn_rsn` | `surf/module/srfsn_rsn_mod.F90` | remaining |
| 191 | Weather support | `srfvegevol_mod::srfvegevol` | `surf/module/srfvegevol_mod.F90` | remaining |
| 192 | Weather support | `vupdz0_mod::pz0wn` | `surf/module/vupdz0_mod.F90` | remaining |
| 193 | Spectral transforms | `fft992::qpassf` | `contrib/ectrans/src/trans/algor/fft992.F90` | remaining |
| 194 | Spectral transforms | `fft992::rpassf` | `contrib/ectrans/src/trans/algor/fft992.F90` | remaining |
| 195 | Spectral transforms | `fft992` | `contrib/ectrans/src/trans/algor/fft992.F90` | remaining |
| 196 | Spectral transforms | `asre1b_mod::asre1b` | `contrib/ectrans/src/trans/internal/asre1b_mod.F90` | remaining |
| 197 | Spectral transforms | `fsc_mod::fsc` | `contrib/ectrans/src/trans/internal/fsc_mod.F90` | remaining |
| 198 | Spectral transforms | `ftdir_mod::ftdir` | `contrib/ectrans/src/trans/internal/ftdir_mod.F90` | remaining |
| 199 | Spectral transforms | `ldfou2_mod::ldfou2` | `contrib/ectrans/src/trans/internal/ldfou2_mod.F90` | remaining |
| 200 | Spectral transforms | `ledir_mod::ledir` | `contrib/ectrans/src/trans/internal/ledir_mod.F90` | remaining |
| 201 | Spectral transforms | `ltinv_mod::ltinv` | `contrib/ectrans/src/trans/internal/ltinv_mod.F90` | remaining |
| 202 | Spectral transforms | `prfi2b_mod::prfi2b` | `contrib/ectrans/src/trans/internal/prfi2b_mod.F90` | remaining |
| 203 | Spectral transforms | `spnsde_mod::spnsde` | `contrib/ectrans/src/trans/internal/spnsde_mod.F90` | remaining |
| 204 | Spectral transforms | `uvtvd_mod::uvtvd` | `contrib/ectrans/src/trans/internal/uvtvd_mod.F90` | remaining |
| 205 | Spectral transforms | `vdtuv_mod::vdtuv` | `contrib/ectrans/src/trans/internal/vdtuv_mod.F90` | remaining |
| 206 | Dynamics | `lavent` | `arpifs/adiab/lavent.F90` | deferred original accuracy rejection |

The historical 207-routine priority mapping, including diagnostic-profile matches and source-dependency classifications, is retained at `.runtime/openifs/implicit_stage_reviews_7207705/weather-forecast-impact-priority-source-r1/complete207-weather-forecast-impact-order-r1.tsv`. Its 53,841 bytes have SHA256 `ae2e8468f0b078b16a8ac33df883b1c32bcf5694a223146359c5ac90e3062afe`. This document lists the 206 remaining weather identifiers once and does not duplicate the broader main-phase inventory.
