!> Compute the selected complete spectral norm output from native fields.
module forecast_selected_spectral_norms
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(==)
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_spectral_norm_namespace, only: spectral_norm_persistent_state
  use forecast_ordered_spectral_norm_arithmetic, only: selected_spectral_norm_matrix, selected_spectral_norm_average
  implicit none
  private
  public :: spectral_norm_fields, spectral_norm_model_controls
  public :: compute_selected_spectral_norms, spectral_norm_environment_supported
  public :: selected_spectral_norm_result_words
  integer, parameter :: selected_spectral_norm_result_words = 2616
  !> Borrow initialized spectral owners without changing their values.
  !! VO,D and temperature have shape(level,real_coefficient). Pressure is one
  !! contiguous real-coefficient vector. All views retain their original units.
  !! These pointers are views of the caller's actual field owners,not defaults.
  type :: spectral_norm_fields
    real(real64), pointer :: vorticity(:, :) => null(), divergence(:, :) => null(), temperature(:, :) => null()
    real(real64), pointer :: surface_pressure(:) => null()
  end type
  !> The selected source consumes one thermal and one pressure field,no tracers.
  !! The caller copies these counts and the dynamics flag from its real model.
  type :: spectral_norm_model_controls
    integer(int32) :: thermal_fields = 0, pressure_fields = 0, spectral_tracers = 0
    logical :: nonhydrostatic = .false.
  end type
