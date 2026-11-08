!> Own RADDRV preparation, complete radiation calculation and flux scatter.
!! FIELDS and MOTION are the live forecast owners, not duplicated model images.
!! PGPIN has native shape(columns,fields,blocks); pressure uses Pa, temperature
!! kelvin and returned radiative flux W/m2. Caller establishes the FP mode once.
!! Unchanged inactive surface/field words remain in their original owners.
!! Original ECMWF RADDRV science is retained; no model callback supplies a stage.
submodule(native_radiation_forecast_driver) native_radiation_forecast_driver_body
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, int64
  use yomhook, only: lhook, dr_hook, jphook
  use native_radiation_grid_preparation, only: radcfg
  use native_radiation_grid_driver, only: radintg
  use native_radiation_flux_diagnostics, only: raddiag
  use native_radiation_clock_views, only: radiation_clock_is_ready
  implicit none
contains
  module procedure raddrv
  status = 2
  if (.not. radiation_clock_is_ready(context%clock)) return
  if (.not. associated(context%setup) .or. .not. associated(context%configuration)) return
  if (.not. associated(context%surface) .or. .not. associated(context%surface_catalog)) return
  if (.not. associated(context%constants) .or. .not. associated(context%legacy_radiation)) return
  if (.not. associated(context%latitude_first) .or. .not. associated(context%latitude_points)) return
  if (.not. associated(context%latitude_sine) .or. .not. associated(context%longitude)) return
  if (.not. associated(context%terrain) .and. .not. associated(context%orography)) return
  if (.not. context%same_radiation_grid .or. .not. context%two_time_levels) return
  if (context%stochastic_enabled .or. context%chemistry_ozone) return
  if (context%setup%radiation%LEPO3RA .neqv. context%prognostic_ozone) return
  if (context%active_aerosols /= 0 .or. context%chemistry_species /= 0 .or. context%spread_species /= 0) return
  if (context%configuration%phy%LRAYFM .or. context%setup%radiation%LDIAGFORCING) return
  if (context%levels < 3 .or. context%levels > 256 .or. context%block_columns < 1 .or. context%block_columns > 1024) return
  if (local_points < 1 .or. local_points > 2097152 .or. context%local_points /= local_points) return
  if (associated(context%terrain)) then
    if (.not. allocated(context%terrain%blocks)) return
    if (size(context%terrain%blocks) < (local_points - 1)/context%block_columns + 1) return
    block
      integer :: terrain_block, terrain_count
      do terrain_block = 1, (local_points - 1)/context%block_columns + 1
        terrain_count = min(context%block_columns, local_points - (terrain_block - 1)*context%block_columns)
        if (.not. allocated(context%terrain%blocks(terrain_block)%orog)) return
        if (size(context%terrain%blocks(terrain_block)%orog) < terrain_count) return
      end do
    end block
  else
    if (.not. associated(context%orography)) return
  end if
  if (.not. allocated(fields%gfl)) return
  if (.not. associated(fields%constituents)) return
  context%thermal_constituents => fields%constituents
  if (size(fields%gfl, 1) /= context%block_columns .or. size(fields%gfl, 2) /= context%levels) return
  if (size(fields%gfl, 4) < (local_points - 1)/context%block_columns + 1) return
  if (context%prognostic_ozone) then
    if (context%ozone_plane < 1 .or. context%ozone_plane > size(fields%gfl, 3)) return
  end if
  if (size(pgpin, 1) /= context%block_columns .or. size(pgpin, 3) < (local_points - 1)/context%block_columns + 1) return
  if (min(context%water_plane, context%ice_plane, context%liquid_plane, context%rain_plane, context%snow_plane) < 1) return
  if(max(context%water_plane,context%ice_plane,context%liquid_plane,context%rain_plane,context%snow_plane)>size(fields%gfl,3))return
  if (.not. surface_views_ready(context, (local_points - 1)/context%block_columns + 1)) return
  if (context%configuration%ecmwf_physics%LERADIMPL) then
    if (.not. allocated(motion%gmvt1) .or. .not. allocated(motion%gmvt1s)) return
    if (min(motion%yt1%mu, motion%yt1%mv, motion%yt1%mt, motion%yt1%msp) < 1) return
    if (max(motion%yt1%mu, motion%yt1%mv, motion%yt1%mt) > size(motion%gmvt1, 3)) return
    if (motion%yt1%msp > size(motion%gmvt1s, 2)) return
  else
    if (.not. allocated(motion%gmv) .or. .not. allocated(motion%gmvs)) return
    if (min(motion%yph9%mu, motion%yph9%mv, motion%yph9%mt, motion%yph9%msp) < 1) return
    if (max(motion%yph9%mu, motion%yph9%mv, motion%yph9%mt) > size(motion%gmv, 3)) return
    if (motion%yph9%msp > size(motion%gmvs, 2)) return
  end if

  block
    REAL(KIND=JPRB), POINTER :: native_orography(:)
    REAL(KIND=JPRB), ALLOCATABLE :: ZPRE9(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZPRE9F(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZDELP9(:, :)
    LOGICAL, allocatable :: LLLAND(:)
    LOGICAL, allocatable :: LLLANDT(:)
    REAL(KIND=JPRB), allocatable :: ZMU0M(:)
    REAL(KIND=JPRB), allocatable :: ZMU0MT(:)
    REAL(KIND=JPRB), allocatable :: ZALBD(:, :)
    REAL(KIND=JPRB), allocatable :: ZALBP(:, :)
    REAL(KIND=JPRB), allocatable :: ZALBDT(:, :)
    REAL(KIND=JPRB), allocatable :: ZALBPT(:, :)
    REAL(KIND=JPRB), allocatable :: ZCCNL(:)
    REAL(KIND=JPRB), allocatable :: ZCCNO(:)
    REAL(KIND=JPRB), allocatable :: ZCCNLT(:)
    REAL(KIND=JPRB), allocatable :: ZCCNOT(:)
    REAL(KIND=JPRB), allocatable :: ZNEB(:, :)
    REAL(KIND=JPRB), allocatable :: ZQLI(:, :)
    REAL(KIND=JPRB), allocatable :: ZQSAT(:, :)
    REAL(KIND=JPRB), allocatable :: ZQICE(:, :)
    REAL(KIND=JPRB), allocatable :: ZQRAI(:, :)
    REAL(KIND=JPRB), allocatable :: ZRAIT(:, :)
    REAL(KIND=JPRB), allocatable :: ZAERO(:, :, :)
    REAL(KIND=JPRB), allocatable :: ZSPECTRALEMISS(:, :)
    REAL(KIND=JPRB), allocatable :: ZEMIT(:)
    REAL(KIND=JPRB), allocatable :: ZSPECTRALEMISST(:, :)
    REAL(KIND=JPRB), allocatable :: ZEMITT(:)
    REAL(KIND=JPRB), allocatable :: ZTCC(:)
    REAL(KIND=JPRB), allocatable :: ZCCC(:)
    REAL(KIND=JPRB), allocatable :: ZLCC(:)
    REAL(KIND=JPRB), allocatable :: ZMCC(:)
    REAL(KIND=JPRB), allocatable :: ZHCC(:)
    REAL(KIND=JPRB), allocatable :: ZTCCT(:)
    REAL(KIND=JPRB), allocatable :: ZCCCT(:)
    REAL(KIND=JPRB), allocatable :: ZLCCT(:)
    REAL(KIND=JPRB), allocatable :: ZMCCT(:)
    REAL(KIND=JPRB), allocatable :: ZHCCT(:)
    REAL(KIND=JPRB), allocatable :: ZFRSOCT(:, :)
    REAL(KIND=JPRB), allocatable :: ZFRTHCT(:, :)
    REAL(KIND=JPRB), allocatable :: ZTRENU9T(:)
    REAL(KIND=JPRB), allocatable :: ZVFLSMT(:)
    REAL(KIND=JPRB), allocatable :: ZFRTED(:, :)
    REAL(KIND=JPRB), allocatable :: ZTRSODT(:)
    REAL(KIND=JPRB), allocatable :: ZTRSODCT(:)
    REAL(KIND=JPRB), allocatable :: ZTRTEDCT(:)
    REAL(KIND=JPRB), allocatable :: ZSUDUT(:)
    REAL(KIND=JPRB), allocatable :: ZUVDFT(:)
    REAL(KIND=JPRB), allocatable :: ZPARFT(:)
    REAL(KIND=JPRB), allocatable :: ZPARCFT(:)
    REAL(KIND=JPRB), allocatable :: ZTINCFT(:)
    REAL(KIND=JPRB), allocatable :: ZFDIRT(:)
    REAL(KIND=JPRB), allocatable :: ZCDIRT(:)
    REAL(KIND=JPRB), allocatable :: ZVNTOPT(:)
    REAL(KIND=JPRB), allocatable :: ZVNBAST(:)
    REAL(KIND=JPRB), allocatable :: ZPERTT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZQO3(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAER(:, :, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAERMACCS(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAERMACCL(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAERTGS(:, :, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAERTGL(:, :, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAERMACCSJ(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAERMACCLJ(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZGHG(:, :, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZPRE9T(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZPRE9FT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZDELP9T(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZNEBT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZQLIT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZQSATT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZQICET(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZQSNOWT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZQRAIT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZRAITT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZFSDT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZFRSOT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZFRTHT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZTHT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZVREMTDT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZVREMTUT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZVRTRSWT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZVREMTCT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZVRTRSCT(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: Z2Q9T(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: Z2T9T(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: Z2O39T(:, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZAEROT(:, :, :)
    REAL(KIND=JPRB), ALLOCATABLE :: ZLWDERIVATIVE(:, :)
    INTEGER(KIND=JPIM) :: IBL
    INTEGER(KIND=JPIM) :: IEND
    INTEGER(KIND=JPIM) :: IFDIA
    INTEGER(KIND=JPIM) :: IGL1
    INTEGER(KIND=JPIM) :: IGL2
    INTEGER(KIND=JPIM) :: IIDIA
    INTEGER(KIND=JPIM) :: IST
    INTEGER(KIND=JPIM) :: JK
    INTEGER(KIND=JPIM) :: JL
    INTEGER(KIND=JPIM) :: JSTGLO
    INTEGER(KIND=JPIM) :: JSW
    INTEGER(KIND=JPIM) :: JLW
    INTEGER(KIND=JPIM) :: IO3_CHEM
    integer :: allocation_status
    real(jphook) :: ZHOOK_HANDLE
    integer(int64) :: workspace_bytes
    workspace_bytes = 0_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*int(storage_size(.false.)/8, int64)
    workspace_bytes = workspace_bytes + (int(local_points, int64))*int(storage_size(.false.)/8, int64)
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%setup%radiation%NTSW, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%setup%radiation%NTSW, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%setup%radiation%NTSW, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%setup%radiation%NTSW, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
workspace_bytes=workspace_bytes+(int(context%block_columns,int64)*int(context%levels,int64)*int(context%active_aerosols,int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%setup%radiation%NLWEMISS, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%setup%radiation%NLWEMISS, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int((1) - (0) + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int((1) - (0) + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%setup%radiation%NLWOUT, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(0, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int((context%levels) - (0) + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int((context%levels) - (0) + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(local_points, int64)*int(context%levels + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(1, int64)*int(1, int64)*int(1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int((context%levels) - (0) + 1, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
    workspace_bytes = workspace_bytes + (int(context%block_columns, int64)*int(context%levels, int64))*8_int64
! Eight GiB bounds the explicit per-call private grid workspace.
! No numerical field is allocated before this complete count is checked.
    if (workspace_bytes > 8589934592_int64) return
    allocate (LLLAND(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (LLLANDT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZMU0M(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZMU0MT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZALBD(context%block_columns, context%setup%radiation%NTSW), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZALBP(context%block_columns, context%setup%radiation%NTSW), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZALBDT(local_points, context%setup%radiation%NTSW), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZALBPT(local_points, context%setup%radiation%NTSW), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCCNL(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCCNO(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCCNLT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCCNOT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZNEB(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZQLI(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZQSAT(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZQICE(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZQRAI(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZRAIT(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZAERO(context%block_columns, context%levels, context%active_aerosols), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZSPECTRALEMISS(context%block_columns, context%setup%radiation%NLWEMISS), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZEMIT(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZSPECTRALEMISST(local_points, context%setup%radiation%NLWEMISS), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZEMITT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTCC(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCCC(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZLCC(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZMCC(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZHCC(context%block_columns), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTCCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCCCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZLCCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZMCCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZHCCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZFRSOCT(local_points, 0:1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZFRTHCT(local_points, 0:1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTRENU9T(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZVFLSMT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZFRTED(local_points, context%setup%radiation%NLWOUT), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTRSODT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTRSODCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTRTEDCT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZSUDUT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZUVDFT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZPARFT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZPARCFT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZTINCFT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZFDIRT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZCDIRT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZVNTOPT(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZVNBAST(local_points), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    allocate (ZPERTT(local_points, 0), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    if (lhook) call dr_hook('RADDRV', 0, ZHOOK_HANDLE)
    ALLOCATE (ZPRE9T(local_points, 0:context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZPRE9FT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZDELP9T(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZNEBT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZQLIT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZQSATT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZQICET(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZQSNOWT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZQRAIT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZRAITT(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZFRSOT(local_points, 0:context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZFRTHT(local_points, 0:context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZTHT(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZVREMTDT(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZVREMTUT(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZVRTRSWT(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZVREMTCT(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZVRTRSCT(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (Z2Q9T(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (Z2T9T(local_points, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZLWDERIVATIVE(local_points, context%levels + 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    IF (context%prognostic_ozone) THEN
      ALLOCATE (Z2O39T(local_points, context%levels), stat=allocation_status)
    ELSE
      ALLOCATE (Z2O39T(1, 1), stat=allocation_status)
    END IF
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZFSDT(1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAEROT(1, 1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZQO3(1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAER(1, 1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZGHG(1, 1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAERMACCS(1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAERMACCL(1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAERMACCSJ(1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAERMACCLJ(1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAERTGS(1, 1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZAERTGL(1, 1, 1), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    IO3_CHEM = -999
    ALLOCATE (ZPRE9(context%block_columns, 0:context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZPRE9F(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    ALLOCATE (ZDELP9(context%block_columns, context%levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    DO JSTGLO = 1, local_points, context%block_columns
      IST = 1
      IEND = MIN(context%block_columns, local_points - JSTGLO + 1)
      IBL = (JSTGLO - 1)/context%block_columns + 1
      IF (context%configuration%ecmwf_physics%LERADIMPL) THEN
      if (associated(context%terrain)) then
        native_orography => context%terrain%blocks(IBL)%orog
      else
        native_orography => context%orography(:, 1, IBL)
      end if
call radcfg(context,IST,IEND,JSTGLO,size(pgpin,2),LLLAND,native_orography,PGPIN(:,:,IBL),fields%gfl(:,:,:,IBL),motion%gmvt1(:,:, motion%yt1%MU,IBL),motion%gmvt1(:,:, motion%yt1%MV,IBL),motion%gmvt1(:,:, motion%yt1%MT,IBL),motion%gmvt1s(:,motion%yt1%MSP,IBL),context%surface%sp_sb(:,:,:,IBL),context%surface%sp_sg(:,:,:,IBL),context%surface%sp_sl(:,:,IBL),context%surface%sp_rr(:,:,IBL),context%surface%sd_vf(:,:,IBL),context%surface%sd_vn(:,:,IBL),context%surface%sd_vd(:,:,IBL),ZALBD,ZALBP,ZCCNL,ZCCNO,ZPRE9,ZPRE9F,ZNEB,ZCCC,ZHCC,ZLCC,ZMCC,ZTCC,context%longitude(:,IBL),ZDELP9,ZSPECTRALEMISS,ZEMIT,context%latitude_sine(:,IBL),ZMU0M,ZQSAT,ZQICE,ZQLI,ZQRAI,ZRAIT,ZAERO,status)
      if (status /= 0) return
      ELSE
      if (associated(context%terrain)) then
        native_orography => context%terrain%blocks(IBL)%orog
      else
        native_orography => context%orography(:, 1, IBL)
      end if
call radcfg(context,IST,IEND,JSTGLO,size(pgpin,2),LLLAND,native_orography,PGPIN(:,:,IBL),fields%gfl(:,:,:,IBL),motion%gmv(:,:, motion%yph9%MU,IBL),motion%gmv(:,:, motion%yph9%MV,IBL),motion%gmv(:,:, motion%yph9%MT,IBL),motion%gmvs(:,motion%yph9%MSP,IBL),context%surface%sp_sb(:,:,:,IBL),context%surface%sp_sg(:,:,:,IBL),context%surface%sp_sl(:,:,IBL),context%surface%sp_rr(:,:,IBL),context%surface%sd_vf(:,:,IBL),context%surface%sd_vn(:,:,IBL),context%surface%sd_vd(:,:,IBL),ZALBD,ZALBP,ZCCNL,ZCCNO,ZPRE9,ZPRE9F,ZNEB,ZCCC,ZHCC,ZLCC,ZMCC,ZTCC,context%longitude(:,IBL),ZDELP9,ZSPECTRALEMISS,ZEMIT,context%latitude_sine(:,IBL),ZMU0M,ZQSAT,ZQICE,ZQLI,ZQRAI,ZRAIT,ZAERO,status)
      if (status /= 0) return
      END IF
      DO JL = IST, IEND
        LLLANDT(JSTGLO + JL - 1) = LLLAND(JL)
        ZCCCT(JSTGLO + JL - 1) = ZCCC(JL)
        ZHCCT(JSTGLO + JL - 1) = ZHCC(JL)
        ZLCCT(JSTGLO + JL - 1) = ZLCC(JL)
        ZMCCT(JSTGLO + JL - 1) = ZMCC(JL)
        ZTCCT(JSTGLO + JL - 1) = ZTCC(JL)
        ZEMITT(JSTGLO + JL - 1) = ZEMIT(JL)
        ZMU0MT(JSTGLO + JL - 1) = ZMU0M(JL)
        ZTRENU9T(JSTGLO + JL - 1) = context%surface%sp_rr(JL, radiation_surface_index(context, 'YSP_RR%YT', 3), IBL)
        ZVFLSMT(JSTGLO + JL - 1) = context%surface%sd_vf(JL, radiation_surface_index(context, 'YSD_VF%YLSM', 1), IBL)
        ZVNTOPT(JSTGLO + JL - 1) = context%surface%sd_vn(JL, radiation_surface_index(context, 'YSD_VN%YTOP', 1), IBL)
        ZVNBAST(JSTGLO + JL - 1) = context%surface%sd_vn(JL, radiation_surface_index(context, 'YSD_VN%YBAS', 1), IBL)
        ZCCNLT(JSTGLO + JL - 1) = ZCCNL(JL)
        ZCCNOT(JSTGLO + JL - 1) = ZCCNO(JL)
      END DO
      DO JLW = 1, context%setup%radiation%NLWEMISS
      DO JL = IST, IEND
        ZSPECTRALEMISST(JSTGLO + JL - 1, JLW) = ZSPECTRALEMISS(JL, JLW)
      END DO
      END DO
      DO JSW = 1, context%setup%radiation%NTSW
      DO JL = IST, IEND
        ZALBDT(JSTGLO + JL - 1, JSW) = ZALBD(JL, JSW)
        ZALBPT(JSTGLO + JL - 1, JSW) = ZALBP(JL, JSW)
      END DO
      END DO
      DO JK = 0, context%levels
      DO JL = IST, IEND
        ZPRE9T(JSTGLO + JL - 1, JK) = ZPRE9(JL, JK)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZPRE9FT(JSTGLO + JL - 1, JK) = ZPRE9F(JL, JK)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZNEBT(JSTGLO + JL - 1, JK) = ZNEB(JL, JK)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZQSATT(JSTGLO + JL - 1, JK) = ZQSAT(JL, JK)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZQICET(JSTGLO + JL - 1, JK) = fields%gfl(JL, JK, context%ice_plane, IBL)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZQSNOWT(JSTGLO + JL - 1, JK) = fields%gfl(JL, JK, context%snow_plane, IBL)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZQLIT(JSTGLO + JL - 1, JK) = fields%gfl(JL, JK, context%liquid_plane, IBL)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZQRAIT(JSTGLO + JL - 1, JK) = fields%gfl(JL, JK, context%rain_plane, IBL)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZRAITT(JSTGLO + JL - 1, JK) = ZRAIT(JL, JK)
      END DO
      END DO
      DO JK = 1, context%levels
      DO JL = IST, IEND
        Z2Q9T(JSTGLO + JL - 1, JK) = fields%gfl(JL, JK, context%water_plane, IBL)
      END DO
      END DO
      DO JK = 1, context%levels
      IF (context%configuration%ecmwf_physics%LERADIMPL) THEN
      DO JL = IST, IEND
        Z2T9T(JSTGLO + JL - 1, JK) = motion%gmvt1(JL, JK, motion%yt1%MT, IBL)
      END DO
      ELSE
      DO JL = IST, IEND
        Z2T9T(JSTGLO + JL - 1, JK) = motion%gmv(JL, JK, motion%yph9%MT, IBL)
      END DO
      END IF
      END DO
      IF (context%prognostic_ozone) THEN
      DO JK = 1, context%levels
      DO JL = IST, IEND
        Z2O39T(JSTGLO + JL - 1, JK) = fields%gfl(JL, JK, context%ozone_plane, IBL)
      END DO
      END DO
      END IF
      DO JK = 1, context%levels
      DO JL = IST, IEND
        ZDELP9T(JSTGLO + JL - 1, JK) = ZDELP9(JL, JK)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        ZVREMTDT(JSTGLO + JL - 1, JK) = context%setup%fluxes%EMTD(JL, JK, IBL)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        ZVREMTUT(JSTGLO + JL - 1, JK) = 0.0
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        ZVRTRSWT(JSTGLO + JL - 1, JK) = context%setup%fluxes%TRSW(JL, JK, IBL)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        ZVREMTCT(JSTGLO + JL - 1, JK) = context%setup%fluxes%EMTC(JL, JK, IBL)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        ZVRTRSCT(JSTGLO + JL - 1, JK) = context%setup%fluxes%TRSC(JL, JK, IBL)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        ZLWDERIVATIVE(JSTGLO + JL - 1, JK) = context%setup%fluxes%DERIVATIVELW(JL, JK, IBL)
      END DO
      END DO
    END DO
    IF (ALLOCATED(ZPRE9)) DEALLOCATE (ZPRE9)
    IF (ALLOCATED(ZPRE9F)) DEALLOCATE (ZPRE9F)
    IF (ALLOCATED(ZDELP9)) DEALLOCATE (ZDELP9)
call radintg(context,context%levels,context%setup%radiation%NMODE,ZALBDT,ZALBPT,ZCCNLT,ZCCNOT,ZPRE9T,ZPRE9FT,context%setup%gases%RCARDI,ZNEBT,ZQO3,ZAER,ZAERMACCS,ZAERMACCL,ZAERMACCSJ,ZAERMACCLJ,ZAERTGS,ZAERTGL,ZAEROT,ZGHG,ZDELP9T,ZSPECTRALEMISST,ZMU0MT,Z2Q9T,ZQSATT,ZQICET,ZQSNOWT,ZQLIT,ZFSDT,ZQRAIT,ZRAITT,ZVFLSMT,Z2T9T,Z2O39T,ZTRENU9T,ZVREMTDT,ZVREMTUT,ZVRTRSWT,ZVRTRSCT,ZVREMTCT,ZVNTOPT,ZVNBAST,ZPERTT,ZEMITT,ZTHT,ZFRTED,ZTRSODT,ZTRSODCT,ZTRTEDCT,ZSUDUT,ZUVDFT,ZPARFT,ZPARCFT,ZTINCFT,ZFDIRT,ZCDIRT,ZLWDERIVATIVE,status)
    if (status /= 0) return
    IIDIA = 0
    IFDIA = 0
    IGL1 = 1
    IGL2 = size(context%latitude_first)
status=raddiag(IGL1,IGL2,context%latitude_first,context%latitude_points,context%setup%gases%RRAE,context%legacy_radiation%RII0,ZMU0MT,ZVREMTDT,ZVRTRSWT,ZVRTRSCT,ZVREMTCT,ZFRTHCT,ZFRTHT,ZFRSOCT,ZFRSOT)
    if (status /= 0) return
    DO JSTGLO = 1, local_points, context%block_columns
      IST = 1
      IEND = MIN(context%block_columns, local_points - JSTGLO + 1)
      IBL = (JSTGLO - 1)/context%block_columns + 1
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        context%setup%fluxes%EMTD(JL, JK, IBL) = ZVREMTDT(JSTGLO + JL - 1, JK)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        context%setup%fluxes%TRSW(JL, JK, IBL) = ZVRTRSWT(JSTGLO + JL - 1, JK)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        context%setup%fluxes%EMTC(JL, JK, IBL) = ZVREMTCT(JSTGLO + JL - 1, JK)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        context%setup%fluxes%TRSC(JL, JK, IBL) = ZVRTRSCT(JSTGLO + JL - 1, JK)
      END DO
      END DO
      DO JK = 1, context%levels + 1
      DO JL = IST, IEND
        context%setup%fluxes%DERIVATIVELW(JL, JK, IBL) = ZLWDERIVATIVE(JSTGLO + JL - 1, JK)
      END DO
      END DO
      DO JL = IST, IEND
        context%setup%fluxes%SRSWDCS(JL, IBL) = ZSUDUT(JSTGLO + JL - 1)
        context%setup%fluxes%SRSWD(JL, IBL) = ZTRSODT(JSTGLO + JL - 1)
        context%setup%fluxes%SRSWDC(JL, IBL) = ZTRSODCT(JSTGLO + JL - 1)
        context%setup%fluxes%SRLWDC(JL, IBL) = ZTRTEDCT(JSTGLO + JL - 1)
        context%setup%fluxes%SRSWUVB(JL, IBL) = ZUVDFT(JSTGLO + JL - 1)
        context%setup%fluxes%SRSWPAR(JL, IBL) = ZPARFT(JSTGLO + JL - 1)
        context%setup%fluxes%SRSWPARC(JL, IBL) = ZPARCFT(JSTGLO + JL - 1)
        context%setup%fluxes%SRSWTINC(JL, IBL) = ZTINCFT(JSTGLO + JL - 1)
        context%setup%fluxes%SRFDIR(JL, IBL) = ZFDIRT(JSTGLO + JL - 1)
        context%setup%fluxes%SRCDIR(JL, IBL) = ZCDIRT(JSTGLO + JL - 1)
      END DO
      DO JK = 1, context%setup%radiation%NLWOUT
      DO JL = IST, IEND
        context%setup%fluxes%SRLWD(JL, JK, IBL) = ZFRTED(JSTGLO + JL - 1, JK)
      END DO
      END DO
    END DO
    DEALLOCATE (ZPRE9T, ZPRE9FT, ZDELP9T, ZNEBT, ZQLIT, ZQSATT, ZQICET, ZQSNOWT)
    DEALLOCATE (ZQRAIT, ZRAITT, ZFRSOT, ZFRTHT, ZTHT, ZVREMTDT, ZVREMTUT)
    DEALLOCATE (ZVRTRSWT, ZVREMTCT, ZVRTRSCT, Z2Q9T, Z2T9T, Z2O39T)
    DEALLOCATE (ZQO3, ZAER)
    DEALLOCATE (ZAEROT, ZFSDT)
    IF (ALLOCATED(ZGHG)) DEALLOCATE (ZGHG)
    IF (ALLOCATED(ZAERMACCS)) DEALLOCATE (ZAERMACCS)
    IF (ALLOCATED(ZAERMACCL)) DEALLOCATE (ZAERMACCL)
    IF (ALLOCATED(ZAERMACCSJ)) DEALLOCATE (ZAERMACCSJ)
    IF (ALLOCATED(ZAERMACCLJ)) DEALLOCATE (ZAERMACCLJ)
    IF (ALLOCATED(ZAERTGS)) DEALLOCATE (ZAERTGS)
    IF (ALLOCATED(ZAERTGL)) DEALLOCATE (ZAERTGL)
    IF (ALLOCATED(ZLWDERIVATIVE)) DEALLOCATE (ZLWDERIVATIVE)
    if (lhook) call dr_hook('RADDRV', 1, ZHOOK_HANDLE)
    status = 0
  end block
  end procedure
!> Admit all surface owners and selectors before their first selected access.
  logical function surface_views_ready(context, blocks) result(ready)
    type(native_radiation_driver_context), intent(in) :: context
    integer, intent(in) :: blocks
    integer :: index, column, j
    ready = .false.
   if(.not.allocated(context%surface%sd_vf).or..not.allocated(context%surface%sd_vn).or..not.allocated(context%surface%sd_vd))return
    if (.not. allocated(context%surface%sp_rr) .or. .not. allocated(context%surface%sp_sl)) return
    if (.not. allocated(context%surface%sp_sb) .or. .not. allocated(context%surface%sp_sg)) return
    if(size(context%surface%sd_vf,3)<blocks.or.size(context%surface%sd_vn,3)<blocks.or.size(context%surface%sd_vd,3)<blocks)return
    if (size(context%surface%sp_rr, 3) < blocks .or. size(context%surface%sp_sl, 3) < blocks) return
    if (size(context%surface%sp_sb, 4) < blocks .or. size(context%surface%sp_sg, 4) < blocks) return
    index = radiation_surface_index(context, 'YSD_VD%YZ0F', 1)
    if (index < 1 .or. index > size(context%surface%sd_vd, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YALBF', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YCI', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YCLK', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YCO2TYP', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YCUR', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YCVH', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YCVL', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YEMISF', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YGETRL', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YLAIH', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YLAIL', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YLSM', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YSOTY', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YTVH', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YTVL', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VF%YZ0F', 1)
    if (index < 1 .or. index > size(context%surface%sd_vf, 2)) return
    index = radiation_surface_index(context, 'YSD_VN%YACPR', 1)
    if (index < 1 .or. index > size(context%surface%sd_vn, 2)) return
    index = radiation_surface_index(context, 'YSD_VN%YBAS', 1)
    if (index < 1 .or. index > size(context%surface%sd_vn, 2)) return
    index = radiation_surface_index(context, 'YSD_VN%YTOP', 1)
    if (index < 1 .or. index > size(context%surface%sd_vn, 2)) return
    index = radiation_surface_index(context, 'YSP_RR%YT', 3)
    if (index < 1 .or. index > size(context%surface%sp_rr, 2)) return
    index = radiation_surface_index(context, 'YSP_RR%YW', 3)
    if (index < 1 .or. index > size(context%surface%sp_rr, 2)) return
    index = radiation_surface_index(context, 'YSP_SB%YQ', 3)
    if (index < 1 .or. index > size(context%surface%sp_sb, 3)) return
    index = radiation_surface_index(context, 'YSP_SG%YA', 3)
    if (index < 1 .or. index > size(context%surface%sp_sg, 3)) return
    index = radiation_surface_index(context, 'YSP_SG%YF', 3)
    if (index < 1 .or. index > size(context%surface%sp_sg, 3)) return
    index = radiation_surface_index(context, 'YSP_SG%YR', 3)
    if (index < 1 .or. index > size(context%surface%sp_sg, 3)) return
    index = radiation_surface_index(context, 'YSP_SL%YLICD', 3)
    if (index < 1 .or. index > size(context%surface%sp_sl, 2)) return
    index = radiation_surface_index(context, 'YSP_SL%YLICT', 3)
    if (index < 1 .or. index > size(context%surface%sp_sl, 2)) return
    if (context%surface_catalog%albedo_first < 1 .or. context%surface_catalog%albedo_last > size(context%surface%sd_vf, 2)) return
    if (context%surface_catalog%albedo_last < context%surface_catalog%albedo_first) return
    ready = .true.
  end function
end submodule
