!> Source-ordered accumulation of all non-orographic wave launches.
module md2asm_nonorographic_gravity_wave_launches
  use iso_fortran_env, only: int32, int64, real64
  use yoegwd, only: tegwd
  use yoegwwms, only: tegwwms
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_standard_atmosphere_setup, only: standard_atmosphere_state
  use forecast_physics_work_types, only: dimension_type, state_type, aux_type, flux_type
  use md2asm_nonorographic_gravity_waves, only: gwdrag_wms, admit_nonorographic_wave_parameters
  implicit none
  private
  public :: gwdragwms_layer
contains
  !> Clear selected NOGW cells, then add each tendency and subtract each flux.
  !! The original unused YGFL argument is absent. NOGW_U/V are the two actual
  !! native registry P owners, in real64(KLON,KLEV) shape, and are mutable.
  !! STATE/PAUX are input-only borrowed fields. FLUX changes only PSTRDU/V,
  !! native real64(KLON,0:KLEV) stress in Pa. Precipitation uses kg/m2/s and
  !! the child tendencies use m/s2. All other fields and inactive cells stay.
  !! Supports columns1:2048,levels2:512,launches0:3 and empty intervals.
  !! Status0 completes,2 refuses metadata before writes,1 reports private
  !! storage failure; a child failure after a completed launch retains prior
  !! source-ordered mutations. Caller owns disjoint fields and sets FP mode.
  subroutine gwdragwms_layer(constants,ydsta,ydegwd,ydegwwms,kdim,state,paux,flux,nogw_u,nogw_v,status,runtime_grid_spacing)
    type(forecast_physical_constants), intent(in) :: constants
    type(standard_atmosphere_state), intent(in) :: ydsta
    type(tegwd), intent(in) :: ydegwd
    type(tegwwms), intent(in) :: ydegwwms
    type(dimension_type), intent(in) :: kdim
    type(state_type), intent(in) :: state
    type(aux_type), intent(in) :: paux
    type(flux_type), intent(inout) :: flux
    real(real64), intent(inout) :: nogw_u(:, :), nogw_v(:, :)
    integer(int32), intent(out) :: status
    logical, intent(in), optional :: runtime_grid_spacing
    real(real64), allocatable, target :: arena(:)
    real(real64), pointer, contiguous :: rain(:), du(:, :), dv(:, :), fu(:, :), fv(:, :)
    logical :: use_runtime
    integer :: p, l, first, last, j, k, launch, allocation_status, child_status
    integer(int64) :: cells, offset
    real(real64) :: a
    status = 2; use_runtime = .false.
    if (present(runtime_grid_spacing)) use_runtime = runtime_grid_spacing
    p = kdim%klon; l = kdim%klev; first = kdim%kidia; last = kdim%kfdia
    if (p < 1 .or. p > 2048 .or. l < 2 .or. l > 512 .or. first < 1 .or. first > p + 1 .or. last < 0 .or. last > p) return
    if (ydegwwms%nlaunchlev < 0 .or. ydegwwms%nlaunchlev > 3) return
    if (size(nogw_u, 1) /= p .or. size(nogw_u, 2) < l .or. size(nogw_v, 1) /= p .or. size(nogw_v, 2) < l) return
    if (.not. associated(state%t) .or. .not. associated(state%u) .or. .not. associated(state%v)) return
    if (.not. associated(paux%paprsf) .or. .not. associated(paux%paprs) .or. .not. associated(paux%paphif)) return
    if (.not. associated(paux%pgelat) .or. .not. associated(paux%pgaw)) return
    if(.not.associated(flux%pfplcl).or..not.associated(flux%pfplcn).or..not.associated(flux%pfplsl).or..not.associated(flux%pfplsn)) return
    if (.not. associated(flux%pstrdu) .or. .not. associated(flux%pstrdv)) return
    if(size(state%t,1)/=p.or.size(state%t,2)<l.or.size(state%u,1)/=p.or.size(state%u,2)<l.or.size(state%v,1)/=p.or.size(state%v,2)<l) return
    if (lbound(state%t, 2) /= 1 .or. lbound(state%u, 2) /= 1 .or. lbound(state%v, 2) /= 1) return
    if (size(paux%paprsf, 1) /= p .or. size(paux%paprsf, 2) < l .or. size(paux%paphif, 1) /= p .or. size(paux%paphif, 2) < l) return
    if (lbound(paux%paprsf, 2) /= 1 .or. lbound(paux%paphif, 2) /= 1) return
    if (size(paux%paprs, 1) /= p .or. lbound(paux%paprs, 2) /= 0 .or. ubound(paux%paprs, 2) < l) return
    if (min(size(paux%pgelat), size(paux%pgaw)) < p) return
  if (size(flux%pfplcl, 1) /= p .or. size(flux%pfplcn, 1) /= p .or. size(flux%pfplsl, 1) /= p .or. size(flux%pfplsn, 1) /= p) return
    if (max(lbound(flux%pfplcl, 2), lbound(flux%pfplcn, 2), lbound(flux%pfplsl, 2), lbound(flux%pfplsn, 2)) > l) return
    if (min(ubound(flux%pfplcl, 2), ubound(flux%pfplcn, 2), ubound(flux%pfplsl, 2), ubound(flux%pfplsn, 2)) < l) return
    if (size(flux%pstrdu, 1) /= p .or. size(flux%pstrdv, 1) /= p) return
    if(lbound(flux%pstrdu,2)/=0.or.lbound(flux%pstrdv,2)/=0.or.min(ubound(flux%pstrdu,2),ubound(flux%pstrdv,2))<l) return
    if (use_runtime) then
      if (.not. ydegwwms%lozpr .or. ydegwwms%lgacalc .or. ydegwwms%lgsatl .or. ydegwwms%lgindl) return
      if (ydegwwms%nslope /= 1 .or. ydegwwms%ngauss /= 2 .or. ydegwwms%gptwo /= 2.0_real64) return
    end if
    if (ydegwwms%nlaunchlev > 0) then
      if (ydegwwms%nslope < -1 .or. ydegwwms%nslope > 2) return
      if (ydegwwms%gptwo /= 2.0_real64 .and. ydegwwms%gptwo /= 3.0_real64) return
      do launch = 1, ydegwwms%nlaunchlev
        if (ydegwwms%nlaunchl(launch) < 2 .or. ydegwwms%nlaunchl(launch) > l) return
      end do
      if (.not. admit_nonorographic_wave_parameters(constants, ydegwwms, first, last, p, l, paux%pgaw, use_runtime)) return
      if (ydegwwms%lgindl) then
   if (.not. allocated(ydsta%half_pressure) .or. .not. allocated(ydsta%temperature) .or. .not. allocated(ydsta%geopotential)) return
      if (lbound(ydsta%half_pressure, 1) /= 0 .or. lbound(ydsta%temperature, 1) /= 1 .or. lbound(ydsta%geopotential, 1) /= 1) return
        k = maxval(ydegwwms%nlaunchl(1:ydegwwms%nlaunchlev))
        if (ubound(ydsta%half_pressure, 1) < k - 1 .or. min(size(ydsta%temperature), size(ydsta%geopotential)) < k) return
      end if
    end if
    cells = int(p, int64)*int(l, int64)
    allocate (arena(4*cells + 3_int64*p), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    arena = 0.0_real64; offset = 1
    rain(1:p) => arena(offset:offset + p - 1); offset = offset + p
    du(1:p, 1:l) => arena(offset:offset + cells - 1); offset = offset + cells
    dv(1:p, 1:l) => arena(offset:offset + cells - 1); offset = offset + cells
    fu(1:p, 0:l) => arena(offset:offset + cells + p - 1); offset = offset + cells + p
    fv(1:p, 0:l) => arena(offset:offset + cells + p - 1)
    do j = first, last
      a = flux%pfplcl(j, l) + flux%pfplcn(j, l); a = a + flux%pfplsl(j, l); a = a + flux%pfplsn(j, l)
      rain(j) = max(0.0_real64, a)
    end do
    nogw_u(first:last, 1:l) = 0.0_real64; nogw_v(first:last, 1:l) = 0.0_real64
    do launch = 1, ydegwwms%nlaunchlev
      call gwdrag_wms(constants,ydsta,ydegwd,ydegwwms,first,last,p,l,launch,ydegwwms%gtphygwwms,state%t,state%u,state%v,paux%paprsf,paux%paprs,paux%paphif,paux%pgelat,paux%pgaw,rain,du,dv,fu,fv,child_status,use_runtime)
      if (child_status /= 0) then
        status = child_status; return
      end if
      do k = 1, l
        do j = first, last
          nogw_u(j, k) = nogw_u(j, k) + du(j, k); nogw_v(j, k) = nogw_v(j, k) + dv(j, k)
        end do
      end do
      do k = 0, l
        do j = first, last
          flux%pstrdu(j, k) = flux%pstrdu(j, k) - fu(j, k); flux%pstrdv(j, k) = flux%pstrdv(j, k) - fv(j, k)
        end do
      end do
    end do
    status = 0
  end subroutine
end module
