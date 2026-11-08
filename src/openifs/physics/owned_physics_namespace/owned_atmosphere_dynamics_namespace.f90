!> Borrow the existing two atmosphere tables and complete INTDYN map owner.
module forecast_owned_atmosphere_dynamics_namespace
  use iso_fortran_env, only: int32, real64
  use forecast_standard_atmosphere, only: atmosphere_layers
  use forecast_dynamics_field_maps, only: native_dynamics_field_maps, native_initialize_maps => initialize_dynamics_field_maps
  implicit none
  private
  public :: native_atmosphere_dynamics_namespace, initialize_fresh_atmosphere_dynamics_namespace
  public :: bind_produced_atmosphere_dynamics_namespace, release_atmosphere_dynamics_namespace
  public :: native_dynamics_field_maps, initialize_owned_dynamics_field_maps, atmosphere_layers
  !> Readonly borrowed aliases replace the old copied scalar namespace.
 !! Targets remain stable while any consumer holds this view.
  type :: native_atmosphere_dynamics_namespace
    type(atmosphere_layers), pointer :: references(:) => null()
    type(native_dynamics_field_maps) :: maps
  end type
contains
  !> Define fresh zero-born storage before SUSTA and SUINTDYN.
 !! Reference heights use m, gradients K/m, temperatures K and pressures Pa.
 !! Every dynamics member is a dimensionless integer field selector.
  integer(int32) function initialize_fresh_atmosphere_dynamics_namespace(view, references) result(status)
    type(native_atmosphere_dynamics_namespace), intent(inout) :: view
    type(atmosphere_layers), target, intent(inout) :: references(:)
    integer :: j
    status = 2
    if (associated(view%references)) return
    if (size(references) /= 2 .or. .not. is_contiguous(references)) return
    do j = 1, 2
      references(j)%height = 0.0_real64; references(j)%gradient = 0.0_real64
      references(j)%temperature = 0.0_real64; references(j)%pressure = 0.0_real64
    end do
    view%maps = native_dynamics_field_maps()
    view%references => references
    status = 0
  end function
  !> Attach the same final produced records without copying or recomputing them.
  integer(int32) function bind_produced_atmosphere_dynamics_namespace(view, references) result(status)
    type(native_atmosphere_dynamics_namespace), intent(inout) :: view
    type(atmosphere_layers), target, intent(in) :: references(:)
    status = 2
    if (associated(view%references)) return
    if (size(references) /= 2 .or. .not. is_contiguous(references)) return
    view%references => references
    status = 0
  end function
  !> Produce the single inline map record through the unchanged SUINTDYN body.
  integer(int32) function initialize_owned_dynamics_field_maps(view) result(status)
    type(native_atmosphere_dynamics_namespace), intent(inout) :: view
    status = native_initialize_maps(view%maps)
  end function
  !> End only the borrowed views; source tables and map data remain upstream.
  subroutine release_atmosphere_dynamics_namespace(view)
    type(native_atmosphere_dynamics_namespace), intent(inout) :: view
    nullify (view%references)
  end subroutine
end module
