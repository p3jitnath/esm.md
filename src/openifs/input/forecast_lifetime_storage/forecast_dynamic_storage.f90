!> Source-ordered saved departure points, lagged weights and physics tendencies.
module forecast_native_dynamic_storage
  use iso_fortran_env, only: int32, int64, real64
  use forecast_operational_model_types, only: native_operational_model_configuration
  implicit none
  private
  public :: native_forecast_dynamic_storage, initialize_forecast_dynamics_defaults
  public :: allocate_saved_departure_points, initialize_lagged_tendency_configuration
  public :: allocate_saved_physics_tendencies, release_forecast_dynamic_storage
  type native_forecast_dynamic_storage
    real(real64) :: betadt
    logical :: lsetfstat
    integer(int32) :: ncurrent_iter, nvtend, mu_savtend, mv_savtend, mt_savtend
    real(real64), allocatable :: rsavedp(:, :, :, :), rslwx(:), savtend(:, :, :, :)
  end type
contains
!> Store the three SUDYN defaults after the same platform admission.
!! PLATFORM is NCONF,LECMWF,LR2D,LR3D. Every unrelated native member stays intact.
  integer(int32) function initialize_forecast_dynamics_defaults(state, platform) result(status)
    type(native_forecast_dynamic_storage), intent(inout) :: state
    integer(int32), intent(in) :: platform(4)
    status = 2
    if (any(platform /= [1_int32, 1_int32, 0_int32, 1_int32])) return
    state%betadt = 1.0_real64
    state%lsetfstat = .false.
    state%ncurrent_iter = 0_int32
    status = 0
  end function
!> Read the same live Geometry through MODEL. OPERATIONAL selects the wider block bound.
  logical function supported_shape(model, operational, rows, levels, blocks) result(ok)
    type(native_operational_model_configuration), intent(in) :: model
    logical, intent(in) :: operational
    integer(int32), intent(out) :: rows, levels, blocks
    integer(int32) :: maximum_blocks
    ok = .false.; rows = 0; levels = 0; blocks = 0
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    if (.not. model%initial%geometry%initialized) return
    rows = model%initial%geometry%dimensions%nproma
    levels = model%initial%geometry%dimensions%nflevg
    blocks = model%initial%geometry%partition%ngpblks
    maximum_blocks = 4096_int32
    if (operational) maximum_blocks = 388217_int32
    if (rows < 1 .or. rows > 1024 .or. levels < 1 .or. levels > 255 .or. blocks < 1 .or. blocks > maximum_blocks) return
    ok = .true.
  end function
!> Allocate RSAVEDP(rows,levels,3,blocks), preserving every unassigned payload word.
!! Values remain undefined until the qualified Cartesian departure producer writes them.
  integer(int32) function allocate_saved_departure_points(state, model, operational, byte_limit) result(status)
    type(native_forecast_dynamic_storage), intent(inout) :: state
    type(native_operational_model_configuration), intent(in) :: model
    logical, intent(in) :: operational
    integer(int64), intent(in) :: byte_limit
    real(real64), allocatable :: pending(:, :, :, :)
    integer(int32) :: rows, levels, blocks
    integer :: allocation_status
    status = 2
    if (.not. supported_shape(model, operational, rows, levels, blocks)) return
    if (.not. model%interpolation_controls%lsldp_xyz .or. .not. model%interpolation_controls%lsldp_save) return
    if (allocated(state%rsavedp)) return
    if (8_int64*rows*levels*3_int64*blocks > byte_limit) return
    allocate (pending(rows, levels, 3, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    call move_alloc(pending, state%rsavedp)
    status = 0
  end function
!> Allocate RSLWX(1:levels), set exact weights0.5, then publish count3 and positions1:3.
  integer(int32) function initialize_lagged_tendency_configuration(state, model, operational, byte_limit) result(status)
    type(native_forecast_dynamic_storage), intent(inout) :: state
    type(native_operational_model_configuration), intent(in) :: model
    logical, intent(in) :: operational
    integer(int64), intent(in) :: byte_limit
    real(real64), allocatable :: pending(:)
    integer(int32) :: rows, levels, blocks
    integer :: allocation_status
    status = 2
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    levels = model%initial%geometry%dimensions%nflevg
    if (levels < 1 .or. levels > 255) return
    if (.not. model%physics%ecmwf_physics%lslphy) return
    if (allocated(state%rslwx) .or. 8_int64*levels > byte_limit) return
    allocate (pending(levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    pending = 0.5_real64
    call move_alloc(pending, state%rslwx)
    state%nvtend = 3_int32
    state%mu_savtend = 1_int32
    state%mv_savtend = 2_int32
    state%mt_savtend = 3_int32
    status = 0
  end function
!> Allocate SAVTEND from the live three-field producer and store positive zero throughout.
  integer(int32) function allocate_saved_physics_tendencies(state, model, operational, byte_limit) result(status)
    type(native_forecast_dynamic_storage), intent(inout) :: state
    type(native_operational_model_configuration), intent(in) :: model
    logical, intent(in) :: operational
    integer(int64), intent(in) :: byte_limit
    real(real64), allocatable :: pending(:, :, :, :)
    integer(int32) :: rows, levels, blocks
    integer :: allocation_status
    status = 2
    if (.not. supported_shape(model, operational, rows, levels, blocks)) return
    if (.not. model%physics%ecmwf_physics%lslphy .or. state%nvtend /= 3) return
    if (allocated(state%savtend)) return
    if (8_int64*rows*levels*3_int64*blocks > byte_limit) return
    allocate (pending(rows, levels, 3, blocks), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    pending = 0.0_real64
    call move_alloc(pending, state%savtend)
    status = 0
  end function
!> Release only the three owned arrays, in reverse source order.
  integer(int32) function release_forecast_dynamic_storage(state) result(status)
    type(native_forecast_dynamic_storage), intent(inout) :: state
    if (allocated(state%savtend)) deallocate (state%savtend)
    if (allocated(state%rslwx)) deallocate (state%rslwx)
    if (allocated(state%rsavedp)) deallocate (state%rsavedp)
    status = 0
  end function
end module forecast_native_dynamic_storage
