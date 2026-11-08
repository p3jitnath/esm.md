!> Runtime admission for the complete native serial physics driver.
!! This is the default serial source branch. The optional historical parallel
!! build has a separate qualification domain and is not admitted here.
module forecast_runtime_complete_physics_driver
  use iso_fortran_env, only: int32
  use omp_lib, only: omp_in_parallel, omp_get_max_threads
  use forecast_complete_physics_driver, only: ec_phys_drv, native_complete_physics_driver_inputs
  implicit none
  private
  public :: run_runtime_complete_physics_driver
contains
  integer(int32) function run_runtime_complete_physics_driver(inputs) result(status)
    type(native_complete_physics_driver_inputs), target, intent(inout) :: inputs
    integer(int32) :: columns, levels, points, blocks
    status = 2_int32
    if (.not. associated(inputs%records%geometry)) return
    if (.not. associated(inputs%records%model)) return
    if (omp_in_parallel() .or. omp_get_max_threads() /= 1) return
    columns = inputs%records%geometry%dimensions%nproma
    levels = inputs%records%geometry%dimensions%nflevg
    points = inputs%records%geometry%partition%ngptot
    blocks = inputs%records%geometry%partition%ngpblks
    if (columns < 1 .or. columns > 128 .or. levels < 6 .or. levels > 137 .or. points < 1) return
    if (blocks /= (points - 1)/columns + 1) return
    ! The complete driver owns all temporary numerical and metadata storage.
    status = ec_phys_drv(inputs)
  end function
end module forecast_runtime_complete_physics_driver
