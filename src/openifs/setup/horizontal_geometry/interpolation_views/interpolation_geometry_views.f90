!> Borrow the canonical geometry maps needed by native SLCSET.
module forecast_interpolation_geometry_views
  use iso_fortran_env, only: int32
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_interpolation_local_maps, only: native_interpolation_grid_parameters
  implicit none
  private
  public :: native_interpolation_map_views, make_native_interpolation_grid_parameters
  public :: borrow_native_interpolation_map_views, clear_native_interpolation_map_views
  !> Borrow complete int32 owners without allocating or copying map entries.
  !! KSTA and KONL retain their actual two-dimensional bounds, starting at
  !! (-1,1). KLOENG retains -1:NDGLG+2. The three region lists start at 1.
  !! KASET and KBSET are the actual north-south and east-west region indices
  !! from TRANS_INQ, held by the canonical partition. They are not spectral
  !! groups or process-factor indices. All values are dimensionless.
  !! Callers treat targets as read only. The geometry owner is TARGET and
  !! stays at a stable address until every borrowed view has been cleared.
  type :: native_interpolation_map_views
    integer(int32), pointer, contiguous :: ksta(:, :) => null(), konl(:, :) => null()
    integer(int32), pointer, contiguous :: kloeng(:) => null(), kptrfrstlat(:) => null()
    integer(int32), pointer, contiguous :: kfrstlat(:) => null(), klstlat(:) => null()
    integer(int32) :: kaset = 0, kbset = 0
  end type
