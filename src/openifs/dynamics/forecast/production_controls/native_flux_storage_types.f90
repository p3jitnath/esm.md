!> Own named flux controls and source arrays in compiler-managed Fortran storage.
!! Counts and switches are dimensionless; periods are seconds. This is the
!! single native CFU/XFU/MCUF owner. Inactive descriptor/catalogue bytes and
!! reset switches retain their incoming values until their source producer runs.
module forecast_native_flux_storage
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  integer, parameter :: max_flux_levels = 200, max_cumulated_types = 99, max_instantaneous_types = 201
  integer, parameter :: max_cumulated_steps = 40, max_instantaneous_steps = 240, max_filters = 5, max_filter_order = 8
  public :: native_flux_family_descriptor
  type :: native_flux_family_descriptor
    CHARACTER(LEN=4) :: CLPREF(max_flux_levels + 1)
    CHARACTER(LEN=16) :: CLSUFF
    INTEGER(KIND=int32) :: INUMLEV(max_flux_levels + 1)
    INTEGER(KIND=int32) :: ILEV
    INTEGER(KIND=int32) :: IPARITY
  end type
  public :: native_cumulated_flux_indices
  type :: native_cumulated_flux_indices
    INTEGER(KIND=int32) :: MSTRDU
    INTEGER(KIND=int32) :: MSTRDV
    INTEGER(KIND=int32) :: MSTRCU
    INTEGER(KIND=int32) :: MSTRCV
    INTEGER(KIND=int32) :: MFDICQ
    INTEGER(KIND=int32) :: MFDICS
    INTEGER(KIND=int32) :: MSTRTU
    INTEGER(KIND=int32) :: MSTRTV
    INTEGER(KIND=int32) :: MFDITQ
    INTEGER(KIND=int32) :: MFDITS
    INTEGER(KIND=int32) :: MFPLCL
    INTEGER(KIND=int32) :: MFPLSL
    INTEGER(KIND=int32) :: MFPLCN
    INTEGER(KIND=int32) :: MFPLSN
    INTEGER(KIND=int32) :: MFPLCG
    INTEGER(KIND=int32) :: MFPLSG
    INTEGER(KIND=int32) :: MFPLCH
    INTEGER(KIND=int32) :: MFPLSH
    INTEGER(KIND=int32) :: MFCCQL
    INTEGER(KIND=int32) :: MFCCQN
    INTEGER(KIND=int32) :: MFCSQL
    INTEGER(KIND=int32) :: MFCSQN
    INTEGER(KIND=int32) :: MFRSO
    INTEGER(KIND=int32) :: MFRTH
    INTEGER(KIND=int32) :: MFNEB
    INTEGER(KIND=int32) :: MWS
    INTEGER(KIND=int32) :: MSNS
    INTEGER(KIND=int32) :: MQTOT
    INTEGER(KIND=int32) :: MFNEBT
    INTEGER(KIND=int32) :: MOZONT
    INTEGER(KIND=int32) :: MSPRES
    INTEGER(KIND=int32) :: MFCL
    INTEGER(KIND=int32) :: MFCS
    INTEGER(KIND=int32) :: MFDISH
    INTEGER(KIND=int32) :: MFTOPH
    INTEGER(KIND=int32) :: MQICE
    INTEGER(KIND=int32) :: MQLI
    INTEGER(KIND=int32) :: MFRSOC0
    INTEGER(KIND=int32) :: MFRTHC0
    INTEGER(KIND=int32) :: MFRSOC1
    INTEGER(KIND=int32) :: MFRTHC1
    INTEGER(KIND=int32) :: MFRSDNI
    INTEGER(KIND=int32) :: MFRSGNI
    INTEGER(KIND=int32) :: MFRSOPS
    INTEGER(KIND=int32) :: MFRSOPT
    INTEGER(KIND=int32) :: MFRSOLU
    INTEGER(KIND=int32) :: MFRSODS
    INTEGER(KIND=int32) :: MFRTHDS
    INTEGER(KIND=int32) :: MFCLL
    INTEGER(KIND=int32) :: MFCLN
    INTEGER(KIND=int32) :: MFEVL
    INTEGER(KIND=int32) :: MFEVN
    INTEGER(KIND=int32) :: MFONTE
    INTEGER(KIND=int32) :: MFCHSP
    INTEGER(KIND=int32) :: MFEVV
    INTEGER(KIND=int32) :: MFLWSP
    INTEGER(KIND=int32) :: MFTR
    INTEGER(KIND=int32) :: MRUISL
    INTEGER(KIND=int32) :: MRUISP
    INTEGER(KIND=int32) :: MRUISS
    INTEGER(KIND=int32) :: MNEBCON
    INTEGER(KIND=int32) :: MNEBHAU
    INTEGER(KIND=int32) :: MNEBMOY
    INTEGER(KIND=int32) :: MNEBBAS
    INTEGER(KIND=int32) :: MFGEL
    INTEGER(KIND=int32) :: MFGELS
    INTEGER(KIND=int32) :: MFDUTP
    INTEGER(KIND=int32) :: MFLASH
  end type
  public :: native_instantaneous_flux_indices
  type :: native_instantaneous_flux_indices
    INTEGER(KIND=int32) :: MXTRDU
    INTEGER(KIND=int32) :: MXTRDV
    INTEGER(KIND=int32) :: MXTRCU
    INTEGER(KIND=int32) :: MXTRCV
    INTEGER(KIND=int32) :: MXDICQ
    INTEGER(KIND=int32) :: MXDICS
    INTEGER(KIND=int32) :: MXTRTU
    INTEGER(KIND=int32) :: MXTRTV
    INTEGER(KIND=int32) :: MXDITQ
    INTEGER(KIND=int32) :: MXDITS
    INTEGER(KIND=int32) :: MXPLCL
    INTEGER(KIND=int32) :: MXPLSL
    INTEGER(KIND=int32) :: MXPLCN
    INTEGER(KIND=int32) :: MXPLSN
    INTEGER(KIND=int32) :: MXPLCG
    INTEGER(KIND=int32) :: MXPLSG
    INTEGER(KIND=int32) :: MXPLCH
    INTEGER(KIND=int32) :: MXPLSH
    INTEGER(KIND=int32) :: MXRSO
    INTEGER(KIND=int32) :: MXRTH
    INTEGER(KIND=int32) :: MXQICE
    INTEGER(KIND=int32) :: MXQLI
    INTEGER(KIND=int32) :: MXNEB
    INTEGER(KIND=int32) :: MXNEBT
    INTEGER(KIND=int32) :: MXUCLS
    INTEGER(KIND=int32) :: MXVCLS
    INTEGER(KIND=int32) :: MXNUCLS
    INTEGER(KIND=int32) :: MXNVCLS
    INTEGER(KIND=int32) :: MXTCLS
    INTEGER(KIND=int32) :: MXQCLS
    INTEGER(KIND=int32) :: MXRHCLS
    INTEGER(KIND=int32) :: MXTPWCLS
    INTEGER(KIND=int32) :: MXTN
    INTEGER(KIND=int32) :: MXTX
    INTEGER(KIND=int32) :: MXMRT
    INTEGER(KIND=int32) :: MXHUX
    INTEGER(KIND=int32) :: MXHUN
    INTEGER(KIND=int32) :: MXNBCON
    INTEGER(KIND=int32) :: MXNBHAU
    INTEGER(KIND=int32) :: MXNBMOY
    INTEGER(KIND=int32) :: MXNBBAS
    INTEGER(KIND=int32) :: MXFONTE
    INTEGER(KIND=int32) :: MXFCHSP
    INTEGER(KIND=int32) :: MXFLWSP
    INTEGER(KIND=int32) :: MXFEVL
    INTEGER(KIND=int32) :: MXRUISP
    INTEGER(KIND=int32) :: MXRUISS
    INTEGER(KIND=int32) :: MXFEVV
    INTEGER(KIND=int32) :: MXFTR
    INTEGER(KIND=int32) :: MXRUISL
    INTEGER(KIND=int32) :: MXCAPE
    INTEGER(KIND=int32) :: MXCTOP
    INTEGER(KIND=int32) :: MXMOCON
    INTEGER(KIND=int32) :: MXCLPH
    INTEGER(KIND=int32) :: MXVEIN
    INTEGER(KIND=int32) :: MXUGST
    INTEGER(KIND=int32) :: MXVGST
    INTEGER(KIND=int32) :: MXUGST2
    INTEGER(KIND=int32) :: MXVGST2
    INTEGER(KIND=int32) :: MXTHW
    INTEGER(KIND=int32) :: MXXDIAGH
    INTEGER(KIND=int32) :: MXVISICLD
    INTEGER(KIND=int32) :: MXVISIHYD
    INTEGER(KIND=int32) :: MXCLWC
    INTEGER(KIND=int32) :: MXPTYPE
    INTEGER(KIND=int32) :: MXPTYPESEV
    INTEGER(KIND=int32) :: MXVISICLD2
    INTEGER(KIND=int32) :: MXVISIHYD2
    INTEGER(KIND=int32) :: MXCLWC2
    INTEGER(KIND=int32) :: MXPTYPE2
    INTEGER(KIND=int32) :: MXPTYPESEV2
  end type
  public :: native_cumulated_flux_state
  type :: native_cumulated_flux_state
    INTEGER(KIND=int32) :: NCFUTS(0:max_cumulated_steps)
    INTEGER(KIND=int32) :: NFRRC
    INTEGER(KIND=int32) :: NFRCFU
    INTEGER(KIND=int32) :: NFDCFU
    INTEGER(KIND=int32) :: NTYPCFU
    INTEGER(KIND=int32) :: NMTFLASH
    REAL(KIND=real64) :: CALFLASH1, CALFLASH2
    TYPE(native_flux_family_descriptor) :: TYPE_CFU(max_cumulated_types)
    LOGICAL :: LCUMFU
    LOGICAL :: LREACFU
    LOGICAL :: LSTRD
    LOGICAL :: LSTRC
    LOGICAL :: LSTRT
    LOGICAL :: LFPLC
    LOGICAL :: LFPLCG
    LOGICAL :: LFPLCH
    LOGICAL :: LFPLS
    LOGICAL :: LFPLSG
    LOGICAL :: LFPLSH
    LOGICAL :: LFR
    LOGICAL :: LAMIP
    LOGICAL :: LRAYS
    LOGICAL :: LRAYD
    LOGICAL :: LNEBTT
    LOGICAL :: LFSF
    LOGICAL :: LFSOIL
    LOGICAL :: LNEBPAR
    LOGICAL :: LTSTRD
    LOGICAL :: LTSTRC
    LOGICAL :: LTSTRT
    LOGICAL :: LTFPLC
    LOGICAL :: LTFPLS
    LOGICAL :: LTFR
    LOGICAL :: LTNEB
    LOGICAL :: LFDUTP
    LOGICAL :: LMOON
    LOGICAL :: LFRRC
    LOGICAL :: LFLASH
    TYPE(native_cumulated_flux_indices) :: YCFUPT
    REAL(KIND=real64), ALLOCATABLE :: GFUBUF(:, :, :)
  end type
  public :: native_instantaneous_flux_state
  type :: native_instantaneous_flux_state
    TYPE(native_flux_family_descriptor) :: TYPE_XFU(max_instantaneous_types)
    REAL(KIND=real64), ALLOCATABLE :: RMWINDCALC(:)
    REAL(KIND=real64), ALLOCATABLE :: RMNWINDCALC(:)
    INTEGER(KIND=int32) :: MEANPERIOD
    INTEGER(KIND=int32) :: NMEANSTEPS
    INTEGER(KIND=int32) :: NXGSTPERIOD
    INTEGER(KIND=int32) :: NXGSTPERIOD2
    INTEGER(KIND=int32) :: NVISIPERIOD
    INTEGER(KIND=int32) :: NVISIPERIOD2
    INTEGER(KIND=int32) :: NXGSTTS
    INTEGER(KIND=int32) :: NTYPXFU
    INTEGER(KIND=int32) :: NXFUTS(0:max_instantaneous_steps)
    INTEGER(KIND=int32) :: NFRXFU
    INTEGER(KIND=int32) :: NRAZTS(0:max_instantaneous_steps)
    INTEGER(KIND=int32) :: NFRRAZ
    INTEGER(KIND=int32) :: N1RAZ
    INTEGER(KIND=int32) :: NFDXFU
    LOGICAL :: LXFU
    LOGICAL :: LRESET
    LOGICAL :: LRESET_GST
    LOGICAL :: LRESET_GST2
    LOGICAL :: LRESET_PRECIP
    LOGICAL :: LRESET_PRECIP2
    LOGICAL :: LRESET_VISI
    LOGICAL :: LRESET_VISI2
    LOGICAL :: LREAXFU
    LOGICAL :: LXTRD
    LOGICAL :: LXTRC
    LOGICAL :: LXTRT
    LOGICAL :: LXPLC
    LOGICAL :: LXPLCG
    LOGICAL :: LXPLCH
    LOGICAL :: LXPLS
    LOGICAL :: LXPLSG
    LOGICAL :: LXPLSH
    LOGICAL :: LXR
    LOGICAL :: LXNEBTT
    LOGICAL :: LXNEBPA
    LOGICAL :: LXCLS
    LOGICAL :: LXMWINDCLS
    LOGICAL :: LXNUVCLS
    LOGICAL :: LXTTCLS
    LOGICAL :: LXHHCLS
    LOGICAL :: LXTPWCLS
    LOGICAL :: LXSOIL
    LOGICAL :: LTXTRD
    LOGICAL :: LTXTRC
    LOGICAL :: LTXTRT
    LOGICAL :: LTXR
    LOGICAL :: LTXNEB
    LOGICAL :: LTXQICE
    LOGICAL :: LTXQLI
    LOGICAL :: LXICV
    LOGICAL :: LXCTOP
    LOGICAL :: LXCLP
    LOGICAL :: LXVEIN
    LOGICAL :: LXTGST
    LOGICAL :: LXXGST
    LOGICAL :: LXXGST2
    LOGICAL :: LXQCLS
    LOGICAL :: LXTHW
    LOGICAL :: LXXDIAGH
    LOGICAL :: LXMRT
    LOGICAL :: LXVISI
    LOGICAL :: LXVISI2
    TYPE(native_instantaneous_flux_indices) :: YXFUPT
    REAL(KIND=real64), ALLOCATABLE :: XFUBUF(:, :, :)
  end type
  public :: native_coupling_monitor_state
  type :: native_coupling_monitor_state
    REAL(KIND=real64), ALLOCATABLE :: RMCUFSP(:, :)
    REAL(KIND=real64), ALLOCATABLE :: RMCUFFP(:, :, :)
    REAL(KIND=real64) :: RMCUFA(0:max_filter_order, 1:max_filters), &
                                  & RMCUFB(1:max_filter_order, 1:max_filters), &
                                  & RMCUFI(1:max_filters)
    INTEGER(KIND=int32) :: NCUFOR, NCUFNR
    LOGICAL :: LMCUF, LREACUF
  end type
  public :: native_forecast_flux_controls
  type :: native_forecast_flux_controls
    type(native_cumulated_flux_state) :: cfu
    type(native_instantaneous_flux_state) :: xfu
    type(native_coupling_monitor_state) :: mcuf
  end type
end module
