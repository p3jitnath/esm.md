!> Prepare the selected model, pressure and surface output requests from live fort.4.
!! The caller owns the full-position state, requests and common metadata.
!! Model levels are 1:64. The text limit is 262144 bytes. Pressure is in pascals.
!! The caller establishes nearest-even arithmetic and gradual underflow once.
module forecast_output_request_preparation
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_long, c_size_t, c_ptr, c_char, c_null_char, c_loc
  use ieee_exceptions, only: ieee_status_type, ieee_set_status
  use forecast_output_request_types
  use forecast_output_request_status, only: save_output_status, restore_output_status
  use forecast_fullpos_state_types, only: native_fullpos_state
  use forecast_output_namelist, only: native_selected_output_namelist, parse_selected_output_namfpc
  use forecast_output_request_initialization, only: initialize_output_field_requests, initialize_output_dynamic_requests
  implicit none
  private
  public :: native_output_preparation_policy, native_output_common_metadata
  public :: prepare_output_requests, output_request_preparation_count
  type :: native_output_preparation_policy
    logical :: lecmwf = .true., larpegef = .false., lelam = .false.
  end type
  type :: native_output_common_metadata
    logical :: ltracefp, lfppacking, locedelay
    real(real64) :: rwidom
  end type
  interface
    function output_openat(directory, path, flags, mode) bind(c, name='openat') result(fd)
      import :: c_int, c_ptr
      integer(c_int), value :: directory, flags, mode
      type(c_ptr), value :: path
      integer(c_int) :: fd
    end function
    function output_read(fd, buffer, bytes) bind(c, name='read') result(received)
      import :: c_int, c_ptr, c_size_t, c_long
      integer(c_int), value :: fd
      type(c_ptr), value :: buffer
      integer(c_size_t), value :: bytes
      integer(c_long) :: received
    end function
    function output_close(fd) bind(c, name='close') result(status)
      import :: c_int
      integer(c_int), value :: fd
      integer(c_int) :: status
    end function
  end interface
