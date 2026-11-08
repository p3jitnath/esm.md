!> Compose complete native spherical point fields, blocks and resolution length.
module forecast_spherical_geometry_setup
  use iso_c_binding, only: c_int, c_int64_t, c_double
  use forecast_latitude_geometry, only: native_latitude_geometry
  use forecast_spherical_point_geometry, only: native_spherical_point_geometry, spherical_physical_values, &
                                               initialize_spherical_point_geometry, release_spherical_point_geometry
  use forecast_computational_geometry, only: native_computational_geometry, initialize_computational_geometry, &
                                             spherical_resolution_scale, release_computational_geometry
  use forecast_geometry_block_storage, only: native_geometry_block_storage, allocate_geometry_block_storage, &
                                             bind_geometry_blocks, release_geometry_block_storage
  implicit none
  private
  public :: native_spherical_geometry, initialize_spherical_geometry, release_spherical_geometry
  !> Own the complete SUGEM2 numerical arrays and non-owning block views.
  !! resolution_length is the SLHDP physical scale in metres.
  !! The actual owner must have TARGET and stay at its address while views exist.
  type :: native_spherical_geometry
    type(native_spherical_point_geometry) :: spherical
    type(native_computational_geometry) :: computational
    type(native_geometry_block_storage) :: blocked
    real(c_double) :: resolution_length
  end type
