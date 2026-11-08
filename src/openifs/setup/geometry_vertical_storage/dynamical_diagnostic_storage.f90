!> Own all source work arrays for inactive dynamical tendency diagnostics.
module forecast_dynamical_diagnostic_storage
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_dynamical_diagnostic_controls, native_dynamical_diagnostic_storage
  public :: initialize_dynamical_diagnostic_controls, allocate_dynamical_diagnostic_storage
  public :: release_dynamical_diagnostic_storage
  !> Dimensionless diagnostic switches retain the original SUNDDH names.
  type :: native_dynamical_diagnostic_controls
    logical :: lrddhdyn, lrslddh, lrsiddh, lrhdddh
  end type
  !> Native FP64 owners retain exact ranks and source-unwritten payloads.
  !! First two dimensions are1:1. Grid owners have source field/block bounds.
  type :: native_dynamical_diagnostic_storage
    real(c_double), allocatable :: sptndsi_vor(:, :)
    real(c_double), allocatable :: sptndsi_div(:, :)
    real(c_double), allocatable :: sptndsi_t(:, :)
    real(c_double), allocatable :: sptndsi_spd(:, :)
    real(c_double), allocatable :: sptndsi_svd(:, :)
    real(c_double), allocatable :: sptndhd_vor(:, :)
    real(c_double), allocatable :: sptndhd_div(:, :)
    real(c_double), allocatable :: sptndhd_t(:, :)
    real(c_double), allocatable :: sptndhd_spd(:, :)
    real(c_double), allocatable :: sptndhd_svd(:, :)
    real(c_double), allocatable :: sptndhd_snhx(:, :)
    real(c_double), allocatable :: sptndhd_gfl(:, :, :)
    real(c_double), allocatable :: gmvtndsi_ddh(:, :, :, :)
    real(c_double), allocatable :: gmvtndhd_ddh(:, :, :, :)
    real(c_double), allocatable :: gfltndhd_ddh(:, :, :, :)
    real(c_double), allocatable :: gmvtndsl_ddh(:, :, :, :)
    real(c_double), allocatable :: gfltndsl_ddh(:, :, :, :)
  end type
