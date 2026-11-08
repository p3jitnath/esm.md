!> Own the integer control producers used at SUGFL1 and SUPHEC boundaries.
module ecmwf_physics_control_fields_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use minimum_surface_ice_fraction_port, only: initialize_minimum_surface_ice_fraction
  implicit none
  private
  public :: initialize_minimum_surface_ice_fraction
  public :: selected_composition_aerosol_flags, physics_runtime_inputs
  public :: initialize_selected_composition_aerosol_flags, initialize_ecmwf_physics_runtime_inputs

  !> Two source SUGFL1 controls for the selected zero-composition route.
  type :: selected_composition_aerosol_flags
    logical :: laernitrate, laersoa
  end type

  !> Native runtime controls and roughness inputs consumed by SUPHEC.
  !! LSCMEC and LVDFTRAJ have explicit false producers. LROUGH, REXTZ0M
  !! and REXTZ0H use the original zero-initialized module-storage policy.
  !! Roughness extension lengths REXTZ0M and REXTZ0H are in metres.
  !! No explicit target padding member is added; the compiler owns padding.
  type :: physics_runtime_inputs
    logical :: lscmec, lvdftraj, lrough
    real(real64) :: rextz0m, rextz0h
  end type
contains
  !> Apply the original false assignments when all three live counts are zero.
  !! OUTPUT is caller-owned native flags. COUNTS is a readonly int32 array
  !! of exactly three entries, ordered NCHEM, NGHG and NAERO. These record
  !! and array spans must be separate. Return2 before writes for a nonzero
  !! count, unsupported shape or overlap; otherwise write both flags and
  !! return0. All operations are integer or exact logical stores.
  integer(int32) function initialize_selected_composition_aerosol_flags(output, counts) result(status)
    type(selected_composition_aerosol_flags), intent(inout), target :: output
    integer(int32), intent(in), contiguous, target :: counts(:)
    integer(c_intptr_t) :: first, second
    integer(int64) :: first_bytes
    status = 2_int32
    if (size(counts) /= 3) return
    first = transfer(c_loc(output), first)
    second = transfer(c_loc(counts), second)
    first_bytes = storage_size(output, kind=int64)/8_int64
    if (first <= second) then
      if (second - first < first_bytes) return
    else
      if (first - second < 12_int64) return
    end if
    if (any(counts /= 0_int32)) return
    output%laernitrate = .false.
    output%laersoa = .false.
    status = 0_int32
  end function

  !> Produce the source runtime flags and explicit initial-storage policy.
  !! OUTPUT is a complete caller-owned native record with intent INOUT.
  !! Each named member is set separately, preserving all compiler padding.
  !! No floating operation, service call or allocation is needed. Return0.
  integer(int32) function initialize_ecmwf_physics_runtime_inputs(output) result(status)
    type(physics_runtime_inputs), intent(inout) :: output
    output%lscmec = .false.
    output%lvdftraj = .false.
    output%lrough = .false.
    output%rextz0m = 0.0_real64
    output%rextz0h = 0.0_real64
    status = 0_int32
  end function
end module