contains
  !> Check portable parts of the qualified entry environment without new flags.
  !! The current Arm caller also establishes the contract's exact FPCR0.
  !! No numerical call is accepted solely from this portable inquiry.
  logical function spectral_norm_environment_supported() result(ok)
    type(ieee_round_type) :: rounding
    type(ieee_status_type) :: saved
    real(real64), volatile :: normal_minimum, half_subnormal
    call ieee_get_status(saved)
    call ieee_get_rounding_mode(rounding)
    ok = .false.
    if (rounding == ieee_nearest) then
      normal_minimum = tiny(0.0_real64)
      half_subnormal = normal_minimum*0.5_real64
      ok = transfer(half_subnormal, 0_int64) == int(z'0008000000000000', int64)
    end if
    call ieee_set_status(saved)
  end function

  !> Calculate the complete selected T21,L19 source output in canonical order.
  !!
  !! controls contains NSPPR,LELAM,LREFGEN,LREFOUT,NPROC,LDSPOR. Its selected
  !! values are0,0,0,0,1,0. Geometry supplies the actual wave and Laplacian
  !! owners;fields supplies the initialized native weather arrays.
  !!
  !! results is2616 or more contiguous FP64 words in the retained output
  !! encoding. Matrix,level-vector and mean regions retain their original word
  !! positions. Every gap and trailing word stays unchanged. These positions
  !! describe an output file format,not a private compiler record layout.
  !! All mutable outputs and persistent state are disjoint from input owners.
  !!
  !! Status2 refuses unsupported metadata before output mutation. Status0
  !! completes all six matrices,the kinetic combination,five level/mean
  !! calculations and AVNRMDIV update. No allocation,MPI,original routine or
  !! original global supplies a stage. Natural arithmetic flags remain visible.
  subroutine compute_selected_spectral_norms(geometry, model, fields, controls, persistent, results, status)
    type(native_geometry_state), intent(in) :: geometry
    type(spectral_norm_model_controls), intent(in) :: model
    type(spectral_norm_fields), intent(in) :: fields
    integer(int32), intent(in) :: controls(6)
    type(spectral_norm_persistent_state), intent(inout) :: persistent
    real(real64), contiguous, target, intent(inout) :: results(:)
    integer(int32), intent(out) :: status
    real(real64), pointer, contiguous :: vo(:, :), div(:, :), energy(:, :), div_energy(:, :), thermal(:, :), pressure(:, :)
    real(real64), pointer, contiguous :: source_pressure(:, :)
    real(real64) :: sum_value
    integer :: j, k, start
    status = 2
    if (any(controls /= [0_int32, 0_int32, 0_int32, 0_int32, 1_int32, 0_int32])) return
    if (model%nonhydrostatic) return
    if (model%thermal_fields /= 1 .or. model%pressure_fields /= 1 .or. model%spectral_tracers /= 0) return
    if (size(results) < selected_spectral_norm_result_words) return
    if (geometry%dimensions%nsmax /= 21 .or. geometry%dimensions%nflevg /= 19) return
    if (geometry%partition%nump /= 22 .or. geometry%partition%nflevl /= 19) return
    if (geometry%partition%npsp /= 1 .or. geometry%partition%nspec2 /= 506) return
    if (.not. allocated(geometry%laplacian%myms)) return
    if (.not. allocated(geometry%laplacian%nasm0)) return
    if (.not. allocated(geometry%laplacian%rlapin)) return
    if (size(geometry%laplacian%myms) /= 22) return
    if (lbound(geometry%laplacian%nasm0, 1) > 0 .or. ubound(geometry%laplacian%nasm0, 1) < 21) return
    if (lbound(geometry%laplacian%rlapin, 1) > 0 .or. ubound(geometry%laplacian%rlapin, 1) < 21) return
    start = 1
    do j = 0, 21
      if (geometry%laplacian%myms(j + 1) /= j) return
      if (geometry%laplacian%nasm0(j) /= start) return
      start = start + 2*(22 - j)
    end do
    if (.not. associated(fields%vorticity) .or. .not. associated(fields%divergence)) return
    if (.not. associated(fields%temperature) .or. .not. associated(fields%surface_pressure)) return
    if (size(fields%vorticity, 1) < 19 .or. size(fields%vorticity, 2) < 506) return
    if (size(fields%divergence, 1) < 19 .or. size(fields%divergence, 2) < 506) return
    if (size(fields%temperature, 1) < 19 .or. size(fields%temperature, 2) < 506) return
    if (size(fields%surface_pressure) < 506 .or. .not. is_contiguous(fields%surface_pressure)) return
    if (.not. spectral_norm_environment_supported()) return
    vo(1:19, 1:22) => results(1:418)
    div(1:19, 1:22) => results(419:836)
    energy(1:19, 1:22) => results(837:1254)
    div_energy(1:19, 1:22) => results(1255:1672)
    thermal(1:19, 1:22) => results(1673:2090)
    pressure(1:1, 1:22) => results(2091:2112)
    source_pressure(1:1, 1:506) => fields%surface_pressure(1:506)
    call selected_spectral_norm_matrix(geometry%laplacian%myms, geometry%laplacian%nasm0(0:21), &
                                       geometry%laplacian%rlapin(0:21), fields%vorticity, .false., 19_int32, vo, status)
    if (status /= 0) return
    call selected_spectral_norm_matrix(geometry%laplacian%myms, geometry%laplacian%nasm0(0:21), &
                                       geometry%laplacian%rlapin(0:21), fields%divergence, .false., 19_int32, div, status)
    if (status /= 0) return
    call selected_spectral_norm_matrix(geometry%laplacian%myms, geometry%laplacian%nasm0(0:21), &
                                       geometry%laplacian%rlapin(0:21), fields%vorticity, .true., 19_int32, energy, status)
    if (status /= 0) return
    call selected_spectral_norm_matrix(geometry%laplacian%myms, geometry%laplacian%nasm0(0:21), &
                                       geometry%laplacian%rlapin(0:21), fields%divergence, .true., 19_int32, div_energy, status)
    if (status /= 0) return
    call selected_spectral_norm_matrix(geometry%laplacian%myms, geometry%laplacian%nasm0(0:21), &
                                       geometry%laplacian%rlapin(0:21), fields%temperature, .false., 19_int32, thermal, status)
    if (status /= 0) return
    call selected_spectral_norm_matrix(geometry%laplacian%myms, geometry%laplacian%nasm0(0:21), &
                                       geometry%laplacian%rlapin(0:21), source_pressure, .false., 1_int32, pressure, status)
    if (status /= 0) return
    do k = 1, 22
      do j = 1, 19
        sum_value = energy(j, k) + div_energy(j, k)
        energy(j, k) = sum_value*0.5_real64
      end do
    end do
    call selected_spectral_norm_average(vo, 19_int32, .false., results(2509:2527), results(2604), status)
    if (status /= 0) return
    call selected_spectral_norm_average(div, 19_int32, .false., results(2528:2546), results(2605), status)
    if (status /= 0) return
    persistent%avnrmdiv = results(2605)
    call selected_spectral_norm_average(energy, 19_int32, .true., results(2547:2565), results(2606), status)
    if (status /= 0) return
    call selected_spectral_norm_average(thermal, 19_int32, .false., results(2566:2584), results(2607), status)
    if (status /= 0) return
    call selected_spectral_norm_average(pressure, 1_int32, .false., results(2585:2585), results(2608), status)
  end subroutine
end module forecast_selected_spectral_norms
