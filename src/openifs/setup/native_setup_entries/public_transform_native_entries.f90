!> Forward complete pointer arrays to fixed public message and transform entries.
module forecast_native_public_transform_entries
  use iso_c_binding, only: c_ptr, c_int, c_intptr_t, c_size_t, c_associated, c_f_pointer
  implicit none
  private
  public :: md2asm_call_public_message_init
  public :: md2asm_call_public_transform_setup0
  public :: md2asm_call_public_transform_setup
  public :: md2asm_call_public_transform_inquiry
  public :: md2asm_call_public_spectral_distribution
  interface
    subroutine public_entry_0( &
      a1, a2, a3, a4, a5, a6) bind(C, name="__mpl_init_mod_MOD_mpl_init")
      import c_ptr, c_size_t
      type(c_ptr), value :: a1, a2, a3, a4, a5, a6
    end subroutine
    subroutine public_entry_1( &
      a1, a2, a3, a4, a5, a6, a7, a8, &
      a9, a10, a11, a12, a13, a14, a15, a16, &
      a17, a18) bind(C, name="setup_trans0_")
      import c_ptr, c_size_t
      type(c_ptr), value :: a1, a2, a3, a4, a5, a6, a7, a8
      type(c_ptr), value :: a9, a10, a11, a12, a13, a14, a15, a16
      type(c_ptr), value :: a17, a18
    end subroutine
    subroutine public_entry_2( &
      a1, a2, a3, a4, a5, a6, a7, a8, &
      a9, a10, a11, a12, a13, a14, a15, a16, &
      a17, a18, a19, a20, a21, a22, a23, a24) bind(C, name="setup_trans_")
      import c_ptr, c_size_t
      type(c_ptr), value :: a1, a2, a3, a4, a5, a6, a7, a8
      type(c_ptr), value :: a9, a10, a11, a12, a13, a14, a15, a16
      type(c_ptr), value :: a17, a18, a19, a20, a21, a22
      integer(c_size_t), value :: a23, a24
    end subroutine
    subroutine public_entry_3( &
      a1, a2, a3, a4, a5, a6, a7, a8, &
      a9, a10, a11, a12, a13, a14, a15, a16, &
      a17, a18, a19, a20, a21, a22, a23, a24, &
      a25, a26, a27, a28, a29, a30, a31, a32, &
      a33, a34, a35, a36, a37, a38, a39, a40, &
      a41, a42, a43, a44, a45, a46, a47) bind(C, name="trans_inq_")
      import c_ptr, c_size_t
      type(c_ptr), value :: a1, a2, a3, a4, a5, a6, a7, a8
      type(c_ptr), value :: a9, a10, a11, a12, a13, a14, a15, a16
      type(c_ptr), value :: a17, a18, a19, a20, a21, a22, a23, a24
      type(c_ptr), value :: a25, a26, a27, a28, a29, a30, a31, a32
      type(c_ptr), value :: a33, a34, a35, a36, a37, a38, a39, a40
      type(c_ptr), value :: a41, a42, a43, a44, a45, a46, a47
    end subroutine
    subroutine public_entry_4( &
      a1, a2, a3, a4, a5, a6, a7, a8, &
      a9, a10, a11, a12, a13, a14, a15) bind(C, name="ini_spec_dist_")
      import c_ptr, c_size_t
      type(c_ptr), value :: a1, a2, a3, a4, a5, a6, a7, a8
      type(c_ptr), value :: a9, a10, a11, a12, a13, a14, a15
    end subroutine
  end interface
