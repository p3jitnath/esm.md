module initial_model_file_headers_port
  !! Read spectral and Gaussian-grid metadata through public ecCodes.
  !! A is pressure in Pa and B has no unit. Dates are YYYYMMDD labels,
  !! clock and forecast times are seconds, and all dimensions are counts.
  !! The fixed header arrays own their values. No model-global state is used.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding
  use, intrinsic :: ieee_arithmetic, only: ieee_round_type,ieee_nearest,ieee_get_rounding_mode,ieee_get_underflow_mode,ieee_support_underflow_control,operator(/=)
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use runtime_initial_upper_air_reader_port, only: runtime_initial_grid_metadata
  implicit none
  private
  public :: spectral_input_header_metadata, initial_model_header_metadata
  public :: read_initial_model_headers, initial_model_header_count_get
  public :: make_runtime_grid_from_initial_headers
  type :: spectral_input_header_metadata
    integer(int32) :: truncation_j = 0, truncation_k = 0, truncation_m = 0
    integer(int32) :: levels = 0, date = 0, seconds = 0, forecast_seconds = 0
  end type
  type :: initial_model_header_metadata
    type(spectral_input_header_metadata) :: spectral
    integer(int32) :: nusmax = 0, nucmax = 0, nudgl = 0, nudlon = 0, nuhtyp = 0
    integer(int32) :: nusttyp = 0, ngribfile = 0, nsupersede = 0, north_row_count = 0
    integer(int32) :: grid_date = 0, grid_seconds = 0, grid_forecast_seconds = 0
    real(real64) :: ustret = 0.0_real64, umucen = 0.0_real64, ulocen = 0.0_real64
    real(real64) :: a(0:256) = 0.0_real64, b(0:256) = 0.0_real64
    integer(int32) :: north_rows(1280) = 0
    logical :: ready = .false.
  end type
  integer(int64), save :: completed = 0
  interface
    function file_open(path, mode) bind(C, name="fopen") result(stream)
      import
      character(c_char), intent(in) :: path(*), mode(*)
      type(c_ptr) :: stream
    end function
    function file_close(stream) bind(C, name="fclose") result(status)
      import
      type(c_ptr), value :: stream
      integer(c_int) :: status
    end function
    function new_message(context, stream, error) bind(C, name="codes_grib_handle_new_from_file") result(handle)
      import
      type(c_ptr), value :: context, stream
      integer(c_int), intent(out) :: error
      type(c_ptr) :: handle
    end function
    function delete_message(handle) bind(C, name="codes_handle_delete") result(status)
      import
      type(c_ptr), value :: handle
      integer(c_int) :: status
    end function
    function get_long(handle, key, value) bind(C, name="codes_get_long") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: value
      integer(c_int) :: status
    end function
    function get_size(handle, key, length) bind(C, name="codes_get_size") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_size_t), intent(out) :: length
      integer(c_int) :: status
    end function
    function get_reals(handle, key, values, length) bind(C, name="codes_get_double_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      real(c_double), intent(out) :: values(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function get_longs(handle, key, values, length) bind(C, name="codes_get_long_array") result(status)
      import
      type(c_ptr), value :: handle
      character(c_char), intent(in) :: key(*)
      integer(c_long), intent(out) :: values(*)
      integer(c_size_t), intent(inout) :: length
      integer(c_int) :: status
    end function
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function read_initial_model_headers(spectral_path, grid_path, output) result(status)
    !! Each path contains1..4095 characters and no NUL. output is a disjoint,
    !! caller-owned native header. Both first messages must pass the source
    !! metadata bounds and both files must close before output changes.
    !! J/K/M are retained independently. This source-backed triangular route
    !! admits J=K=M and publishes NUSMAX=NUCMAX=J; no Gaussian-order inference
    !! sets spectral truncation. NMSMAX remains a later dimension control.
    !! Only active A/B and north-row prefixes change; unused tails are copied
    !! from the incoming output. No heap allocation or numerical stage occurs.
    !! Status0 succeeds,1 rejects entry,2 open,3 codec,4 metadata,5 close.
    !! Standard nearest/gradual IEEE mode is required. IEEE and errno restore.
    character(*), intent(in) :: spectral_path, grid_path
    type(initial_model_header_metadata), intent(inout) :: output
    type(initial_model_header_metadata) :: staged
    character(kind=c_char, len=4096) :: spectral_name, grid_name
    type(c_ptr) :: stream, handle
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno, error, cleanup_status
    type(ieee_status_type) :: incoming
    integer(c_long) :: date, clock, hours, template, j, k, m, nv, nj, ni, order, pl_present, points
    integer(c_long) :: rows(2560)
    integer(c_size_t) :: count
    real(real64) :: pv(514)
    integer(int64) :: total, maximum, word
    integer(int32) :: seconds, forecast_seconds
    integer :: which, n, r, q
    status = 1
    if (len(spectral_path) < 1 .or. len(spectral_path) > 4095) return
    if (len(grid_path) < 1 .or. len(grid_path) > 4095) return
    if (index(spectral_path, c_null_char) /= 0 .or. index(grid_path, c_null_char) /= 0) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    if (.not. floating_environment_ready()) then
      call ieee_set_status(incoming); error_number = saved_errno
      return
    end if
    do n = 1, len(spectral_path)
      spectral_name(n:n) = spectral_path(n:n)
    end do
    spectral_name(len(spectral_path) + 1:len(spectral_path) + 1) = c_null_char
    do n = 1, len(grid_path)
      grid_name(n:n) = grid_path(n:n)
    end do
    grid_name(len(grid_path) + 1:len(grid_path) + 1) = c_null_char
    staged = output
    stream = c_null_ptr; handle = c_null_ptr
    status = 0
    do which = 1, 2
      if (which == 1) then
        stream = file_open(spectral_name, 'rb'//c_null_char)
      else
        stream = file_open(grid_name, 'rb'//c_null_char)
      end if
      status = 2
      if (.not. c_associated(stream)) goto900
      error = 0
      handle = new_message(c_null_ptr, stream, error)
      status = 3
      if (error /= 0 .or. .not. c_associated(handle)) goto900
      if (get_long(handle, 'dataDate'//c_null_char, date) /= 0) goto900
      if (get_long(handle, 'dataTime'//c_null_char, clock) /= 0) goto900
      if (get_long(handle, 'step'//c_null_char, hours) /= 0) goto900
      status = 4
      if (date < 1 .or. date > 99991231_c_long) goto900
      if (clock < 0 .or. clock/100 > 23 .or. mod(clock, 100_c_long) > 59) goto900
      if (hours < 0 .or. hours > 596523_c_long) goto900
      seconds = int((clock/100)*3600 + mod(clock, 100_c_long)*60, int32)
      forecast_seconds = int(hours*3600, int32)
      status = 3
      if (get_long(handle, 'gridDefinitionTemplateNumber'//c_null_char, template) /= 0) goto900
      status = 4
      if (which == 1) then
        if (template /= 50) goto900
        status = 3
        if (get_long(handle, 'pentagonalResolutionParameterJ'//c_null_char, j) /= 0) goto900
        if (get_long(handle, 'pentagonalResolutionParameterK'//c_null_char, k) /= 0) goto900
        if (get_long(handle, 'pentagonalResolutionParameterM'//c_null_char, m) /= 0) goto900
        status = 4
        if (j < 0 .or. j > 4096 .or. k /= j .or. m /= j) goto900
        status = 3
        if (get_long(handle, 'numberOfVerticalCoordinateValues'//c_null_char, nv) /= 0) goto900
        status = 4
        if (nv < 4 .or. nv > 514 .or. mod(nv, 2_c_long) /= 0) goto900
        status = 3
        if (get_size(handle, 'pv'//c_null_char, count) /= 0) goto900
        status = 4
        if (count /= nv) goto900
        status = 3
        if (get_reals(handle, 'pv'//c_null_char, pv, count) /= 0) goto900
        status = 4
        if (count /= nv) goto900
        n = int(nv/2)
        do q = 1, n
          word = transfer(pv(q), 0_int64)
          if (iand(ishft(word, -52), 2047_int64) == 2047) goto900
          word = transfer(pv(n + q), 0_int64)
          if (iand(ishft(word, -52), 2047_int64) == 2047) goto900
          staged%a(q - 1) = pv(q); staged%b(q - 1) = pv(n + q)
        end do
 staged%spectral=spectral_input_header_metadata(int(j,int32),int(k,int32),int(m,int32),n-1,int(date,int32),seconds,forecast_seconds)
        staged%nusmax = int(j, int32); staged%nucmax = int(j, int32)
        staged%nusttyp = 1; staged%ngribfile = 1; staged%nsupersede = 1
        staged%ustret = 1.0_real64; staged%umucen = 1.0_real64; staged%ulocen = 0.0_real64
      else
        if (template /= 40) goto900
        status = 3
        if (get_long(handle, 'Nj'//c_null_char, nj) /= 0) goto900
        if (get_long(handle, 'Ni'//c_null_char, ni) /= 0) goto900
        if (get_long(handle, 'N'//c_null_char, order) /= 0) goto900
        if (get_long(handle, 'PLPresent'//c_null_char, pl_present) /= 0) goto900
        status = 4
        if (pl_present < 0 .or. pl_present > 1) goto900
        if (nj < 2 .or. nj > 2560 .or. mod(nj, 2_c_long) /= 0) goto900
        if (order < 1 .or. order > 1280 .or. 2*order /= nj) goto900
        r = int(order)
        if (pl_present == 0) then
          if (order > 256 .or. ni < 1 .or. ni > 2147483647_c_long) goto900
          staged%north_rows(1:r) = int(ni, int32)
          staged%nudlon = int(ni, int32); staged%nuhtyp = 0
        else
          status = 3
          if (get_size(handle, 'pl'//c_null_char, count) /= 0) goto900
          status = 4
          if (count /= nj) goto900
          status = 3
          if (get_longs(handle, 'pl'//c_null_char, rows, count) /= 0) goto900
          status = 4
          if (count /= nj) goto900
          total = 0
          do q = 1, int(nj)
            if (rows(q) < 1 .or. rows(q) > 2147483647_c_long) goto900
            total = total + rows(q)
            if (total > 2147483647_int64) goto900
          end do
          maximum = 0; staged%nuhtyp = 0
          do q = 1, r
            if (rows(q) /= rows(int(nj) + 1 - q)) goto900
            if (rows(q) /= rows(1)) staged%nuhtyp = 2
            maximum = max(maximum, int(rows(q), int64))
            staged%north_rows(q) = int(rows(q), int32)
          end do
          staged%nudlon = int(maximum, int32)
          status = 3
          if (get_long(handle, 'numberOfDataPoints'//c_null_char, points) /= 0) goto900
          status = 4
          if (points /= total) goto900
        end if
        staged%nudgl = int(nj, int32); staged%north_row_count = r
        staged%grid_date = int(date, int32); staged%grid_seconds = seconds
        staged%grid_forecast_seconds = forecast_seconds
      end if
      status = 0
      cleanup_status = delete_message(handle); handle = c_null_ptr
      if (cleanup_status /= 0) status = 3
      cleanup_status = file_close(stream); stream = c_null_ptr
      if (status == 0 .and. cleanup_status /= 0) status = 5
      if (status /= 0) goto900
    end do
    staged%ready = .true.
    output = staged
    completed = completed + 1_int64
900 if (c_associated(handle)) then
      cleanup_status = delete_message(handle)
      if (status == 0 .and. cleanup_status /= 0) status = 3
    end if
    if (c_associated(stream)) then
      cleanup_status = file_close(stream)
      if (status == 0 .and. cleanup_status /= 0) status = 5
    end if
    call ieee_set_status(incoming); error_number = saved_errno
  end function
  integer(int64) function initial_model_header_count_get() result(count)
    !! Serial successful-publication count. No file or output state changes.
    count = completed
  end function
  integer(int32) function make_runtime_grid_from_initial_headers(headers, grid) result(status)
    !! Project the admitted file header into the one existing native grid
    !! owner. Allocation and replacement of north_rows occur only on success.
    !! Other callers borrow the resulting grid by its existing module identity.
    !! Status0 succeeds,1 allocation,2 metadata. IEEE and errno are preserved.
    type(initial_model_header_metadata), intent(in) :: headers
    type(runtime_initial_grid_metadata), intent(inout) :: grid
    integer(c_int), allocatable :: north(:)
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming
    integer(int64) :: points
    integer :: r, error
    status = 2
    if (.not. headers%ready) return
    r = headers%north_row_count
    if (r < 1 .or. r > 1280 .or. headers%nudgl /= 2*r) return
    if (headers%spectral%levels < 1 .or. headers%spectral%levels > 256) return
    if (any(headers%north_rows(1:r) < 1)) return
    if (maxval(headers%north_rows(1:r)) /= headers%nudlon) return
    points = 2*sum(int(headers%north_rows(1:r), int64))
    if (points > 2147483647_int64) return
    if (headers%grid_date < 1 .or. headers%grid_date > 99991231) return
    if (headers%grid_seconds < 0 .or. headers%grid_seconds > 86340 .or. mod(headers%grid_seconds, 60) /= 0) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    allocate (north(r), stat=error)
    status = 1
    if (error == 0) then
      north = headers%north_rows(1:r)
      call move_alloc(north, grid%north_rows)
      grid%levels = headers%spectral%levels; grid%gaussian_order = r
      grid%row_count = headers%nudgl; grid%maximum_longitudes = headers%nudlon
      grid%date = headers%grid_date; grid%seconds = headers%grid_seconds
      status = 0
    end if
    call ieee_set_status(incoming); error_number = saved_errno
  end function
  logical function floating_environment_ready() result(ready)
    !! Use the supported public inquiry,or the already-qualified exact
    !! tiny*0.5 probe when GNU does not expose underflow control.
    type(ieee_round_type) :: rounding
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    logical :: gradual
    ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    ready = .true.
  end function
end module