contains
  !> Read fort.4 and replace all source-owned request arrays in source order.
  !! fullpos and policy are read-only. fields, physical, dynamic, common and counters mutate.
  !! Status 0 is success, 1 is allocation failure and 116 is unsupported input or I/O.
  !! A refusal retains the source's already released or constructed persistent prefix.
  !! Temporary text and an acquired file descriptor are released on every normal return.
  !! Legacy KTIME, KLAG, delay and ocean arguments are unused by this source branch.
  integer(int32) function prepare_output_requests(fullpos, model_levels, policy, nfpos, ngribfile, common, &
                                                  fields, physical, dynamic, counters) result(status)
    type(native_fullpos_state), intent(in) :: fullpos
    integer(int32), intent(in) :: model_levels, nfpos, ngribfile
    type(native_output_preparation_policy), intent(in) :: policy
    type(native_output_common_metadata), intent(inout) :: common
    type(tfpfields), intent(inout) :: fields
    type(trqfp), intent(inout) :: physical
    type(trqfpdyn), intent(inout) :: dynamic
    type(native_output_service_counters), intent(inout) :: counters
    type(native_selected_output_namelist) :: parsed
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before, fd, close_status
    integer(c_long) :: received
    character(kind=c_char, len=:), allocatable, target :: text
    character(kind=c_char, len=7), target :: path
    integer :: used, i, ierr
    integer(int32) :: child_status, external_codes(686), science_fit(7), science_filter(7)
    logical :: surface_flags(686)
    call save_output_status(saved, error_slot, error_before)
    call clear_preparation_requests(fields, physical, dynamic)
    status = 116
    fd = -1
    if (fullpos%yfpcnt%nfpconf /= 0 .or. fullpos%yfpcnt%lfpcnt) goto 900
    if (fullpos%yfpcnt%cnam /= repeat(' ', len(fullpos%yfpcnt%cnam))) goto 900
    if (.not. policy%lecmwf .or. policy%larpegef .or. policy%lelam) goto 900
    if (model_levels < 1 .or. model_levels > 64) goto 900
    if (.not. allocated(fullpos%yfpgeometry%yfpusergeo)) goto 900
    if (size(fullpos%yfpgeometry%yfpusergeo) /= 1) goto 900
    if (.not. allocated(fullpos%yfpvab%vbh)) goto 900
    if (ubound(fullpos%yfpvab%vbh, 1) < model_levels) goto 900
    common%ltracefp = .false.
    common%lfppacking = nfpos /= 0 .and. ngribfile == 0
    common%locedelay = .true.
    common%rwidom = transfer(int(z'7FEFFFFFFFFFFFFF', int64), 0.0_real64)
    allocate (character(kind=c_char, len=262145) :: text, stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    path = 'fort.4'//c_null_char
    fd = output_openat(-100_c_int, c_loc(path), 0_c_int, 0_c_int)
    if (fd < 0) goto 900
    used = 0
    do
      received = output_read(fd, c_loc(text(used + 1:used + 1)), int(262145 - used, c_size_t))
      if (received < 0_c_long) then
        if (error_slot == 4_c_int) cycle
        goto 900
      end if
      if (received == 0_c_long) exit
      used = used + int(received)
      if (used > 262144) goto 900
    end do
    close_status = output_close(fd)
    fd = -1
    if (close_status /= 0) goto 900
    child_status = parse_selected_output_namfpc(text(1:used), parsed)
    deallocate (text)
    if (child_status /= 0) goto 900
    if (parsed%request%field_count(1) == 0 .and. parsed%request%nrfp3s(1) == -99) goto 900
    if (any(parsed%request%field_count(3:7) /= 0)) goto 900
    child_status = initialize_output_field_requests(parsed%request, model_levels, fields)
    if (child_status /= 0) then
      if (child_status == 1) status = 1
      goto 900
    end if
    do i = 1, fields%nfp3p
      if (fields%rfp3p(i) > 100000.0_real64) goto 900
    end do
    do i = 1, 686
      external_codes(i) = fullpos%yafn%tfp_dynds(i)%igrib
      surface_flags(i) = fullpos%yafn%tfp_dynds(i)%llsrf
    end do
    science_fit = [fullpos%ynamfpsci%nfitp, fullpos%ynamfpsci%nfitt, fullpos%ynamfpsci%nfitv, &
                   fullpos%ynamfpsci%nfiti, fullpos%ynamfpsci%nfitf, fullpos%ynamfpsci%nfith, fullpos%ynamfpsci%nfits]
    science_filter = [fullpos%ynamfpsci%nspfilp, fullpos%ynamfpsci%nspfilt, fullpos%ynamfpsci%nspfilv, &
                      fullpos%ynamfpsci%nspfili, fullpos%ynamfpsci%nspfilf, fullpos%ynamfpsci%nspfilh, fullpos%ynamfpsci%nspfils]
    child_status = initialize_output_dynamic_requests(external_codes, surface_flags, science_fit, science_filter, fields, dynamic)
    if (child_status /= 0) then
      if (child_status == 1) status = 1
      goto 900
    end if
    call increment_output_counter(counters%preparation)
    ! Existing generated preparation explicitly publishes errno zero before restoring IEEE status.
    ! This is source preservation; original/native status equality awaits the independent gate.
    error_slot = 0_c_int
    call ieee_set_status(saved)
    status = 0
    return
900 continue
    if (fd >= 0) close_status = output_close(fd)
    if (allocated(text)) deallocate (text)
    call restore_output_status(saved, error_slot, error_before)
  end function
  !> Release fields, physical requests and dynamic requests before selected admission.
  !! Native descriptors and padding remain compiler-owned; only named source counts are reset.
  subroutine clear_preparation_requests(fields, physical, dynamic)
    type(tfpfields), intent(inout) :: fields
    type(trqfp), intent(inout) :: physical
    type(trqfpdyn), intent(inout) :: dynamic
    if (allocated(fields%cfp3df)) deallocate (fields%cfp3df)
    if (allocated(fields%cfp2df)) deallocate (fields%cfp2df)
    if (allocated(fields%cfpphy)) deallocate (fields%cfpphy)
    if (allocated(fields%cfpcfu)) deallocate (fields%cfpcfu)
    if (allocated(fields%cfpxfu)) deallocate (fields%cfpxfu)
    if (allocated(fields%mfp3dfs)) deallocate (fields%mfp3dfs)
    if (allocated(fields%mfp3dfp)) deallocate (fields%mfp3dfp)
    if (allocated(fields%mfp3dfh)) deallocate (fields%mfp3dfh)
    if (allocated(fields%mfp3dft)) deallocate (fields%mfp3dft)
    if (allocated(fields%mfp3dfv)) deallocate (fields%mfp3dfv)
    if (allocated(fields%mfp3dfi)) deallocate (fields%mfp3dfi)
    if (allocated(fields%mfp3dff)) deallocate (fields%mfp3dff)
    if (allocated(fields%mfp2df)) deallocate (fields%mfp2df)
    if (allocated(fields%mfpphy)) deallocate (fields%mfpphy)
    if (allocated(fields%rfp3p)) deallocate (fields%rfp3p)
    if (allocated(fields%rfp3h)) deallocate (fields%rfp3h)
    if (allocated(fields%rfp3th)) deallocate (fields%rfp3th)
    if (allocated(fields%rfp3pv)) deallocate (fields%rfp3pv)
    if (allocated(fields%rfp3i)) deallocate (fields%rfp3i)
    if (allocated(fields%rfp3f)) deallocate (fields%rfp3f)
    if (allocated(fields%nrfp3s)) deallocate (fields%nrfp3s)
    if (allocated(physical%icod)) deallocate (physical%icod)
    if (allocated(physical%igrib)) deallocate (physical%igrib)
    if (allocated(physical%llsurf)) deallocate (physical%llsurf)
    if (allocated(physical%ivec)) deallocate (physical%ivec)
    if (allocated(physical%zlev)) deallocate (physical%zlev)
    if (allocated(physical%clname)) deallocate (physical%clname)
    if (allocated(physical%clpref)) deallocate (physical%clpref)
    if (allocated(physical%idom)) deallocate (physical%idom)
    if (allocated(physical%idmp)) deallocate (physical%idmp)
    if (allocated(physical%ivsetg)) deallocate (physical%ivsetg)
    if (allocated(physical%ivlocg)) deallocate (physical%ivlocg)
    if (allocated(dynamic%ypr%zpxlev)) deallocate (dynamic%ypr%zpxlev)
    if (allocated(dynamic%ypr%icod)) deallocate (dynamic%ypr%icod)
    if (allocated(dynamic%ypr%npplevg)) deallocate (dynamic%ypr%npplevg)
    if (allocated(dynamic%ypr%ilev)) deallocate (dynamic%ypr%ilev)
    if (allocated(dynamic%ypr%idom)) deallocate (dynamic%ypr%idom)
    if (allocated(dynamic%ypr%idmp)) deallocate (dynamic%ypr%idmp)
    if (allocated(dynamic%yth%zpxlev)) deallocate (dynamic%yth%zpxlev)
    if (allocated(dynamic%yth%icod)) deallocate (dynamic%yth%icod)
    if (allocated(dynamic%yth%npplevg)) deallocate (dynamic%yth%npplevg)
    if (allocated(dynamic%yth%ilev)) deallocate (dynamic%yth%ilev)
    if (allocated(dynamic%yth%idom)) deallocate (dynamic%yth%idom)
    if (allocated(dynamic%yth%idmp)) deallocate (dynamic%yth%idmp)
    if (allocated(dynamic%ypv%zpxlev)) deallocate (dynamic%ypv%zpxlev)
    if (allocated(dynamic%ypv%icod)) deallocate (dynamic%ypv%icod)
    if (allocated(dynamic%ypv%npplevg)) deallocate (dynamic%ypv%npplevg)
    if (allocated(dynamic%ypv%ilev)) deallocate (dynamic%ypv%ilev)
    if (allocated(dynamic%ypv%idom)) deallocate (dynamic%ypv%idom)
    if (allocated(dynamic%ypv%idmp)) deallocate (dynamic%ypv%idmp)
    if (allocated(dynamic%yho%zpxlev)) deallocate (dynamic%yho%zpxlev)
    if (allocated(dynamic%yho%icod)) deallocate (dynamic%yho%icod)
    if (allocated(dynamic%yho%npplevg)) deallocate (dynamic%yho%npplevg)
    if (allocated(dynamic%yho%ilev)) deallocate (dynamic%yho%ilev)
    if (allocated(dynamic%yho%idom)) deallocate (dynamic%yho%idom)
    if (allocated(dynamic%yho%idmp)) deallocate (dynamic%yho%idmp)
    if (allocated(dynamic%yes%zpxlev)) deallocate (dynamic%yes%zpxlev)
    if (allocated(dynamic%yes%icod)) deallocate (dynamic%yes%icod)
    if (allocated(dynamic%yes%npplevg)) deallocate (dynamic%yes%npplevg)
    if (allocated(dynamic%yes%ilev)) deallocate (dynamic%yes%ilev)
    if (allocated(dynamic%yes%idom)) deallocate (dynamic%yes%idom)
    if (allocated(dynamic%yes%idmp)) deallocate (dynamic%yes%idmp)
    if (allocated(dynamic%yfl%zpxlev)) deallocate (dynamic%yfl%zpxlev)
    if (allocated(dynamic%yfl%icod)) deallocate (dynamic%yfl%icod)
    if (allocated(dynamic%yfl%npplevg)) deallocate (dynamic%yfl%npplevg)
    if (allocated(dynamic%yfl%ilev)) deallocate (dynamic%yfl%ilev)
    if (allocated(dynamic%yfl%idom)) deallocate (dynamic%yfl%idom)
    if (allocated(dynamic%yfl%idmp)) deallocate (dynamic%yfl%idmp)
    if (allocated(dynamic%yit%zpxlev)) deallocate (dynamic%yit%zpxlev)
    if (allocated(dynamic%yit%icod)) deallocate (dynamic%yit%icod)
    if (allocated(dynamic%yit%npplevg)) deallocate (dynamic%yit%npplevg)
    if (allocated(dynamic%yit%ilev)) deallocate (dynamic%yit%ilev)
    if (allocated(dynamic%yit%idom)) deallocate (dynamic%yit%idom)
    if (allocated(dynamic%yit%idmp)) deallocate (dynamic%yit%idmp)
    if (allocated(dynamic%y2d%icod)) deallocate (dynamic%y2d%icod)
    if (allocated(dynamic%y2d%idom)) deallocate (dynamic%y2d%idom)
    if (allocated(dynamic%y2d%idmp)) deallocate (dynamic%y2d%idmp)
    fields%nfp3p = 0
    fields%nfp3h = 0
    fields%nfp3th = 0
    fields%nfp3pv = 0
    fields%nfp3i = 0
    fields%nfp3s = 0
    fields%nfp3f = 0
    fields%nfp3dfs = 0
    fields%nfp3dfp = 0
    fields%nfp3dfh = 0
    fields%nfp3dft = 0
    fields%nfp3dfv = 0
    fields%nfp3dfi = 0
    fields%nfp3dff = 0
    fields%nfp3df = 0
    fields%nfp2df = 0
    fields%nfpphy = 0
    fields%nfpcfu = 0
    fields%nfpxfu = 0
    physical%nfieldg = 0
    physical%nfieldl = 0
    dynamic%ypr%nppfieldg = 0
    dynamic%ypr%npxlev = 0
    dynamic%ypr%nfit = 0
    dynamic%ypr%nspfil = 0
    dynamic%yth%nppfieldg = 0
    dynamic%yth%npxlev = 0
    dynamic%yth%nfit = 0
    dynamic%yth%nspfil = 0
    dynamic%ypv%nppfieldg = 0
    dynamic%ypv%npxlev = 0
    dynamic%ypv%nfit = 0
    dynamic%ypv%nspfil = 0
    dynamic%yho%nppfieldg = 0
    dynamic%yho%npxlev = 0
    dynamic%yho%nfit = 0
    dynamic%yho%nspfil = 0
    dynamic%yes%nppfieldg = 0
    dynamic%yes%npxlev = 0
    dynamic%yes%nfit = 0
    dynamic%yes%nspfil = 0
    dynamic%yfl%nppfieldg = 0
    dynamic%yfl%npxlev = 0
    dynamic%yfl%nfit = 0
    dynamic%yfl%nspfil = 0
    dynamic%yit%nppfieldg = 0
    dynamic%yit%npxlev = 0
    dynamic%yit%nfit = 0
    dynamic%yit%nspfil = 0
    dynamic%y2d%nppfieldg = 0
  end subroutine
  integer(int64) function output_request_preparation_count(counters) result(value)
    type(native_output_service_counters), intent(in) :: counters
    value = counters%preparation
  end function
end module forecast_output_request_preparation
