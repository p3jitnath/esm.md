!> Set the generated top-physics, gravity-wave and CAPE control stages.
!! The enclosing parent keeps the original stage order. This module imports
!! only native type declarations and the accepted empty-group parser.
module upper_atmosphere_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_double, c_loc, c_intptr_t
  use yomtoph, only: ttoph
  use yomnorgwd, only: tnorgwd
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  !> Own the five original CAPE namespace scalars in one portable C record.
  !! Counts and indices are int32. GCAPERET is the dimensionless retained
  !! condensate fraction; GCAPEPSD is a dimensionless pressure ratio.
  !! No default is imposed on source-unwritten incoming values.
  type, bind(c), public :: native_convective_energy_controls
    integer(c_int) :: ncapeiter, netapes, ncapepsd
    real(c_double) :: gcaperet, gcapepsd
  end type
  public :: admit_upper_atmosphere_setup, admit_selected_upper_atmosphere_setup
  public :: initialize_top_physics_parameters_raw
  public :: initialize_nonorographic_wave_parameters_raw
  public :: initialize_convective_energy_controls_raw
  public :: search_pressure_parameter_level
contains
  !> Admit the live-count draft without changing an output record.
  !! TEXT has 1:262144 characters and its first uppercase NAMTOPH,
  !! NAMNORGWD and NAMCAPE groups must be empty. TOP and WAVE are readonly
  !! native declaration records; CAPE is the readonly owned scalar record.
  !! STANDARD_PRESSURE is contiguous real64(1:n), in pascals, for 1:256
  !! layers. It is positive, nondecreasing and at most 200000 Pa.
  !! HALF_A and HALF_B are contiguous real64(0:n) dimensionless coefficients
  !! in [0,1], with either signed zero allowed. ITERATIONS is int32 in1:100.
  !! LRRMES must be false and LECMWF true; LAGPHY can be either native
  !! logical value. Output records are mutually disjoint and separate
  !! from all inputs. The compiler owns native alignment and bounds.
  !! The caller establishes nearest-even and gradual underflow once.
  !! Return 0 admits; return 2 refuses. No numerical stage or allocation runs.
  !! The 19-layer source cohort and larger live cohorts qualify separately.
  integer(int32) function admit_upper_atmosphere_setup(text, top, wave, cape, standard_pressure, &
                                                       half_a, half_b, iterations, lrrmes, lagphy, lecmwf) result(status)
    character(len=*), intent(in), target :: text
    type(ttoph), intent(in), target :: top
    type(tnorgwd), intent(in), target :: wave
    type(native_convective_energy_controls), intent(in), target :: cape
    real(real64), intent(in), target :: standard_pressure(:), half_a(0:), half_b(0:)
    integer(int32), intent(in), target :: iterations
    logical, intent(in), target :: lrrmes, lagphy, lecmwf
    integer(int32) :: levels, j, k
    integer(int64) :: word, previous, magnitude
    integer(c_intptr_t) :: addresses(11)
    integer(int64) :: lengths(11)
    status = 2_int32
    if (.not. is_contiguous(standard_pressure)) return
    if (.not. is_contiguous(half_a)) return
    if (.not. is_contiguous(half_b)) return
    if (len(text, kind=int64) < 1_int64 .or. len(text, kind=int64) > 262144_int64) return
    if (size(standard_pressure, kind=int64) < 1_int64 .or. size(standard_pressure, kind=int64) > 256_int64) return
    levels = size(standard_pressure, kind=int32)
    if (size(half_a, kind=int64) /= int(levels, int64) + 1_int64) return
    if (size(half_b, kind=int64) /= int(levels, int64) + 1_int64) return
    if (iterations < 1_int32 .or. iterations > 100_int32) return
    if (transfer(lrrmes, 0_int32) /= 0_int32) return
    if (transfer(lecmwf, 0_int32) /= 1_int32) return
    word = int(transfer(lagphy, 0_int32), int64)
    if (word /= 0_int64 .and. word /= 1_int64) return
    addresses = [transfer(c_loc(top), 0_c_intptr_t), transfer(c_loc(wave), 0_c_intptr_t), &
                 transfer(c_loc(cape), 0_c_intptr_t), transfer(c_loc(text), 0_c_intptr_t), &
                 transfer(c_loc(standard_pressure), 0_c_intptr_t), transfer(c_loc(half_a), 0_c_intptr_t), &
                 transfer(c_loc(half_b), 0_c_intptr_t), transfer(c_loc(iterations), 0_c_intptr_t), &
                 transfer(c_loc(lrrmes), 0_c_intptr_t), transfer(c_loc(lagphy), 0_c_intptr_t), &
                 transfer(c_loc(lecmwf), 0_c_intptr_t)]
    lengths = [storage_size(top, kind=int64)/8_int64, storage_size(wave, kind=int64)/8_int64, &
               storage_size(cape, kind=int64)/8_int64, len(text, kind=int64), &
               8_int64*int(levels, int64), 8_int64*(int(levels, int64) + 1_int64), &
               8_int64*(int(levels, int64) + 1_int64), 4_int64, 4_int64, 4_int64, 4_int64]
    do j = 1, 3
      do k = j + 1, 11
        if (.not. disjoint(addresses(j), lengths(j), addresses(k), lengths(k))) return
      end do
    end do
    previous = 0_int64
    do j = 1, levels
      word = transfer(standard_pressure(j), 0_int64)
      if (word <= 0_int64 .or. word > int(z'41086A0000000000', int64)) return
      if (word < previous) return
      previous = word
    end do
    do j = 0, levels
      word = transfer(half_a(j), 0_int64)
      magnitude = iand(word, int(z'7FFFFFFFFFFFFFFF', int64))
      if (magnitude > int(z'3FF0000000000000', int64)) return
      if (word < 0_int64 .and. magnitude /= 0_int64) return
      word = transfer(half_b(j), 0_int64)
      magnitude = iand(word, int(z'7FFFFFFFFFFFFFFF', int64))
      if (magnitude > int(z'3FF0000000000000', int64)) return
      if (word < 0_int64 .and. magnitude /= 0_int64) return
    end do
    if (require_empty_physics_group(text, 'NAMTOPH') /= 0_int32) return
    if (require_empty_physics_group(text, 'NAMNORGWD') /= 0_int32) return
    if (require_empty_physics_group(text, 'NAMCAPE') /= 0_int32) return
    status = 0_int32
  end function

  !> Apply the same readonly admission with the frozen 19-layer limit.
  !! Arguments, units and mutation rules match ADMIT_UPPER_ATMOSPHERE_SETUP.
  !! This keeps the selected source scope separate from the live draft.
  integer(int32) function admit_selected_upper_atmosphere_setup(text, top, wave, cape, standard_pressure, &
                                                                half_a, half_b, iterations, lrrmes, lagphy, lecmwf) result(status)
    character(len=*), intent(in), target :: text
    type(ttoph), intent(in), target :: top
    type(tnorgwd), intent(in), target :: wave
    type(native_convective_energy_controls), intent(in), target :: cape
    real(real64), intent(in), target :: standard_pressure(:), half_a(0:), half_b(0:)
    integer(int32), intent(in), target :: iterations
    logical, intent(in), target :: lrrmes, lagphy, lecmwf
    status = 2_int32
    if (.not. is_contiguous(standard_pressure)) return
    if (.not. is_contiguous(half_a)) return
    if (.not. is_contiguous(half_b)) return
    if (size(standard_pressure, kind=int64) /= 19_int64) return
    status = admit_upper_atmosphere_setup(text, top, wave, cape, standard_pressure, &
                                          half_a, half_b, iterations, lrrmes, lagphy, lecmwf)
  end function

  !> Find the lowest pressure index at or above TARGET, including exact ties.
  !! TARGET is real64 in pascals; STANDARD_PRESSURE is admitted contiguous
  !! real64(1:n). INDEX is int32 OUT and remains n if no layer qualifies.
  !! The caller admits 1:256 layers. This is the complete SEAPRE scan.
  pure subroutine search_pressure_parameter_level(target, index, standard_pressure)
    real(real64), intent(in) :: target
    integer(int32), intent(out) :: index
    real(real64), intent(in), contiguous :: standard_pressure(:)
    integer(int32) :: j, levels
    levels = size(standard_pressure, kind=int32)
    index = levels
    do j = levels, 1, -1
      if (target <= standard_pressure(j)) index = j
    end do
  end subroutine

  !> Set the source top-physics scalars without touching its profile owners.
  !! OUTPUT is native TTOPH INOUT. STANDARD_PRESSURE is admitted real64(1:n)
  !! in pascals. All three profile owners keep allocation, bounds and data.
  !! Coefficients retain their original units and literal rounding.
  !! The enclosing caller admits the complete selected inputs before entry.
  subroutine initialize_top_physics_parameters_raw(output, standard_pressure)
    type(ttoph), intent(inout) :: output
    real(real64), intent(in), contiguous :: standard_pressure(:)
    integer(int32) :: levels
    levels = size(standard_pressure, kind=int32)
    output%etqsat = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etdifu = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etcoef = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etdrag = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etcvim = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etplui = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%et850 = transfer(int(z'40F4C08000000000', int64), 0.0_real64)
    output%et950 = transfer(int(z'40F7318000000000', int64), 0.0_real64)
    output%etradi = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etnebu = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etozon = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etdrme = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etcoet = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etajuc = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etrelaxt = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etrelaxq = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%etrelaxu = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%ntqsat = 1_int32
    output%ntdifu = 1_int32
    output%ntcoef = 1_int32
    output%ntdrag = 1_int32
    output%ntcvim = 1_int32
    output%ntplui = 1_int32
    output%ntradi = 1_int32
    output%ntnebu = 1_int32
    output%ntozon = 1_int32
    output%ntdrme = 1_int32
    output%ntcoet = 1_int32
    output%ntajuc = 1_int32
    output%ntrelaxt = levels
    output%ntrelaxq = levels
    output%ntrelaxu = levels
    output%xdrmuk = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmux = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmup = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmtk = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmtx = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmtp = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmqk = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmqp = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%xdrmqx = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rfmesoq = transfer(int(z'3ECF3F60681FA40A', int64), 0.0_real64)
    output%rclx = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%tpsclim = transfer(int(z'4068A00000000000', int64), 0.0_real64)
    call search_pressure_parameter_level(output%et850, output%nt850, standard_pressure)
    call search_pressure_parameter_level(output%et950, output%nt950, standard_pressure)
  end subroutine

  !> Set gravity-wave constants and source pressure-index conventions.
  !! OUTPUT is native TNORGWD INOUT; STANDARD_PRESSURE is admitted real64
  !! in pascals. Constants keep their binary64 words, including literals
  !! first rounded at default precision. Rain rate uses kg m^-2 s^-1,
  !! time uses seconds, and characteristic source depths use metres.
  subroutine initialize_nonorographic_wave_parameters_raw(output, standard_pressure)
    type(tnorgwd), intent(inout) :: output
    real(real64), intent(in), contiguous :: standard_pressure(:)
    integer(int32) :: levels, j, index
    levels = size(standard_pressure, kind=int32)
    output%norgwd_scheme = 'RAND'
    output%norgwd_dzfron = transfer(int(z'408F400000000000', int64), 0.0_real64)
    output%norgwd_gfron = transfer(int(z'3FE3333340000000', int64), 0.0_real64)
    output%norgwd_gb = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%norgwd_prmax = transfer(int(z'3F2E573AC0000000', int64), 0.0_real64)
    output%norgwd_dz = transfer(int(z'408F400000000000', int64), 0.0_real64)
    output%norgwd_ptropo = transfer(int(z'40D3880000000000', int64), 0.0_real64)
    output%norgwd_ruwmax = transfer(int(z'3F947AE147AE147B', int64), 0.0_real64)
    output%norgwd_sat = transfer(int(z'3FEB333333333333', int64), 0.0_real64)
    output%norgwd_rdiss = transfer(int(z'4044000000000000', int64), 0.0_real64)
    output%norgwd_deltat = transfer(int(z'40F5180000000000', int64), 0.0_real64)
    output%norgwd_kmin = transfer(int(z'3F0A36E2E0000000', int64), 0.0_real64)
    output%norgwd_kmax = transfer(int(z'3F33A92A40000000', int64), 0.0_real64)
    output%norgwd_cmin = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%norgwd_cmax = transfer(int(z'403E000000000000', int64), 0.0_real64)
    output%norgwd_plaunch = transfer(int(z'40F3880000000000', int64), 0.0_real64)
    output%norgwd_pnoverdif = transfer(int(z'40C3880000000000', int64), 0.0_real64)
    index = levels
    do j = levels, 1, -1
      if (standard_pressure(j) > output%norgwd_plaunch) index = j
    end do
    output%norgwd_nlaunch = levels - index
    index = levels
    do j = levels, 1, -1
      if (standard_pressure(j) > output%norgwd_ptropo) index = j
    end do
    output%norgwd_ntropo = levels - index
    index = levels
    do j = levels, 1, -1
      if (standard_pressure(j) > output%norgwd_pnoverdif) index = j
    end do
    output%norgwd_nnoverdif = index
  end subroutine

  !> Set CAPE controls using each ordered half-level pressure sum.
  !! OUTPUT is the owned native CAPE scalar record INOUT. HALF_A and HALF_B
  !! are admitted contiguous dimensionless real64(0:n); ITERATIONS is
  !! readonly int32 in1:100. The parent can insert its required stage
  !! between gravity-wave setup and this call. Each addition retains its
  !! real64 rounding point. NCAPEPSD is retained if no layer qualifies.
  subroutine initialize_convective_energy_controls_raw(output, half_a, half_b, iterations)
    type(native_convective_energy_controls), intent(inout) :: output
    real(real64), intent(in), contiguous :: half_a(0:), half_b(0:)
    integer(int32), intent(in) :: iterations
    integer(int32) :: levels, j
    real(real64) :: midpoint
    levels = size(half_a, kind=int32) - 1_int32
    output%ncapeiter = iterations
    output%netapes = 1_int32
    output%gcaperet = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%gcapepsd = transfer(int(z'3FE6666666666666', int64), 0.0_real64)
    do j = 1, levels
      midpoint = half_a(j) + half_b(j)
      midpoint = midpoint + half_a(j - 1)
      midpoint = midpoint + half_b(j - 1)
      midpoint = midpoint*0.5_real64
      if (midpoint <= output%gcapepsd) output%ncapepsd = j
    end do
  end subroutine

  logical function disjoint(left, left_bytes, right, right_bytes) result(valid)
    integer(c_intptr_t), intent(in) :: left, right
    integer(int64), intent(in) :: left_bytes, right_bytes
    valid = .false.
    if (left < 0_c_intptr_t .or. right < 0_c_intptr_t .or. left_bytes < 0_int64 .or. right_bytes < 0_int64) return
    if (left > huge(left) - left_bytes .or. right > huge(right) - right_bytes) return
    valid = left + left_bytes <= right .or. right + right_bytes <= left
  end function
end module upper_atmosphere_setup_port
