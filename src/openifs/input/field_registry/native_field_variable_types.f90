!> Native names and owners for forecast field registration.
module forecast_native_field_variable_types
  use iso_fortran_env, only: int32, real64
  use forecast_registry_field_types
  use grid_field_component_types_port, only: field_component_metadata
  use surface_field_registration_port, only: surface_field_metadata
  implicit none
  private
  public :: native_field_variables, native_surface_variables, native_registry_extra_aliases
  public :: native_registry_geometry_inputs, native_registry_ecphysics_inputs
  public :: native_registry_radiation_inputs
  type :: native_geometry_variables
    type(native_registry_variable_2d) :: rcori
    type(native_registry_variable_2d) :: rcoric
    type(native_registry_variable_2d) :: gemu
    type(native_registry_variable_2d) :: gsqm2
    type(native_registry_variable_2d) :: gelam
    type(native_registry_variable_2d) :: gelat
    type(native_registry_variable_2d) :: geclo
    type(native_registry_variable_2d) :: geslo
    type(native_registry_variable_2d) :: gm
    type(native_registry_variable_2d) :: gmappa
    type(native_registry_variable_2d) :: gomvrl
    type(native_registry_variable_2d) :: gomvrm
    type(native_registry_variable_2d) :: gnordl
    type(native_registry_variable_2d) :: gnordm
    type(native_registry_variable_2d) :: gnordlcl
    type(native_registry_variable_2d) :: gnordmcl
    type(native_registry_variable_2d) :: gnordmcm
    type(native_registry_variable_2d) :: gaw
    type(native_registry_variable_2d) :: orog
    type(native_registry_variable_2d) :: orogl
    type(native_registry_variable_2d) :: orogm
  end type
  type :: native_ecphys_variables
    type(native_registry_variable_3d) :: ustrti
    type(native_registry_variable_3d) :: vstrti
    type(native_registry_variable_3d) :: ahfsti
    type(native_registry_variable_3d) :: evapti
    type(native_registry_variable_3d) :: tskti
  end type
  type :: native_radiation_variables
    type(native_registry_variable_3d) :: emtd
    type(native_registry_variable_3d) :: trsw
    type(native_registry_variable_3d) :: emtc
    type(native_registry_variable_3d) :: trsc
    type(native_registry_variable_3d) :: emtu
    type(native_registry_variable_4d) :: tauaer
    type(native_registry_variable_2d) :: srswd
    type(native_registry_variable_2d) :: srlwdc
    type(native_registry_variable_3d) :: srlwd
    type(native_registry_variable_2d) :: srswdc
    type(native_registry_variable_2d) :: srswdcs
    type(native_registry_variable_2d) :: srlwdcs
    type(native_registry_variable_2d) :: srswdv
    type(native_registry_variable_2d) :: srswduv
    type(native_registry_variable_2d) :: edro
    type(native_registry_variable_2d) :: srswpar
    type(native_registry_variable_2d) :: srswuvb
    type(native_registry_variable_2d) :: srswparc
    type(native_registry_variable_2d) :: srswtinc
    type(native_registry_variable_2d) :: srfdir
    type(native_registry_variable_2d) :: srcdir
    type(native_registry_variable_2d) :: rmoon
    type(native_registry_variable_3d) :: derivativelw
  end type
  type :: native_field_variables
    type(native_registry_variable_3d) :: u
    type(native_registry_variable_3d) :: v
    type(native_registry_variable_3d) :: t
    type(native_registry_variable_3d) :: div
    type(native_registry_variable_3d) :: vor
    type(native_registry_variable_2d) :: sp
    type(native_registry_variable_3d) :: spd
    type(native_registry_variable_3d) :: svd
    type(native_registry_variable_3d) :: nhx
    type(native_registry_variable_3d) :: edot
    type(native_registry_variable_3d) :: sgrtl
    type(native_registry_variable_3d) :: sgrtm
    type(native_registry_variable_3d) :: q
    type(native_registry_variable_3d) :: i
    type(native_registry_variable_3d) :: l
    type(native_registry_variable_3d) :: lconv
    type(native_registry_variable_3d) :: iconv
    type(native_registry_variable_3d) :: rconv
    type(native_registry_variable_3d) :: sconv
    type(native_registry_variable_3d) :: irad
    type(native_registry_variable_3d) :: lrad
    type(native_registry_variable_3d) :: s
    type(native_registry_variable_3d) :: r
    type(native_registry_variable_3d) :: g
    type(native_registry_variable_3d) :: h
    type(native_registry_variable_3d) :: tke
    type(native_registry_variable_3d) :: tte
    type(native_registry_variable_3d) :: efb1
    type(native_registry_variable_3d) :: efb2
    type(native_registry_variable_3d) :: efb3
    type(native_registry_variable_3d) :: a
    type(native_registry_variable_3d) :: o3
    type(native_registry_variable_3d) :: src
    type(native_registry_variable_3d) :: mxl
    type(native_registry_variable_3d) :: shtur
    type(native_registry_variable_3d) :: fqtur
    type(native_registry_variable_3d) :: fstur
    type(native_registry_variable_3d) :: cpf
    type(native_registry_variable_3d) :: spf
    type(native_registry_variable_3d) :: cvgq
    type(native_registry_variable_3d) :: qva
    type(native_registry_variable_3d), pointer :: ghg_g(:) => null(), ghg(:) => null()
    type(native_registry_variable_3d), pointer :: chem_g(:) => null(), chem(:) => null()
    type(native_registry_variable_3d), pointer :: aero_g(:) => null(), aero(:) => null()
    type(native_registry_variable_3d) :: lrch4
    type(native_registry_variable_3d), pointer :: forc_g(:) => null(), forc(:) => null()
    type(native_registry_variable_3d), pointer :: ezdiag_g(:) => null(), ezdiag(:) => null()
    type(native_registry_variable_3d), pointer :: era40_g(:) => null(), era40(:) => null()
    type(native_registry_variable_3d), pointer :: nogw_g(:) => null(), nogw(:) => null()
    type(native_registry_variable_3d), pointer :: emis3d_g(:) => null(), emis3d(:) => null()
    type(native_registry_variable_3d), pointer :: edrp_g(:) => null(), edrp(:) => null()
    type(native_registry_variable_3d), pointer :: sldia_g(:) => null(), sldia(:) => null()
    type(native_registry_variable_3d), pointer :: aeraot_g(:) => null(), aeraot(:) => null()
    type(native_registry_variable_3d), pointer :: aerlisi_g(:) => null(), aerlisi(:) => null()
    type(native_registry_variable_3d), pointer :: aerout_g(:) => null(), aerout(:) => null()
    type(native_registry_variable_3d), pointer :: aeroclim_g(:) => null(), aeroclim(:) => null()
    type(native_registry_variable_3d), pointer :: uvp_g(:) => null(), uvp(:) => null()
    type(native_registry_variable_3d), pointer :: phys_g(:) => null(), phys(:) => null()
    type(native_registry_variable_3d) :: phycty
    type(native_registry_variable_3d) :: rspec
    type(native_registry_variable_3d) :: sdsat
    type(native_registry_variable_3d) :: cvv
    type(native_registry_variable_3d) :: rkth
    type(native_registry_variable_3d) :: rktqv
    type(native_registry_variable_3d) :: rktqc
    type(native_registry_variable_3d) :: uom
    type(native_registry_variable_3d) :: ual
    type(native_registry_variable_3d) :: dom
    type(native_registry_variable_3d) :: dal
    type(native_registry_variable_3d) :: uen
    type(native_registry_variable_3d) :: unebh
    type(native_registry_variable_3d), pointer :: lima_g(:) => null(), lima(:) => null()
    type(native_registry_variable_3d) :: fsd
    type(native_registry_variable_3d), pointer :: ext_g(:) => null(), ext(:) => null()
    type(native_geometry_variables) :: geometry
    type(native_ecphys_variables) :: ecphys
    type(native_radiation_variables) :: radiation
  end type
  type :: native_surface_variables_sp_sb
    type(native_registry_variable_3d) :: vt
    type(native_registry_variable_3d) :: vq
    type(native_registry_variable_3d) :: vtl
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sp_sg
    type(native_registry_variable_3d) :: vf
    type(native_registry_variable_3d) :: va
    type(native_registry_variable_3d) :: vr
    type(native_registry_variable_3d) :: vt
    type(native_registry_variable_3d) :: vw
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sp_sl
    type(native_registry_variable_2d) :: vlict
    type(native_registry_variable_2d) :: vlmlt
    type(native_registry_variable_2d) :: vltlt
    type(native_registry_variable_2d) :: vlblt
    type(native_registry_variable_2d) :: vlshf
    type(native_registry_variable_2d) :: vlicd
    type(native_registry_variable_2d) :: vlmld
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sp_rr
    type(native_registry_variable_2d) :: vt
    type(native_registry_variable_2d) :: vw
    type(native_registry_variable_2d) :: vfc
    type(native_registry_variable_2d) :: vic
    type(native_registry_variable_2d) :: vfp1
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sp_cl
    type(native_registry_variable_2d) :: vtcls
    type(native_registry_variable_2d) :: vhucls
    type(native_registry_variable_2d) :: vucls
    type(native_registry_variable_2d) :: vvcls
    type(native_registry_variable_2d) :: vnucls
    type(native_registry_variable_2d) :: vnvcls
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sp_om
    type(native_registry_variable_3d) :: vto
    type(native_registry_variable_3d) :: vso
    type(native_registry_variable_3d) :: vuo
    type(native_registry_variable_3d) :: vvo
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sp_ep
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sp_x2
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sp_ci
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_vf
    type(native_registry_variable_2d) :: vz0f
    type(native_registry_variable_2d) :: valbf
    type(native_registry_variable_2d) :: vemisf
    type(native_registry_variable_2d) :: vgetrl
    type(native_registry_variable_2d) :: vlsm
    type(native_registry_variable_2d) :: vveg
    type(native_registry_variable_2d) :: vvrlan
    type(native_registry_variable_2d) :: vvrldi
    type(native_registry_variable_2d) :: vsig
    type(native_registry_variable_2d) :: valbsf
    type(native_registry_variable_2d) :: vlan
    type(native_registry_variable_2d) :: vsst
    type(native_registry_variable_2d) :: vsss
    type(native_registry_variable_2d) :: vlz0h
    type(native_registry_variable_2d) :: vcvl
    type(native_registry_variable_2d) :: vco2typ
    type(native_registry_variable_2d) :: vcvh
    type(native_registry_variable_2d) :: vcur
    type(native_registry_variable_2d) :: vtvl
    type(native_registry_variable_2d) :: vtvh
    type(native_registry_variable_2d) :: vlail
    type(native_registry_variable_2d) :: vlaih
    type(native_registry_variable_2d) :: vfwet
    type(native_registry_variable_2d) :: vsoty
    type(native_registry_variable_2d) :: vclk
    type(native_registry_variable_2d) :: vdl
    type(native_registry_variable_2d) :: vci
    type(native_registry_variable_2d) :: vucur
    type(native_registry_variable_2d) :: vvcur
    type(native_registry_variable_2d) :: vz0rlf
    type(native_registry_variable_2d) :: vcgpp
    type(native_registry_variable_2d) :: vcrec
    type(native_registry_variable_2d) :: vsdfor
    type(native_registry_variable_2d) :: valuvp
    type(native_registry_variable_2d) :: valuvd
    type(native_registry_variable_2d) :: valnip
    type(native_registry_variable_2d) :: valnid
    type(native_registry_variable_2d) :: vfp1
    type(native_registry_variable_2d) :: vso2dd
    type(native_registry_variable_2d) :: vdmso
    type(native_registry_variable_2d) :: vurbf
    type(native_registry_variable_2d) :: vfca1
    type(native_registry_variable_2d) :: vfca2
    type(native_registry_variable_2d) :: vaerdep
    type(native_registry_variable_2d) :: vaerlts
    type(native_registry_variable_2d) :: vaerscc
    type(native_registry_variable_2d) :: vdsf
    type(native_registry_variable_2d), allocatable :: vchemflxo(:)
    type(native_registry_variable_2d), allocatable :: vchemwdflx(:)
    type(native_registry_variable_2d), allocatable :: vchemddflx(:)
    type(native_registry_variable_2d), allocatable :: vchemdv(:)
    type(native_registry_variable_2d) :: vnudm
    type(native_registry_variable_2d), allocatable :: vemis2d(:)
    type(native_registry_variable_2d), allocatable :: vemis2daux(:)
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_vn
    type(native_registry_variable_2d) :: vtop
    type(native_registry_variable_2d) :: vbas
    type(native_registry_variable_2d) :: vacpr
    type(native_registry_variable_2d) :: vaccpr
    type(native_registry_variable_2d) :: vaccpr5
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_v2
    type(native_registry_variable_2d) :: vocdep
    type(native_registry_variable_2d) :: vustrc
    type(native_registry_variable_2d) :: vvstrc
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_v3
    type(native_registry_variable_3d) :: vdifm
    type(native_registry_variable_3d) :: vdift
    type(native_registry_variable_3d) :: vdifs
    type(native_registry_variable_3d) :: vadvt
    type(native_registry_variable_3d) :: vadvs
    type(native_registry_variable_3d) :: vtri0
    type(native_registry_variable_3d) :: vtri1
    type(native_registry_variable_3d) :: vswdk
    type(native_registry_variable_3d) :: vzo
    type(native_registry_variable_3d) :: vho
    type(native_registry_variable_3d) :: vdo
    type(native_registry_variable_3d) :: vho_inv
    type(native_registry_variable_3d) :: vuoc
    type(native_registry_variable_3d) :: vvoc
    type(native_registry_variable_3d) :: votke
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sd_vd
    type(native_registry_variable_2d) :: vlsp
    type(native_registry_variable_2d) :: vcp
    type(native_registry_variable_2d) :: vsf
    type(native_registry_variable_2d) :: vfzra
    type(native_registry_variable_2d) :: vbld
    type(native_registry_variable_2d) :: vsshf
    type(native_registry_variable_2d) :: vslhf
    type(native_registry_variable_2d) :: vnee
    type(native_registry_variable_2d) :: vgpp
    type(native_registry_variable_2d) :: vrec
    type(native_registry_variable_2d) :: vmsl
    type(native_registry_variable_2d) :: vsp
    type(native_registry_variable_2d) :: vtcc
    type(native_registry_variable_2d) :: v10u
    type(native_registry_variable_2d) :: v10v
    type(native_registry_variable_2d) :: v2t
    type(native_registry_variable_2d) :: v2d
    type(native_registry_variable_2d) :: v2sh
    type(native_registry_variable_2d) :: vssr
    type(native_registry_variable_2d) :: vstr
    type(native_registry_variable_2d) :: vtsr
    type(native_registry_variable_2d) :: vttr
    type(native_registry_variable_2d) :: vewss
    type(native_registry_variable_2d) :: vnsss
    type(native_registry_variable_2d) :: ve
    type(native_registry_variable_2d) :: vpev
    type(native_registry_variable_2d) :: vccc
    type(native_registry_variable_2d) :: vlcc
    type(native_registry_variable_2d) :: vmcc
    type(native_registry_variable_2d) :: vhcc
    type(native_registry_variable_2d) :: vlgws
    type(native_registry_variable_2d) :: vmgws
    type(native_registry_variable_2d) :: vgwd
    type(native_registry_variable_2d) :: vmx2t
    type(native_registry_variable_2d) :: vmn2t
    type(native_registry_variable_2d), allocatable :: vmx2t6(:)
    type(native_registry_variable_2d), allocatable :: vmn2t6(:)
    type(native_registry_variable_2d) :: vro
    type(native_registry_variable_2d) :: vsro
    type(native_registry_variable_2d) :: vssro
    type(native_registry_variable_2d) :: valb
    type(native_registry_variable_2d) :: viewss
    type(native_registry_variable_2d) :: vinsss
    type(native_registry_variable_2d) :: visshf
    type(native_registry_variable_2d) :: vie
    type(native_registry_variable_2d) :: vinee
    type(native_registry_variable_2d) :: vigpp
    type(native_registry_variable_2d) :: virec
    type(native_registry_variable_2d) :: vich4
    type(native_registry_variable_2d) :: vcsf
    type(native_registry_variable_2d) :: vlssf
    type(native_registry_variable_2d) :: vmxtpr
    type(native_registry_variable_2d) :: vmntpr
    type(native_registry_variable_2d), allocatable :: vmxtpr6(:)
    type(native_registry_variable_2d), allocatable :: vmntpr6(:)
    type(native_registry_variable_2d) :: vtpr
    type(native_registry_variable_2d) :: vlsrr
    type(native_registry_variable_2d) :: vcrr
    type(native_registry_variable_2d) :: vlssfr
    type(native_registry_variable_2d) :: vcsfr
    type(native_registry_variable_2d) :: vptype
    type(native_registry_variable_2d) :: vilspf
    type(native_registry_variable_2d) :: vz0f
    type(native_registry_variable_2d) :: vlz0h
    type(native_registry_variable_2d) :: vviwve
    type(native_registry_variable_2d) :: vviwvn
    type(native_registry_variable_2d) :: vtcw
    type(native_registry_variable_2d) :: vtcwv
    type(native_registry_variable_2d) :: vtclw
    type(native_registry_variable_2d) :: vtciw
    type(native_registry_variable_2d) :: vtcrw
    type(native_registry_variable_2d) :: vtcsw
    type(native_registry_variable_2d) :: vtcslw
    type(native_registry_variable_2d) :: vssrd
    type(native_registry_variable_2d) :: vstrd
    type(native_registry_variable_2d) :: vssrdc
    type(native_registry_variable_2d) :: vstrdc
    type(native_registry_variable_2d) :: vblh
    type(native_registry_variable_2d) :: vsund
    type(native_registry_variable_2d) :: vspar
    type(native_registry_variable_2d) :: vsuvb
    type(native_registry_variable_2d) :: vsfdir
    type(native_registry_variable_2d) :: vscdir
    type(native_registry_variable_2d) :: vsdsrp
    type(native_registry_variable_2d) :: vcape
    type(native_registry_variable_2d) :: vmucape
    type(native_registry_variable_2d) :: vmlcape50
    type(native_registry_variable_2d) :: vmlcape100
    type(native_registry_variable_2d) :: vpdepl
    type(native_registry_variable_2d) :: vcapes
    type(native_registry_variable_2d), allocatable :: vmxcap6(:)
    type(native_registry_variable_2d), allocatable :: vmxcaps6(:)
    type(native_registry_variable_2d) :: vtropotp
    type(native_registry_variable_2d) :: vtsrc
    type(native_registry_variable_2d) :: vttrc
    type(native_registry_variable_2d) :: vssrc
    type(native_registry_variable_2d) :: vstrc
    type(native_registry_variable_2d) :: ves
    type(native_registry_variable_2d) :: vsmlt
    type(native_registry_variable_2d) :: v10fg
    type(native_registry_variable_2d), allocatable :: v10fg6(:)
    type(native_registry_variable_2d) :: v10fgcv
    type(native_registry_variable_2d) :: vi10fg
    type(native_registry_variable_2d) :: vlspf
    type(native_registry_variable_2d) :: vtco3
    type(native_registry_variable_2d) :: vvimd
    type(native_registry_variable_2d) :: vsparc
    type(native_registry_variable_2d) :: vstinc
    type(native_registry_variable_2d) :: vcbase
    type(native_registry_variable_2d) :: v0degl
    type(native_registry_variable_2d) :: vm10degl
    type(native_registry_variable_2d) :: vvisih
    type(native_registry_variable_2d) :: vcin
    type(native_registry_variable_2d) :: vmlcin50
    type(native_registry_variable_2d) :: vmlcin100
    type(native_registry_variable_2d) :: vkindex
    type(native_registry_variable_2d) :: vttindex
    type(native_registry_variable_2d) :: vcbasea
    type(native_registry_variable_2d) :: vctopc
    type(native_registry_variable_2d) :: vztwetb0
    type(native_registry_variable_2d) :: vztwetb1
    type(native_registry_variable_2d), allocatable :: vtcghg(:)
    type(native_registry_variable_2d), allocatable :: vtcchem(:)
    type(native_registry_variable_2d), allocatable :: vaerodiag(:, :)
    type(native_registry_variable_2d), allocatable :: vaero_wvl_diag(:, :)
    type(native_registry_variable_2d) :: v100u
    type(native_registry_variable_2d) :: v100v
    type(native_registry_variable_2d) :: v200u
    type(native_registry_variable_2d) :: v200v
    type(native_registry_variable_2d) :: vzust
    type(native_registry_variable_2d) :: v10nu
    type(native_registry_variable_2d) :: v10nv
    type(native_registry_variable_2d) :: vdndzn
    type(native_registry_variable_2d) :: vdndza
    type(native_registry_variable_2d) :: vdctb
    type(native_registry_variable_2d) :: vtplb
    type(native_registry_variable_2d) :: vtplt
    type(native_registry_variable_2d) :: vodss
    type(native_registry_variable_2d) :: voddu
    type(native_registry_variable_2d) :: vodom
    type(native_registry_variable_2d) :: vodbc
    type(native_registry_variable_2d) :: vodsu
    type(native_registry_variable_2d) :: vodni
    type(native_registry_variable_2d) :: vodam
    type(native_registry_variable_2d) :: vodsoa
    type(native_registry_variable_2d) :: vodvfa
    type(native_registry_variable_2d) :: vodvsu
    type(native_registry_variable_2d) :: vodtoacc
    type(native_registry_variable_2d) :: vaepm1
    type(native_registry_variable_2d) :: vaepm25
    type(native_registry_variable_2d) :: vaepm10
    type(native_registry_variable_2d) :: vuvbed
    type(native_registry_variable_2d) :: vuvbedcs
    type(native_registry_variable_2d) :: vlitoti
    type(native_registry_variable_2d) :: vlicgi
    type(native_registry_variable_2d), allocatable :: vlitota6(:)
    type(native_registry_variable_2d), allocatable :: vlicga6(:)
    type(native_registry_variable_2d), allocatable :: vptypeocc6(:, :)
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_sm
    type(native_registry_variable_3d) :: vclbt
    type(native_registry_variable_3d) :: vcsbt
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sd_ws
    type(native_registry_variable_2d) :: vchar
    type(native_registry_variable_2d) :: vcharhq
    type(native_registry_variable_2d) :: vustokes
    type(native_registry_variable_2d) :: vvstokes
    type(native_registry_variable_2d) :: vtauocx
    type(native_registry_variable_2d) :: vtauocy
    type(native_registry_variable_2d) :: vphioc
    type(native_registry_variable_2d) :: vwsemean
    type(native_registry_variable_2d) :: vwsfmean
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_ww
    type(native_registry_variable_2d) :: vu10n
    type(native_registry_variable_2d) :: vv10n
    type(native_registry_variable_2d) :: vrho
    type(native_registry_variable_2d) :: vzil
    type(native_registry_variable_2d) :: vcif
    type(native_registry_variable_2d) :: vclk
    type(native_registry_variable_2d) :: vucurw
    type(native_registry_variable_2d) :: vvcurw
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables_sd_xa
    type(native_registry_field_4d) :: f_group
  end type
  type :: native_surface_variables_sd_x2
    type(native_registry_field_3d) :: f_group
  end type
  type :: native_surface_variables
    type(native_surface_variables_sp_sb) :: gsp_sb
    type(native_surface_variables_sp_sg) :: gsp_sg
    type(native_surface_variables_sp_sl) :: gsp_sl
    type(native_surface_variables_sp_rr) :: gsp_rr
    type(native_surface_variables_sp_cl) :: gsp_cl
    type(native_surface_variables_sp_om) :: gsp_om
    type(native_surface_variables_sp_ep) :: gsp_ep
    type(native_surface_variables_sp_x2) :: gsp_x2
    type(native_surface_variables_sp_ci) :: gsp_ci
    type(native_surface_variables_sd_vf) :: gsd_vf
    type(native_surface_variables_sd_vn) :: gsd_vn
    type(native_surface_variables_sd_v2) :: gsd_v2
    type(native_surface_variables_sd_v3) :: gsd_v3
    type(native_surface_variables_sd_vd) :: gsd_vd
    type(native_surface_variables_sd_sm) :: gsd_sm
    type(native_surface_variables_sd_ws) :: gsd_ws
    type(native_surface_variables_sd_ww) :: gsd_ww
    type(native_surface_variables_sd_xa) :: gsd_xa
    type(native_surface_variables_sd_x2) :: gsd_x2
  end type
  !> Borrowed FP64 arrays; callers retain every numerical owner and its lifetime.
  type :: native_registry_geometry_inputs
    real(real64), pointer :: rcori(:, :) => null()
    real(real64), pointer :: rcoric(:, :) => null()
    real(real64), pointer :: gemu(:, :) => null()
    real(real64), pointer :: gsqm2(:, :) => null()
    real(real64), pointer :: gelam(:, :) => null()
    real(real64), pointer :: gelat(:, :) => null()
    real(real64), pointer :: geclo(:, :) => null()
    real(real64), pointer :: geslo(:, :) => null()
    real(real64), pointer :: gm(:, :) => null()
    real(real64), pointer :: gmappa(:, :) => null()
    real(real64), pointer :: gomvrl(:, :) => null()
    real(real64), pointer :: gomvrm(:, :) => null()
    real(real64), pointer :: gnordl(:, :) => null()
    real(real64), pointer :: gnordm(:, :) => null()
    real(real64), pointer :: gnordlcl(:, :) => null()
    real(real64), pointer :: gnordmcl(:, :) => null()
    real(real64), pointer :: gnordmcm(:, :) => null()
    real(real64), pointer :: gaw(:, :) => null()
    real(real64), pointer :: orog(:, :) => null()
    real(real64), pointer :: orogl(:, :) => null()
    real(real64), pointer :: orogm(:, :) => null()
  end type
  !> Borrowed FP64 arrays; callers retain every numerical owner and its lifetime.
  type :: native_registry_ecphysics_inputs
    real(real64), pointer :: ustrti(:, :, :) => null()
    real(real64), pointer :: vstrti(:, :, :) => null()
    real(real64), pointer :: ahfsti(:, :, :) => null()
    real(real64), pointer :: evapti(:, :, :) => null()
    real(real64), pointer :: tskti(:, :, :) => null()
  end type
  !> Borrowed FP64 arrays; callers retain every numerical owner and its lifetime.
  type :: native_registry_radiation_inputs
    real(real64), pointer :: emtd(:, :, :) => null()
    real(real64), pointer :: trsw(:, :, :) => null()
    real(real64), pointer :: emtc(:, :, :) => null()
    real(real64), pointer :: trsc(:, :, :) => null()
    real(real64), pointer :: emtu(:, :, :) => null()
    real(real64), pointer :: tauaer(:, :, :, :) => null()
    real(real64), pointer :: srswd(:, :) => null()
    real(real64), pointer :: srlwdc(:, :) => null()
    real(real64), pointer :: srlwd(:, :, :) => null()
    real(real64), pointer :: srswdc(:, :) => null()
    real(real64), pointer :: srswdcs(:, :) => null()
    real(real64), pointer :: srlwdcs(:, :) => null()
    real(real64), pointer :: srswdv(:, :) => null()
    real(real64), pointer :: srswduv(:, :) => null()
    real(real64), pointer :: edro(:, :) => null()
    real(real64), pointer :: srswpar(:, :) => null()
    real(real64), pointer :: srswuvb(:, :) => null()
    real(real64), pointer :: srswparc(:, :) => null()
    real(real64), pointer :: srswtinc(:, :) => null()
    real(real64), pointer :: srfdir(:, :) => null()
    real(real64), pointer :: srcdir(:, :) => null()
    real(real64), pointer :: rmoon(:, :) => null()
    real(real64), pointer :: derivativelw(:, :, :) => null()
  end type
  !> Four original aliases which have no member in the existing producer records.
  !! These views borrow metadata only. An absent pointer denotes an absent
  !! original alias only when its upstream producer has established that fact.
  type :: native_registry_extra_aliases
    type(field_component_metadata), pointer :: phys(:) => null()
    type(surface_field_metadata), pointer :: tcghg(:) => null(), tcchem(:) => null(), aerodiag(:, :) => null()
  end type
end module forecast_native_field_variable_types
