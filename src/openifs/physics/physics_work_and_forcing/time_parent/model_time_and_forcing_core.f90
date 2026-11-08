!> Advance actual clock, orbital and monthly owners in the UPDTIM source order.
!! All temporal values are seconds. Angles use radians and distance uses metres.
!! No original MODEL, global numerical stage, callback or numerical payload copy is used.
module forecast_model_time_forcing_core
  use iso_fortran_env, only: int32, int64, real64
  use forecast_model_time_and_forcing, only: native_time_and_forcing_context
  use forecast_selected_model_storage, only: native_selected_model_storage, model_parameter_aliases_match
  use forecast_orbital_illumination, only: calculate_runtime_orbital_illumination
  use forecast_source_rounding_trigonometry, only: original_rounding_cosine, original_rounding_sine
  use forecast_operational_step_coefficients, only: update_operational_time_coefficients
  use forecast_ozone_environment, only: update_yearly_ozone_record, update_ozone_record
  use forecast_monthly_climate_updates, only: update_monthly_greenhouse
  use forecast_monthly_aerosol_updates, only: update_monthly_aerosols
  use forecast_native_clock_radiation_forcing, only: update_native_clock_radiation_forcing
  use forecast_native_ozone_chemistry_update, only: update_native_ozone_chemistry
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use ieee_exceptions, only: ieee_status_type
  use md2asm_hybrid_pressure_one_based, only: hybrid_pressure_controls
  implicit none
  private
  public :: run_time_forcing_prefix, finish_time_forcing_daily, agree_time_status, time_forcing_admission
contains
!> Complete all non-daily source operations, then return the daily window.
!! A later nonzero child status retains all reached source writes. The loop owns
!! CLOCK%CURRENT_STEP and neither this entry nor a monthly child changes it.
  integer(int32) function run_time_forcing_prefix(storage, step, tdt, tstep, context, runtime, daily) result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tdt, tstep
    type(native_time_and_forcing_context), target, intent(inout) :: context
    logical, intent(in) :: runtime
    logical, intent(out) :: daily
    integer(int32) :: child, itime, izt, iday, isec, istass, minutes, frequency
    real(real64), volatile :: value, product, theta, phase, season, orbit(3), stati, hgmt, absolute_time
    type(hybrid_pressure_controls) :: pressure
    daily = .false.
    status = 2
    if (.not. associated(storage%model%initial)) return
    if (.not. allocated(storage%model%initial%geometry)) return
    status = time_forcing_admission(storage, step, tdt, tstep, context, runtime)
    if (runtime) status = agree_time_status(storage, status)
    if (status /= 0) return
    associate (clock => storage%model%initial%controls%clock, c => storage%model%initial%constants, &
               rad => storage%ecmwf%radiation%radiation, gas => storage%ecmwf%radiation%gases, &
               vert => storage%model%initial%geometry%vertical, grid => storage%model%initial%geometry%dimensions)
      itime = nint(tstep, kind=int32)
      value = real(step, real64) + 0.5_real64
      product = tstep*value
      izt = nint(product, kind=int32)
      clock%integration%relative_seconds = real(izt, real64)
      iday = nint(c%rday, kind=int32)
      clock%integration%date_time_flags(1) = izt/iday
      clock%integration%date_time_flags(2) = mod(izt, iday)
      istass = mod(izt + iday/2 - clock%initial_seconds, iday)
      clock%integration%initial_seconds_j2000 = clock%initial_seconds_j2000 + clock%integration%relative_seconds
      clock%integration%initial_solar(1) = real(mod(izt + clock%initial_seconds, iday), real64)
      product = c%rday*365.25_real64
      theta = clock%integration%initial_seconds_j2000/product
      status = calculate_runtime_orbital_illumination(clock%integration%initial_seconds_j2000, c, orbit)
      if (status /= 0) goto 900
      clock%integration%initial_solar(4) = orbit(1)
      clock%integration%initial_solar(5) = orbit(2)
      clock%integration%initial_solar(2) = orbit(3)
      clock%integration%initial_solar(3) = orbit(3) + clock%integration%initial_solar(1)
      product = clock%integration%initial_solar(3)*2.0_real64
      product = product*c%rpi
      clock%integration%initial_solar(6) = product/c%rday
      season = c%rea*c%rea
      product = orbit(1)*orbit(1)
      season = season/product
      product = gas%rsolinc*season
      clock%integration%initial_solar(7) = product
      storage%meteo_france%legacy_radiation_parameters%rii0 = product
      clock%integration%initial_solar(8) = original_rounding_cosine(clock%integration%initial_solar(5))
      clock%integration%initial_solar(9) = original_rounding_sine(clock%integration%initial_solar(5))
      clock%integration%initial_solar(10) = original_rounding_cosine(clock%integration%initial_solar(6))
      clock%integration%initial_solar(11) = original_rounding_sine(clock%integration%initial_solar(6))
      status = update_operational_time_coefficients(tdt, c%ra, clock%integration%work(1), clock%integration%work(2), &
             clock%integration%work(3), clock%integration%work(4), clock%integration%work(5), storage%model%physics_auxiliary%tsphy)
      if (status /= 0) goto 900