contains
  !> Call the fixed public __mpl_init_mod_MOD_mpl_init entry using 6 original pointer arguments.
 !! arguments borrows an aligned array of at least 8 C pointer words.
 !! Every pointed-to object keeps its public-library type, bounds and intent.
 !! The caller owns the array and all targets through return; this entry owns no storage.
 !! Return two refuses a null or unaligned array; return zero follows the public call.
 !! Numerical status from the public service is retained without modification.
  integer(c_int) function md2asm_call_public_message_init(arguments) bind(C, name='md2asm_call_public_message_init') result(status)
    type(c_ptr), value, intent(in) :: arguments
    type(c_ptr), pointer :: a(:)
    integer(c_intptr_t) :: address
    status = 2_c_int
    if (.not. c_associated(arguments)) return
    address = transfer(arguments, address)
    if (mod(address, 8_c_intptr_t) /= 0_c_intptr_t) return
    call c_f_pointer(arguments, a, [8])
    call public_entry_0( &
      a(1), a(2), a(3), a(4), a(5), a(6))
    status = 0_c_int
  end function
  !> Call the fixed public setup_trans0_ entry using 18 original pointer arguments.
 !! arguments borrows an aligned array of at least 18 C pointer words.
 !! Every pointed-to object keeps its public-library type, bounds and intent.
 !! The caller owns the array and all targets through return; this entry owns no storage.
 !! Return two refuses a null or unaligned array; return zero follows the public call.
 !! Numerical status from the public service is retained without modification.
 integer(c_int) function md2asm_call_public_transform_setup0(arguments) bind(C,name='md2asm_call_public_transform_setup0') result(status)
    type(c_ptr), value, intent(in) :: arguments
    type(c_ptr), pointer :: a(:)
    integer(c_intptr_t) :: address
    status = 2_c_int
    if (.not. c_associated(arguments)) return
    address = transfer(arguments, address)
    if (mod(address, 8_c_intptr_t) /= 0_c_intptr_t) return
    call c_f_pointer(arguments, a, [18])
    call public_entry_1( &
      a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), &
      a(9), a(10), a(11), a(12), a(13), a(14), a(15), a(16), &
      a(17), a(18))
    status = 0_c_int
  end function
  !> Call the fixed public setup_trans_ entry using 22 pointers and two character-length words.
 !! arguments borrows an aligned array of at least 24 C pointer words.
 !! Every pointed-to object keeps its public-library type, bounds and intent.
 !! The caller owns the array and all targets through return; this entry owns no storage.
 !! Return two refuses a null or unaligned array; return zero follows the public call.
 !! Numerical status from the public service is retained without modification.
 integer(c_int) function md2asm_call_public_transform_setup(arguments) bind(C,name='md2asm_call_public_transform_setup') result(status)
    type(c_ptr), value, intent(in) :: arguments
    type(c_ptr), pointer :: a(:)
    integer(c_intptr_t) :: address
    status = 2_c_int
    if (.not. c_associated(arguments)) return
    address = transfer(arguments, address)
    if (mod(address, 8_c_intptr_t) /= 0_c_intptr_t) return
    call c_f_pointer(arguments, a, [24])
    call public_entry_2( &
      a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), &
      a(9), a(10), a(11), a(12), a(13), a(14), a(15), a(16), &
      a(17), a(18), a(19), a(20), a(21), a(22), transfer(a(23), 0_c_size_t), transfer(a(24), 0_c_size_t))
    status = 0_c_int
  end function
  !> Call the fixed public trans_inq_ entry using 47 original pointer arguments.
 !! arguments borrows an aligned array of at least 47 C pointer words.
 !! Every pointed-to object keeps its public-library type, bounds and intent.
 !! The caller owns the array and all targets through return; this entry owns no storage.
 !! Return two refuses a null or unaligned array; return zero follows the public call.
 !! Numerical status from the public service is retained without modification.
 integer(c_int) function md2asm_call_public_transform_inquiry(arguments) bind(C,name='md2asm_call_public_transform_inquiry') result(status)
    type(c_ptr), value, intent(in) :: arguments
    type(c_ptr), pointer :: a(:)
    integer(c_intptr_t) :: address
    status = 2_c_int
    if (.not. c_associated(arguments)) return
    address = transfer(arguments, address)
    if (mod(address, 8_c_intptr_t) /= 0_c_intptr_t) return
    call c_f_pointer(arguments, a, [47])
    call public_entry_3( &
      a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), &
      a(9), a(10), a(11), a(12), a(13), a(14), a(15), a(16), &
      a(17), a(18), a(19), a(20), a(21), a(22), a(23), a(24), &
      a(25), a(26), a(27), a(28), a(29), a(30), a(31), a(32), &
      a(33), a(34), a(35), a(36), a(37), a(38), a(39), a(40), &
      a(41), a(42), a(43), a(44), a(45), a(46), a(47))
    status = 0_c_int
  end function
  !> Call the fixed public ini_spec_dist_ entry using 15 original pointer arguments.
 !! arguments borrows an aligned array of at least 15 C pointer words.
 !! Every pointed-to object keeps its public-library type, bounds and intent.
 !! The caller owns the array and all targets through return; this entry owns no storage.
 !! Return two refuses a null or unaligned array; return zero follows the public call.
 !! Numerical status from the public service is retained without modification.
 integer(c_int) function md2asm_call_public_spectral_distribution(arguments) bind(C,name='md2asm_call_public_spectral_distribution') result(status)
    type(c_ptr), value, intent(in) :: arguments
    type(c_ptr), pointer :: a(:)
    integer(c_intptr_t) :: address
    status = 2_c_int
    if (.not. c_associated(arguments)) return
    address = transfer(arguments, address)
    if (mod(address, 8_c_intptr_t) /= 0_c_intptr_t) return
    call c_f_pointer(arguments, a, [15])
    call public_entry_4( &
      a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), &
      a(9), a(10), a(11), a(12), a(13), a(14), a(15))
    status = 0_c_int
  end function
end module forecast_native_public_transform_entries
