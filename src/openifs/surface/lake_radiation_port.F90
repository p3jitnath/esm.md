!> Port the ordered transmission and layer means in lake_radiation.S.
!! The original type modules define data only; EXP is the public C service.
module flakerad_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yos_flake, only: tflake, ropticpar_medium
  implicit none
  private
  public :: flakerad
  interface
    function selected_exp(value) bind(c, name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_exp
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Compute lake radiation over the inclusive active column interval.
  !! KIDIA and KFDIA are int32 indices into every rank-one array.
  !! LDLAKEPOINT selects lake columns. Depths and layer thicknesses are in m.
  !! The two optical records contain 1 to 6 band fractions and coefficients in 1/m.
  !! Radiation inputs and outputs are real64 fluxes in W/m2.
  !! YDFLAKE supplies the minimum ice and mixed-layer thicknesses in m.
  !! Output arrays retain all inactive and non-lake words, including signed zeros.
  !! All arrays must contain the active indices; native sections can have signed strides.
  subroutine flakerad(kidia, kfdia, ldlakepoint, pdepth_w, popticpar_water, popticpar_ice, &
      ydflake, pi_atm_flk, ph_ice_p_flk, ph_ml_p_flk, pi_ice_flk, pi_bot_flk, pi_w_flk, &
      pi_h_flk, pi_intm_0_h_flk, pi_intm_h_d_flk)
    integer(int32), intent(in) :: kidia, kfdia
    logical, intent(in) :: ldlakepoint(:)
    real(real64), intent(in) :: pdepth_w(:), pi_atm_flk(:), ph_ice_p_flk(:), ph_ml_p_flk(:)
    type(ropticpar_medium), intent(in) :: popticpar_water, popticpar_ice
    type(tflake), intent(in) :: ydflake
    real(real64), intent(inout) :: pi_ice_flk(:), pi_bot_flk(:), pi_w_flk(:)
    real(real64), intent(inout) :: pi_h_flk(:), pi_intm_0_h_flk(:), pi_intm_h_d_flk(:)
    integer(int32) :: column, band
    logical :: mixed_present, deep_present
    type(ieee_round_type) :: rounding
    real(real64), volatile :: gradual_operand, gradual_scale
    real(real64) :: gradual_probe, depth, mixed_depth, ice_depth, incoming, water_surface
    real(real64) :: ice_sum, mixed_sum, bottom_sum, mixed_mean, deep_mean
    real(real64) :: a, b, ratio, mixed_exponential, bottom_exponential

    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    gradual_operand = tiny(1.0_real64)
    gradual_scale = 0.5_real64
    gradual_probe = gradual_operand * gradual_scale
    if (gradual_probe == 0.0_real64) call reject_contract()
    if (kidia > kfdia) return

    do column = kidia, kfdia
      if (.not. ldlakepoint(column)) cycle
      depth = max(2.0_real64, pdepth_w(column))
      depth = min(50.0_real64, depth)
      mixed_depth = ph_ml_p_flk(column)
      incoming = pi_atm_flk(column)
      pi_ice_flk(column) = incoming
      ice_depth = ph_ice_p_flk(column)
      if (ice_depth >= ydflake%rh_ice_min_flk) then
        ice_sum = 0.0_real64
        do band = 1, popticpar_ice%nband_optic
          a = -popticpar_ice%rextincoef_optic(band)
          a = a * ice_depth
          a = selected_exp(a)
          a = popticpar_ice%rfrac_optic(band) * a
          ice_sum = ice_sum + a
        end do
        water_surface = incoming * ice_sum
      else
        water_surface = incoming
      end if
      pi_w_flk(column) = water_surface

      mixed_present = mixed_depth >= ydflake%rh_ml_min_flk
      a = depth - ydflake%rh_ml_min_flk
      deep_present = mixed_depth <= a
      mixed_sum = 0.0_real64
      bottom_sum = 0.0_real64
      mixed_mean = 0.0_real64
      deep_mean = 0.0_real64
      do band = 1, popticpar_water%nband_optic
        if (mixed_present .or. deep_present) then
          a = -popticpar_water%rextincoef_optic(band)
          a = a * mixed_depth
          mixed_exponential = selected_exp(a)
        end if
        a = -popticpar_water%rextincoef_optic(band)
        a = a * depth
        bottom_exponential = selected_exp(a)
        a = popticpar_water%rfrac_optic(band) * bottom_exponential
        bottom_sum = bottom_sum + a
        if (.not. (mixed_present .or. deep_present)) cycle
        ratio = popticpar_water%rfrac_optic(band) / popticpar_water%rextincoef_optic(band)
        if (mixed_present) then
          a = popticpar_water%rfrac_optic(band) * mixed_exponential
          mixed_sum = mixed_sum + a
          a = 1.0_real64 - mixed_exponential
          a = ratio * a
          mixed_mean = mixed_mean + a
        end if
        if (deep_present) then
          a = mixed_exponential - bottom_exponential
          a = ratio * a
          deep_mean = deep_mean + a
        end if
      end do
      a = water_surface * bottom_sum
      pi_bot_flk(column) = a
      if (mixed_present) then
        mixed_sum = water_surface * mixed_sum
        mixed_mean = water_surface * mixed_mean
        mixed_mean = mixed_mean / mixed_depth
      else
        mixed_sum = water_surface
        mixed_mean = mixed_sum
      end if
      pi_h_flk(column) = mixed_sum
      pi_intm_0_h_flk(column) = mixed_mean
      if (deep_present) then
        deep_mean = water_surface * deep_mean
        a = depth - mixed_depth
        deep_mean = deep_mean / a
      else
        deep_mean = mixed_sum
      end if
      pi_intm_h_d_flk(column) = deep_mean
    end do
  end subroutine flakerad
end module flakerad_mod
