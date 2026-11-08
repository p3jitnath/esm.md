!> Publish exact source radiation interpolation halo widths on native owners.
module forecast_radiation_halo_widths
  use iso_fortran_env, only: int32, int64, real64
  use forecast_native_radiation_grid, only: native_radiation_grid, native_radiation_point_partition
  use forecast_radiation_interpolation_context, only: native_radiation_main_grid_view
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: publish_runtime_radiation_halo_widths
contains
!> Set north,south,east,west widths for actual RI and RO interpolation states.
!! EXTREMA is radiation min/max latitude, min/max longitude, then main-grid
!! equivalents, in degrees. Bounds and widths are dimensionless integer rows.
!! All readonly maps retain their original bounds and values. Status2 refuses
!! before any public store; status0 publishes eight widths and two local bounds.
integer(int32)function publish_runtime_radiation_halo_widths(g,main,radiation_partition,partition,ri,ro,nradint,extrema)result(status)
  type(native_radiation_grid), intent(inout) :: g
  type(native_radiation_main_grid_view), intent(in) :: main
  type(native_radiation_point_partition), intent(in) :: radiation_partition
  type(native_distributed_partition), intent(in) :: partition
  type(native_interpolation_state), intent(inout) :: ri, ro
  integer(int32), intent(in) :: nradint
  real(real64), intent(in) :: extrema(:)
  integer(int32) :: n, r, regions, region, first, last, mmax, rmax, w(8), lower, upper
  integer :: j
  real(real64) :: main_latitude_scale, main_longitude_scale, radiation_latitude_scale, radiation_longitude_scale
  status = 2; n = main%grid%ndglg; r = g%ndglg
  if (partition%phase /= 7 .or. nradint < 2 .or. nradint > 3) return
  if (n < 2 .or. n > 65536 .or. mod(n, 2) /= 0 .or. r < 2 .or. r > 8192 .or. mod(r, 2) /= 0) return
  if (g%ndgsal /= 1 .or. g%nfrstloff < 0 .or. g%nfrstloff >= r) return
  if (g%ndgenl < 1 .or. g%ndgenl + g%nfrstloff > r) return
 if (.not. associated(main%row_lengths) .or. .not. associated(main%first_latitude) .or. .not. associated(main%last_latitude)) return
if(.not.associated(radiation_partition%longitude_count).or..not.associated(radiation_partition%first_latitude).or..not.associated(radiation_partition%last_latitude))return
 if(.not.is_contiguous(main%row_lengths).or..not.is_contiguous(main%first_latitude).or..not.is_contiguous(main%last_latitude))return
if(.not.is_contiguous(radiation_partition%longitude_count).or..not.is_contiguous(radiation_partition%first_latitude).or..not.is_contiguous(radiation_partition%last_latitude))return
  regions = size(main%first_latitude); region = partition%my_region_ns
  if (regions < 1 .or. regions > 64 .or. region < 1 .or. region > regions) return
  if (lbound(main%first_latitude, 1) /= 1 .or. lbound(main%last_latitude, 1) /= 1 .or. size(main%last_latitude) /= regions) return
  if (lbound(main%row_lengths, 1) /= -1 .or. ubound(main%row_lengths, 1) /= n + 2) return
  if (radiation_partition%n_regions_ns /= regions .or. radiation_partition%my_region_ns /= region) return
  if (lbound(radiation_partition%longitude_count, 1) /= -1 .or. ubound(radiation_partition%longitude_count, 1) /= r + 2) return
  if (lbound(radiation_partition%first_latitude, 1) /= 1 .or. size(radiation_partition%first_latitude) /= regions) return
  if (lbound(radiation_partition%last_latitude, 1) /= 1 .or. size(radiation_partition%last_latitude) /= regions) return
  first = main%first_latitude(region); last = main%last_latitude(region)
  if (first < 1 .or. last < first .or. last > n) return
  if (main%row_lengths(first) < 1 .or. main%row_lengths(first) > 2*n + 16) return
  if (main%row_lengths(last) < 1 .or. main%row_lengths(last) > 2*n + 16) return
  mmax = max(main%row_lengths(first), main%row_lengths(last))
  first = radiation_partition%first_latitude(region); last = radiation_partition%last_latitude(region)
  if (first < 1 .or. last < first .or. last > r) return
  if (radiation_partition%longitude_count(first) < 1 .or. radiation_partition%longitude_count(first) > 2*r + 16) return
  if (radiation_partition%longitude_count(last) < 1 .or. radiation_partition%longitude_count(last) > 2*r + 16) return
  rmax = max(radiation_partition%longitude_count(first), radiation_partition%longitude_count(last))
  if (size(extrema) < 8) return
  do j = 1, 8
    if (ibits(transfer(extrema(j), 0_int64), 52, 11) == 2047) return
  end do
  if (extrema(1) > extrema(2) .or. extrema(5) > extrema(6) .or. extrema(3) > extrema(4) .or. extrema(7) > extrema(8)) return
  if (extrema(1) < -90.0_real64 .or. extrema(2) > 90.0_real64 .or. extrema(5) < -90.0_real64 .or. extrema(6) > 90.0_real64) return
  if (extrema(3) < 0.0_real64 .or. extrema(4) > 360.0_real64 .or. extrema(7) < 0.0_real64 .or. extrema(8) > 360.0_real64) return
