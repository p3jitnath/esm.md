!> Borrow the two source inactive coupling flags without a global namespace.
module forecast_inactive_coupling_bindings
  use iso_fortran_env, only: int32
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_initial_fields_storage, only: native_initial_fields_state
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_ecmwf_physics_field_types, only: native_physics_runtime_data
  implicit none
  private
  public :: native_inactive_coupling_scalars, native_inactive_coupling_bindings
  public :: bind_operational_inactive_coupling_context
  !> The root forecast lifetime owns this one source CPL_NEMO_LIM flag.
  !! It is separate from TCOM and from the model's TMCC configuration.
  type :: native_inactive_coupling_scalars
    logical :: cpl_nemo_lim = .false.
  end type
  type :: native_inactive_coupling_bindings
    logical, pointer :: lusekf_ref => null(), cpl_nemo_lim => null()
  end type
contains
  !> All inputs borrow one live model/fields/partition graph. The two output
  !! pointers remain valid while their TARGET owners stay at the same address.
  !! Historical world4 admission is retained; other live process counts use
  !! the same source H/V/rank relationships and await forecast qualification.
  integer(int32) function bind_operational_inactive_coupling_context(model,fields,partition,runtime,scalars,output)result(status)
    type(native_operational_model_configuration), target, intent(in) :: model
    type(native_initial_fields_state), intent(in) :: fields
    type(native_distributed_partition), target, intent(in) :: partition
    type(native_physics_runtime_data), target, intent(in) :: runtime
    type(native_inactive_coupling_scalars), target, intent(inout) :: scalars
    type(native_inactive_coupling_bindings), intent(inout) :: output
    type(native_geometry_state), pointer :: geometry
    status = 2
    if (.not. associated(model%initial)) return
    if (.not. associated(fields%state_model, model)) return
    if (.not. associated(model%partition, partition)) return
    if (.not. allocated(model%initial%geometry)) return
    geometry => model%initial%geometry
    if (.not. associated(fields%geometry, geometry)) return
    if (partition%phase /= 7 .or. geometry%transform_control%nproc < 1) return
    if (geometry%transform_control%nprtrw < 1 .or. geometry%transform_control%nprtrv < 1) return
    if (geometry%transform_control%nprtrw*geometry%transform_control%nprtrv /= geometry%transform_control%nproc) return
    if (geometry%transform_control%myproc < 1 .or. geometry%transform_control%myproc > geometry%transform_control%nproc) return
  if (geometry%transform_control%mysetv /= mod(geometry%transform_control%myproc - 1, geometry%transform_control%nprtrv) + 1) return
    if (model%climate%cplng_active .or. model%climate%lnemocoup) return
    if (model%initial%controls%namespace%nconf /= 1 .or. model%initial%controls%namespace%lecmwf /= 1) return
    if (model%initial%controls%namespace%larpegef /= 0 .or. model%initial%controls%namespace%lelam /= 0) return
    if (model%initial%controls%namespace%lifstraj /= 0 .or. model%initial%controls%namespace%lifsmin /= 0) return
    if (model%initial%controls%namespace%lsforc /= 0 .or. runtime%lusekf_ref) return
    scalars%cpl_nemo_lim = .false.
    output%lusekf_ref => runtime%lusekf_ref
    output%cpl_nemo_lim => scalars%cpl_nemo_lim
    status = 0
  end function
end module
