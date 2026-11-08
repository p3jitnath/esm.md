!> Define native plane indices for the retained interpolation work arrays.
!! A plane is one field slot in an array of weights or coordinates. These
!! integer builders preserve source order and calculate no weather value.
module md2asm_internal_interpolation_plane_maps
  use iso_fortran_env, only: int32
  implicit none
  private
  public :: interpolation_plane_controls, linear_weight_plane_map, nonlinear_weight_plane_map
  public :: spherical_coordinate_plane_map, cartesian_coordinate_plane_map
  public :: initialize_internal_interpolation_plane_maps, initialize_linear_weight_planes
  public :: initialize_nonlinear_weight_planes, initialize_spherical_coordinate_planes
  public :: initialize_cartesian_coordinate_planes
  !> Supply the initialized named SUDYN/GFL controls.
  !! nslDimk counts1:4 horizontal weight sets. The other members retain their
  !! original logical meanings. selectors contains exact12-character CSLINT
  !! names after SUGFL3; names select Hermite weights without changing fields.
  type :: interpolation_plane_controls
    logical :: lslag = .false., lvsplip = .false., lsltvweno = .false., lrhsvweno = .false.
    logical :: lslvf = .false., lslhdheat = .false., lvweno_t = .false.
    integer(int32) :: nsldimk = 1
  end type
  !> Original TLSCAW plane starts and total allocated field count.
  type :: linear_weight_plane_map
    integer(int32) :: m_wdlo = 0, m_wdlat = 0, m_wdver = 0, m_wdlomad = 0, m_wdlamad = 0, m_wdvermad = 0, ndim = 0
  end type
  !> Original TRSCAW plane starts; unused horizontal slots retain input values.
  !! Each longitude start spans6 real planes; latitude starts span3. Other
  !! widths follow the named operation. Plane numbers are one-based integers.
  type :: nonlinear_weight_plane_map
    integer(int32) :: m_wclo(4) = 0, m_wcla(4) = 0, m_wvintw = 0
    integer(int32) :: m_wclosld(4) = 0, m_wclasld(4) = 0, m_wcloslt = 0, m_wclaslt = 0
    integer(int32) :: m_wvintwsld = 0, m_wvintwslt = 0, m_wvintwslvf = 0
    integer(int32) :: m_wclomad(4) = 0, m_wclamad(4) = 0, m_wvintwmad = 0
    integer(int32) :: m_wvintws = 0, m_wvderw = 0, m_whvw = 0, m_cw = 0, ndim = 0
  end type
  !> Original TSCO coordinate-plane starts and total count.
  type :: spherical_coordinate_plane_map
    integer(int32) :: m_cosco = 0, m_sinco = 0, m_sinla = 0, m_cophi = 0, ndim = 0
  end type
  !> Original TCCO longitude,latitude and wind-rotation plane starts.
  type :: cartesian_coordinate_plane_map
    integer(int32) :: m_rlon = 0, m_rlat = 0, m_rqx = 0, m_rqy = 0, ndim = 0
  end type
