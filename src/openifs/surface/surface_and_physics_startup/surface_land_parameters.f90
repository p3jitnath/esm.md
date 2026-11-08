!> Own the selected soil, vegetation and exchange parameter transaction.
module forecast_surface_land_parameters
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use yos_dim, only: tdim
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  use yos_exc, only: texc
  use forecast_owned_surface_land_soil, only: calculate_owned_soil_parameters
  use forecast_owned_surface_land_vegetation, only: calculate_owned_vegetation_parameters
  use suvexc_mod, only: suvexc
  implicit none
  private
  public :: native_surface_land_controls, initialize_surface_land_parameters, release_surface_land_parameters
  !> Switches are logical. RTHRFRTI,RALFMINPSN and RLAIINT are fractions;
  !! completed RCIMIN,REXTZ0M/H use metres; RPLRG is a gravity scale.
  type :: native_surface_land_controls
    logical(int32) :: levgen, lessro, lesn09, lesnml
    integer(int32) :: nsnmlws
    logical(int32) :: lelaiv, lectessel, leags, lefarquhar, leairco2coup
    logical(int32) :: leocwa, leocco, leocsa, leocla, lwcou, lwcou2w, lwcouhmf, lscmec, lrough
    real(real64) :: rthrfrti, ralfminpsn, rcimin, rlaiint, rextz0m, rextz0h, rplrg
  end type
  interface
    function errno_address() bind(C, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Each outer record is caller-owned and all35 array owners are absent.
  !! NCSS=4,NCSNEC=5,NTILES=9,NMONTH=12. Allocation and all arithmetic
  !! remain private until a complete successful commit. Failure1 frees
  !! only the private reached prefix; refusal2 changes no caller member.
  !! The seven source-unwritten soil switches remain unchanged.
  integer(int32) function initialize_surface_land_parameters(controls,constants,dimensions,soil,vegetation,exchange)result(status)
    type(native_surface_land_controls), intent(in) :: controls
    type(tcst), intent(in) :: constants
    type(tdim), intent(in) :: dimensions
    type(tsoil), intent(inout) :: soil
    type(tveg), intent(inout) :: vegetation
    type(texc), intent(inout) :: exchange
    type(tsoil), target :: pending_soil
    type(tveg), target :: pending_vegetation
    type(texc) :: pending_exchange
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: error
    status = 2
    if (dimensions%ncss /= 4 .or. dimensions%ncsnec /= 5 .or. dimensions%ntiles /= 9 .or. dimensions%nmonth /= 12) return
    if (controls%nsnmlws < 1 .or. controls%nsnmlws > 3) return
    if (.not. in_range(constants%rtt, 200.0_real64, 350.0_real64)) return
    if (.not. in_range(constants%rpi, 3.0_real64, 4.0_real64)) return
    if (.not. in_range(constants%retv, 0.0_real64, 2.0_real64)) return
    if (transfer(constants%retv, 0_int64) < 0_int64) return
    if (.not. in_range(controls%rthrfrti, 0.0_real64, 1.0_real64)) return
    if (.not. in_range(controls%ralfminpsn, 0.0_real64, 1.0_real64)) return
    if (.not. in_range(controls%rcimin, 0.0_real64, 1.0_real64)) return
    if (.not. in_range(controls%rlaiint, 0.0_real64, 1.0_real64)) return
    if (transfer(controls%rplrg, 0_int64) /= int(z'3FE0000000000000', int64) .and. &
        transfer(controls%rplrg, 0_int64) /= int(z'3FF0000000000000', int64) .and. &
        transfer(controls%rplrg, 0_int64) /= int(z'4000000000000000', int64)) return
    if (allocated(soil%rdat)) return
    if (allocated(soil%rdaw)) return
    if (allocated(soil%rdai)) return
    if (allocated(soil%rcwpsism)) return
    if (allocated(soil%rmvgalpha)) return
    if (allocated(soil%rwconsm)) return
    if (allocated(soil%rmfacm)) return
    if (allocated(soil%rnfacm)) return
    if (allocated(soil%rlambdam)) return
    if (allocated(soil%rwsatm)) return
    if (allocated(soil%rwcapm)) return
    if (allocated(soil%rwpwpm)) return
    if (allocated(soil%rwrestm)) return
    if (allocated(soil%rdmaxm)) return
    if (allocated(soil%rdminm)) return
    if (allocated(soil%rqwevapm)) return
    if (allocated(soil%rqwsbcrm)) return
    if (allocated(soil%rlambdadrym)) return
    if (allocated(soil%rlamsat1m)) return
    if (allocated(soil%rrcsoilm)) return
    if (allocated(soil%rsndtdestc_ml)) return
    if (allocated(soil%rlevsnmin)) return
    if (allocated(soil%rlevsnmax)) return
    if (allocated(soil%rlevsnmin_gl)) return
    if (allocated(soil%rlevsnmax_gl)) return
    if (allocated(vegetation%rvcov)) return
    if (allocated(vegetation%rvlai)) return
    if (allocated(vegetation%rvrootsa)) return
    if (allocated(vegetation%rvlamsk)) return
    if (allocated(vegetation%rvlamsks)) return
    if (allocated(vegetation%rvtrsr)) return
    if (allocated(vegetation%rvz0m)) return
    if (allocated(vegetation%rvz0h)) return
    if (allocated(vegetation%rvrsmin)) return
    if (allocated(vegetation%rvhstr)) return
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    pending_soil = soil
    pending_vegetation = vegetation
    pending_exchange = exchange
    allocate (pending_soil%rdat(1:4), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rdaw(1:4), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rdai(1:4), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rcwpsism(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rmvgalpha(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rwconsm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rmfacm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rnfacm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlambdam(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rwsatm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rwcapm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rwpwpm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rwrestm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rdmaxm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rdminm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rqwevapm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rqwsbcrm(0:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlambdadrym(1:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlamsat1m(1:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rrcsoilm(1:7), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rsndtdestc_ml(1:5), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlevsnmin(1:5), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlevsnmax(1:5), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlevsnmin_gl(1:5), stat=error)
    if (error /= 0) goto900
    allocate (pending_soil%rlevsnmax_gl(1:5), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvcov(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvlai(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvrootsa(1:4, 0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvlamsk(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvlamsks(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvtrsr(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvz0m(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvz0h(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvrsmin(0:20), stat=error)
    if (error /= 0) goto900
    allocate (pending_vegetation%rvhstr(0:20), stat=error)
    if (error /= 0) goto900
    call calculate_owned_soil_parameters(controls%rthrfrti, controls%levgen, controls%lessro, controls%lesn09, &
                       controls%lesnml, controls%nsnmlws, dimensions, constants, pending_soil, controls%ralfminpsn, controls%rcimin)
    call calculate_owned_vegetation_parameters(controls%lelaiv, controls%lectessel, controls%leags, &
              controls%lefarquhar, controls%leairco2coup, controls%rlaiint, dimensions, constants, pending_soil, pending_vegetation)
    call suvexc(controls%leocwa, controls%leocco, controls%leocsa, controls%leocla, controls%lwcou, &
                controls%lwcou2w, controls%lwcouhmf, controls%lscmec, controls%lrough, controls%rextz0m, controls%rextz0h, &
                controls%rplrg, pending_exchange)
    soil%lerolake = pending_soil%lerolake
    soil%leskti5 = pending_soil%leskti5
    soil%leskti8 = pending_soil%leskti8
    soil%lesn09 = pending_soil%lesn09
    soil%lesncheck = pending_soil%lesncheck
    soil%lesncheckabort = pending_soil%lesncheckabort
    soil%lesnml = pending_soil%lesnml
    soil%lesnwbcon = pending_soil%lesnwbcon
    soil%lesoilcond = pending_soil%lesoilcond
    soil%lessro = pending_soil%lessro
    soil%levgen = pending_soil%levgen
    soil%lewbcheck = pending_soil%lewbcheck
    soil%lewbcheckabort = pending_soil%lewbcheckabort
    soil%lewbsoilfix = pending_soil%lewbsoilfix
    soil%nlevsn = pending_soil%nlevsn
    soil%nsnmlws = pending_soil%nsnmlws
    soil%nsoty = pending_soil%nsoty
    soil%ralamsn = pending_soil%ralamsn
    soil%ralfmaxsn = pending_soil%ralfmaxsn
    soil%ralfminpsn = pending_soil%ralfminpsn
    soil%ralfminsn = pending_soil%ralfminsn
    soil%rcimin = pending_soil%rcimin
    soil%rcondsice = pending_soil%rcondsice
    soil%rcwpsis = pending_soil%rcwpsis
    soil%rdansice = pending_soil%rdansice
    soil%rdarsice = pending_soil%rdarsice
    soil%rdfsice = pending_soil%rdfsice
    soil%rdsnmax = pending_soil%rdsnmax
    soil%rfrsmall = pending_soil%rfrsmall
    soil%rfrtiny = pending_soil%rfrtiny
    soil%rgh2o = pending_soil%rgh2o
    soil%rhoci = pending_soil%rhoci
    soil%rhoice = pending_soil%rhoice
    soil%rhomaxsn = pending_soil%rhomaxsn
    soil%rhomaxsn_new = pending_soil%rhomaxsn_new
    soil%rhominsn = pending_soil%rhominsn
    soil%rhominsna = pending_soil%rhominsna
    soil%rhominsnb = pending_soil%rhominsnb
    soil%rhominsnc = pending_soil%rhominsnc
    soil%rhominsnd = pending_soil%rhominsnd
    soil%rkerst1 = pending_soil%rkerst1
    soil%rkerst2 = pending_soil%rkerst2
    soil%rkerst3 = pending_soil%rkerst3
    soil%rlambdadry = pending_soil%rlambdadry
    soil%rlambdaice = pending_soil%rlambdaice
    soil%rlambdawat = pending_soil%rlambdawat
    soil%rlamice = pending_soil%rlamice
    soil%rlamsat1 = pending_soil%rlamsat1
    soil%rlice = pending_soil%rlice
    soil%rlwcswea = pending_soil%rlwcswea
    soil%rlwcsweb = pending_soil%rlwcsweb
    soil%rlwcswec = pending_soil%rlwcswec
    soil%rpsfr = pending_soil%rpsfr
    soil%rqsncr = pending_soil%rqsncr
    soil%rqwevap = pending_soil%rqwevap
    soil%rqwsbcr = pending_soil%rqwsbcr
    soil%rrcsice = pending_soil%rrcsice
    soil%rrcsoil = pending_soil%rrcsoil
    soil%rsfresh = pending_soil%rsfresh
    soil%rsigormax = pending_soil%rsigormax
    soil%rsigormin = pending_soil%rsigormin
    soil%rsimp = pending_soil%rsimp
    soil%rsndamob = pending_soil%rsndamob
    soil%rsndatauw = pending_soil%rsndatauw
    soil%rsndaw = pending_soil%rsndaw
    soil%rsndbtauw = pending_soil%rsndbtauw
    soil%rsndbw = pending_soil%rsndbw
    soil%rsndkv = pending_soil%rsndkv
    soil%rsndmob = pending_soil%rsndmob
    soil%rsndtdesta = pending_soil%rsndtdesta
    soil%rsndtdestb = pending_soil%rsndtdestb
    soil%rsndtdestc = pending_soil%rsndtdestc
    soil%rsndtdestroi = pending_soil%rsndtdestroi
    soil%rsndtovera = pending_soil%rsndtovera
    soil%rsndtoverb = pending_soil%rsndtoverb
    soil%rsndtoverc = pending_soil%rsndtoverc
    soil%rsndwcompmax = pending_soil%rsndwcompmax
    soil%rsnper = pending_soil%rsnper
    soil%rsrdep = pending_soil%rsrdep
    soil%rtaua = pending_soil%rtaua
    soil%rtauf = pending_soil%rtauf
    soil%rtempamp = pending_soil%rtempamp
    soil%rtf1 = pending_soil%rtf1
    soil%rtf2 = pending_soil%rtf2
    soil%rtf3 = pending_soil%rtf3
    soil%rtf4 = pending_soil%rtf4
    soil%rtfreezsice = pending_soil%rtfreezsice
    soil%rthrfrti = pending_soil%rthrfrti
    soil%rtmeltsice = pending_soil%rtmeltsice
    soil%rwb = pending_soil%rwb
    soil%rwcap = pending_soil%rwcap
    soil%rwcons = pending_soil%rwcons
    soil%rwlmax = pending_soil%rwlmax
    soil%rwpwp = pending_soil%rwpwp
    soil%rwsat = pending_soil%rwsat
    soil%snhcondav = pending_soil%snhcondav
    soil%snhcondbv = pending_soil%snhcondbv
    soil%snhcondcv = pending_soil%snhcondcv
    soil%snhcondpov = pending_soil%snhcondpov
    soil%ssag1 = pending_soil%ssag1
    soil%ssag2 = pending_soil%ssag2
    soil%ssag3 = pending_soil%ssag3
    soil%ssagsnsmax = pending_soil%ssagsnsmax
    soil%ssasnextcnst = pending_soil%ssasnextcnst
    soil%ssasnextmax = pending_soil%ssasnextmax
    soil%ssasnextmin = pending_soil%ssasnextmin
    vegetation%leags = pending_vegetation%leags
    vegetation%leairco2coup = pending_vegetation%leairco2coup
    vegetation%lectessel = pending_vegetation%lectessel
    vegetation%lefarquhar = pending_vegetation%lefarquhar
    vegetation%lelaiv = pending_vegetation%lelaiv
    vegetation%nvtiles = pending_vegetation%nvtiles
    vegetation%nvtypes = pending_vegetation%nvtypes
    vegetation%rcepsw = pending_vegetation%rcepsw
    vegetation%rcvc = pending_vegetation%rcvc
    vegetation%repevap = pending_vegetation%repevap
    vegetation%repsr = pending_vegetation%repsr
    vegetation%rlaiint = pending_vegetation%rlaiint
    vegetation%rlhaero = pending_vegetation%rlhaero
    vegetation%rlhaeros = pending_vegetation%rlhaeros
    vegetation%rvinter = pending_vegetation%rvinter
    vegetation%rvlt = pending_vegetation%rvlt
    vegetation%rvrad = pending_vegetation%rvrad
    exchange = pending_exchange
    call move_alloc(pending_soil%rdat, soil%rdat)
    call move_alloc(pending_soil%rdaw, soil%rdaw)
    call move_alloc(pending_soil%rdai, soil%rdai)
    call move_alloc(pending_soil%rcwpsism, soil%rcwpsism)
    call move_alloc(pending_soil%rmvgalpha, soil%rmvgalpha)
    call move_alloc(pending_soil%rwconsm, soil%rwconsm)
    call move_alloc(pending_soil%rmfacm, soil%rmfacm)
    call move_alloc(pending_soil%rnfacm, soil%rnfacm)
    call move_alloc(pending_soil%rlambdam, soil%rlambdam)
    call move_alloc(pending_soil%rwsatm, soil%rwsatm)
    call move_alloc(pending_soil%rwcapm, soil%rwcapm)
    call move_alloc(pending_soil%rwpwpm, soil%rwpwpm)
    call move_alloc(pending_soil%rwrestm, soil%rwrestm)
    call move_alloc(pending_soil%rdmaxm, soil%rdmaxm)
    call move_alloc(pending_soil%rdminm, soil%rdminm)
    call move_alloc(pending_soil%rqwevapm, soil%rqwevapm)
    call move_alloc(pending_soil%rqwsbcrm, soil%rqwsbcrm)
    call move_alloc(pending_soil%rlambdadrym, soil%rlambdadrym)
    call move_alloc(pending_soil%rlamsat1m, soil%rlamsat1m)
    call move_alloc(pending_soil%rrcsoilm, soil%rrcsoilm)
    call move_alloc(pending_soil%rsndtdestc_ml, soil%rsndtdestc_ml)
    call move_alloc(pending_soil%rlevsnmin, soil%rlevsnmin)
    call move_alloc(pending_soil%rlevsnmax, soil%rlevsnmax)
    call move_alloc(pending_soil%rlevsnmin_gl, soil%rlevsnmin_gl)
    call move_alloc(pending_soil%rlevsnmax_gl, soil%rlevsnmax_gl)
    call move_alloc(pending_vegetation%rvcov, vegetation%rvcov)
    call move_alloc(pending_vegetation%rvlai, vegetation%rvlai)
    call move_alloc(pending_vegetation%rvrootsa, vegetation%rvrootsa)
    call move_alloc(pending_vegetation%rvlamsk, vegetation%rvlamsk)
    call move_alloc(pending_vegetation%rvlamsks, vegetation%rvlamsks)
    call move_alloc(pending_vegetation%rvtrsr, vegetation%rvtrsr)
    call move_alloc(pending_vegetation%rvz0m, vegetation%rvz0m)
    call move_alloc(pending_vegetation%rvz0h, vegetation%rvz0h)
    call move_alloc(pending_vegetation%rvrsmin, vegetation%rvrsmin)
    call move_alloc(pending_vegetation%rvhstr, vegetation%rvhstr)
    error_number = saved_errno
    status = 0
    return
900 continue
    call release_private(pending_soil, pending_vegetation)
    error_number = saved_errno
    status = 1
  end function
  !> Release the35 owners in the exact source DEALLO order.
  integer(int32) function release_surface_land_parameters(soil, vegetation) result(status)
    type(tsoil), intent(inout) :: soil
    type(tveg), intent(inout) :: vegetation
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    if (allocated(soil%rdat)) deallocate (soil%rdat)
    if (allocated(soil%rdaw)) deallocate (soil%rdaw)
    if (allocated(soil%rdai)) deallocate (soil%rdai)
    if (allocated(soil%rcwpsism)) deallocate (soil%rcwpsism)
    if (allocated(soil%rmvgalpha)) deallocate (soil%rmvgalpha)
    if (allocated(soil%rwconsm)) deallocate (soil%rwconsm)
    if (allocated(soil%rmfacm)) deallocate (soil%rmfacm)
    if (allocated(soil%rnfacm)) deallocate (soil%rnfacm)
    if (allocated(soil%rlambdam)) deallocate (soil%rlambdam)
    if (allocated(soil%rwsatm)) deallocate (soil%rwsatm)
    if (allocated(soil%rwcapm)) deallocate (soil%rwcapm)
    if (allocated(soil%rwpwpm)) deallocate (soil%rwpwpm)
    if (allocated(soil%rwrestm)) deallocate (soil%rwrestm)
    if (allocated(soil%rdmaxm)) deallocate (soil%rdmaxm)
    if (allocated(soil%rdminm)) deallocate (soil%rdminm)
    if (allocated(soil%rqwevapm)) deallocate (soil%rqwevapm)
    if (allocated(soil%rqwsbcrm)) deallocate (soil%rqwsbcrm)
    if (allocated(soil%rlambdadrym)) deallocate (soil%rlambdadrym)
    if (allocated(soil%rlamsat1m)) deallocate (soil%rlamsat1m)
    if (allocated(soil%rrcsoilm)) deallocate (soil%rrcsoilm)
    if (allocated(soil%rsndtdestc_ml)) deallocate (soil%rsndtdestc_ml)
    if (allocated(soil%rlevsnmin)) deallocate (soil%rlevsnmin)
    if (allocated(soil%rlevsnmax)) deallocate (soil%rlevsnmax)
    if (allocated(soil%rlevsnmin_gl)) deallocate (soil%rlevsnmin_gl)
    if (allocated(soil%rlevsnmax_gl)) deallocate (soil%rlevsnmax_gl)
    if (allocated(vegetation%rvcov)) deallocate (vegetation%rvcov)
    if (allocated(vegetation%rvlai)) deallocate (vegetation%rvlai)
    if (allocated(vegetation%rvrootsa)) deallocate (vegetation%rvrootsa)
    if (allocated(vegetation%rvlamsk)) deallocate (vegetation%rvlamsk)
    if (allocated(vegetation%rvlamsks)) deallocate (vegetation%rvlamsks)
    if (allocated(vegetation%rvtrsr)) deallocate (vegetation%rvtrsr)
    if (allocated(vegetation%rvz0m)) deallocate (vegetation%rvz0m)
    if (allocated(vegetation%rvz0h)) deallocate (vegetation%rvz0h)
    if (allocated(vegetation%rvrsmin)) deallocate (vegetation%rvrsmin)
    if (allocated(vegetation%rvhstr)) deallocate (vegetation%rvhstr)
    error_number = saved_errno
    status = 0
  end function
  subroutine release_private(soil, vegetation)
    type(tsoil), intent(inout) :: soil
    type(tveg), intent(inout) :: vegetation
    if (allocated(soil%rdat)) deallocate (soil%rdat)
    if (allocated(soil%rdaw)) deallocate (soil%rdaw)
    if (allocated(soil%rdai)) deallocate (soil%rdai)
    if (allocated(soil%rcwpsism)) deallocate (soil%rcwpsism)
    if (allocated(soil%rmvgalpha)) deallocate (soil%rmvgalpha)
    if (allocated(soil%rwconsm)) deallocate (soil%rwconsm)
    if (allocated(soil%rmfacm)) deallocate (soil%rmfacm)
    if (allocated(soil%rnfacm)) deallocate (soil%rnfacm)
    if (allocated(soil%rlambdam)) deallocate (soil%rlambdam)
    if (allocated(soil%rwsatm)) deallocate (soil%rwsatm)
    if (allocated(soil%rwcapm)) deallocate (soil%rwcapm)
    if (allocated(soil%rwpwpm)) deallocate (soil%rwpwpm)
    if (allocated(soil%rwrestm)) deallocate (soil%rwrestm)
    if (allocated(soil%rdmaxm)) deallocate (soil%rdmaxm)
    if (allocated(soil%rdminm)) deallocate (soil%rdminm)
    if (allocated(soil%rqwevapm)) deallocate (soil%rqwevapm)
    if (allocated(soil%rqwsbcrm)) deallocate (soil%rqwsbcrm)
    if (allocated(soil%rlambdadrym)) deallocate (soil%rlambdadrym)
    if (allocated(soil%rlamsat1m)) deallocate (soil%rlamsat1m)
    if (allocated(soil%rrcsoilm)) deallocate (soil%rrcsoilm)
    if (allocated(soil%rsndtdestc_ml)) deallocate (soil%rsndtdestc_ml)
    if (allocated(soil%rlevsnmin)) deallocate (soil%rlevsnmin)
    if (allocated(soil%rlevsnmax)) deallocate (soil%rlevsnmax)
    if (allocated(soil%rlevsnmin_gl)) deallocate (soil%rlevsnmin_gl)
    if (allocated(soil%rlevsnmax_gl)) deallocate (soil%rlevsnmax_gl)
    if (allocated(vegetation%rvcov)) deallocate (vegetation%rvcov)
    if (allocated(vegetation%rvlai)) deallocate (vegetation%rvlai)
    if (allocated(vegetation%rvrootsa)) deallocate (vegetation%rvrootsa)
    if (allocated(vegetation%rvlamsk)) deallocate (vegetation%rvlamsk)
    if (allocated(vegetation%rvlamsks)) deallocate (vegetation%rvlamsks)
    if (allocated(vegetation%rvtrsr)) deallocate (vegetation%rvtrsr)
    if (allocated(vegetation%rvz0m)) deallocate (vegetation%rvz0m)
    if (allocated(vegetation%rvz0h)) deallocate (vegetation%rvz0h)
    if (allocated(vegetation%rvrsmin)) deallocate (vegetation%rvrsmin)
    if (allocated(vegetation%rvhstr)) deallocate (vegetation%rvhstr)
  end subroutine
  logical function in_range(value, lower, upper)
    real(real64), intent(in) :: value, lower, upper
    integer(int64) :: bits
    bits = transfer(value, 0_int64)
    in_range = .false.
    if (iand(shiftr(bits, 52), 2047_int64) == 2047_int64) return
    in_range = value >= lower .and. value <= upper
  end function
end module
