!> Native selected SUCUMF2 linearized-convection parameter fields.
!! Convection carries heat and moisture through rising and sinking air.
!! OUTPUT owns its native TECUMF2 fields; SWITCHES owns three logical fields.
!! PRESSURE has L full-level values in Pa, where the caller admits 4<=L<=512.
!! Gravity RG is in m/s^2. RPLRG and RPLRADI are dimensionless scale factors.
!! TIMESTEP is in seconds and retains the full upstream input interface.
!! The selected empty-namelist path disables the short-step limiter, so this
!! procedure does not read TIMESTEP. It performs no namelist or diagnostic I/O.
!! The caller validates finite inputs, separate owners and nearest rounding
!! with gradual underflow. RTAU02, padding and unselected indices stay unchanged.
module convection_linearized_parameter_fields_mod
  use iso_fortran_env, only: real64,int32,int64
  use yoecumf2, only: tecumf2
  use yomcumfs, only: tcumfs
  implicit none
  private
  public :: initialize_linearized_convection_fields
contains
  !> Set the selected rates, switches and strict pressure thresholds.
  !! OUTPUT and SWITCHES are modified in place. All scalar and array inputs
  !! are readonly. The complete pressure shape supplies the live level count.
  subroutine initialize_linearized_convection_fields(output,switches,pressure,rg,rplrg,rplradi,timestep)
    type(tecumf2), intent(inout) :: output
    type(tcumfs), intent(inout) :: switches
    real(real64), intent(in) :: pressure(:),rg,rplrg,rplradi,timestep
    integer(int32) :: levels,level
    levels=size(pressure,kind=int32)
    ! Literal source values include its folded constant melting time.
    output%entstpc12=transfer(int(z'3fe999999999999a',int64),0.0_real64)
    output%entstpc22=transfer(int(z'3f2a36e2eb1c432d',int64),0.0_real64)
    output%entstpc32=transfer(int(z'4008000000000000',int64),0.0_real64)
    output%entshalp2=transfer(int(z'4000000000000000',int64),0.0_real64)
    output%rmfcmin2=transfer(int(z'3e45798ee2308c3a',int64),0.0_real64)
    output%rmfdeps2=transfer(int(z'3fd3333333333333',int64),0.0_real64)
    output%rdepths2=transfer(int(z'40d3880000000000',int64),0.0_real64)
    output%rcucov2=transfer(int(z'3fa999999999999a',int64),0.0_real64)
    output%rtaumel2=transfer(int(z'40c7340000000000',int64),0.0_real64)
    output%lmfmid2=.true.
    output%lmfdd2=.true.
    output%lmfdudv2=.true.
    output%lmfuvdis2=.false.
    output%lmfwetb2=.true.
    output%lmfglac2=.true.
    output%ruvper2=transfer(int(z'3fd3333333333333',int64),0.0_real64)
    output%rmfsoluv2=transfer(int(z'3ff0000000000000',int64),0.0_real64)
    output%rmfsoltq2=transfer(int(z'3ff0000000000000',int64),0.0_real64)
    output%rmfsolct2=transfer(int(z'3ff0000000000000',int64),0.0_real64)
    output%rmfsolrhs2=transfer(int(z'0000000000000000',int64),0.0_real64)
    output%rcapdcycl2=transfer(int(z'4000000000000000',int64),0.0_real64)
    output%rmflia2=transfer(int(z'4000000000000000',int64),0.0_real64)
    output%rmfcfl2=transfer(int(z'3ff0000000000000',int64),0.0_real64)
    ! Preserve the six ordered source operations on live upstream values.
    output%detrpen2=0.75e-4_real64*rplrg
    output%entrorg2=1.75e-3_real64*rplrg
    output%entrdd2=3.0e-4_real64*rplrg
    output%rprcon2=1.4e-3_real64*rplrg
    output%rcpecons2=5.44e-4_real64/rg
    output%rtau2=0.33_real64*rplradi
    output%njkt12=2_int32
    output%njkt22=2_int32
    output%njkt32=levels-2_int32
    ! Descending scans leave the smallest eligible level after strict ties.
    do level=levels,2,-1
      if (pressure(level)>35000.0_real64) output%njkt12=level
      if (pressure(level)>6000.0_real64) output%njkt22=level
      if (pressure(level)>95000.0_real64) output%njkt32=level
      if (pressure(level)>50000.0_real64) output%njkt52=level
      if (pressure(level)>70000.0_real64) output%njkt62=level
    end do
    output%njkt32=min(output%njkt32,levels-2_int32)
    switches%lecumfs=.false.
    switches%lregcv=.false.
    switches%lmfcfl2_shstep=.false.
  end subroutine initialize_linearized_convection_fields
end module convection_linearized_parameter_fields_mod
