!> Release the actual native forecast execution owner in source order.
!! One allocatable TARGET retains every canonical owner until all borrowers end.
!! Each child keeps its natural status and its existing acquired-prefix policy.
module forecast_selected_bootstrap_release
  use iso_fortran_env, only: int32
  use forecast_native_execution_state, only: native_forecast_execution_state
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_runtime_event_tables, only: release_runtime_forecast_events
  use forecast_actual_output_lifetime, only: release_actual_output_runtime
  use forecast_native_gp_input_factory, only: release_native_gp_input_factory
  use forecast_grid_storage, only: release_forecast_grid_work
  use forecast_interpolation_coefficient_tables, only: release_interpolation_coefficient_tables
  use forecast_interpolation_buffer_setup, only: release_distributed_interpolation_buffer
  use forecast_runtime_fullpos_factory, only: release_runtime_fullpos_factory
  use forecast_spectral_setup_state, only: release_native_spectral_calculation_state
  use forecast_dynamical_diagnostic_storage, only: release_dynamical_diagnostic_storage
  use forecast_disabled_stochastic_patterns, only: release_disabled_sppt_setup
  use forecast_native_flux_controls, only: release_native_forecast_flux_controls
  use forecast_owned_ecmwf_physics_setup_native_clock_waves, only: release_owned_ecmwf_physics_from_native_clock
  use forecast_owned_radiation_setup_from_native_clock, only: release_owned_actual_radiation_setup
  use forecast_selected_field_container_attachment, only: release_selected_field_containers
  use forecast_registry_release, only: release_registry_graph
  use forecast_attached_field_container, only: attached_field_container_is_empty
  use forecast_ecmwf_physics_fields, only: release_runtime_ecmwf_physics_fields
  use forecast_selected_bootstrap_startup, only: release_native_forecast_startup_storage
  implicit none
  private
  public :: release_selected_bootstrap_execution
  interface
    function execution_release_errno_address() bind(c, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Close only genuine acquired resources and retire the final owner on success.
 !! OUTPUT is the unique allocatable TARGET execution state. It must be outside
 !! all forecast calls. An absent owner succeeds. Return zero means complete
 !! release; a nonzero natural child status leaves remaining owners for retry.
 !! No weather data, clock or configuration is recreated. The complete incoming
 !! IEEE status and errno are restored on every path that can mutate an owner.
  function release_selected_bootstrap_execution(output) result(status)
    type(native_forecast_execution_state), allocatable, target, intent(inout) :: output
    integer(int32) :: status
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: allocation_status
    integer(int32) :: radiation_status
    status = 0
    if (.not. allocated(output)) return

    ! The real retained-transport busy flag is checked before any live view ends.
    status = 2
    if (output%gp_work%retained%busy) return
    if (allocated(output%fullpos)) then
      if (.not. allocated(output%startup)) return
      if (.not. allocated(output%startup%initial)) return
      if (.not. allocated(output%startup%initial%geometry)) return
    end if
    ! Preserve the actual Fullpos foreign-owner admission before output cleanup
    ! clears DATA%YFPOS. No foreign state is released through this enclosing owner.
    if (associated(output%fullpos_data%yfpos)) then
      if (.not. allocated(output%fullpos)) return
      if (.not. associated(output%fullpos_data%yfpos, output%fullpos)) return
    end if
    if (allocated(output%startup)) then
      if (associated(output%startup%loaded%fields)) then
        ! The actual GP/registry factory acquires T1,T0,T9 only. PC/PT stay absent.
        ! A different stage must release any separately acquired PC/PT owners.
        if (.not. attached_field_container_is_empty(output%startup%loaded%fields%field_pc)) return
        if (.not. attached_field_container_is_empty(output%startup%loaded%fields%field_pt)) return
      end if
    end if

    call ieee_get_status(saved_status)
    call c_f_pointer(execution_release_errno_address(), error_number)
    saved_errno = error_number
    cleanup: block
      call retire_execution_controller_views(output)
      status = release_runtime_forecast_events(output%loop%events)
      if (status /= 0) exit cleanup
      status = release_actual_output_runtime(output%scan%output%driver, output%fullpos_data)
      if (status /= 0) exit cleanup

      call release_native_gp_input_factory(output%gp_work, output%grid, status)
      if (status /= 0) exit cleanup
      call retire_execution_physics_views(output)
      status = release_forecast_grid_work(output%grid_work)
      if (status /= 0) exit cleanup
      status = release_interpolation_coefficient_tables(output%interpolation_tables)
      if (status /= 0) exit cleanup
      if (allocated(output%startup)) then
        if (allocated(output%startup%loaded%storage)) then
          ! CVER is still the actual source selector. SL owns NSLMAP; RI/RO do not.
          status = release_distributed_interpolation_buffer(output%startup%loaded%storage%model%interpolation)
          if (status /= 0) exit cleanup
        end if
      end if

      if (allocated(output%fullpos)) then
        status = release_runtime_fullpos_factory(output%fullpos, output%fullpos_data, output%output_configuration, &
                                                 output%startup%initial%geometry%stream)
        if (status /= 0) exit cleanup
      end if
      call retire_execution_transform_views(output)
      call release_native_spectral_calculation_state(output%spectral_setup)
      call release_dynamical_diagnostic_storage(output%diagnostic_storage)
      ! Do not read unproduced SPPT source controls on an entirely fresh prefix.
      if (associated(output%sppt_data%ygpsdt) .or. associated(output%sppt_data%ygpsdt0) .or. &
          associated(output%sppt_data%ygpsdt1) .or. associated(output%sppt_data%nseed_sdt) .or. &
          associated(output%sppt_data%yspsdt_ar1)) then
        status = release_disabled_sppt_setup(output%sppt_configuration, output%sppt_data)
        if (status /= 0) exit cleanup
      end if
      status = release_native_forecast_flux_controls(output%flux_controls)
      if (status /= 0) exit cleanup
      if (allocated(output%rspongf)) then
        deallocate (output%rspongf, stat=allocation_status)
        status = int(allocation_status, int32)
        if (status /= 0) exit cleanup
      end if

      if (allocated(output%startup)) then
        if (allocated(output%startup%loaded%storage)) then
          status = release_owned_ecmwf_physics_from_native_clock(output%startup%loaded%storage%ecmwf, &
                                                                 output%startup%loaded%storage%model%physics)
          ! Early radiation preparation can acquire storage before the main
          ! RADIATION_ATTEMPTED flag. Always close that real prefix after SUPHEC,
          ! while retaining the first natural nonzero status of this cleanup pair.
          radiation_status = release_owned_actual_radiation_setup(output%startup%loaded%storage%ecmwf%radiation)
          if (status == 0) status = radiation_status
          if (status /= 0) exit cleanup
          ! All owned radiation resources have closed. Retire its borrowed
          ! setup context before the enclosing MODEL owner checks for live views.
          output%startup%loaded%storage%ecmwf%radiation%context_ready = .false.
        end if
        if (associated(output%startup%loaded%fields)) then
          status = release_selected_field_containers(output%startup%loaded%fields)
          if (status /= 0) exit cleanup
          status = release_registry_graph(output%startup%loaded%fields%registry%variables, &
                                          output%startup%loaded%fields%registry%surface)
          if (status /= 0) exit cleanup
          status = release_runtime_ecmwf_physics_fields(output%startup%loaded%fields%ecphysics)
          if (status /= 0) exit cleanup
        end if
      end if

      status = release_native_forecast_startup_storage(output%startup)
      if (status /= 0) exit cleanup
      deallocate (output, stat=allocation_status)
      status = int(allocation_status, int32)
    end block cleanup
    error_number = saved_errno
    call ieee_set_status(saved_status)
  end function release_selected_bootstrap_execution

  !> Retire the controller views without changing any pointed-to owner.
  subroutine retire_execution_controller_views(output)
    type(native_forecast_execution_state), target, intent(inout) :: output
    nullify (output%loop%storage)
    nullify (output%loop%input)
    nullify (output%loop%step)
    nullify (output%loop%forcing)
    nullify (output%loop%spectral_norms)
    nullify (output%loop%mass)
    nullify (output%loop%spectral_layout)
    nullify (output%loop%map_factor)
    nullify (output%loop%output)
    nullify (output%loop%fullpos)
    nullify (output%loop%fullpos_data)
    nullify (output%loop%physical_count)
    nullify (output%loop%physical_codes)
    nullify (output%loop%excluded)
    nullify (output%loop%loop_data)
    nullify (output%step%model)
    nullify (output%step%scan)
    nullify (output%step%transform)
    nullify (output%step%transform_fields)
    nullify (output%step%spectral)
    nullify (output%step%spectral_fields)
    nullify (output%step%excluded)
    nullify (output%step%inverse_flags)
    nullify (output%step%implicit_weights)
    nullify (output%step%loop_data)
    nullify (output%scan%model)
    nullify (output%scan%fields)
    nullify (output%scan%input)
    nullify (output%scan%scalars)
    nullify (output%scan%grid)
    nullify (output%scan%lfindvsep)
    nullify (output%scan%hook_control)
    nullify (output%scan%output%fields)
    nullify (output%scan%output%buffer)
    nullify (output%scan%output%physical_count)
    nullify (output%scan%output%physical_codes)
    nullify (output%physical_count)
    nullify (output%physical_codes)
  end subroutine

  !> Retire the physics views without changing any pointed-to owner.
  subroutine retire_execution_physics_views(output)
    type(native_forecast_execution_state), target, intent(inout) :: output
    ! The actual GP registry consumers have closed; these four views own no metadata.
    nullify (output%registry_aliases%phys)
    nullify (output%registry_aliases%tcghg)
    nullify (output%registry_aliases%tcchem)
    nullify (output%registry_aliases%aerodiag)
    nullify (output%physics%surface_variables)
    nullify (output%physics%physics)
    nullify (output%physics%runtime)
    nullify (output%physics%lnodryflx)
    nullify (output%physics%providers)
    nullify (output%physics%post_controls)
    nullify (output%physics%stochastic_physics)
    nullify (output%physics%rcovsr)
    nullify (output%physics%rsivsr)
    nullify (output%physics%latitude)
    nullify (output%physics%records%geometry)
    nullify (output%physics%records%variables)
    nullify (output%physics%records%motion)
    nullify (output%physics%records%surface_metadata)
    nullify (output%physics%records%model)
    nullify (output%physics%records%dimensions)
    nullify (output%physics%records%auxiliary)
    nullify (output%physics%records%surface)
    nullify (output%physics%records%radiation)
    nullify (output%physics%records%perturbation)
    nullify (output%physics%records%flux)
    nullify (output%physics%records%diagnostics)
    nullify (output%physics%records%surface_diagnostics)
    nullify (output%physics%records%auxiliary_local)
    nullify (output%physics%records%surface_local)
    nullify (output%physics%records%keys)
    nullify (output%physics%records%perturbation_local)
    nullify (output%physics%records%previous_state)
    nullify (output%physics%records%state_t0)
    nullify (output%physics%records%tendency_dyn)
    nullify (output%physics%records%tendency_cml)
    nullify (output%physics%records%state_tmp)
    nullify (output%physics%records%tendency_tmp)
    nullify (output%physics%records%tendency_vdf)
    nullify (output%physics%records%tendency_satadj)
    nullify (output%physics%records%tendency_loc)
    nullify (output%physics%records%configuration)
    nullify (output%physics%records%tendency_phy)
    nullify (output%physics%records%trajectory_primary)
    nullify (output%physics%records%trajectory_oops)
    nullify (output%physics%records%trajectory_physics)
    nullify (output%physics%arrays%pbup9)
    nullify (output%physics%arrays%pbvp9)
    nullify (output%physics%arrays%pbtp9)
    nullify (output%physics%arrays%pb2)
    nullify (output%physics%arrays%convectivity)
    nullify (output%physics%arrays%smos_observations)
    nullify (output%physics%arrays%smos_brightness)
    nullify (output%physics%arrays%smos_angle)
    nullify (output%physics%arrays%smos_faraday)
    nullify (output%physics%arrays%smos_geometry)
    nullify (output%physics%arrays%gflt1)
    nullify (output%physics%arrays%gfl)
    nullify (output%physics%arrays%gflslp)
    nullify (output%physics%arrays%phys_mwave)
    nullify (output%physics%arrays%saved_tendencies)
    nullify (output%physics%arrays%pbgflp9)
    nullify (output%physics%arrays%extra_dynamics)
    nullify (output%physics%arrays%coverage)
    nullify (output%physics%arrays%cgpp)
    nullify (output%physics%arrays%crec)
    nullify (output%physics%arrays%smap_observations)
    nullify (output%physics%arrays%smap_brightness)
    nullify (output%physics%arrays%smap_angle)
    nullify (output%physics%arrays%pgmvt1)
    nullify (output%physics%arrays%pgmv)
    nullify (output%physics%arrays%zgfl_dyn)
    nullify (output%physics%arrays%smos_keys)
    nullify (output%physics%arrays%smap_keys)
    nullify (output%physics%cellular%convective)
    nullify (output%physics%cellular%nonlinear)
    nullify (output%physics%cellular%cape)
    nullify (output%physics%solar_clock%tstep)
    nullify (output%physics%solar_clock%tdt)
    nullify (output%physics%solar_clock%rstati)
    nullify (output%physics%solar_clock%rcodec)
    nullify (output%physics%solar_clock%rsidec)
    nullify (output%physics%solar_clock%rwsovr)
    nullify (output%physics%solar_clock%rcodecm)
    nullify (output%physics%solar_clock%rsidecm)
    nullify (output%physics%solar_clock%rwsovrm)
    nullify (output%physics%solar_clock%nstart)
    nullify (output%physics%solar_clock%step)
    nullify (output%physics%solar_clock%initial_date)
    nullify (output%physics%solar_clock%initial_seconds)
    nullify (output%physics_factory%providers%physical)
    nullify (output%physics_factory%providers%thermal)
    nullify (output%physics_factory%providers%stability)
    nullify (output%physics_factory%providers%physics3)
    nullify (output%physics_factory%providers%stochastic_configuration)
    nullify (output%physics_factory%providers%current_step)
    nullify (output%physics_factory%providers%initial_step)
    nullify (output%physics_factory%providers%hook_enabled)
    nullify (output%physics_factory%providers%scmec_enabled)
    nullify (output%physics_factory%providers%rslwx)
    nullify (output%physics_factory%providers%chem_light_active)
    nullify (output%physics_factory%providers%runtime_scalars)
    nullify (output%physics_factory%providers%ozone_chemistry)
    nullify (output%physics_factory%providers%solar_declination)
    nullify (output%physics_factory%post_controls%rdtdz1)
    nullify (output%physics_factory%post_controls%rmdi)
    nullify (output%physics_factory%post_controls%nlextrap)
    nullify (output%physics_factory%post_controls%lecfpos)
    nullify (output%physics_factory%post_controls%lrsacc)
    nullify (output%physics_factory%post_controls%nfpphy)
    nullify (output%physics_factory%post_controls%no2dgg)
    nullify (output%physics_factory%post_controls%lrppuv_cstext)
    nullify (output%physics_factory%post_controls%lrppuv_callitpq)
    nullify (output%physics_factory%post_controls%mfpphy)
    nullify (output%physics_factory%post_controls%m2dggp)
    nullify (output%radiation%constants)
    nullify (output%radiation%thermal)
    nullify (output%radiation%configuration)
    nullify (output%radiation%setup)
    nullify (output%radiation%surface)
    nullify (output%radiation%surface_catalog)
    nullify (output%radiation%surface_parameters)
    nullify (output%radiation%legacy_radiation)
    nullify (output%radiation%physics_dimensions)
    nullify (output%radiation%cloud_parameters)
    nullify (output%radiation%pressure_controls)
    nullify (output%radiation%latitude_sine)
    nullify (output%radiation%longitude)
    nullify (output%radiation%orography)
    nullify (output%radiation%half_a)
    nullify (output%radiation%half_b)
    nullify (output%radiation%vc)
    nullify (output%radiation%full_a)
    nullify (output%radiation%full_b)
    nullify (output%radiation%delta_a)
    nullify (output%radiation%delta_b)
    nullify (output%radiation%thermal_constituents)
    nullify (output%radiation%longitude_cosine)
    nullify (output%radiation%longitude_sine)
    nullify (output%radiation%latitude_first)
    nullify (output%radiation%latitude_points)
    nullify (output%radiation%terrain)
    nullify (output%radiation%clock%tstep)
    nullify (output%radiation%clock%tdt)
    nullify (output%radiation%clock%rstati)
    nullify (output%radiation%clock%rcodec)
    nullify (output%radiation%clock%rsidec)
    nullify (output%radiation%clock%rwsovr)
    nullify (output%radiation%clock%rcodecm)
    nullify (output%radiation%clock%rsidecm)
    nullify (output%radiation%clock%rwsovrm)
    nullify (output%radiation%clock%nstart)
    nullify (output%radiation%clock%step)
    nullify (output%radiation%clock%initial_date)
    nullify (output%radiation%clock%initial_seconds)
    nullify (output%radiation%sea_ice%ice_thickness)
    nullify (output%radiation%sea_ice%snow_thickness)
    nullify (output%radiation%sea_ice%ice_albedo)
    nullify (output%radiation%sea_ice%sea_temperature)
    nullify (output%radiation%sea_ice%ice_temperature)
  end subroutine

  !> Retire the transform views without changing any pointed-to owner.
  subroutine retire_execution_transform_views(output)
    type(native_forecast_execution_state), target, intent(inout) :: output
    nullify (output%transform%level_partition)
    nullify (output%transform_fields%vorticity)
    nullify (output%transform_fields%divergence)
    nullify (output%transform_fields%log_pressure)
    nullify (output%transform_fields%thermodynamic)
    nullify (output%transform_fields%current_grid)
    nullify (output%transform_fields%current_surface)
    nullify (output%transform_fields%previous_grid)
    nullify (output%transform_fields%previous_surface)
    nullify (output%transform_fields%gradient_vorticity)
    nullify (output%transform_fields%gradient_divergence)
  end subroutine
end module forecast_selected_bootstrap_release
