module vertical_configuration_port
  !! Own named vertical-discretisation controls and bounded input admission.
  !! Logical switches use canonical C int32 values zero or one.
  use, intrinsic :: iso_c_binding, only: c_double, c_int32_t, c_int64_t
  use physics_configuration_text_port, only: skip_physics_space, physics_space, &
                                             physics_key_character, physics_fold_equal, parse_physics_boolean
  implicit none
  private
  public :: native_vertical_configuration, initialize_vertical_configuration
  public :: read_operational_vertical_controls, initialize_operational_vertical_configuration
  type, bind(C) :: native_vertical_configuration
    integer(c_int32_t) :: laprxpk = 0, ndlnpr = 0
    real(c_double) :: rhydr0 = 0
    integer(c_int32_t) :: lregeta = 0, lvfe_regeta = 0, nvsch = 0, nvfe_type = 0, nvfe_order = 0
    integer(c_int32_t) :: nvfe_intbc = 0, nvfe_derbc = 0, nvfe_internals = 0, nvfe_bc = 0, lvertfe = 0
    integer(c_int32_t) :: lvfe_lapl = 0, lvfe_lapl_bc = 0, lvfe_lapl_tbc = 0, lvfe_lapl_bbc = 0, lvfe_lapl2pi = 0
    real(c_double) :: rlapl2pi = 0
    integer(c_int32_t) :: lvfe_x_term = 0, lvfe_z_term = 0, lvfe_gw = 0, lvfe_delnhpre = 0, lvfe_gwmpa = 0
    integer(c_int32_t) :: lvfe_centri = 0, lvfe_cheb = 0
    real(c_double) :: rvfe_centri = 0, rvfe_alpha = 0, rvfe_beta = 0, rvfe_knot_stretch = 0
    integer(c_int32_t) :: lvfe_approx = 0, lvfe_ecmwf = 0, lvfe_lapl_half = 0, lvfe_fix_order = 0
    integer(c_int32_t) :: lvfe_gw_half = 0, lvfe_maximas = 0, lvfe_verbose = 0, lvfe_normalize = 0, ldyn_analysis_stability = 0
    real(c_double) :: rmindeta = 0, rfac1 = 0, rfac2 = 0
  end type