! Recompute the source stored-step clock before the radiation-time shift.
      itime = nint(clock%integration%first_dt, kind=int32)
      value = real(step, real64) + 0.5_real64
      product = clock%integration%first_dt*value
      izt = nint(product, kind=int32)
      stati = real(izt, real64)
      value = real(rad%nradfr - 1, real64)
      value = 0.5_real64*value
      value = value*real(itime, real64)
      stati = stati + value
      istass = mod(izt, iday)
      absolute_time = clock%initial_seconds_j2000 + stati
      hgmt = real(mod(nint(stati, kind=int32) + clock%initial_seconds, iday), real64)
      status = update_native_clock_radiation_forcing(storage%model%dynamics, rad, gas, clock, c, &
                                                storage%ecmwf%radiation%climate, clock%integration%first_step, .true., context%cmip)
      if (status /= 0) goto 900
      product = gas%rsolinc*season
      clock%integration%initial_solar(7) = product
      storage%meteo_france%legacy_radiation_parameters%rii0 = product
      status = calculate_runtime_orbital_illumination(absolute_time, c, orbit)
      if (status /= 0) goto 900
      frequency = rad%nradfr
      if (mod(step, frequency) == 0) then
        context%radiation_clock%rsovrm = orbit(3) + hgmt
        product = context%radiation_clock%rsovrm*2.0_real64
        product = product*c%rpi
        context%radiation_clock%rwsovrm = product/c%rday
        context%radiation_clock%rcodecm = original_rounding_cosine(orbit(2))
        context%radiation_clock%rsidecm = original_rounding_sine(orbit(2))
        context%radiation_clock%rcovsrm = original_rounding_cosine(context%radiation_clock%rwsovrm)
        context%radiation_clock%rsivsrm = original_rounding_sine(context%radiation_clock%rwsovrm)
      end if
! Preserve both source rounding points around the cancelling longitude constant.
      phase = 6.283076_real64*theta
      phase = 1.7535_real64 + phase
      phase = phase - 1.7535_real64
      call update_yearly_ozone_record(phase, storage%ecmwf%radiation%ozone, status)
      if (status /= 0) goto 900
      if (mod(step, frequency) == 0) then
        value = stati + real(clock%initial_seconds, real64)
        value = value/60.0_real64
        minutes = nint(value, kind=int32)
        call update_ozone_record(c%rpi, gas%ro3, rad%rpertoz, rad%npertoz, clock%initial_date, minutes, &
                                 storage%ecmwf%radiation%ozone, status)
        if (status /= 0) goto 900
        status = update_monthly_greenhouse(clock%initial_date, minutes, rad, gas, c, storage%ecmwf%radiation%climate)
        if (status /= 0) goto 900
        pressure%approximate_mode = 0
        pressure%finite_elements = vert%configuration%lvertfe /= 0
        pressure%top_pressure = vert%toppres
        pressure%dry_gas_constant = c%rd
        pressure%dry_isochoric_heat_capacity = c%rcvd
        status = update_monthly_aerosols(clock%initial_date, minutes, vert%levels, rad, context%cmip, &
                                         storage%ecmwf%radiation%tegen, storage%ecmwf%radiation%cams, pressure, vert%vp00, &
                                         vert%vah, vert%vbh, vert%vc, vert%vaf, vert%vbf, vert%vdela, vert%vdelb)
        if (status /= 0) goto 900
      end if
      status = 0
      daily = istass < itime
