!> Own the radiation-grid Gaussian, local-coordinate and latitude fields.
!! This radiation-specific owner is distinct from the model grid. It replaces
!! the old private RADGRID byte image. Arrays use FP64 and native descriptors.
!! Latitude/longitude use radians. Sines/cosines and interpolation weights
!! are dimensionless except cubic latitude coefficients, in radian**(-3).
module forecast_native_radiation_grid
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: native_radiation_grid, native_radiation_point_partition
  public :: calculate_runtime_grid_angular_extrema, calculate_preallocated_grid_angular_extrema
  public :: fill_preallocated_radiation_gaussian_fields, create_runtime_radiation_gaussian_fields
  public :: release_runtime_radiation_gaussian_fields, create_runtime_radiation_point_coordinates
  public :: release_runtime_radiation_point_coordinates
  public :: create_runtime_radiation_latitude_interpolation, create_operational_radiation_latitude_interpolation
  public :: release_runtime_radiation_latitude_interpolation, release_operational_radiation_latitude_interpolation
  !> Only source-produced radiation-grid counts belong here; no clock is copied.
  type :: native_radiation_grid
    integer(int32) :: ndglg = 0, ndlon = 0, nsmax = 0, ngptot = 0
    integer(int32) :: nfrstloff = 0, ndgsl = 0, ndgsah = 0, ndgenh = 0
    integer(int32) :: ndgsal = 0, ndgenl = 0, ndlonh = 0, ndlonm = 0
    integer(int32) :: myfrstlat = 0, mylstlat = 0
    real(real64), allocatable :: rmu(:), rsqm2(:), rlatig(:), rlati(:), ripi(:, :)
    real(real64), allocatable :: gelam(:), gelat(:), geslo(:), geclo(:), gemu(:)
  end type
  !> Borrow complete initialized public row maps. Their producer stays live.
 !! Longitude counts retain lower bound -1. START/COUNT preserve their real
 !! row bounds and physical strides. The operative map origin is the one
 !! source NDGSL member in the radiation-grid owner.
  type :: native_radiation_point_partition
    integer(int32) :: my_region_ns = 0, my_region_ew = 0, n_regions_ns = 0, n_regions_ew = 0
    integer(int32) :: nstencilwide = 0
    integer(int32), pointer :: first_latitude(:) => null(), last_latitude(:) => null()
    integer(int32), pointer :: longitude_count(:) => null(), start(:, :) => null(), count(:, :) => null()
  end type
  interface
    function public_asin(x) bind(C, name="asin") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_sin(x) bind(C, name="sin") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
    function public_cos(x) bind(C, name="cos") result(y)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: y
    end function
  end interface
