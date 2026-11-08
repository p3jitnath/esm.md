! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Borrow physics arrays and the one native registry field owner.
!> Array ranks and names follow the source declarations. This module owns no
!> numerical payload and calls no original method. Pointer heads start absent.
module forecast_physics_work_types
  use iso_fortran_env, only: int32, real64
  use forecast_registry_field_types, only: FIELD_2D => native_registry_field_2d, &
                                           FIELD_3D => native_registry_field_3d, FIELD_4D => native_registry_field_4d
  use forecast_integer_logical_work_fields, only: &
    FIELD_INT2D => native_integer_work_field, FIELD_LOG2D => native_logical_work_field
  use forecast_native_field_variable_types, only: native_surface_variables
  use ecphys_dimension_type_mod, only: DIMENSION_TYPE
  use yomphyder, only: GEMS_LOCAL_TYPE
  implicit none
  private
  integer, parameter :: JPIM = int32, JPRB = real64
  public :: DIMENSION_TYPE, GEMS_LOCAL_TYPE
  public :: SURFACE_VIEW_GROUP_SOILB
  public :: SURFACE_VIEW_GROUP_SNOWG
  public :: SURFACE_VIEW_GROUP_LAKEB
  public :: SURFACE_VIEW_GROUP_RESVR
  public :: SURFACE_VIEW_GROUP_CLS
  public :: SURFACE_VIEW_GROUP_OML
  public :: SURFACE_VIEW_GROUP_EXTRP
  public :: SURFACE_VIEW_GROUP_XTRP2
  public :: SURFACE_VIEW_GROUP_CANRI
  public :: STATE_FIELD_MASK
  public :: MASK_GFL_TYPE
  public :: STATE_TYPE
  public :: AUX_TYPE
  public :: KEYS_LOCAL_TYPE
  public :: AUX_RAD_TYPE
  public :: AUX_DIAG_TYPE
  public :: AUX_DIAG_LOCAL_TYPE
  public :: SURF_AND_MORE_TYPE
  public :: SURF_AND_MORE_LOCAL_TYPE
  public :: DDH_SURF_TYPE
  public :: FLUX_TYPE
  public :: PERTURB_TYPE
  public :: PERTURB_LOCAL_TYPE

  type SURFACE_VIEW_GROUP_SOILB
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 1
    real(real64), pointer :: PT_T0(:, :) => null()
    real(real64), pointer :: PT_T1(:, :) => null()
    real(real64), pointer :: PT_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_T_T0 => null(), F_T_T1 => null(), F_T_T9 => null()
    real(real64), pointer :: PQ_T0(:, :) => null()
    real(real64), pointer :: PQ_T1(:, :) => null()
    real(real64), pointer :: PQ_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_Q_T0 => null(), F_Q_T1 => null(), F_Q_T9 => null()
    real(real64), pointer :: PTL_T0(:, :) => null()
    real(real64), pointer :: PTL_T1(:, :) => null()
    real(real64), pointer :: PTL_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_TL_T0 => null(), F_TL_T1 => null(), F_TL_T9 => null()
    real(real64), pointer :: PGROUP(:, :, :) => null()
    type(FIELD_4D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_SOILB

  type SURFACE_VIEW_GROUP_SNOWG
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 2
    real(real64), pointer :: PF_T0(:, :) => null()
    real(real64), pointer :: PF_T1(:, :) => null()
    real(real64), pointer :: PF_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_F_T0 => null(), F_F_T1 => null(), F_F_T9 => null()
    real(real64), pointer :: PA_T0(:, :) => null()
    real(real64), pointer :: PA_T1(:, :) => null()
    real(real64), pointer :: PA_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_A_T0 => null(), F_A_T1 => null(), F_A_T9 => null()
    real(real64), pointer :: PR_T0(:, :) => null()
    real(real64), pointer :: PR_T1(:, :) => null()
    real(real64), pointer :: PR_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_R_T0 => null(), F_R_T1 => null(), F_R_T9 => null()
    real(real64), pointer :: PT_T0(:, :) => null()
    real(real64), pointer :: PT_T1(:, :) => null()
    real(real64), pointer :: PT_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_T_T0 => null(), F_T_T1 => null(), F_T_T9 => null()
    real(real64), pointer :: PW_T0(:, :) => null()
    real(real64), pointer :: PW_T1(:, :) => null()
    real(real64), pointer :: PW_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_W_T0 => null(), F_W_T1 => null(), F_W_T9 => null()
    real(real64), pointer :: PGROUP(:, :, :) => null()
    type(FIELD_4D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_SNOWG

  type SURFACE_VIEW_GROUP_LAKEB
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 3
    real(real64), pointer :: PLICT_T0(:) => null()
    real(real64), pointer :: PLICT_T1(:) => null()
    real(real64), pointer :: PLICT_T9(:) => null()
    type(FIELD_2D), pointer :: F_LICT_T0 => null(), F_LICT_T1 => null(), F_LICT_T9 => null()
    real(real64), pointer :: PLMLT_T0(:) => null()
    real(real64), pointer :: PLMLT_T1(:) => null()
    real(real64), pointer :: PLMLT_T9(:) => null()
    type(FIELD_2D), pointer :: F_LMLT_T0 => null(), F_LMLT_T1 => null(), F_LMLT_T9 => null()
    real(real64), pointer :: PLTLT_T0(:) => null()
    real(real64), pointer :: PLTLT_T1(:) => null()
    real(real64), pointer :: PLTLT_T9(:) => null()
    type(FIELD_2D), pointer :: F_LTLT_T0 => null(), F_LTLT_T1 => null(), F_LTLT_T9 => null()
    real(real64), pointer :: PLBLT_T0(:) => null()
    real(real64), pointer :: PLBLT_T1(:) => null()
    real(real64), pointer :: PLBLT_T9(:) => null()
    type(FIELD_2D), pointer :: F_LBLT_T0 => null(), F_LBLT_T1 => null(), F_LBLT_T9 => null()
    real(real64), pointer :: PLSHF_T0(:) => null()
    real(real64), pointer :: PLSHF_T1(:) => null()
    real(real64), pointer :: PLSHF_T9(:) => null()
    type(FIELD_2D), pointer :: F_LSHF_T0 => null(), F_LSHF_T1 => null(), F_LSHF_T9 => null()
    real(real64), pointer :: PLICD_T0(:) => null()
    real(real64), pointer :: PLICD_T1(:) => null()
    real(real64), pointer :: PLICD_T9(:) => null()
    type(FIELD_2D), pointer :: F_LICD_T0 => null(), F_LICD_T1 => null(), F_LICD_T9 => null()
    real(real64), pointer :: PLMLD_T0(:) => null()
    real(real64), pointer :: PLMLD_T1(:) => null()
    real(real64), pointer :: PLMLD_T9(:) => null()
    type(FIELD_2D), pointer :: F_LMLD_T0 => null(), F_LMLD_T1 => null(), F_LMLD_T9 => null()
    real(real64), pointer :: PGROUP(:, :) => null()
    type(FIELD_3D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_LAKEB

  type SURFACE_VIEW_GROUP_RESVR
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 4
    real(real64), pointer :: PT_T0(:) => null()
    real(real64), pointer :: PT_T1(:) => null()
    real(real64), pointer :: PT_T9(:) => null()
    type(FIELD_2D), pointer :: F_T_T0 => null(), F_T_T1 => null(), F_T_T9 => null()
    real(real64), pointer :: PW_T0(:) => null()
    real(real64), pointer :: PW_T1(:) => null()
    real(real64), pointer :: PW_T9(:) => null()
    type(FIELD_2D), pointer :: F_W_T0 => null(), F_W_T1 => null(), F_W_T9 => null()
    real(real64), pointer :: PFC_T0(:) => null()
    real(real64), pointer :: PFC_T1(:) => null()
    real(real64), pointer :: PFC_T9(:) => null()
    type(FIELD_2D), pointer :: F_FC_T0 => null(), F_FC_T1 => null(), F_FC_T9 => null()
    real(real64), pointer :: PIC_T0(:) => null()
    real(real64), pointer :: PIC_T1(:) => null()
    real(real64), pointer :: PIC_T9(:) => null()
    type(FIELD_2D), pointer :: F_IC_T0 => null(), F_IC_T1 => null(), F_IC_T9 => null()
    real(real64), pointer :: PFP1_T0(:) => null()
    real(real64), pointer :: PFP1_T1(:) => null()
    real(real64), pointer :: PFP1_T9(:) => null()
    type(FIELD_2D), pointer :: F_FP1_T0 => null(), F_FP1_T1 => null(), F_FP1_T9 => null()
    real(real64), pointer :: PGROUP(:, :) => null()
    type(FIELD_3D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_RESVR

  type SURFACE_VIEW_GROUP_CLS
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 5
    real(real64), pointer :: PTCLS_T0(:) => null()
    real(real64), pointer :: PTCLS_T1(:) => null()
    real(real64), pointer :: PTCLS_T9(:) => null()
    type(FIELD_2D), pointer :: F_TCLS_T0 => null(), F_TCLS_T1 => null(), F_TCLS_T9 => null()
    real(real64), pointer :: PHUCLS_T0(:) => null()
    real(real64), pointer :: PHUCLS_T1(:) => null()
    real(real64), pointer :: PHUCLS_T9(:) => null()
    type(FIELD_2D), pointer :: F_HUCLS_T0 => null(), F_HUCLS_T1 => null(), F_HUCLS_T9 => null()
    real(real64), pointer :: PUCLS_T0(:) => null()
    real(real64), pointer :: PUCLS_T1(:) => null()
    real(real64), pointer :: PUCLS_T9(:) => null()
    type(FIELD_2D), pointer :: F_UCLS_T0 => null(), F_UCLS_T1 => null(), F_UCLS_T9 => null()
    real(real64), pointer :: PVCLS_T0(:) => null()
    real(real64), pointer :: PVCLS_T1(:) => null()
    real(real64), pointer :: PVCLS_T9(:) => null()
    type(FIELD_2D), pointer :: F_VCLS_T0 => null(), F_VCLS_T1 => null(), F_VCLS_T9 => null()
    real(real64), pointer :: PNUCLS_T0(:) => null()
    real(real64), pointer :: PNUCLS_T1(:) => null()
    real(real64), pointer :: PNUCLS_T9(:) => null()
    type(FIELD_2D), pointer :: F_NUCLS_T0 => null(), F_NUCLS_T1 => null(), F_NUCLS_T9 => null()
    real(real64), pointer :: PNVCLS_T0(:) => null()
    real(real64), pointer :: PNVCLS_T1(:) => null()
    real(real64), pointer :: PNVCLS_T9(:) => null()
    type(FIELD_2D), pointer :: F_NVCLS_T0 => null(), F_NVCLS_T1 => null(), F_NVCLS_T9 => null()
    real(real64), pointer :: PGROUP(:, :) => null()
    type(FIELD_3D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_CLS

  type SURFACE_VIEW_GROUP_OML
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 6
    real(real64), pointer :: PTO_T0(:, :) => null()
    real(real64), pointer :: PTO_T1(:, :) => null()
    real(real64), pointer :: PTO_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_TO_T0 => null(), F_TO_T1 => null(), F_TO_T9 => null()
    real(real64), pointer :: PSO_T0(:, :) => null()
    real(real64), pointer :: PSO_T1(:, :) => null()
    real(real64), pointer :: PSO_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_SO_T0 => null(), F_SO_T1 => null(), F_SO_T9 => null()
    real(real64), pointer :: PUO_T0(:, :) => null()
    real(real64), pointer :: PUO_T1(:, :) => null()
    real(real64), pointer :: PUO_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_UO_T0 => null(), F_UO_T1 => null(), F_UO_T9 => null()
    real(real64), pointer :: PVO_T0(:, :) => null()
    real(real64), pointer :: PVO_T1(:, :) => null()
    real(real64), pointer :: PVO_T9(:, :) => null()
    type(FIELD_3D), pointer :: F_VO_T0 => null(), F_VO_T1 => null(), F_VO_T9 => null()
    real(real64), pointer :: PGROUP(:, :, :) => null()
    type(FIELD_4D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_OML

  type SURFACE_VIEW_GROUP_EXTRP
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 7
    real(real64), pointer :: PGROUP(:, :, :) => null()
    type(FIELD_4D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_EXTRP

  type SURFACE_VIEW_GROUP_XTRP2
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 8
    real(real64), pointer :: PGROUP(:, :) => null()
    type(FIELD_3D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_XTRP2

  type SURFACE_VIEW_GROUP_CANRI
    type(native_surface_variables), pointer :: VARIABLE_GROUP => null()
    integer(int32) :: GROUP_CODE = 9
    real(real64), pointer :: PGROUP(:, :) => null()
    type(FIELD_3D), pointer :: F_GROUP => null()
  end type SURFACE_VIEW_GROUP_CANRI

  type STATE_FIELD_MASK
    LOGICAL :: U = .false., V = .false., T = .false., O3 = .false., Q = .false., A = .false., TKE = .false.
  end type STATE_FIELD_MASK

  type MASK_GFL_TYPE
    LOGICAL :: O3 = .false., Q = .false., A = .false., QL = .false., QI = .false., QR = .false., QS = .false., TKE = .false.
  end type MASK_GFL_TYPE

  type STATE_TYPE
    TYPE(MASK_GFL_TYPE) :: KEYMASK
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: U => null(), V => null(), T => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: O3 => null(), Q => null(), A => null(), TKE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: QL => null(), QI => null(), QR => null(), QS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: CLD => null()
  TYPE(FIELD_3D), POINTER :: F_U=>null(), F_V=>null(), F_T=>null(), F_O3=>null(), F_Q=>null(), F_A=>null(), F_QL=>null(), F_QI=>null(), F_QR=>null(), F_QS=>null(), F_TKE=>null()
    TYPE(FIELD_4D), POINTER :: F_CLD => null()
    TYPE(STATE_FIELD_MASK) :: FIELD_OWNED
  end type STATE_TYPE

  type AUX_TYPE
    INTEGER(KIND=JPIM) :: NLEV
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PAPHI => null(), PAPHIF => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PGEOM1 => null(), PGEOMH => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PAPRS => null(), PAPRSF => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDELP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PRS1 => null(), PRSF1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDELP1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PVERVEL => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PGELAM => null(), PGELAT => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PGAW => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCLON => null(), PSLON => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PMU0 => null(), PMU0M => null(), PMU0T => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PGEMU => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: POROG => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PGNORDL => null(), PGNORDM => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PGSQM2 => null()
  TYPE(FIELD_2D), POINTER :: F_PGELAM=>null(), F_PGELAT=>null(), F_PGAW=>null(), F_PCLON=>null(), F_PSLON=>null(), F_PMU0=>null(), F_PMU0M=>null(), F_PMU0T=>null(), F_PGEMU=>null(), F_POROG=>null(), F_PGNORDL=>null(), F_PGNORDM=>null(), F_PGSQM2=>null()
  TYPE(FIELD_3D), POINTER :: F_PAPHI=>null(), F_PAPHIF=>null(), F_PGEOM1=>null(), F_PGEOMH=>null(), F_PAPRS=>null(), F_PAPRSF=>null(), F_PDELP=>null(), F_PRS1=>null(), F_PRSF1=>null(), F_PVERVEL=>null()
  end type AUX_TYPE

  type KEYS_LOCAL_TYPE
  LOGICAL, DIMENSION(:), POINTER, CONTIGUOUS  :: LLLAND=>null(), LLSICE=>null(), LLNH=>null(), LLCUM=>null(), LLSC=>null(), LLSHCV=>null(), LLCUM_LIG=>null()
    LOGICAL, DIMENSION(:), POINTER, CONTIGUOUS :: LLLAKE => null(), LLOCN_KPP => null()
    LOGICAL, POINTER :: LLCLDCOVER => null()
    LOGICAL, POINTER :: LLMAINCALL => null()
  TYPE(FIELD_LOG2D), POINTER :: F_LLLAND=>null(), F_LLSICE=>null(), F_LLNH=>null(), F_LLCUM=>null(), F_LLSC=>null(), F_LLSHCV=>null(), F_LLLAKE=>null(), F_LLOCN_KPP=>null(), F_LLCUM_LIG=>null()
  end type KEYS_LOCAL_TYPE

  type AUX_RAD_TYPE
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PNEB => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PQICE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PQLI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PEMTD => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTRSW => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PEMTC => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTRSC => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PTAUAER => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSRLWD => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRLWDC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWD => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWDC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWDCS => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PEDRO => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWPAR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWUVB => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWPARC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRSWTINC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRFDIR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSRCDIR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTINCF => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFDIR => null(), PCDIR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PDSRP => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PISUND => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PINCSR => null(), PINCSR0 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PHRSW => null(), PHRLW => null(), PHRSC => null(), PHRLC => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: DERIVATIVELW => null()
  TYPE(FIELD_2D), POINTER :: F_PSRLWDC=>null(), F_PSRSWD=>null(), F_PSRSWDC=>null(), F_PSRSWDCS=>null(), F_PEDRO=>null(), F_PSRSWPAR=>null(), F_PSRSWUVB=>null(), F_PSRSWPARC=>null(), F_PSRSWTINC=>null(), F_PSRFDIR=>null(), F_PSRCDIR=>null(), F_PTINCF=>null(), F_PFDIR=>null(), F_PCDIR=>null(), F_PDSRP=>null(), F_PISUND=>null(), F_PINCSR=>null(), F_PINCSR0=>null()
  TYPE(FIELD_3D), POINTER :: F_PSRLWD=>null(), F_PNEB=>null(), F_PQICE=>null(), F_PQLI=>null(), F_PEMTD=>null(), F_PTRSW=>null(), F_PEMTC=>null(), F_PTRSC=>null(), F_PHRSW=>null(), F_PHRLW=>null(), F_PHRSC=>null(), F_PHRLC=>null(), F_DERIVATIVELW=>null()
    TYPE(FIELD_4D), POINTER :: F_PTAUAER => null()
  end type AUX_RAD_TYPE

  type AUX_DIAG_TYPE
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCAPE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZCAPE => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PPDEPL => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCBASE => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCBASEA => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCTOPC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: P0DEGL => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PM10DEGL => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTROPOTP => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PVISIH => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PCIN => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PVDISCU => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PVDIS => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PVDISG => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PUSTRG => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PVSTRG => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PI10FG => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PPRECTYPE => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFZRA => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PCONVIND => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PZTWETB => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PQSAT => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PZTENT => null(), PZTENQ => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PMFUDE_RATE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PMFDDE_RATE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PKH_VDF => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PKM_VDF => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZRI => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZEIS => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZINV => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PCOVPTOT => null()
    INTEGER(KIND=JPIM), DIMENSION(:), POINTER, CONTIGUOUS :: ITYPE => null(), ICBOT => null(), ICTOP => null()
    INTEGER(KIND=JPIM), DIMENSION(:), POINTER, CONTIGUOUS :: IPBLTYPE => null()
    INTEGER(KIND=JPIM), DIMENSION(:), POINTER, CONTIGUOUS :: ICBOT_LIG => null(), ICTOP_LIG => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PMFU => null(), PMFD => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZLUDE => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: ZLUDELI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZLU => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZLRAIN => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: ZSNDE => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PRSUD => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PLIGH_TOT => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PLIGH_CTG => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCHARGE_LIG => null()
  TYPE(FIELD_2D), POINTER :: F_PCAPE=>null(), F_PPDEPL=>null(), F_PCBASE=>null(), F_PCBASEA=>null(), F_PCTOPC=>null(), F_P0DEGL=>null(), F_PM10DEGL=>null(), F_PVISIH=>null(), F_PVDISCU=>null(), F_PVDIS=>null(), F_PVDISG=>null(), F_PUSTRG=>null(), F_PVSTRG=>null(), F_PI10FG=>null(), F_PPRECTYPE=>null(), F_PFZRA=>null(), F_PLIGH_TOT=>null(), F_PLIGH_CTG=>null(), F_PCHARGE_LIG=>null(), F_ZEIS=>null(), F_ZINV=>null(), F_PTROPOTP=>null()
  TYPE(FIELD_3D), POINTER :: F_PCONVIND=>null(), F_PZTWETB=>null(), F_PQSAT=>null(), F_PZTENT=>null(), F_PZTENQ=>null(), F_PMFUDE_RATE=>null(), F_PMFDDE_RATE=>null(), F_PKH_VDF=>null(), F_PCOVPTOT=>null(), F_PMFU=>null(), F_PMFD=>null(), F_ZLUDE=>null(), F_ZLU=>null(), F_ZLRAIN=>null(), F_PKM_VDF=>null(), F_ZRI=>null(), F_ZCAPE=>null(), F_PCIN=>null()
    TYPE(FIELD_4D), POINTER :: F_ZLUDELI => null(), F_ZSNDE => null(), F_PRSUD => null()
  TYPE(FIELD_INT2D), POINTER :: F_ITYPE=>null(), F_ICBOT=>null(), F_ICTOP=>null(), F_IPBLTYPE=>null(), F_ICBOT_LIG=>null(), F_ICTOP_LIG=>null()
  end type AUX_DIAG_TYPE

  type AUX_DIAG_LOCAL_TYPE
    INTEGER(KIND=JPIM) :: IEXT3D
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZWND => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZCCNL => null(), ZCCNO => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZRAINFRAC_TOPRFZ => NULL()
    INTEGER(KIND=JPIM), DIMENSION(:), POINTER, CONTIGUOUS :: ITOPC => null(), IBASC => null(), IBOTSC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZEMIT => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZTRSOD => null(), ZSUDU => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZTSKRAD => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZTHT => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZCTRSO => null(), ZCEMTR => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZSOTEU => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZSOTEV => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZSOBETA => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZLCRIT_AER => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZICRIT_AER => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZRE_LIQ => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZRE_ICE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZCCN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZNICE => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZPATMP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZPLSMP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZPLTMP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZLISUM => null()
  TYPE(FIELD_2D), POINTER :: F_ZWND=>null(), F_ZCCNL=>null(), F_ZCCNO=>null(), F_ZRAINFRAC_TOPRFZ=>null(), F_ZEMIT=>null(), F_ZTRSOD=>null(), F_ZSUDU=>null(), F_ZTSKRAD=>null()
  TYPE(FIELD_3D), POINTER :: F_ZTHT=>null(), F_ZCTRSO=>null(), F_ZCEMTR=>null(), F_ZSOTEU=>null(), F_ZSOTEV=>null(), F_ZSOBETA=>null(), F_ZLCRIT_AER=>null(), F_ZICRIT_AER=>null(), F_ZRE_LIQ=>null(), F_ZRE_ICE=>null(), F_ZCCN=>null(), F_ZNICE=>null(), F_ZPATMP=>null(), F_ZPLSMP=>null(), F_ZPLTMP=>null(), F_ZLISUM=>null()
    TYPE(FIELD_INT2D), POINTER :: F_ITOPC => null(), F_IBASC => null(), F_IBOTSC => null()
  end type AUX_DIAG_LOCAL_TYPE

  type SURF_AND_MORE_TYPE
    TYPE(SURFACE_VIEW_GROUP_SOILB) :: GSP_SB
    TYPE(SURFACE_VIEW_GROUP_SNOWG) :: GSP_SG
    TYPE(SURFACE_VIEW_GROUP_LAKEB) :: GSP_SL
    TYPE(SURFACE_VIEW_GROUP_RESVR) :: GSP_RR
    TYPE(SURFACE_VIEW_GROUP_CLS) :: GSP_CL
    TYPE(SURFACE_VIEW_GROUP_OML) :: GSP_OM
    TYPE(SURFACE_VIEW_GROUP_EXTRP) :: GSP_EP
    TYPE(SURFACE_VIEW_GROUP_XTRP2) :: GSP_X2
    TYPE(SURFACE_VIEW_GROUP_CANRI) :: GSP_CI
  REAL(KIND=JPRB), DIMENSION(:,:), POINTER, CONTIGUOUS :: PSP_SL=>null(), PSP_RR=>null(), PSP_X2=>null(), PSD_WS=>null(), PSD_VF=>null(), PSD_VN=>null(), PSD_V2=>null(), PSD_VD=>null(), PSD_X2=>null(), PSD_WW=>null()
  REAL(KIND=JPRB), DIMENSION(:,:,:), POINTER, CONTIGUOUS :: PSP_SG=>null(), PSP_OM=>null(), PSP_SB=>null(), PSP_EP=>null(), PSD_V3=>null(), PSD_XA=>null(), PSD_SM=>null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PEXTRD => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PCOVPTOT => NULL()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PUSTRTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PVSTRTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PAHFSTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PEVAPTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTSKTI => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PEMIS => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCGPP => null(), PCREC => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSNSE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PRSNE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTSNE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PWSNE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PASNE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PWLE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTLE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTSAE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PWSAE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTIAE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PUOE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PVOE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTOE1 => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSOE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PHSTD => null()
    INTEGER(KIND=JPIM), DIMENSION(:), POINTER, CONTIGUOUS :: ITVH => null(), ITVL => null(), ICO2TYP => null(), ISOTY => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCVL => null(), PCVH => null(), PCUR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCO2TYP => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PLAIL => null(), PLAIH => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWET => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PEVAPMU => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTLICEE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTLMNWE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTLWMLE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTLBOTE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTLSFE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PHLICEE1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PHLMLE1 => null()
  TYPE(FIELD_2D), POINTER :: F_PEMIS=>null(), F_PCGPP=>null(), F_PCREC=>null(), F_PWLE1=>null(), F_PTLE1=>null(), F_PHSTD=>null(), F_PCVL=>null(), F_PCO2TYP=>null(), F_PCVH=>null(), F_PCUR=>null(), F_PLAIL=>null(), F_PLAIH=>null(), F_PFWET=>null(), F_PEVAPMU=>null(), F_PTLICEE1=>null(), F_PTLMNWE1=>null(), F_PTLWMLE1=>null(), F_PTLBOTE1=>null(), F_PTLSFE1=>null(), F_PHLICEE1=>null(), F_PHLMLE1=>null()
  TYPE(FIELD_3D), POINTER :: F_PCOVPTOT=>null(), F_PUSTRTI=>null(), F_PVSTRTI=>null(), F_PAHFSTI=>null(), F_PEVAPTI=>null(), F_PTSKTI=>null(), F_PSNSE1=>null(), F_PRSNE1=>null(), F_PTSNE1=>null(), F_PWSNE1=>null(), F_PASNE1=>null(), F_PTSAE1=>null(), F_PWSAE1=>null(), F_PTIAE1=>null(), F_PUOE1=>null(), F_PVOE1=>null(), F_PTOE1=>null(), F_PSOE1=>null()
    TYPE(FIELD_INT2D), POINTER :: F_ITVH => null(), F_ITVL => null(), F_ISOTY => null(), F_ICO2TYP => null()
  end type SURF_AND_MORE_TYPE

  type SURF_AND_MORE_LOCAL_TYPE
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZLAILI => null(), ZLAIHI => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZWLM1M => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZSNM1M => null(), ZRSNM1M => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZHSDFOR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZPCLAKE => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZTHKICE => null(), ZSNTICE => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCGPP => null(), PCREC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZWLMX => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZEMIR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZEMIW => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZSPECTRALEMISS => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZEVAPSNW => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZFRTI => null(), ZALBTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZFRSOTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZAHFTRTI => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZALBD => null(), ZALBP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZANDAYVT => null(), ZANFMVT => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: ZDHVEGS => null()
  TYPE(FIELD_2D), POINTER :: F_ZLAILI=>null(), F_ZLAIHI=>null(), F_ZWLM1M=>null(), F_ZHSDFOR=>null(), F_ZPCLAKE=>null(), F_ZTHKICE=>null(), F_ZSNTICE=>null(), F_PCGPP=>null(), F_PCREC=>null(), F_ZWLMX=>null(), F_ZEVAPSNW=>null()
  TYPE(FIELD_3D), POINTER :: F_ZSNM1M=>null(), F_ZRSNM1M=>null(), F_ZSPECTRALEMISS=>null(), F_ZFRTI=>null(), F_ZALBTI=>null(), F_ZFRSOTI=>null(), F_ZAHFTRTI=>null(), F_ZALBD=>null(), F_ZALBP=>null(), F_ZANDAYVT=>null(), F_ZANFMVT=>null()
    TYPE(FIELD_4D), POINTER :: F_ZDHVEGS => null()
  end type SURF_AND_MORE_LOCAL_TYPE

  type DDH_SURF_TYPE
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PDHTLS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PDHTSS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PDHTTS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PDHTIS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PDHSSS => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDHIIS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PDHWLS => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDHFSS => null()
    TYPE(FIELD_3D), POINTER :: F_PDHFSS => null(), F_PDHIIS => null()
  TYPE(FIELD_4D), POINTER :: F_PDHTLS=>null(), F_PDHTSS=>null(), F_PDHTTS=>null(), F_PDHTIS=>null(), F_PDHSSS=>null(), F_PDHWLS=>null()
  end type DDH_SURF_TYPE

  type FLUX_TYPE
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFRSOC => null(), PFRTHC => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDIFCQ => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDIFCS => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDIFTQ => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDIFTI => null(), PDIFTL => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PDIFTS => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFCQNG => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFCQLNG => null(), PFCQNNG => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFCQRNG => null(), PFCQSNG => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFPLCL => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFPLCN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFPLSL => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFPLSN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFHPCL => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFHPCN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFHPSL => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFHPSN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFRSO => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFRTH => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSTRCU => null(), PSTRCV => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSTRDU => null(), PSTRDV => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSTRTU => null(), PSTRTV => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFCCQL => null(), PFCCQN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFCSQL => null(), PFCSQN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFSQRF => null(), PFSQSF => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFSQLTUR => null(), PFSQITUR => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFRSOD => null(), PFRSODC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFRTHD => null(), PFRTHDC => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PUVDF => null(), PPARF => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PPARCF => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PTOFDU => null(), PTOFDV => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFTG12 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWG12 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWEV => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWSB => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWMLT => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWROD => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFWRO1 => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFTLHEV => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PFTLHSB => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PENES => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PAERODDF => null()
  TYPE(FIELD_2D), POINTER :: F_PFRSOD=>null(), F_PFRSODC=>null(), F_PFRTHD=>null(), F_PFRTHDC=>null(), F_PUVDF=>null(), F_PPARF=>null(), F_PPARCF=>null(), F_PTOFDU=>null(), F_PTOFDV=>null(), F_PFTG12=>null(), F_PFWG12=>null(), F_PFWEV=>null(), F_PFWSB=>null(), F_PFWMLT=>null(), F_PFWROD=>null(), F_PFWRO1=>null(), F_PFTLHEV=>null(), F_PFTLHSB=>null()
  TYPE(FIELD_3D), POINTER :: F_PFRSOC=>null(), F_PFRTHC=>null(), F_PDIFCQ=>null(), F_PDIFCS=>null(), F_PDIFTQ=>null(), F_PDIFTI=>null(), F_PDIFTL=>null(), F_PDIFTS=>null(), F_PFCQNG=>null(), F_PFCQLNG=>null(), F_PFCQNNG=>null(), F_PFCQRNG=>null(), F_PFCQSNG=>null(), F_PFPLCL=>null(), F_PFPLCN=>null(), F_PFPLSL=>null(), F_PFPLSN=>null(), F_PFHPCL=>null(), F_PFHPCN=>null(), F_PFHPSL=>null(), F_PFHPSN=>null(), F_PFRSO=>null(), F_PFRTH=>null(), F_PSTRCU=>null(), F_PSTRCV=>null(), F_PSTRDU=>null(), F_PSTRDV=>null(), F_PSTRTU=>null(), F_PSTRTV=>null(), F_PFCCQL=>null(), F_PFCCQN=>null(), F_PFCSQL=>null(), F_PFCSQN=>null(), F_PFSQRF=>null(), F_PFSQSF=>null(), F_PFSQLTUR=>null(), F_PFSQITUR=>null(), F_PENES=>null()
    TYPE(FIELD_4D), POINTER :: F_PAERODDF => null()
  end type FLUX_TYPE

  type PERTURB_TYPE
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PSTOPHCA => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PGP2DSDT => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :), POINTER, CONTIGUOUS :: PGP2DSPP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PVORT => null(), PVORTGRADX => null(), PVORTGRADY => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTOTDISS_SMOOTH => null()
 REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PFORCEU => null(), PFORCEV => null(), PFORCET => null(), PFORCEQ => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCUCONVCA => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PNLCONVCA => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: PCAPECONVCA => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PSTREAM => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTEMP => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: PTOTDISS => null()
    REAL(KIND=JPRB), DIMENSION(:, :, :, :), POINTER, CONTIGUOUS :: PSPPTGFIX => null()
  end type PERTURB_TYPE

  type PERTURB_LOCAL_TYPE
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZWMEAN => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZDISSCU => null()
    REAL(KIND=JPRB), DIMENSION(:), POINTER, CONTIGUOUS :: ZCUCONVCA => null()
    REAL(KIND=JPRB), DIMENSION(:, :), POINTER, CONTIGUOUS :: ZDISSGW => null()
    TYPE(FIELD_2D), POINTER :: F_ZWMEAN => null(), F_ZCUCONVCA => null()
    TYPE(FIELD_3D), POINTER :: F_ZDISSCU => null(), F_ZDISSGW => null()
  end type PERTURB_LOCAL_TYPE
end module forecast_physics_work_types
