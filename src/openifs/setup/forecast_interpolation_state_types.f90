!> Own the interpolation buffers and communication maps as native arrays.
!! A halo is the extra grid region that supplies neighbouring values for an
!! interpolation. This declaration preserves every source-named SL_STRUCT
!! member, rank and declaration default. It imports no original model type,
!! procedure, constructor or finalizer. The compiler owns native descriptors.
module forecast_interpolation_state_types
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: native_interpolation_state

  !> Hold a complete interpolation state in one stable caller-owned record.
  !! Integer counts, indices and maps are int32; switches are native logical.
  !! DIST1GP(:) and DISTUNUSEDHALO are real64 distances in kilometres.
  !! CVER is the exact two-character interpolation code. Every allocatable
  !! array retains the original rank and obtains bounds from live geometry.
  !! New objects have absent owners. Source-unwritten members retain their
  !! incoming values. An enclosing stable TARGET owner permits consumers to
  !! borrow array views for its lifetime. Allocation and release belong to
  !! the producing routine, with no implicit original methods or finalizer.
  type :: native_interpolation_state
    CHARACTER(LEN=2) :: CVER = 'XX'
    INTEGER(KIND=int32) :: NSLGROUP = 0
    INTEGER(KIND=int32), ALLOCATABLE :: NSLSTA(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLONL(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLOFF(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLPTSWEST(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLPTSEAST(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLEXT(:, :)
    LOGICAL, ALLOCATABLE :: LCOMPLAT(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NLATGLO(:)
    REAL(KIND=real64), ALLOCATABLE :: DIST1GP(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLSENDPOS(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLRECVPOS(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLSENDPTR(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLRECVPTR(:)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLCOMM(:)
    LOGICAL, ALLOCATABLE :: LSLCOMM(:, :)
    INTEGER(KIND=int32) :: NASLB1 = 0
    INTEGER(KIND=int32) :: NASLB1_TRUE = 0
    INTEGER(KIND=int32) :: NSLPAD = 0
    LOGICAL :: LSLT_ARRAYS_INIT = .FALSE.
    LOGICAL :: LSLONDEM = .FALSE.
    LOGICAL :: LSLONDEM_ACTIVE = .FALSE.
    INTEGER(KIND=int32) :: NUNUSEDHALO = 999999
    REAL(KIND=real64) :: DISTUNUSEDHALO = 999999.0_real64
    INTEGER(KIND=int32), ALLOCATABLE :: MASK_SL1(:)
    INTEGER(KIND=int32), ALLOCATABLE :: MASK_SL2(:)
    INTEGER(KIND=int32), ALLOCATABLE :: MASK_SL2T(:, :)
    INTEGER(KIND=int32), ALLOCATABLE :: MASK_SLD(:)
    INTEGER(KIND=int32) :: NSLPROCS = 0
    INTEGER(KIND=int32) :: NSLRPT = 0
    INTEGER(KIND=int32) :: NSLSPT = 0
    INTEGER(KIND=int32) :: NSLWIDEN = 0
    INTEGER(KIND=int32) :: NSLWIDES = 0
    INTEGER(KIND=int32) :: NSLWIDEE = 0
    INTEGER(KIND=int32) :: NSLWIDEW = 0
    INTEGER(KIND=int32) :: NSLWIDE = 0
    INTEGER(KIND=int32), ALLOCATABLE :: NSLMAP(:, :)
    INTEGER(KIND=int32), ALLOCATABLE :: NSLCORE(:)
    LOGICAL, ALLOCATABLE :: LSLCORE(:)
    INTEGER(KIND=int32), ALLOCATABLE :: MASK_SLTOT(:)
    INTEGER(KIND=int32) :: NDGLG = 0
    INTEGER(KIND=int32) :: NDLON = 0
    INTEGER(KIND=int32) :: NDGSAG = 0
    INTEGER(KIND=int32) :: NDGENG = 0
    INTEGER(KIND=int32) :: NDGSAL = 0
    INTEGER(KIND=int32) :: NDGENL = 0
    INTEGER(KIND=int32) :: NDGSAH = 0
    INTEGER(KIND=int32) :: NDGENH = 0
    INTEGER(KIND=int32) :: NGPTOT = 0
    INTEGER(KIND=int32) :: NDGUXL = 0
    INTEGER(KIND=int32) :: NDLUNG = 0
    INTEGER(KIND=int32) :: NDLUXG = 0
    INTEGER(KIND=int32) :: NDGUNG = 0
    INTEGER(KIND=int32) :: NDGUXG = 0
    INTEGER(KIND=int32) :: NDSUR1 = 0
    INTEGER(KIND=int32) :: NDLSUR = 0
    INTEGER(KIND=int32) :: NDGSUR = 0
    INTEGER(KIND=int32) :: NPTRFLOFF = 0
    INTEGER(KIND=int32) :: NFRSTLOFF = 0
    INTEGER(KIND=int32) :: MYFRSTACTLAT = 0
    INTEGER(KIND=int32) :: MYLSTACTLAT = 0
    INTEGER(KIND=int32), ALLOCATABLE :: NLOENG(:)
  end type native_interpolation_state
end module forecast_interpolation_state_types
