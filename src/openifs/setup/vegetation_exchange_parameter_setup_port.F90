module susveg_mod
  use iso_fortran_env, only: int32,int64,real64
  use yos_dim, only: tdim
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use yos_veg, only: tveg
  use srfrootfr_mod, only: srfrootfr
  implicit none
  private
  public :: susveg
  interface
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
  real(real64), parameter :: initial_rvcov(20)=[ &
    0.9_real64, &
    0.85_real64, &
    0.9_real64, &
    0.9_real64, &
    0.9_real64, &
    0.99_real64, &
    0.7_real64, &
    0.0_real64, &
    0.5_real64, &
    0.9_real64, &
    0.1_real64, &
    0.0_real64, &
    0.6_real64, &
    0.0_real64, &
    0.0_real64, &
    0.5_real64, &
    0.5_real64, &
    0.9_real64, &
    0.9_real64, &
    0.6_real64]
  real(real64), parameter :: initial_rvlai(20)=[ &
    3.0_real64, &
    2.0_real64, &
    5.0_real64, &
    5.0_real64, &
    5.0_real64, &
    6.0_real64, &
    2.0_real64, &
    0.5_real64, &
    1.0_real64, &
    3.0_real64, &
    0.5_real64, &
    0.0_real64, &
    4.0_real64, &
    0.0_real64, &
    0.0_real64, &
    3.0_real64, &
    1.5_real64, &
    5.0_real64, &
    2.5_real64, &
    4.0_real64]
  real(real64), parameter :: initial_rvlamsk(20)=[ &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    15.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    58.0_real64, &
    10.0_real64, &
    10000000000.0_real64, &
    10000000000.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10000000000.0_real64]
  real(real64), parameter :: initial_rvlamsks(20)=[ &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    15.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    58.0_real64, &
    10.0_real64, &
    10000000000.0_real64, &
    10000000000.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10.0_real64, &
    10000000000.0_real64]
  real(real64), parameter :: initial_rvtrsr(20)=[ &
    0.05_real64, &
    0.05_real64, &
    0.03_real64, &
    0.03_real64, &
    0.03_real64, &
    0.03_real64, &
    0.05_real64, &
    0.0_real64, &
    0.05_real64, &
    0.05_real64, &
    0.05_real64, &
    0.0_real64, &
    0.05_real64, &
    0.0_real64, &
    0.0_real64, &
    0.05_real64, &
    0.05_real64, &
    0.03_real64, &
    0.03_real64, &
    0.0_real64]
  real(real64), parameter :: initial_rvrsmin(20)=[ &
    100.0_real64, &
    100.0_real64, &
    250.0_real64, &
    250.0_real64, &
    175.0_real64, &
    240.0_real64, &
    100.0_real64, &
    250.0_real64, &
    80.0_real64, &
    100.0_real64, &
    150.0_real64, &
    0.0_real64, &
    240.0_real64, &
    0.0_real64, &
    0.0_real64, &
    225.0_real64, &
    225.0_real64, &
    250.0_real64, &
    175.0_real64, &
    150.0_real64]
  real(real64), parameter :: initial_rvhstr(20)=[ &
    0.0_real64, &
    0.0_real64, &
    0.03_real64, &
    0.03_real64, &
    0.03_real64, &
    0.03_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.0_real64, &
    0.03_real64, &
    0.03_real64, &
    0.0_real64]
  real(real64), parameter :: initial_rvz0m(20)=[ &
    0.25_real64, &
    0.1_real64, &
    2.0_real64, &
    2.0_real64, &
    2.0_real64, &
    2.0_real64, &
    0.47_real64, &
    0.013_real64, &
    0.034_real64, &
    0.5_real64, &
    0.17_real64, &
    0.0013_real64, &
    0.5_real64, &
    0.0001_real64, &
    0.0001_real64, &
    0.1_real64, &
    0.25_real64, &
    2.0_real64, &
    1.1_real64, &
    0.02_real64]
  integer(int32), parameter :: heat_divisor(20)=[1,1,0,0,0,0,1,1,1,1,1,2,1,2,2,1,1,0,1,2]