contains
  integer(c_int32_t) function initialize_vertical_configuration(output, ecmwf, nonhydrostatic, two_dimensional) result(status)
    !! output is a mutable native record. The three inputs are canonical int32.
    !! All coefficients are dimensionless. Source-unwritten members and padding
    !! remain unchanged, including rlapl2pi and rvfe_centri.
    type(native_vertical_configuration), intent(inout) :: output
    integer(c_int32_t), intent(in) :: ecmwf, nonhydrostatic, two_dimensional
    integer(c_int32_t) :: finite_elements
    status = 2
    if (ecmwf < 0 .or. ecmwf > 1) return
    if (nonhydrostatic < 0 .or. nonhydrostatic > 1) return
    if (two_dimensional < 0 .or. two_dimensional > 1) return
    finite_elements = 0
    if (ecmwf == 1 .and. nonhydrostatic == 0 .and. two_dimensional == 0) finite_elements = 1
    output%laprxpk = ecmwf
    output%ndlnpr = 0
    if (ecmwf == 1) then
      output%rhydr0 = transfer(int(z'3fe62e42fefa39ef', c_int64_t), 0.0_c_double)
    else
      output%rhydr0 = 1.0_c_double
    end if
    output%lregeta = 0
    output%lvfe_regeta = 0
    output%nvsch = 0
    output%nvfe_type = 3*finite_elements
    output%nvfe_order = output%nvfe_type + 1
    output%nvfe_intbc = 3*finite_elements
    output%nvfe_derbc = 3*finite_elements
    output%nvfe_internals = 0
    output%nvfe_bc = 0
    output%lvertfe = finite_elements
    output%lvfe_lapl = 0
    output%lvfe_lapl_bc = 0
    output%lvfe_lapl_tbc = 0
    output%lvfe_lapl_bbc = 0
    output%lvfe_lapl2pi = 0
    output%lvfe_x_term = 0
    output%lvfe_z_term = 0
    output%lvfe_gw = 0
    output%lvfe_delnhpre = 0
    output%lvfe_gwmpa = 0
    output%lvfe_centri = finite_elements
    output%lvfe_cheb = 0
    output%rvfe_alpha = 0.0_c_double
    output%rvfe_beta = 0.5_c_double
    output%rvfe_knot_stretch = 1.0_c_double
    output%lvfe_approx = 0
    output%lvfe_ecmwf = 0
    output%lvfe_lapl_half = 0
    output%lvfe_fix_order = finite_elements
    output%lvfe_gw_half = 0
    output%lvfe_maximas = 0
    output%lvfe_verbose = 0
    output%lvfe_normalize = 0
    output%ldyn_analysis_stability = 0
    output%rmindeta = 0.0_c_double
    output%rfac1 = 0.0_c_double
    output%rfac2 = 0.0_c_double
    status = 0
  end function
  integer function first_operational_group(text) result(cursor)
    !! Select the first uppercase NAMCVER prefix, including unsupported positions.
    !! A supported marker is the first token within byte columns one through ten.
    character(len=*), intent(in) :: text
    integer :: i, first, line_start, n, last
    cursor = 0
    n = len(text)
    if (n < 1 .or. n > 262144) return
    first = 0; line_start = 1
    do i = 1, n
      if (iachar(text(i:i)) == 10) then
        first = 0; line_start = i + 1
        cycle
      end if
      if (first == 0) then
        if (.not. physics_space(text(i:i))) first = i
      end if
      if (text(i:i) /= '&') cycle
      last = i + 7
      if (last > n) cycle
      if (text(i:last) /= '&NAMCVER') cycle
      if (i /= first .or. i - line_start > 9) return
      if (last == n) return
      if (.not. physics_space(text(last + 1:last + 1))) then
        if (index(',/!', text(last + 1:last + 1)) == 0) return
      end if
      cursor = last + 1
      return
    end do
  end function
  subroutine parse_signed_integer(token, value, valid)
    !! Parse one complete decimal int32 without overflowing an intermediate.
    character(len=*), intent(in) :: token
    integer(c_int32_t), intent(out) :: value
    logical, intent(out) :: valid
    integer :: i, code, negative
    integer(c_int64_t) :: accumulated, limit
    value = 0; valid = .false.
    if (len(token) == 0) return
    i = 1; negative = 0
    if (token(1:1) == '+' .or. token(1:1) == '-') then
      if (token(1:1) == '-') negative = 1
      i = 2
    end if
    if (i > len(token)) return
    accumulated = 0
    limit = 2147483647_c_int64_t + negative
    do while (i <= len(token))
      code = iachar(token(i:i)) - 48
      if (code < 0 .or. code > 9) return
      if (accumulated > (limit - code)/10_c_int64_t) return
      accumulated = 10_c_int64_t*accumulated + code
      i = i + 1
    end do
    if (negative == 1) accumulated = -accumulated
    value = int(accumulated, c_int32_t); valid = .true.
  end subroutine
  integer(c_int32_t) function read_operational_vertical_controls(text, geometry, output) result(status)
    !! geometry has [levels,ECMWF,nonhydrostatic,two_dimensional]=[137,1,0,0].
    !! output(6) appends NVSCH and LVFE_GWMPA. It changes only on success.
    character(len=*), intent(in) :: text
    integer(c_int32_t), intent(in) :: geometry(4)
    integer(c_int32_t), intent(inout) :: output(6)
    character(len=12), parameter :: keys(9) = [character(len=12) :: &
                                               'LVERTFE', 'NVSCH', 'LVFE_GWMPA', 'LVFE_GW', 'LVFE_Z_TERM', 'LVFE_X_TERM', &
                                               'LVFE_LAPL_BC', 'LVFE_LAPL', 'NDLNPR']
    integer(c_int32_t) :: values(9), parsed
    integer :: cursor, first, last, n, key, j
    logical :: valid, boolean
    status = 2
    if (any(geometry /= [137_c_int32_t, 1_c_int32_t, 0_c_int32_t, 0_c_int32_t])) return
    cursor = first_operational_group(text)
    if (cursor == 0) return
    n = len(text)
    values = 0; values(1) = 1
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
      key = 0
      do j = 1, 9
        if (physics_fold_equal(text(first:last), trim(keys(j)))) then
          key = j
          exit
        end if
      end do
      if (key == 0) return
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
      if (key == 2 .or. key == 9) then
        call parse_signed_integer(text(first:cursor - 1), parsed, valid)
      else
        call parse_physics_boolean(text(first:cursor - 1), boolean, valid)
        parsed = 0
        if (boolean) parsed = 1
      end if
      if (.not. valid) return
      values(key) = parsed
    end do
    if (values(1) /= 1 .or. values(2) /= 3 .or. values(3) /= 1) return
    if (values(4) /= 0 .or. values(6) /= 0) return
    output(1:4) = geometry
    output(5) = values(2); output(6) = values(3)
    status = 0
  end function
  integer(c_int32_t) function initialize_operational_vertical_configuration(text, geometry, output) result(status)
    !! Apply the validated operational overrides after the complete default/reset
    !! constructor. The complete record retains its incoming undefined fields.
    character(len=*), intent(in) :: text
    integer(c_int32_t), intent(in) :: geometry(4)
    type(native_vertical_configuration), intent(inout) :: output
    integer(c_int32_t) :: controls(6)
    status = read_operational_vertical_controls(text, geometry, controls)
    if (status /= 0) return
    status = initialize_vertical_configuration(output, geometry(2), geometry(3), geometry(4))
    if (status /= 0) return
    output%nvsch = controls(5)
    output%lvfe_gwmpa = controls(6)
  end function
end module vertical_configuration_port
