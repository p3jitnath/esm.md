!> Prepare the three source-named model field and physics records.
module forecast_fresh_model_physics_records
  use iso_fortran_env, only: int32, real64
  use yomdimf, only: tdimf
  use yomdphy, only: tdphy
  use yomphy2, only: tphy2
  implicit none
  private
  public :: initialize_fresh_model_physics_records
contains
!> Define fresh storage before the owning model configuration stages.
!! FIELD_DIMENSIONS is INOUT canonical TDIMF,PHYSICS_DIMENSIONS is INOUT
!! canonical TDPHY and PHYSICS_AUXILIARY is INOUT canonical TPHY2. These
!! are caller-owned valid fresh native objects. Their numeric zeros retain
!! the units of each source field; flags and field counts are unitless.
!! Both TDIMF allocatables must be absent. Status2 changes no output if one
!! is live. Status0 sets56 named scalar fields to typed zero or false and
!! leaves valid unallocated descriptors. The declarations have no fixed
!! arrays,pointers,nested data or component initializers to retain.
!! This is storage preparation,not SUPHY2 or physical-ready state. Original
!! methods and global data are unused. Compiler padding stays unqualified,
!! with no byte fill,gap repair,numerical stage or floating-point probe.
integer(int32) function initialize_fresh_model_physics_records(field_dimensions,physics_dimensions,physics_auxiliary) result(status)
    type(tdimf), intent(inout) :: field_dimensions
    type(tdphy), intent(inout) :: physics_dimensions
    type(tphy2), intent(inout) :: physics_auxiliary
    status = 2_int32
    if (allocated(field_dimensions%ngrbsp3)) return
    if (allocated(field_dimensions%ngrbsp2)) return
    field_dimensions = tdimf( &
                       nfther=0_int32, &
                       nf3d=0_int32, &
                       nfd2d=0_int32, &
                       nfc2d=0_int32, &
                       ns3d=0_int32, &
                       ns2d=0_int32, &
                       ns1d=0_int32, &
                       lvor=.false., &
                       lader=.false., &
                       luvder=.false., &
                       lspt=.false.)
    physics_dimensions = tdphy( &
                         ncss=0_int32, &
                         nvxp=0_int32, &
                         nvxp2=0_int32, &
                         ncxp=0_int32, &
                         ncsi=0_int32, &
                         ncom=0_int32, &
                         ncsnec=0_int32, &
                         ntiles=0_int32, &
                         nvextr=0_int32, &
                         nvextrdi=0_int32, &
                         nvextrrad=0_int32, &
                         nvextrdyn=0_int32, &
                         nvxtr2=0_int32, &
                         nvecout=0_int32, &
                         ncextr=0_int32, &
                         nvclis=0_int32, &
                         ntoz1d=0_int32, &
                         ntoz2d=0_int32, &
                         ntoz3d=0_int32, &
                         ntssg=0_int32, &
                         ltprof=.false., &
                         ldirclsmod=.false.)
    physics_auxiliary = tphy2( &
                        ntshm=0_int32, &
                        ntsml=0_int32, &
                        tsphy=0.0_real64, &
                        xmucvpp=0.0_real64, &
                        xmulaf=0.0_real64, &
                        xdamp=0.0_real64, &
                        hclp=0.0_real64, &
                        htcls=0.0_real64, &
                        hvcls=0.0_real64, &
                        htshm=0.0_real64, &
                        htsml=0.0_real64, &
                        hwmohigh=0.0_real64, &
                        hwmolow=0.0_real64, &
                        gz0raf=0.0_real64, &
                        facraf=0.0_real64, &
                        facrafcv=0.0_real64, &
                        facrafdcape=0.0_real64, &
                        gcaperaf=0.0_real64, &
                        htkeraf=0.0_real64, &
                        lraftur=.false., &
                        lmulaf=.false., &
                        lwmocloud=.false., &
                        lraftke=.false.)
    status = 0_int32
  end function
end module forecast_fresh_model_physics_records
