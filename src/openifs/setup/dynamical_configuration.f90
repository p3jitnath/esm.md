module dynamical_configuration_port
  !! Construct the owned configuration for large-scale atmospheric motion.
  !! All real fields use FP64. Scale factors and switches are dimensionless.
  use, intrinsic :: iso_c_binding, only: c_double, c_int32_t, c_int64_t, c_char
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use physics_configuration_text_port, only: find_physics_group, skip_physics_space, &
                                             physics_key_character, physics_space, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: native_dynamical_configuration, owned_dynamical_configuration
  public :: initialize_dynamical_configuration, initialize_operational_dynamical_configuration
  public :: initialize_owned_dynamical_configuration
  type, bind(C) :: native_dynamical_configuration
    real(c_double) :: rplrg = 0, rpldare = 0, rplradi = 0, rusplradi = 0, rcorioi = 0, ruscorioi = 0, rusplrg = 0
    real(c_double) :: ramp = 0, rt00_dyn = 0, rp00_dyn = 0, ru00_dyn = 0, rst0_dyn = 0, rsigmab = 0, reference_level = 0
    real(c_double) :: rdelta_t = 0, rdelta_theta = 0, rpressure_scale = 0
    real(c_double) :: rhs_kf = 0, rhs_ka = 0, rhs_ks = 0, rhs_ks_ka = 0, rhs_kappa = 0
    real(c_double) :: rthsw_0 = 0, rphsw_d = 0, rphsw_eq = 0, rphsw_pl = 0, rphsw_eq_pl_half = 0, rphsw_d_rev = 0
    real(c_double) :: rjacsldia = 0, rlipsldia = 0, rchi = 0, rlambda0 = 0, rlambdad = 0, rphid = 0
    integer(c_int32_t) :: laqua = 0, lape = 0, lheldsuarez = 0, lppsteps = 0, l_hs_williamson = 0
    integer(c_int32_t) :: ntestcase = 0, msstscheme = 0, noisevor = 0
    character(c_char) :: ctest_family(12) = achar(0, kind=c_char)
  end type
  type(native_dynamical_configuration), bind(C, name='md2asm_owned_dynamical_configuration_native'), &
    save, target :: owned_dynamical_configuration
contains
  integer(c_int32_t) function initialize_dynamical_configuration(text, output) result(status)
    !! text is a bounded source group; output is one caller-owned mutable record.
    !! The first uppercase NAMDYNCORE must be empty. Refusal changes no output.
    !! The caller supplies nearest rounding, gradual underflow and no FP traps.
    character(len=*), intent(in) :: text
    type(native_dynamical_configuration), intent(inout) :: output
    status = require_empty_physics_group(text, 'NAMDYNCORE')
    if (status /= 0) return
    call construct_defaults(output)
  end function
  integer(c_int32_t) function initialize_operational_dynamical_configuration(text, output) result(status)
    !! Admit an empty group or repeated explicit LAQUA=false assignments.
    !! This preserves the selected Earth configuration with upstream text intact.
    character(len=*), intent(in) :: text
    type(native_dynamical_configuration), intent(inout) :: output
    integer :: cursor, first, last, n
    logical :: value, valid
    status = 2
    cursor = find_physics_group(text, 'NAMDYNCORE', .true.)
    if (cursor == 0) return
    n = len(text)
    do
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) == ',') then
        cursor = cursor + 1
        cycle
      end if
      if (text(cursor:cursor) == '/') exit
      first = cursor
      do while (cursor <= n)
        if (.not. physics_key_character(text(cursor:cursor), .false.)) exit
        cursor = cursor + 1
      end do
      last = cursor - 1
      if (last < first) return
      if (.not. physics_fold_equal(text(first:last), 'LAQUA')) return
      call skip_physics_space(text, cursor)
      if (cursor > n) return
      if (text(cursor:cursor) /= '=') return
      cursor = cursor + 1
      call skip_physics_space(text, cursor)
      first = cursor
      do while (cursor <= n)
        if (physics_space(text(cursor:cursor))) exit
        if (index(',!/', text(cursor:cursor)) /= 0) exit
        cursor = cursor + 1
      end do
      if (cursor > n .or. cursor == first) return
      call parse_physics_boolean(text(first:cursor - 1), value, valid)
      if (.not. valid .or. value) return
    end do
    call construct_defaults(output)
    status = 0
  end function
  integer(c_int32_t) function initialize_owned_dynamical_configuration(text, operational) result(status)
    !! Initialise only the named native namespace. No original module is used.
    character(len=*), intent(in) :: text
    logical, intent(in) :: operational
    if (operational) then
      status = initialize_operational_dynamical_configuration(text, owned_dynamical_configuration)
    else
      status = initialize_dynamical_configuration(text, owned_dynamical_configuration)
    end if
  end function
  subroutine construct_defaults(output)
    !! Preserve source store and scalar arithmetic order. Temperatures are K;
    !! rp00_dyn and rphsw_d are Pa, rphsw_pl is hPa, and all scales are unitless.
    !! Eleven source-unwritten FP64 fields and alignment bytes stay unchanged.
    type(native_dynamical_configuration), intent(inout) :: output
    real(c_double), volatile :: one, ratio, denominator
    one = 1.0_c_double
    output%lppsteps = 0
    output%rt00_dyn = 288.15_c_double
    output%rp00_dyn = 101315.0_c_double
    output%ru00_dyn = 0.0_c_double
    output%rst0_dyn = 0.0_c_double
    output%noisevor = 0
    output%ramp = 0.0_c_double
    output%rusplradi = 1.0_c_double
    output%ruscorioi = 1.0_c_double
    output%rusplrg = 1.0_c_double
    denominator = output%rusplradi
    ratio = one/denominator
    output%rplradi = ratio
    denominator = output%ruscorioi
    ratio = one/denominator
    output%rcorioi = ratio
    denominator = output%rusplrg
    ratio = one/denominator
    output%rplrg = ratio
    output%rpldare = 1.0_c_double
    output%ctest_family = ' '
    output%ntestcase = -1
    output%laqua = 0
    output%lape = 0
    output%msstscheme = 9
    output%lheldsuarez = 0
    output%rdelta_t = 60.0_c_double
    output%rdelta_theta = 10.0_c_double
    output%rsigmab = 0.7_c_double
    ratio = one - output%rsigmab
    output%reference_level = ratio
    output%rpressure_scale = 0.00001_c_double
    output%rhs_kappa = transfer(int(z'3fd2492492492492', c_int64_t), 0.0_c_double)
    output%l_hs_williamson = 0
    output%rthsw_0 = 200.0_c_double
    output%rphsw_pl = 10.0_c_double
    output%rphsw_d = 10000.0_c_double
    output%rjacsldia = 1.5_c_double
    output%rlipsldia = 5.0_c_double
    denominator = output%rusplradi
    ratio = one/denominator
    output%rplradi = ratio
    if (output%ruscorioi /= 0.0_c_double) then
      denominator = output%ruscorioi
      ratio = one/denominator
      output%rcorioi = ratio
    else
      output%rcorioi = 0.0_c_double
    end if
    denominator = output%rusplrg
    ratio = one/denominator
    output%rplrg = ratio
  end subroutine
end module dynamical_configuration_port