contains
  !> Admit the actual first empty NAMDDH group before four logical stores.
  integer(c_int) function initialize_dynamical_diagnostic_controls(state, text) result(status)
    type(native_dynamical_diagnostic_controls), intent(inout) :: state
    character(*), intent(in) :: text
    status = require_empty_physics_group(text, 'NAMDDH')
    if (status /= 0) return
    state%lrslddh = .false.; state%lrsiddh = .false.; state%lrhdddh = .false.
    state%lrddhdyn = state%lrslddh .or. state%lrsiddh .or. state%lrhdddh
  end function
  !> Allocate17 owners in source order, then initialize only declared fields.
  !! Counts are dimensionless int32. Inputs describe live producer metadata.
  !! LRDDHDYN is false; LNHDYN/LNHX must be canonical logicals. Success0
  !! transfers all owners. Refusal2 and allocation failure1 preserve STATE.
  integer(c_int) function allocate_dynamical_diagnostic_storage(state, controls, block_count, &
                                                                nfther, numflds, numspflds, ndimsigmv, lnhdyn, lnhx) result(status)
    type(native_dynamical_diagnostic_storage), intent(inout) :: state
    type(native_dynamical_diagnostic_controls), intent(in) :: controls
    integer(c_int), intent(in) :: block_count, nfther, numflds, numspflds, ndimsigmv
    logical, intent(in) :: lnhdyn, lnhx
    type(native_dynamical_diagnostic_storage) :: pending
    integer :: allocation_status
    integer(c_int64_t) :: largest, product
    status = 2
    if (transfer(controls%lrddhdyn, 0_c_int) /= 0) return
    if (.not. canonical_logical(lnhdyn) .or. .not. canonical_logical(lnhx)) return
    if (block_count < 1 .or. ndimsigmv < 1 .or. nfther < 0 .or. nfther > huge(0_c_int) - 2) return
    if (numflds < 0 .or. numspflds < 0) return
    largest = max(int(ndimsigmv, c_int64_t), int(nfther, c_int64_t) + 2_c_int64_t, &
                  int(numflds, c_int64_t), int(max(1, numspflds), c_int64_t))
    product = largest*int(block_count, c_int64_t)
    if (product > huge(0_c_int64_t)/8_c_int64_t) return
    if (allocated(state%sptndsi_vor)) return
    if (allocated(state%sptndsi_div)) return
    if (allocated(state%sptndsi_t)) return
    if (allocated(state%sptndsi_spd)) return
    if (allocated(state%sptndsi_svd)) return
    if (allocated(state%sptndhd_vor)) return
    if (allocated(state%sptndhd_div)) return
    if (allocated(state%sptndhd_t)) return
    if (allocated(state%sptndhd_gfl)) return
    if (allocated(state%sptndhd_spd)) return
    if (allocated(state%sptndhd_svd)) return
    if (allocated(state%sptndhd_snhx)) return
    if (allocated(state%gmvtndsi_ddh)) return
    if (allocated(state%gmvtndhd_ddh)) return
    if (allocated(state%gfltndhd_ddh)) return
    if (allocated(state%gmvtndsl_ddh)) return
    if (allocated(state%gfltndsl_ddh)) return
    allocate (pending%sptndsi_vor(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndsi_div(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndsi_t(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndsi_spd(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndsi_svd(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_vor(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_div(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_t(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_gfl(1, 1, max(1, numspflds)), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_spd(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_svd(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%sptndhd_snhx(1, 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%gmvtndsi_ddh(1, 1, ndimsigmv, block_count), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%gmvtndhd_ddh(1, 1, nfther + 2, block_count), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%gfltndhd_ddh(1, 1, max(1, numspflds), block_count), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%gmvtndsl_ddh(1, 1, nfther + 2, block_count), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%gfltndsl_ddh(1, 1, numflds, block_count), stat=allocation_status)
    if (allocation_status /= 0) goto900
    pending%sptndsi_vor = 0.0_c_double
    pending%sptndsi_div = 0.0_c_double
    if (nfther > 0) pending%sptndsi_t = 0.0_c_double
    if (lnhdyn) pending%sptndsi_spd = 0.0_c_double
    if (lnhdyn) pending%sptndsi_svd = 0.0_c_double
    pending%sptndhd_vor = 0.0_c_double
    pending%sptndhd_div = 0.0_c_double
    if (nfther > 0) pending%sptndhd_t = 0.0_c_double
    pending%sptndhd_gfl = 0.0_c_double
    if (lnhdyn) pending%sptndhd_spd = 0.0_c_double
    if (lnhdyn) pending%sptndhd_svd = 0.0_c_double
    if (lnhx) pending%sptndhd_snhx = 0.0_c_double
    pending%gmvtndsi_ddh = 0.0_c_double
    pending%gmvtndhd_ddh = 0.0_c_double
    pending%gfltndhd_ddh = 0.0_c_double
    pending%gmvtndsl_ddh = 0.0_c_double
    pending%gfltndsl_ddh = 0.0_c_double
    call move_alloc(pending%sptndsi_vor, state%sptndsi_vor)
    call move_alloc(pending%sptndsi_div, state%sptndsi_div)
    call move_alloc(pending%sptndsi_t, state%sptndsi_t)
    call move_alloc(pending%sptndsi_spd, state%sptndsi_spd)
    call move_alloc(pending%sptndsi_svd, state%sptndsi_svd)
    call move_alloc(pending%sptndhd_vor, state%sptndhd_vor)
    call move_alloc(pending%sptndhd_div, state%sptndhd_div)
    call move_alloc(pending%sptndhd_t, state%sptndhd_t)
    call move_alloc(pending%sptndhd_gfl, state%sptndhd_gfl)
    call move_alloc(pending%sptndhd_spd, state%sptndhd_spd)
    call move_alloc(pending%sptndhd_svd, state%sptndhd_svd)
    call move_alloc(pending%sptndhd_snhx, state%sptndhd_snhx)
    call move_alloc(pending%gmvtndsi_ddh, state%gmvtndsi_ddh)
    call move_alloc(pending%gmvtndhd_ddh, state%gmvtndhd_ddh)
    call move_alloc(pending%gfltndhd_ddh, state%gfltndhd_ddh)
    call move_alloc(pending%gmvtndsl_ddh, state%gmvtndsl_ddh)
    call move_alloc(pending%gfltndsl_ddh, state%gfltndsl_ddh)
    status = 0
    return
900 continue
    call release_dynamical_diagnostic_storage(pending)
    status = 1
  end function
  !> Release the17 owned arrays in reverse source order; repetition is valid.
  subroutine release_dynamical_diagnostic_storage(state)
    type(native_dynamical_diagnostic_storage), intent(inout) :: state
    real(c_double), allocatable :: detached2(:, :), detached3(:, :, :), detached4(:, :, :, :)
    if (allocated(state%gfltndsl_ddh)) then
      call move_alloc(state%gfltndsl_ddh, detached4)
      deallocate (detached4)
    end if
    if (allocated(state%gmvtndsl_ddh)) then
      call move_alloc(state%gmvtndsl_ddh, detached4)
      deallocate (detached4)
    end if
    if (allocated(state%gfltndhd_ddh)) then
      call move_alloc(state%gfltndhd_ddh, detached4)
      deallocate (detached4)
    end if
    if (allocated(state%gmvtndhd_ddh)) then
      call move_alloc(state%gmvtndhd_ddh, detached4)
      deallocate (detached4)
    end if
    if (allocated(state%gmvtndsi_ddh)) then
      call move_alloc(state%gmvtndsi_ddh, detached4)
      deallocate (detached4)
    end if
    if (allocated(state%sptndhd_snhx)) then
      call move_alloc(state%sptndhd_snhx, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndhd_svd)) then
      call move_alloc(state%sptndhd_svd, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndhd_spd)) then
      call move_alloc(state%sptndhd_spd, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndhd_gfl)) then
      call move_alloc(state%sptndhd_gfl, detached3)
      deallocate (detached3)
    end if
    if (allocated(state%sptndhd_t)) then
      call move_alloc(state%sptndhd_t, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndhd_div)) then
      call move_alloc(state%sptndhd_div, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndhd_vor)) then
      call move_alloc(state%sptndhd_vor, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndsi_svd)) then
      call move_alloc(state%sptndsi_svd, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndsi_spd)) then
      call move_alloc(state%sptndsi_spd, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndsi_t)) then
      call move_alloc(state%sptndsi_t, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndsi_div)) then
      call move_alloc(state%sptndsi_div, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%sptndsi_vor)) then
      call move_alloc(state%sptndsi_vor, detached2)
      deallocate (detached2)
    end if
  end subroutine
  pure logical function canonical_logical(value) result(valid)
    logical, intent(in) :: value
    integer(c_int) :: bits
    bits = transfer(value, bits)
    valid = bits == 0 .or. bits == 1
  end function
end module forecast_dynamical_diagnostic_storage
