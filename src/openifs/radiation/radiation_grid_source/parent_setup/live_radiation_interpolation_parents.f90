!> Construct and release the two live radiation interpolation exchanges.
!! RI maps model values into the radiation grid; RO maps values back. This
!! module owns their ordered setup and reports, not a numerical callback.
!! Callers retain all TARGET records and borrowed map owners through release.
module forecast_live_radiation_interpolation
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_radiation_interpolation_context, only: native_radiation_main_grid_view
  use forecast_live_radiation_halo, only: create_live_radiation_halo_setup, release_live_radiation_halo_setup, &
                                          validate_live_radiation_halo_setup
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_interpolation_local_maps, only: native_interpolation_grid_parameters
  use forecast_interpolation_buffer_setup, only: initialize_distributed_interpolation_buffer, &
                                                 release_distributed_interpolation_buffer, interpolation_global_halo_capacity
  use forecast_interpolation_reporting, only: write_distributed_halo_status
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status, abort_distributed_partition
  implicit none
  private
  public :: native_radiation_interpolation_lifetime
  public :: create_live_radiation_first_interpolation, release_live_radiation_first_interpolation
  public :: create_live_radiation_second_interpolation, release_live_radiation_second_interpolation
  !> Track the actual typed owners that replaced the old ownership sidecar.
 !! Phase0 is fresh,1 includes RI and2 includes both RI and RO. This record
 !! borrows identities only; it contains no duplicated field or geometry.
  type :: native_radiation_interpolation_lifetime
    integer(int32) :: phase = 0
    type(native_radiation_transform_storage), pointer :: storage => null()
    type(native_radiation_grid), pointer :: grid => null()
    type(native_interpolation_state), pointer :: ri => null(), ro => null()
  end type
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Agree only additional integer admission, preserving incoming FP and errno.
  integer(int32) function agree_control(control, local_status) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: incoming
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: old_errno
    call c_f_pointer(errno_address(), error_number)
    old_errno = error_number; call ieee_get_status(incoming)
    status = agree_distributed_partition_status(control, local_status)
    call ieee_set_status(incoming); error_number = old_errno
  end function
  !> Test only the fourteen arrays owned by RI or RO, preserving other owners.
  logical function fresh_maps(state) result(fresh)
    type(native_interpolation_state), intent(in) :: state
    fresh = .false.
    if (allocated(state%nloeng)) return
    if (allocated(state%nslsta)) return
    if (allocated(state%nslonl)) return
    if (allocated(state%nsloff)) return
    if (allocated(state%nslcore)) return
    if (allocated(state%nslext)) return
    if (allocated(state%mask_sl1)) return
    if (allocated(state%mask_sl2)) return
    if (allocated(state%mask_sld)) return
    if (allocated(state%nslsendpos)) return
    if (allocated(state%nslrecvpos)) return
    if (allocated(state%nslsendptr)) return
    if (allocated(state%nslrecvptr)) return
    if (allocated(state%nslcomm)) return
    fresh = .true.
  end function
  !> Confirm complete native owners before a collective release.
 !! Fortran allocatable owners cannot overlap each other through normal
 !! typed construction. Foreign arrays that this stage does not own remain.
  logical function complete_maps(state) result(complete)
    type(native_interpolation_state), intent(in) :: state
    complete = .false.
    if (.not. allocated(state%nloeng)) return
    if (.not. allocated(state%nslsta)) return
    if (.not. allocated(state%nslonl)) return
    if (.not. allocated(state%nsloff)) return
    if (.not. allocated(state%nslcore)) return
    if (.not. allocated(state%nslext)) return
    if (.not. allocated(state%mask_sl1)) return
    if (.not. allocated(state%mask_sl2)) return
    if (.not. allocated(state%mask_sld)) return
    if (.not. allocated(state%nslsendpos)) return
    if (.not. allocated(state%nslrecvpos)) return
    if (.not. allocated(state%nslsendptr)) return
    if (.not. allocated(state%nslrecvptr)) return
    if (.not. allocated(state%nslcomm)) return
    if (state%ndglg < 2 .or. state%ndglg > 8192 .or. mod(state%ndglg, 2) /= 0) return
    if (state%ndlon < 1 .or. state%ndlon > 32768) return
    if (state%ndgenl < 1 .or. state%ndgenl > state%ndglg) return
    if (state%ngptot < 1 .or. state%ngptot > 268435456) return
    if (state%naslb1 < 1 .or. state%naslb1 > 268435456) return
    if (min(state%nslwiden, state%nslwides, state%nslwidew, state%nslwidee) < 0) return
    if (max(state%nslwiden, state%nslwides, state%nslwidew, state%nslwidee) > 63) return
    if (lbound(state%nloeng, 1) /= -1 .or. ubound(state%nloeng, 1) /= state%ndglg + 2) return
    if (lbound(state%nslsta, 1) /= 1 - state%nslwiden) return
    if (ubound(state%nslsta, 1) /= state%ndgenl + state%nslwides) return
    if (lbound(state%nslonl, 1) /= lbound(state%nslsta, 1)) return
    if (ubound(state%nslonl, 1) /= ubound(state%nslsta, 1)) return
    if (lbound(state%nsloff, 1) /= lbound(state%nslsta, 1)) return
    if (ubound(state%nsloff, 1) /= ubound(state%nslsta, 1)) return
    if (lbound(state%nslext, 1) /= 1 - state%ndlon .or. ubound(state%nslext, 1) /= 2*state%ndlon) return
    if (lbound(state%nslext, 2) /= lbound(state%nslsta, 1)) return
    if (ubound(state%nslext, 2) /= ubound(state%nslsta, 1)) return
    if (state%nslprocs < 0 .or. state%nslprocs > 65536) return
    if (state%nslrpt < 0 .or. state%nslspt < 0) return
    if (size(state%nslcomm) /= state%nslprocs) return
    if (size(state%nslsendptr) /= state%nslprocs + 1) return
    if (size(state%nslrecvptr) /= state%nslprocs + 1) return
    if (size(state%nslsendpos) /= state%nslspt) return
    if (size(state%nslrecvpos) /= state%nslrpt) return
    if (size(state%nslcore) /= state%ngptot) return
    if (size(state%nloeng) /= state%ndglg + 4) return
    if (size(state%nslsta) /= size(state%nslonl)) return
    if (size(state%nslsta) /= size(state%nsloff)) return
    if (size(state%mask_sl1) /= state%naslb1 + 4) return
    if (size(state%mask_sl2) /= state%naslb1 + 4) return
    if (size(state%mask_sld) /= state%naslb1 + 4) return
    complete = .true.
  end function
  !> Check borrowed actual main-grid views before any dependent reader.
  integer(int32) function admit_main(main, control) result(status)
    type(native_radiation_main_grid_view), intent(in) :: main
    type(native_transform_control), intent(in) :: control
    status = 2
    if (.not. control%message_ready) return
    if (.not. associated(main%row_lengths)) return
    if (.not. associated(main%starts)) return
    if (.not. associated(main%counts)) return
    if (.not. associated(main%first_point)) return
    if (.not. associated(main%first_latitude)) return
    if (.not. associated(main%last_latitude)) return
    if (.not. associated(main%process_ids)) return
    if (.not. associated(main%latitude)) return
    if (.not. associated(main%longitude)) return
    if (main%communication_budget < 1_int64) return
    if (main%report_unit /= 6) return
    if (lbound(main%row_lengths, 1) /= -1) return
    if (lbound(main%starts, 1) /= -1 .or. lbound(main%counts, 1) /= -1) return
    if (main%grid%ngptot < 1) return
    if (size(main%latitude) < main%grid%ngptot .or. size(main%longitude) < main%grid%ngptot) return
    if (size(main%process_ids) /= control%nproc) return
    if (main%grid%nstencilwide /= 2) return
    status = 0
  end function
  !> Continue genuine point/halo setup through the first SLCSET exchange.
 !! Radiation row lengths retain bounds(-1:N+2). EXTREMA stores eight degrees
 !! in radiation then main order. Actual RI/RO/G/ STORAGE objects are distinct
 !! stable TARGET owners, initially without this stage's allocated arrays.
 !! Control and partition refer to one live public communicator and geometry.
 !! Status0 publishes RI;1 is allocation failure;2 refuses unsupported input.
 !! A failed enclosing create releases its new owners and restores scalar
 !! records and extrema. Source reports already written remain observable.
  integer(int32) function create_live_radiation_first_interpolation(life, storage, g, &
                   radiation_row_lengths, main, ri, ro, control, partition, physical, nradint, nstencilwide, extrema) result(status)
    type(native_radiation_interpolation_lifetime), intent(inout) :: life
    type(native_radiation_transform_storage), target, intent(inout) :: storage
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: radiation_row_lengths(-1:)
    type(native_radiation_main_grid_view), intent(in) :: main
    type(native_interpolation_state), target, intent(inout) :: ri, ro
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint, nstencilwide
    real(real64), intent(inout) :: extrema(8)
    type(native_interpolation_state) :: old_ri, old_ro
    type(native_radiation_grid) :: old_g
    real(real64) :: old_extrema(8)
    integer(int32) :: local, child, ignored
    integer(int64) :: capacity
    status = 2
    if (.not. control%message_ready) return
    local = admit_main(main, control)
    if (.not. is_contiguous(radiation_row_lengths)) local = 2
    if (life%phase /= 0) local = 2
    if (associated(life%storage) .or. associated(life%grid) .or. associated(life%ri) .or. associated(life%ro)) local = 2
    if (.not. fresh_maps(ri) .or. .not. fresh_maps(ro)) local = 2
    status = agree_control(control, local); if (status /= 0) return
    call copy_scalars(ri, old_ri); call copy_scalars(ro, old_ro)
    call copy_grid_scalars(g, old_g); old_extrema = extrema
    status = create_live_radiation_halo_setup(storage, g, radiation_row_lengths, main, ri, ro, &
                                              control, partition, physical, nradint, nstencilwide, extrema)
    if (status /= 0) return
    ri%cver = 'RI'
    capacity = interpolation_global_halo_capacity(main%row_lengths, main%grid%ndglg)
    status = initialize_distributed_interpolation_buffer(ri, main%grid, main%starts, main%counts, &
                                                      main%row_lengths, main%first_point, main%first_latitude, main%last_latitude, &
                                              partition%my_region_ns, partition%my_region_ew, main%process_ids, control, capacity, &
                                                         main%communication_budget, main%report_unit, child)
    if (status /= 0) then
      ignored = release_distributed_interpolation_buffer(ri)
      ignored = release_live_radiation_halo_setup(storage, g, control)
      if (ignored /= 0) call abort_distributed_partition()
      call copy_scalars(old_ri, ri); call copy_scalars(old_ro, ro)
      call copy_grid_scalars(old_g, g); extrema = old_extrema
      return
    end if
    life%storage => storage; life%grid => g; life%ri => ri; life%ro => ro; life%phase = 1
  end function
  !> Release complete RI maps, then all preceding halo/point/storage owners.
 !! Refused ownership/phase checks leave all records and owners unchanged.
  integer(int32) function release_live_radiation_first_interpolation(life, storage, g, ri, control) result(status)
    type(native_radiation_interpolation_lifetime), intent(inout) :: life
    type(native_radiation_transform_storage), target, intent(inout) :: storage
    type(native_radiation_grid), target, intent(inout) :: g
    type(native_interpolation_state), target, intent(inout) :: ri
    type(native_transform_control), intent(in) :: control
    integer(int32) :: local, ignored
    status = 2; if (.not. control%message_ready) return
    local = 0
    if (life%phase /= 1) local = 2
    if (.not. associated(life%storage, storage)) local = 2
    if (.not. associated(life%grid, g)) local = 2
    if (.not. associated(life%ri, ri)) local = 2
    if (.not. complete_maps(ri)) local = 2
    if (ri%cver /= 'RI') local = 2
    if (storage%state /= 5) local = 2
    status = agree_control(control, local); if (status /= 0) return
    status = validate_live_radiation_halo_setup(storage, g, control); if (status /= 0) return
    ignored = release_distributed_interpolation_buffer(ri)
    status = release_live_radiation_halo_setup(storage, g, control)
    if (status /= 0) call abort_distributed_partition()
    life%phase = 0; nullify (life%storage, life%grid, life%ri, life%ro)
  end function
  !> Continue RI through its outer report, genuine RO setup and RO report.
 !! The selected complete call uses equal main/radiation stencil2 and unit6.
 !! The native local map and communication bodies consume actual radiation
 !! dimensions and maps. No model byte layout or caller callback supplies RO.
  integer(int32) function create_live_radiation_second_interpolation(life, storage, g, &
                   radiation_row_lengths, main, ri, ro, control, partition, physical, nradint, nstencilwide, extrema) result(status)
    type(native_radiation_interpolation_lifetime), intent(inout) :: life
    type(native_radiation_transform_storage), target, intent(inout) :: storage
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: radiation_row_lengths(-1:)
    type(native_radiation_main_grid_view), intent(in) :: main
    type(native_interpolation_state), target, intent(inout) :: ri, ro
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint, nstencilwide
    real(real64), intent(inout) :: extrema(8)
    type(native_interpolation_state) :: old_ri, old_ro
    type(native_radiation_grid) :: old_g
    type(native_interpolation_grid_parameters) :: rad
    real(real64) :: old_extrema(8)
    integer(int32) :: local, child, ignored
    integer(int64) :: capacity
    status = 2; if (.not. control%message_ready) return
    local = 0
    if (nstencilwide /= 2 .or. main%grid%nstencilwide /= nstencilwide) local = 2
    if (.not. is_contiguous(radiation_row_lengths)) local = 2
    if (main%report_unit /= 6) local = 2
    status = agree_control(control, local); if (status /= 0) return
    call copy_scalars(ri, old_ri); call copy_scalars(ro, old_ro)
    call copy_grid_scalars(g, old_g); old_extrema = extrema
    status = create_live_radiation_first_interpolation(life, storage, g, radiation_row_lengths, main, &
                                                       ri, ro, control, partition, physical, nradint, nstencilwide, extrema)
    if (status /= 0) return
    ignored = write_distributed_halo_status(ri, main%report_unit)
    if (ignored /= 0) call abort_distributed_partition()
    ro%cver = 'RO'
    call bind_radiation_grid(g, nstencilwide, rad)
    capacity = interpolation_global_halo_capacity(storage%row_lengths, rad%ndglg)
    status = initialize_distributed_interpolation_buffer(ro, rad, storage%nsta, storage%nonl, &
                                                      storage%row_lengths, storage%nptrfrstlat, storage%nfrstlat, storage%nlstlat, &
                                              partition%my_region_ns, partition%my_region_ew, main%process_ids, control, capacity, &
                                                         main%communication_budget, main%report_unit, child)
    if (status /= 0) then
      ignored = release_distributed_interpolation_buffer(ro)
      ignored = release_live_radiation_first_interpolation(life, storage, g, ri, control)
      if (ignored /= 0) call abort_distributed_partition()
      call copy_scalars(old_ri, ri); call copy_scalars(old_ro, ro)
      call copy_grid_scalars(old_g, g); extrema = old_extrema
      return
    end if
    ignored = write_distributed_halo_status(ro, main%report_unit)
    if (ignored /= 0) call abort_distributed_partition()
    life%phase = 2
  end function
  !> Release RO first and then the complete preceding RI/halo state.
  integer(int32) function release_live_radiation_second_interpolation(life, storage, g, ri, ro, control) result(status)
    type(native_radiation_interpolation_lifetime), intent(inout) :: life
    type(native_radiation_transform_storage), target, intent(inout) :: storage
    type(native_radiation_grid), target, intent(inout) :: g
    type(native_interpolation_state), target, intent(inout) :: ri, ro
    type(native_transform_control), intent(in) :: control
    integer(int32) :: local, ignored
    status = 2; if (.not. control%message_ready) return
    local = 0
    if (life%phase /= 2) local = 2
    if (.not. associated(life%storage, storage)) local = 2
    if (.not. associated(life%grid, g)) local = 2
    if (.not. associated(life%ri, ri)) local = 2
    if (.not. associated(life%ro, ro)) local = 2
    if (.not. complete_maps(ri) .or. .not. complete_maps(ro)) local = 2
    if (ri%cver /= 'RI' .or. ro%cver /= 'RO') local = 2
    if (storage%state /= 5) local = 2
    status = agree_control(control, local); if (status /= 0) return
    status = validate_live_radiation_halo_setup(storage, g, control); if (status /= 0) return
    ignored = release_distributed_interpolation_buffer(ro)
    life%phase = 1
    status = release_live_radiation_first_interpolation(life, storage, g, ri, control)
    if (status /= 0) call abort_distributed_partition()
  end function
  !> Bind the actual radiation-grid counts for the unchanged generic RO child.
  subroutine bind_radiation_grid(g, nstencilwide, rad)
    type(native_radiation_grid), intent(in) :: g
    integer(int32), intent(in) :: nstencilwide
    type(native_interpolation_grid_parameters), intent(out) :: rad
    rad%ndglg = g%ndglg; rad%ndlon = g%ndlon
    rad%ndgsag = -1; rad%ndgeng = g%ndglg + 2; rad%ndgsal = g%ndgsal; rad%ndgenl = g%ndgenl
    rad%ngptot = g%ngptot; rad%ndguxl = 0; rad%ndlung = 1
    rad%ndluxg = 0; rad%ndgung = 0; rad%ndguxg = 0
    rad%ndsur1 = 3; rad%ndlsur = g%ndlon + 3
    rad%nptrfloff = g%ndgsl; rad%nfrstloff = g%nfrstloff
    rad%myfrstactlat = g%myfrstlat; rad%mylstactlat = g%mylstlat
    rad%nstencilwide = nstencilwide; rad%ndgsur = 2
  end subroutine
  !> Copy scalar preimages only, without copying or allocating array owners.
  subroutine copy_scalars(source, destination)
    type(native_interpolation_state), intent(in) :: source
    type(native_interpolation_state), intent(inout) :: destination
    destination%CVER = source%CVER
    destination%NSLGROUP = source%NSLGROUP
    destination%NASLB1 = source%NASLB1
    destination%NASLB1_TRUE = source%NASLB1_TRUE
    destination%NSLPAD = source%NSLPAD
    destination%LSLT_ARRAYS_INIT = source%LSLT_ARRAYS_INIT
    destination%LSLONDEM = source%LSLONDEM
    destination%LSLONDEM_ACTIVE = source%LSLONDEM_ACTIVE
    destination%NUNUSEDHALO = source%NUNUSEDHALO
    destination%DISTUNUSEDHALO = source%DISTUNUSEDHALO
    destination%NSLPROCS = source%NSLPROCS
    destination%NSLRPT = source%NSLRPT
    destination%NSLSPT = source%NSLSPT
    destination%NSLWIDEN = source%NSLWIDEN
    destination%NSLWIDES = source%NSLWIDES
    destination%NSLWIDEE = source%NSLWIDEE
    destination%NSLWIDEW = source%NSLWIDEW
    destination%NSLWIDE = source%NSLWIDE
    destination%NDGLG = source%NDGLG
    destination%NDLON = source%NDLON
    destination%NDGSAG = source%NDGSAG
    destination%NDGENG = source%NDGENG
    destination%NDGSAL = source%NDGSAL
    destination%NDGENL = source%NDGENL
    destination%NDGSAH = source%NDGSAH
    destination%NDGENH = source%NDGENH
    destination%NGPTOT = source%NGPTOT
    destination%NDGUXL = source%NDGUXL
    destination%NDLUNG = source%NDLUNG
    destination%NDLUXG = source%NDLUXG
    destination%NDGUNG = source%NDGUNG
    destination%NDGUXG = source%NDGUXG
    destination%NDSUR1 = source%NDSUR1
    destination%NDLSUR = source%NDLSUR
    destination%NDGSUR = source%NDGSUR
    destination%NPTRFLOFF = source%NPTRFLOFF
    destination%NFRSTLOFF = source%NFRSTLOFF
    destination%MYFRSTACTLAT = source%MYFRSTACTLAT
    destination%MYLSTACTLAT = source%MYLSTACTLAT
  end subroutine
  subroutine copy_grid_scalars(source, destination)
    type(native_radiation_grid), intent(in) :: source
    type(native_radiation_grid), intent(inout) :: destination
    destination%ndglg = source%ndglg
    destination%ndlon = source%ndlon
    destination%nsmax = source%nsmax
    destination%ngptot = source%ngptot
    destination%nfrstloff = source%nfrstloff
    destination%ndgsl = source%ndgsl
    destination%ndgsah = source%ndgsah
    destination%ndgenh = source%ndgenh
    destination%ndgsal = source%ndgsal
    destination%ndgenl = source%ndgenl
    destination%ndlonh = source%ndlonh
    destination%ndlonm = source%ndlonm
    destination%myfrstlat = source%myfrstlat
    destination%mylstlat = source%mylstlat
  end subroutine
end module