contains
  !> Initialize all six source records from explicit live controls.
  !! controls and selectors are read only. All output records are native
  !! caller-owned values,disjoint from inputs and each other. Full/half linear
  !! maps match. Only the full nonlinear map enables spline/Hermite extras.
  !! Arrays above controls%nsldimk retain their incoming integer values.
  !! Status2 refuses inactive LSLAG,unsupported set count or over2163 names
  !! before any output;status0 completes every source-named integer store.
  !! No allocation,original model call,profiling hook or FP operation is used.
  subroutine initialize_internal_interpolation_plane_maps(controls, selectors, linear_full, linear_half, &
                                                          nonlinear_full, nonlinear_half, spherical, cartesian, status)
    type(interpolation_plane_controls), intent(in) :: controls
    character(len=12), intent(in) :: selectors(:)
    type(linear_weight_plane_map), intent(inout) :: linear_full, linear_half
    type(nonlinear_weight_plane_map), intent(inout) :: nonlinear_full, nonlinear_half
    type(spherical_coordinate_plane_map), intent(inout) :: spherical
    type(cartesian_coordinate_plane_map), intent(inout) :: cartesian
    integer(int32), intent(out) :: status
    logical :: hermite
    integer :: j
    status = 2
    if (.not. controls%lslag) return
    if (controls%nsldimk < 1 .or. controls%nsldimk > 4) return
    if (size(selectors) > 2163) return
    hermite = .false.
    do j = 1, size(selectors)
      select case (selectors(j))
      case ('LAIHVT      ', 'LAIHVTQM    ', 'LAIHVTQMH   ')
        hermite = .true.
        exit
      end select
    end do
    call initialize_linear_weight_planes(linear_full)
    call initialize_linear_weight_planes(linear_half)
    call initialize_nonlinear_weight_planes(controls, controls%lvsplip, hermite, nonlinear_full, status)
    if (status /= 0) return
    call initialize_nonlinear_weight_planes(controls, .false., .false., nonlinear_half, status)
    if (status /= 0) return
    call initialize_spherical_coordinate_planes(spherical)
    call initialize_cartesian_coordinate_planes(cartesian)
    status = 0
  end subroutine

  !> Set every TLSCAW index in its declared allocation order.
  subroutine initialize_linear_weight_planes(map)
    type(linear_weight_plane_map), intent(out) :: map
    map%m_wdlo = 1
    map%m_wdlat = 5
    map%m_wdver = 6
    map%m_wdlomad = 7
    map%m_wdlamad = 11
    map%m_wdvermad = 12
    map%ndim = 12
  end subroutine

  !> Set TRSCAW starts,including source aliases for inactive families.
  !! controls%nsldimk selects1:4 active horizontal slots. Only those slots
  !! change;all scalar members are assigned. spline and hermite select4-plane
  !! extras. WENO reserves its original3-window widths and3 final weights.
  !! Status2 leaves map unchanged for an invalid set count;status0 succeeds.
  subroutine initialize_nonlinear_weight_planes(controls, spline, hermite, map, status)
    type(interpolation_plane_controls), intent(in) :: controls
    logical, intent(in) :: spline, hermite
    type(nonlinear_weight_plane_map), intent(inout) :: map
    integer(int32), intent(out) :: status
    integer(int32) :: next, j
    logical :: weno
    status = 2
    if (controls%nsldimk < 1 .or. controls%nsldimk > 4) return
    next = 1
    do j = 1, controls%nsldimk
      map%m_wclo(j) = next
      next = next + 6
    end do
    do j = 1, controls%nsldimk
      map%m_wcla(j) = next
      next = next + 3
    end do
    map%m_wvintw = next
    next = next + 3
    weno = controls%lsltvweno .or. controls%lrhsvweno
    if (weno) next = next + 6
    if (controls%lslvf) then
      map%m_wvintwslvf = next
      next = next + 3
      if (controls%lrhsvweno .and. controls%lvweno_t) next = next + 6
    else
      map%m_wvintwslvf = map%m_wvintw
    end if
    do j = 1, controls%nsldimk
      map%m_wclosld(j) = next
      next = next + 6
    end do
    if (controls%lslhdheat) then
      map%m_wcloslt = next
      next = next + 6
    else
      map%m_wcloslt = map%m_wclosld(1)
    end if
    do j = 1, controls%nsldimk
      map%m_wclasld(j) = next
      next = next + 3
    end do
    if (controls%lslhdheat) then
      map%m_wclaslt = next
      next = next + 3
    else
      map%m_wclaslt = map%m_wclasld(1)
    end if
    map%m_wvintwsld = next
    next = next + 3
    if (controls%lslhdheat) then
      map%m_wvintwslt = next
      next = next + 3
    else
      map%m_wvintwslt = map%m_wvintwsld
    end if
    do j = 1, controls%nsldimk
      map%m_wclomad(j) = next
      next = next + 6
    end do
    do j = 1, controls%nsldimk
      map%m_wclamad(j) = next
      next = next + 3
    end do
    map%m_wvintwmad = next
    next = next + 3
    map%m_wvintws = 1
    if (spline) then
      map%m_wvintws = next
      next = next + 4
    end if
    map%m_wvderw = 1
    if (hermite) then
      map%m_wvderw = next
      next = next + 4
    end if
    map%m_whvw = 1
    if (hermite) then
      map%m_whvw = next
      next = next + 4
    end if
    map%m_cw = 1
    if (weno) then
      map%m_cw = next
      next = next + 3
    end if
    map%ndim = next - 1
    status = 0
  end subroutine

  !> Set all four dimensionless spherical coordinate slots.
  subroutine initialize_spherical_coordinate_planes(map)
    type(spherical_coordinate_plane_map), intent(out) :: map
    map%m_cosco = 1
    map%m_sinco = 2
    map%m_sinla = 3
    map%m_cophi = 4
    map%ndim = 4
  end subroutine

  !> Set longitude/latitude radians and dimensionless rotation slots.
  subroutine initialize_cartesian_coordinate_planes(map)
    type(cartesian_coordinate_plane_map), intent(out) :: map
    map%m_rlon = 1
    map%m_rlat = 2
    map%m_rqx = 3
    map%m_rqy = 4
    map%ndim = 4
  end subroutine
end module md2asm_internal_interpolation_plane_maps
