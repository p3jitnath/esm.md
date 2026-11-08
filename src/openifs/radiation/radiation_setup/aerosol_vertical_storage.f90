!> Own the nine source-ordered vertical aerosol allocations with native arrays.
module aerosol_vertical_storage_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t, c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_all, ieee_underflow, ieee_inexact
  use yoeaerd, only: teaerd
  use yoerad, only: terad
  implicit none
  private
  public :: create_selected_aerosol_vertical_storage, create_runtime_aerosol_vertical_storage
  public :: release_selected_aerosol_vertical_storage
  type :: private_array_owner
    real(real64), allocatable :: values(:)
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate the original nineteen-level, twenty-boundary aerosol owners.
  !! AEROSOL and RADIATION are separate native TEAERD and TERAD records.
  !! Four CVDAE arrays in AEROSOL and five in RADIATION must be unallocated.
  !! Each caller-owned component gets twenty real64 entries, bounds1:20.
  !! Payloads stay source-unwritten. Other record fields stay unchanged.
  !! Return0 after all nine allocations commit,1 on allocation failure with
  !! every public byte unchanged, or2 before mutation on invalid input.
  integer(int32) function create_selected_aerosol_vertical_storage(aerosol, radiation) result(status)
    type(teaerd), intent(inout), target :: aerosol
    type(terad), intent(inout), target :: radiation
    status = create_runtime_aerosol_vertical_storage(aerosol, radiation, 19_int32)
  end function

  !> Allocate the same native owner family for a live1:512 level count.
  !! Each component has LEVELS+1 entries. The private allocations keep the
  !! four-then-five source order. MOVE_ALLOC publishes their native bounds
  !! only after all nine succeed. The compiler owns descriptor storage.
  !! The owner set, mutation and return values match the entry above.
  !! A new runtime count needs its own independent reference comparison.
  integer(int32) function create_runtime_aerosol_vertical_storage(aerosol, radiation, levels) result(status)
    type(teaerd), intent(inout), target :: aerosol
    type(terad), intent(inout), target :: radiation
    integer(int32), intent(in) :: levels
    type(private_array_owner) :: private_owners(9)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno, failure_errno
    integer :: owner, owner_cleanup, allocation_status, release_status
    logical :: incoming_flags(size(ieee_all))
    status = 2_int32
    if (levels < 1 .or. levels > 512) return
    if (.not. separate_records(aerosol, radiation)) return
    if (allocated(aerosol%cvdaes)) return
    if (allocated(aerosol%cvdael)) return
    if (allocated(aerosol%cvdaeu)) return
    if (allocated(aerosol%cvdaed)) return
    if (allocated(radiation%cvdaess)) return
    if (allocated(radiation%cvdaedu)) return
    if (allocated(radiation%cvdaeom)) return
    if (allocated(radiation%cvdaebc)) return
    if (allocated(radiation%cvdaesu)) return
    if (.not. supported_floating_mode()) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    do owner = 1, 9
      allocate (private_owners(owner)%values(levels + 1), stat=allocation_status)
      if (allocation_status /= 0) then
        failure_errno = errno_value
        do owner_cleanup = 1, 9
          if (allocated(private_owners(owner_cleanup)%values)) &
            deallocate (private_owners(owner_cleanup)%values, stat=release_status)
        end do
        call ieee_set_flag(ieee_all, incoming_flags)
        errno_value = failure_errno
        status = 1_int32
        return
      end if
    end do
    call move_alloc(private_owners(1)%values, aerosol%cvdaes)
    call move_alloc(private_owners(2)%values, aerosol%cvdael)
    call move_alloc(private_owners(3)%values, aerosol%cvdaeu)
    call move_alloc(private_owners(4)%values, aerosol%cvdaed)
    call move_alloc(private_owners(5)%values, radiation%cvdaess)
    call move_alloc(private_owners(6)%values, radiation%cvdaedu)
    call move_alloc(private_owners(7)%values, radiation%cvdaeom)
    call move_alloc(private_owners(8)%values, radiation%cvdaebc)
    call move_alloc(private_owners(9)%values, radiation%cvdaesu)
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = incoming_errno
    status = 0_int32
  end function

  !> Release only the nine owned arrays in their declared source order.
  !! Repeated release succeeds. Every other native record member remains
  !! incoming; the compiler clears each released allocatable association.
  !! Incoming FP flags and errno are preserved. Return2 on record overlap,
  !!1 on a native release failure or0 after all present owners are released.
  integer(int32) function release_selected_aerosol_vertical_storage(aerosol, radiation) result(status)
    type(teaerd), intent(inout), target :: aerosol
    type(terad), intent(inout), target :: radiation
    integer(c_int), pointer :: errno_value
    integer(c_int) :: incoming_errno
    integer :: release_status
    logical :: incoming_flags(size(ieee_all))
    status = 2_int32
    if (.not. separate_records(aerosol, radiation)) return
    call c_f_pointer(errno_address(), errno_value)
    incoming_errno = errno_value
    call ieee_get_flag(ieee_all, incoming_flags)
    status = 0_int32
    if (allocated(aerosol%cvdaes)) then
      deallocate (aerosol%cvdaes, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(aerosol%cvdael)) then
      deallocate (aerosol%cvdael, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(aerosol%cvdaeu)) then
      deallocate (aerosol%cvdaeu, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(aerosol%cvdaed)) then
      deallocate (aerosol%cvdaed, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(radiation%cvdaess)) then
      deallocate (radiation%cvdaess, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(radiation%cvdaedu)) then
      deallocate (radiation%cvdaedu, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(radiation%cvdaeom)) then
      deallocate (radiation%cvdaeom, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(radiation%cvdaebc)) then
      deallocate (radiation%cvdaebc, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    if (allocated(radiation%cvdaesu)) then
      deallocate (radiation%cvdaesu, stat=release_status)
      if (release_status /= 0) status = 1_int32
    end if
    call ieee_set_flag(ieee_all, incoming_flags)
    errno_value = incoming_errno
  end function

  !> Compare the compiler-derived complete native record spans.
  logical function separate_records(aerosol, radiation) result(separate)
    type(teaerd), intent(in), target :: aerosol
    type(terad), intent(in), target :: radiation
    integer(c_intptr_t) :: first, second
    first = transfer(c_loc(aerosol), first)
    second = transfer(c_loc(radiation), second)
    separate = disjoint(first, storage_size(aerosol, kind=int64)/8_int64, &
                        second, storage_size(radiation, kind=int64)/8_int64)
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
