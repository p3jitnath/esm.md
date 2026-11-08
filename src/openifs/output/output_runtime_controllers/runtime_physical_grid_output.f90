!> Own the complete runtime physical-output buffer and preserve the source block call order.
module forecast_runtime_physical_grid_output
  use iso_fortran_env, only: int32, int64, real64
  use forecast_runtime_physical_output_block, only: native_physical_output_controls, admit_physical_output_controls, &
                                                    physical_output_block_workspace_bytes
  use forecast_runtime_physical_output_scan, only: scan_physical_output_block
  use forecast_output_request_types, only: trqfp
  use forecast_fullpos_state_types, only: native_fullpos_state
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use forecast_orography_storage, only: native_orography_storage
  use forecast_distributed_partition_types, only: native_distributed_partition
  implicit none
  private
  public :: native_physical_output_buffer, calculate_runtime_physical_grid_output, release_physical_output_buffer
  type :: native_physical_output_buffer
    real(real64), pointer :: values(:, :, :) => null()
    logical :: owns_memory = .false.
  end type
  interface
    subroutine gstats(event, switch)
      import :: int32
      integer(int32), intent(in) :: event, switch
    end subroutine
  end interface
contains
  !> Calculate every local block and publish its owner only after complete success.
  !! controls derives dimensions and physical flags from the actual root owners.
  !! partition is the canonical live phase7 owner and terrain owns its real final extent.
  !! Optional p2fields(width,fields,blocks) or p3fields(width,levels,fields,blocks) stays caller-owned.
  !! A source failure can leave an optional external buffer partially written.
  !! Status0 succeeds,1 refuses allocation,2 refuses metadata and3 reports a progressed child failure.
  integer(int32) function calculate_runtime_physical_grid_output(request, fullpos, state, registry, terrain, &
                                   partition, configuration, controls, buffer, p2fields, p3fields, p3levels, p3count) result(status)
    type(trqfp), intent(in) :: request
    type(native_fullpos_state), intent(in) :: fullpos
    type(surface_field_state), target, intent(in) :: state
    type(surface_field_registry), target, intent(in) :: registry
    type(native_orography_storage), target, intent(in) :: terrain
    type(native_distributed_partition), intent(in) :: partition
    character(1), intent(in) :: configuration
    type(native_physical_output_controls), intent(in) :: controls
    type(native_physical_output_buffer), intent(inout) :: buffer
    real(real64), target, intent(inout), optional :: p2fields(:, :, :), p3fields(:, :, :, :)
    integer(int32), intent(in), optional :: p3levels, p3count
    real(real64), pointer :: candidate(:, :, :)
    real(real64), pointer, contiguous :: p3_contiguous(:, :, :, :)
    integer :: width, fields, blocks, block, active, ierr, domain
    integer(int64) :: bytes, workspace
    integer(int32) :: child
    logical :: owned, started
    status = 2
    nullify (candidate)
    owned = .false.
    started = .false.
    if (admit_physical_output_controls(controls) /= 0) return
    if (associated(buffer%values) .or. buffer%owns_memory) return
    if (configuration == 'S' .or. fullpos%ynamfpsci%nfpcli /= 0) return
    if (partition%phase /= 7 .or. partition%ngptot /= controls%local_points) return
    width = controls%block_width
    fields = request%nfieldg
    blocks = int((int(controls%local_points, int64) + width - 1_int64)/width)
    if (fields < 1 .or. fields > 1639 .or. partition%ngpblks /= blocks) return
    if (fullpos%yfpgeometry%lfposhor) return
    if (fullpos%yfpgeometry%yfpgeo%nfproma /= width .or. fullpos%yfpgeometry%yfpgeo%nfpblocs /= blocks) return
    if (.not. allocated(fullpos%yfpgeometry%yfpusergeo)) return
    if (size(fullpos%yfpgeometry%yfpusergeo) < 1 .or. size(fullpos%yfpgeometry%yfpusergeo) > 8) return
    do domain = lbound(fullpos%yfpgeometry%yfpusergeo, 1), ubound(fullpos%yfpgeometry%yfpusergeo, 1)
      if (fullpos%yfpgeometry%yfpusergeo(domain)%lfpmapf) return
    end do
    if (.not. allocated(terrain%blocks)) return
    if (size(terrain%blocks) /= blocks .or. lbound(terrain%blocks, 1) /= 1) return
    do block = 1, blocks
      active = min(width, controls%local_points - (block - 1)*width)
      if (.not. allocated(terrain%blocks(block)%orog)) return
      if (size(terrain%blocks(block)%orog) < active) return
    end do
    bytes = 8_int64*width*fields*blocks
    ! Reserve the same native leaf plan together with the live full output owner.
    workspace = physical_output_block_workspace_bytes(fields, width, controls%snow_layers) + 3072_int64 + bytes
    if (workspace > controls%budget_bytes) return
    if (present(p2fields)) then
      if (any(shape(p2fields) /= [width, fields, blocks]) .or. .not. is_contiguous(p2fields)) return
      candidate => p2fields
    else if (present(p3fields)) then
      if (.not. present(p3levels) .or. .not. present(p3count)) return
      if (p3levels < 1 .or. p3count < 1) return
      if (int(p3levels, int64)*p3count /= fields) return
      if (any(shape(p3fields) /= [width, p3levels, p3count, blocks]) .or. .not. is_contiguous(p3fields)) return
      p3_contiguous => p3fields
      candidate(1:width, 1:fields, 1:blocks) => p3_contiguous
    else
      allocate (candidate(width, fields, blocks), stat=ierr)
      if (ierr /= 0) then
        status = 1
        return
      end if
      owned = .true.
    end if
    call gstats(1434_int32, 0_int32)
    started = .true.
    do block = 1, blocks
      active = min(width, controls%local_points - (block - 1)*width)
      child = scan_physical_output_block(request, fullpos%ynamfpsci, fullpos%yafn, .false., state, registry, &
                                  terrain%blocks(block)%orog, block, active, configuration == 'P', controls, candidate(:, :, block))
      if (child /= 0) then
        status = 3
        goto 900
      end if
    end do
    call gstats(1434_int32, 1_int32)
    started = .false.
    call gstats(1911_int32, 0_int32)
    call gstats(1911_int32, 1_int32)
    buffer%values => candidate
    buffer%owns_memory = owned
    status = 0
    return
900 continue
    if (started) call gstats(1434_int32, 1_int32)
    if (owned .and. associated(candidate)) deallocate (candidate)
  end function
  !> Release only an allocation owned by this output object; expire borrowed views first.
  subroutine release_physical_output_buffer(buffer)
    type(native_physical_output_buffer), intent(inout) :: buffer
    if (buffer%owns_memory .and. associated(buffer%values)) deallocate (buffer%values)
    nullify (buffer%values)
    buffer%owns_memory = .false.
  end subroutine
end module forecast_runtime_physical_grid_output
