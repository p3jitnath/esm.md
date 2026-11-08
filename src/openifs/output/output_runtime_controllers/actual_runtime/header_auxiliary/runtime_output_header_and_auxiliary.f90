!> Construct selected output names and auxiliary owners through native records.
!! Names contain256characters. Calendar dates use YYYYMMDD; model steps are counts.
!! The source omits the optional time-step argument in all three name calls.
module forecast_runtime_output_header_and_auxiliary
  use iso_fortran_env, only: int32, int64, real64
  use forecast_fullpos_state_types
  use forecast_output_request_types
  use forecast_output_request_storage, only: release_output_header, allocate_empty_physical_request
  use forecast_output_request_status
  use forecast_runtime_output_auxiliary_requests, only: initialize_runtime_auxiliary_requests
  use type_fpofn, only: tfpofn
  use runtime_output_file_names_port, only: make_output_name, provider_name_count => output_header_count
  implicit none
  private
  public::initialize_runtime_output_header,initialize_runtime_output_auxiliary,runtime_output_auxiliary_count,runtime_output_header_count
contains
  !> Release the old header first, then build names and the allocated empty buffer.
  integer(int32) function initialize_runtime_output_header(fullpos, physical, step, names, auxiliary, dynamic, &
                                                           linc, time_format, physics_enabled, counters) result(status)
    type(native_fullpos_state), intent(in) :: fullpos
    type(trqfp), intent(in) :: physical
    integer(int32), intent(in) :: step, time_format
    type(tfpofn), intent(inout) :: names
    type(fposbuf), intent(inout) :: auxiliary
    type(trqfpdyn), intent(in) :: dynamic
    logical, intent(in) :: linc, physics_enabled
    logical :: any_horizontal
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: first, digits, ierr
    call save_output_status(saved, error_slot, error_before)
    status = release_output_header(auxiliary, counters)
    if (linc) then
      status = 109
      goto 900
    end if
    status = 116
    if (fullpos%yfpcnt%nfpconf /= 0) goto 900
    if (fullpos%ynamfpsci%nfpsurfex /= 0) goto 900
    if (fullpos%yfpioh%ynamfpios%nfpwrite < 0 .or. fullpos%yfpioh%ynamfpios%nfpwrite > 1) goto 900
    if (.not. allocated(fullpos%yfpgeometry%yfpusergeo)) goto 900
    if (size(fullpos%yfpgeometry%yfpusergeo) /= 1) goto 900
    any_horizontal = any(fullpos%yfpgeometry%yfpusergeo%lfposbufshape)
    any_horizontal = any_horizontal .or. fullpos%ynamfpsci%nfpcli > 0
    if (fullpos%yfpgeometry%yfpgeo%nfproma < 1 .or. fullpos%yfpgeometry%yfpgeo%nfproma > 1024 .or. &
        fullpos%yfpgeometry%yfpgeo%nfpblocs < 1) goto 900
    if (.not. allocated(fullpos%yfpioh%yfpofn)) goto 900
    if (size(fullpos%yfpioh%yfpofn) /= 1) goto 900
    first = lbound(fullpos%yfpioh%yfpofn, 1)
    digits = fullpos%yfpioh%ynamfpios%nfpdigits
    if (fullpos%yfpioh%ynamfpios%nfpwrite == 1) then
      call make_output_name(fullpos%yfpioh%yfpofn(first)%csh, step, digits, time_format, names%csh, status)
      if (status /= 0) goto 900
      call make_output_name(fullpos%yfpioh%yfpofn(first)%cgg, step, digits, time_format, names%cgg, status)
      if (status /= 0) goto 900
      call make_output_name(fullpos%yfpioh%yfpofn(first)%cua, step, digits, time_format, names%cua, status)
      if (status /= 0) goto 900
      status = 116
    end if
    status = initialize_runtime_auxiliary_requests(physical, auxiliary%yrqphy, &
                                                 int(fullpos%ynamfpint%nfpinphy, int32), fullpos, physics_enabled, any_horizontal, &
                                                   fullpos%yfpgeometry%lfposhor, dynamic)
    if (status /= 0) goto 900
    allocate (auxiliary%fpbuf(fullpos%yfpgeometry%yfpgeo%nfproma, &
                              auxiliary%yrqphy%nfieldg, fullpos%yfpgeometry%yfpgeo%nfpblocs), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    call increment_output_counter(counters%header)
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Retain the lagged bypass and the original signed calendar-month calculation.
  integer(int32) function initialize_runtime_output_auxiliary(fullpos, model_resolution, data, lag, lfpmois, &
                                                              initial_date, update_date, counters) result(status)
    type(native_fullpos_state), target, intent(in) :: fullpos
    integer(int32), intent(in) :: model_resolution, lag, initial_date, update_date
    type(native_fullpos_data), intent(inout) :: data
    logical, intent(in) :: lfpmois
    type(native_output_service_counters), intent(inout) :: counters
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: month, domains, ierr
    status = 109
    if (fullpos%ynamfpsci%nfpcli /= 0 .or. fullpos%yfpgeometry%lfposhor) return
    if (lag >= 2) then
      data%yfpos => fullpos
      call increment_output_counter(counters%auxiliary)
      status = 0
      return
    end if
    status = 116
    if (fullpos%yfpgeometry%nmdlresol /= model_resolution) return
    call save_output_status(saved, error_slot, error_before)
    if (data%lfpupdcli) then
      month = initial_date
      if (lfpmois) month = update_date
      month = mod(month/100, 100)
      if (month >= 1 .and. month <= 12) then
        data%lfpupdcli = .true.
        if (fullpos%yfpgeometry%yfpgeo%nfproma < 1 .or. fullpos%yfpgeometry%yfpgeo%nfproma > 1024 .or. &
            fullpos%yfpgeometry%yfpgeo%nfpblocs < 1) goto 900
        if (.not. allocated(fullpos%yfpgeometry%yfpusergeo)) goto 900
        domains = size(fullpos%yfpgeometry%yfpusergeo)
        if (domains < 1 .or. domains > 8) goto 900
        status = release_output_header(data%yfpclimo, counters)
        status = allocate_empty_physical_request(data%yfpclimo%yrqphy, int(domains, int32), counters)
        if (status /= 0) goto 900
        allocate (data%yfpclimo%fpbuf(fullpos%yfpgeometry%yfpgeo%nfproma, 0:0, &
                                      fullpos%yfpgeometry%yfpgeo%nfpblocs), stat=ierr)
        if (ierr /= 0) then
          status = 1
          goto 900
        end if
      else
        data%lfpupdcli = .false.
      end if
    else
      data%lfpupdcli = .false.
    end if
    data%yfpos => fullpos
    call increment_output_counter(counters%auxiliary)
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  integer(int64) function runtime_output_auxiliary_count(counters) result(value)
    type(native_output_service_counters), intent(in) :: counters
    value = counters%auxiliary
  end function
  !> Join the actual outer-header counter and unchanged name-provider observation.
  integer(int64) function runtime_output_header_count(index, counters) result(value)
    integer(int64), intent(in) :: index
    type(native_output_service_counters), intent(in) :: counters
    value = 0
    if (index == 0) value = counters%header
    if (index == 1) value = provider_name_count(1_int64)
  end function
end module forecast_runtime_output_header_and_auxiliary
