!> Add source-defined field metadata and optional-owner observations.
!! Fixed capture buffers belong to the observer. Scientific owners stay readonly.
module forecast_native_weather_extensions
  use iso_c_binding
  use iso_fortran_env, only: int32, int64
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_attached_field_container, only: native_attached_field_container
  use forecast_native_field_metadata_capture, only: capture_native_field_metadata_named
  use forecast_weather_view_protocol
  implicit none
  private
  integer(c_int8_t), target, save :: field_records(184, 4200, 5)
  integer(c_int32_t), target, save :: field_indices(8, 4200, 5), capture_dimensions(4), associations(8)
  public :: describe_native_weather_extensions
contains
  subroutine describe_native_weather_extensions(state, observer, status)
    type(native_forecast_execution_state), target, intent(in) :: state
    type(c_funptr), intent(in) :: observer
    integer(c_int), intent(out) :: status
    procedure(weather_view_callback), pointer :: observe
    status = 2
    if (.not. c_associated(observer)) return
    if (.not. allocated(state%startup)) return
    if (.not. allocated(state%startup%initial)) return
    if (.not. allocated(state%startup%initial%geometry)) return
    if (.not. associated(state%startup%loaded%fields)) return
    call c_f_procpointer(observer, observe)
    associate (g => state%startup%initial%geometry)
      capture_dimensions = [g%dimensions%nproma, g%dimensions%nflevg, g%partition%ngpblks, g%partition%ngptot]
    end associate
 call observe_weather_primitive('capture.dimensions',1_c_int,4_c_int,[1_c_int64_t],[4_c_int64_t],capture_dimensions,3_c_int,observe,status)
    if (status /= 0) return
    if (allocated(state%flux_controls%cfu%gfubuf)) then
 call observe_weather_primitive('flux.cfu.gfubuf',2_c_int,8_c_int,lbound(state%flux_controls%cfu%gfubuf,kind=c_int64_t),ubound(state%flux_controls%cfu%gfubuf,kind=c_int64_t),state%flux_controls%cfu%gfubuf,1_c_int,observe,status)
    else
      call observe_absent_weather_view('flux.cfu.gfubuf', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%flux_controls%xfu%xfubuf)) then
 call observe_weather_primitive('flux.xfu.xfubuf',2_c_int,8_c_int,lbound(state%flux_controls%xfu%xfubuf,kind=c_int64_t),ubound(state%flux_controls%xfu%xfubuf,kind=c_int64_t),state%flux_controls%xfu%xfubuf,1_c_int,observe,status)
    else
      call observe_absent_weather_view('flux.xfu.xfubuf', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%flux_controls%xfu%rmwindcalc)) then
 call observe_weather_primitive('flux.xfu.rmwindcalc',2_c_int,8_c_int,lbound(state%flux_controls%xfu%rmwindcalc,kind=c_int64_t),ubound(state%flux_controls%xfu%rmwindcalc,kind=c_int64_t),state%flux_controls%xfu%rmwindcalc,1_c_int,observe,status)
    else
      call observe_absent_weather_view('flux.xfu.rmwindcalc', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%flux_controls%xfu%rmnwindcalc)) then
 call observe_weather_primitive('flux.xfu.rmnwindcalc',2_c_int,8_c_int,lbound(state%flux_controls%xfu%rmnwindcalc,kind=c_int64_t),ubound(state%flux_controls%xfu%rmnwindcalc,kind=c_int64_t),state%flux_controls%xfu%rmnwindcalc,1_c_int,observe,status)
    else
      call observe_absent_weather_view('flux.xfu.rmnwindcalc', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%flux_controls%mcuf%rmcufsp)) then
 call observe_weather_primitive('flux.mcuf.rmcufsp',2_c_int,8_c_int,lbound(state%flux_controls%mcuf%rmcufsp,kind=c_int64_t),ubound(state%flux_controls%mcuf%rmcufsp,kind=c_int64_t),state%flux_controls%mcuf%rmcufsp,1_c_int,observe,status)
    else
      call observe_absent_weather_view('flux.mcuf.rmcufsp', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%flux_controls%mcuf%rmcuffp)) then
 call observe_weather_primitive('flux.mcuf.rmcuffp',2_c_int,8_c_int,lbound(state%flux_controls%mcuf%rmcuffp,kind=c_int64_t),ubound(state%flux_controls%mcuf%rmcuffp,kind=c_int64_t),state%flux_controls%mcuf%rmcuffp,1_c_int,observe,status)
    else
      call observe_absent_weather_view('flux.mcuf.rmcuffp', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.rmcufa',2_c_int,8_c_int,lbound(state%flux_controls%mcuf%rmcufa,kind=c_int64_t),ubound(state%flux_controls%mcuf%rmcufa,kind=c_int64_t),state%flux_controls%mcuf%rmcufa,1_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.rmcufb',2_c_int,8_c_int,lbound(state%flux_controls%mcuf%rmcufb,kind=c_int64_t),ubound(state%flux_controls%mcuf%rmcufb,kind=c_int64_t),state%flux_controls%mcuf%rmcufb,1_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.rmcufi',2_c_int,8_c_int,lbound(state%flux_controls%mcuf%rmcufi,kind=c_int64_t),ubound(state%flux_controls%mcuf%rmcufi,kind=c_int64_t),state%flux_controls%mcuf%rmcufi,1_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.ncufor',1_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%flux_controls%mcuf%ncufor,3_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.ncufnr',1_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%flux_controls%mcuf%ncufnr,3_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.lmcuf',3_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%flux_controls%mcuf%lmcuf,3_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('flux.mcuf.lreacuf',3_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%flux_controls%mcuf%lreacuf,3_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('source_controls.lelam',1_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%startup%initial%controls%namespace%lelam,3_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('source_controls.ltenc_column',3_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%grid%blocks%controls%column%limited_area_tendencies,3_c_int,observe,status)
    if (status /= 0) return
 call observe_weather_primitive('source_controls.ltenc_grid',3_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%grid%blocks%controls%column%grid%boundary_coupling,3_c_int,observe,status)
    if (status /= 0) return

    associations(1) = merge(1, 0, associated(state%startup%loaded%fields%registry%variables))
    associations(2) = merge(1, 0, associated(state%startup%loaded%fields%registry%surface))
    associations(3) = merge(1, 0, associated(state%startup%loaded%fields%registry%geometry))
    associations(4) = merge(1, 0, associated(state%startup%loaded%fields%registry%model))
    associations(5) = 0
    if (associated(state%startup%loaded%fields%field, state%startup%loaded%fields%field_t0)) associations(5) = 1
    if (associated(state%startup%loaded%fields%field, state%startup%loaded%fields%field_t1)) associations(5) = 2
    if (associated(state%startup%loaded%fields%field, state%startup%loaded%fields%field_t9)) associations(5) = 3
    associations(6) = merge(1, 0, associated(state%startup%loaded%fields%state_model))
    associations(7) = merge(1, 0, associated(state%startup%loaded%fields%geometry))
    associations(8) = 0
call observe_weather_primitive('field.alias_tokens',1_c_int,4_c_int,[1_c_int64_t],[8_c_int64_t],associations,3_c_int,observe,status)
    if (status /= 0) return
    if (associated(state%startup%loaded%fields%registry%variables)) then
 call observe_weather_primitive('registry.nproma',1_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%startup%loaded%fields%registry%nproma,3_c_int,observe,status)
      if (status /= 0) return
 call observe_weather_primitive('registry.nblocks',1_c_int,4_c_int,[integer(c_int64_t)::],[integer(c_int64_t)::],state%startup%loaded%fields%registry%nblocks,3_c_int,observe,status)
      if (status /= 0) return
    end if
    call describe_field('field_t0', state%startup%loaded%fields%field_t0, 1, observe, status)
    if (status /= 0) return
    call describe_field('field_t1', state%startup%loaded%fields%field_t1, 2, observe, status)
    if (status /= 0) return
    call describe_field('field_t9', state%startup%loaded%fields%field_t9, 3, observe, status)
    if (status /= 0) return
    call describe_field('field_pc', state%startup%loaded%fields%field_pc, 4, observe, status)
    if (status /= 0) return
    call describe_field('field_pt', state%startup%loaded%fields%field_pt, 5, observe, status)
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%ra1)) then
 call observe_weather_primitive('surface_parameters.yagf.ra1',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%ra1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%ra1,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%ra1,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.ra1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rb1)) then
 call observe_weather_primitive('surface_parameters.yagf.rb1',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rb1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rb1,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rb1,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rb1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rdownregulation_co2_coef)) then
 call observe_weather_primitive('surface_parameters.yagf.rdownregulation_co2_coef',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rdownregulation_co2_coef,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rdownregulation_co2_coef,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rdownregulation_co2_coef,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rdownregulation_co2_coef', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%re_jmax)) then
 call observe_weather_primitive('surface_parameters.yagf.re_jmax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%re_jmax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%re_jmax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%re_jmax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.re_jmax', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%re_vcmax)) then
 call observe_weather_primitive('surface_parameters.yagf.re_vcmax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%re_vcmax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%re_vcmax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%re_vcmax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.re_vcmax', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rg0)) then
 call observe_weather_primitive('surface_parameters.yagf.rg0',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rg0,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rg0,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rg0,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rg0', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rgm25)) then
 call observe_weather_primitive('surface_parameters.yagf.rgm25',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rgm25,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rgm25,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rgm25,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rgm25', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rhumrel)) then
 call observe_weather_primitive('surface_parameters.yagf.rhumrel',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rhumrel,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rhumrel,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rhumrel,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rhumrel', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rstruct_const)) then
 call observe_weather_primitive('surface_parameters.yagf.rstruct_const',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rstruct_const,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rstruct_const,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rstruct_const,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rstruct_const', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yagf%rvcmax25)) then
 call observe_weather_primitive('surface_parameters.yagf.rvcmax25',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yagf%rvcmax25,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yagf%rvcmax25,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yagf%rvcmax25,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yagf.rvcmax25', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%lvstress)) then
 call observe_weather_primitive('surface_parameters.yags.lvstress',3_c_int,4_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%lvstress,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%lvstress,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%lvstress,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.lvstress', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvah)) then
 call observe_weather_primitive('surface_parameters.yags.rvah',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvah,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvah,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvah,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvah', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvammax)) then
 call observe_weather_primitive('surface_parameters.yags.rvammax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvammax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvammax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvammax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvammax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvanmax)) then
 call observe_weather_primitive('surface_parameters.yags.rvanmax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvanmax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvanmax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvanmax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvanmax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvbh)) then
 call observe_weather_primitive('surface_parameters.yags.rvbh',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvbh,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvbh,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvbh,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvbh', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvbslai)) then
 call observe_weather_primitive('surface_parameters.yags.rvbslai',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvbslai,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvbslai,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvbslai,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvbslai', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvbslai_nitro)) then
 call observe_weather_primitive('surface_parameters.yags.rvbslai_nitro',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvbslai_nitro,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvbslai_nitro,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvbslai_nitro,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvbslai_nitro', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvce)) then
 call observe_weather_primitive('surface_parameters.yags.rvce',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvce,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvce,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvce,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvce', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvcf)) then
 call observe_weather_primitive('surface_parameters.yags.rvcf',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvcf,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvcf,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvcf,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvcf', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvch4qvt)) then
 call observe_weather_primitive('surface_parameters.yags.rvch4qvt',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvch4qvt,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvch4qvt,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvch4qvt,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvch4qvt', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvcna)) then
 call observe_weather_primitive('surface_parameters.yags.rvcna',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvcna,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvcna,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvcna,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvcna', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvdmax)) then
 call observe_weather_primitive('surface_parameters.yags.rvdmax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvdmax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvdmax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvdmax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvdmax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvepso)) then
 call observe_weather_primitive('surface_parameters.yags.rvepso',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvepso,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvepso,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvepso,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvepso', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvf2i)) then
 call observe_weather_primitive('surface_parameters.yags.rvf2i',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvf2i,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvf2i,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvf2i,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvf2i', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvfzero)) then
 call observe_weather_primitive('surface_parameters.yags.rvfzero',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvfzero,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvfzero,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvfzero,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvfzero', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvfzerost)) then
 call observe_weather_primitive('surface_parameters.yags.rvfzerost',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvfzerost,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvfzerost,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvfzerost,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvfzerost', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvgamm)) then
 call observe_weather_primitive('surface_parameters.yags.rvgamm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvgamm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvgamm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvgamm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvgamm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvgc)) then
 call observe_weather_primitive('surface_parameters.yags.rvgc',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvgc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvgc,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvgc,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvgc', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvgmes)) then
 call observe_weather_primitive('surface_parameters.yags.rvgmes',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvgmes,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvgmes,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvgmes,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvgmes', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvlaimin)) then
 call observe_weather_primitive('surface_parameters.yags.rvlaimin',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvlaimin,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvlaimin,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvlaimin,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvlaimin', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvqdammax)) then
 call observe_weather_primitive('surface_parameters.yags.rvqdammax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvqdammax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvqdammax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvqdammax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvqdammax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvqdgamm)) then
 call observe_weather_primitive('surface_parameters.yags.rvqdgamm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvqdgamm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvqdgamm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvqdgamm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvqdgamm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvqdgmes)) then
 call observe_weather_primitive('surface_parameters.yags.rvqdgmes',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvqdgmes,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvqdgmes,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvqdgmes,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvqdgmes', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvr0vt)) then
 call observe_weather_primitive('surface_parameters.yags.rvr0vt',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvr0vt,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvr0vt,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvr0vt,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvr0vt', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvsefold)) then
 call observe_weather_primitive('surface_parameters.yags.rvsefold',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvsefold,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvsefold,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvsefold,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvsefold', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvt1ammax)) then
 call observe_weather_primitive('surface_parameters.yags.rvt1ammax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvt1ammax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvt1ammax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvt1ammax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvt1ammax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvt1gmes)) then
 call observe_weather_primitive('surface_parameters.yags.rvt1gmes',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvt1gmes,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvt1gmes,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvt1gmes,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvt1gmes', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvt2ammax)) then
 call observe_weather_primitive('surface_parameters.yags.rvt2ammax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvt2ammax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvt2ammax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvt2ammax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvt2ammax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvt2gmes)) then
 call observe_weather_primitive('surface_parameters.yags.rvt2gmes',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvt2gmes,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvt2gmes,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvt2gmes,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvt2gmes', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rvtopt)) then
 call observe_weather_primitive('surface_parameters.yags.rvtopt',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rvtopt,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rvtopt,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rvtopt,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rvtopt', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yags%rxbomegam)) then
 call observe_weather_primitive('surface_parameters.yags.rxbomegam',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yags%rxbomegam,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yags%rxbomegam,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yags%rxbomegam,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yags.rxbomegam', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rcwpsism)) then
 call observe_weather_primitive('surface_parameters.ysoil.rcwpsism',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rcwpsism,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rcwpsism,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rcwpsism,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rcwpsism', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rdai)) then
 call observe_weather_primitive('surface_parameters.ysoil.rdai',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdai,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdai,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rdai,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rdai', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rdat)) then
 call observe_weather_primitive('surface_parameters.ysoil.rdat',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdat,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdat,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rdat,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rdat', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rdaw)) then
 call observe_weather_primitive('surface_parameters.ysoil.rdaw',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdaw,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdaw,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rdaw,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rdaw', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rdmaxm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rdmaxm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdmaxm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdmaxm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rdmaxm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rdmaxm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rdminm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rdminm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdminm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rdminm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rdminm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rdminm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdadrym)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlambdadrym',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdadrym,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdadrym,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdadrym,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlambdadrym', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdam)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlambdam',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdam,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdam,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlambdam,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlambdam', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlamsat1m)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlamsat1m',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlamsat1m,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlamsat1m,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlamsat1m,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlamsat1m', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlevsnmax',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlevsnmax', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax_gl)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlevsnmax_gl',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax_gl,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax_gl,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmax_gl,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlevsnmax_gl', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlevsnmin',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlevsnmin', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin_gl)) then
 call observe_weather_primitive('surface_parameters.ysoil.rlevsnmin_gl',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin_gl,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin_gl,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rlevsnmin_gl,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rlevsnmin_gl', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rmfacm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rmfacm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rmfacm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rmfacm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rmfacm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rmfacm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rmvgalpha)) then
 call observe_weather_primitive('surface_parameters.ysoil.rmvgalpha',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rmvgalpha,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rmvgalpha,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rmvgalpha,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rmvgalpha', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rnfacm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rnfacm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rnfacm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rnfacm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rnfacm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rnfacm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rqwevapm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rqwevapm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rqwevapm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rqwevapm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rqwevapm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rqwevapm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rqwsbcrm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rqwsbcrm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rqwsbcrm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rqwsbcrm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rqwsbcrm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rqwsbcrm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rrcsoilm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rrcsoilm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rrcsoilm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rrcsoilm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rrcsoilm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rrcsoilm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rsndtdestc_ml)) then
 call observe_weather_primitive('surface_parameters.ysoil.rsndtdestc_ml',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rsndtdestc_ml,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rsndtdestc_ml,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rsndtdestc_ml,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rsndtdestc_ml', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rwcapm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rwcapm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwcapm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwcapm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rwcapm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rwcapm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rwconsm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rwconsm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwconsm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwconsm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rwconsm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rwconsm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rwpwpm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rwpwpm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwpwpm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwpwpm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rwpwpm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rwpwpm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rwrestm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rwrestm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwrestm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwrestm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rwrestm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rwrestm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysoil%rwsatm)) then
 call observe_weather_primitive('surface_parameters.ysoil.rwsatm',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwsatm,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysoil%rwsatm,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysoil%rwsatm,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysoil.rwsatm', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_an)) then
 call observe_weather_primitive('surface_parameters.ysw.ralbice_an',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_an,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_an,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_an,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysw.ralbice_an', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_ar)) then
 call observe_weather_primitive('surface_parameters.ysw.ralbice_ar',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_ar,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_ar,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysw%ralbice_ar,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysw.ralbice_ar', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%ysw%rsun)) then
 call observe_weather_primitive('surface_parameters.ysw.rsun',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%ysw%rsun,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%ysw%rsun,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%ysw%rsun,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.ysw.rsun', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvcov)) then
 call observe_weather_primitive('surface_parameters.yveg.rvcov',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvcov,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvcov,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvcov,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvcov', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvhstr)) then
 call observe_weather_primitive('surface_parameters.yveg.rvhstr',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvhstr,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvhstr,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvhstr,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvhstr', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvlai)) then
 call observe_weather_primitive('surface_parameters.yveg.rvlai',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvlai,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvlai,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvlai,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvlai', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsk)) then
 call observe_weather_primitive('surface_parameters.yveg.rvlamsk',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsk,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsk,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsk,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvlamsk', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsks)) then
 call observe_weather_primitive('surface_parameters.yveg.rvlamsks',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsks,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsks,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvlamsks,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvlamsks', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvrootsa)) then
 call observe_weather_primitive('surface_parameters.yveg.rvrootsa',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvrootsa,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvrootsa,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvrootsa,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvrootsa', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvrsmin)) then
 call observe_weather_primitive('surface_parameters.yveg.rvrsmin',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvrsmin,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvrsmin,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvrsmin,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvrsmin', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvtrsr)) then
 call observe_weather_primitive('surface_parameters.yveg.rvtrsr',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvtrsr,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvtrsr,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvtrsr,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvtrsr', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvz0h)) then
 call observe_weather_primitive('surface_parameters.yveg.rvz0h',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvz0h,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvz0h,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvz0h,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvz0h', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    if (allocated(state%startup%loaded%storage%ecmwf%surface%yveg%rvz0m)) then
 call observe_weather_primitive('surface_parameters.yveg.rvz0m',2_c_int,8_c_int,lbound(state%startup%loaded%storage%ecmwf%surface%yveg%rvz0m,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%surface%yveg%rvz0m,kind=c_int64_t),state%startup%loaded%storage%ecmwf%surface%yveg%rvz0m,1_c_int,observe,status)
    else
      call observe_absent_weather_view('surface_parameters.yveg.rvz0m', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) return
    status = 0
  end subroutine
  subroutine describe_field(name, field, slot, observe, status)
    character(*), intent(in) :: name
    type(native_attached_field_container), target, intent(in) :: field
    integer, intent(in) :: slot
    procedure(weather_view_callback) :: observe
    integer(c_int), intent(out) :: status
    integer :: i
    status = 2
    if (field%lcreated) then
      if (.not. allocated(field%metadata) .or. .not. allocated(field%field_index) .or. .not. allocated(field%index_gp)) return
      if (size(field%metadata) /= 4200 .or. size(field%field_index) /= 4200 .or. size(field%index_gp) /= 4200) return
      status = capture_native_field_metadata_named(field%metadata, field_records(:, :, slot))
      if (status /= 0) return
      do i = 1, 4200
        field_indices(1, i, slot) = field%field_index(i)%l_on
        field_indices(2, i, slot) = field%field_index(i)%l_active
        field_indices(3, i, slot) = field%index_gp(i)%l_on
        field_indices(4, i, slot) = field%index_gp(i)%l_active
        field_indices(5, i, slot) = field%index_gp(i)%istart
        field_indices(6, i, slot) = field%index_gp(i)%iend
        field_indices(7, i, slot) = field%index_gp(i)%l_hders
        ! DL has an original NULL default. DM is undefined and is never queried.
        if (associated(field%index_gp(i)%dl)) return
        field_indices(8, i, slot) = 0
      end do
      call observe_weather_primitive(trim(name)//'.named_metadata', 1_c_int, 1_c_int, [1_c_int64_t, 1_c_int64_t], &
                                     [184_c_int64_t, 4200_c_int64_t], field_records(:, :, slot), 1_c_int, observe, status)
      if (status /= 0) return
      call observe_weather_primitive(trim(name)//'.named_indices', 1_c_int, 4_c_int, [1_c_int64_t, 1_c_int64_t], &
                                     [8_c_int64_t, 4200_c_int64_t], field_indices(:, :, slot), 1_c_int, observe, status)
    else
      call observe_absent_weather_view(trim(name)//'.named_metadata', 2_c_int, 1_c_int, observe, status)
      if (status /= 0) return
      call observe_absent_weather_view(trim(name)//'.named_indices', 2_c_int, 1_c_int, observe, status)
    end if
  end subroutine
end module
