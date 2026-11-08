!> Retain ordered grid-field sums and the public weighted norm reduction.
module forecast_grid_field_norms
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_int32_t
  use mpi_f08
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_selected_spectral_norms, only: spectral_norm_environment_supported
  implicit none
  private
  public :: selected_gridpoint_norm_result, compute_selected_gridpoint_norms
  public :: compute_runtime_grid_field_norms
  !> Eight canonical output rows:vertical-sum mean,field mean,minimum,maximum.
  !! selected_count occupies the next int32 word;reserved retains its preimage.
  !! This public C record describes output encoding,not a private model layout.
  type, bind(C) :: selected_gridpoint_norm_result
    real(c_double) :: values(4, 8)
    integer(c_int32_t) :: selected_count, reserved
  end type
#include "gpnorm_trans.h"
contains
  !> Retain FMINNM signed-zero selection for finite scientific input values.
  real(real64) function source_minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    integer(int64) :: left, right
    left = transfer(a, 0_int64); right = transfer(b, 0_int64)
    if (iand(left, int(z'7fffffffffffffff', int64)) == 0_int64 .and. &
        iand(right, int(z'7fffffffffffffff', int64)) == 0_int64) then
      value = transfer(ior(left, right), 0.0_real64)
    else
      value = min(a, b)
    end if
  end function

  !> Retain FMAXNM signed-zero selection for finite scientific input values.
  real(real64) function source_maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    integer(int64) :: left, right
    left = transfer(a, 0_int64); right = transfer(b, 0_int64)
    if (iand(left, int(z'7fffffffffffffff', int64)) == 0_int64 .and. &
        iand(right, int(z'7fffffffffffffff', int64)) == 0_int64) then
      value = transfer(iand(left, right), 0.0_real64)
    else
      value = max(a, b)
    end if
  end function

  !> Add levels first at each physical cell,and retain source extrema order.
  !! fields(P,L,C,B) is borrowed;selection contains one-based field indices.
  !! sums(P,F,B),block_min/max(F,B),minimum/max(F) are disjoint private owners.
  !! Final-block padding is never read or initialized. Active values are finite
  !! scientific inputs in the qualified source range. Every add rounds in FP64.
  subroutine form_vertical_sums(fields, selection, physical_points, sums, block_min, block_max, minimum, maximum)
    real(real64), intent(in) :: fields(:, :, :, :)
    integer(int32), intent(in) :: selection(:), physical_points
    real(real64), intent(inout) :: sums(:, :, :), block_min(:, :), block_max(:, :), minimum(:), maximum(:)
    integer :: f, block, level, cell, active, pitch, levels, blocks, source_field
    real(real64) :: value, low, high
    pitch = size(fields, 1); levels = size(fields, 2); blocks = size(fields, 4)
    do f = 1, size(selection)
      source_field = selection(f)
      do block = 1, blocks
        active = min(pitch, physical_points - (block - 1)*pitch)
        low = fields(1, 1, source_field, 1)
        high = low
        do cell = 1, active
          sums(cell, f, block) = 0.0_real64
        end do
        do level = 1, levels
          do cell = 1, active
            value = fields(cell, level, source_field, block)
            sums(cell, f, block) = sums(cell, f, block) + value
            low = source_minimum(low, value)
            high = source_maximum(high, value)
          end do
        end do
        block_min(f, block) = low
        block_max(f, block) = high
      end do
      low = block_min(f, 1); high = block_max(f, 1)
      do block = 2, blocks
        low = source_minimum(low, block_min(f, block))
        high = source_maximum(high, block_max(f, block))
      end do
      minimum(f) = low; maximum(f) = high
    end do
  end subroutine

  !> Compute the selected eight-field P24,L19,Q2048 source result.
  !!
  !! geometry owns the actual live public transform resolution. fields has
  !! exact native shape(24,19,8,86);lgp(8) are actual component selection flags.
  !! controls is NSPPR,LELAM,NPROC=0,0,1. Active values have their original
  !! field units and are finite;the source contract excludes nonfinite inputs.
  !! All outputs retain their source order;result%reserved stays unchanged.
  !! Status0 succeeds,1 refuses allocation and2 refuses before any output.
  !! Public GPNORM_TRANS owns latitude weighting with LDAVE_ONLY=true. Its
  !! initialized resolution must stay live. No original OpenIFS stage is called.
  subroutine compute_selected_gridpoint_norms(geometry, fields, lgp, controls, result, status)
    type(native_geometry_state), intent(in) :: geometry
    real(real64), intent(in) :: fields(:, :, :, :)
    logical, intent(in) :: lgp(:)
    integer(int32), intent(in) :: controls(3)
    type(selected_gridpoint_norm_result), intent(inout) :: result
    integer(int32), intent(out) :: status
    real(real64), allocatable :: sums(:, :, :)
    real(real64) :: block_min(8, 86), block_max(8, 86), minimum(8), maximum(8), average(8)
    integer(int32) :: selection(8)
    integer :: f, code
    status = 2
    if (any(controls /= [0_int32, 0_int32, 1_int32])) return
    if (geometry%dimensions%nproma /= 24 .or. geometry%dimensions%nflevg /= 19) return
    if (geometry%partition%ngpblks /= 86 .or. geometry%partition%ngptot /= 2048) return
    if (geometry%transform_resolution%resolution < 1) return
    if (geometry%transform_control%nproc /= 1) return
    if (any(shape(fields) /= [24, 19, 8, 86]) .or. .not. is_contiguous(fields)) return
    if (size(lgp) /= 8) return
    if (.not. all(lgp)) return
    if (.not. spectral_norm_environment_supported()) return
    allocate (sums(24, 8, 86), stat=code)
    if (code /= 0) then
      status = 1
      return
    end if
    do f = 1, 8
      selection(f) = f
    end do
    call form_vertical_sums(fields, selection, 2048_int32, sums, block_min, block_max, minimum, maximum)
    do f = 1, 8
      result%values(3, f) = minimum(f)
      result%values(4, f) = maximum(f)
    end do
    call gpnorm_trans(sums, 8_int32, 24_int32, average, minimum, maximum, .true., &
                      geometry%transform_resolution%resolution)
    do f = 1, 8
      result%values(1, f) = average(f)
      result%values(2, f) = average(f)/19.0_real64
      result%values(3, f) = minimum(f)
      result%values(4, f) = maximum(f)
    end do
    deallocate (sums)
    result%selected_count = 8
    status = 0
  end subroutine

  !> Compute live selected-field norms on every process through public MPI.
  !!
  !! fields(P,L,C,B) is a dense native array with P1:4096,L1:512,C1:2048.
  !! Physical local Q=geometry%partition%NGPTOT is positive and B=ceil(Q/P).
  !! lgp(C) selects F1:16 fields in ascending source order. All ranks use the
  !! same L and selection. controls is NSPPR,LELAM,world,optional-present,with
  !! only actual world nonzero. nonhydrostatic is the actual model LNHDYN flag.
  !!
  !! result_values has at least(4,F) elements and canonical_capacity>=32*F+8
  !! bytes. selected_count is the separately named int32 output. A caller's
  !! trailing padding word is not an argument and is never changed. Only rank0
  !! publishes. budget is positive and<=64GiB;one allocation uses8*(P+2)*F*B.
  !! Inputs,private storage and outputs are disjoint. Active values are finite
  !! scientific inputs. The caller qualifies exact FPCR0 on the current target.
  !!
  !! Status0 succeeds,1 refuses allocation,2 refuses metadata or common field
  !! selection and3 reports a returned public MPI error. All ranks call
  !! together. Refusal leaves public outputs unchanged and frees acquired work.
  subroutine compute_runtime_grid_field_norms(comm, geometry, fields, lgp, controls, nonhydrostatic, &
                                              result_values, selected_count, canonical_capacity, budget, status)
    type(MPI_Comm), intent(in) :: comm
    type(native_geometry_state), intent(in) :: geometry
    real(real64), intent(in) :: fields(:, :, :, :)
    logical, intent(in) :: lgp(:), nonhydrostatic
    integer(int32), intent(in) :: controls(4)
    real(real64), intent(inout) :: result_values(:, :)
    integer(int32), intent(inout) :: selected_count
    integer(int64), intent(in) :: canonical_capacity, budget
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: work(:)
    real(real64), pointer, contiguous :: sums(:, :, :), block_min(:, :), block_max(:, :)
    real(real64) :: minimum(16), maximum(16), average(16), stage(4, 16)
    integer(int32) :: selection(16), common(18), reference(18), local_status
    integer :: world, rank, error, pitch, levels, components, blocks, points, f, i, code
    integer(int64) :: sum_words, block_words, required
    status = 3
    call MPI_Comm_rank(comm, rank, error)
    if (error /= MPI_SUCCESS) return
    call MPI_Comm_size(comm, world, error)
    if (error /= MPI_SUCCESS) return
    local_status = 2
    f = 0; selection = 0
    if (world < 1 .or. world > 65536) goto100
    if (any(controls /= [0_int32, 0_int32, int(world, int32), 0_int32])) goto100
    if (nonhydrostatic) goto100
    if (geometry%partition%phase /= 7) goto100
    if (geometry%transform_control%nproc /= world .or. geometry%transform_control%myproc /= rank + 1) goto100
    if (geometry%partition%borrowed_resolution /= geometry%transform_resolution%resolution) goto100
    if (geometry%transform_resolution%resolution < 1) goto100
    pitch = geometry%dimensions%nproma; levels = geometry%dimensions%nflevg
    blocks = geometry%partition%ngpblks; points = geometry%partition%ngptot
    if (pitch < 1 .or. pitch > 4096 .or. levels < 1 .or. levels > 512) goto100
    if (points < 1 .or. blocks < 1) goto100
    if ((int(points, int64) - 1_int64)/pitch + 1_int64 /= int(blocks, int64)) goto100
    components = size(fields, 3)
    if (components < 1 .or. components > 2048 .or. size(lgp) /= components) goto100
    if (any(shape(fields) /= [pitch, levels, components, blocks])) goto100
    if (.not. is_contiguous(fields)) goto100
    do i = 1, components
      if (.not. lgp(i)) cycle
      if (f == 16) goto100
      f = f + 1; selection(f) = i
    end do
    if (f < 1) goto100
    if (size(result_values, 1) < 4 .or. size(result_values, 2) < f) goto100
    if (canonical_capacity < 32_int64*f + 8_int64) goto100
    if (budget < 1_int64 .or. budget > 2_int64**36) goto100
    required = 8_int64*(int(pitch, int64) + 2_int64)*f*blocks
    if (required > budget) goto100
    if (.not. spectral_norm_environment_supported()) goto100
    local_status = 0