900   continue
    end associate
    if (runtime) status = agree_time_status(storage, status)
  end function
!> Complete the source daily chemistry and final gas update after daily climate.
  integer(int32) function finish_time_forcing_daily(storage, context, runtime, daily) result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    type(native_time_and_forcing_context), target, intent(inout) :: context
    logical, intent(in) :: runtime, daily
    status = 0
    if (daily) then
      if (storage%model%physics%ecmwf_physics%leo3ch) then
        status = update_native_ozone_chemistry(storage%model%initial%controls%clock, storage%model%dynamics, &
                                   storage%model%physics%ecmwf_physics, storage%model%physics_dimensions, context%ozone_chemistry, &
                                storage%model%initial%geometry%dimensions%nflevg, storage%model%initial%geometry%dimensions%nsmax, &
                                 storage%model%initial%geometry%dimensions%ndglg, storage%model%initial%geometry%dimensions%ndlon, &
                           storage%model%initial%geometry%configuration%nloeng(1:storage%model%initial%geometry%dimensions%ndglg), &
                                               .true., storage%model%initial%controls%clock%integration%first_step, &
                                               storage%model%initial%geometry%transform_control, trim(context%data_directory))
        if (status /= 0) goto 910
      end if
      status = update_native_clock_radiation_forcing(storage%model%dynamics, storage%ecmwf%radiation%radiation, &
                             storage%ecmwf%radiation%gases, storage%model%initial%controls%clock, storage%model%initial%constants, &
                 storage%ecmwf%radiation%climate, storage%model%initial%controls%clock%integration%first_step, .true., context%cmip)
    end if
910 continue
    if (runtime) status = agree_time_status(storage, status)
  end function
!> Public agreements add no scientific state or changed status flags.
  integer(int32) function agree_time_status(storage, local_status) result(status)
    type(native_selected_model_storage), intent(in) :: storage
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: saved
    integer(int32) :: saved_errno
    call save_lifetime_status(saved, saved_errno)
    status = agree_distributed_partition_status(storage%model%initial%geometry%transform_control, local_status)
    call restore_lifetime_status(saved, saved_errno)
  end function
