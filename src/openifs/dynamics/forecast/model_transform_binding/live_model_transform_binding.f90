!> Bind the real model transform views at their final native addresses.
!! This support entry allocates no field and performs no numerical calculation.
module forecast_live_model_transform_binding
  use iso_fortran_env, only: int32, int64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_native_loop_data, only: native_loop_data
  use spectral_field_storage_port, only: spectral_field_state
  use md2asm_model_transform_callers, only: model_transform_context, model_transform_state
  implicit none
  private
  public :: bind_live_model_transform_state, detach_live_model_transform_state
contains
  !> Borrow initialized geometry, motion, spectral and loop-data owners.
  !! MODEL and SPECTRAL are stable TARGET records through the final transform.
  !! The field order is the source TYPE_GMVS YT0/YT1 order. Spectral views use
  !! their existing named VOR,DIV,SP,SCAL pointers. The nonpressure SP target is
  !! the source one-word dummy; no pressure field is invented on that rank.
  !! WORK_BYTES is an admitted byte capacity for the transform's private work.
  !! HYDROSTATIC_DIAGNOSTICS comes from its actual diagnostic setup producer.
  !! This current runtime route requires hydrostatic equations, no spectral
  !! tracers, no pressure-gradient filtering and an unsplit public transform.
  !! Failure leaves both output descriptors unchanged. Status is0 or2.
  integer(int32) function bind_live_model_transform_state(model, spectral, loop_data, work_bytes, &
                                                          hydrostatic_diagnostics, context, fields) result(status)
    type(native_operational_model_configuration), target, intent(inout) :: model
    type(spectral_field_state), target, intent(inout) :: spectral
    type(native_loop_data), target, intent(in) :: loop_data
    integer(int64), intent(in) :: work_bytes
    logical, intent(in) :: hydrostatic_diagnostics
    type(model_transform_context), intent(inout) :: context
    type(model_transform_state), intent(inout) :: fields
    type(model_transform_context) :: pending
    type(model_transform_state) :: views
    integer(int32) :: p, l, q, b, c, v, owner
    status = 2
    if (associated(context%level_partition)) return
    if (associated(fields%vorticity) .or. associated(fields%divergence) .or. associated(fields%log_pressure)) return
    if (associated(fields%thermodynamic) .or. associated(fields%current_grid) .or. associated(fields%previous_grid)) return
    if (associated(fields%current_surface) .or. associated(fields%previous_surface)) return
    if (associated(fields%gradient_vorticity) .or. associated(fields%gradient_divergence)) return
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready .or. .not. allocated(model%initial%geometry)) return
    if (.not. model%initial%geometry%initialized .or. .not. spectral%ready) return
    if (.not. associated(model%partition, model%initial%geometry%partition)) return
    if (model%partition%phase /= 7) return
    if (.not. model%initial%geometry%transform_control%environment_ready) return
    if (model%initial%geometry%transform_resolution%resolution < 1) return
    if (model%dynamics%lnhdyn .or. model%lrsiddh .or. hydrostatic_diagnostics) return
    if (model%dynamics%lgradsp .or. loop_data%npromatr > 0) return
    if (model%fields%registration%numspflds /= 0 .or. model%field_dimensions%nfther /= 1) return
    if (work_bytes < 1_int64 .or. work_bytes > 2_int64**36) return
    p = model%initial%geometry%dimensions%nproma
    l = model%initial%geometry%dimensions%nflevg
    q = model%partition%ngptot; b = model%partition%ngpblks
    c = model%partition%nspec2; v = model%partition%nflevl
    if (p < 1 .or. l < 1 .or. l > 512 .or. q < 1 .or. c < 0 .or. v < 0 .or. v > l) return
    if (int(b, int64) /= (int(q, int64) + p - 1_int64)/p) return
    if (.not. allocated(model%partition%nbsetlev)) return
    if (size(model%partition%nbsetlev) /= l) return
    if (.not. allocated(model%motion%gmv) .or. .not. allocated(model%motion%gmvs)) return
    if (.not. allocated(model%motion%gmvt1) .or. .not. allocated(model%motion%gmvt1s)) return
    if (any(shape(model%motion%gmv) /= [p, l, model%motion%ndimgmv, b])) return
    if (any(shape(model%motion%gmvs) /= [p, model%motion%ndimgmvs, b])) return
    if (size(model%motion%gmvt1, 1) /= p .or. size(model%motion%gmvt1, 2) /= l .or. size(model%motion%gmvt1, 4) /= b) return
    if (size(model%motion%gmvt1s, 1) /= p .or. size(model%motion%gmvt1s, 3) /= b) return
    if (model%motion%yt0%ndimuv < 2 .or. model%motion%yt0%ndimuv > model%motion%yt0%ndim) return
    if (model%motion%yt0%ndim > size(model%motion%gmv, 3)) return
    if (model%motion%yt0%ndims < 1 .or. model%motion%yt0%ndims > size(model%motion%gmvs, 2)) return
    if (model%motion%yt1%ndim < 2 .or. model%motion%yt1%ndim > size(model%motion%gmvt1, 3)) return
    if (model%motion%yt1%ndims < 1 .or. model%motion%yt1%ndims > size(model%motion%gmvt1s, 2)) return
    if (model%motion%yt0%mu < 1 .or. model%motion%yt0%mv < model%motion%yt0%mu) return
    if (model%motion%yt0%mv > model%motion%yt0%ndimuv) return
    if (.not. associated(spectral%vor) .or. .not. associated(spectral%div)) return
    if (.not. associated(spectral%sp) .or. .not. associated(spectral%scal)) return
    if (any(shape(spectral%vor) /= [v, c]) .or. any(shape(spectral%div) /= [v, c])) return
    if (any(shape(spectral%scal) /= [v, c, 1])) return
    owner = model%partition%nbsetsp
    if (owner < 1 .or. owner > model%initial%geometry%transform_control%nprtrv) return
    if (model%initial%geometry%transform_control%mysetv == owner) then
      if (size(spectral%sp) /= c) return
    else
      if (size(spectral%sp) /= 1) return
    end if
    pending%transform%resolution = model%initial%geometry%transform_resolution%resolution
    pending%transform%block_rows = p
    pending%transform%processes = model%initial%geometry%transform_control%nproc
    pending%transform%split_fields = loop_data%npromatr
    pending%transform%latitude_longitude = model%initial%controls%namespace%lelam /= 0
    pending%global_levels = l; pending%local_points = q
    pending%pressure_partition = owner
    pending%vertical_partition = model%initial%geometry%transform_control%mysetv
    pending%step = model%initial%controls%clock%current_step
    pending%current_wind_fields = model%motion%yt0%ndimuv
    pending%current_volume_fields = model%motion%yt0%ndim
    pending%current_surface_fields = model%motion%yt0%ndims
    pending%previous_volume_fields = model%motion%yt1%ndim
    pending%previous_surface_fields = model%motion%yt1%ndims
    pending%current_u = model%motion%yt0%mu; pending%current_v = model%motion%yt0%mv
    pending%gradient_fields = [model%motion%yt9%msgrtl, model%motion%yt9%msgrtm, &
                               model%motion%yt0%msgrtl, model%motion%yt0%msgrtm]
    pending%spectral_tracers = model%fields%registration%numspflds
    pending%pressure_gradients = model%dynamics%lgradsp
    pending%gradient_volume_fields = model%dynamics%lgradsp
    pending%nonhydrostatic = model%dynamics%lnhdyn
    pending%semiimplicit_diagnostics = model%lrsiddh
    pending%hydrostatic_diagnostics = hydrostatic_diagnostics
    pending%workspace_budget = work_bytes; pending%level_partition => model%partition%nbsetlev
    views%vorticity => spectral%vor; views%divergence => spectral%div
    views%log_pressure => spectral%sp; views%thermodynamic => spectral%scal
    views%current_grid => model%motion%gmv; views%current_surface => model%motion%gmvs
    views%previous_grid => model%motion%gmvt1; views%previous_surface => model%motion%gmvt1s
    context = pending; fields = views
    status = 0
  end function
  !> Detach views before releasing their borrowed model or spectral owner.
  subroutine detach_live_model_transform_state(context, fields)
    type(model_transform_context), intent(inout) :: context
    type(model_transform_state), intent(inout) :: fields
    nullify (context%level_partition)
    nullify (fields%vorticity, fields%divergence, fields%log_pressure, fields%thermodynamic)
    nullify (fields%current_grid, fields%current_surface, fields%previous_grid, fields%previous_surface)
    nullify (fields%gradient_vorticity, fields%gradient_divergence)
  end subroutine
end module forecast_live_model_transform_binding
