!> Own the selected output spectral controller and its result namespace.
module forecast_fullpos_spectral_norm_controller
  use iso_fortran_env, only: int32, int64, real64
  use yomhook, only: dr_hook, jphook
  use forecast_fullpos_result_types, only: native_fullpos_spectral_norms
  use forecast_fullpos_spectral_norm_arithmetic, only: output_spectral_norm_matrix
  implicit none
  private
  public :: calculate_output_spectral_norms, fpspnorms
  interface fpspnorms
    module procedure calculate_output_spectral_norms
  end interface
contains
  !> Calculate39 or fewer output-field norms on the complete serial wave layout.
 !! LEVELS represents the selected field count. WORLD must be one. P/S are
 !! the admitted source I/O configurations. BUDGET bounds private matrix bytes.
 !! Active result slots change; source tails and unrelated owners are retained.
 integer(int32)function calculate_output_spectral_norms(world,maximum_degree,waves,starts,field,vertical_sets,configuration,hook_enabled,budget,result)result(status)
  integer(int32), intent(in) :: world, maximum_degree, waves(:), starts(0:), vertical_sets(:)
  real(real64), intent(in) :: field(:, :)
  character(*), intent(in) :: configuration
  logical, intent(in) :: hook_enabled
  integer(int64), intent(in) :: budget
  type(native_fullpos_spectral_norms), intent(inout) :: result
  real(real64), allocatable :: matrix(:, :)
  real(real64) :: value, total
  real(kind=jphook) :: handle
  integer :: levels, w, l, ierr
  status = 2; levels = size(vertical_sets)
  if (world /= 1 .or. levels < 1 .or. levels > 39) return
  if (len(configuration) < 1) return
  if (configuration(1:1) /= 'P' .and. configuration(1:1) /= 'S') return
  if (any(vertical_sets /= 1)) return
  if (maximum_degree < 1 .or. maximum_degree > 8191) return
  if (8_int64*levels*(maximum_degree + 1_int64) > budget) return
  if (hook_enabled) call dr_hook('FPSPNORMS', 0, handle)
  allocate (matrix(levels, maximum_degree + 1), stat=ierr)
  if (ierr /= 0) then
    status = 1; goto900
  end if
  call output_spectral_norm_matrix(maximum_degree, waves, starts, field, .false., int(levels, int32), matrix, status)
  if (status /= 0) then
    deallocate (matrix); goto900
  end if
  do l = 1, levels
    total = 0.0_real64
    do w = 1, maximum_degree + 1
      total = total + matrix(l, w)
    end do
    value = sqrt(total)
    result%values(l) = value
    if (.not. (value >= epsilon(1.0_real64))) value = 0.0_real64
    result%display(l) = value
  end do
  result%count = levels
  deallocate (matrix)
  status = 0
900 if (hook_enabled) call dr_hook('FPSPNORMS', 1, handle)
  end function
end module