!> Check the exact source specialization before its first numerical write.
!! The native clock producer supplies the source LASTRF=false standard epoch.
  integer(int32) function time_forcing_admission(storage, step, tdt, tstep, context, runtime) result(status)
    type(native_selected_model_storage), target, intent(in) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tdt, tstep
    type(native_time_and_forcing_context), intent(in) :: context
    logical, intent(in) :: runtime
    status = 2
    if (.not. associated(storage%model%initial)) return
    if (.not. allocated(storage%model%initial%geometry)) return
    if (.not. associated(storage%model%initial%geometry%vertical)) return
    if (.not. model_parameter_aliases_match(storage)) return
    if (.not. associated(context%lscmec) .or. .not. associated(context%lrlxg)) return
    if (context%lscmec .or. context%lrlxg) return
    if (.not. associated(context%surface_arrays) .or. .not. associated(context%surface_catalog)) return
    if (storage%linear_model .or. storage%model%nudging%lnudg) return
    if (storage%model%dynamical_core%lape /= 0) return
    if (storage%model%initial%controls%namespace%nconf /= 1 .or. storage%model%nsupersede /= 1) return
    if (storage%model%initial%controls%namespace%l4dvar /= 0 .or. storage%model%initial%controls%namespace%l_oops /= 0) return
    if (storage%model%initial%controls%clock%control /= 0) return
    if (.not. finite_positive(tdt, 86400.0_real64) .or. .not. finite_positive(tstep, 86400.0_real64)) return
    if (.not. allocated(storage%ecmwf%radiation%climate)) return
    if (.not. storage%ecmwf%setup_complete .or. .not. storage%ecmwf%radiation%setup_complete) return
    if (storage%model%initial%constants%rpi /= 3.141592653589793_real64) return
    if (storage%model%initial%constants%rday /= 86400.0_real64) return
    if (storage%model%initial%constants%rea /= 149597870000.0_real64) return
    if (storage%model%initial%constants%repsm /= 0.409093_real64) return
    if (.not. allocated(storage%model%initial%geometry%configuration%nloeng)) return
    if (lbound(storage%model%initial%geometry%configuration%nloeng, 1) > 1) return
    if (ubound(storage%model%initial%geometry%configuration%nloeng, 1) < storage%model%initial%geometry%dimensions%ndglg) return
    if (context%cmip%no3cmip /= 0) return
    if (runtime) then
    if (storage%model%initial%geometry%dimensions%nsmax /= 1279 .or. storage%model%initial%geometry%dimensions%nflevg /= 137) return
      if (storage%model%initial%geometry%dimensions%nproma < 1 .or. storage%model%initial%geometry%dimensions%nproma > 1024) return
      if (.not. storage%model%initial%geometry%transform_control%message_ready) return
     if(storage%model%initial%geometry%transform_control%nproc<1.or.storage%model%initial%geometry%transform_control%nproc>32)return
      if (storage%model%initial%controls%clock%initial_seconds_j2000 /= 835272000.0_real64) return
      if (tstep /= 450.0_real64 .or. storage%model%initial%controls%clock%integration%first_dt /= 450.0_real64) return
    if(storage%model%initial%controls%clock%initial_date/=20260621.or.storage%model%initial%controls%clock%initial_seconds/=0)return
 if(storage%model%initial%controls%clock%integration%total_steps<0.or.storage%model%initial%controls%clock%integration%total_steps>575)return
      if (step < 0 .or. step > storage%model%initial%controls%clock%integration%total_steps + 1) return
      if (storage%model%fields%alias_controls%naero /= 0_int32) return
      if (.not. storage%model%dynamics%ltwotl) return
      if (.not. storage%model%physics%ecmwf_physics%lephys) return
      if (.not. storage%model%physics%ecmwf_physics%lneeonline) return
      if (.not. storage%ecmwf%radiation%radiation%lmannersswupdate) return
      if (.not. storage%ecmwf%radiation%radiation%lcentredtimesza) return
      if (.not. storage%ecmwf%radiation%radiation%leco2var) return
      if (.not. storage%ecmwf%radiation%radiation%lhghg) return
      if (.not. storage%ecmwf%radiation%radiation%lnewaer) return
      if (storage%ecmwf%radiation%radiation%naermacc /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%nghgrad /= 20_int32) return
      if (storage%ecmwf%radiation%radiation%nhincsol /= 4_int32) return
      if (storage%ecmwf%radiation%radiation%nozocl /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%nradfr /= 8_int32) return
      if (storage%ecmwf%radiation%radiation%nradnfr /= 8_int32) return
      if (storage%ecmwf%radiation%radiation%nradsfr /= 8_int32) return
      if (storage%ecmwf%radiation%radiation%lerad1h) return
      if (storage%ecmwf%radiation%radiation%leso4his) return
      if (storage%ecmwf%radiation%radiation%lhvolca) return
      if (storage%ecmwf%radiation%radiation%lperpet) return
      if (storage%ecmwf%radiation%radiation%nradelg /= 0_int32) return
      if (.not. storage%ecmwf%radiation%radiation%laer3d) return
      if (storage%ecmwf%radiation%ultraviolet%luvproc) return
      if (storage%model%physics%linear_ecmwf%lphylin) return
      if (.not. storage%model%physics%ecmwf_physics%leo3ch) return
      if (storage%model%physics%ecmwf_physics%leocml) return
      if (storage%model%physics%ecmwf_physics%locmltke) return
      if (storage%model%climate%lmcc01) return
      if (storage%model%climate%lmcc01_mse) return
      if (storage%model%climate%lmcc03) return
      if (storage%model%climate%lmcc04) return
      if (storage%model%climate%lmcc05) return
      if (storage%model%climate%lmcc_compo) return
      if (storage%model%physics%phy%lmphys) return
      if (storage%model%physics%simplified_physics%lsimph) return
      if (storage%model%physics%phy%lrayfm15) return
      if (storage%model%physics%phy%lraylu) return
      if (storage%model%physics%phy%lrmu0m) return
      if (storage%model%physics%arpege_physics%lmse) return
      if (context%cmip%no3cmip /= 0_int32) return
    else
      if (storage%model%initial%geometry%dimensions%nsmax /= 21 .or. storage%model%initial%geometry%dimensions%nflevg /= 19) return
      if (tstep /= 3600.0_real64 .or. storage%model%initial%controls%clock%integration%first_dt /= 3600.0_real64) return
      if (step < 0 .or. step > 25) return
      if (storage%model%fields%alias_controls%naero /= 0_int32) return
      if (.not. storage%model%dynamics%ltwotl) return
      if (.not. storage%model%physics%ecmwf_physics%lephys) return
      if (.not. storage%model%physics%ecmwf_physics%lneeonline) return
      if (.not. storage%ecmwf%radiation%radiation%lmannersswupdate) return
      if (.not. storage%ecmwf%radiation%radiation%lcentredtimesza) return
      if (.not. storage%ecmwf%radiation%radiation%leco2var) return
      if (.not. storage%ecmwf%radiation%radiation%lhghg) return
      if (.not. storage%ecmwf%radiation%radiation%lnewaer) return
      if (storage%ecmwf%radiation%radiation%naermacc /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%nghgrad /= 21_int32) return
      if (storage%ecmwf%radiation%radiation%nhincsol /= 4_int32) return
      if (storage%ecmwf%radiation%radiation%nozocl /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%nradfr /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%nradnfr /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%nradsfr /= 1_int32) return
      if (storage%ecmwf%radiation%radiation%lerad1h) return
      if (storage%ecmwf%radiation%radiation%leso4his) return
      if (storage%ecmwf%radiation%radiation%lhvolca) return
      if (storage%ecmwf%radiation%radiation%lperpet) return
      if (storage%ecmwf%radiation%radiation%nradelg /= 0_int32) return
      if (storage%ecmwf%radiation%radiation%laer3d) return
      if (storage%ecmwf%radiation%ultraviolet%luvproc) return
      if (storage%model%physics%linear_ecmwf%lphylin) return
      if (storage%model%physics%ecmwf_physics%leo3ch) return
      if (storage%model%physics%ecmwf_physics%leocml) return
      if (storage%model%physics%ecmwf_physics%locmltke) return
      if (storage%model%climate%lmcc01) return
      if (storage%model%climate%lmcc01_mse) return
      if (storage%model%climate%lmcc03) return
      if (storage%model%climate%lmcc04) return
      if (storage%model%climate%lmcc05) return
      if (storage%model%climate%lmccec) return
      if (storage%model%climate%lmcc_compo) return
      if (storage%model%physics%phy%lmphys) return
      if (storage%model%physics%simplified_physics%lsimph) return
      if (storage%model%physics%phy%lrayfm) return
      if (storage%model%physics%phy%lrayfm15) return
      if (storage%model%physics%phy%lraylu) return
      if (storage%model%physics%phy%lrmu0m) return
      if (storage%model%physics%arpege_physics%lmse) return
      if (context%cmip%no3cmip /= 0_int32) return
    end if
    status = 0
  end function
  logical function finite_positive(value, maximum) result(ok)
    real(real64), intent(in) :: value, maximum
    integer(int64) :: bits
    bits = transfer(value, bits); ok = .false.
    if (btest(bits, 63) .or. bits == 0 .or. ibits(bits, 52, 11) == 2047) return
    if (value > maximum) return
    ok = .true.
  end function
end module
