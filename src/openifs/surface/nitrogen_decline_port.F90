module nitro_decline_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_int64_t
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use ieee_exceptions, only: ieee_invalid, ieee_set_flag
  use yos_cst, only: tcst
  use yos_ags, only: tags
  implicit none
  private
  public :: nitro_decline, md2asm_nitro_decline_native_calls_get

  integer(c_int64_t), bind(c, name="md2asm_nitro_decline_native_calls"), save :: native_calls = 0_c_int64_t
  integer(int64), parameter :: sign_bit = int(z'8000000000000000', int64)
  integer(int64), parameter :: magnitude_mask = int(z'7fffffffffffffff', int64)
  integer(int64), parameter :: infinity_bits = int(z'7ff0000000000000', int64)
  integer(int64), parameter :: quiet_bit = int(z'0008000000000000', int64)
  real(real64), parameter :: latitude_intercept = transfer(int(z'40170a3d70a3d70a', int64), 0.0_real64)
  real(real64), parameter :: latitude_scale = transfer(int(z'3fe47ae147ae147b', int64), 0.0_real64)
  real(real64), parameter :: latitude_floor = transfer(int(z'400e666666666666', int64), 0.0_real64)
  real(real64), parameter :: conductance_power = transfer(int(z'3fd48b4395810625', int64), 0.0_real64)
  real(real64), parameter :: mortality_floor = transfer(int(z'3e45798ee2308c3a', int64), 0.0_real64)
  real(real64), parameter :: tenth_log_two = transfer(int(z'3fb1be9bff2e94bf', int64), 0.0_real64)

  interface
    function public_power(base, exponent) bind(c, name="pow") result(value)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: value
    end function public_power
    function public_arctangent(argument) bind(c, name="atan") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function public_arctangent
    function public_exponential(argument) bind(c, name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function public_exponential
    subroutine reject_input() bind(c, name="abort")
    end subroutine reject_input
  end interface

contains
  !> Update plant biomass in the order of the generated nitrogen_decline.S.
  !! Integer controls and vegetation types use int32. All real arguments use FP64.
  !! Every vector has at least KLON cells. KIDIA through KFDIA select active cells.
  !! TCST supplies day length in s, pi and the freezing temperature in K.
  !! TAGS supplies native vegetation tables whose valid type indices include 0 through 20.
  !! PTSPHY is the physics time step in s. PCV is the unitless tile fraction.
  !! PTSKM1M and PTSOIL are temperatures in K. PLAT is latitude in degrees.
  !! PLAI is leaf area divided by ground area in m2/m2.
  !! Biomass compartments and PBLOSS use kg/m2. Respiration accumulators use kg CO2/m2.
  !! PANFM is leaf assimilation in kg CO2/kg air m/s. All eight final vectors can change.
  !! Callers own all arrays and must supply disjoint writable owners where the source requires them.
  !! The caller qualifies actual floating-point controls. This entry also checks nearest rounding
  !! and gradual underflow without changing valid-path status. Public libm helper equivalence
  !! remains subject to the independent complete-byte check on each target.
  subroutine nitro_decline(kidia, kfdia, kvt, klon, kstep, ptsphy, pcv, &
                           ptskm1m, ptsoil, plat, plai, ydcst, ydags, panfm, prespbstr, prespbstr2, &
                           pbiomass_last, pbiomasstr_last, pbiomasstr2_last, pbiomass, pbloss)
    integer(int32), intent(in) :: kidia, kfdia, klon, kstep
    integer(int32), intent(in) :: kvt(:)
    real(real64), intent(in) :: ptsphy, pcv(:), ptskm1m(:), ptsoil(:), plat(:), plai(:)
    type(tcst), intent(in) :: ydcst
    type(tags), intent(in) :: ydags
    real(real64), intent(inout) :: panfm(:), prespbstr(:), prespbstr2(:)
    real(real64), intent(inout) :: pbiomass_last(:), pbiomasstr_last(:), pbiomasstr2_last(:)
    real(real64), intent(inout) :: pbiomass(:), pbloss(:)
    integer(int32) :: column, vegetation_type
    real(real64) :: day_length, pi_value, freezing_temperature
    real(real64) :: nitrogen_exponent, nitrogen_coefficient, respiration_factor, mortality_limit
    real(real64) :: allometry_coefficient, allometry_exponent, limiting_total
    real(real64) :: mortality_time, active_loss, active_mortality, structural_mortality
    real(real64) :: deep_mortality, assimilation, storage, total_biomass, structural_biomass, deep_biomass
    real(real64) :: latitude_correction, a, b, c, d, e
    real(real64), volatile :: underflow_input, underflow_result
    type(ieee_round_type) :: rounding

    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_input()
    underflow_input = tiny(0.0_real64)
    underflow_result = underflow_input*0.5_real64
    if (transfer(underflow_result, 0_int64) /= int(z'0008000000000000', int64)) call reject_input()
    if (klon < 1_int32 .or. klon > 4096_int32) call reject_input()
    if (kidia < 1_int32 .or. kidia > klon + 1_int32) call reject_input()
    if (kfdia < 0_int32 .or. kfdia > klon) call reject_input()
    if (size(kvt, kind=int64) < klon) call reject_input()
    if (size(pcv, kind=int64) < klon .or. size(ptskm1m, kind=int64) < klon) call reject_input()
    if (size(ptsoil, kind=int64) < klon .or. size(plat, kind=int64) < klon) call reject_input()
    if (size(plai, kind=int64) < klon .or. size(panfm, kind=int64) < klon) call reject_input()
    if (size(prespbstr, kind=int64) < klon .or. size(prespbstr2, kind=int64) < klon) call reject_input()
    if (size(pbiomass_last, kind=int64) < klon .or. size(pbiomasstr_last, kind=int64) < klon) call reject_input()
    if (size(pbiomasstr2_last, kind=int64) < klon .or. size(pbiomass, kind=int64) < klon) call reject_input()
    if (size(pbloss, kind=int64) < klon) call reject_input()

    day_length = ydcst%rday
    pi_value = ydcst%rpi
    freezing_temperature = ydcst%rtt
    nitrogen_exponent = ydags%rca_1x_co2_nit
    nitrogen_coefficient = ydags%rcc_nit
    respiration_factor = ydags%rrespfactor_nit
    mortality_limit = ydags%rtaulim
    if (nitrogen_coefficient <= 0.0_real64) call reject_input()
    if (nitrogen_exponent <= 0.0_real64) call reject_input()
    if (nitrogen_exponent >= 1.0_real64) call reject_input()

    a = public_power(10.0_real64, nitrogen_exponent)
    allometry_coefficient = nitrogen_coefficient/a
    allometry_exponent = nitrogen_exponent
    a = 1.0_real64/allometry_exponent
    limiting_total = public_power(allometry_coefficient, a)
    mortality_time = 0.0_real64
    active_loss = 0.0_real64
    active_mortality = 0.0_real64
    structural_mortality = 0.0_real64
    deep_mortality = 0.0_real64
    assimilation = 0.0_real64
    storage = 0.0_real64
    total_biomass = 0.0_real64
    structural_biomass = 0.0_real64
    deep_biomass = 0.0_real64

    do column = kidia, kfdia
      if (pcv(column) <= 0.0_real64) cycle
      vegetation_type = kvt(column)
      if (vegetation_type < 0_int32 .or. vegetation_type > 20_int32) call reject_input()
      deep_biomass = pbiomasstr2_last(column)

      a = abs(plat(column))
      a = a*pi_value
      a = a/180.0_real64
      if (iand(transfer(a, 0_int64), magnitude_mask) >= infinity_bits) call reject_input()
      a = public_arctangent(a)
      a = latitude_scale*a
      a = latitude_intercept - a
      latitude_correction = maximum_number(a, latitude_floor)

      a = panfm(column)/ydags%rvanmax(vegetation_type)
      a = minimum_number(1.0_real64, a)
      a = ydags%rvsefold(vegetation_type)*a
      b = ydags%rvgmes(vegetation_type)*1000.0_real64
      b = public_power(b, conductance_power)
      b = b*plai(column)
      b = b/latitude_correction
      b = maximum_number(b, 1.0_real64)
      a = a*b
      mortality_time = a/day_length
      mortality_time = maximum_number(mortality_floor, mortality_time)
      a = mortality_limit/100.0_real64
      a = a*ydags%rvsefold(vegetation_type)
      a = a/day_length
      mortality_time = maximum_number(a, mortality_time)

      a = ydags%rvlaimin(vegetation_type)*ydags%rvbslai_nitro(vegetation_type)
      a = pbiomass(column) - a
      b = -1.0_real64/mortality_time
      b = public_exponential(b)
      b = 1.0_real64 - b
      b = pbiomass(column)*b
      active_loss = minimum_number(a, b)
      active_loss = maximum_number(active_loss, 0.0_real64)
      assimilation = pbiomass(column) - pbiomass_last(column)
      pbiomass(column) = pbiomass(column) - active_loss

      a = -1.0_real64*day_length
      a = a/ydags%rvsefold(vegetation_type)
      a = public_exponential(a)
      a = 1.0_real64 - a
      deep_mortality = deep_biomass*a

      if (pbiomass(column) < pbiomass_last(column)) then
        storage = 0.0_real64
        a = -1.0_real64*day_length
        a = a/ydags%rvsefold(vegetation_type)
        a = public_exponential(a)
        a = 1.0_real64 - a
        structural_mortality = pbiomasstr_last(column)*a
        a = pbiomasstr_last(column) - structural_mortality
        structural_biomass = a - prespbstr(column)
        structural_biomass = maximum_number(structural_biomass, 0.0_real64)
        total_biomass = pbiomass(column) + structural_biomass
      else
        a = pbiomass(column)/allometry_coefficient
        b = 1.0_real64 - allometry_exponent
        b = 1.0_real64/b
        a = public_power(a, b)
        total_biomass = maximum_number(pbiomass(column), a)
        structural_biomass = total_biomass - pbiomass(column)
        a = -1.0_real64*day_length
        a = a/ydags%rvsefold(vegetation_type)
        a = public_exponential(a)
        a = 1.0_real64 - a
        structural_mortality = structural_biomass*a
        a = structural_biomass - pbiomasstr_last(column)
        a = a + structural_mortality
        storage = a + prespbstr(column)
      end if

      a = minimum_number(storage, 0.0_real64)
      deep_biomass = deep_biomass - a
      storage = maximum_number(0.0_real64, storage)
      if (.not. (storage <= active_loss)) then
        a = -1.0_real64*day_length
        a = a/ydags%rvsefold(vegetation_type)
        a = public_exponential(a)
        a = 1.0_real64 - a
        structural_mortality = pbiomasstr_last(column)*a
        a = pbiomass_last(column) + pbiomasstr_last(column)
        a = a + assimilation
        a = a - structural_mortality
        total_biomass = a - prespbstr(column)
        a = 1.0_real64 - allometry_exponent
        a = public_power(total_biomass, a)
        pbiomass(column) = allometry_coefficient*a
        structural_biomass = total_biomass - pbiomass(column)
        a = pbiomass_last(column) + assimilation
        active_loss = a - pbiomass(column)
        a = structural_biomass - pbiomasstr_last(column)
        a = a + structural_mortality
        storage = a + prespbstr(column)
      end if

      a = active_loss - storage
      active_mortality = maximum_number(0.0_real64, a)
      if (.not. (total_biomass > limiting_total)) then
        if (.not. (mortality_time <= 1.0_real64)) deep_biomass = deep_biomass + active_mortality
      end if
      a = deep_biomass - deep_mortality
      deep_biomass = a - prespbstr2(column)
      deep_biomass = maximum_number(deep_biomass, 0.0_real64)
      pbiomass_last(column) = pbiomass(column)
      pbiomasstr_last(column) = structural_biomass
      pbiomasstr2_last(column) = deep_biomass
      prespbstr(column) = 0.0_real64
      prespbstr2(column) = 0.0_real64
      panfm(column) = 0.0_real64
      pbloss(column) = active_loss
    end do

    do column = kidia, kfdia
      if (pcv(column) <= 0.0_real64) cycle
      a = pbiomasstr_last(column)*respiration_factor
      b = ptskm1m(column) - freezing_temperature
      b = b - 25.0_real64
      b = tenth_log_two*b
      b = public_exponential(b)
      a = a*b
      a = a*ptsphy
      prespbstr(column) = prespbstr(column) + a

      a = pbiomasstr2_last(column)*respiration_factor
      b = ptsoil(column) - freezing_temperature
      b = b - 25.0_real64
      b = tenth_log_two*b
      b = public_exponential(b)
      a = a*b
      a = a*ptsphy
      prespbstr2(column) = prespbstr2(column) + a
    end do

    if (native_calls == huge(native_calls)) then
      native_calls = -huge(native_calls) - 1_c_int64_t
    else
      native_calls = native_calls + 1_c_int64_t
    end if
  end subroutine nitro_decline

  !> Return the completed-call counter as its unchanged 64-bit word.
  function md2asm_nitro_decline_native_calls_get() bind(c) result(count)
    integer(c_int64_t) :: count
    count = native_calls
  end function md2asm_nitro_decline_native_calls_get

  !> Apply the original maximum-number rule, including signed zeros and NaN words.
  function maximum_number(left, right) result(value)
    real(real64), intent(in) :: left, right
    real(real64) :: value
    integer(int64) :: left_bits, right_bits
    logical :: left_nan, right_nan
    left_bits = transfer(left, 0_int64)
    right_bits = transfer(right, 0_int64)
    left_nan = iand(left_bits, magnitude_mask) > infinity_bits
    right_nan = iand(right_bits, magnitude_mask) > infinity_bits
    if (left_nan .or. right_nan) then
      call select_nan_or_number(left_bits, right_bits, left_nan, right_nan, value)
    else if (left > right) then
      value = left
    else if (left < right) then
      value = right
    else if (iand(left_bits, magnitude_mask) == 0_int64) then
      value = transfer(iand(left_bits, right_bits), 0.0_real64)
    else
      value = left
    end if
  end function maximum_number

  !> Apply the original minimum-number rule, including signed zeros and NaN words.
  function minimum_number(left, right) result(value)
    real(real64), intent(in) :: left, right
    real(real64) :: value
    integer(int64) :: left_bits, right_bits
    logical :: left_nan, right_nan
    left_bits = transfer(left, 0_int64)
    right_bits = transfer(right, 0_int64)
    left_nan = iand(left_bits, magnitude_mask) > infinity_bits
    right_nan = iand(right_bits, magnitude_mask) > infinity_bits
    if (left_nan .or. right_nan) then
      call select_nan_or_number(left_bits, right_bits, left_nan, right_nan, value)
    else if (left < right) then
      value = left
    else if (left > right) then
      value = right
    else if (iand(left_bits, magnitude_mask) == 0_int64) then
      value = transfer(ior(left_bits, right_bits), 0.0_real64)
    else
      value = left
    end if
  end function minimum_number

  !> Select the numerical operand or quiet the first available NaN payload.
  subroutine select_nan_or_number(left_bits, right_bits, left_nan, right_nan, value)
    integer(int64), intent(in) :: left_bits, right_bits
    logical, intent(in) :: left_nan, right_nan
    real(real64), intent(out) :: value
    logical :: left_signaling, right_signaling
    left_signaling = left_nan .and. iand(left_bits, quiet_bit) == 0_int64
    right_signaling = right_nan .and. iand(right_bits, quiet_bit) == 0_int64
    if (left_signaling .or. right_signaling) then
      call ieee_set_flag(ieee_invalid, .true.)
      if (left_signaling) then
        value = transfer(ior(left_bits, quiet_bit), 0.0_real64)
      else
        value = transfer(ior(right_bits, quiet_bit), 0.0_real64)
      end if
    else if (.not. left_nan) then
      value = transfer(left_bits, 0.0_real64)
    else if (.not. right_nan) then
      value = transfer(right_bits, 0.0_real64)
    else
      value = transfer(ior(left_bits, quiet_bit), 0.0_real64)
    end if
  end subroutine select_nan_or_number
end module nitro_decline_mod