contains
  !> Check native producer completion and the complete source-declared extents.
  !! This checks storage needed for borrowing, without scanning numerical maps
  !! or replacing the consuming SLCSET child's own input admission.
  logical function geometry_maps_admitted(geometry) result(admitted)
    type(native_geometry_state), intent(in) :: geometry
    integer :: n, ns, ew, a, b, last
    admitted = .false.
    if (.not. geometry%initialized .or. geometry%partition%phase /= 7) return
    if (.not. geometry%transform_control%message_ready) return
    if (.not. geometry%transform_control%environment_ready) return
    n = geometry%dimensions%ndglg
    ns = geometry%transform_control%regions_ns
    ew = geometry%transform_control%regions_ew
    if (n < 2 .or. n > 8192) return
    if (ns < 1 .or. ns > 32 .or. ew < 1 .or. ew > 32) return
    if (geometry%dimensions%ndgsag /= -1 .or. geometry%dimensions%ndgeng /= n + 2) return
    if (.not. allocated(geometry%transform_control%n_regions)) return
    if (lbound(geometry%transform_control%n_regions, 1) /= 1) return
    if (size(geometry%transform_control%n_regions) /= ns) return
    a = geometry%partition%my_region_ns
    b = geometry%partition%my_region_ew
    if (a < 1 .or. a > ns .or. b < 1 .or. b > ew) return
    if (b > geometry%transform_control%n_regions(a)) return
    if (.not. allocated(geometry%partition%nsta)) return
    if (.not. allocated(geometry%partition%nonl)) return
    last = geometry%dimensions%ndgeng + ns - 1
    if (any(lbound(geometry%partition%nsta) /= [-1, 1])) return
    if (any(lbound(geometry%partition%nonl) /= [-1, 1])) return
    if (any(ubound(geometry%partition%nsta) /= [last, ew])) return
    if (any(ubound(geometry%partition%nonl) /= [last, ew])) return
    if (.not. allocated(geometry%configuration%nloeng)) return
    if (lbound(geometry%configuration%nloeng, 1) /= -1) return
    if (ubound(geometry%configuration%nloeng, 1) /= n + 2) return
    if (.not. allocated(geometry%partition%nptrfrstlat)) return
    if (.not. allocated(geometry%partition%nfrstlat)) return
    if (.not. allocated(geometry%partition%nlstlat)) return
    if (lbound(geometry%partition%nptrfrstlat, 1) /= 1) return
    if (lbound(geometry%partition%nfrstlat, 1) /= 1) return
    if (lbound(geometry%partition%nlstlat, 1) /= 1) return
    if (size(geometry%partition%nptrfrstlat) /= ns) return
    if (size(geometry%partition%nfrstlat) /= ns) return
    if (size(geometry%partition%nlstlat) /= ns) return
    admitted = .true.
  end function

  !> Project all twenty named SLCSET grid inputs from their actual producers.
  !! geometry is read only. Global and stencil dimensions come from SUDIM;
  !! local physical rows, points and offsets come from the actual partition.
  !! No field is inferred from the horizontal or vertical process split.
  !! Status 0 publishes all fields. Status 2 leaves output unchanged.
  integer(int32) function make_native_interpolation_grid_parameters(geometry, output) result(status)
    type(native_geometry_state), intent(in) :: geometry
    type(native_interpolation_grid_parameters), intent(inout) :: output
    type(native_interpolation_grid_parameters) :: pending
    status = 2
    if (.not. geometry_maps_admitted(geometry)) return
    pending%ndglg = geometry%dimensions%ndglg
    pending%ndlon = geometry%dimensions%ndlon
    pending%ndgsag = geometry%dimensions%ndgsag
    pending%ndgeng = geometry%dimensions%ndgeng
    pending%ndgsal = geometry%partition%ndgsal
    pending%ndgenl = geometry%partition%ndgenl
    pending%ngptot = geometry%partition%ngptot
    pending%ndguxl = geometry%partition%ndguxl
    pending%ndlung = geometry%dimensions%ndlung
    pending%ndluxg = geometry%dimensions%ndluxg
    pending%ndgung = geometry%dimensions%ndgung
    pending%ndguxg = geometry%dimensions%ndguxg
    pending%ndsur1 = geometry%dimensions%ndsur1
    pending%ndlsur = geometry%dimensions%ndlsur
    pending%nptrfloff = geometry%partition%nptrfloff
    pending%nfrstloff = geometry%partition%nfrstloff
    pending%myfrstactlat = geometry%partition%myfrstactlat
    pending%mylstactlat = geometry%partition%mylstactlat
    pending%nstencilwide = geometry%dimensions%nstencilwide
    pending%ndgsur = geometry%dimensions%ndgsur
    output = pending
    status = 0
  end function

  !> Associate full native maps with their actual lower and upper bounds.
  !! geometry is a stable TARGET, kept live by its caller. views owns no target
  !! memory. Assignment replaces only its pointer associations and two indices.
  !! No map element is read, copied or changed. Status 2 preserves all views.
  integer(int32) function borrow_native_interpolation_map_views(geometry, views) result(status)
    type(native_geometry_state), target, intent(in) :: geometry
    type(native_interpolation_map_views), intent(inout) :: views
    type(native_interpolation_map_views) :: pending
    status = 2
    if (.not. geometry_maps_admitted(geometry)) return
    pending%ksta(lbound(geometry%partition%nsta, 1):, lbound(geometry%partition%nsta, 2):) &
      => geometry%partition%nsta
    pending%konl(lbound(geometry%partition%nonl, 1):, lbound(geometry%partition%nonl, 2):) &
      => geometry%partition%nonl
    pending%kloeng(lbound(geometry%configuration%nloeng, 1):) => geometry%configuration%nloeng
    pending%kptrfrstlat(lbound(geometry%partition%nptrfrstlat, 1):) => geometry%partition%nptrfrstlat
    pending%kfrstlat(lbound(geometry%partition%nfrstlat, 1):) => geometry%partition%nfrstlat
    pending%klstlat(lbound(geometry%partition%nlstlat, 1):) => geometry%partition%nlstlat
    pending%kaset = geometry%partition%my_region_ns
    pending%kbset = geometry%partition%my_region_ew
    views = pending
    status = 0
  end function

  !> End borrowing without freeing or changing any geometry owner.
  subroutine clear_native_interpolation_map_views(views)
    type(native_interpolation_map_views), intent(inout) :: views
    nullify (views%ksta, views%konl, views%kloeng, views%kptrfrstlat, views%kfrstlat, views%klstlat)
    views%kaset = 0
    views%kbset = 0
  end subroutine
end module forecast_interpolation_geometry_views
