!> Compose FULLPOS_DRV, ALLFPOS and the scalar FPTSA copy.
submodule(forecast_output_controller) forecast_output_controller_implementation
  use iso_c_binding, only: c_null_ptr, c_loc
  use forecast_output_request_types
  use forecast_output_request_preparation, only: prepare_output_requests
  use forecast_output_header_and_auxiliary, only: initialize_output_header, initialize_output_auxiliary
  use forecast_output_request_selection, only: scan_output_metadata, construct_output_request_metadata
  use forecast_output_request_storage, only: release_fullpos_requests, release_output_header
  use forecast_output_request_views, only: native_output_io_views, output_io_views
  use forecast_output_grid_calculations, only: calculate_output_grid_fields
  use forecast_pressure_output_controller, only: write_pressure_output
  use forecast_model_level_field_output, only: write_model_level_output
  use forecast_output_norm_dispatch, only: dispatch_output_norms
  use md2asm_scalar_output_transform_caller, only: scalar_output_request, transdir_fp
  use type_fpofn, only: tfpofn
  use yomhook, only: dr_hook
  implicit none
  interface
    subroutine gstats(identifier, position)
      import int32
      integer(int32), intent(in) :: identifier, position
    end subroutine
  end interface
contains
  !> Execute source order with the actual root clock and named field owners.
  !! Requests and temporary output arrays are locally owned. Existing native
  !! children own every calculation, transform, encoding and file stage.
  !! Active selected output requires T21/L19/world1 and the matching public
  !! transform handle. No actual T1279 encoding admission is claimed.
  module procedure execute_fullpos_driver
  type(tfpfields) :: fields
  type(trqfp), target :: physical
  type(trqfpdyn), target :: dynamic
  real(real64) :: hook
  real(real64), volatile :: elapsed_work
  integer(int32), volatile :: elapsed_seconds
  integer(int32) :: cleanup_status, levels
  logical :: event29, event1776, profile_open
  status = 2
  event29 = .false.; event1776 = .false.; profile_open = .false.
  if (lag < 0 .or. lag > 2) return
  if (fullpos%yfpcnt%nfpconf /= 0 .or. fullpos%yfpgeometry%lfposhor) return
  if (.not. associated(context%model) .or. .not. associated(context%common)) return
  if (.not. associated(context%model%initial)) return
  if (.not. allocated(context%model%initial%geometry)) return
  if (.not. associated(context%model%initial%geometry%vertical)) return
  if (context%preparation_policy%larpegef) return
  if (size(physical_codes) /= 1639) return
  levels = context%model%initial%geometry%vertical%levels
  if (context%hook_enabled) then
    call dr_hook('FULLPOS_DRV', 0, hook)
    profile_open = .true.
  end if
  call gstats(29_int32, 0_int32); event29 = .true.
  elapsed_work = real(context%model%initial%controls%clock%current_step, real64)* &
                 context%model%initial%controls%clock%dt
  elapsed_work = elapsed_work + 0.5_real64
  elapsed_seconds = int(elapsed_work, int32)
  status = prepare_output_requests(fullpos, levels, context%preparation_policy, context%nfpos, &
                                   context%grib_file_count, context%common, fields, physical, dynamic, context%service_counters)
  if (status /= 0) goto 900
  if (physical%nfieldg /= 0) then
    status = 2
    goto 900
  end if
  physical_count = physical%nfieldg
  call gstats(29_int32, 1_int32); event29 = .false.
  call gstats(1776_int32, 0_int32); event1776 = .true.
  status = initialize_output_auxiliary(fullpos, context%model%initial%geometry%transform_resolution%resolution, &
                                       data, lag, context%common%lfpmois, context%model%initial%controls%clock%initial_date, &
                                       context%update_date, context%service_counters)
  if (status /= 0) goto 900
  status = execute_allfpos(context, data, physical, dynamic, lag >= 2, delay .and. ocean)