contains
  !> Check every owned output before any child can acquire storage.
  logical function spherical_owners_fresh(state)
    type(native_spherical_geometry), intent(in) :: state
    spherical_owners_fresh = .false.
    if (allocated(state%spherical%rcori)) return
    if (allocated(state%spherical%rcoric)) return
    if (allocated(state%spherical%gemu)) return
    if (allocated(state%spherical%gsqm2)) return
    if (allocated(state%spherical%gelam)) return
    if (allocated(state%spherical%gelat)) return
    if (allocated(state%spherical%geclo)) return
    if (allocated(state%spherical%geslo)) return
    if (allocated(state%spherical%gexco)) return
    if (allocated(state%spherical%geyco)) return
    if (allocated(state%spherical%gezco)) return
    if (allocated(state%spherical%gm)) return
    if (allocated(state%spherical%gmappa)) return
    if (allocated(state%spherical%gomvrl)) return
    if (allocated(state%spherical%gomvrm)) return
    if (allocated(state%spherical%gnordl)) return
    if (allocated(state%spherical%gnordm)) return
    if (allocated(state%spherical%gnordlcl)) return
    if (allocated(state%spherical%gnordmcl)) return
    if (allocated(state%spherical%gnordmcm)) return
    if (allocated(state%spherical%gaw)) return
    if (allocated(state%spherical%ngplat)) return
    if (allocated(state%spherical%nuniquegp)) return
    if (allocated(state%computational%rcolon)) return
    if (allocated(state%computational%rsilon)) return
    if (allocated(state%computational%rindx)) return
    if (allocated(state%computational%rindy)) return
    if (allocated(state%computational%ratath)) return
    if (allocated(state%computational%ratatx)) return
    if (allocated(state%blocked%rcori)) return
    if (allocated(state%blocked%rcoric)) return
    if (allocated(state%blocked%gemu)) return
    if (allocated(state%blocked%gsqm2)) return
    if (allocated(state%blocked%gelam)) return
    if (allocated(state%blocked%gelat)) return
    if (allocated(state%blocked%geclo)) return
    if (allocated(state%blocked%geslo)) return
    if (allocated(state%blocked%gexco)) return
    if (allocated(state%blocked%geyco)) return
    if (allocated(state%blocked%gezco)) return
    if (allocated(state%blocked%gm)) return
    if (allocated(state%blocked%gmappa)) return
    if (allocated(state%blocked%gomvrl)) return
    if (allocated(state%blocked%gomvrm)) return
    if (allocated(state%blocked%gnordl)) return
    if (allocated(state%blocked%gnordm)) return
    if (allocated(state%blocked%gnordlcl)) return
    if (allocated(state%blocked%gnordmcl)) return
    if (allocated(state%blocked%gnordmcm)) return
    if (allocated(state%blocked%gaw)) return
    if (allocated(state%blocked%ngplat)) return
    if (allocated(state%blocked%nuniquegp)) return
    if (allocated(state%blocked%spherical_views)) return
    if (allocated(state%blocked%computational_views)) return
    spherical_owners_fresh = .true.
  end function

  !> Compose source children in allocation and calculation order.
  !! Physical constants and existing SUGEM1B coefficients are named by p.
  !! All point and partition arrays describe the live grid; no fixed-grid
  !! replacement is made. The selected32x64 and actual reduced/distributed
  !! routes use the same ordered native children.
  !! latitudes owns complete global Gaussian rows; its halo words are borrowed.
  !! The caller keeps state TARGET and the latitude/partition inputs live.
  !! Return2 refuses unsupported or existing output ownership before mutation.
  !! Return1 releases this group's acquired54owners in source cleanup order.
  integer(c_int) function initialize_spherical_geometry(state, p, point_count, block_width, unique_pitch, &
              truncation, global_longitudes, local_rows, point_starts, first_longitudes, longitude_counts, latitudes) result(status)
    type(native_spherical_geometry), target, intent(inout) :: state
    type(spherical_physical_values), intent(in) :: p
    integer(c_int), intent(in) :: point_count, block_width, unique_pitch, truncation
    integer(c_int), intent(in) :: global_longitudes(:), local_rows(:), point_starts(:)
    integer(c_int), intent(in) :: first_longitudes(:), longitude_counts(:)
    type(native_latitude_geometry), intent(in) :: latitudes
    integer(c_int) :: child
    integer :: rows
    status = 2
    if (.not. spherical_owners_fresh(state)) return
    if (point_count < 1 .or. block_width < 1 .or. block_width > 1048576) return
    if (truncation < 1 .or. truncation > 1279) return
    rows = size(global_longitudes)
    if (rows < 1) return
    if (.not. allocated(latitudes%rmu) .or. .not. allocated(latitudes%rsqm2)) return
    if (.not. allocated(latitudes%rw)) return
    if (lbound(latitudes%rmu, 1) > 1 .or. ubound(latitudes%rmu, 1) < rows) return
    if (lbound(latitudes%rsqm2, 1) > 1 .or. ubound(latitudes%rsqm2, 1) < rows) return
    if (lbound(latitudes%rw, 1) /= 1 .or. ubound(latitudes%rw, 1) /= rows) return
    child = initialize_spherical_point_geometry(state%spherical, p, point_count, unique_pitch, &
                                                global_longitudes, local_rows, point_starts, first_longitudes, longitude_counts, &
                                                latitudes%rmu(1:rows), latitudes%rw)
    if (child /= 0) then
      status = child
      return
    end if
    child = allocate_geometry_block_storage(state%blocked, block_width, point_count)
    if (child /= 0) goto 900
    child = initialize_computational_geometry(state%computational, p, point_count, global_longitudes, &
                       local_rows, point_starts, first_longitudes, longitude_counts, latitudes%rmu(1:rows), latitudes%rsqm2(1:rows))
    if (child /= 0) goto 900
    child = bind_geometry_blocks(state%blocked, state%spherical, state%computational)
    if (child /= 0) goto 900
    child = spherical_resolution_scale(state%resolution_length, p, truncation)
    if (child /= 0) goto 900
    status = 0
    return
900 continue
    call release_spherical_geometry(state)
    status = 1
  end function

  !> Release the exact source owner groups; views never release their targets.
  !! Point arrays, computational arrays, blocked arrays and both view owners
  !! are freed in that order. Scalar resolution_length remains stored.
  subroutine release_spherical_geometry(state)
    type(native_spherical_geometry), intent(inout) :: state
    call release_spherical_point_geometry(state%spherical)
    call release_computational_geometry(state%computational)
    call release_geometry_block_storage(state%blocked)
  end subroutine
end module forecast_spherical_geometry_setup