contains
  !> Set vegetation parameters and root fractions for twenty surface types.
  !!
  !! The five logical controls select the declared vegetation options. PRLAIINT
  !! is the dimensionless leaf area fraction. YDDIM has four soil layers and
  !! nine tiles. YDCST supplies the dimensionless humidity factor RETV.
  !! YDSOIL supplies four water-layer depths in metres. YDVEG owns nine vectors
  !! with bounds 0:20 and root fractions with bounds (1:4,0:20). The default
  !! type zero copies desert type eight. Other source-unwritten fields retain
  !! their incoming values. A private result is committed after all arithmetic.
  subroutine susveg(ld_lelaiv,ld_lectessel,ld_leags,ld_lefarquhar,ld_leairco2coup,prlaiint,yddim,ydcst,ydsoil,ydveg)
    logical(int32), intent(in) :: ld_lelaiv,ld_lectessel,ld_leags,ld_lefarquhar,ld_leairco2coup
    real(real64), intent(in) :: prlaiint
    type(tdim), intent(in) :: yddim
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(in) :: ydsoil
    type(tveg), intent(inout) :: ydveg
    type(tveg) :: work
    real(real64) :: value,humidity_scale
    integer(int32) :: vegetation,status
    if (yddim%ncss/=4 .or. yddim%ntiles/=9) call reject_contract()
    if (.not.in_range(prlaiint,0.0_real64,1.0_real64)) call reject_contract()
    if (.not.in_range(ydcst%retv,0.0_real64,2.0_real64)) call reject_contract()
    if (transfer(ydcst%retv,0_int64)<0_int64) call reject_contract()
    if (.not.allocated(ydsoil%rdaw)) call reject_contract()
    if (size(ydsoil%rdaw)/=4) call reject_contract()
    work=ydveg
    call ensure_vector(work%rvcov)
    call ensure_vector(work%rvlai)
    call ensure_vector(work%rvlamsk)
    call ensure_vector(work%rvlamsks)
    call ensure_vector(work%rvtrsr)
    call ensure_vector(work%rvz0m)
    call ensure_vector(work%rvz0h)
    call ensure_vector(work%rvrsmin)
    call ensure_vector(work%rvhstr)
    if (allocated(work%rvrootsa)) then
      if (any(lbound(work%rvrootsa)/=[1,0]) .or. any(ubound(work%rvrootsa)/=[4,20])) call reject_contract()
    else
      allocate(work%rvrootsa(1:4,0:20),stat=status)
      if (status/=0) call reject_contract()
    end if
    work%nvtypes=20
    work%nvtiles=2
    work%repevap=1.0e-10_real64
    work%rvinter=0.5_real64
    work%rvcov(1:20)=initial_rvcov
    work%rvcov(0)=work%rvcov(8)
    work%rvlai(1:20)=initial_rvlai
    work%rvlai(0)=work%rvlai(8)
    work%lelaiv=ld_lelaiv
    work%lectessel=ld_lectessel
    work%leags=ld_leags
    work%lefarquhar=ld_lefarquhar
    work%leairco2coup=ld_leairco2coup
    work%rlaiint=prlaiint
    work%rlhaero=15.0_real64
    work%rlhaeros=10.0_real64
    work%rvlamsk(1:20)=initial_rvlamsk
    work%rvlamsk(0)=work%rvlamsk(8)
    work%rvlamsks(1:20)=initial_rvlamsks
    work%rvlamsks(0)=work%rvlamsks(8)
    work%rvtrsr(1:20)=initial_rvtrsr
    work%rvtrsr(0)=work%rvtrsr(8)
    call srfrootfr(4_int32,20_int32,ydsoil%rdaw,work%rvrootsa(:,1:20))
    work%rvrootsa(:,0)=work%rvrootsa(:,8)
    work%rcepsw=0.001_real64
    work%rvrsmin(1:20)=initial_rvrsmin
    work%rvrsmin(0)=work%rvrsmin(8)
    work%rvhstr(1:20)=initial_rvhstr
    work%rvhstr(0)=work%rvhstr(8)
    value=ydcst%retv+1.0_real64
    humidity_scale=1013.25_real64*value
    do vegetation=0,20
      work%rvhstr(vegetation)=humidity_scale*work%rvhstr(vegetation)
    end do
    work%rvz0m(1:20)=initial_rvz0m
    work%rvz0m(0)=work%rvz0m(8)
    do vegetation=1,20
      value=work%rvz0m(vegetation)
      if (heat_divisor(vegetation)==1) then
        value=value/100.0_real64
      else if (heat_divisor(vegetation)==2) then
        value=value/10.0_real64
      end if
      work%rvz0h(vegetation)=value
    end do
    work%rvz0h(0)=work%rvz0h(8)
    work%rcvc=240.0_real64
    work%rvlt=4.0_real64
    work%rvrad=0.5_real64
    work%repsr=1.0e-10_real64
    ydveg=work
  end subroutine susveg
  !> Allocate one vegetation vector or check its source bounds.
  subroutine ensure_vector(array)
    real(real64), allocatable, intent(inout) :: array(:)
    integer :: status
    if (allocated(array)) then
      if (lbound(array,1)/=0 .or. ubound(array,1)/=20) call reject_contract()
    else
      allocate(array(0:20),stat=status)
      if (status/=0) call reject_contract()
    end if
  end subroutine ensure_vector
  !> Check a dimensionless input interval before any output change.
  elemental pure logical function in_range(value,low,high)
    real(real64), intent(in) :: value,low,high
    integer(int64) :: bits
    bits=transfer(value,0_int64)
    if (iand(shiftr(bits,52),2047_int64)==2047_int64) then
      in_range=.false.
    else
      in_range=value>=low .and. value<=high
    end if
  end function in_range
