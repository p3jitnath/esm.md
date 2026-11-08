!> Read live trajectory controls into the existing canonical dynamics owner.
module forecast_operational_lagrangian_controls
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_dynamics_control_defaults, only: native_dynamics_controls
  use forecast_reference_pressure_coefficients, only: reference_atmosphere_values, initialize_reference_atmosphere_values
 use physics_configuration_text_port,only:find_physics_group,skip_physics_space,physics_space,physics_key_character,physics_fold_equal
  implicit none
  private
  public :: native_lagrangian_controls, initialize_operational_lagrangian_controls, initialize_operational_rayleigh_controls
  !> Additional source-named trajectory fields, separate from TDYNA controls.
  type :: native_lagrangian_controls
    logical :: l2tlff, ladvf, limpf, lrhs_curv, lsetfstat, lsettlsvf, lsettlsvf_diff
    logical :: lsldp_curv, lsldp_rk, lsldp_save, lsldp_xyz, lsvtsm, lmascor
    integer(c_int) :: ncurrent_iter, nspdlag, nsplthoi, nsvdlag, ntlag, nvlag, nwlag, nflevsf, nitmp
    real(c_double) :: betadt, rcmslp0, rintopt, rrintopt, rscale, rscaleoff, rpres_settlsvf, vesl, rw2tlff, xidt
  end type
