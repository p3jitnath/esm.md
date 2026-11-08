!> Describe actual weather owners at a stopped forecast boundary.
!! Views are readonly and keep their native TARGET lifetime. No numerical payload
!! is read here. The existing interval reader and sink perform the raw comparison.
module forecast_native_weather_capture_views
  use iso_c_binding
  use iso_fortran_env, only: int32, int64
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_native_execution_state, only: native_forecast_execution_state
  use forecast_weather_view_protocol
  implicit none
  private
  public :: describe_native_weather_state
  interface
    function weather_errno_address() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Export native named primitive views. SNAPSHOT_INDEX is0,1 or2.
  !! Its matching labels mean first STEPO entry and successful STEPO0/1 returns.
  !! OBSERVER is a synchronous C callback. It may keep view metadata but must
  !! finish payload reads before the stopped owner resumes or is released.
  !! Status0 means the declared views were exported. It does not admit an
  !! original initialized interval, complete catalogue or forecast comparison.
  subroutine describe_native_weather_state(state, snapshot_index, observer, status)
    type(native_forecast_execution_state), target, intent(in) :: state
    integer(c_int), intent(in) :: snapshot_index
    type(c_funptr), intent(in) :: observer
    integer(c_int), intent(out) :: status
    procedure(weather_view_callback), pointer :: observe
    type(ieee_status_type) :: saved_ieee
    integer(c_int), pointer, volatile :: error_word
    integer(c_int) :: saved_errno
    call ieee_get_status(saved_ieee)
    call c_f_pointer(weather_errno_address(), error_word)
    saved_errno = error_word
    status = 2
    if (.not. c_associated(observer)) goto900
    if (snapshot_index < 0 .or. snapshot_index > 2) goto900
    if (.not. allocated(state%startup)) goto900
    if (.not. allocated(state%startup%initial)) goto900
    if (.not. allocated(state%startup%loaded%storage)) goto900
    if (.not. allocated(state%startup%loaded%input)) goto900
    if (.not. associated(state%startup%loaded%fields)) goto900
    if (.not. state%startup%initial%ready) goto900
    if (state%step%completed /= int(snapshot_index, int64)) goto900
    if (state%startup%initial%controls%clock%current_step /= merge(1, 0, snapshot_index == 2)) goto900
    call c_f_procpointer(observer, observe)
    if (allocated(state%startup%loaded%storage%model%motion%gmv)) then
      call observe_weather_primitive('motion.gmv', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmv,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmv,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmv, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmv', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmvs)) then
      call observe_weather_primitive('motion.gmvs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmvs,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmvs,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmvs, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmvs', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmvt1)) then
      call observe_weather_primitive('motion.gmvt1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmvt1,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmvt1,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmvt1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmvt1', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmvt1s)) then
      call observe_weather_primitive('motion.gmvt1s', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmvt1s,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmvt1s,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmvt1s, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmvt1s', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmv5)) then
      call observe_weather_primitive('motion.gmv5', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmv5,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmv5,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmv5, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmv5', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmv5s)) then
      call observe_weather_primitive('motion.gmv5s', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmv5s,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmv5s,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmv5s, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmv5s', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmv_depart)) then
      call observe_weather_primitive('motion.gmv_depart', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmv_depart,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmv_depart,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmv_depart, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmv_depart', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%model%motion%gmvs_depart)) then
      call observe_weather_primitive('motion.gmvs_depart', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%model%motion%gmvs_depart,kind=c_int64_t),ubound(state%startup%loaded%storage%model%motion%gmvs_depart,kind=c_int64_t), &
                                     state%startup%loaded%storage%model%motion%gmvs_depart, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('motion.gmvs_depart', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('motion.ndimgmv', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%model%motion%ndimgmv, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('motion.ndimgmvs', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%model%motion%ndimgmvs, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%sp2d)) then
      call observe_weather_primitive('spectral.sp2d', 2_c_int, 8_c_int, &
  lbound(state%startup%loaded%input%spectral%sp2d,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%sp2d,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%sp2d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.sp2d', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%sp3d)) then
      call observe_weather_primitive('spectral.sp3d', 2_c_int, 8_c_int, &
  lbound(state%startup%loaded%input%spectral%sp3d,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%sp3d,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%sp3d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.sp3d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%sp1d)) then
      call observe_weather_primitive('spectral.sp1d', 2_c_int, 8_c_int, &
  lbound(state%startup%loaded%input%spectral%sp1d,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%sp1d,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%sp1d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.sp1d', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nsmax', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nsmax, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nmsmax', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nmsmax, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.ns2d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%ns2d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.ns3d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%ns3d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.ns1d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%ns1d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.ns2g', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%ns2g, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nflevl', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nflevl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nflevg', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nflevg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nspec2', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nspec2, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nspec2g', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nspec2g, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nump', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nump, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nspsizel', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nspsizel, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.nspsizeg', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%nspsizeg, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%ns2l)) then
      call observe_weather_primitive('spectral.ns2l', 1_c_int, 4_c_int, &
  lbound(state%startup%loaded%input%spectral%ns2l,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%ns2l,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ns2l, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ns2l', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nasm0)) then
      call observe_weather_primitive('spectral.nasm0', 1_c_int, 4_c_int, &
lbound(state%startup%loaded%input%spectral%nasm0,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nasm0,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nasm0, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nasm0', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nasm0g)) then
      call observe_weather_primitive('spectral.nasm0g', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%nasm0g,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nasm0g,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nasm0g, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nasm0g', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nesm0)) then
      call observe_weather_primitive('spectral.nesm0', 1_c_int, 4_c_int, &
lbound(state%startup%loaded%input%spectral%nesm0,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nesm0,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nesm0, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nesm0', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nesm0g)) then
      call observe_weather_primitive('spectral.nesm0g', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%nesm0g,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nesm0g,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nesm0g, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nesm0g', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%ncpl4m)) then
      call observe_weather_primitive('spectral.ncpl4m', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%ncpl4m,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%ncpl4m,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ncpl4m, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ncpl4m', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%numpp)) then
      call observe_weather_primitive('spectral.numpp', 1_c_int, 4_c_int, &
lbound(state%startup%loaded%input%spectral%numpp,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%numpp,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%numpp, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.numpp', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nallms)) then
      call observe_weather_primitive('spectral.nallms', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%nallms,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nallms,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nallms, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nallms', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%ms_proc)) then
      call observe_weather_primitive('spectral.ms_proc', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%ms_proc,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%ms_proc,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ms_proc, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ms_proc', 2_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%numll)) then
      call observe_weather_primitive('spectral.numll', 1_c_int, 4_c_int, &
lbound(state%startup%loaded%input%spectral%numll,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%numll,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%numll, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.numll', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nptrll)) then
      call observe_weather_primitive('spectral.nptrll', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%nptrll,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nptrll,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nptrll, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nptrll', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%npsurf)) then
      call observe_weather_primitive('spectral.npsurf', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%npsurf,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%npsurf,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%npsurf, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.npsurf', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%nptrms)) then
      call observe_weather_primitive('spectral.nptrms', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%nptrms,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%nptrms,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nptrms, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nptrms', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%myms)) then
      call observe_weather_primitive('spectral.myms', 1_c_int, 4_c_int, &
  lbound(state%startup%loaded%input%spectral%myms,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%myms,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%myms, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.myms', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%mylevs)) then
      call observe_weather_primitive('spectral.mylevs', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%mylevs,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%mylevs,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%mylevs, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.mylevs', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%spectral%ngrib)) then
      call observe_weather_primitive('spectral.ngrib', 1_c_int, 4_c_int, &
lbound(state%startup%loaded%input%spectral%ngrib,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%ngrib,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ngrib, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ngrib', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%ngrib2)) then
      call observe_weather_primitive('spectral.ngrib2', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%ngrib2,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%ngrib2,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ngrib2, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ngrib2', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%ngrib3)) then
      call observe_weather_primitive('spectral.ngrib3', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%input%spectral%ngrib3,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%ngrib3,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ngrib3, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ngrib3', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%vor)) then
      call observe_weather_primitive('spectral.vor', 2_c_int, 8_c_int, &
 lbound(state%startup%loaded%input%spectral%vor, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%vor, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%vor, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.vor', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%div)) then
      call observe_weather_primitive('spectral.div', 2_c_int, 8_c_int, &
 lbound(state%startup%loaded%input%spectral%div, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%div, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%div, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.div', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%t)) then
      call observe_weather_primitive('spectral.t', 2_c_int, 8_c_int, &
     lbound(state%startup%loaded%input%spectral%t, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%t, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%t, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.t', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%q)) then
      call observe_weather_primitive('spectral.q', 2_c_int, 8_c_int, &
     lbound(state%startup%loaded%input%spectral%q, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%q, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%q, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.q', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%o3)) then
      call observe_weather_primitive('spectral.o3', 2_c_int, 8_c_int, &
   lbound(state%startup%loaded%input%spectral%o3, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%o3, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%o3, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.o3', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%l)) then
      call observe_weather_primitive('spectral.l', 2_c_int, 8_c_int, &
     lbound(state%startup%loaded%input%spectral%l, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%l, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%l, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.l', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%i)) then
      call observe_weather_primitive('spectral.i', 2_c_int, 8_c_int, &
     lbound(state%startup%loaded%input%spectral%i, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%i, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%i, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.i', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%spd)) then
      call observe_weather_primitive('spectral.spd', 2_c_int, 8_c_int, &
 lbound(state%startup%loaded%input%spectral%spd, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%spd, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%spd, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.spd', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%svd)) then
      call observe_weather_primitive('spectral.svd', 2_c_int, 8_c_int, &
 lbound(state%startup%loaded%input%spectral%svd, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%svd, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%svd, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.svd', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%nhx)) then
      call observe_weather_primitive('spectral.nhx', 2_c_int, 8_c_int, &
 lbound(state%startup%loaded%input%spectral%nhx, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%nhx, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%nhx, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.nhx', 2_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%sp)) then
      call observe_weather_primitive('spectral.sp', 2_c_int, 8_c_int, &
   lbound(state%startup%loaded%input%spectral%sp, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%sp, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%sp, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.sp', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%orog)) then
      call observe_weather_primitive('spectral.orog', 2_c_int, 8_c_int, &
  lbound(state%startup%loaded%input%spectral%orog,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%orog,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%orog, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.orog', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%ub)) then
      call observe_weather_primitive('spectral.ub', 2_c_int, 8_c_int, &
   lbound(state%startup%loaded%input%spectral%ub, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%ub, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%ub, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.ub', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%vb)) then
      call observe_weather_primitive('spectral.vb', 2_c_int, 8_c_int, &
   lbound(state%startup%loaded%input%spectral%vb, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%vb, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%vb, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.vb', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%scal)) then
      call observe_weather_primitive('spectral.scal', 2_c_int, 8_c_int, &
  lbound(state%startup%loaded%input%spectral%scal,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%scal,kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%scal, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.scal', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%gfl)) then
      call observe_weather_primitive('spectral.gfl', 2_c_int, 8_c_int, &
 lbound(state%startup%loaded%input%spectral%gfl, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%gfl, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%gfl, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.gfl', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%input%spectral%hv)) then
      call observe_weather_primitive('spectral.hv', 2_c_int, 8_c_int, &
   lbound(state%startup%loaded%input%spectral%hv, kind=c_int64_t), ubound(state%startup%loaded%input%spectral%hv, kind=c_int64_t), &
                                     state%startup%loaded%input%spectral%hv, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('spectral.hv', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.dummy', 2_c_int, 8_c_int, &
lbound(state%startup%loaded%input%spectral%dummy,kind=c_int64_t),ubound(state%startup%loaded%input%spectral%dummy,kind=c_int64_t), &
                                   state%startup%loaded%input%spectral%dummy, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('spectral.ready', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%spectral%ready, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%upper%fields%gfl)) then
      call observe_weather_primitive('gfl.gfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%upper%fields%gfl,kind=c_int64_t),ubound(state%startup%loaded%input%upper%fields%gfl,kind=c_int64_t), &
                                     state%startup%loaded%input%upper%fields%gfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('gfl.gfl', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%upper%fields%gflslp)) then
      call observe_weather_primitive('gfl.gflslp', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%upper%fields%gflslp,kind=c_int64_t),ubound(state%startup%loaded%input%upper%fields%gflslp,kind=c_int64_t), &
                                     state%startup%loaded%input%upper%fields%gflslp, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('gfl.gflslp', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%upper%fields%gflpt)) then
      call observe_weather_primitive('gfl.gflpt', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%upper%fields%gflpt,kind=c_int64_t),ubound(state%startup%loaded%input%upper%fields%gflpt,kind=c_int64_t), &
                                     state%startup%loaded%input%upper%fields%gflpt, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('gfl.gflpt', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%upper%fields%gflpc)) then
      call observe_weather_primitive('gfl.gflpc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%upper%fields%gflpc,kind=c_int64_t),ubound(state%startup%loaded%input%upper%fields%gflpc,kind=c_int64_t), &
                                     state%startup%loaded%input%upper%fields%gflpc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('gfl.gflpc', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('gfl.pitch', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%upper%fields%pitch, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('gfl.levels', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%upper%fields%levels, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('gfl.blocks', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%upper%fields%blocks, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('gfl.ready', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%input%upper%fields%ready, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%next%gflt1)) then
      call observe_weather_primitive('next_time.gflt1', 2_c_int, 8_c_int, &
                 lbound(state%startup%loaded%next%gflt1, kind=c_int64_t), ubound(state%startup%loaded%next%gflt1, kind=c_int64_t), &
                                     state%startup%loaded%next%gflt1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('next_time.gflt1', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_sb)) then
      call observe_weather_primitive('surface.sp_sb', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_sb,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_sb,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_sb, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_sb', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_sg)) then
      call observe_weather_primitive('surface.sp_sg', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_sg,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_sg,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_sg, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_sg', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_sl)) then
      call observe_weather_primitive('surface.sp_sl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_sl,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_sl,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_sl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_sl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_rr)) then
      call observe_weather_primitive('surface.sp_rr', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_rr,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_rr,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_rr, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_rr', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_cl)) then
      call observe_weather_primitive('surface.sp_cl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_cl,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_cl,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_cl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_cl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_om)) then
      call observe_weather_primitive('surface.sp_om', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_om,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_om,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_om, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_om', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_ep)) then
      call observe_weather_primitive('surface.sp_ep', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_ep,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_ep,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_ep, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_ep', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_x2)) then
      call observe_weather_primitive('surface.sp_x2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_x2,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_x2,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_x2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_x2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sp_ci)) then
      call observe_weather_primitive('surface.sp_ci', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sp_ci,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sp_ci,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sp_ci, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sp_ci', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vf)) then
      call observe_weather_primitive('surface.sd_vf', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vf,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vf,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vf, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vf', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vp)) then
      call observe_weather_primitive('surface.sd_vp', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vp,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vp,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vp, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vp', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vv)) then
      call observe_weather_primitive('surface.sd_vv', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vv,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vv,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vv, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vv', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vn)) then
      call observe_weather_primitive('surface.sd_vn', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vn,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vn,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vn, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vn', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vh)) then
      call observe_weather_primitive('surface.sd_vh', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vh,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vh,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vh, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vh', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vk)) then
      call observe_weather_primitive('surface.sd_vk', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vk,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vk,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vk, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vk', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_va)) then
      call observe_weather_primitive('surface.sd_va', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_va,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_va,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_va, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_va', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vc)) then
      call observe_weather_primitive('surface.sd_vc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vc,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vc,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vc', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_v2)) then
      call observe_weather_primitive('surface.sd_v2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_v2,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_v2,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_v2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_v2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_v3)) then
      call observe_weather_primitive('surface.sd_v3', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_v3,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_v3,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_v3, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_v3', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vd)) then
      call observe_weather_primitive('surface.sd_vd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vd,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vd,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vd, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vd', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_sm)) then
      call observe_weather_primitive('surface.sd_sm', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_sm,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_sm,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_sm, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_sm', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_ws)) then
      call observe_weather_primitive('surface.sd_ws', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_ws,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_ws,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_ws, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_ws', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_ww)) then
      call observe_weather_primitive('surface.sd_ww', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_ww,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_ww,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_ww, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_ww', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_vx)) then
      call observe_weather_primitive('surface.sd_vx', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_vx,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_vx,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_vx, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_vx', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_xa)) then
      call observe_weather_primitive('surface.sd_xa', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_xa,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_xa,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_xa, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_xa', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_xr)) then
      call observe_weather_primitive('surface.sd_xr', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_xr,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_xr,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_xr, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_xr', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_x2)) then
      call observe_weather_primitive('surface.sd_x2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_x2,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_x2,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_x2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_x2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_sfl)) then
      call observe_weather_primitive('surface.sd_sfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_sfl,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_sfl,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_sfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_sfl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_sfo)) then
      call observe_weather_primitive('surface.sd_sfo', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_sfo,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_sfo,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_sfo, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_sfo', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_pf)) then
      call observe_weather_primitive('surface.sd_pf', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_pf,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_pf,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_pf, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_pf', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_di)) then
      call observe_weather_primitive('surface.sd_di', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_di,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_di,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_di, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_di', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_oc)) then
      call observe_weather_primitive('surface.sd_oc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_oc,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_oc,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_oc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_oc', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_xp)) then
      call observe_weather_primitive('surface.sd_xp', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_xp,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_xp,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_xp, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_xp', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%input%surface_arrays%sd_xp2)) then
      call observe_weather_primitive('surface.sd_xp2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%input%surface_arrays%sd_xp2,kind=c_int64_t),ubound(state%startup%loaded%input%surface_arrays%sd_xp2,kind=c_int64_t), &
                                     state%startup%loaded%input%surface_arrays%sd_xp2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('surface.sd_xp2', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.betadt', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%betadt, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.lsetfstat', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%lsetfstat, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.ncurrent_iter', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%ncurrent_iter, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.nvtend', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%nvtend, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.mu_savtend', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%mu_savtend, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.mv_savtend', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%mv_savtend, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('dynamic.mt_savtend', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%dynamic%mt_savtend, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%dynamic%rsavedp)) then
      call observe_weather_primitive('dynamic.rsavedp', 2_c_int, 8_c_int, &
       lbound(state%startup%loaded%dynamic%rsavedp, kind=c_int64_t), ubound(state%startup%loaded%dynamic%rsavedp, kind=c_int64_t), &
                                     state%startup%loaded%dynamic%rsavedp, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('dynamic.rsavedp', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%dynamic%rslwx)) then
      call observe_weather_primitive('dynamic.rslwx', 2_c_int, 8_c_int, &
           lbound(state%startup%loaded%dynamic%rslwx, kind=c_int64_t), ubound(state%startup%loaded%dynamic%rslwx, kind=c_int64_t), &
                                     state%startup%loaded%dynamic%rslwx, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('dynamic.rslwx', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%dynamic%savtend)) then
      call observe_weather_primitive('dynamic.savtend', 2_c_int, 8_c_int, &
       lbound(state%startup%loaded%dynamic%savtend, kind=c_int64_t), ubound(state%startup%loaded%dynamic%savtend, kind=c_int64_t), &
                                     state%startup%loaded%dynamic%savtend, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('dynamic.savtend', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%ecphysics%rustrti)) then
      call observe_weather_primitive('ecphysics.rustrti', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%ecphysics%rustrti,kind=c_int64_t),ubound(state%startup%loaded%fields%ecphysics%rustrti,kind=c_int64_t), &
                                     state%startup%loaded%fields%ecphysics%rustrti, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ecphysics.rustrti', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%ecphysics%rvstrti)) then
      call observe_weather_primitive('ecphysics.rvstrti', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%ecphysics%rvstrti,kind=c_int64_t),ubound(state%startup%loaded%fields%ecphysics%rvstrti,kind=c_int64_t), &
                                     state%startup%loaded%fields%ecphysics%rvstrti, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ecphysics.rvstrti', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%ecphysics%rahfsti)) then
      call observe_weather_primitive('ecphysics.rahfsti', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%ecphysics%rahfsti,kind=c_int64_t),ubound(state%startup%loaded%fields%ecphysics%rahfsti,kind=c_int64_t), &
                                     state%startup%loaded%fields%ecphysics%rahfsti, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ecphysics.rahfsti', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%ecphysics%revapti)) then
      call observe_weather_primitive('ecphysics.revapti', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%ecphysics%revapti,kind=c_int64_t),ubound(state%startup%loaded%fields%ecphysics%revapti,kind=c_int64_t), &
                                     state%startup%loaded%fields%ecphysics%revapti, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ecphysics.revapti', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%ecphysics%rtskti)) then
      call observe_weather_primitive('ecphysics.rtskti', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%ecphysics%rtskti,kind=c_int64_t),ubound(state%startup%loaded%fields%ecphysics%rtskti,kind=c_int64_t), &
                                     state%startup%loaded%fields%ecphysics%rtskti, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ecphysics.rtskti', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('ecphysics.lphys_mwave_filled_in', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%ecphysics%lphys_mwave_filled_in, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%ecphysics%phys_mwave)) then
      call observe_weather_primitive('ecphysics.phys_mwave', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%ecphysics%phys_mwave,kind=c_int64_t),ubound(state%startup%loaded%fields%ecphysics%phys_mwave,kind=c_int64_t), &
                                     state%startup%loaded%fields%ecphysics%phys_mwave, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ecphysics.phys_mwave', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('ecphysics.storage_metadata_written', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%ecphysics%storage_metadata_written, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lgradgp', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lgradgp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.ldry_ecmwf', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%ldry_ecmwf, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lmusclfa', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lmusclfa, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lforcewr', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lforcewr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.ltestinc', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%ltestinc, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lbfasecv', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lbfasecv, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lusekf_ref', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lusekf_ref, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.luse_smos_tb', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%luse_smos_tb, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.npol_max', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%npol_max, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.nang_max', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%nang_max, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lesmos_active', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lesmos_active, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lesmap_active', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lesmap_active, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.lesmos_sekf', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%lesmos_sekf, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.legbrad_active', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%legbrad_active, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('physics_runtime.leraingg_active', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%physics_runtime%leraingg_active, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%physics_runtime%gpforceu)) then
      call observe_weather_primitive('physics_runtime.gpforceu', 2_c_int, 8_c_int, &
                   lbound(state%physics_runtime%gpforceu, kind=c_int64_t), ubound(state%physics_runtime%gpforceu, kind=c_int64_t), &
                                     state%physics_runtime%gpforceu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('physics_runtime.gpforceu', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%physics_runtime%gpforcev)) then
      call observe_weather_primitive('physics_runtime.gpforcev', 2_c_int, 8_c_int, &
                   lbound(state%physics_runtime%gpforcev, kind=c_int64_t), ubound(state%physics_runtime%gpforcev, kind=c_int64_t), &
                                     state%physics_runtime%gpforcev, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('physics_runtime.gpforcev', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%physics_runtime%gpforcet)) then
      call observe_weather_primitive('physics_runtime.gpforcet', 2_c_int, 8_c_int, &
                   lbound(state%physics_runtime%gpforcet, kind=c_int64_t), ubound(state%physics_runtime%gpforcet, kind=c_int64_t), &
                                     state%physics_runtime%gpforcet, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('physics_runtime.gpforcet', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%physics_runtime%gpforceq)) then
      call observe_weather_primitive('physics_runtime.gpforceq', 2_c_int, 8_c_int, &
                   lbound(state%physics_runtime%gpforceq, kind=c_int64_t), ubound(state%physics_runtime%gpforceq, kind=c_int64_t), &
                                     state%physics_runtime%gpforceq, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('physics_runtime.gpforceq', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lejk', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lejk, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lgwdiags_on', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lgwdiags_on, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.liau', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%liau, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.mysetv', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%mysetv, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.nouttype', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%nouttype, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.nprtrn', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%nprtrn, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.nprtrv', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%nprtrv, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lnudg', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lnudg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.nrsaccfrq', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%nrsaccfrq, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.nfrres', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%nfrres, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lrlxg', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lrlxg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.restart', 4_c_int, int(len(state%startup%loop_data%restart), c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%restart, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.npromatr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%npromatr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lecv', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lecv, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lmoderr', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lmoderr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.lvareps', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%lvareps, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.vp00', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%vp00, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loop_data%spvor_flt)) then
      call observe_weather_primitive('filtered_history.spvor_flt', 2_c_int, 8_c_int, &
             lbound(state%startup%loop_data%spvor_flt, kind=c_int64_t), ubound(state%startup%loop_data%spvor_flt, kind=c_int64_t), &
                                     state%startup%loop_data%spvor_flt, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('filtered_history.spvor_flt', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loop_data%spdiv_flt)) then
      call observe_weather_primitive('filtered_history.spdiv_flt', 2_c_int, 8_c_int, &
             lbound(state%startup%loop_data%spdiv_flt, kind=c_int64_t), ubound(state%startup%loop_data%spdiv_flt, kind=c_int64_t), &
                                     state%startup%loop_data%spdiv_flt, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('filtered_history.spdiv_flt', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.nrests', 1_c_int, 4_c_int, &
                   lbound(state%startup%loop_data%nrests, kind=c_int64_t), ubound(state%startup%loop_data%nrests, kind=c_int64_t), &
                                   state%startup%loop_data%nrests, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loop_data%spub_flt)) then
      call observe_weather_primitive('filtered_history.spub_flt', 2_c_int, 8_c_int, &
               lbound(state%startup%loop_data%spub_flt, kind=c_int64_t), ubound(state%startup%loop_data%spub_flt, kind=c_int64_t), &
                                     state%startup%loop_data%spub_flt, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('filtered_history.spub_flt', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loop_data%spvb_flt)) then
      call observe_weather_primitive('filtered_history.spvb_flt', 2_c_int, 8_c_int, &
               lbound(state%startup%loop_data%spvb_flt, kind=c_int64_t), ubound(state%startup%loop_data%spvb_flt, kind=c_int64_t), &
                                     state%startup%loop_data%spvb_flt, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('filtered_history.spvb_flt', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('filtered_history.owned_mask', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loop_data%owned_mask, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.nrcp', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%nrcp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.no3cmip', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%no3cmip, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.nghgcmip', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%nghgcmip, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.ncmipfixyr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%ncmipfixyr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.ncurryr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%ncurryr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.ghgdatadir', 4_c_int, int(len(state%startup%forcing%cmip%ghgdatadir), c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%ghgdatadir, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.csolardata', 4_c_int, int(len(state%startup%forcing%cmip%csolardata), c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%csolardata, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.co3datadir', 4_c_int, int(len(state%startup%forcing%cmip%co3datadir), c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%co3datadir, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('cmip.co3datafil', 4_c_int, int(len(state%startup%forcing%cmip%co3datafil), c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%cmip%co3datafil, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%cmip%zozcl)) then
      call observe_weather_primitive('cmip.zozcl', 2_c_int, 8_c_int, &
               lbound(state%startup%forcing%cmip%zozcl, kind=c_int64_t), ubound(state%startup%forcing%cmip%zozcl, kind=c_int64_t), &
                                     state%startup%forcing%cmip%zozcl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('cmip.zozcl', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%cmip%rsinc1)) then
      call observe_weather_primitive('cmip.rsinc1', 2_c_int, 8_c_int, &
             lbound(state%startup%forcing%cmip%rsinc1, kind=c_int64_t), ubound(state%startup%forcing%cmip%rsinc1, kind=c_int64_t), &
                                     state%startup%forcing%cmip%rsinc1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('cmip.rsinc1', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%cmip%rproc1)) then
      call observe_weather_primitive('cmip.rproc1', 2_c_int, 8_c_int, &
             lbound(state%startup%forcing%cmip%rproc1, kind=c_int64_t), ubound(state%startup%forcing%cmip%rproc1, kind=c_int64_t), &
                                     state%startup%forcing%cmip%rproc1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('cmip.rproc1', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%cmip%rlatcli)) then
      call observe_weather_primitive('cmip.rlatcli', 2_c_int, 8_c_int, &
           lbound(state%startup%forcing%cmip%rlatcli, kind=c_int64_t), ubound(state%startup%forcing%cmip%rlatcli, kind=c_int64_t), &
                                     state%startup%forcing%cmip%rlatcli, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('cmip.rlatcli', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%cmip%rloncli)) then
      call observe_weather_primitive('cmip.rloncli', 2_c_int, 8_c_int, &
           lbound(state%startup%forcing%cmip%rloncli, kind=c_int64_t), ubound(state%startup%forcing%cmip%rloncli, kind=c_int64_t), &
                                     state%startup%forcing%cmip%rloncli, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('cmip.rloncli', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%cmip%rozt1)) then
      call observe_weather_primitive('cmip.rozt1', 2_c_int, 8_c_int, &
               lbound(state%startup%forcing%cmip%rozt1, kind=c_int64_t), ubound(state%startup%forcing%cmip%rozt1, kind=c_int64_t), &
                                     state%startup%forcing%cmip%rozt1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('cmip.rozt1', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%ozone_chemistry%toz2dg)) then
      call observe_weather_primitive('ozone_chemistry.toz2dg', 2_c_int, 8_c_int, &
      lbound(state%startup%forcing%ozone_chemistry%toz2dg,kind=c_int64_t),ubound(state%startup%forcing%ozone_chemistry%toz2dg,kind=c_int64_t), &
                                     state%startup%forcing%ozone_chemistry%toz2dg, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ozone_chemistry.toz2dg', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%ozone_chemistry%toz2dl)) then
      call observe_weather_primitive('ozone_chemistry.toz2dl', 2_c_int, 8_c_int, &
      lbound(state%startup%forcing%ozone_chemistry%toz2dl,kind=c_int64_t),ubound(state%startup%forcing%ozone_chemistry%toz2dl,kind=c_int64_t), &
                                     state%startup%forcing%ozone_chemistry%toz2dl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ozone_chemistry.toz2dl', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%forcing%ozone_chemistry%toz3dbl)) then
      call observe_weather_primitive('ozone_chemistry.toz3dbl', 2_c_int, 8_c_int, &
      lbound(state%startup%forcing%ozone_chemistry%toz3dbl,kind=c_int64_t),ubound(state%startup%forcing%ozone_chemistry%toz3dbl,kind=c_int64_t), &
                                     state%startup%forcing%ozone_chemistry%toz3dbl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('ozone_chemistry.toz3dbl', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('ozone_chemistry.teecl2', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%ozone_chemistry%teecl2, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_clock.rcodecm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%radiation_clock%rcodecm, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_clock.rsidecm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%radiation_clock%rsidecm, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_clock.rcovsrm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%radiation_clock%rcovsrm, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_clock.rsivsrm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%radiation_clock%rsivsrm, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_clock.rsovrm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%radiation_clock%rsovrm, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_clock.rwsovrm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%forcing%radiation_clock%rwsovrm, 1_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtd)) then
      call observe_weather_primitive('radiation_flux.emtd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtd,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%emtd, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.emtd', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%trsw)) then
      call observe_weather_primitive('radiation_flux.trsw', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%trsw,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%trsw,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%trsw, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.trsw', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtc)) then
      call observe_weather_primitive('radiation_flux.emtc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%emtc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.emtc', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%trsc)) then
      call observe_weather_primitive('radiation_flux.trsc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%trsc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%trsc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%trsc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.trsc', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtu)) then
      call observe_weather_primitive('radiation_flux.emtu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%emtu,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%emtu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.emtu', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%tauaer)) then
      call observe_weather_primitive('radiation_flux.tauaer', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%tauaer,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%tauaer,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%tauaer, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.tauaer', 4_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswd)) then
      call observe_weather_primitive('radiation_flux.srswd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswd,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswd, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswd', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdc)) then
      call observe_weather_primitive('radiation_flux.srlwdc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srlwdc', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwd)) then
      call observe_weather_primitive('radiation_flux.srlwd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwd,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwd, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srlwd', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdc)) then
      call observe_weather_primitive('radiation_flux.srswdc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswdc', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdcs)) then
      call observe_weather_primitive('radiation_flux.srswdcs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdcs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdcs,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdcs, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswdcs', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdcs)) then
      call observe_weather_primitive('radiation_flux.srlwdcs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdcs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdcs,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srlwdcs, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srlwdcs', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdv)) then
      call observe_weather_primitive('radiation_flux.srswdv', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdv,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdv,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswdv, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswdv', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswduv)) then
      call observe_weather_primitive('radiation_flux.srswduv', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswduv,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswduv,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswduv, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswduv', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%edro)) then
      call observe_weather_primitive('radiation_flux.edro', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%edro,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%edro,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%edro, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.edro', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswpar)) then
      call observe_weather_primitive('radiation_flux.srswpar', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswpar,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswpar,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswpar, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswpar', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswuvb)) then
      call observe_weather_primitive('radiation_flux.srswuvb', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswuvb,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswuvb,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswuvb, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswuvb', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswparc)) then
      call observe_weather_primitive('radiation_flux.srswparc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswparc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswparc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswparc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswparc', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswtinc)) then
      call observe_weather_primitive('radiation_flux.srswtinc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswtinc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srswtinc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srswtinc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srswtinc', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srfdir)) then
      call observe_weather_primitive('radiation_flux.srfdir', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srfdir,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srfdir,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srfdir, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srfdir', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%srcdir)) then
      call observe_weather_primitive('radiation_flux.srcdir', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srcdir,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%srcdir,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%srcdir, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.srcdir', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%fluxes%rmoon)) then
      call observe_weather_primitive('radiation_flux.rmoon', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%rmoon,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%rmoon,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%rmoon, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.rmoon', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%fluxes%derivativelw)) then
      call observe_weather_primitive('radiation_flux.derivativelw', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%fluxes%derivativelw,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%fluxes%derivativelw,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%fluxes%derivativelw, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_flux.derivativelw', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.naer', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%naer, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nmode', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nmode, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nozocl', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nozocl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradfr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradfr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradpfr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradpfr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradpla', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradpla, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradint', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradint, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradres', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradres, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradnfr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradnfr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradsfr', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradsfr, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nrade1h', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nrade1h, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nrade3h', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nrade3h, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradelg', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradelg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.novlp', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%novlp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nrproma', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nrproma, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nsw', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nsw, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nswnl', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nswnl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nswtl', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nswtl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlwemiss', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlwemiss, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlwout', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlwout, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ntsw', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ntsw, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nuv', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nuv, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ncsradf', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ncsradf, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.niceopt', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%niceopt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nliqopt', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nliqopt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nswiceopt', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nswiceopt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nswliqopt', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nswliqopt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlwiceopt', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlwiceopt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlwliqopt', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlwliqopt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradip', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradip, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nradlp', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nradlp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ninhom', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ninhom, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlayinh', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlayinh, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlngr1h', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlngr1h, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.npertaer', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%npertaer, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.npertoz', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%npertoz, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nscen', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nscen, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nhincsol', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nhincsol, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nmcica', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nmcica, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nghgrad', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nghgrad, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ndecolat', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ndecolat, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nminice', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nminice, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nvolcvert', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nvolcvert, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nredglw', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nredglw, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nredgsw', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nredgsw, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.naermacc', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%naermacc, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nmclat', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nmclat, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nmclon', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nmclon, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nmclev', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nmclev, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nmcvar', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nmcvar, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nspmapl', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%nspmapl,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%nspmapl,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nspmapl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nspmaps', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%nspmaps,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%nspmaps,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nspmaps, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlwscattering', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlwscattering, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nswsolver', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nswsolver, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nlwsolver', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nlwsolver, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.kmodts', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%kmodts, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nsolarspectrum', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nsolarspectrum, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.nswwvcontinuum', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%nswwvcontinuum, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ndumpbadinputs', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ndumpbadinputs, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ndumpinputs', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ndumpinputs, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ncloudoverlap', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ncloudoverlap, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rcloud_frac_std', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rcloud_frac_std, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rcloud_separation_scale_toa', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                       state%startup%loaded%storage%ecmwf%radiation%radiation%rcloud_separation_scale_toa, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rcloud_separation_scale_surf', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                      state%startup%loaded%storage%ecmwf%radiation%radiation%rcloud_separation_scale_surf, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lfu_lw_ice_optics_bug', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                             state%startup%loaded%storage%ecmwf%radiation%radiation%lfu_lw_ice_optics_bug, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.linterpincloudmean', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%radiation%linterpincloudmean, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lerad1h', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lerad1h, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lepo3ra', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lepo3ra, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lonewsw', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lonewsw, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lecsrad', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lecsrad, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lrrtm', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lrrtm, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lsrtm', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lsrtm, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ldiffc', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ldiffc, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lhvolca', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lhvolca, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lnewaer', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lnewaer, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lnotroaer', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lnotroaer, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lrayl', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lrayl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.loptrproma', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%loptrproma, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.leco2var', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%leco2var, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lhghg', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lhghg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.leso4his', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%leso4his, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.letracgms', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%letracgms, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.laerclim', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%laerclim, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.laervisi', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%laervisi, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.laer3d', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%laer3d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lvolcspec', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lvolcspec, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lvolcdamp', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lvolcdamp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ldiagforcing', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ldiagforcing, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.laeradcli', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%laeradcli, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.laeradjdu', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%laeradjdu, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lapproxlwupdate', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lapproxlwupdate, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lapproxswupdate', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lapproxswupdate, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lmannersswupdate', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                  state%startup%loaded%storage%ecmwf%radiation%radiation%lmannersswupdate, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lcentredtimesza', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lcentredtimesza, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.laveragesza', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%laveragesza, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lecompgrid', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lecompgrid, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lusepre2017rad', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lusepre2017rad, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lduseason', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lduseason, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lccnl', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lccnl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lccno', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lccno, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.lperpet', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%lperpet, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.raovlp', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%raovlp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rbovlp', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rbovlp, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rccnlnd', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rccnlnd, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rccnsea', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rccnsea, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.ledbug', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%ledbug, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rpertoz', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rpertoz, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rre2de', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rre2de, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rlwinhf', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rlwinhf, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rswinhf', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rswinhf, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rminice', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rminice, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rvolcspec', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%rvolcspec,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%rvolcspec,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rvolcspec, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rns', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rns, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.rsigair', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%rsigair, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.raeshss', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%raeshss, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.raeshdu', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%raeshdu, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.raeshom', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%raeshom, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.raeshbc', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%raeshbc, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.raeshsu', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%raeshsu, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.trbkg', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%trbkg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.stbkg', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%stbkg, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.cghgclimfile',4_c_int,int(len(state%startup%loaded%storage%ecmwf%radiation%radiation%cghgclimfile),c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%radiation%cghgclimfile, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.cghgtimeseriesfile',4_c_int,int(len(state%startup%loaded%storage%ecmwf%radiation%radiation%cghgtimeseriesfile),c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%radiation%cghgtimeseriesfile, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_time_dependent.csolarirradiancefile',4_c_int,int(len(state%startup%loaded%storage%ecmwf%radiation%radiation%csolarirradiancefile),c_int), &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                              state%startup%loaded%storage%ecmwf%radiation%radiation%csolarirradiancefile, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaess)) then
      call observe_weather_primitive('radiation_time_dependent.cvdaess', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaess,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaess,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaess, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_time_dependent.cvdaess', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaedu)) then
      call observe_weather_primitive('radiation_time_dependent.cvdaedu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaedu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaedu,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaedu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_time_dependent.cvdaedu', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaeom)) then
      call observe_weather_primitive('radiation_time_dependent.cvdaeom', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaeom,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaeom,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaeom, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_time_dependent.cvdaeom', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaebc)) then
      call observe_weather_primitive('radiation_time_dependent.cvdaebc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaebc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaebc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaebc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_time_dependent.cvdaebc', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaesu)) then
      call observe_weather_primitive('radiation_time_dependent.cvdaesu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaesu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaesu,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%radiation%cvdaesu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_time_dependent.cvdaesu', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaes)) then
      call observe_weather_primitive('aerosol_time_dependent.cvdaes', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaes,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaes,kind=c_int64_t), &
                                 state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaes, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('aerosol_time_dependent.cvdaes', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdael)) then
      call observe_weather_primitive('aerosol_time_dependent.cvdael', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdael,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdael,kind=c_int64_t), &
                                 state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdael, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('aerosol_time_dependent.cvdael', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaeu)) then
      call observe_weather_primitive('aerosol_time_dependent.cvdaeu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaeu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaeu,kind=c_int64_t), &
                                 state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaeu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('aerosol_time_dependent.cvdaeu', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaed)) then
      call observe_weather_primitive('aerosol_time_dependent.cvdaed', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaed,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaed,kind=c_int64_t), &
                                 state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%cvdaed, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('aerosol_time_dependent.cvdaed', 1_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raesc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raesc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raesc,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raesc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raess', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raess,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raess,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raess, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raelc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raelc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raelc,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raelc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raels', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raels,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raels,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raels, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raeuc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeuc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeuc,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeuc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raeus', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeus,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeus,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeus, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raedc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raedc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raedc,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raedc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.raeds', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeds,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeds,kind=c_int64_t), &
                                  state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%raeds, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeops', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeops, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeopl', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeopl, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeopu', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeopu, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeopd', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeopd, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rctrbga', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rctrbga, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcvobga', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcvobga, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcstbga', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcstbga, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rctrpt', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                 state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rctrpt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeadk', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeadk,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeadk,kind=c_int64_t), &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeadk, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeadm', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeadm, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('aerosol_time_dependent.rcaeros', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                state%startup%loaded%storage%ecmwf%radiation%aerosol_distribution%rcaeros, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%ozone%zozcl)) then
      call observe_weather_primitive('radiation_ozone.zozcl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%zozcl,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%zozcl,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%ozone%zozcl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_ozone.zozcl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%ozone%zozclaqua)) then
      call observe_weather_primitive('radiation_ozone.zozclaqua', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%zozclaqua,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%zozclaqua,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%ozone%zozclaqua, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_ozone.zozclaqua', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.cozqc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozqc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozqc,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%cozqc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.cozqs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozqs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozqs,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%cozqs, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.cozhc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozhc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozhc,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%cozhc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.cozhs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozhs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%cozhs,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%cozhs, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.rsinc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%rsinc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%rsinc,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%rsinc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.rozt', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%rozt,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%rozt,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%rozt, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_ozone.rproc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%ozone%rproc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%ozone%rproc,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%ozone%rproc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.initial_date', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%initial_date, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.initial_seconds', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%initial_seconds, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.initial_seconds_j2000', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%initial_seconds_j2000, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.control', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%control, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.first_step', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%first_step, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.total_steps', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%total_steps, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.model_number', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%model_number, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.retained_control', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%retained_control, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.current_step', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%current_step, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('clock.dt', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%dt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.first_step', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%first_step, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.total_steps', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%total_steps, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.stop',4_c_int,int(len(state%startup%initial%controls%clock%integration%stop),c_int), &
      lbound(state%startup%initial%controls%clock%integration%stop,kind=c_int64_t),ubound(state%startup%initial%controls%clock%integration%stop,kind=c_int64_t), &
                                   state%startup%initial%controls%clock%integration%stop, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.date_time_flags', 1_c_int, 4_c_int, &
      lbound(state%startup%initial%controls%clock%integration%date_time_flags,kind=c_int64_t),ubound(state%startup%initial%controls%clock%integration%date_time_flags,kind=c_int64_t), &
                                   state%startup%initial%controls%clock%integration%date_time_flags, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.initial_iteration', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%initial_iteration, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.reserved', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%reserved, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.relative_seconds', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%relative_seconds, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.initial_seconds_j2000', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%initial_seconds_j2000, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.initial_solar', 2_c_int, 8_c_int, &
      lbound(state%startup%initial%controls%clock%integration%initial_solar,kind=c_int64_t),ubound(state%startup%initial%controls%clock%integration%initial_solar,kind=c_int64_t), &
                                   state%startup%initial%controls%clock%integration%initial_solar, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.retained_solar', 2_c_int, 8_c_int, &
      lbound(state%startup%initial%controls%clock%integration%retained_solar,kind=c_int64_t),ubound(state%startup%initial%controls%clock%integration%retained_solar,kind=c_int64_t), &
                                   state%startup%initial%controls%clock%integration%retained_solar, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.initial_orbit', 2_c_int, 8_c_int, &
      lbound(state%startup%initial%controls%clock%integration%initial_orbit,kind=c_int64_t),ubound(state%startup%initial%controls%clock%integration%initial_orbit,kind=c_int64_t), &
                                   state%startup%initial%controls%clock%integration%initial_orbit, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.first_dt', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%first_dt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.second_dt', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%initial%controls%clock%integration%second_dt, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('integration_clock.work', 2_c_int, 8_c_int, &
      lbound(state%startup%initial%controls%clock%integration%work,kind=c_int64_t),ubound(state%startup%initial%controls%clock%integration%work,kind=c_int64_t), &
                                   state%startup%initial%controls%clock%integration%work, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('mass.gmassi', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%mass%gmassi, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('mass.gmass0', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%mass%gmass0, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('mass.gmassinc', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%mass%gmassinc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.lcreated', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%lcreated, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.mstortype', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%mstortype, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.m_attach', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%m_attach, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.nfields', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%nfields, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.nfields_on', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%nfields_on, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.nleveltypes', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%nleveltypes, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.ndim3types', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%ndim3types, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.npoints', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%npoints, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.ilen_storage1d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%ilen_storage1d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.nhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%nhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.nblocks', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%nblocks, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.l_attach_gfl_nproma_fixed', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%l_attach_gfl_nproma_fixed, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t0.lhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t0%lhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%nlevels)) then
      call observe_weather_primitive('field_t0.nlevels', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%nlevels,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%nlevels,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%nlevels, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.nlevels', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%ndim3s)) then
      call observe_weather_primitive('field_t0.ndim3s', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%ndim3s,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%ndim3s,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%ndim3s, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.ndim3s', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%npoints_block)) then
      call observe_weather_primitive('field_t0.npoints_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%npoints_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%npoints_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%npoints_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.npoints_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mall_fields)) then
      call observe_weather_primitive('field_t0.mall_fields', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mall_fields,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mall_fields,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mall_fields, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mall_fields', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%index_last_block)) then
      call observe_weather_primitive('field_t0.index_last_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%index_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%index_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%index_last_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.index_last_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%clevtype)) then
      call observe_weather_primitive('field_t0.clevtype', 4_c_int, int(len(state%startup%loaded%fields%field_t0%clevtype), c_int), &
      lbound(state%startup%loaded%fields%field_t0%clevtype,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%clevtype,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%clevtype, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.clevtype', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%storage_last_block)) then
      call observe_weather_primitive('field_t0.storage_last_block', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_t0%storage_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%storage_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%storage_last_block, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.storage_last_block', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%unassigned_gfl)) then
      call observe_weather_primitive('field_t0.unassigned_gfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_t0%unassigned_gfl,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%unassigned_gfl,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%unassigned_gfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.unassigned_gfl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt9_map)) then
      call observe_weather_primitive('field_t0.mt9_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt9_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt9_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt9_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt9_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt1_map)) then
      call observe_weather_primitive('field_t0.mt1_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt1_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt1_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt1_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt1_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt0_map)) then
      call observe_weather_primitive('field_t0.mt0_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt0_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt0_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt0_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt0_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mpc_map)) then
      call observe_weather_primitive('field_t0.mpc_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mpc_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mpc_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mpc_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mpc_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mpt_map)) then
      call observe_weather_primitive('field_t0.mpt_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mpt_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mpt_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mpt_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mpt_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt0_dl_map)) then
      call observe_weather_primitive('field_t0.mt0_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt0_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt0_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt0_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt0_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt0_dm_map)) then
      call observe_weather_primitive('field_t0.mt0_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt0_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt0_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt0_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt0_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt9_dl_map)) then
      call observe_weather_primitive('field_t0.mt9_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt9_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt9_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt9_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt9_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt9_dm_map)) then
      call observe_weather_primitive('field_t0.mt9_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt9_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt9_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt9_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt9_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t0%mt0_size)) then
      call observe_weather_primitive('field_t0.mt0_size', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t0%mt0_size,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t0%mt0_size,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t0%mt0_size, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t0.mt0_size', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.lcreated', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%lcreated, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.mstortype', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%mstortype, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.m_attach', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%m_attach, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.nfields', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%nfields, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.nfields_on', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%nfields_on, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.nleveltypes', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%nleveltypes, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.ndim3types', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%ndim3types, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.npoints', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%npoints, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.ilen_storage1d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%ilen_storage1d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.nhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%nhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.nblocks', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%nblocks, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.l_attach_gfl_nproma_fixed', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%l_attach_gfl_nproma_fixed, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t1.lhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t1%lhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%nlevels)) then
      call observe_weather_primitive('field_t1.nlevels', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%nlevels,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%nlevels,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%nlevels, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.nlevels', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%ndim3s)) then
      call observe_weather_primitive('field_t1.ndim3s', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%ndim3s,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%ndim3s,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%ndim3s, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.ndim3s', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%npoints_block)) then
      call observe_weather_primitive('field_t1.npoints_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%npoints_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%npoints_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%npoints_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.npoints_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mall_fields)) then
      call observe_weather_primitive('field_t1.mall_fields', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mall_fields,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mall_fields,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mall_fields, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mall_fields', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%index_last_block)) then
      call observe_weather_primitive('field_t1.index_last_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%index_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%index_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%index_last_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.index_last_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%clevtype)) then
      call observe_weather_primitive('field_t1.clevtype', 4_c_int, int(len(state%startup%loaded%fields%field_t1%clevtype), c_int), &
      lbound(state%startup%loaded%fields%field_t1%clevtype,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%clevtype,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%clevtype, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.clevtype', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%storage_last_block)) then
      call observe_weather_primitive('field_t1.storage_last_block', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_t1%storage_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%storage_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%storage_last_block, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.storage_last_block', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%unassigned_gfl)) then
      call observe_weather_primitive('field_t1.unassigned_gfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_t1%unassigned_gfl,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%unassigned_gfl,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%unassigned_gfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.unassigned_gfl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt9_map)) then
      call observe_weather_primitive('field_t1.mt9_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt9_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt9_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt9_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt9_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt1_map)) then
      call observe_weather_primitive('field_t1.mt1_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt1_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt1_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt1_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt1_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt0_map)) then
      call observe_weather_primitive('field_t1.mt0_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt0_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt0_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt0_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt0_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mpc_map)) then
      call observe_weather_primitive('field_t1.mpc_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mpc_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mpc_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mpc_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mpc_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mpt_map)) then
      call observe_weather_primitive('field_t1.mpt_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mpt_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mpt_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mpt_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mpt_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt0_dl_map)) then
      call observe_weather_primitive('field_t1.mt0_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt0_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt0_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt0_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt0_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt0_dm_map)) then
      call observe_weather_primitive('field_t1.mt0_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt0_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt0_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt0_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt0_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt9_dl_map)) then
      call observe_weather_primitive('field_t1.mt9_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt9_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt9_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt9_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt9_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt9_dm_map)) then
      call observe_weather_primitive('field_t1.mt9_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt9_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt9_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt9_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt9_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t1%mt0_size)) then
      call observe_weather_primitive('field_t1.mt0_size', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t1%mt0_size,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t1%mt0_size,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t1%mt0_size, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t1.mt0_size', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.lcreated', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%lcreated, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.mstortype', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%mstortype, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.m_attach', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%m_attach, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.nfields', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%nfields, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.nfields_on', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%nfields_on, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.nleveltypes', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%nleveltypes, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.ndim3types', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%ndim3types, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.npoints', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%npoints, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.ilen_storage1d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%ilen_storage1d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.nhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%nhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.nblocks', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%nblocks, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.l_attach_gfl_nproma_fixed', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%l_attach_gfl_nproma_fixed, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_t9.lhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_t9%lhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%nlevels)) then
      call observe_weather_primitive('field_t9.nlevels', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%nlevels,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%nlevels,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%nlevels, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.nlevels', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%ndim3s)) then
      call observe_weather_primitive('field_t9.ndim3s', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%ndim3s,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%ndim3s,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%ndim3s, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.ndim3s', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%npoints_block)) then
      call observe_weather_primitive('field_t9.npoints_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%npoints_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%npoints_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%npoints_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.npoints_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mall_fields)) then
      call observe_weather_primitive('field_t9.mall_fields', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mall_fields,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mall_fields,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mall_fields, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mall_fields', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%index_last_block)) then
      call observe_weather_primitive('field_t9.index_last_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%index_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%index_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%index_last_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.index_last_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%clevtype)) then
      call observe_weather_primitive('field_t9.clevtype', 4_c_int, int(len(state%startup%loaded%fields%field_t9%clevtype), c_int), &
      lbound(state%startup%loaded%fields%field_t9%clevtype,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%clevtype,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%clevtype, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.clevtype', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%storage_last_block)) then
      call observe_weather_primitive('field_t9.storage_last_block', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_t9%storage_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%storage_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%storage_last_block, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.storage_last_block', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%unassigned_gfl)) then
      call observe_weather_primitive('field_t9.unassigned_gfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_t9%unassigned_gfl,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%unassigned_gfl,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%unassigned_gfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.unassigned_gfl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt9_map)) then
      call observe_weather_primitive('field_t9.mt9_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt9_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt9_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt9_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt9_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt1_map)) then
      call observe_weather_primitive('field_t9.mt1_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt1_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt1_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt1_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt1_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt0_map)) then
      call observe_weather_primitive('field_t9.mt0_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt0_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt0_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt0_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt0_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mpc_map)) then
      call observe_weather_primitive('field_t9.mpc_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mpc_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mpc_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mpc_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mpc_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mpt_map)) then
      call observe_weather_primitive('field_t9.mpt_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mpt_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mpt_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mpt_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mpt_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt0_dl_map)) then
      call observe_weather_primitive('field_t9.mt0_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt0_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt0_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt0_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt0_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt0_dm_map)) then
      call observe_weather_primitive('field_t9.mt0_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt0_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt0_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt0_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt0_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt9_dl_map)) then
      call observe_weather_primitive('field_t9.mt9_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt9_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt9_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt9_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt9_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt9_dm_map)) then
      call observe_weather_primitive('field_t9.mt9_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt9_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt9_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt9_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt9_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_t9%mt0_size)) then
      call observe_weather_primitive('field_t9.mt0_size', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_t9%mt0_size,kind=c_int64_t),ubound(state%startup%loaded%fields%field_t9%mt0_size,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_t9%mt0_size, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_t9.mt0_size', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.lcreated', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%lcreated, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.mstortype', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%mstortype, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.m_attach', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%m_attach, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.nfields', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%nfields, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.nfields_on', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%nfields_on, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.nleveltypes', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%nleveltypes, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.ndim3types', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%ndim3types, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.npoints', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%npoints, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.ilen_storage1d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%ilen_storage1d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.nhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%nhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.nblocks', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%nblocks, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.l_attach_gfl_nproma_fixed', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%l_attach_gfl_nproma_fixed, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pc.lhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pc%lhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%nlevels)) then
      call observe_weather_primitive('field_pc.nlevels', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%nlevels,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%nlevels,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%nlevels, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.nlevels', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%ndim3s)) then
      call observe_weather_primitive('field_pc.ndim3s', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%ndim3s,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%ndim3s,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%ndim3s, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.ndim3s', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%npoints_block)) then
      call observe_weather_primitive('field_pc.npoints_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%npoints_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%npoints_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%npoints_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.npoints_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mall_fields)) then
      call observe_weather_primitive('field_pc.mall_fields', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mall_fields,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mall_fields,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mall_fields, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mall_fields', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%index_last_block)) then
      call observe_weather_primitive('field_pc.index_last_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%index_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%index_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%index_last_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.index_last_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%clevtype)) then
      call observe_weather_primitive('field_pc.clevtype', 4_c_int, int(len(state%startup%loaded%fields%field_pc%clevtype), c_int), &
      lbound(state%startup%loaded%fields%field_pc%clevtype,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%clevtype,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%clevtype, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.clevtype', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%storage_last_block)) then
      call observe_weather_primitive('field_pc.storage_last_block', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_pc%storage_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%storage_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%storage_last_block, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.storage_last_block', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%unassigned_gfl)) then
      call observe_weather_primitive('field_pc.unassigned_gfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_pc%unassigned_gfl,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%unassigned_gfl,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%unassigned_gfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.unassigned_gfl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt9_map)) then
      call observe_weather_primitive('field_pc.mt9_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt9_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt9_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt9_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt9_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt1_map)) then
      call observe_weather_primitive('field_pc.mt1_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt1_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt1_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt1_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt1_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt0_map)) then
      call observe_weather_primitive('field_pc.mt0_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt0_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt0_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt0_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt0_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mpc_map)) then
      call observe_weather_primitive('field_pc.mpc_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mpc_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mpc_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mpc_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mpc_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mpt_map)) then
      call observe_weather_primitive('field_pc.mpt_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mpt_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mpt_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mpt_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mpt_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt0_dl_map)) then
      call observe_weather_primitive('field_pc.mt0_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt0_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt0_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt0_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt0_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt0_dm_map)) then
      call observe_weather_primitive('field_pc.mt0_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt0_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt0_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt0_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt0_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt9_dl_map)) then
      call observe_weather_primitive('field_pc.mt9_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt9_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt9_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt9_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt9_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt9_dm_map)) then
      call observe_weather_primitive('field_pc.mt9_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt9_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt9_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt9_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt9_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pc%mt0_size)) then
      call observe_weather_primitive('field_pc.mt0_size', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pc%mt0_size,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pc%mt0_size,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pc%mt0_size, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pc.mt0_size', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.lcreated', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%lcreated, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.mstortype', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%mstortype, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.m_attach', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%m_attach, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.nfields', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%nfields, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.nfields_on', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%nfields_on, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.nleveltypes', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%nleveltypes, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.ndim3types', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%ndim3types, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.npoints', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%npoints, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.ilen_storage1d', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%ilen_storage1d, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.nhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%nhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.nblocks', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%nblocks, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.l_attach_gfl_nproma_fixed', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%l_attach_gfl_nproma_fixed, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('field_pt.lhders', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%fields%field_pt%lhders, 3_c_int, observe, status)
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%nlevels)) then
      call observe_weather_primitive('field_pt.nlevels', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%nlevels,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%nlevels,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%nlevels, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.nlevels', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%ndim3s)) then
      call observe_weather_primitive('field_pt.ndim3s', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%ndim3s,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%ndim3s,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%ndim3s, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.ndim3s', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%npoints_block)) then
      call observe_weather_primitive('field_pt.npoints_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%npoints_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%npoints_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%npoints_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.npoints_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mall_fields)) then
      call observe_weather_primitive('field_pt.mall_fields', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mall_fields,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mall_fields,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mall_fields, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mall_fields', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%index_last_block)) then
      call observe_weather_primitive('field_pt.index_last_block', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%index_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%index_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%index_last_block, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.index_last_block', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%clevtype)) then
      call observe_weather_primitive('field_pt.clevtype', 4_c_int, int(len(state%startup%loaded%fields%field_pt%clevtype), c_int), &
      lbound(state%startup%loaded%fields%field_pt%clevtype,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%clevtype,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%clevtype, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.clevtype', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%storage_last_block)) then
      call observe_weather_primitive('field_pt.storage_last_block', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_pt%storage_last_block,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%storage_last_block,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%storage_last_block, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.storage_last_block', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%unassigned_gfl)) then
      call observe_weather_primitive('field_pt.unassigned_gfl', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%fields%field_pt%unassigned_gfl,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%unassigned_gfl,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%unassigned_gfl, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.unassigned_gfl', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt9_map)) then
      call observe_weather_primitive('field_pt.mt9_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt9_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt9_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt9_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt9_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt1_map)) then
      call observe_weather_primitive('field_pt.mt1_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt1_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt1_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt1_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt1_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt0_map)) then
      call observe_weather_primitive('field_pt.mt0_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt0_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt0_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt0_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt0_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mpc_map)) then
      call observe_weather_primitive('field_pt.mpc_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mpc_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mpc_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mpc_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mpc_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mpt_map)) then
      call observe_weather_primitive('field_pt.mpt_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mpt_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mpt_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mpt_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mpt_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt0_dl_map)) then
      call observe_weather_primitive('field_pt.mt0_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt0_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt0_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt0_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt0_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt0_dm_map)) then
      call observe_weather_primitive('field_pt.mt0_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt0_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt0_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt0_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt0_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt9_dl_map)) then
      call observe_weather_primitive('field_pt.mt9_dl_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt9_dl_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt9_dl_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt9_dl_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt9_dl_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt9_dm_map)) then
      call observe_weather_primitive('field_pt.mt9_dm_map', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt9_dm_map,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt9_dm_map,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt9_dm_map, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt9_dm_map', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%fields%field_pt%mt0_size)) then
      call observe_weather_primitive('field_pt.mt0_size', 1_c_int, 4_c_int, &
      lbound(state%startup%loaded%fields%field_pt%mt0_size,kind=c_int64_t),ubound(state%startup%loaded%fields%field_pt%mt0_size,kind=c_int64_t), &
                                     state%startup%loaded%fields%field_pt%mt0_size, 3_c_int, observe, status)
    else
      call observe_absent_weather_view('field_pt.mt0_size', 1_c_int, 3_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc)) then
      call observe_weather_primitive('radiation_cams.rmacbc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacbc', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor)) then
      call observe_weather_primitive('radiation_cams.rmacor', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacor, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacor', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd)) then
      call observe_weather_primitive('radiation_cams.rmacsd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss)) then
      call observe_weather_primitive('radiation_cams.rmacss', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu)) then
      call observe_weather_primitive('radiation_cams.rmacsu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsu', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc)) then
      call observe_weather_primitive('radiation_cams.rmaebc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaebc', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor)) then
      call observe_weather_primitive('radiation_cams.rmaeor', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaeor', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd)) then
      call observe_weather_primitive('radiation_cams.rmaesd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess)) then
      call observe_weather_primitive('radiation_cams.rmaess', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu)) then
      call observe_weather_primitive('radiation_cams.rmaesu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesu', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc1)) then
      call observe_weather_primitive('radiation_cams.rmacbc1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacbc1', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc2)) then
      call observe_weather_primitive('radiation_cams.rmacbc2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacbc2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc1)) then
      call observe_weather_primitive('radiation_cams.rmaebc1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaebc1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc2)) then
      call observe_weather_primitive('radiation_cams.rmaebc2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaebc2', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor1)) then
      call observe_weather_primitive('radiation_cams.rmacor1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacor1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacor1', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor2)) then
      call observe_weather_primitive('radiation_cams.rmacor2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacor2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacor2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor1)) then
      call observe_weather_primitive('radiation_cams.rmaeor1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaeor1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor2)) then
      call observe_weather_primitive('radiation_cams.rmaeor2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaeor2', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd1)) then
      call observe_weather_primitive('radiation_cams.rmacsd1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd1', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd2)) then
      call observe_weather_primitive('radiation_cams.rmacsd2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd3)) then
      call observe_weather_primitive('radiation_cams.rmacsd3', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd3,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd3,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd3, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd3', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd1)) then
      call observe_weather_primitive('radiation_cams.rmaesd1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd2)) then
      call observe_weather_primitive('radiation_cams.rmaesd2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd2', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd3)) then
      call observe_weather_primitive('radiation_cams.rmaesd3', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd3,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd3,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd3, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd3', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss1)) then
      call observe_weather_primitive('radiation_cams.rmacss1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss1', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss2)) then
      call observe_weather_primitive('radiation_cams.rmacss2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss2', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss3)) then
      call observe_weather_primitive('radiation_cams.rmacss3', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss3,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss3,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss3, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss3', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess1)) then
      call observe_weather_primitive('radiation_cams.rmaess1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess2)) then
      call observe_weather_primitive('radiation_cams.rmaess2', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess2,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess2,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess2, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess2', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess3)) then
      call observe_weather_primitive('radiation_cams.rmaess3', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess3,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess3,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess3, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess3', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu1)) then
      call observe_weather_primitive('radiation_cams.rmacsu1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsu1', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu1)) then
      call observe_weather_primitive('radiation_cams.rmaesu1', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu1,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu1,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu1, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesu1', 2_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc13d)) then
      call observe_weather_primitive('radiation_cams.rmacbc13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc13d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacbc13d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc23d)) then
      call observe_weather_primitive('radiation_cams.rmacbc23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacbc23d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacbc23d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor13d)) then
      call observe_weather_primitive('radiation_cams.rmacor13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacor13d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacor13d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor23d)) then
      call observe_weather_primitive('radiation_cams.rmacor23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacor23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacor23d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacor23d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd13d)) then
      call observe_weather_primitive('radiation_cams.rmacsd13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd13d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd13d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd23d)) then
      call observe_weather_primitive('radiation_cams.rmacsd23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd23d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd23d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd33d)) then
      call observe_weather_primitive('radiation_cams.rmacsd33d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd33d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd33d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsd33d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsd33d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss13d)) then
      call observe_weather_primitive('radiation_cams.rmacss13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss13d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss13d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss23d)) then
      call observe_weather_primitive('radiation_cams.rmacss23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss23d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss23d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss33d)) then
      call observe_weather_primitive('radiation_cams.rmacss33d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss33d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacss33d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacss33d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacss33d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu13d)) then
      call observe_weather_primitive('radiation_cams.rmacsu13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmacsu13d, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmacsu13d', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_prs)) then
      call observe_weather_primitive('radiation_cams.ref_mon_aer_prs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_prs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_prs,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_prs, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.ref_mon_aer_prs', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_dprs)) then
      call observe_weather_primitive('radiation_cams.ref_mon_aer_dprs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_dprs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_dprs,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%ref_mon_aer_dprs, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.ref_mon_aer_dprs', 4_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc13d)) then
      call observe_weather_primitive('radiation_cams.rmaebc13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc13d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaebc13d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc23d)) then
      call observe_weather_primitive('radiation_cams.rmaebc23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaebc23d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaebc23d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor13d)) then
      call observe_weather_primitive('radiation_cams.rmaeor13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor13d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaeor13d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor23d)) then
      call observe_weather_primitive('radiation_cams.rmaeor23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaeor23d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaeor23d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd13d)) then
      call observe_weather_primitive('radiation_cams.rmaesd13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd13d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd13d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd23d)) then
      call observe_weather_primitive('radiation_cams.rmaesd23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd23d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd23d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd33d)) then
      call observe_weather_primitive('radiation_cams.rmaesd33d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd33d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd33d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesd33d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesd33d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess13d)) then
      call observe_weather_primitive('radiation_cams.rmaess13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess13d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess13d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess23d)) then
      call observe_weather_primitive('radiation_cams.rmaess23d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess23d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess23d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess23d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess23d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess33d)) then
      call observe_weather_primitive('radiation_cams.rmaess33d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess33d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaess33d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaess33d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaess33d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu13d)) then
      call observe_weather_primitive('radiation_cams.rmaesu13d', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu13d,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu13d,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%rmaesu13d, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.rmaesu13d', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_prs)) then
      call observe_weather_primitive('radiation_cams.ref_aer_prs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_prs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_prs,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_prs, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.ref_aer_prs', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (allocated(state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_dprs)) then
      call observe_weather_primitive('radiation_cams.ref_aer_dprs', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_dprs,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_dprs,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%cams%ref_aer_dprs, 1_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_cams.ref_aer_dprs', 3_c_int, 1_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_cams.is_initialised', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%cams%is_initialised, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.repaer', 2_c_int, 8_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%repaer, 1_c_int, observe, status)
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%raerbc)) then
      call observe_weather_primitive('radiation_tegen.raerbc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%raerbc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%raerbc,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%raerbc, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.raerbc', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%raeror)) then
      call observe_weather_primitive('radiation_tegen.raeror', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%raeror,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%raeror,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%raeror, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.raeror', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%raersd)) then
      call observe_weather_primitive('radiation_tegen.raersd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%raersd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%raersd,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%raersd, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.raersd', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%raerss)) then
      call observe_weather_primitive('radiation_tegen.raerss', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%raerss,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%raerss,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%raerss, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.raerss', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%raersu)) then
      call observe_weather_primitive('radiation_tegen.raersu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%raersu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%raersu,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%raersu, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.raersu', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%raerv)) then
      call observe_weather_primitive('radiation_tegen.raerv', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%raerv,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%raerv,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%raerv, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.raerv', 3_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    if (associated(state%startup%loaded%storage%ecmwf%radiation%tegen%rlatv)) then
      call observe_weather_primitive('radiation_tegen.rlatv', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rlatv,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rlatv,kind=c_int64_t), &
                                     state%startup%loaded%storage%ecmwf%radiation%tegen%rlatv, 2_c_int, observe, status)
    else
      call observe_absent_weather_view('radiation_tegen.rlatv', 1_c_int, 2_c_int, observe, status)
    end if
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.rtaebc', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaebc,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaebc,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%rtaebc, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.rtaeor', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaeor,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaeor,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%rtaeor, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.rtaesd', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaesd,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaesd,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%rtaesd, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.rtaess', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaess,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaess,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%rtaess, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.rtaesu', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaesu,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaesu,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%rtaesu, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.rtaevo', 2_c_int, 8_c_int, &
      lbound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaevo,kind=c_int64_t),ubound(state%startup%loaded%storage%ecmwf%radiation%tegen%rtaevo,kind=c_int64_t), &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%rtaevo, 1_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.isyear', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%isyear, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.ieyear', 1_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%ieyear, 3_c_int, observe, status)
    if (status /= 0) goto900
    call observe_weather_primitive('radiation_tegen.is_initialised', 3_c_int, 4_c_int, &
                                   [integer(c_int64_t) ::], [integer(c_int64_t) ::], &
                                   state%startup%loaded%storage%ecmwf%radiation%tegen%is_initialised, 3_c_int, observe, status)
    if (status /= 0) goto900
    status = 0
900 call ieee_set_status(saved_ieee)
    error_word = saved_errno
  end subroutine
end module
