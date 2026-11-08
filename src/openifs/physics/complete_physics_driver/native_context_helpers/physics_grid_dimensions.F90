!> Native dimensions and shared serial diagnostics for the physics context.
module physics_context_helper_counters_mod
  use iso_fortran_env, only: int32, int64
  implicit none
  private
  public :: increment_context_helper_count, physics_dimension_call_count_get
  public :: physics_context_address_call_count_get, physics_context_block_call_count_get
  integer(int64), save :: dimension_counts(2) = 0_int64, address_counts(3) = 0_int64, block_counts(4) = 0_int64
contains
  subroutine increment_word(word)
    integer(int64), intent(inout) :: word
    if (word == huge(word)) then
      word = -huge(word) - 1_int64
    else
      word = word + 1_int64
    end if
  end subroutine
  subroutine increment_context_helper_count(group, index)
    integer, intent(in) :: group, index
    select case (group)
    case (1)
      call increment_word(dimension_counts(index))
    case (2)
      call increment_word(address_counts(index))
    case (3)
      call increment_word(block_counts(index))
    end select
  end subroutine
  integer(int64) function physics_dimension_call_count_get(index) result(word)
    integer(int32), intent(in) :: index
    word = 0_int64
    if (index >= 0 .and. index < 2) word = dimension_counts(index + 1)
  end function
  integer(int64) function physics_context_address_call_count_get(index) result(word)
    integer(int32), intent(in) :: index
    word = 0_int64
    if (index >= 0 .and. index < 3) word = address_counts(index + 1)
  end function
  integer(int64) function physics_context_block_call_count_get(index) result(word)
    integer(int32), intent(in) :: index
    word = 0_int64
    if (index >= 0 .and. index < 4) word = block_counts(index + 1)
  end function
end module
module physics_grid_dimension_helpers_mod
  use iso_fortran_env, only: int32, int64
  use yomphyder, only: dimension_type
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_operational_model_types, only: native_operational_model_configuration
  use surface_field_configuration_port, only: surface_field_registry
  use physics_context_helper_counters_mod, only: increment_context_helper_count
  implicit none
  private
  public :: initialize_physics_dimensions, update_physics_dimensions, surface_group_index
contains
  !> Locate a named group in the actual readonly surface metadata.
  integer function surface_group_index(surface, key) result(group)
    type(surface_field_registry), intent(in) :: surface
    character(len=*), intent(in) :: key
    integer :: j
    group = 0
    do j = 1, size(surface%groups)
      if (surface%groups(j)%key == key) then
        group = j; return
      end if
    end do
  end function
  !> Copy the source counts without changing block metadata or latitude view.
  !! Counts are dimensionless. SOIL_DIAGNOSTICS has exactly14 int32 counts,
  !! ordered TLS pair,TSS pair,TTS pair,TIS pair,SSS pair,IIS pair,WLS pair.
  !! LSPSDT/N2D are the actual readonly stochastic controls. No missing
  !! producer value is replaced by a literal. Status2 refuses metadata before
  !! mutation; valid source callers return0 and preserve all numerical owners.
 integer(int32) function initialize_physics_dimensions(dimensions,geometry,model,surface,soil_diagnostics,lspsdt,n2d) result(status)
    type(dimension_type), intent(inout) :: dimensions
    type(native_geometry_state), intent(in) :: geometry
    type(native_operational_model_configuration), intent(in) :: model
    type(surface_field_registry), intent(in) :: surface
    integer(int32), intent(in) :: soil_diagnostics(:), n2d
    logical, intent(in) :: lspsdt
    integer :: soil, extra, extra2
    status = 2
    if (size(soil_diagnostics) /= 14) return
    soil = surface_group_index(surface, 'YSP_SBD')
    extra = surface_group_index(surface, 'YSD_XAD')
    extra2 = surface_group_index(surface, 'YSD_X2D')
    if (soil == 0 .or. extra == 0 .or. extra2 == 0) return
    call increment_context_helper_count(1, 1)
    dimensions%klon = geometry%dimensions%nproma
    dimensions%ksmax = geometry%dimensions%nsmax
    dimensions%klevs = surface%groups(soil)%metadata%layers
    dimensions%ktiles = model%physics_dimensions%ntiles
    dimensions%klevx = surface%groups(extra)%metadata%layers
    dimensions%kfldx = surface%groups(extra)%metadata%stored_fields
    dimensions%kfldx2 = surface%groups(extra2)%metadata%stored_fields
    dimensions%klev = geometry%dimensions%nflevg
    dimensions%kvclis = model%physics_dimensions%nvclis
    dimensions%klevi = model%physics_dimensions%ncsi
    dimensions%klevo = model%physics_dimensions%ncom - 1_int32
    dimensions%klevsn = model%physics_dimensions%ncsnec
    dimensions%kdhvtls = soil_diagnostics(1)
    dimensions%kdhftls = soil_diagnostics(2)
    dimensions%kdhvtss = soil_diagnostics(3)
    dimensions%kdhftss = soil_diagnostics(4)
    dimensions%kdhvtts = soil_diagnostics(5)
    dimensions%kdhftts = soil_diagnostics(6)
    dimensions%kdhvtis = soil_diagnostics(7)
    dimensions%kdhftis = soil_diagnostics(8)
    dimensions%kdhvsss = soil_diagnostics(9)
    dimensions%kdhfsss = soil_diagnostics(10)
    dimensions%kdhviis = soil_diagnostics(11)
    dimensions%kdhfiis = soil_diagnostics(12)
    dimensions%kdhvwls = soil_diagnostics(13)
    dimensions%kdhfwls = soil_diagnostics(14)
    dimensions%kidia = 1_int32
    dimensions%ktdia = 1_int32
    if (lspsdt) then
      dimensions%k2dsdt = n2d
    else
      dimensions%k2dsdt = 0_int32
    end if
    status = 0
  end function
  !> Borrow a native latitude pointer, preserving its bounds and empty state.
  !! Latitude indices are dimensionless; every other dimension member stays.
  integer(int32) function update_physics_dimensions(dimensions, block, active, global_start, latitude) result(status)
    type(dimension_type), intent(inout) :: dimensions
    integer(int32), intent(in) :: block, active, global_start
    integer(int32), pointer, intent(in) :: latitude(:)
    call increment_context_helper_count(1, 2)
    dimensions%kbl = block; dimensions%kfdia = active; dimensions%kstglo = global_start
    dimensions%kgplat => latitude
    status = 0
  end function
end module physics_grid_dimension_helpers_mod