contains
  !> Initialise source-selected global, hydrostatic trajectory controls.
 !! DYNAMICS is the existing read-only TDYNA; STATE owns only these new fields.
 !! HALF_PRESSURE(0:LEVELS) is the produced standard-atmosphere pressure in Pa.
 !! HALF_A_FIRST is the produced A(1) in Pa; STRETCH is dimensionless and RD
 !! has units J/(kg K). REFERENCE is the existing named atmosphere scalar owner.
 !! The five platform values are NCONF,LECMWF,LR2D,LR3D,LELAM, in that order.
 !! The first uppercase NAMDYN is admitted before any output is changed.
  integer(c_int) function initialize_operational_lagrangian_controls(text, platform, nstop, levels, half_pressure, half_a_first, &
                                               finite_elements, stretch, rd, dynamics, lsplthoigfl, state, reference) result(status)
    character(*), intent(in) :: text
    integer(c_int), intent(in) :: platform(5), nstop, levels, finite_elements, lsplthoigfl
    real(c_double), intent(in), contiguous :: half_pressure(0:)
    real(c_double), intent(in) :: half_a_first, stretch, rd
    type(native_dynamics_controls), intent(in) :: dynamics
    type(native_lagrangian_controls), intent(inout) :: state
    type(reference_atmosphere_values), intent(inout) :: reference
    logical :: lmascor, lrfric, lrfricisotr
    integer(c_int) :: nitmp, nflevsf, j, child
    integer(c_int64_t) :: bits
    status = 2
    if (any(platform /= [1_c_int, 1_c_int, 0_c_int, 1_c_int, 0_c_int])) return
    if (nstop < 1 .or. levels < 1 .or. levels > 255) return
    if (transfer(dynamics%lnhdyn, 0_c_int) /= 0 .or. transfer(dynamics%ltwotl, 0_c_int) /= 1 .or. &
        transfer(dynamics%lslag, 0_c_int) /= 1 .or. lsplthoigfl /= 0) return
    if (transfer(dynamics%lsettlst, 0_c_int) < 0 .or. transfer(dynamics%lsettlst, 0_c_int) > 1) return
    if (transfer(dynamics%lsettlsv, 0_c_int) < 0 .or. transfer(dynamics%lsettlsv, 0_c_int) > 1) return
    if (size(half_pressure, kind=c_int64_t) /= int(levels, c_int64_t) + 1) return
    do j = 0, levels
      bits = transfer(half_pressure(j), bits)
      if (btest(bits, 63) .or. ibits(bits, 52, 11) == 2047) return
    end do
    lmascor = .false.; lrfric = .false.; lrfricisotr = .false.; nitmp = 2
    if (dynamics%lsettlst .or. dynamics%lsettlsv) nitmp = 3
    child = parse_lagrangian_group(text, .false., lmascor, nitmp, lrfric, lrfricisotr)
    if (child /= 0) return
    nflevsf = 0
    do j = 1, levels
      if (half_pressure(j) <= 6000.0_c_double) nflevsf = nflevsf + 1
    end do
    nflevsf = min(nflevsf, levels)
    child = initialize_reference_atmosphere_values(half_a_first, finite_elements, stretch, rd, reference)
    if (child /= 0) return
    state%l2tlff = .false.
    state%ladvf = .false.
    state%limpf = .true.
    state%lrhs_curv = .false.
    state%lsetfstat = .false.
    state%lsettlsvf = .true.
    state%lsettlsvf_diff = .false.
    state%lsldp_curv = .true.
    state%lsldp_rk = .false.
    state%lsldp_save = .true.
    state%lsldp_xyz = .true.
    state%lsvtsm = .false.
    state%ncurrent_iter = 0
    state%nspdlag = 3
    state%nsplthoi = 0
    state%nsvdlag = 3
    state%ntlag = 3
    state%nvlag = 3
    state%nwlag = 3
    state%betadt = 1.0_c_double
    state%rcmslp0 = 1.0_c_double
    state%rintopt = 1.0_c_double
    state%rrintopt = 1.0_c_double
    state%rscale = transfer(int(z'42d6bcc41e900000', c_int64_t), 0.0_c_double)
    state%rscaleoff = transfer(int(z'3d06849b86a12b9b', c_int64_t), 0.0_c_double)
    state%rpres_settlsvf = 6000.0_c_double
    state%vesl = 0.0_c_double
    state%rw2tlff = 0.0_c_double
    state%nflevsf = nflevsf
    state%lmascor = lmascor
    state%nitmp = nitmp
    state%xidt = 0.05_c_double
    if (reference%temperature == 350.0_c_double) state%xidt = 0.0_c_double
    status = 0
  end function
  !> Admit the actual137-level inactive Rayleigh branch, without other stores.
  integer(c_int) function initialize_operational_rayleigh_controls(text, levels, lecmwf, lrfric, lrfricisotr) result(status)
    character(*), intent(in) :: text
    integer(c_int), intent(in) :: levels, lecmwf
    logical, intent(inout) :: lrfric, lrfricisotr
    logical :: mass, fric, isotr
    integer(c_int) :: nitmp
    status = 2
    if (levels /= 137 .or. lecmwf /= 1) return
    mass = .false.; fric = .false.; isotr = .false.; nitmp = 3
    if (parse_lagrangian_group(text, .true., mass, nitmp, fric, isotr) /= 0) return
    if (fric .or. isotr) return
    lrfric = .false.; lrfricisotr = .false.
    status = 0
  end function
  !> Retain source case, token, duplicate-key and first-group policies.
  integer(c_int) function parse_lagrangian_group(text, rayleigh, lmascor, nitmp, lrfric, lrfricisotr) result(status)
    character(*), intent(in) :: text
    logical, intent(in) :: rayleigh
    logical, intent(inout) :: lmascor, lrfric, lrfricisotr
    integer(c_int), intent(inout) :: nitmp
    integer :: p, k, v, q, n, first, last, code, digit
    integer(c_int) :: ival
    logical :: value, negative
    status = 2
    n = len(text)
    if (n < 1 .or. n > 262144) return
    p = find_physics_group(text, 'NAMDYN', .false.)
    if (p == 0) return
    do
      call skip_physics_space(text, p)
      if (p > n) return
      if (text(p:p) == ',') then
        p = p + 1; cycle
      end if
      if (text(p:p) == '/') then
        status = 0; return
      end if
      k = p
      do while (p <= n)
        if (.not. physics_key_character(text(p:p), .true.) .and. text(p:p) /= '(' .and. text(p:p) /= ')') exit
        p = p + 1
      end do
      q = p - 1
      if (q < k) return
      call skip_physics_space(text, p)
      if (p > n) return
      if (text(p:p) /= '=') return
      p = p + 1
      call skip_physics_space(text, p)
      if (p > n) return
      v = p
      do while (p <= n)
        if (physics_space(text(p:p)) .or. index(',!/', text(p:p)) > 0) exit
        p = p + 1
      end do
      if (p > n .or. p == v) return
      if (physics_fold_equal(text(k:q), 'NITMP')) then
        first = v; last = p - 1; negative = .false.
        if (text(first:first) == '-' .or. text(first:first) == '+') then
          negative = text(first:first) == '-'; first = first + 1
        end if
        if (first > last) return
        ival = 0
        do code = first, last
          digit = iachar(text(code:code)) - 48
          if (digit < 0 .or. digit > 9) return
          if (ival > 9999999) return
          ival = ival*10 + digit
          if (ival > 99999999) return
        end do
        if (negative) ival = -ival
        if (ival < 0 .or. ival > 20) return
        nitmp = ival
      else
        first = v; last = p - 1
        if (text(first:first) == '.') then
          if (last - first < 2) return
          if (text(last:last) /= '.') return
          first = first + 1; last = last - 1
        end if
        if (physics_fold_equal(text(first:last), 'TRUE')) then
          value = .true.
        else if (physics_fold_equal(text(first:last), 'FALSE')) then
          value = .false.
        else
          return
        end if
        if (physics_fold_equal(text(k:q), 'LMASCOR')) then
          lmascor = value
        else if (rayleigh .and. physics_fold_equal(text(k:q), 'LRFRIC')) then
          lrfric = value
        else if (rayleigh .and. physics_fold_equal(text(k:q), 'LRFRICISOTR')) then
          lrfricisotr = value
        else
          return
        end if
      end if
    end do
  end function
end module forecast_operational_lagrangian_controls
