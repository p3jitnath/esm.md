!> Own cloud-overlap storage and the complete source linear profile.
module cloud_overlap_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_all, ieee_underflow, ieee_inexact
  use yomsta, only: tsta
  use yoeovlp, only: teovlp
  use yoerad, only: terad
  implicit none
  private
  public :: create_cloud_overlap_storage, initialize_cloud_overlap_profile, release_cloud_overlap_storage
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate native RA1OVLP(1:LEVELS) without writing its payload.
  !! OVERLAP is caller-owned TEOVLP and must have an unallocated RA1OVLP.
  !! LEVELS is int32 from1through256. Private allocation commits only after
  !! success. Return0 on success,1 on allocation failure or2 before mutation.
  !! The output stays unchanged after allocation failure. Preserve FP flags
  !! and successful-call errno, retaining the allocator errno after failure.
  integer(int32) function create_cloud_overlap_storage(overlap, levels) result(status)
    type(teovlp), intent(inout) :: overlap
    integer(int32), intent(in) :: levels
    real(real64), allocatable :: private_profile(:)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno, failure_errno
    integer :: allocation_status
    logical :: incoming_flags(size(ieee_all))
    status = 2_int32
    if (levels < 1 .or. levels > 256) return
    if (allocated(overlap%ra1ovlp)) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    allocate (private_profile(levels), stat=allocation_status)
    if (allocation_status /= 0) then
      failure_errno = errno_value
      call ieee_set_flag(ieee_all, incoming_flags)
      errno_value = failure_errno
      status = 1_int32
      return
    end if
    call move_alloc(private_profile, overlap%ra1ovlp)
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = incoming_errno
    status = 0_int32
  end function

  !> Evaluate one rounded product then one addition per height in metres.
  !! ATMOSPHERE is readonly native TSTA with allocated STZ(1:LEVELS).
  !! RADIATION is readonly TERAD. RAOVLP has unitsm**(-1); RBOVLP has no unit.
  !! OVERLAP owns allocated dimensionless RA1OVLP(1:LEVELS). All complete
  !! records and both payloads must be separate, with finite live inputs.
  !! Increasing level order preserves the complete SUOVLP arithmetic.
  !! No array is allocated or released. Return2 before writes on an
  !! unsupported input or0 after all profile values. Natural FP flags remain.
  integer(int32) function initialize_cloud_overlap_profile(atmosphere, overlap, radiation, levels) result(status)
    type(tsta), intent(in), target :: atmosphere
    type(teovlp), intent(inout), target :: overlap
    type(terad), intent(in), target :: radiation
    integer(int32), intent(in) :: levels
    integer(c_intptr_t) :: addresses(5)
    integer(int64) :: lengths(5)
    integer :: first, second, level
    real(real64) :: product
    status = 2_int32
    if (levels < 1 .or. levels > 256) return
    if (.not. allocated(atmosphere%stz)) return
    if (.not. allocated(overlap%ra1ovlp)) return
    if (lbound(atmosphere%stz, 1) /= 1 .or. size(atmosphere%stz) /= levels) return
    if (lbound(overlap%ra1ovlp, 1) /= 1 .or. size(overlap%ra1ovlp) /= levels) return
    if (.not. finite_value(radiation%raovlp) .or. .not. finite_value(radiation%rbovlp)) return
    do level = 1, levels
      if (.not. finite_value(atmosphere%stz(level))) return
    end do
    addresses = [transfer(c_loc(atmosphere), 0_c_intptr_t), transfer(c_loc(overlap), 0_c_intptr_t), &
                 transfer(c_loc(radiation), 0_c_intptr_t), transfer(c_loc(atmosphere%stz), 0_c_intptr_t), &
                 transfer(c_loc(overlap%ra1ovlp), 0_c_intptr_t)]
    lengths = [storage_size(atmosphere, kind=int64)/8_int64, storage_size(overlap, kind=int64)/8_int64, &
               storage_size(radiation, kind=int64)/8_int64, int(levels, int64)*8_int64, int(levels, int64)*8_int64]
    do first = 1, 4
      do second = first + 1, 5
        if (.not. disjoint(addresses(first), lengths(first), addresses(second), lengths(second))) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    do level = 1, levels
      product = radiation%raovlp*atmosphere%stz(level)
      overlap%ra1ovlp(level) = product + radiation%rbovlp
    end do
    status = 0_int32
  end function

  !> Release only RA1OVLP, accepting an already released native owner.
  !! Preserve all other record bytes, incoming FP flags and errno.
  !! Return0 on success or1 if native deallocation reports failure.
  integer(int32) function release_cloud_overlap_storage(overlap) result(status)
    type(teovlp), intent(inout) :: overlap
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer :: release_status
    logical :: incoming_flags(size(ieee_all))
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    status = 0_int32
    if (allocated(overlap%ra1ovlp)) then
      deallocate (overlap%ra1ovlp, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = incoming_errno
  end function

  !> Check finite FP64 values without producing a new floating exception.
  logical function finite_value(value) result(finite)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = iand(transfer(value, 0_int64), int(z'7fffffffffffffff', int64))
    finite = word < int(z'7ff0000000000000', int64)
  end function

  !> Check native storage without constructing a private target layout.
  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

  !> Require nearest rounding and gradual underflow without changing flags.
  !! The launcher establishes the complete target floating-point contract.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function
end module
