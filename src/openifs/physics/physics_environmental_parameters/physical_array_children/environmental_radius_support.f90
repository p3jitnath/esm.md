!> Native particle configuration and declared public scalar math services.
module forecast_environmental_radius_support
  use iso_c_binding, only: c_double
  use iso_fortran_env, only: int32, int64, real64
  use forecast_public_scalar_math, only: power_original_rounding
  implicit none
  private
  public :: radius_perturbation_entry, radius_perturbation_view, liquid_radius_controls, ice_radius_controls
  public :: public_exp, public_log, public_asin, public_cos, power_original_rounding, numeric_min, numeric_max
  !> Dimensionless perturbation coefficients and its one-based pattern column.
  type :: radius_perturbation_entry
    real(real64) :: mean, magnitude
    integer(int32) :: pattern
  end type
  !> Borrow one live entry table; the caller retains its bounds and lifetime.
  type :: radius_perturbation_view
    logical :: enabled
    integer(int32) :: selected_entry, pattern_count
    type(radius_perturbation_entry), pointer :: entries(:) => null()
  end type
  !> Copy only the source-selected controls; nuclei are in particles per cm3.
  type :: liquid_radius_controls
    integer(int32) :: mode, atmospheric_aerosols, radiation_selector, radiation_aerosols, cloud_aerosols
    logical :: local_land_nuclei, local_sea_nuclei
    real(real64) :: land_nuclei, sea_nuclei
  end type
  !> Diameter controls are in micrometres; the radius factor is dimensionless.
  type :: ice_radius_controls
    integer(int32) :: mode
    logical :: latitude_minimum
    real(real64) :: radius_factor, minimum_diameter
  end type
  interface
    function public_exp(x) bind(C, name="exp") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_log(x) bind(C, name="log") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_asin(x) bind(C, name="asin") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_cos(x) bind(C, name="cos") result(y)
      import c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  !> Return the numeric minimum, including signed-zero and NaN selection.
  function numeric_min(a, b) result(v)
    real(real64), intent(in) :: a, b
    real(real64) :: v
    integer(int64) :: ia, ib, aa, ab
    logical :: na, nb, sa, sb
    ia = transfer(a, 0_int64); ib = transfer(b, 0_int64)
    aa = iand(ia, int(z'7fffffffffffffff', int64)); ab = iand(ib, int(z'7fffffffffffffff', int64))
    na = aa > int(z'7ff0000000000000', int64); nb = ab > int(z'7ff0000000000000', int64)
    sa = na .and. .not. btest(ia, 51); sb = nb .and. .not. btest(ib, 51)
    if (sa .or. sb .or. (na .and. nb)) then
      v = a + b
    else if (na) then
      v = b
    else if (nb) then
      v = a
    else if (aa == 0 .and. ab == 0) then
      v = transfer(ior(ia, ib), 0.0_real64)
    else if (a < b) then
      v = a
    else
      v = b
    end if
  end function
  !> Return the numeric maximum, including signed-zero and NaN selection.
  function numeric_max(a, b) result(v)
    real(real64), intent(in) :: a, b
    real(real64) :: v
    integer(int64) :: ia, ib, aa, ab
    logical :: na, nb, sa, sb
    ia = transfer(a, 0_int64); ib = transfer(b, 0_int64)
    aa = iand(ia, int(z'7fffffffffffffff', int64)); ab = iand(ib, int(z'7fffffffffffffff', int64))
    na = aa > int(z'7ff0000000000000', int64); nb = ab > int(z'7ff0000000000000', int64)
    sa = na .and. .not. btest(ia, 51); sb = nb .and. .not. btest(ib, 51)
    if (sa .or. sb .or. (na .and. nb)) then
      v = a + b
    else if (na) then
      v = b
    else if (nb) then
      v = a
    else if (aa == 0 .and. ab == 0) then
      v = transfer(iand(ia, ib), 0.0_real64)
    else if (a > b) then
      v = a
    else
      v = b
    end if
  end function
end module