end module susveg_mod

module suvexc_mod
  use iso_fortran_env, only: int32,int64,real64
  use yos_exc, only: texc
  implicit none
  private
  public :: suvexc
  interface
    subroutine reject_contract() bind(c,name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Set the native ocean and surface exchange parameters.
  !!
  !! The nine logical controls select the supplied ocean, wave and roughness
  !! options. PEXTZ0M and PEXTZ0H are roughness lengths in metres; their bits
  !! pass through unchanged. PRPLRG is the dimensionless gravity scale and is
  !! one half, one or two. YDEXC is changed only after the private calculation.
  subroutine suvexc(ld_leocwa,ld_leocco,ld_leocsa,ld_leocla,ld_lwcou,ld_lwcou2w,ld_lwcouhmf, &
      ld_lscmec,ld_lrough,pextz0m,pextz0h,prplrg,ydexc)
    logical(int32), intent(in) :: ld_leocwa,ld_leocco,ld_leocsa,ld_leocla,ld_lwcou,ld_lwcou2w,ld_lwcouhmf,ld_lscmec,ld_lrough
    real(real64), intent(in) :: pextz0m,pextz0h,prplrg
    type(texc), intent(inout) :: ydexc
    type(texc) :: work
    real(real64), volatile :: decimal_tenth
    real(real64) :: viscosity
    integer(int64) :: scale_bits
    scale_bits=transfer(prplrg,0_int64)
    if (scale_bits/=int(z'3fe0000000000000',int64) .and. scale_bits/=int(z'3ff0000000000000',int64) .and. &
        scale_bits/=int(z'4000000000000000',int64)) call reject_contract()
    work=ydexc
    work%rkap=0.4_real64
    work%rz0ice=0.001_real64/prplrg
    work%rchar=0.0155_real64
    decimal_tenth=0.1_real64
    work%repdu2=decimal_tenth*decimal_tenth
    work%repust=0.0001_real64
    viscosity=1.5e-5_real64/prplrg
    work%rnu=viscosity
    work%rnum=0.11_real64*viscosity
    work%rnuh=0.40_real64*viscosity
    work%rnuq=0.62_real64*viscosity
    work%rparzi=1000.0_real64/prplrg
    work%lelwdd=.true.
    work%lelwtl=.true.
    work%leocwa=ld_leocwa
    work%leocco=ld_leocco
    work%leocsa=ld_leocsa
    work%leocla=ld_leocla
    work%lwcou=ld_lwcou
    work%lwcou2w=ld_lwcou2w
    work%lwcouhmf=ld_lwcouhmf
    work%lscmec=ld_lscmec
    work%lrough=ld_lrough
    work%rextz0m=pextz0m
    work%rextz0h=pextz0h
    ydexc=work
  end subroutine suvexc
end module suvexc_mod
