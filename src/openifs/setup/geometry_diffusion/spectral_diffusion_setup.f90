!> Own source-named spectral diffusion controls and five native array owners.
module forecast_spectral_diffusion_setup
  use iso_c_binding, only: c_int, c_int64_t, c_double, c_float
  use forecast_dynamics_control_defaults, only: native_dynamics_controls
  implicit none
  private
  public :: native_spectral_diffusion_state, initialize_spectral_diffusion_controls
  public :: allocate_spectral_diffusion_storage, calculate_spectral_diffusion_coefficients, release_spectral_diffusion_storage
  type :: native_spectral_diffusion_state
    real(c_double) :: hdirvor
    real(c_double) :: hdirdiv
    real(c_double) :: hdirt
    real(c_double) :: hdirq
    real(c_double) :: hdiro3
    real(c_double) :: hdirpd
    real(c_double) :: hdirvd
    real(c_double) :: hdirsp
    real(c_double) :: hrdirvor
    real(c_double) :: hrdirdiv
    real(c_double) :: hrdirt
    real(c_double) :: hrdirq
    real(c_double) :: hrdiro3
    real(c_double) :: hrdirpd
    real(c_double) :: hrdirvd
    real(c_double) :: hrdirsp
    real(c_double) :: rrdxtau
    real(c_double) :: rdampvor
    real(c_double) :: rdampdiv
    real(c_double) :: rdampt
    real(c_double) :: rdampq
    real(c_double) :: rdampo3
    real(c_double) :: rdamppd
    real(c_double) :: rdampvd
    real(c_double) :: rdampsp
    logical :: lnewhd
    real(c_double) :: rexpdh
    real(c_double) :: frandh
    real(c_double) :: slevdh
    real(c_double) :: slevdh1
    real(c_double) :: slevdh2
    real(c_double) :: slevdh3
    integer(c_int) :: nsrefdh
    real(c_double) :: ratio_hdi_top
    integer(c_int) :: nprofilehd
    real(c_double) :: rprofhdbt
    real(c_double) :: rprofhdtp
    real(c_double) :: rprofhdmx
    real(c_double) :: rprofhdex
    logical :: lrdispe_ec
    real(c_double) :: klsponge
    logical :: lm0damp
    real(c_double) :: rbegsponge
    logical :: ltop_vor
    integer(c_int) :: ntop_vor_trunc
    integer(c_int) :: ntop_vor_bot
    real(c_double) :: slhda0
    real(c_double) :: slhda0t
    real(c_double) :: slhdb
    real(c_double) :: slhdbt
    real(c_double) :: slhdd00
    real(c_double) :: slhdd00t
    real(c_double) :: slhddiv
    real(c_double) :: slhdratddiv
    real(c_double) :: slhdhor
    real(c_double) :: slhd_p_low
    real(c_double) :: slhd_p_high
    logical :: lslhdheat
    logical :: lslhdsponge
    real(c_double) :: hdsrvor
    real(c_double) :: hdsrdiv
    real(c_double) :: hdsrvd
    real(c_double) :: hrdsrvor
    real(c_double) :: hrdsrdiv
    real(c_double) :: hrdsrvd
    real(c_double) :: rdampvors
    real(c_double) :: rdampdivs
    real(c_double) :: rdampvds
    real(c_double) :: rdamphds
    real(c_double) :: rexpdhs
    real(c_double) :: slevdhs
    real(c_double) :: slevdhs1
    real(c_double) :: slevdhs2
    real(c_double) :: sdred
    logical :: lhdiffm
    logical :: lspecvis
    integer(c_int) :: ndiffact
    logical :: lgpstress
    real(c_double) :: rclstress
    real(c_double) :: rclpole
    real(c_double), allocatable :: rdivor(:, :), rdidiv(:, :), rditg(:, :), rdigfl(:, :, :), rdisp(:)
  end type
  interface
    function public_pow(x, y) bind(C, name='pow') result(value)
      import c_double
      real(c_double), value :: x, y
      real(c_double) :: value
    end function
    function public_exp(x) bind(C, name='exp') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_log10(x) bind(C, name='log10') result(value)
      import c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Initialise controls from live counts and the existing dynamics owner.
 !! Counts and MY_LEVELS are dimensionless. HALF_A(0:) is pressure in Pa.
 !! RHOUR is seconds/hour, P0 is Pa and RPLRADI is dimensionless.
 !! TRACER_SWITCHES are humidity/ozone nonlinear diffusion, then their
 !! spectral flags; all four are inactive in this source branch.
 !! RUNTIME selects the separately bounded original runtime control entry.
 !! Only named scalar fields change; existing arrays retain their owners.
  integer(c_int) function initialize_spectral_diffusion_controls(state, dynamics, global_levels, local_levels, truncation, &
          global_rows, longitudes, my_levels, half_a, rhour, p0, rplradi, spectral_tracers, tracer_switches, runtime) result(status)
    type(native_spectral_diffusion_state), intent(inout) :: state
    type(native_dynamics_controls), intent(in) :: dynamics
    integer(c_int), intent(in) :: global_levels, local_levels, truncation, global_rows, longitudes, spectral_tracers
    integer(c_int), intent(in), contiguous :: my_levels(:)
    real(c_double), intent(in), contiguous :: half_a(0:)
    real(c_double), intent(in) :: rhour, p0, rplradi
    logical, intent(in) :: tracer_switches(4)
    logical, intent(in), optional :: runtime
    logical :: live
    real(c_double) :: tau, vor, div
    real(c_double), volatile :: one
    status = 2; live = .false.
    if (present(runtime)) live = runtime
    if (.not. valid_switches(dynamics, spectral_tracers, tracer_switches)) return
    if (.not. positive(rhour) .or. .not. positive(p0) .or. .not. positive(rplradi)) return
    if (live) then
      if (global_levels < 1 .or. global_levels > 256 .or. truncation < 21 .or. truncation > 4096) return
      if (global_rows <= truncation + 1 .or. global_rows > 8192 .or. longitudes < 1) return
    else
    if (.not. valid_dimensions(.false., global_levels, local_levels, truncation, global_rows, longitudes, my_levels, half_a)) return
    end if
    state%lnewhd = .false.
    state%rexpdh = transfer(int(z'4010000000000000', c_int64_t), 0.0_c_double)
    state%frandh = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%rrdxtau = transfer(int(z'404ca8f5c28f5c29', c_int64_t), 0.0_c_double)
    state%rdampdiv = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rdampvor = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rdampt = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rdampq = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rdampsp = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%rdampo3 = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%rdampvd = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rdamppd = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%nprofilehd = 1_c_int
    state%lrdispe_ec = .true.
    state%hdirvor = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdirdiv = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdirt = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdirq = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdiro3 = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdirsp = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdirpd = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%hdirvd = transfer(int(z'c0c3878000000000', c_int64_t), 0.0_c_double)
    state%slevdh = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%slevdh1 = transfer(int(z'3fa999999999999a', c_int64_t), 0.0_c_double)
    state%slevdh2 = transfer(int(z'3f747ae147ae147b', c_int64_t), 0.0_c_double)
    state%ratio_hdi_top = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rprofhdbt = transfer(int(z'40c3880000000000', c_int64_t), 0.0_c_double)
    state%rprofhdtp = transfer(int(z'4059000000000000', c_int64_t), 0.0_c_double)
    state%rprofhdmx = transfer(int(z'40c3880000000000', c_int64_t), 0.0_c_double)
    state%rprofhdex = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rdampdivs = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%rdampvors = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%rdampvds = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%rdamphds = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%slhda0 = transfer(int(z'3fd0000000000000', c_int64_t), 0.0_c_double)
    state%slhda0t = transfer(int(z'3fa47ae147ae147b', c_int64_t), 0.0_c_double)
    state%slhdb = transfer(int(z'4010000000000000', c_int64_t), 0.0_c_double)
    state%slhdbt = transfer(int(z'4010000000000000', c_int64_t), 0.0_c_double)
    state%slhdd00 = transfer(int(z'3f110a137f38c543', c_int64_t), 0.0_c_double)
    state%slhdd00t = transfer(int(z'3f153bd1676640a7', c_int64_t), 0.0_c_double)
    state%slhddiv = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%slhdratddiv = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%slhdhor = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%slhd_p_low = transfer(int(z'409f400000000000', c_int64_t), 0.0_c_double)
    state%slhd_p_high = transfer(int(z'408f400000000000', c_int64_t), 0.0_c_double)
    state%rexpdhs = transfer(int(z'4018000000000000', c_int64_t), 0.0_c_double)
    state%slevdhs = transfer(int(z'3fd0000000000000', c_int64_t), 0.0_c_double)
    state%slevdhs1 = transfer(int(z'3fa999999999999a', c_int64_t), 0.0_c_double)
    state%slevdhs2 = transfer(int(z'3f747ae147ae147b', c_int64_t), 0.0_c_double)
    state%sdred = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%lslhdheat = .true.
    state%lslhdsponge = .true.
    state%hdsrvor = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%hdsrdiv = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%hdsrvd = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%hrdsrvor = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%hrdsrdiv = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%hrdsrvd = transfer(int(z'0000000000000000', c_int64_t), 0.0_c_double)
    state%lhdiffm = .false.
    state%lspecvis = .true.
    state%ndiffact = 6_c_int
    state%lgpstress = .false.
    state%rclstress = transfer(int(z'3ff0000000000000', c_int64_t), 0.0_c_double)
    state%rclpole = transfer(int(z'3fefae147ae147ae', c_int64_t), 0.0_c_double)
    state%ntop_vor_trunc = 255_c_int
    state%ntop_vor_bot = 3_c_int
    state%lm0damp = .false.
    state%rbegsponge = transfer(int(z'4022000000000000', c_int64_t), 0.0_c_double)
    state%ltop_vor = .false.
    state%klsponge = transfer(int(z'4030000000000000', c_int64_t), 0.0_c_double)
    if (live .and. global_levels >= 60) then
      if (global_levels < 91) then
        state%klsponge = 8.0_c_double
      else if (global_levels < 137) then
        state%klsponge = 10.0_c_double
      else
        state%klsponge = 14.0_c_double
        state%ltop_vor = .true.
      end if
    end if
    state%nsrefdh = truncation
    state%slevdh3 = 100.0_c_double/p0
    if (live .and. truncation >= 319) then
      if (truncation >= 3999) then
        tau = 240.0_c_double
      else if (truncation >= 2047) then
        tau = 450.0_c_double
      else if (truncation >= 1279) then
        tau = 600.0_c_double
      else if (truncation >= 799) then
        tau = 1200.0_c_double
      else if (truncation >= 511) then
        tau = 1800.0_c_double
      else
        tau = 2100.0_c_double
      end if
    else if (truncation >= 255) then
      tau = 2500.0_c_double
    else if (truncation >= 213) then
      tau = 2700.0_c_double
    else if (truncation >= 159) then
      tau = 5400.0_c_double
    else if (truncation >= 106) then
      tau = 12570.0_c_double
    else if (truncation >= 95) then
      tau = 15000.0_c_double
    else if (truncation >= 63) then
      tau = 27000.0_c_double
    else if (truncation >= 42) then
      tau = 54000.0_c_double
    else
      tau = 108000.0_c_double
    end if
    one = 1.0_c_double
    div = tau/one
    vor = real(nint(tau, kind=c_int64_t), c_double)
    div = real(nint(div, kind=c_int64_t), c_double)
    div = div*rplradi
    vor = vor*rplradi
    state%hdirdiv = div
    state%hdirvor = vor
    state%hdirt = vor
    state%hdirq = vor
    state%hdirsp = 0.0_c_double
    state%hdiro3 = 0.0_c_double
    state%hdirpd = 0.0_c_double
    state%hdirvd = 0.0_c_double
    state%slevdh1 = 1.0_c_double
    state%slevdh2 = 1.0_c_double
    state%slevdhs1 = 0.25_c_double
    state%slevdhs2 = 0.25_c_double
    if (state%hdirvor == 0.0_c_double) then
      state%hrdirvor = 0.0_c_double
    else
      state%hrdirvor = 1.0_c_double/state%hdirvor
    end if
    if (state%hdirdiv == 0.0_c_double) then
      state%hrdirdiv = 0.0_c_double
    else
      state%hrdirdiv = 1.0_c_double/state%hdirdiv
    end if
    if (state%hdirt == 0.0_c_double) then
      state%hrdirt = 0.0_c_double
    else
      state%hrdirt = 1.0_c_double/state%hdirt
    end if
    if (state%hdirq == 0.0_c_double) then
      state%hrdirq = 0.0_c_double
    else
      state%hrdirq = 1.0_c_double/state%hdirq
    end if
    if (state%hdiro3 == 0.0_c_double) then
      state%hrdiro3 = 0.0_c_double
    else
      state%hrdiro3 = 1.0_c_double/state%hdiro3
    end if
    if (state%hdirsp == 0.0_c_double) then
      state%hrdirsp = 0.0_c_double
    else
      state%hrdirsp = 1.0_c_double/state%hdirsp
    end if
    if (state%hdirvd == 0.0_c_double) then
      state%hrdirvd = 0.0_c_double
    else
      state%hrdirvd = 1.0_c_double/state%hdirvd
    end if
    if (state%hdirpd == 0.0_c_double) then
      state%hrdirpd = 0.0_c_double
    else
      state%hrdirpd = 1.0_c_double/state%hdirpd
    end if
    status = 0
  end function
  !> Allocate the five source owners in order; publish only complete success.
 !! RDIVOR/RDIDIV(local levels,0:truncation), RDITG(global levels,0:truncation),
 !! RDIGFL(local levels,0:truncation,1:0), RDISP(0:truncation) use FP64.
 !! Payloads are uninitialised. RUNTIME keeps the live local-level route.
  integer(c_int) function allocate_spectral_diffusion_storage(state, dynamics, global_levels, local_levels, truncation, &
                      global_rows, longitudes, my_levels, half_a, spectral_tracers, tracer_switches, runtime, half_b) result(status)
    type(native_spectral_diffusion_state), intent(inout) :: state
    type(native_dynamics_controls), intent(in) :: dynamics
    integer(c_int), intent(in) :: global_levels, local_levels, truncation, global_rows, longitudes, spectral_tracers
    integer(c_int), intent(in), contiguous :: my_levels(:)
    real(c_double), intent(in), contiguous :: half_a(0:)
    real(c_double), intent(in), contiguous, optional :: half_b(0:)
    logical, intent(in) :: tracer_switches(4)
    logical, intent(in), optional :: runtime
    type(native_spectral_diffusion_state) :: pending
    integer :: allocation_status, ignored
    logical :: live
    status = 2; live = .false.
    if (present(runtime)) live = runtime
    if (.not. valid_switches(dynamics, spectral_tracers, tracer_switches)) return
    if (.not. valid_dimensions(live, global_levels, local_levels, truncation, global_rows, longitudes, my_levels, half_a)) return
    if (live) then
      if (.not. present(half_b)) return
      if (size(half_b, kind=c_int64_t) /= int(global_levels, c_int64_t) + 1) return
      if (transfer(state%lhdiffm, 0_c_int) /= 0 .or. transfer(state%lspecvis, 0_c_int) /= 1) return
    end if
    if (allocated(state%rdivor) .or. allocated(state%rdidiv) .or. allocated(state%rditg) .or. &
        allocated(state%rdigfl) .or. allocated(state%rdisp)) return
    allocate (pending%rdivor(local_levels, 0:truncation), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%rdidiv(local_levels, 0:truncation), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%rditg(global_levels, 0:truncation), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%rdigfl(local_levels, 0:truncation, 1:0), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    allocate (pending%rdisp(0:truncation), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    call move_alloc(pending%rdivor, state%rdivor)
    call move_alloc(pending%rdidiv, state%rdidiv)
    call move_alloc(pending%rditg, state%rditg)
    call move_alloc(pending%rdigfl, state%rdigfl)
    call move_alloc(pending%rdisp, state%rdisp)
    status = 0
    return
900 ignored = release_spectral_diffusion_storage(pending)
  end function
  !> Generate source-ordered sponge and viscosity rates, in inverse seconds.
 !! MY_LEVELS maps local wind levels to global profile entries; temperature
 !! has all global levels. DT is the actual positive time step in seconds.
 !! Runtime pressure profiles consume both produced A/B(0:global_levels).
 !! Public C POW, EXP and LOG10 provide the mathematical services.
  integer(c_int) function calculate_spectral_diffusion_coefficients(state, dynamics, global_levels, local_levels, truncation, &
          global_rows,longitudes,my_levels,half_a,rhour,p0,rplradi,dt,spectral_tracers,tracer_switches,runtime,half_b)result(status)
    type(native_spectral_diffusion_state), intent(inout) :: state
    type(native_dynamics_controls), intent(in) :: dynamics
    integer(c_int), intent(in) :: global_levels, local_levels, truncation, global_rows, longitudes, spectral_tracers
    integer(c_int), intent(in), contiguous :: my_levels(:)
    real(c_double), intent(in), contiguous :: half_a(0:)
    real(c_double), intent(in), contiguous, optional :: half_b(0:)
    real(c_double), intent(in) :: rhour, p0, rplradi, dt
    logical, intent(in) :: tracer_switches(4)
    logical, intent(in), optional :: runtime
    real(c_double), allocatable :: profile(:)
    logical :: live, pressure_profile
    integer :: allocation_status, j, k, n, power, threshold
    real(c_double)::base,product,sponge,previous_half,current_half,pressure,amp,vor,div,term,x,y,viscosity,inverse_factor,e
    real(c_double), volatile :: discard
    status = 2; live = .false.; pressure_profile = .false.
    if (present(runtime)) live = runtime
    if (.not. valid_switches(dynamics, spectral_tracers, tracer_switches)) return
    if (.not. valid_dimensions(live, global_levels, local_levels, truncation, global_rows, longitudes, my_levels, half_a)) return
    if (.not. positive(rhour) .or. .not. positive(p0) .or. .not. positive(rplradi) .or. .not. positive(dt)) return
    if (.not. valid_storage(state, global_levels, local_levels, truncation)) return
    if (state%rexpdh /= 4.0_c_double) return
  if (.not. (state%hdirvor > 1.0_c_double) .or. .not. (state%hdirdiv > 1.0_c_double) .or. .not. (state%hdirt > 1.0_c_double)) return
    if (live) then
      if (.not. present(half_b)) return
      if (size(half_b, kind=c_int64_t) /= int(global_levels, c_int64_t) + 1) return
      if (transfer(state%lhdiffm, 0_c_int) /= 0 .or. transfer(state%lspecvis, 0_c_int) /= 1) return
      if (.not. finite(half_a(1)) .or. .not. finite(state%rbegsponge)) return
      if(.not.finite(state%hdirvor).or..not.finite(state%hdirdiv).or..not.finite(state%hdirt).or..not.finite(state%klsponge))return
      if (transfer(state%ltop_vor, 0_c_int) < 0 .or. transfer(state%ltop_vor, 0_c_int) > 1) return
      x = 0.5_c_double*half_a(1)
      pressure_profile = x <= 10.5_c_double
      if (pressure_profile .and. global_levels >= 91 .and. state%ltop_vor) then
        if (state%ntop_vor_trunc < 1 .or. state%ntop_vor_trunc > 46340) return
        if (state%ntop_vor_bot < 0 .or. state%ntop_vor_bot > global_levels) return
      end if
    end if
    allocate (profile(global_levels), stat=allocation_status)
    if (allocation_status /= 0) return
    sponge = 1.0_c_double
    if (pressure_profile) then
      sponge = state%rbegsponge
      x = half_b(0)*p0
      previous_half = half_a(0) + x
      do j = 1, global_levels
        x = half_b(j)*p0
        current_half = half_a(j) + x
        pressure = current_half + previous_half
        pressure = 0.5_c_double*pressure
        if (.not. positive(pressure)) then
          deallocate (profile)
          return
        end if
        x = public_log10(pressure)
        x = 3.0_c_double - x
        x = 7.5_c_double*x
        x = 1.0_c_double + x
        profile(j) = max(sponge, x)
        previous_half = current_half
      end do
    else
      do j = 1, global_levels
        if (global_levels == 19) then
          base = 2.0_c_double; power = max(6 - j, 0)
        else
          base = 1.3_c_double; power = max(min(global_levels, 9) - j, 0)
        end if
        product = 1.0_c_double
        do while (power /= 0)
          if (btest(power, 0)) product = product*base
          power = shiftr(power, 1)
          if (power == 0) exit
          base = base*base
        end do
        profile(j) = min(16.0_c_double, product)
      end do
      state%rbegsponge = 1.0_c_double
    end if
    discard = real(state%ndiffact, c_double)*dt
    do n = 0, truncation
      do j = 1, local_levels
        k = my_levels(j)
        if ((live .and. global_levels == 1) .or. profile(k) <= sponge) then
          vor = 0.0_c_double; div = 0.0_c_double
        else
          amp = profile(k) - sponge
          vor = diffusion_shape(n, global_rows - 1, amp, 4.0_c_double)
          vor = vor/state%hdirvor
          div = diffusion_shape(n, global_rows - 1, amp, 4.0_c_double)
          if (pressure_profile) then
            if (global_levels >= 91) then
              term = wave_fraction(n, global_rows - 1)
              x = state%klsponge - real(k, c_double)
              x = max(x, 0.0_c_double)
              term = term*x
              div = div + term
            else
              x = real(global_rows - 1, c_double)/rplradi
              if (x > 200.0_c_double) then
                term = wave_fraction(n, global_rows - 1)
                term = term*term
                term = 5.0_c_double*term
                x = state%klsponge - real(k, c_double)
                x = max(x, 0.0_c_double)
                term = term*x
                div = div + term
              end if
            end if
          end if
          div = div/state%hdirdiv
          if (pressure_profile .and. global_levels >= 91 .and. state%ltop_vor) then
            vor = diffusion_shape(n, global_rows - 1, amp, 4.0_c_double)
            term = wave_fraction(n, state%ntop_vor_trunc)
            term = public_pow(term, 4.0_c_double)
            x = real(real(state%ntop_vor_bot - k, c_float), c_double)
            x = max(x, 0.0_c_double)
            term = term*x
            vor = vor + term
            vor = vor/state%hdirdiv
          end if
        end if
        state%rdivor(j, n) = vor
        state%rdidiv(j, n) = div
      end do
      do j = 1, global_levels
        if ((live .and. global_levels == 1) .or. profile(j) <= sponge) then
          term = 0.0_c_double
        else
          amp = profile(j) - sponge
          term = diffusion_shape(n, global_rows - 1, amp, 4.0_c_double)
          term = term/state%hdirt
        end if
        state%rditg(j, n) = term
      end do
      state%rdisp(n) = 0.0_c_double
    end do
    inverse_factor = 1.0_c_double/real(2*truncation, c_double)
    inverse_factor = inverse_factor/dt
    threshold = truncation/2
    if (live .and. truncation >= 1999) threshold = truncation - 800
    do n = 0, truncation
      if (n <= threshold) then
        viscosity = 0.0_c_double
      else
        x = real(n - truncation, c_double)
        x = x*x
        x = -0.5_c_double*x
        y = real(n - threshold, c_double)
        y = y*y
        x = x/y
        e = public_exp(x)
        x = real(n*(n + 1), c_double)
        y = real(truncation*(truncation + 1), c_double)
        x = x/y
        x = x*x
        x = inverse_factor*x
        y = e*e
        viscosity = x*y
      end if
      do j = 1, local_levels
        state%rdivor(j, n) = state%rdivor(j, n) + viscosity
        state%rdidiv(j, n) = state%rdidiv(j, n) + viscosity
      end do
      do j = 1, global_levels
        state%rditg(j, n) = state%rditg(j, n) + viscosity
      end do
      state%rdisp(n) = 0.0_c_double
    end do
    do j = local_levels, 1, -1
      if (state%rdivor(j, truncation) > 1e-7_c_double) then
        discard = 1.0_c_double/state%rdivor(j, truncation)
        discard = discard/rhour
      end if
      if (state%rditg(j, truncation) > 1e-7_c_double) then
        discard = 1.0_c_double/state%rditg(j, truncation)
        discard = discard/rhour
      end if
      if (state%rdidiv(j, truncation) > 1e-7_c_double) then
        discard = 1.0_c_double/state%rdidiv(j, truncation)
        discard = discard/rhour
      end if
    end do
    deallocate (profile)
    status = 0
  end function
  !> Reverse source-owner release; compiler descriptors retain native form.
  integer(c_int) function release_spectral_diffusion_storage(state) result(status)
    type(native_spectral_diffusion_state), intent(inout) :: state
    if (allocated(state%rdisp)) deallocate (state%rdisp)
    if (allocated(state%rdigfl)) deallocate (state%rdigfl)
    if (allocated(state%rditg)) deallocate (state%rditg)
    if (allocated(state%rdidiv)) deallocate (state%rdidiv)
    if (allocated(state%rdivor)) deallocate (state%rdivor)
    status = 0
  end function
  logical function valid_switches(dynamics, spectral_tracers, tracer_switches) result(valid)
    type(native_dynamics_controls), intent(in) :: dynamics
    integer(c_int), intent(in) :: spectral_tracers
    logical, intent(in) :: tracer_switches(4)
    integer :: j
    valid = .false.
    if (spectral_tracers /= 0) return
    if (transfer(dynamics%lnhdyn, 0_c_int) /= 0 .or. transfer(dynamics%lslag, 0_c_int) /= 1) return
    if (transfer(dynamics%lslhd, 0_c_int) /= 0 .or. transfer(dynamics%lslhd_w, 0_c_int) /= 0 .or. &
        transfer(dynamics%lslhd_t, 0_c_int) /= 0 .or. transfer(dynamics%lslhd_spd, 0_c_int) /= 0 .or. &
        transfer(dynamics%lslhd_svd, 0_c_int) /= 0 .or. transfer(dynamics%lslhd_static, 0_c_int) /= 0) return
    do j = 1, 4
      if (transfer(tracer_switches(j), 0_c_int) /= 0) return
    end do
    valid = .true.
  end function
  logical function valid_dimensions(live, g, l, n, rows, longitudes, my_levels, half_a) result(valid)
    logical, intent(in) :: live
    integer(c_int), intent(in) :: g, l, n, rows, longitudes, my_levels(:)
    real(c_double), intent(in) :: half_a(0:)
    integer :: j
    valid = .false.
    if (longitudes < 1) return
    if (live) then
      if (g < 1 .or. g > 2147483646 .or. l < 0 .or. l > g .or. n < 1 .or. n > 46340) return
      if (rows <= n + 1 .or. rows > 46341) return
    else
      if (g < 2 .or. g > 59 .or. l /= g .or. n < 21 .or. n > 255) return
      if (rows <= n + 1 .or. rows > 1024) return
    end if
    if (size(my_levels, kind=c_int64_t) /= int(l, c_int64_t)) return
    do j = 1, l
      if (my_levels(j) < 1 .or. my_levels(j) > g) return
    end do
    if (size(half_a, kind=c_int64_t) /= int(g, c_int64_t) + 1) return
    if (.not. live) then
      if (.not. finite(half_a(1))) return
      if (half_a(1) <= 21.0_c_double) return
    end if
    valid = .true.
  end function
  logical function valid_storage(state, g, l, n) result(valid)
    type(native_spectral_diffusion_state), intent(in) :: state
    integer(c_int), intent(in) :: g, l, n
    valid = .false.
    if (.not. allocated(state%rdivor) .or. .not. allocated(state%rdidiv) .or. .not. allocated(state%rditg) .or. &
        .not. allocated(state%rdigfl) .or. .not. allocated(state%rdisp)) return
    if (any(lbound(state%rdivor) /= [1, 0]) .or. any(ubound(state%rdivor) /= [l, n])) return
    if (any(lbound(state%rdidiv) /= [1, 0]) .or. any(ubound(state%rdidiv) /= [l, n])) return
    if (any(lbound(state%rditg) /= [1, 0]) .or. any(ubound(state%rditg) /= [g, n])) return
    ! Empty native dimensions have standard bounds1:0 rather than raw strides.
    if (any(shape(state%rdigfl) /= [l, n + 1, 0])) return
    if (any(lbound(state%rdisp) /= [0]) .or. any(ubound(state%rdisp) /= [n])) return
    valid = .true.
  end function
  real(c_double) function wave_fraction(n, limit) result(value)
    integer, intent(in) :: n, limit
    real(c_double) :: denominator
    value = real(n*(n + 1), c_double)
    denominator = real(limit*(limit + 1), c_double)
    value = value/denominator
    value = sqrt(value)
    value = max(value, 0.0_c_double)
  end function
  real(c_double) function diffusion_shape(n, limit, amplitude, exponent) result(value)
    integer, intent(in) :: n, limit
    real(c_double), intent(in) :: amplitude, exponent
    real(c_double) :: x, y, first, second
    real(c_double), volatile :: one, zero, three, two
    one = 1.0_c_double; zero = 0.0_c_double; three = 3.0_c_double; two = 2.0_c_double
    x = wave_fraction(n, limit)
    x = public_pow(x, exponent)
    x = one*x
    first = x*amplitude
    x = wave_fraction(n, limit)
    y = exponent*three
    y = y/two
    x = public_pow(x, y)
    x = zero*x
    x = x*amplitude
    second = first + x
    x = wave_fraction(n, limit)
    x = public_pow(x, exponent)
    x = one*x
    value = second + x
  end function
  logical function finite(x) result(valid)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: bits
    bits = transfer(x, bits)
    valid = ibits(bits, 52, 11) /= 2047
  end function
  logical function positive(x) result(valid)
    real(c_double), intent(in) :: x
    integer(c_int64_t) :: bits
    bits = transfer(x, bits)
    valid = .not. btest(bits, 63) .and. bits /= 0 .and. ibits(bits, 52, 11) /= 2047
  end function
end module forecast_spectral_diffusion_setup
