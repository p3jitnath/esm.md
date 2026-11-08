! (C) Copyright1989- ECMWF and Meteo-France. Apache Licence Version2.0.
!> Own the declared integer codes required by Fullpos field metadata.
!! GRIB is a file format for weather fields. Codes and their indices are dimensionless.
!! This owner has14 scalar int32 values and one three-entry int32 array.
!! Initialisation uses the exact earlier source declarations; it performs no FP arithmetic.
!! Bind only at the caller's final TARGET address, and retain that owner while views are used.
module forecast_native_fullpos_grib_codes
  use iso_fortran_env, only: int32
  use forecast_fullpos_file_metadata, only: native_fullpos_grib_code_targets
  implicit none
  private
  public :: native_fullpos_grib_code_owner, initialize_fullpos_grib_code_owner
  public :: bind_fullpos_grib_code_targets, clear_fullpos_grib_code_targets, fullpos_grib_codes_ready
  type :: native_fullpos_grib_code_owner
    private
    integer(int32) :: ngrbdl
    integer(int32) :: ngrbgpp
    integer(int32) :: ngrbigpp
    integer(int32) :: ngrbinee
    integer(int32) :: ngrbirec
    integer(int32) :: ngrblblt
    integer(int32) :: ngrblicd
    integer(int32) :: ngrblict
    integer(int32) :: ngrblmld
    integer(int32) :: ngrblmlt
    integer(int32) :: ngrblshf
    integer(int32) :: ngrbltlt
    integer(int32) :: ngrbnee
    integer(int32) :: ngrbrec
    integer(int32) :: ngrbtcghg(3)
    logical :: ready = .false.
  end type
contains
!> Initialise a fresh fixed-storage owner. No target or value is borrowed.
!! owner is INOUT. Return0 means complete,2 means that it was already initialised.
  integer(int32) function initialize_fullpos_grib_code_owner(owner) result(status)
    type(native_fullpos_grib_code_owner), intent(inout) :: owner
    status = 2
    if (owner%ready) return
    owner%ngrbdl = 228007_int32
    owner%ngrbgpp = 228081_int32
    owner%ngrbigpp = 228084_int32
    owner%ngrbinee = 228083_int32
    owner%ngrbirec = 228085_int32
    owner%ngrblblt = 228010_int32
    owner%ngrblicd = 228014_int32
    owner%ngrblict = 228013_int32
    owner%ngrblmld = 228009_int32
    owner%ngrblmlt = 228008_int32
    owner%ngrblshf = 228012_int32
    owner%ngrbltlt = 228011_int32
    owner%ngrbnee = 228080_int32
    owner%ngrbrec = 228082_int32
    owner%ngrbtcghg = [210064_int32, 210065_int32, 210066_int32]
    owner%ready = .true.
    status = 0
  end function
!> Bind a fresh readonly view to this actual persistent owner.
!! owner is a borrowed TARGET with IN intent. targets is INOUT and owns no payload.
!! Refusal2 changes no pointer. Success0 associates all15 native slots without allocation.
  integer(int32) function bind_fullpos_grib_code_targets(owner, targets) result(status)
    type(native_fullpos_grib_code_owner), target, intent(in) :: owner
    type(native_fullpos_grib_code_targets), intent(inout) :: targets
    status = 2
    if (.not. owner%ready) return
    if (associated(targets%ngrbdl)) return
    if (associated(targets%ngrbgpp)) return
    if (associated(targets%ngrbigpp)) return
    if (associated(targets%ngrbinee)) return
    if (associated(targets%ngrbirec)) return
    if (associated(targets%ngrblblt)) return
    if (associated(targets%ngrblicd)) return
    if (associated(targets%ngrblict)) return
    if (associated(targets%ngrblmld)) return
    if (associated(targets%ngrblmlt)) return
    if (associated(targets%ngrblshf)) return
    if (associated(targets%ngrbltlt)) return
    if (associated(targets%ngrbnee)) return
    if (associated(targets%ngrbrec)) return
    if (associated(targets%ngrbtcghg)) return
    targets%ngrbdl => owner%ngrbdl
    targets%ngrbgpp => owner%ngrbgpp
    targets%ngrbigpp => owner%ngrbigpp
    targets%ngrbinee => owner%ngrbinee
    targets%ngrbirec => owner%ngrbirec
    targets%ngrblblt => owner%ngrblblt
    targets%ngrblicd => owner%ngrblicd
    targets%ngrblict => owner%ngrblict
    targets%ngrblmld => owner%ngrblmld
    targets%ngrblmlt => owner%ngrblmlt
    targets%ngrblshf => owner%ngrblshf
    targets%ngrbltlt => owner%ngrbltlt
    targets%ngrbnee => owner%ngrbnee
    targets%ngrbrec => owner%ngrbrec
    targets%ngrbtcghg => owner%ngrbtcghg
    status = 0
  end function
!> Clear only borrowed associations before the owner lifetime ends.
!! This routine allocates and frees no payload and changes no code value.
  subroutine clear_fullpos_grib_code_targets(targets)
    type(native_fullpos_grib_code_targets), intent(inout) :: targets
    nullify (targets%ngrbdl)
    nullify (targets%ngrbgpp)
    nullify (targets%ngrbigpp)
    nullify (targets%ngrbinee)
    nullify (targets%ngrbirec)
    nullify (targets%ngrblblt)
    nullify (targets%ngrblicd)
    nullify (targets%ngrblict)
    nullify (targets%ngrblmld)
    nullify (targets%ngrblmlt)
    nullify (targets%ngrblshf)
    nullify (targets%ngrbltlt)
    nullify (targets%ngrbnee)
    nullify (targets%ngrbrec)
    nullify (targets%ngrbtcghg)
  end subroutine
!> Report whether the explicit declaration producer has completed.
  logical function fullpos_grib_codes_ready(owner) result(ready)
    type(native_fullpos_grib_code_owner), intent(in) :: owner
    ready = owner%ready
  end function
end module