! Preserve the source's four independent rounded scale divisions.
  main_latitude_scale = real(n, real64)/180.0_real64
  main_longitude_scale = real(mmax, real64)/360.0_real64
  radiation_latitude_scale = real(r, real64)/180.0_real64
  radiation_longitude_scale = real(rmax, real64)/360.0_real64
! Source execution visits south,north,west,east on each direction.
  w(2) = source_halo_width(extrema(1), extrema(5), main_latitude_scale, .false., .true.)
  w(1) = source_halo_width(extrema(2), extrema(6), main_latitude_scale, .false., .false.)
  w(4) = source_halo_width(extrema(3), extrema(7), main_longitude_scale, .false., .true.)
  w(3) = source_halo_width(extrema(4), extrema(8), main_longitude_scale, .false., .false.)
  w(6) = source_halo_width(extrema(1), extrema(5), radiation_latitude_scale, .true., .true.)
  w(5) = source_halo_width(extrema(2), extrema(6), radiation_latitude_scale, .true., .false.)
  w(8) = source_halo_width(extrema(3), extrema(7), radiation_longitude_scale, .true., .true.)
  w(7) = source_halo_width(extrema(4), extrema(8), radiation_longitude_scale, .true., .false.)
  lower = max(g%ndgsal + g%nfrstloff - w(5), -1) - g%nfrstloff
  upper = min(g%ndgenl + g%nfrstloff + w(6), r + 2) - g%nfrstloff
  ri%nslwiden = w(1); ri%nslwides = w(2); ri%nslwidee = w(3); ri%nslwidew = w(4)
  ro%nslwiden = w(5); ro%nslwides = w(6); ro%nslwidee = w(7); ro%nslwidew = w(8)
  g%ndgsah = lower; g%ndgenh = upper
  status = 0
  end function
!> Execute both directed integer conversions before choosing a width.
  integer(int32) function source_halo_width(a, b, scale, reverse, expand_less) result(width)
    real(real64), intent(in) :: a, b, scale
    logical, intent(in) :: reverse, expand_less
    real(real64) :: difference, amount
    integer(int32), volatile :: up, down
    integer(int32) :: expanded, contracted
    logical :: less
    difference = a - b; amount = abs(difference); amount = amount*scale
    up = ceiling(amount, kind=int32); down = floor(amount, kind=int32)
    expanded = 5_int32 + up; contracted = max(0_int32, 5_int32 - down)
    if (reverse) then
      less = b < a
    else
      less = a < b
    end if
    if (less .eqv. expand_less) then
      width = expanded
    else
      width = contracted
    end if
  end function
end module forecast_radiation_halo_widths
