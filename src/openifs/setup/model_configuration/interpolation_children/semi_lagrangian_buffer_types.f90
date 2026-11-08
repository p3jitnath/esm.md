!> Own source-named interpolation controls and three small buffer maps.
!! Counts and indices are int32 and unitless. Parity values are exact real64
!! multipliers. VMAX1 and VMAX2 are trajectory speed limits in metres per second.
!! No original type method or private byte layout belongs to this module.
module forecast_semi_lagrangian_buffer_types
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: native_interpolation_platform, native_interpolation_controls
  public :: native_sl_buffer_one, native_sl_buffer_two, native_sl_buffer_refined
  public :: native_semi_lagrangian_buffers
  type :: native_interpolation_platform
    integer(int32) :: nconf = 0, lecmwf = 0, lr2d = 0, lr3d = 0
  end type
  !> Hold only the source SUDYN members consumed by the generated setup.
  !! Source-unwritten members retain their input values. New objects represent
  !! the named scalar part of the enclosing fresh zero owner.
  type :: native_interpolation_controls
    integer(int32) :: nvlag = 0, nwlag = 0, ntlag = 0, nspdlag = 0, nsvdlag = 0
    integer(int32) :: nsplthoi = 0, nsldimk = 0, nitmp = 0
    logical :: lsvtsm = .false., lsldp_rk = .false., lrhs_curv = .false.
    logical :: ladvf = .false., l2tlff = .false., lsldp_curv = .false.
    logical :: lsldp_xyz = .false., lsldp_save = .false., lslhdheat = .false.
    logical :: lvweno_t = .false., lmascor = .false., lvsplip = .false., lslvf = .false.
    real(real64) :: vmax1 = 0.0_real64, vmax2 = 0.0_real64
  end type
  !> The compiler owns native descriptors. Each parity array starts absent.
  !! Integer member order and names follow the three original declarations.
  type :: native_sl_buffer_one
    INTEGER(KIND=int32) :: NFLDSLB1 = 0_int32
    REAL(KIND=real64), ALLOCATABLE :: RPARSL1(:)
    INTEGER(KIND=int32) :: MSLBUF1 = 0_int32
    INTEGER(KIND=int32) :: MSLB1U9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1V9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1Z9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1T9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFL9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFLSP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1PD9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VD9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1NHX9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UR0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VR0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZR0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1WR0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UR00 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VR00 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZR00 = 0_int32
    INTEGER(KIND=int32) :: MSLB1WR00 = 0_int32
    INTEGER(KIND=int32) :: MSLB1WRA = 0_int32
    INTEGER(KIND=int32) :: MSLB1UR9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VR9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZR9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1DBBC9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1DPHI9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GWS9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1U0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1V0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1Z0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1T0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1PD0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VD0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1C9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1SP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1SP0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1C0 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1TP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFLP9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1U9_SI = 0_int32
    INTEGER(KIND=int32) :: MSLB1V9_SI = 0_int32
    INTEGER(KIND=int32) :: MSLB1T9_SI = 0_int32
    INTEGER(KIND=int32) :: MSLB1PD9_SI = 0_int32
    INTEGER(KIND=int32) :: MSLB1VD9_SI = 0_int32
    INTEGER(KIND=int32) :: MSLB1C9_SI = 0_int32
    INTEGER(KIND=int32) :: MSLB1UF9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VF9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1TF9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFLF9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VDF9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFLSPF9 = 0_int32
    INTEGER(KIND=int32) :: MSLB1U9_NL = 0_int32
    INTEGER(KIND=int32) :: MSLB1V9_NL = 0_int32
    INTEGER(KIND=int32) :: MSLB1T9_NL = 0_int32
    INTEGER(KIND=int32) :: MSLB1PD9_NL = 0_int32
    INTEGER(KIND=int32) :: MSLB1VD9_NL = 0_int32
    INTEGER(KIND=int32) :: MSLB1C9_NL = 0_int32
  end type native_sl_buffer_one
  type :: native_sl_buffer_two
    INTEGER(KIND=int32) :: NFLDSLB2 = 0_int32
    INTEGER(KIND=int32) :: MSLBUF2 = 0_int32
    INTEGER(KIND=int32) :: MSLB2DBBC1 = 0_int32
    INTEGER(KIND=int32) :: MSLB2DPHI1 = 0_int32
    INTEGER(KIND=int32) :: MSLB2USI = 0_int32
    INTEGER(KIND=int32) :: MSLB2VSI = 0_int32
    INTEGER(KIND=int32) :: MSLB2TSI = 0_int32
    INTEGER(KIND=int32) :: MSLB2PDSI = 0_int32
    INTEGER(KIND=int32) :: MSLB2VDSI = 0_int32
    INTEGER(KIND=int32) :: MSLB2SPSI = 0_int32
    INTEGER(KIND=int32) :: MSLB2VVEL = 0_int32
    INTEGER(KIND=int32) :: MSLB2URL = 0_int32
    INTEGER(KIND=int32) :: MSLB2VRL = 0_int32
    INTEGER(KIND=int32) :: MSLB2WRL = 0_int32
    INTEGER(KIND=int32) :: MSLB2ZRL = 0_int32
    INTEGER(KIND=int32) :: MSLB2URL5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2VRL5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2WRL5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2ZRL5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2USI5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2VSI5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2U15 = 0_int32
    INTEGER(KIND=int32) :: MSLB2V15 = 0_int32
    INTEGER(KIND=int32) :: MSLB2T15 = 0_int32
    INTEGER(KIND=int32) :: MSLB2Q15 = 0_int32
    INTEGER(KIND=int32) :: MSLB2KAPPA = 0_int32
    INTEGER(KIND=int32) :: MSLB2KAPPAT = 0_int32
    INTEGER(KIND=int32) :: MSLB2KAPPAM = 0_int32
    INTEGER(KIND=int32) :: MSLB2KAPPAH = 0_int32
    INTEGER(KIND=int32) :: MSLB2KAPPA5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2KAPPAT5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2GWF = 0_int32
    INTEGER(KIND=int32) :: MSLB2GDW = 0_int32
    INTEGER(KIND=int32) :: MSLB2GWS = 0_int32
    INTEGER(KIND=int32) :: MSLB2STDDISU = 0_int32
    INTEGER(KIND=int32) :: MSLB2STDDISV = 0_int32
    INTEGER(KIND=int32) :: MSLB2STDDISW = 0_int32
    INTEGER(KIND=int32) :: MSLB2STDDISU5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2STDDISV5 = 0_int32
    INTEGER(KIND=int32) :: MSLB2STDDISW5 = 0_int32
  end type native_sl_buffer_two
  type :: native_sl_buffer_refined
    INTEGER(KIND=int32) :: NFLDSLB15 = 0_int32
    REAL(KIND=real64), ALLOCATABLE :: RPARSL15(:)
    INTEGER(KIND=int32) :: MSLBUF15 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UR05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VR05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZR05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1WR05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UR005 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VR005 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZR005 = 0_int32
    INTEGER(KIND=int32) :: MSLB1WR005 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UR95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VR95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZR95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1U05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1V05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1Z05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1T05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1C05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1SP05 = 0_int32
    INTEGER(KIND=int32) :: MSLB1U95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1V95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1Z95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1T95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFL95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1C95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1UP95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1VP95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1ZP95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1TP95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1GFLP95 = 0_int32
    INTEGER(KIND=int32) :: MSLB1SP95 = 0_int32
  end type native_sl_buffer_refined
  !> Own the three maps together while retaining their separate source identities.
  type :: native_semi_lagrangian_buffers
    type(native_sl_buffer_one) :: first
    type(native_sl_buffer_two) :: second
    type(native_sl_buffer_refined) :: refined
  end type
end module forecast_semi_lagrangian_buffer_types
