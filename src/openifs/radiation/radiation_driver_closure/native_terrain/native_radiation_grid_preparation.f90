!> Prepare fine-grid pressure, astronomy and complete surface/cloud inputs.
!! Surface arrays retain native column/layer/field storage and existing owners.
!! Inputs use Pa, kelvin, kg/kg and radian coordinates. Status0 completes.
!! Source attribution: ECMWF RADCFG; no original numerical entry is imported.
module native_radiation_grid_preparation
  use iso_fortran_env, only: JPIM => int32, JPRB => real64, real64, int32
  use yomhook, only: lhook, dr_hook, jphook
  use native_radiation_forecast_driver, only: native_radiation_driver_context, radiation_surface_index
  use md2asm_hybrid_pressure_one_based, only: compute_hybrid_pressure_one_based
  use md2asm_moist_air_gas_properties, only: moist_air_constants, compute_moist_air_properties
  use native_radiation_solar_geometry_from_clock, only: cos_sza_openifs_source_compatibility
  use native_radiation_parameter_preparation, only: radpar
  use native_radiation_clock_views, only: radiation_clock_is_ready
  implicit none
  private
  public :: radcfg
contains
subroutine radcfg(context,KST,KEND,KSTGLO,KFLDS,LDLAND,POROG,PB2,PGFL,PUT9,PVT9,PTT9,PSPT9,PSP_SB,PSP_SG,PSP_SL,PSP_RR,PSD_VF,PSD_VN,PSD_VD,PALBD,PALBP,PCCNL,PCCNO,PPRE9,PPRE9F,PNEB,PCCC,PHCC,PLCC,PMCC,PTCC,PGELAM,PDELP9,PSPECTRALEMISS,PEMIT,PGEMU,PMU0M,PQSAT,PQICE,PQLI,PQRAIN,PRAINT,PAERO,status)
    type(native_radiation_driver_context), intent(inout) :: context
    INTEGER(KIND=JPIM), INTENT(IN) :: KFLDS
    INTEGER(KIND=JPIM), INTENT(IN) :: KST
    INTEGER(KIND=JPIM), INTENT(IN) :: KEND
    INTEGER(KIND=JPIM), INTENT(IN) :: KSTGLO
    LOGICAL, INTENT(INOUT) :: LDLAND(context%block_columns)
