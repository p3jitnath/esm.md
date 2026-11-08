module spectral_field_storage_port
  !! Own spectral fields, integer maps and typed named views.
  !! A spectral coefficient is one real word in the triangular wave ordering.
  !! Arrays keep the source level/coefficient/field order. Values retain their
  !! field units. The compiler owns every descriptor and allocation address.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_arithmetic
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  implicit none
  private
  public :: spectral_field_state, initialize_serial_spectral_field, release_spectral_field
  public :: serial_spectral_wave_distribution, spectral_field_is_fresh, spectral_storage_mode_supported
  type :: spectral_field_state
    real(real64), allocatable :: sp2d(:, :), sp3d(:, :, :), sp1d(:, :)
    integer(int32) :: nsmax = 0, nmsmax = 0, ns2d = 0, ns3d = 0, ns1d = 0, ns2g = 0
    integer(int32) :: nflevl = 0, nflevg = 0, nspec2 = 0, nspec2g = 0, nump = 0, nspsizel = 0, nspsizeg = 0
    integer(int32), allocatable :: ns2l(:), nasm0(:), nasm0g(:), nesm0(:), nesm0g(:), ncpl4m(:)
    integer(int32), allocatable :: numpp(:), nallms(:), ms_proc(:, :), numll(:), nptrll(:), npsurf(:)
    integer(int32), allocatable :: nptrms(:), myms(:), mylevs(:), ngrib(:)
    integer(int32), pointer, contiguous :: ngrib2(:) => null(), ngrib3(:) => null()
    real(real64), pointer, contiguous :: vor(:, :) => null(), div(:, :) => null(), t(:, :) => null()
    real(real64), pointer, contiguous :: q(:, :) => null(), o3(:, :) => null(), l(:, :) => null(), i(:, :) => null()
    real(real64), pointer, contiguous :: spd(:, :) => null(), svd(:, :) => null(), nhx(:, :) => null()
    real(real64), pointer, contiguous :: sp(:) => null(), orog(:) => null(), ub(:) => null(), vb(:) => null()
    real(real64), pointer, contiguous :: scal(:, :, :) => null(), gfl(:, :, :) => null(), hv(:, :, :) => null()
    real(real64) :: dummy(3) = 0.0_real64
    logical :: ready = .false.
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  logical function spectral_storage_mode_supported() result(supported)
    !! The caller verifies actual FPCR zero. This portable guard also checks
    !! round-to-nearest and gradual underflow without changing incoming flags.
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    logical :: gradual
    call ieee_get_status(saved)
    call ieee_get_rounding_mode(rounding)
    supported = rounding == ieee_nearest
    if (supported) then
      if (ieee_support_underflow_control(0.0_real64)) then
        call ieee_get_underflow_mode(gradual)
        supported = gradual
      else
        minimum_normal = tiny(0.0_real64); half_value = 0.5_real64
        subnormal_probe = minimum_normal*half_value
        supported = transfer(subnormal_probe, 0_int64) == ibset(0_int64, 51)
      end if
    end if
    call ieee_set_status(saved)
  end function

  logical function spectral_field_is_fresh(state) result(fresh)
    !! A fresh caller-owned record has no array or view and zero dimensions.
    type(spectral_field_state), intent(in) :: state
    fresh = .false.
    if (state%ready) return
    if (allocated(state%sp2d)) return
    if (allocated(state%sp3d)) return
    if (allocated(state%sp1d)) return
    if (allocated(state%nasm0)) return
    if (allocated(state%nasm0g)) return
    if (allocated(state%nesm0)) return
    if (allocated(state%nesm0g)) return
    if (allocated(state%ncpl4m)) return
    if (allocated(state%numpp)) return
    if (allocated(state%ms_proc)) return
    if (allocated(state%numll)) return
    if (allocated(state%nptrll)) return
    if (allocated(state%npsurf)) return
    if (allocated(state%ns2l)) return
    if (allocated(state%ngrib)) return
    if (allocated(state%myms)) return
    if (allocated(state%mylevs)) return
    if (allocated(state%nallms)) return
    if (allocated(state%nptrms)) return
    if (associated(state%ngrib2)) return
    if (associated(state%ngrib3)) return
    if (associated(state%vor)) return
    if (associated(state%div)) return
    if (associated(state%t)) return
    if (associated(state%q)) return
    if (associated(state%o3)) return
    if (associated(state%l)) return
    if (associated(state%i)) return
    if (associated(state%spd)) return
    if (associated(state%svd)) return
    if (associated(state%nhx)) return
    if (associated(state%sp)) return
    if (associated(state%orog)) return
    if (associated(state%scal)) return
    if (associated(state%gfl)) return
    if (associated(state%hv)) return
    if (associated(state%ub)) return
    if (associated(state%vb)) return
    if (any([state%nsmax, state%nmsmax, state%ns2d, state%ns3d, state%ns1d, state%ns2g, &
             state%nflevl, state%nflevg, state%nspec2, state%nspec2g, state%nump, state%nspsizel, state%nspsizeg] /= 0)) return
    fresh = .true.
  end function

  integer(int32) function serial_spectral_wave_distribution(asm0, allms, ptrms, numpp, n) result(status)
    !! N is0..63 or1279. asm0(0:N) is the one-based real-word start of
    !! each wave; allms(1:N+1) lists0..N. ptrms and numpp each have one word.
    integer(int32), contiguous, intent(inout) :: asm0(0:), allms(:), ptrms(:), numpp(:)
    integer(int32), intent(in) :: n
    integer(int32) :: wave, next
    status = 2
    if (.not. ((n >= 0 .and. n <= 63) .or. n == 1279)) return
    if (size(asm0) /= n + 1 .or. size(allms) /= n + 1 .or. size(ptrms) /= 1 .or. size(numpp) /= 1) return
    next = 1
    do wave = 0, n
      asm0(wave) = next; allms(wave + 1) = wave
      next = next + 2*(n + 1 - wave)
    end do
    ptrms(1) = 1; numpp(1) = n + 1
    status = 0
  end function

  integer(int32) function initialize_serial_spectral_field(output, levels, n, identifiers, byte_cap) result(status)
    !! output is fresh and TARGET at its final stable address until release.
    !! Support L1..64/N0..63 and exact L137/N1279. identifiers contain a
    !! permutation of138/155/130 and152/129 within those two groups. Values
    !! are metadata only; the produced map retains canonical source ordering.
    !! byte_cap bounds complete payload bytes; outer object/runtime overhead
    !! requires a separate caller resource admission. Return0/1/2 means
    !! success/cleaned allocation failure/atomic unsupported input.
    type(spectral_field_state), target, intent(inout) :: output
    integer(int32), intent(in) :: levels, n, identifiers(5)
    integer(int64), intent(in) :: byte_cap
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int64) :: required
    integer(int32) :: waves, coefficients, ignored
    integer :: ios, wave
    status = 2
    if (.not. spectral_field_is_fresh(output)) return
    if (.not. spectral_storage_mode_supported()) return
    if (.not. ((levels >= 1 .and. levels <= 64 .and. n >= 0 .and. n <= 63) .or. (levels == 137 .and. n == 1279))) return
    if (count(identifiers(1:3) == 138) /= 1 .or. count(identifiers(1:3) == 155) /= 1 .or. count(identifiers(1:3) == 130) &
        /= 1) return
    if (count(identifiers(4:5) == 152) /= 1 .or. count(identifiers(4:5) == 129) /= 1) return
    waves = n + 1; coefficients = (n + 1)*(n + 2)
    required = 20_int64*int(waves, int64) + 4_int64*int(levels, int64) + 44_int64 + &
               8_int64*(3_int64*int(levels, int64)*int(coefficients, int64) + 2_int64*int(coefficients, int64) + 2_int64)
    if (byte_cap < required) return
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    status = 1
    allocate (output%myms(waves), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%nallms(waves), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%nptrms(1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%numll(1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%nptrll(1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%npsurf(1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%mylevs(levels), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%nasm0(0:n), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%nasm0g(0:n), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%numpp(1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%ms_proc(waves, 1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%ns2l(1), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%ngrib(5), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%sp3d(levels, coefficients, 3), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%sp2d(coefficients, 2), stat=ios)
    if (ios /= 0) goto 800
    allocate (output%sp1d(1, 2), stat=ios)
    if (ios /= 0) goto 800
    output%nsmax = n; output%nmsmax = 0; output%ns2d = 2; output%ns3d = 3; output%ns1d = 0; output%ns2g = 2
    output%nflevl = levels; output%nflevg = levels; output%nspec2 = coefficients; output%nspec2g = coefficients
    output%nump = waves; output%nspsizel = (3*levels + 2)*coefficients; output%nspsizeg = output%nspsizel
    ignored = serial_spectral_wave_distribution(output%nasm0, output%nallms, output%nptrms, output%numpp, n)
    if (ignored /= 0) goto 800
    do wave = 0, n
      output%myms(wave + 1) = wave
      output%ms_proc(wave + 1, 1) = output%nallms(wave + 1)
      output%nasm0g(wave) = output%nasm0(wave)
    end do
    output%numll(1) = levels; output%nptrll(1) = 0; output%npsurf(1) = 1; output%ns2l(1) = 2
    do wave = 1, levels
      output%mylevs(wave) = wave - 1
    end do
    output%ngrib = [138_int32, 155_int32, 130_int32, 152_int32, 129_int32]
    output%sp3d = 0.0_real64; output%sp2d = 0.0_real64; output%sp1d = 0.0_real64; output%dummy = 0.0_real64
    output%ngrib3 => output%ngrib(1:3); output%ngrib2 => output%ngrib(4:5)
    output%vor => output%sp3d(:, :, 1); output%div => output%sp3d(:, :, 2); output%t => output%sp3d(:, :, 3)
    output%scal => output%sp3d(:, :, 3:3); output%hv => output%sp3d(:, :, 3:3)
    output%sp => output%sp2d(:, 1); output%orog => output%sp2d(:, 2)
    output%ub => output%sp1d(:, 1); output%vb => output%sp1d(:, 2)
    output%q(1:1, 1:1) => output%dummy(2:2); output%o3(1:1, 1:1) => output%dummy(2:2)
    output%l(1:1, 1:1) => output%dummy(2:2); output%spd(1:1, 1:1) => output%dummy(2:2)
    output%svd(1:1, 1:1) => output%dummy(2:2); output%nhx(1:1, 1:1) => output%dummy(2:2)
    output%gfl(1:1, 1:1, 1:1) => output%dummy(3:3)
    output%ready = .true.
    status = 0
    goto 900
800 ignored = release_spectral_field(output)
900 error_number = saved_errno
    call ieee_set_status(saved)
  end function

  integer(int32) function release_spectral_field(output) result(status)
    !! Release live or partially acquired owners in source order. Null every
    !! view before releasing its target. Source dimension metadata remains;
    !! a released raw record is not a fresh record for reinitialisation.
    type(spectral_field_state), intent(inout) :: output
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call ieee_get_status(saved)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    nullify (output%ngrib2)
    nullify (output%ngrib3)
    nullify (output%vor)
    nullify (output%div)
    nullify (output%t)
    nullify (output%q)
    nullify (output%o3)
    nullify (output%l)
    nullify (output%i)
    nullify (output%spd)
    nullify (output%svd)
    nullify (output%nhx)
    nullify (output%sp)
    nullify (output%orog)
    nullify (output%scal)
    nullify (output%gfl)
    nullify (output%hv)
    nullify (output%ub)
    nullify (output%vb)
    if (allocated(output%sp2d)) deallocate (output%sp2d)
    if (allocated(output%sp3d)) deallocate (output%sp3d)
    if (allocated(output%sp1d)) deallocate (output%sp1d)
    if (allocated(output%nasm0)) deallocate (output%nasm0)
    if (allocated(output%nasm0g)) deallocate (output%nasm0g)
    if (allocated(output%nesm0)) deallocate (output%nesm0)
    if (allocated(output%nesm0g)) deallocate (output%nesm0g)
    if (allocated(output%ncpl4m)) deallocate (output%ncpl4m)
    if (allocated(output%numpp)) deallocate (output%numpp)
    if (allocated(output%ms_proc)) deallocate (output%ms_proc)
    if (allocated(output%numll)) deallocate (output%numll)
    if (allocated(output%nptrll)) deallocate (output%nptrll)
    if (allocated(output%npsurf)) deallocate (output%npsurf)
    if (allocated(output%ns2l)) deallocate (output%ns2l)
    if (allocated(output%ngrib)) deallocate (output%ngrib)
    if (allocated(output%myms)) deallocate (output%myms)
    if (allocated(output%mylevs)) deallocate (output%mylevs)
    if (allocated(output%nallms)) deallocate (output%nallms)
    if (allocated(output%nptrms)) deallocate (output%nptrms)
    output%ready = .false.
    status = 0
    error_number = saved_errno
    call ieee_set_status(saved)
  end function
end module spectral_field_storage_port
