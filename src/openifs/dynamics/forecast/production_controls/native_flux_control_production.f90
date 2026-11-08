!> Produce source-inactive flux controls from actual setup and Fullpos owners.
module forecast_native_flux_controls
  use iso_fortran_env, only: int32, real64
  use forecast_native_flux_storage, only: native_forecast_flux_controls
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_fullpos_file_metadata, only: native_fullpos_file_metadata
  use yomfpc, only: tnamfpl, tnamfpsci
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_forecast_flux_controls, initialize_native_forecast_flux_controls, release_native_forecast_flux_controls
  public :: initialize_inactive_flux_source_values
contains
  !> Read the first source groups and consume the final Fullpos request records.
 !! MODEL, LEVELS, SCIENCE and FILE_METADATA are genuine readonly setup outputs.
 !! OUTPUT is their one final-address native CFU/XFU/MCUF owner. The supported
 !! route has LMPHYS/LDPRECIPS/LDPRECIPS2 false and no activating flux request.
 !! Active requests return2 before mutation. The two owned FP64 arrays have
 !! shape (live block width,0,live block count); their payload has zero bytes.
 !! Status0 publishes controls and allocations,1 means allocation failure,
 !! and2 means an unsupported or incomplete producer. No ready flag is added.
integer(int32) function initialize_native_forecast_flux_controls(text, model, levels, science, file_metadata, output) result(status)
    character(*), intent(in) :: text
    type(native_operational_model_configuration), target, intent(in) :: model
    type(tnamfpl), target, intent(in) :: levels
    type(tnamfpsci), target, intent(in) :: science
    type(native_fullpos_file_metadata), target, intent(in) :: file_metadata
    type(native_forecast_flux_controls), target, intent(inout) :: output
    integer(int32) :: nproma, ngpblks
    integer :: j
    character(16) :: activation_names(35)
    status = 2
    if (len(text) < 1 .or. len(text) > 262144) return
    if (.not. associated(model%initial)) return
    if (.not. allocated(model%initial%geometry)) return
    if (.not. model%initial%geometry%initialized) return
    if (model%initial%geometry%partition%phase /= 7) return
    if (model%initial%controls%namespace%lecmwf /= 1 .or. model%initial%controls%namespace%nfpos /= 2 .or. &
        model%initial%controls%namespace%nconf /= 1) return
    if (model%physics%phy%lmphys .or. model%physics%phy%ldprecips .or. model%physics%phy%ldprecips2) return
    if (.not. file_metadata%ready) return
    status = require_empty_physics_group(text, 'NAMCFU')
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMXFU')
    if (status /= 0) return
    status = require_empty_physics_group(text, 'NAMMCUF')
    if (status /= 0) return
    status = 2
    ! SUFPCFU/SUFPXFU stop at their first blank; later names are source-unread.
    if (levels%cfpcfu(1) /= ' ' .or. levels%cfpxfu(1) /= ' ') return
    if (science%lfpcapex) return
    activation_names = [character(16) :: &
                        file_metadata%yfa_xx2t%clname, &
                        file_metadata%yfa_xn2t%clname, &
                        file_metadata%yfa_xx2hu%clname, &
                        file_metadata%yfa_xn2hu%clname, &
                        file_metadata%yfa_asmc%clname, &
                        file_metadata%yfa_msat7c1%clname, &
                        file_metadata%yfa_msat7c2%clname, &
                        file_metadata%yfa_msat8c1%clname, &
                        file_metadata%yfa_msat8c2%clname, &
                        file_metadata%yfa_msat8c3%clname, &
                        file_metadata%yfa_msat8c4%clname, &
                        file_metadata%yfa_msat8c5%clname, &
                        file_metadata%yfa_msat8c6%clname, &
                        file_metadata%yfa_msat8c7%clname, &
                        file_metadata%yfa_msat8c8%clname, &
                        file_metadata%yfa_msat9c1%clname, &
                        file_metadata%yfa_msat9c2%clname, &
                        file_metadata%yfa_msat9c3%clname, &
                        file_metadata%yfa_msat9c4%clname, &
                        file_metadata%yfa_msat9c5%clname, &
                        file_metadata%yfa_msat9c6%clname, &
                        file_metadata%yfa_msat9c7%clname, &
                        file_metadata%yfa_msat9c8%clname, &
                        file_metadata%yfa_goes11c1%clname, &
                        file_metadata%yfa_goes11c2%clname, &
                        file_metadata%yfa_goes11c3%clname, &
                        file_metadata%yfa_goes11c4%clname, &
                        file_metadata%yfa_goes12c1%clname, &
                        file_metadata%yfa_goes12c2%clname, &
                        file_metadata%yfa_goes12c3%clname, &
                        file_metadata%yfa_goes12c4%clname, &
                        file_metadata%yfa_mtsat1c1%clname, &
                        file_metadata%yfa_mtsat1c2%clname, &
                        file_metadata%yfa_mtsat1c3%clname, &
                        file_metadata%yfa_mtsat1c4%clname]
    do j = 1, size(levels%cfp2df)
      if (any(levels%cfp2df(j) == activation_names)) return
      if (levels%cfp2df(j) == ' ') exit
    end do
    nproma = model%initial%geometry%dimensions%nproma
    ngpblks = model%initial%geometry%partition%ngpblks
    status = initialize_inactive_flux_source_values(nproma, ngpblks, output)
  end function

  !> Write the complete generated source-inactive setup values in source order.
 !! This common child requires prior request/control admission. It preserves
 !! unused family descriptors, reset flags and inactive wind-array owners.
 !! The compiler constructs the two rank-three zero-size array descriptors.
  integer(int32) function initialize_inactive_flux_source_values(nproma, ngpblks, output) result(status)
    integer(int32), intent(in) :: nproma, ngpblks
    type(native_forecast_flux_controls), target, intent(inout) :: output
    real(real64), allocatable :: cumulative(:, :, :), instantaneous(:, :, :)
    real(real64), volatile :: maximum_filter
    real(real64) :: coefficient
    integer :: allocation_status, j
    status = 2
    if (nproma < 1 .or. nproma > 4096 .or. ngpblks < 1) return
    if (allocated(output%cfu%gfubuf) .or. allocated(output%xfu%xfubuf)) return
    if (allocated(output%xfu%rmwindcalc) .or. allocated(output%xfu%rmnwindcalc)) return
    if (allocated(output%mcuf%rmcufsp) .or. allocated(output%mcuf%rmcuffp)) return
    allocate (cumulative(nproma, 0, ngpblks), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (instantaneous(nproma, 0, ngpblks), stat=allocation_status)
    if (allocation_status /= 0) then
      deallocate (cumulative); status = 1; return
    end if
    output%cfu%lcumfu = .false.
    output%cfu%lreacfu = .false.
    output%cfu%lstrd = .false.
    output%cfu%lstrc = .false.
    output%cfu%lstrt = .false.
    output%cfu%lfplc = .false.
    output%cfu%lfplcg = .false.
    output%cfu%lfplch = .false.
    output%cfu%lfpls = .false.
    output%cfu%lfplsg = .false.
    output%cfu%lfplsh = .false.
    output%cfu%lfr = .false.
    output%cfu%lamip = .false.
    output%cfu%lrays = .false.
    output%cfu%lrayd = .false.
    output%cfu%lnebtt = .false.
    output%cfu%lfsf = .false.
    output%cfu%lfsoil = .false.
    output%cfu%lnebpar = .false.
    output%cfu%ltstrd = .false.
    output%cfu%ltstrc = .false.
    output%cfu%ltstrt = .false.
    output%cfu%ltfplc = .false.
    output%cfu%ltfpls = .false.
    output%cfu%ltfr = .false.
    output%cfu%ltneb = .false.
    output%cfu%lfdutp = .false.
    output%cfu%lmoon = .false.
    output%cfu%lfrrc = .false.
    output%cfu%lflash = .false.
    output%cfu%ycfupt%mstrdu = 0
    output%cfu%ycfupt%mstrdv = 0
    output%cfu%ycfupt%mstrcu = 0
    output%cfu%ycfupt%mstrcv = 0
    output%cfu%ycfupt%mfdicq = 0
    output%cfu%ycfupt%mfdics = 0
    output%cfu%ycfupt%mstrtu = 0
    output%cfu%ycfupt%mstrtv = 0
    output%cfu%ycfupt%mfditq = 0
    output%cfu%ycfupt%mfdits = 0
    output%cfu%ycfupt%mfplcl = 0
    output%cfu%ycfupt%mfplsl = 0
    output%cfu%ycfupt%mfplcn = 0
    output%cfu%ycfupt%mfplsn = 0
    output%cfu%ycfupt%mfplcg = 0
    output%cfu%ycfupt%mfplsg = 0
    output%cfu%ycfupt%mfplch = 0
    output%cfu%ycfupt%mfplsh = 0
    output%cfu%ycfupt%mfccql = 0
    output%cfu%ycfupt%mfccqn = 0
    output%cfu%ycfupt%mfcsql = 0
    output%cfu%ycfupt%mfcsqn = 0
    output%cfu%ycfupt%mfrso = 0
    output%cfu%ycfupt%mfrth = 0
    output%cfu%ycfupt%mfneb = 0
    output%cfu%ycfupt%mws = 0
    output%cfu%ycfupt%msns = 0
    output%cfu%ycfupt%mqtot = 0
    output%cfu%ycfupt%mfnebt = 0
    output%cfu%ycfupt%mozont = 0
    output%cfu%ycfupt%mspres = 0
    output%cfu%ycfupt%mfcl = 0
    output%cfu%ycfupt%mfcs = 0
    output%cfu%ycfupt%mfdish = 0
    output%cfu%ycfupt%mftoph = 0
    output%cfu%ycfupt%mqice = 0
    output%cfu%ycfupt%mqli = 0
    output%cfu%ycfupt%mfrsoc0 = 0
    output%cfu%ycfupt%mfrthc0 = 0
    output%cfu%ycfupt%mfrsoc1 = 0
    output%cfu%ycfupt%mfrthc1 = 0
    output%cfu%ycfupt%mfrsdni = 0
    output%cfu%ycfupt%mfrsgni = 0
    output%cfu%ycfupt%mfrsops = 0
    output%cfu%ycfupt%mfrsopt = 0
    output%cfu%ycfupt%mfrsolu = 0
    output%cfu%ycfupt%mfrsods = 0
    output%cfu%ycfupt%mfrthds = 0
    output%cfu%ycfupt%mfcll = 0
    output%cfu%ycfupt%mfcln = 0
    output%cfu%ycfupt%mfevl = 0
    output%cfu%ycfupt%mfevn = 0
    output%cfu%ycfupt%mfonte = 0
    output%cfu%ycfupt%mfchsp = 0
    output%cfu%ycfupt%mfevv = 0
    output%cfu%ycfupt%mflwsp = 0
    output%cfu%ycfupt%mftr = 0
    output%cfu%ycfupt%mruisl = 0
    output%cfu%ycfupt%mruisp = 0
    output%cfu%ycfupt%mruiss = 0
    output%cfu%ycfupt%mnebcon = 0
    output%cfu%ycfupt%mnebhau = 0
    output%cfu%ycfupt%mnebmoy = 0
    output%cfu%ycfupt%mnebbas = 0
    output%cfu%ycfupt%mfgel = 0
    output%cfu%ycfupt%mfgels = 0
    output%cfu%ycfupt%mfdutp = 0
    output%cfu%ycfupt%mflash = 0
    output%cfu%ncfuts = 0
    output%cfu%nfrrc = 0; output%cfu%nfrcfu = 20
    output%cfu%nfdcfu = 0; output%cfu%ntypcfu = 0
    output%cfu%nmtflash = 1
    output%cfu%calflash1 = 1.0_real64; output%cfu%calflash2 = 1.0_real64
    output%xfu%lxfu = .false.
    output%xfu%lreaxfu = .false.
    output%xfu%lxtrd = .false.
    output%xfu%lxtrc = .false.
    output%xfu%lxtrt = .false.
    output%xfu%lxplc = .false.
    output%xfu%lxplcg = .false.
    output%xfu%lxplch = .false.
    output%xfu%lxpls = .false.
    output%xfu%lxplsg = .false.
    output%xfu%lxplsh = .false.
    output%xfu%lxr = .false.
    output%xfu%lxnebtt = .false.
    output%xfu%lxnebpa = .false.
    output%xfu%lxcls = .false.
    output%xfu%lxmwindcls = .false.
    output%xfu%lxnuvcls = .false.
    output%xfu%lxttcls = .false.
    output%xfu%lxhhcls = .false.
    output%xfu%lxtpwcls = .false.
    output%xfu%lxsoil = .false.
    output%xfu%ltxtrd = .false.
    output%xfu%ltxtrc = .false.
    output%xfu%ltxtrt = .false.
    output%xfu%ltxr = .false.
    output%xfu%ltxneb = .false.
    output%xfu%ltxqice = .false.
    output%xfu%ltxqli = .false.
    output%xfu%lxicv = .false.
    output%xfu%lxctop = .false.
    output%xfu%lxclp = .false.
    output%xfu%lxvein = .false.
    output%xfu%lxtgst = .false.
    output%xfu%lxxgst = .false.
    output%xfu%lxxgst2 = .false.
    output%xfu%lxqcls = .false.
    output%xfu%lxthw = .false.
    output%xfu%lxxdiagh = .false.
    output%xfu%lxmrt = .false.
    output%xfu%lxvisi = .false.
    output%xfu%lxvisi2 = .false.
    output%xfu%yxfupt%mxtrdu = 0
    output%xfu%yxfupt%mxtrdv = 0
    output%xfu%yxfupt%mxtrcu = 0
    output%xfu%yxfupt%mxtrcv = 0
    output%xfu%yxfupt%mxdicq = 0
    output%xfu%yxfupt%mxdics = 0
    output%xfu%yxfupt%mxtrtu = 0
    output%xfu%yxfupt%mxtrtv = 0
    output%xfu%yxfupt%mxditq = 0
    output%xfu%yxfupt%mxdits = 0
    output%xfu%yxfupt%mxplcl = 0
    output%xfu%yxfupt%mxplsl = 0
    output%xfu%yxfupt%mxplcn = 0
    output%xfu%yxfupt%mxplsn = 0
    output%xfu%yxfupt%mxplcg = 0
    output%xfu%yxfupt%mxplsg = 0
    output%xfu%yxfupt%mxplch = 0
    output%xfu%yxfupt%mxplsh = 0
    output%xfu%yxfupt%mxrso = 0
    output%xfu%yxfupt%mxrth = 0
    output%xfu%yxfupt%mxqice = 0
    output%xfu%yxfupt%mxqli = 0
    output%xfu%yxfupt%mxneb = 0
    output%xfu%yxfupt%mxnebt = 0
    output%xfu%yxfupt%mxucls = 0
    output%xfu%yxfupt%mxvcls = 0
    output%xfu%yxfupt%mxnucls = 0
    output%xfu%yxfupt%mxnvcls = 0
    output%xfu%yxfupt%mxtcls = 0
    output%xfu%yxfupt%mxqcls = 0
    output%xfu%yxfupt%mxrhcls = 0
    output%xfu%yxfupt%mxtpwcls = 0
    output%xfu%yxfupt%mxtn = 0
    output%xfu%yxfupt%mxtx = 0
    output%xfu%yxfupt%mxmrt = 0
    output%xfu%yxfupt%mxhux = 0
    output%xfu%yxfupt%mxhun = 0
    output%xfu%yxfupt%mxnbcon = 0
    output%xfu%yxfupt%mxnbhau = 0
    output%xfu%yxfupt%mxnbmoy = 0
    output%xfu%yxfupt%mxnbbas = 0
    output%xfu%yxfupt%mxfonte = 0
    output%xfu%yxfupt%mxfchsp = 0
    output%xfu%yxfupt%mxflwsp = 0
    output%xfu%yxfupt%mxfevl = 0
    output%xfu%yxfupt%mxruisp = 0
    output%xfu%yxfupt%mxruiss = 0
    output%xfu%yxfupt%mxfevv = 0
    output%xfu%yxfupt%mxftr = 0
    output%xfu%yxfupt%mxruisl = 0
    output%xfu%yxfupt%mxcape = 0
    output%xfu%yxfupt%mxctop = 0
    output%xfu%yxfupt%mxmocon = 0
    output%xfu%yxfupt%mxclph = 0
    output%xfu%yxfupt%mxvein = 0
    output%xfu%yxfupt%mxugst = 0
    output%xfu%yxfupt%mxvgst = 0
    output%xfu%yxfupt%mxugst2 = 0
    output%xfu%yxfupt%mxvgst2 = 0
    output%xfu%yxfupt%mxthw = 0
    output%xfu%yxfupt%mxxdiagh = 0
    output%xfu%yxfupt%mxvisicld = 0
    output%xfu%yxfupt%mxvisihyd = 0
    output%xfu%yxfupt%mxclwc = 0
    output%xfu%yxfupt%mxptype = 0
    output%xfu%yxfupt%mxptypesev = 0
    output%xfu%yxfupt%mxvisicld2 = 0
    output%xfu%yxfupt%mxvisihyd2 = 0
    output%xfu%yxfupt%mxclwc2 = 0
    output%xfu%yxfupt%mxptype2 = 0
    output%xfu%yxfupt%mxptypesev2 = 0
    output%xfu%nxfuts = 0; output%xfu%nrazts = 0
    output%xfu%nfrxfu = 20; output%xfu%nfrraz = 20
    output%xfu%n1raz = 1; output%xfu%nmeansteps = 1
    output%xfu%meanperiod = 600
    output%xfu%nxgstperiod = 3600; output%xfu%nxgstperiod2 = 900
    output%xfu%nvisiperiod = 3600; output%xfu%nvisiperiod2 = 900
    output%xfu%ntypxfu = 0; output%xfu%nfdxfu = 0
    output%mcuf%rmcufa = 0.0_real64; output%mcuf%rmcufb = 0.0_real64
    maximum_filter = 99999.0_real64
    do j = 1, size(output%mcuf%rmcufa, 2)
      coefficient = 2.0_real64*maximum_filter
      output%mcuf%rmcufa(0, j) = coefficient
    end do
    output%mcuf%rmcufi = 10800.0_real64
    output%mcuf%ncufor = 2; output%mcuf%ncufnr = 0
    output%mcuf%lmcuf = .false.; output%mcuf%lreacuf = .false.
    call move_alloc(cumulative, output%cfu%gfubuf)
    call move_alloc(instantaneous, output%xfu%xfubuf)
    status = 0
  end function

  !> Release only the two arrays created by the source-inactive route.
 !! All scalar controls and every source-unwritten member stay unchanged.
  integer(int32) function release_native_forecast_flux_controls(output) result(status)
    type(native_forecast_flux_controls), target, intent(inout) :: output
    if (allocated(output%cfu%gfubuf)) deallocate (output%cfu%gfubuf)
    if (allocated(output%xfu%xfubuf)) deallocate (output%xfu%xfubuf)
    status = 0
  end function
end module
