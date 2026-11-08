!> Preserve the named field, rotation and vertical interpolation selectors.
module forecast_interpolation_control_children
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: initialize_field_interpolation_controls, initialize_coriolis_controls
  public :: initialize_vertical_smoothness_controls
contains
  !> Set the ten dimensionless source logical outputs from explicit live inputs.
  !! NCONF is an int32 route number. LECMWF and LSLAG are native logicals
  !! whose representations must be canonical0or1. Refusal2 changes no output.
  !! The caller passes its existing named fields, so this child owns no record.
  integer(c_int) function initialize_field_interpolation_controls(nconf, lecmwf, lslag, &
                                                 lqmw, lqmhw, lqmt, lqmht, lqmp, lqmhp, lqmpd, lqmhpd, lqmvd, lqmhvd) result(status)
    integer(c_int), intent(in) :: nconf
    logical, intent(in) :: lecmwf, lslag
    logical, intent(inout) :: lqmw, lqmhw, lqmt, lqmht, lqmp, lqmhp, lqmpd, lqmhpd, lqmvd, lqmhvd
    logical :: active
    status = 2
    if (.not. canonical_logical(lecmwf) .or. .not. canonical_logical(lslag)) return
    active = lslag .and. (nconf == 1 .or. nconf == 302 .or. nconf == 904 .or. (.not. lecmwf .and. nconf == 131))
    lqmw = .false.; lqmhw = active; lqmt = .false.; lqmht = active; lqmp = active
    lqmhp = .false.; lqmpd = .false.; lqmhpd = .false.; lqmvd = .false.; lqmhvd = .false.
    status = 0
  end function
  !> Set source Coriolis selectors without changing the four logical inputs.
  !! All values are dimensionless. Success0 publishes LADVF then LIMPF.
  integer(c_int) function initialize_coriolis_controls(lecmwf, lr2d, ltwotl, lslag, ladvf, limpf) result(status)
    logical, intent(in) :: lecmwf, lr2d, ltwotl, lslag
    logical, intent(inout) :: ladvf, limpf
    logical :: both, implicit_value, advective_value
    status = 2
    if (.not. canonical_logical(lecmwf) .or. .not. canonical_logical(lr2d)) return
    if (.not. canonical_logical(ltwotl) .or. .not. canonical_logical(lslag)) return
    both = ltwotl .and. lslag
    if (lecmwf) then
      if (lr2d) then
        implicit_value = .true.; advective_value = .false.
      else
        implicit_value = both; advective_value = .not. both
      end if
    else
      implicit_value = .false.; advective_value = both
    end if
    ladvf = advective_value; limpf = implicit_value
    status = 0
  end function
  !> Set dimensionless smoothness controls from the live sponge-level value.
  !! KLSPONGE is FP64 in0:255. NINT retains source half ties away from zero.
  !! The six output fields change only after complete scalar admission.
  integer(c_int) function initialize_vertical_smoothness_controls(klspongE, ralpha, ralpha_top, &
                                                                  nlev_zalpha, neder, lwenobc, nqmhoislt) result(status)
    real(c_double), intent(in) :: klsponge
    real(c_double), intent(inout) :: ralpha, ralpha_top
    integer(c_int), intent(inout) :: nlev_zalpha, neder, nqmhoislt
    logical, intent(inout) :: lwenobc
    integer(c_int64_t) :: bits
    integer(c_int) :: rounded
    status = 2
    bits = transfer(klsponge, bits)
    if (ibits(bits, 52, 11) == 2047_c_int64_t) return
    if (klsponge < 0.0_c_double .or. klsponge > 255.0_c_double) return
    rounded = nint(klsponge, kind=c_int)
    ralpha = 2.0_c_double; ralpha_top = 2.0_c_double
    nlev_zalpha = rounded; neder = 5; lwenobc = .false.; nqmhoislt = 0
    status = 0
  end function
  pure logical function canonical_logical(value) result(valid)
    logical, intent(in) :: value
    integer(c_int) :: bits
    bits = transfer(value, bits)
    valid = bits == 0 .or. bits == 1
  end function
end module forecast_interpolation_control_children