! Source-selected RADCFG does not read POROG; retain its actual borrowed span.
    REAL(KIND=JPRB), INTENT(IN) :: POROG(:)
    REAL(KIND=JPRB), INTENT(IN) :: PB2(context%block_columns, KFLDS)
    REAL(KIND=JPRB), INTENT(INOUT) :: PGFL(:, :, :)
    REAL(KIND=JPRB), INTENT(IN) :: PUT9(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(IN) :: PVT9(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTT9(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(IN) :: PSPT9(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSP_SB(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSP_SG(:, :, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSP_SL(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSP_RR(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSD_VF(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSD_VN(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSD_VD(:, :)
    REAL(KIND=JPRB), INTENT(INOUT) :: PALBD(context%block_columns, context%setup%radiation%NTSW)
    REAL(KIND=JPRB), INTENT(INOUT) :: PALBP(context%block_columns, context%setup%radiation%NTSW)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCCNL(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCCNO(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PPRE9(context%block_columns, 0:context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PPRE9F(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PNEB(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PCCC(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PHCC(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PLCC(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMCC(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PTCC(context%block_columns)
    REAL(KIND=JPRB), INTENT(IN) :: PGELAM(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PDELP9(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PSPECTRALEMISS(context%block_columns, context%setup%radiation%NLWEMISS)
    REAL(KIND=JPRB), INTENT(INOUT) :: PEMIT(context%block_columns)
    REAL(KIND=JPRB), INTENT(IN) :: PGEMU(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PMU0M(context%block_columns)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQSAT(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQICE(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQLI(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PQRAIN(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PRAINT(context%block_columns, context%levels)
    REAL(KIND=JPRB), INTENT(INOUT) :: PAERO(context%block_columns, context%levels, context%active_aerosols)
    integer(int32), intent(out) :: status
    integer :: allocation_status, cell
    real(jphook) :: hook
    type(moist_air_constants) :: gas_constants
    real(real64), allocatable :: ZXYB9(:, :, :), ZR9(:, :), ZCP9(:, :)
    status = 2
    if (.not. radiation_clock_is_ready(context%clock)) return
    if (.not. associated(context%constants) .or. .not. associated(context%setup)) return
    if (.not. associated(context%pressure_controls) .or. .not. associated(context%thermal_constituents)) return
    if (.not. associated(context%surface_catalog)) return
    if (.not. context%two_time_levels .or. context%active_aerosols /= 0) return
    if (.not. context%pressure_controls%finite_elements) return
    if (any(context%pressure_field_indices /= [1, 2, 3, 4, 5, 6, 7])) return
    if (KST < 1 .or. KEND > context%block_columns .or. KST > KEND) return
    if (size(PGFL, 1) /= context%block_columns .or. size(PGFL, 2) /= context%levels) return
    if (min(context%water_plane, context%liquid_plane, context%ice_plane, context%cloud_fraction_plane) < 1) return
    if (max(context%water_plane, context%liquid_plane, context%ice_plane, context%cloud_fraction_plane) > size(PGFL, 3)) return
    if (context%vertical_velocity_plane < 1 .or. context%vertical_velocity_plane + context%levels - 1 > size(PB2, 2)) return
allocate(ZXYB9(context%block_columns,context%levels,7),ZR9(context%block_columns,context%levels),ZCP9(context%block_columns,context%levels),stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    if (lhook) call dr_hook('RADCFG', 0, hook)
    do cell = KST, KEND
      PPRE9(cell, context%levels) = exp(PSPT9(cell))
    end do
    ZXYB9(:, :, 1) = PDELP9
call compute_hybrid_pressure_one_based(context%pressure_controls,context%block_columns,KST,KEND,context%levels,context%half_a,context%half_b,PPRE9,status,7,context%pressure_field_indices,context%vc,context%full_a,context%full_b,context%delta_a,context%delta_b,ZXYB9,PPRE9F)
    if (status /= 0) return
    PDELP9 = ZXYB9(:, :, 1)
gas_constants=moist_air_constants(context%constants%rd,context%constants%rcpd,context%constants%rv,context%constants%rcpv,context%constants%rcw,context%constants%rcs)
call compute_moist_air_properties(gas_constants,context%block_columns,KST,KEND,context%levels,[.false.,.false.,.false.,.false.,.false.,.false.],status,heat_capacity=ZCP9,gas_constant=ZR9,generic_fields=PGFL,constituents=context%thermal_constituents,layout_code=9)
    if (status /= 0) return
call cos_sza_openifs_source_compatibility(context%constants,context%setup%radiation,context%clock,context%clock,KST,KEND,context%block_columns,PGEMU,PGELAM,.true.,PMU0M)
CALL RADPAR (context, KST,KEND,context%block_columns,size(PSP_SB,2),size(PSP_SG,2),KSTGLO, 1,context%levels,context%clock%NSTART,context%clock%step, PPRE9   ,PPRE9F, PTT9 ,PGFL(:,:,context%water_plane), PUT9 ,PVT9, PGFL(:,:,context%liquid_plane) ,PGFL(:,:,context%ice_plane) ,PGFL(:,:,context%cloud_fraction_plane), PSP_SG(:,:,radiation_surface_index(context,'YSP_SG%YF',3) )     ,PSP_SG(:,:,radiation_surface_index(context,'YSP_SG%YR',3)), PSP_RR(:,radiation_surface_index(context,'YSP_RR%YT',3) ), PSP_RR(:,radiation_surface_index(context,'YSP_RR%YW',3)  )    ,PSP_SB(:,:,radiation_surface_index(context,'YSP_SB%YQ',3) ),PB2(:,context%vertical_velocity_plane:context%vertical_velocity_plane+context%levels-1), PSP_SL(:,radiation_surface_index(context,'YSP_SL%YLICD',3)), PSP_SL(:,radiation_surface_index(context,'YSP_SL%YLICT',3)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YCLK',1))     , PSD_VF(:,radiation_surface_index(context,'YSD_VF%YALBF',1))    , PSD_VF(:,context%surface_catalog%albedo_first:context%surface_catalog%albedo_last), PSP_SG(:,:,radiation_surface_index(context,'YSP_SG%YA',3))   ,PSD_VF(:,radiation_surface_index(context,'YSD_VF%YEMISF',1)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YLSM',1))     ,PMU0M              ,PGEMU, PSD_VF(:,radiation_surface_index(context,'YSD_VF%YZ0F',1)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YTVL',1)),PSD_VF(:,radiation_surface_index(context,'YSD_VF%YCO2TYP',1)),PSD_VF(:,radiation_surface_index(context,'YSD_VF%YTVH',1)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YCVL',1))     ,PSD_VF(:,radiation_surface_index(context,'YSD_VF%YCVH',1)),PSD_VF(:,radiation_surface_index(context,'YSD_VF%YCUR',1)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YLAIL',1))    ,PSD_VF(:,radiation_surface_index(context,'YSD_VF%YLAIH',1)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YSOTY',1))    ,PSD_VF(:,radiation_surface_index(context,'YSD_VF%YGETRL',1)), PSD_VF(:,radiation_surface_index(context,'YSD_VF%YCI',1)), PSD_VN(:,radiation_surface_index(context,'YSD_VN%YTOP',1))     ,PSD_VN(:,radiation_surface_index(context,'YSD_VN%YBAS',1)) ,PSD_VN(:,radiation_surface_index(context,'YSD_VN%YACPR',1)), LDLAND  ,PALBD  ,PALBP  ,PCCNL  ,PCCNO, PNEB    ,PQICE  ,PQLI   ,PQSAT, PCCC    ,PHCC   ,PLCC   ,PMCC   ,PTCC, PSPECTRALEMISS,PEMIT, PSD_VD(:,radiation_surface_index(context,'YSD_VD%YZ0F',1)) ,status)
    if (status /= 0) return
    PQRAIN(KST:KEND, :) = 0.0_real64
    PRAINT(KST:KEND, :) = 0.0_real64
    if (lhook) call dr_hook('RADCFG', 1, hook)
    status = 0

  end subroutine
end module
