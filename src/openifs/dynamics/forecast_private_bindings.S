/* Private names over accepted direct assembly entries.
 * Contract: skills/md2asm/references/openifs/dynamics/retained_forecast_callers.md.
 * Original by-address interfaces and frozen child order are retained. */
.arch armv8.2-a
.text
.p2align 2
.global md2asm_scm_coriolis_prepare
.type md2asm_scm_coriolis_prepare,%function
md2asm_scm_coriolis_prepare:
 b spcimpfinit_assembly_
.size md2asm_scm_coriolis_prepare,.-md2asm_scm_coriolis_prepare
.global md2asm_scm_coriolis_correct
.type md2asm_scm_coriolis_correct,%function
md2asm_scm_coriolis_correct:
 b spcimpfpost_assembly_
.size md2asm_scm_coriolis_correct,.-md2asm_scm_coriolis_correct
.global md2asm_scm_spectral_filter
.type md2asm_scm_spectral_filter,%function
md2asm_scm_spectral_filter:
 b spfilt_
.size md2asm_scm_spectral_filter,.-md2asm_scm_spectral_filter
.global md2asm_spcsi_pressure_solve
.type md2asm_spcsi_pressure_solve,%function
md2asm_spcsi_pressure_solve:
 b spcimpfsolve_assembly_
.size md2asm_spcsi_pressure_solve,.-md2asm_spcsi_pressure_solve
.global md2asm_spcsi_sigam
.type md2asm_spcsi_sigam,%function
md2asm_spcsi_sigam:
 b sigam_assembly_
.size md2asm_spcsi_sigam,.-md2asm_spcsi_sigam
.global md2asm_spcsi_temperature_pressure
.type md2asm_spcsi_temperature_pressure,%function
md2asm_spcsi_temperature_pressure:
 b sitnu_
.size md2asm_spcsi_temperature_pressure,.-md2asm_spcsi_temperature_pressure
.global verdisint_assembly_
.type verdisint_assembly_,%function
verdisint_assembly_:
 b verdisint_
.size verdisint_assembly_,.-verdisint_assembly_
.global md2asm_owned_greenhouse_lookup
.type md2asm_owned_greenhouse_lookup,%function
md2asm_owned_greenhouse_lookup:
 b __yomghgtimeseries_MOD_get_ghg_concentrations
.size md2asm_owned_greenhouse_lookup,.-md2asm_owned_greenhouse_lookup
.global md2asm_owned_solar_lookup
.type md2asm_owned_solar_lookup,%function
md2asm_owned_solar_lookup:
 b __yomsolarirradiance_MOD_get_solar_irradiance
.size md2asm_owned_solar_lookup,.-md2asm_owned_solar_lookup
.global md2asm_su_aerv
.type md2asm_su_aerv,%function
md2asm_su_aerv:
 b su_aerv_
.size md2asm_su_aerv,.-md2asm_su_aerv
.global md2asm_updecaec_private_gphpre
.type md2asm_updecaec_private_gphpre,%function
md2asm_updecaec_private_gphpre:
 b gphpre_
.size md2asm_updecaec_private_gphpre,.-md2asm_updecaec_private_gphpre
/* Unsupported transform inputs retain the original aborting guard. */
.global md2asm_external_transform_guard_terminal_r2
.type md2asm_external_transform_guard_terminal_r2,%function
md2asm_external_transform_guard_terminal_r2:
 b abort
.size md2asm_external_transform_guard_terminal_r2,.-md2asm_external_transform_guard_terminal_r2
.section .note.GNU-stack,"",%progbits