contains
  logical function finite_word(x)
    real(real64), intent(in) :: x
    finite_word = iand(transfer(x, 0_int64), int(z'7ff0000000000000', int64)) /= int(z'7ff0000000000000', int64)
  end function
  !> Convert complete radians to degrees and retain the first equal extrema.
 !! Inputs and outputs are disjoint. Only four extrema and optional work
 !! prefixes mutate; padding and all borrowed inputs retain their bytes.
  integer(int32) function calculate_runtime_grid_angular_extrema(latitude, longitude, physical, extrema) result(status)
    real(real64), intent(in) :: latitude(:), longitude(:)
    type(forecast_physical_constants), intent(in) :: physical
    real(real64), intent(inout) :: extrema(:)
    real(real64) :: work1(0), work2(0)
    status = angles(latitude, longitude, physical, extrema, work1, work2, .false.)
  end function
 integer(int32)function calculate_preallocated_grid_angular_extrema(latitude,longitude,physical,extrema,latitude_degrees,longitude_degrees)result(status)
  real(real64), intent(in) :: latitude(:), longitude(:)
  type(forecast_physical_constants), intent(in) :: physical
  real(real64), intent(inout) :: extrema(:), latitude_degrees(:), longitude_degrees(:)
  status = angles(latitude, longitude, physical, extrema, latitude_degrees, longitude_degrees, .true.)
  end function
  integer(int32) function angles(lat, lon, p, e, ld, od, capture) result(status)
    real(real64), intent(in) :: lat(:), lon(:)
    type(forecast_physical_constants), intent(in) :: p
    real(real64), intent(inout) :: e(:), ld(:), od(:)
    logical, intent(in) :: capture
    integer :: i, n
    real(real64) :: a, b, mnlat, mxlat, mnlon, mxlon, halfpi, twopi
    status = 2; n = size(lat)
    if (n < 1 .or. int(n, int64) > 268435456_int64 .or. size(lon) < n .or. size(e) < 4) return
    if (capture) then
      if (size(ld) < n .or. size(od) < n) return
    end if
    if (.not. finite_word(p%rpi)) return
    if (p%rpi < 3._real64 .or. p%rpi >= 4._real64) return
    halfpi = p%rpi*0.5_real64; twopi = p%rpi*2._real64
    do i = 1, n
      if (.not. finite_word(lat(i)) .or. .not. finite_word(lon(i))) return
      if (lat(i) > halfpi .or. lat(i) < -halfpi .or. lon(i) < 0._real64 .or. lon(i) > twopi) return
    end do
    do i = 1, n
      a = lat(i)/p%rpi; a = a*2._real64; a = a*90._real64
      b = lon(i) - p%rpi; b = b/p%rpi; b = b*180._real64; b = b + 180._real64
      if (capture) then
        ld(i) = a; od(i) = b
      end if
      if (i == 1) then
        mnlat = a; mxlat = a; mnlon = b; mxlon = b
      else
        if (mnlat > a) mnlat = a
        if (mxlat < a) mxlat = a
        if (mnlon > b) mnlon = b
        if (mxlon < b) mxlon = b
      end if
    end do
    e(1) = mnlat; e(2) = mxlat; e(3) = mnlon; e(4) = mxlon; status = 0
  end function
  !> Fill existing -1:N+2 Gaussian owners, with two reflected rows per pole.
 !! The ordinary sine input decreases strictly and lies inside (-1,1).
  logical function gaussian_input_is_valid(g, zmu, physical, nradint)
    type(native_radiation_grid), intent(in) :: g
    real(real64), intent(in) :: zmu(-1:)
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint
    integer :: j, n
    gaussian_input_is_valid = .false.; n = g%ndglg
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0 .or. nradint < 2 .or. nradint > 3) return
    if (ubound(zmu, 1) < n + 2) return
    if (.not. finite_word(physical%rpi)) return
    if (physical%rpi < 3._real64 .or. physical%rpi >= 4._real64) return
    do j = 1, n
      if (.not. finite_word(zmu(j))) return
      if (abs(zmu(j)) >= 1._real64) return
      if (j == 1) then
        if (1._real64 <= zmu(j)) return
      else
        if (zmu(j - 1) <= zmu(j)) return
      end if
    end do
    gaussian_input_is_valid = .true.
  end function
  integer(int32) function fill_preallocated_radiation_gaussian_fields(g, zmu, physical, nradint) result(status)
    type(native_radiation_grid), intent(inout) :: g
    real(real64), intent(inout) :: zmu(-1:)
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint
    integer :: j, n, src, dst
    real(real64) :: a
    status = 2; n = g%ndglg
    if (.not. gaussian_input_is_valid(g, zmu, physical, nradint)) return
    if (.not. allocated(g%rmu) .or. .not. allocated(g%rsqm2) .or. .not. allocated(g%rlatig)) return
    if (lbound(g%rmu, 1) /= -1 .or. ubound(g%rmu, 1) /= n + 2) return
    if (lbound(g%rsqm2, 1) /= -1 .or. ubound(g%rsqm2, 1) /= n + 2) return
    if (lbound(g%rlatig, 1) /= -1 .or. ubound(g%rlatig, 1) /= n + 2) return
    do j = 1, n
      g%rmu(j) = zmu(j)
    end do
    do j = 1, n
      a = zmu(j)*zmu(j); a = 1._real64 - a
      g%rsqm2(j) = sqrt(a); g%rlatig(j) = public_asin(zmu(j))
    end do
    do j = 1, 2
      src = j; dst = 1 - j
      zmu(dst) = zmu(src); g%rmu(dst) = g%rmu(src); g%rsqm2(dst) = g%rsqm2(src)
      g%rlatig(dst) = physical%rpi - g%rlatig(src)
    end do
    do j = 1, 2
      src = n + 1 - j; dst = n + j
      zmu(dst) = zmu(src); g%rmu(dst) = g%rmu(src); g%rsqm2(dst) = g%rsqm2(src)
      a = -physical%rpi; g%rlatig(dst) = a - g%rlatig(src)
    end do
    status = 0
  end function
  integer(int32) function create_runtime_radiation_gaussian_fields(g, zmu, physical, nradint) result(status)
    type(native_radiation_grid), intent(inout) :: g
    real(real64), intent(inout) :: zmu(-1:)
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint
    real(real64), allocatable :: mu(:), cs(:), lat(:)
    integer :: a, n
    status = 2; n = g%ndglg
    if (allocated(g%rmu) .or. allocated(g%rsqm2) .or. allocated(g%rlatig)) return
    if (.not. gaussian_input_is_valid(g, zmu, physical, nradint)) return
    allocate (mu(-1:n + 2), stat=a); if (a /= 0) then; status = 1; return; end if
    allocate (cs(-1:n + 2), stat=a); if (a /= 0) then; status = 1; return; end if
    allocate (lat(-1:n + 2), stat=a); if (a /= 0) then; status = 1; return; end if
    call move_alloc(mu, g%rmu); call move_alloc(cs, g%rsqm2); call move_alloc(lat, g%rlatig)
    status = fill_preallocated_radiation_gaussian_fields(g, zmu, physical, nradint)
  end function
  integer(int32) function release_runtime_radiation_gaussian_fields(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    integer :: n, k
    n = g%ndglg; status = 2; k = 0
    if (allocated(g%rmu)) k = k + 1
    if (allocated(g%rsqm2)) k = k + 1
    if (allocated(g%rlatig)) k = k + 1
    if (k == 0) then; status = 0; return; end if
    if (k /= 3) return
    if (lbound(g%rmu, 1) /= -1 .or. ubound(g%rmu, 1) /= n + 2) return
    if (lbound(g%rsqm2, 1) /= -1 .or. ubound(g%rsqm2, 1) /= n + 2) return
    if (lbound(g%rlatig, 1) /= -1 .or. ubound(g%rlatig, 1) /= n + 2) return
    deallocate (g%rlatig); deallocate (g%rsqm2); deallocate (g%rmu); status = 0
  end function
  !> Own complete local latitudes and three source-ordered cubic coefficients.
  integer(int32) function create_runtime_radiation_latitude_interpolation(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    real(real64), allocatable :: lat(:), coef(:, :)
    real(real64) :: a, b, c, d, ab, ac, ad, bc, bd, cd, x
    integer :: j, k, n, ierr, first, last
    status = 2; n = g%ndglg; first = g%ndgsah; last = g%ndgenh
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0 .or. first > last) return
    if (g%nfrstloff < 0 .or. g%nfrstloff >= n) return
    if (first + g%nfrstloff < -1 .or. last + g%nfrstloff > n + 2) return
    if (allocated(g%rlati) .or. allocated(g%ripi) .or. .not. allocated(g%rlatig)) return
    if (lbound(g%rlatig, 1) /= -1 .or. ubound(g%rlatig, 1) /= n + 2) return
    do j = -1, n + 2
      if (.not. finite_word(g%rlatig(j))) return
      if (j > -1) then
        if (g%rlatig(j - 1) <= g%rlatig(j)) return
      end if
    end do
    allocate (lat(first:last), stat=ierr); if (ierr /= 0) then; status = 1; return; end if
    allocate (coef(first:last, 3), stat=ierr); if (ierr /= 0) then; status = 1; return; end if
    do j = first, last
      k = j + g%nfrstloff; lat(j) = g%rlatig(k)
      if (k < 0 .or. k > n) cycle
      a = g%rlatig(k - 1); b = g%rlatig(k); c = g%rlatig(k + 1); d = g%rlatig(k + 2)
      ab = a - b; ac = a - c; ad = a - d; bc = b - c; bd = b - d; cd = c - d
      x = ab*bc; x = x*bd; coef(j, 1) = -1._real64/x
      x = ac*bc; x = x*cd; coef(j, 2) = 1._real64/x
      x = ad*bd; x = x*cd; coef(j, 3) = -1._real64/x
    end do
    call move_alloc(lat, g%rlati); call move_alloc(coef, g%ripi); status = 0
  end function
  integer(int32) function create_operational_radiation_latitude_interpolation(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    status = 2; if (g%ndglg /= 800) return
    status = create_runtime_radiation_latitude_interpolation(g)
  end function
  integer(int32) function release_runtime_radiation_latitude_interpolation(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    status = 2
    if (.not. allocated(g%rlati) .and. .not. allocated(g%ripi)) then; status = 0; return; end if
    if (.not. allocated(g%rlati) .or. .not. allocated(g%ripi)) return
    if (lbound(g%rlati, 1) /= g%ndgsah .or. ubound(g%rlati, 1) /= g%ndgenh) return
    if (lbound(g%ripi, 1) /= g%ndgsah .or. ubound(g%ripi, 1) /= g%ndgenh .or. size(g%ripi, 2) /= 3) return
    deallocate (g%ripi); deallocate (g%rlati); status = 0
  end function
  integer(int32) function release_operational_radiation_latitude_interpolation(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    status = 2; if (g%ndglg /= 800) return
    status = release_runtime_radiation_latitude_interpolation(g)
  end function
  !> Create longitude, latitude, longitude sine/cosine and latitude sine.
 !! Five allocations finish before publication. Empty local regions retain
 !! zero logical extents. Point visits follow global row then longitude.
  integer(int32) function create_runtime_radiation_point_coordinates(g, zmu, physical, p) result(status)
    type(native_radiation_grid), intent(inout) :: g
    real(real64), intent(in) :: zmu(-1:)
    type(forecast_physical_constants), intent(in) :: physical
    type(native_radiation_point_partition), intent(in) :: p
    real(real64), allocatable :: lon(:), lat(:), sn(:), cs(:), mu(:)
    integer :: first, last, row, slot, ew, start, count, m, j, q, a, n
    integer(int64) :: total
    real(real64) :: x, y, den
    status = 2; n = g%ndglg
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0 .or. g%ngptot < 0) return
    if (g%ndlon < 1 .or. g%ndlon > 2*n + 16 .or. g%nsmax < 0 .or. g%nsmax > 2*n) return
    if (p%n_regions_ns < 1 .or. p%n_regions_ns > 64 .or. p%n_regions_ew < 1 .or. p%n_regions_ew > 64) return
    if (p%my_region_ns < 1 .or. p%my_region_ns > p%n_regions_ns .or. p%my_region_ew < 1 .or. p%my_region_ew > p%n_regions_ew) return
    if (p%nstencilwide < 1 .or. p%nstencilwide > 16 .or. ubound(zmu, 1) < n + 2) return
    if (.not. associated(p%first_latitude) .or. .not. associated(p%last_latitude) .or. .not. associated(p%longitude_count)) return
    if (.not. associated(p%start) .or. .not. associated(p%count)) return
    if (size(p%first_latitude) < p%n_regions_ns .or. size(p%last_latitude) < p%n_regions_ns) return
    if (lbound(p%longitude_count, 1) > -1 .or. ubound(p%longitude_count, 1) < n + 2) return
    if (size(p%start, 1) /= n + p%n_regions_ns + 3 .or. size(p%count, 1) /= n + p%n_regions_ns + 3) return
    if (ubound(p%start, 2) < p%my_region_ew .or. ubound(p%count, 2) < p%my_region_ew) return
    if (allocated(g%gelam) .or. allocated(g%gelat) .or. allocated(g%geslo) .or. allocated(g%geclo) .or. allocated(g%gemu)) return
    first = p%first_latitude(p%my_region_ns); last = p%last_latitude(p%my_region_ns)
    if (first < 1 .or. first > n + 1 .or. last < first - 1 .or. last > n) return
    ew = p%my_region_ew; slot = g%ndgsl + 1
    if (slot < lbound(p%start, 1) .or. slot + last - first > ubound(p%start, 1)) return
    if (slot < lbound(p%count, 1) .or. slot + last - first > ubound(p%count, 1)) return
    if (.not. finite_word(physical%rpi)) return
    if (physical%rpi < 3._real64 .or. physical%rpi >= 4._real64) return
    total = 0
    do row = first, last
      start = p%start(slot, ew); count = p%count(slot, ew); m = p%longitude_count(row)
      if (count < 0 .or. m < 1 .or. m > 2*n + 16) return
      if (count > 0) then
        if (start < 1 .or. int(start, int64) + count - 1 > m) return
      end if
      total = total + count; if (total > g%ngptot) return
      if (.not. finite_word(zmu(row))) return
      if (abs(zmu(row)) >= 1._real64) return
      slot = slot + 1
    end do
    if (total /= g%ngptot) return
    allocate (lon(g%ngptot), stat=a); if (a /= 0) then; status = 1; return; end if
    allocate (lat(g%ngptot), stat=a); if (a /= 0) then; status = 1; return; end if
    allocate (sn(g%ngptot), stat=a); if (a /= 0) then; status = 1; return; end if
    allocate (cs(g%ngptot), stat=a); if (a /= 0) then; status = 1; return; end if
    allocate (mu(g%ngptot), stat=a); if (a /= 0) then; status = 1; return; end if
    g%ndgsal = 1; g%ndgenl = last - g%nfrstloff
    g%ndlonh = 2*p%nstencilwide - 1 - mod(g%ndlon, 2)
    g%ndlonm = max(g%ndlon, 2*g%nsmax + 1) + g%ndlonh
    g%myfrstlat = first; g%mylstlat = last
    slot = g%ndgsl + 1; q = 0
    do row = first, last
      start = p%start(slot, ew); count = p%count(slot, ew); den = real(p%longitude_count(row), real64)
      do j = start, start + count - 1
        q = q + 1; x = real(j - 1, real64); x = x*2._real64; x = x*physical%rpi; x = x/den
        lon(q) = x; lat(q) = public_asin(zmu(row)); sn(q) = public_sin(x); cs(q) = public_cos(x); mu(q) = zmu(row)
      end do
      slot = slot + 1
    end do
    call move_alloc(lon, g%gelam); call move_alloc(lat, g%gelat); call move_alloc(sn, g%geslo)
    call move_alloc(cs, g%geclo); call move_alloc(mu, g%gemu); status = 0
  end function
  integer(int32) function release_runtime_radiation_point_coordinates(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    integer :: k, n
    status = 2; k = 0; n = g%ngptot
    if (allocated(g%gelam)) k = k + 1
    if (allocated(g%gelat)) k = k + 1
    if (allocated(g%geslo)) k = k + 1
    if (allocated(g%geclo)) k = k + 1
    if (allocated(g%gemu)) k = k + 1
    if (k == 0) then; status = 0; return; end if
    if (k /= 5) return
    if (size(g%gelam) /= n .or. size(g%gelat) /= n .or. size(g%geslo) /= n .or. size(g%geclo) /= n .or. size(g%gemu) /= n) return
    deallocate (g%gemu); deallocate (g%geclo); deallocate (g%geslo); deallocate (g%gelat); deallocate (g%gelam); status = 0
  end function
end module