900 continue
  if (event29) call gstats(29_int32, 1_int32)
  if (event1776) call gstats(1776_int32, 1_int32)
  cleanup_status = release_fullpos_requests(fields, physical, dynamic, context%service_counters)
  if (status == 0) status = cleanup_status
  if (profile_open) call dr_hook('FULLPOS_DRV', 1, hook)
  if (status == 0) call increment_output_counter(context%driver_calls)
  end procedure

  integer(int32) function execute_allfpos(context, data, physical, dynamic, lagged, ocean) result(status)
    type(native_fullpos_driver_context), intent(inout) :: context
    type(native_fullpos_data), intent(inout) :: data
    type(trqfp), target, intent(in) :: physical
    type(trqfpdyn), target, intent(in) :: dynamic
    logical, intent(in) :: lagged, ocean
    type(native_fullpos_state), pointer :: fullpos
    type(type_fprqdyn) :: request
    type(trqfp), target :: spectral_request, grid_request
    type(fposbuf) :: header
    type(tfpofn), target :: names
    type(native_output_io_views) :: io_views
    type(scalar_output_request) :: transform_request
    real(real64), pointer :: levels(:)
    real(real64), allocatable :: fit(:, :, :), auxiliary(:, :, :), source_spectrum(:, :), target_spectrum(:, :)
    integer(int32), allocatable :: block_ends(:)
    integer(int32), target :: step
    real(real64), target :: dt
    integer(int32) :: scan, level_count, width, blocks, words, points, cleanup_status
    integer :: allocation_status, b, alias, water
    integer(int32) :: aliases(6)
    real(real64) :: hook, copy_hook
    logical :: include_surface, profile_open, scan_open, event_copy
    status = 2; nullify (levels); profile_open = .false.; scan_open = .false.; event_copy = .false.
    if (.not. associated(data%yfpos)) return
    fullpos => data%yfpos
    step = context%model%initial%controls%clock%current_step
    dt = context%model%initial%controls%clock%dt
    if (context%hook_enabled) then
      call dr_hook('ALLFPOS', 0, hook); profile_open = .true.
    end if
    status = initialize_output_header(fullpos, physical, step, names, header, dynamic, .false., &
                                      context%time_format, context%service_counters)
    if (status /= 0) goto 900
    if (lagged .or. ocean) goto 800
    include_surface = .true.
    do scan = 1, 7
      if (scan == 5 .and. fullpos%yfpcnt%nfpconf == 0 .and. &
          .not. context%preparation_policy%larpegef .and. .not. fullpos%yfpgeometry%lfposhor) &
        include_surface = .true.
      level_count = 0
      status = scan_output_metadata(fullpos, dynamic, request, spectral_request, grid_request, scan, &
                                    include_surface, level_count, levels, .false., &
                                    context%model%initial%geometry%transform_control%nprtrv, &
                                    context%model%initial%geometry%transform_control%mysetv, [.false.], context%service_counters)
      scan_open = .true.
      if (status /= 0) goto 900
      if (request%nfpdynb > 0) then
        status = 2
        if (scan /= 1 .and. scan /= 5) goto 900
        if (request%ifit /= 2 .or. request%nfpvec /= 0 .or. request%nfpvecg /= 0) goto 900
        if (request%nfpgt1 < 0 .or. request%nfpgt1 > 39 .or. request%nfpauxb < 0 .or. request%nfpauxb > 39) goto 900
        if (request%nfpsca /= request%nfpspb) goto 900
        if (.not. associated(levels)) goto 900
        if (.not. associated(context%model_fields)) goto 900
        if (.not. associated(context%model_fields%state_model, context%model)) goto 900
        if (.not. associated(context%model_fields%grid_fields)) goto 900
        if (.not. allocated(context%model_fields%grid_fields%gfl)) goto 900
        if (.not. allocated(context%model%motion%gmv) .or. .not. allocated(context%model%motion%gmvs)) goto 900
        width = size(context%model%motion%gmv, 1)
        blocks = size(context%model%motion%gmv, 4)
        points = context%model%initial%geometry%partition%ngptot
        words = context%model%initial%geometry%partition%nspec2
        if (width /= 24 .or. blocks /= 86 .or. points /= 2048 .or. words /= 506) goto 900
        if (context%model%initial%geometry%vertical%levels /= 19) goto 900
        if (context%model%initial%geometry%transform_resolution%truncation /= 21) goto 900
        if (context%model%initial%geometry%transform_resolution%resolution /= 1) goto 900
        if (context%model%initial%geometry%transform_control%nproc /= 1) goto 900
        context%grid_sources%geometry => context%model%initial%geometry
        context%grid_sources%motion => context%model%motion
        context%grid_sources%constants => context%model%initial%constants
        context%grid_sources%constituents => context%model_fields%grid_fields%gfl
        aliases = [context%model%fields%aliases%yq, context%model%fields%aliases%yl, &
                   context%model%fields%aliases%yi, context%model%fields%aliases%yr, &
                   context%model%fields%aliases%ys, context%model%fields%aliases%yg]
        do water = 1, 6
          alias = aliases(water)
          if (alias < 1 .or. alias > size(context%model%fields%components)) goto 900
          context%grid_sources%water_enabled(water) = context%model%fields%components(alias)%lthermact /= 0
          if (water <= 5) context%grid_sources%constituent_index(water) = context%model%fields%components(alias)%mp
        end do
        allocate (fit(width, request%nfpgt1, blocks), stat=allocation_status)
        if (allocation_status /= 0) goto 700
        allocate (auxiliary(width, request%nfpauxb, blocks), stat=allocation_status)
        if (allocation_status /= 0) goto 700
        allocate (source_spectrum(request%nfpsca, words), stat=allocation_status)
        if (allocation_status /= 0) goto 700
        allocate (target_spectrum(request%nfpspb, words), stat=allocation_status)
        if (allocation_status /= 0) goto 700
        status = calculate_output_grid_fields(request, context%grid_sources, levels, scan, fit, auxiliary, &
                                              context%view_counters, context%grid_calculation_calls)
        if (status /= 0) goto 900
        if (request%nfpgt1 > 0) then
          transform_request%nfpscag = request%nfpscag
          transform_request%nfpvecg = request%nfpvecg
          call transdir_fp(transform_request, fit, source_spectrum, context%transform_counters, status)
          if (status /= 0) goto 900
          call gstats(1992_int32, 0_int32); event_copy = .true.
          if (context%hook_enabled) call dr_hook('FPTSA_DIR', 0, copy_hook)
          do b = 1, words
            do alias = 1, request%nfpsca
              target_spectrum(alias, b) = source_spectrum(alias, b)
            end do
          end do
          if (context%hook_enabled) call dr_hook('FPTSA_DIR', 1, copy_hook)
          call increment_output_counter(context%scalar_copy_calls)
          call gstats(1992_int32, 1_int32); event_copy = .false.
        end if
        status = construct_output_request_metadata(fullpos, request, spectral_request, grid_request, scan, &
                                                   level_count, levels, context%service_counters)
        if (status /= 0) goto 900
        status = output_io_views(fullpos, c_loc(context%model%initial%geometry), &
                                 c_loc(context%model%surface_controls), c_loc(context%model_fields%ecphysics), &
                                 c_loc(context%model%physics), physical, names, step, dt, io_views, context%view_counters)
        if (status /= 0) goto 900
        context%writer_inputs%geometry => context%model%initial%geometry
        context%writer_inputs%clock => context%model%initial%controls%clock
        if (scan == 5) then
          status = write_model_level_output(spectral_request, grid_request, target_spectrum, auxiliary, &
                                            words, points, width, names%csh, names%cua, context%writer, context%writer_inputs, &
                                            context%writer_policy, context%io_service, context%split_output, context%hook_enabled, &
                                            'm', ocean, lagged, physical%nfieldg)
        else
          status = write_pressure_output(spectral_request, grid_request, target_spectrum, auxiliary, &
                                         words, points, width, names%csh, names%cua, context%writer, context%writer_inputs, &
                                         context%writer_policy, context%io_service, context%split_output, context%hook_enabled, 'p')
        end if
        if (status /= 0) goto 900
        allocate (block_ends(blocks), stat=allocation_status)
        if (allocation_status /= 0) goto 700
        do b = 1, blocks
          block_ends(b) = min(width, points - (b - 1)*width)
        end do
        status = dispatch_output_norms(context%norm_context, context%norm_results, spectral_request, &
                                       grid_request, target_spectrum, auxiliary, context%norm_partition, block_ends, &
                                    context%norm_chunk_size, scan, context%model%initial%geometry%transform_resolution%resolution, &
                                 context%model%initial%geometry%partition%ngptotg, context%domain_name, context%norm_dispatch_calls)
        deallocate (block_ends)
        if (status /= 0) goto 900
        deallocate (fit); deallocate (auxiliary); deallocate (source_spectrum); deallocate (target_spectrum)
      end if
      status = scan_output_metadata(fullpos, dynamic, request, spectral_request, grid_request, scan, &
                                    include_surface, level_count, levels, .true., &
                                    context%model%initial%geometry%transform_control%nprtrv, &
                                    context%model%initial%geometry%transform_control%mysetv, [.false.], context%service_counters)
      scan_open = .false.
      if (status /= 0) goto 900
      include_surface = .false.
    end do
800 status = 0
    goto 900
700 status = 1
900 continue
    if (event_copy) call gstats(1992_int32, 1_int32)
    if (allocated(fit)) deallocate (fit)
    if (allocated(auxiliary)) deallocate (auxiliary)
    if (allocated(source_spectrum)) deallocate (source_spectrum)
    if (allocated(target_spectrum)) deallocate (target_spectrum)
    if (allocated(block_ends)) deallocate (block_ends)
    if (scan_open) then
      cleanup_status = scan_output_metadata(fullpos, dynamic, request, spectral_request, grid_request, scan, &
                                            include_surface, level_count, levels, .true., &
                                            context%model%initial%geometry%transform_control%nprtrv, &
                                       context%model%initial%geometry%transform_control%mysetv, [.false.], context%service_counters)
    end if
    cleanup_status = release_output_header(header, context%service_counters)
    if (status == 0) status = cleanup_status
    if (profile_open) call dr_hook('ALLFPOS', 1, hook)
    if (status == 0) call increment_output_counter(context%allfpos_calls)
  end function
end submodule
