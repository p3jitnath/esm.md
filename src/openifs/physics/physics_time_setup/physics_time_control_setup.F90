!> Initialize the selected physics time controls and cloud level indices.
!! This structured Fortran port owns the complete SUPHY2 calculation in
!! physics_time_controls.S. Native TPHY2 remains owned by its model caller.
!! The caller establishes nearest-even rounding and gradual underflow once.
!! This child preserves natural flags and makes no FP-mode refusal claim.
module physics_time_control_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use yomphy2, only: tphy2
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_physics_time_controls, initialize_runtime_physics_time_controls
contains
  !> Initialize the selected 19-layer SUPHY2 configuration.
  !! TEXT is readonly TARGET character data of 1:262144 bytes and contains
  !! the first uppercase empty NAMPHY2 group. OUTPUT is a caller-owned native
  !! TPHY2 INOUT TARGET record. All 23 named fields, currently 160 bytes,
  !! are written on success; no record is allocated or copied.
  !! HALF_ETA_A and HALF_ETA_B are readonly TARGET FP64 views declared
  !! with lower bound zero. Each has at least 20 contiguous dimensionless
  !! coefficients. Only indices 0:19 are read; larger capacity stays readonly.
  !! Each consumed value is finite and in [0,1]; either signed zero is valid.
  !! LECMWF is readonly TARGET logical and must have canonical true bits.
  !! OUTPUT is separate from all input spans. The two coefficient views
  !! can alias each other. No CONTIGUOUS attribute creates an implicit copy.
  !! The initial TSPHY is one second. The observing and cloud heights use
  !! metres. Cloud transition coefficients and the resulting indices are
  !! dimensionless. Other empirical parameters retain their source values.
  !! Return zero after success or two before mutation. Preserve readonly
  !! bytes, errno and incoming FP flags; arithmetic adds its natural flags.
  integer(int32) function initialize_physics_time_controls(text, output, half_eta_a, &
                                                           half_eta_b, lecmwf) result(status)
    character(len=*), intent(in), target :: text
    type(tphy2), intent(inout), target :: output
    real(real64), intent(in), target :: half_eta_a(0:), half_eta_b(0:)
    logical, intent(in), target :: lecmwf
    status = initialize_controls(text, output, half_eta_a, half_eta_b, lecmwf, 19_int32)
  end function

  !> Apply the same ordered SUPHY2 calculation to a live runtime grid.
  !! Arguments and mutation follow the default entry. Both coefficient
  !! views have the same size, LEVELS+1, where LEVELS is SIZE(A)-1 from
  !! 1:256. No padding or input copy is made. This distinct grid extension
  !! requires its own same-input byte proof before operational acceptance.
  integer(int32) function initialize_runtime_physics_time_controls(text, output, &
                                                                   half_eta_a, half_eta_b, lecmwf) result(status)
    character(len=*), intent(in), target :: text
    type(tphy2), intent(inout), target :: output
    real(real64), intent(in), target :: half_eta_a(0:), half_eta_b(0:)
    logical, intent(in), target :: lecmwf
    integer(int32) :: levels
    status = 2_int32
    if (size(half_eta_a, kind=int64) < 2_int64 .or. size(half_eta_a, kind=int64) > 257_int64) return
    if (size(half_eta_b, kind=int64) /= size(half_eta_a, kind=int64)) return
    levels = int(size(half_eta_a, kind=int64) - 1_int64, int32)
    status = initialize_controls(text, output, half_eta_a, half_eta_b, lecmwf, levels)
  end function

  integer(int32) function initialize_controls(text, output, half_eta_a, half_eta_b, &
                                              lecmwf, levels) result(status)
    character(len=*), intent(in), target :: text
    type(tphy2), intent(inout), target :: output
    real(real64), intent(in), target :: half_eta_a(0:), half_eta_b(0:)
    logical, intent(in), target :: lecmwf
    integer(int32), intent(in) :: levels
    integer(c_intptr_t) :: address, other_addresses(2)
    integer(int64) :: bytes, other_bytes(2)
    integer :: other, level
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144) return
    address = transfer(c_loc(output), 0_c_intptr_t)
    bytes = storage_size(output, kind=int64)/8_int64
    if (.not. disjoint(address, bytes, transfer(c_loc(text(1:1)), 0_c_intptr_t), &
                       int(len(text), int64))) return
    if (.not. disjoint(address, bytes, transfer(c_loc(lecmwf), 0_c_intptr_t), &
                       storage_size(lecmwf, kind=int64)/8_int64)) return
    if (transfer(lecmwf, 0_int32) /= 1_int32) return
    if (size(half_eta_a, kind=int64) < int(levels, int64) + 1_int64) return
    if (size(half_eta_b, kind=int64) < int(levels, int64) + 1_int64) return
    if (.not. is_contiguous(half_eta_a) .or. .not. is_contiguous(half_eta_b)) return
    other_addresses = [transfer(c_loc(half_eta_a(0)), 0_c_intptr_t), &
                       transfer(c_loc(half_eta_b(0)), 0_c_intptr_t)]
    other_bytes = [size(half_eta_a, kind=int64)*8_int64, size(half_eta_b, kind=int64)*8_int64]
    do other = 1, 2
      if (.not. disjoint(address, bytes, other_addresses(other), other_bytes(other))) return
    end do
    do level = 0, levels
      if (.not. unit_interval(half_eta_a(level))) return
      if (.not. unit_interval(half_eta_b(level))) return
    end do
    if (require_empty_physics_group(text, 'NAMPHY2') /= 0_int32) return
    call set_physics_time_controls_fields(output, half_eta_a, half_eta_b, levels)
    status = 0_int32
  end function

  !> Store source literals, then choose the last qualifying level.
  !! Caller validation is complete. Each layer centre uses three separate
  !! FP64 additions, in written order, then multiplication by one half.
  !! A threshold tie qualifies. No failure remains after the first store.
  subroutine set_physics_time_controls_fields(output, half_eta_a, half_eta_b, levels)
    type(tphy2), intent(inout) :: output
    real(real64), intent(in) :: half_eta_a(0:), half_eta_b(0:)
    integer(int32), intent(in) :: levels
    real(real64) :: centre
    integer(int32) :: level
    output%xmulaf = transfer(int(z'bffc000000000000', int64), 0.0_real64)
    output%xmucvpp = 0.0_real64
    output%xdamp = 0.0_real64
    output%hclp = transfer(int(z'4097700000000000', int64), 0.0_real64)
    output%htcls = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%hvcls = transfer(int(z'4024000000000000', int64), 0.0_real64)
    output%htshm = transfer(int(z'3fdccccccccccccd', int64), 0.0_real64)
    output%htsml = transfer(int(z'3fe91eb851eb851f', int64), 0.0_real64)
    output%tsphy = transfer(int(z'3ff0000000000000', int64), 0.0_real64)
    output%lraftur = .false.
    output%lraftke = .false.
    output%gz0raf = transfer(int(z'4024000000000000', int64), 0.0_real64)
    output%facraf = transfer(int(z'402e000000000000', int64), 0.0_real64)
    output%facrafcv = 0.0_real64
    output%facrafdcape = 0.0_real64
    output%gcaperaf = transfer(int(z'4059000000000000', int64), 0.0_real64)
    output%lmulaf = .false.
    output%lwmocloud = .false.
    output%hwmohigh = transfer(int(z'40b3880000000000', int64), 0.0_real64)
    output%hwmolow = transfer(int(z'40a3880000000000', int64), 0.0_real64)
    output%htkeraf = transfer(int(z'4034000000000000', int64), 0.0_real64)
    output%ntshm = 0_int32
    output%ntsml = 0_int32
    do level = 1, levels
      centre = half_eta_a(level) + half_eta_b(level)
      centre = centre + half_eta_a(level - 1)
      centre = centre + half_eta_b(level - 1)
      centre = centre*0.5_real64
      if (centre <= output%htshm) output%ntshm = level
      if (centre <= output%htsml) output%ntsml = level
    end do
  end subroutine

  pure logical function unit_interval(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word, magnitude
    word = transfer(value, 0_int64)
    magnitude = iand(word, int(z'7fffffffffffffff', int64))
    valid = .false.
    if (magnitude > int(z'3ff0000000000000', int64)) return
    if (word < 0_int64 .and. magnitude /= 0_int64) return
    valid = .true.
  end function

  logical function disjoint(first, first_bytes, second, second_bytes) result(separate)
    integer(c_intptr_t), intent(in) :: first, second
    integer(int64), intent(in) :: first_bytes, second_bytes
    if (first <= second) then
      separate = second - first >= first_bytes
    else
      separate = first - second >= second_bytes
    end if
  end function

end module physics_time_control_setup_port
