! (C) Copyright ECMWF and Meteo-France.
! Data-only trajectory declarations derive from YOMTRAJ.
! This software is licensed under the Apache Licence Version 2.0:
! http://www.apache.org/licenses/LICENSE-2.0.
! ECMWF retains its privileges and immunities as an intergovernmental organisation.
!> Native inactive trajectory declarations. Array fields borrow their payloads.
!! Bounds are dimensionless. Fields keep the source-declared precision.
!! These data declarations contain no numerical or original method.
module forecast_native_trajectory_types
  use iso_fortran_env, only: int32, real32, real64
  use spectral_field_storage_port, only: spectral_field_state
  implicit none
  integer, parameter :: JPIM = int32, JPRB = real64, MKINDTRAJ = real32
  TYPE TRAJ_PHYS_TYPE
    LOGICAL :: LASTCHUNK
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: PTT95 => NULL(), PQT95 => NULL(), PUT95 => NULL(), PVT95 => NULL(), &
    &    PTET5 => NULL(), PTEQ5 => NULL(), PTEU5 => NULL(), PTEV5 => NULL(), PVVEL5 => NULL(), PGFLT9_LRCH45 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PLT95 => NULL(), PIT95 => NULL(), PTEL5 => NULL(), PTEI5 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: PEMTED5 => NULL(), PTRSOL5 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :, :), POINTER :: PGFLT9_GHG5 => NULL(), PTEGFL_GHG5 => NULL(), &
                        & PGFLT9_AERO5 => NULL(), PTEGFL_AERO5 => NULL(), PGFLT9_CHEM5 => NULL(), PTEGFL_CHEM5 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:,:), POINTER :: PTSA95=>NULL(), PWSA95=>NULL(), PSNS95=>NULL(),PRSN95=>NULL(), PTIA95=>NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:), POINTER :: PSPT95 => NULL(), PSPT15 => NULL(), PWL95 => NULL(), &
   &    PTL95 => NULL(), PNTOP5 => NULL(), PNBAS5 => NULL(), PACPR5 => NULL(), PACCPR5 => NULL(), PGZ0M5 => NULL(), PLZ0H5 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: PUSTRTI5 => NULL(), PVSTRTI5 => NULL(), PAHFSTI5 => NULL(), &
    &    PEVAPTI5 => NULL(), PTSKTI5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: RR2 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PUT9MF5 => NULL(), PVT9MF5 => NULL(), PTT9MF5 => NULL(), PQT9MF5 => NULL(), &
    &    PQLT9MF5 => NULL(), PQIT9MF5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PSP9MF5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PKTROVMF => NULL(), PKUROVMF => NULL(), PRAPGWDMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:,:), POINTER  :: PQLMF=>NULL(),PQIMF=>NULL(),PQRMF=>NULL(),PQSMF=>NULL(),PLIQCVPPKFMF=>NULL(), &
    &    PNEBCVPPKFMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PCDROVMF => NULL(), PCHROVMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PQSSMF => NULL(), PTSMF => NULL(), PSNSMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PQSS1MF => NULL(), PTS1MF => NULL()
  END TYPE TRAJ_PHYS_TYPE

  TYPE CLD_TRAJ_TYPE
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: YA => NULL(), YL => NULL(), YI => NULL()
  END TYPE CLD_TRAJ_TYPE

  TYPE TRAJ_RAINGG_TLAD_TYPE
    LOGICAL :: LASTCHUNK
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: RR => NULL()
  END TYPE TRAJ_RAINGG_TLAD_TYPE

  TYPE TRAJ_PHYS_TLAD_TYPE
    LOGICAL :: LASTCHUNK
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PEMTED5 => NULL(), PTRSOL5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PA5 => NULL(), PL5 => NULL(), PI5 => NULL(), &
     & PLUDE5 => NULL(), PLU5 => NULL(), PMFU5 => NULL(), PMFD5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PTENUWM5 => NULL(), PTENVWM5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PTENTVD5 => NULL(), PTENQVD5 => NULL(), PTENUVD5 => NULL(), &
     & PTENVVD5 => NULL(), PTENTGW5 => NULL(), PTENUGW5 => NULL(), PTENVGW5 => NULL(), PTENTCO5 => NULL(), PTENQCO5 => NULL(), &
     & PTENUCO5 => NULL(), PTENVCO5 => NULL(), PTENTSL5 => NULL(), PTENQSL5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PDIFTQ5 => NULL(), PDIFTS5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PTENTCL5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PFPLCL5 => NULL(), PFPLCN5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PUCFL5 => NULL(), PVCFL5 => NULL(), PTCFL5 => NULL(), PQCFL5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PFRSOTI5 => NULL(), PAHFSTI5 => NULL(), PEVAPTI5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PEVAPSNW5 => NULL(), PFPLSL5 => NULL(), PFPLSN5 => NULL(), PFRTH5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER :: TENDC55D => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PHTENU5 => NULL(), PHTENV5 => NULL(), PHTENT5 => NULL(), PHTENQ5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PUP95 => NULL(), PVP95 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PUSLP95 => NULL(), PVSLP95 => NULL(), PZSLP95 => NULL(), &
     & PTSLP95 => NULL(), PQSLP95 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PCVGQMF => NULL(), PTENDUMF => NULL(), PTENDVMF => NULL(), PTENDHMF => NULL(),&
     & PTENDQMF => NULL(), PTENDQLMF => NULL(), PTENDQIMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:,:), POINTER  :: PQLMF=>NULL(),PQIMF=>NULL(),PQRMF=>NULL(),PQSMF=>NULL(),PLIQCVPPKFMF=>NULL(),&
     & PNEBCVPPKFMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PDIFCQMF => NULL(), PDIFCSMF => NULL(), PDIFTQMF => NULL(), PDIFTSMF => NULL(), &
     & PFCCQLMF=>NULL(),PFCCQNMF=>NULL(),PFCSQLMF=>NULL(),PFCSQNMF=>NULL(),PFPLCLMF=>NULL(),PFPLCNMF=>NULL(),PFPLSLMF=>NULL(),&
     & PFPLSNMF=>NULL(),PFRSOMF=>NULL(),PFRTHMF=>NULL(), PSTRCUMF=>NULL(),PSTRCVMF=>NULL(),PSTRDUMF=>NULL(),PSTRDVMF=>NULL(),&
     & PSTRTUMF => NULL(), PSTRTVMF => NULL(), PSTRMUMF => NULL(), PSTRMVMF => NULL(), PFRMHMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER :: PKTROVMF => NULL(), PKUROVMF => NULL(), PXTROVMF => NULL(),&
     & PXUROVMF => NULL(), PRAPGWDMF => NULL()
    REAL(KIND=JPRB), DIMENSION(:), POINTER :: PCDROVMF => NULL(), PCHROVMF => NULL(), PXDROVMF => NULL(), PXHROVMF => NULL(),&
     & PTRIGCONVMF => NULL()
  END TYPE TRAJ_PHYS_TLAD_TYPE

  TYPE TRAJ_CST_TYPE
    LOGICAL :: LASTCHUNK
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: MIX_CST => NULL()
  END TYPE TRAJ_CST_TYPE

  TYPE TRAJ_SRFC_TYPE
    LOGICAL :: LASTCHUNK
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: MIX_SRFC => NULL()
  END TYPE TRAJ_SRFC_TYPE

  TYPE TRAJ_SLAG_TYPE
    LOGICAL :: LASTCHUNK
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: PUL95 => NULL(), PVL95 => NULL(), PTL95 => NULL(), &
     &  PCL95 => NULL(), PUL05 => NULL(), PVL05 => NULL(), PTL05 => NULL(), PUT15 => NULL(), PVT15 => NULL(), &
     &  PURL05 => NULL(), PVRL05 => NULL(), PZRL05 => NULL(), PWRL05 => NULL(), PZL95 => NULL(), PZL05 => NULL(), &
     &  PURL005 => NULL(), PVRL005 => NULL(), PZRL005 => NULL(), PWRL005 => NULL(), &
     &  PURL5 => NULL(), PVRL5 => NULL(), PWRL5 => NULL(), PZRL5 => NULL(), &
     &  PKAPPA5 => NULL(), PKAPPAT5 => NULL(), PTT15 => NULL(), PQT15 => NULL(), PWRL95 => NULL(), &
     &  PSTDDISU5 => NULL(), PSTDDISV5 => NULL(), PSTDDISW5 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :, :), POINTER :: PSAVEDP5 => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER :: PGFLL95 => NULL()
    INTEGER(KIND=JPIM), DIMENSION(:), POINTER :: IGFLL95 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:), POINTER :: PX95 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:), POINTER :: PUT95 => NULL(), PVT95 => NULL(), PSPNLT95 => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:), POINTER :: PUSI5 => NULL(), PVSI5 => NULL(), PSPL95 => NULL(), PSPL05 => NULL()
  END TYPE TRAJ_SLAG_TYPE

  TYPE TRAJ_MAIN_TYPE
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :, :), POINTER :: GFL => NULL(), GMV => NULL()
    REAL(KIND=MKINDTRAJ), DIMENSION(:, :), POINTER :: GMVS => NULL()
  END TYPE TRAJ_MAIN_TYPE
  type native_trajectory_time_record
    type(spectral_field_state), pointer :: spec(:) => null()
    type(TRAJ_SRFC_TYPE), pointer :: srfc(:) => null()
    type(TRAJ_CST_TYPE), pointer :: cst(:) => null()
    type(TRAJ_SLAG_TYPE), pointer :: slag(:) => null()
    type(TRAJ_PHYS_TYPE), pointer :: phys(:) => null()
    type(TRAJ_PHYS_TLAD_TYPE), pointer :: phys_tlad(:) => null()
    type(TRAJ_RAINGG_TLAD_TYPE), pointer :: raingg_tlad(:) => null()
    type(TRAJ_MAIN_TYPE), pointer :: main(:) => null()
  end type
!> Six owners. Each time record borrows the same three block arrays.
  type native_empty_trajectory_state
    integer(int32), allocatable :: msteptrajw(:), msteptrajr(:)
    type(native_trajectory_time_record), allocatable :: trajec(:)
    type(TRAJ_CST_TYPE), pointer :: cst(:) => null()
    type(TRAJ_SLAG_TYPE), pointer :: slag(:) => null()
    type(TRAJ_PHYS_TYPE), pointer :: phys(:) => null()
  end type
end module forecast_native_trajectory_types