100 continue
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    common = 0
    common(1:f) = selection(1:f) - 1
    common(17) = f; common(18) = levels
    reference = common
    call MPI_Bcast(reference, 18, MPI_INTEGER, 0, comm, error)
    if (error /= MPI_SUCCESS) then
      status = 3
      return
    end if
    local_status = 0
    if (any(common /= reference)) local_status = 2
    call agree_status(comm, local_status, status)
    if (status /= 0) return
    allocate (work(required/8_int64), stat=code)
    local_status = 0
    if (code /= 0) local_status = 1
    call agree_status(comm, local_status, status)
    if (status /= 0) then
      if (allocated(work)) deallocate (work)
      return
    end if
    sum_words = int(pitch, int64)*f*blocks
    block_words = int(f, int64)*blocks
    sums(1:pitch, 1:f, 1:blocks) => work(1:sum_words)
    block_min(1:f, 1:blocks) => work(sum_words + 1:sum_words + block_words)
    block_max(1:f, 1:blocks) => work(sum_words + block_words + 1:sum_words + 2*block_words)
    call form_vertical_sums(fields, selection(1:f), int(points, int32), sums, block_min, block_max, &
                            minimum(1:f), maximum(1:f))
    call gpnorm_trans(sums, int(f, int32), int(pitch, int32), average(1:f), minimum(1:f), maximum(1:f), &
                      .true., geometry%transform_resolution%resolution)
    if (rank == 0) then
      do i = 1, f
        stage(1, i) = average(i)
        stage(2, i) = average(i)/real(levels, real64)
        stage(3, i) = minimum(i)
        stage(4, i) = maximum(i)
      end do
    end if
    nullify (sums, block_min, block_max)
    deallocate (work)
    call agree_status(comm, 0_int32, status)
    if (status /= 0) return
    if (rank == 0) then
      result_values(1:4, 1:f) = stage(1:4, 1:f)
      selected_count = f
    end if
  end subroutine

  subroutine agree_status(comm, local_status, status)
    type(MPI_Comm), intent(in) :: comm
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: status
    integer :: error
    call MPI_Allreduce(local_status, status, 1, MPI_INTEGER, MPI_MAX, comm, error)
    if (error /= MPI_SUCCESS) status = 3
  end subroutine
end module forecast_grid_field_norms
