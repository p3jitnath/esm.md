module owned_ecmwf_thermal_state_port
  !! Own and publish named atmospheric thermal and stability parameters.
  !! This module copies values. It performs no thermodynamic calculation.
  !! The producer supplies complete native records after its owned thermal,
  !! stability and convection setup stages. It must report completion truthfully.
  !! Temperatures use kelvin, density uses kg m^-3, pressure coefficients use
  !! pascals, and stability tables are dimensionless. Other coefficient units
  !! and equations remain those of their named thermal parameter producers.
  use, intrinsic :: iso_c_binding, only: c_double,c_int,c_bool
  use owned_physical_constant_state_port, only: owned_physical_constants_ready
  implicit none
  private
  public :: thermal_parameter_record,stability_parameter_record
  public :: ecmwf_thermal_state_record,publish_owned_ecmwf_thermal_state
  public :: owned_ecmwf_thermal_state_ready
  integer, parameter :: stability_table_size=101
  type, bind(c) :: thermal_parameter_record
    real(c_double) :: r2es
    real(c_double) :: r3les
    real(c_double) :: r3ies
    real(c_double) :: r4les
    real(c_double) :: r4ies
    real(c_double) :: r5les
    real(c_double) :: r5ies
    real(c_double) :: rvtmp2
    real(c_double) :: rhoh2o
    real(c_double) :: r5alvcp
    real(c_double) :: r5alscp
    real(c_double) :: ralvdcp
    real(c_double) :: ralsdcp
    real(c_double) :: ralfdcp
    real(c_double) :: rtwat
    real(c_double) :: rtber
    real(c_double) :: rtbercu
    real(c_double) :: rtice
    real(c_double) :: rticecu
    real(c_double) :: rtwat_rtice_r
    real(c_double) :: rtwat_rticecu_r
    real(c_double) :: rkoop1
    real(c_double) :: rkoop2
  end type
  type, bind(c) :: stability_parameter_record
    real(c_double) :: ritbl(stability_table_size)
    real(c_double) :: aritbl(stability_table_size)
    real(c_double) :: rchba
    real(c_double) :: rchbb
    real(c_double) :: rchbc
    real(c_double) :: rchbd
    real(c_double) :: rchb23a
    real(c_double) :: rchbbcd
    real(c_double) :: rchbcd
    real(c_double) :: rcheta
    real(c_double) :: rchetb
    real(c_double) :: rchbhdl
    real(c_double) :: rcdhalf
    real(c_double) :: rcdhpi2
    real(c_double) :: rimax
    real(c_double) :: dritbl
    real(c_double) :: dri26
  end type
  type, bind(c) :: ecmwf_thermal_state_record
    type(thermal_parameter_record) :: thermal
    type(stability_parameter_record) :: stability
  end type
  type(ecmwf_thermal_state_record), public, protected, save, &
    bind(c,name="md2asm_owned_ecmwf_thermal_namespace") :: ecmwf_thermal_state
  type(ecmwf_thermal_state_record), public, protected, save, &
    bind(c,name="md2asm_owned_thermal_stability_namespace") :: thermal_stability_state
  ! Public C names are owned compatibility copies, with compiler-defined
  ! types and alignment. No private alias address identity is claimed.
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r2es") :: r2es=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r3les") :: r3les=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r3ies") :: r3ies=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r4les") :: r4les=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r4ies") :: r4ies=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r5les") :: r5les=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r5ies") :: r5ies=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rvtmp2") :: rvtmp2=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rhoh2o") :: rhoh2o=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r5alvcp") :: r5alvcp=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_r5alscp") :: r5alscp=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_ralvdcp") :: ralvdcp=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_ralsdcp") :: ralsdcp=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_ralfdcp") :: ralfdcp=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rtwat") :: rtwat=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rtber") :: rtber=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rtbercu") :: rtbercu=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rtice") :: rtice=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rticecu") :: rticecu=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rtwat_rtice_r") :: rtwat_rtice_r=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rtwat_rticecu_r") :: rtwat_rticecu_r=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rkoop1") :: rkoop1=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoethf_MOD_rkoop2") :: rkoop2=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_ritbl") :: ritbl(stability_table_size)=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_aritbl") :: aritbl(stability_table_size)=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchba") :: rchba=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchbb") :: rchbb=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchbc") :: rchbc=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchbd") :: rchbd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchb23a") :: rchb23a=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchbbcd") :: rchbbcd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchbcd") :: rchbcd=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rcheta") :: rcheta=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchetb") :: rchetb=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rchbhdl") :: rchbhdl=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rcdhalf") :: rcdhalf=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rcdhpi2") :: rcdhpi2=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_rimax") :: rimax=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_dritbl") :: dritbl=0.0_c_double
  real(c_double), public, protected, save, &
    bind(c,name="__yoevdfs_MOD_dri26") :: dri26=0.0_c_double
  logical, save :: published=.false.
contains
  function publish_owned_ecmwf_thermal_state(thermal,stability,producers_complete) &
      bind(c,name="md2asm_publish_owned_ecmwf_thermal_state_fortran") result(status)
    !! Publish complete immutable parameters once from the serial setup owner.
    !!
    !! THERMAL and STABILITY are complete read-only native records. The two
    !! fixed stability arrays each contain 101 entries in producer order.
    !! They must not overlap the exported writable storage on first entry.
    !! PRODUCERS_COMPLETE is a one-byte C boolean supplied only after every
    !! owned producer has finished, including thermal section 0.2, its final
    !! convection values and the complete stability-table calculation.
    !! Owned physical-constant publication must also already be complete.
    !! Return 2 before a copy when either admission condition is false.
    !! Return 0 after publication. A repeat call returns 0 without reading
    !! input records, changing storage or repeating any producer calculation.
    type(thermal_parameter_record), intent(in) :: thermal
    type(stability_parameter_record), intent(in) :: stability
    logical(c_bool), intent(in) :: producers_complete
    integer(c_int) :: status
    if (published) then
      status=0_c_int
      return
    end if
    status=2_c_int
    if (.not.producers_complete) return
    if (.not.owned_physical_constants_ready()) return
    ecmwf_thermal_state%thermal=thermal
    ecmwf_thermal_state%stability=stability
    thermal_stability_state=ecmwf_thermal_state
    r2es=thermal%r2es
    r3les=thermal%r3les
    r3ies=thermal%r3ies
    r4les=thermal%r4les
    r4ies=thermal%r4ies
    r5les=thermal%r5les
    r5ies=thermal%r5ies
    rvtmp2=thermal%rvtmp2
    rhoh2o=thermal%rhoh2o
    r5alvcp=thermal%r5alvcp
    r5alscp=thermal%r5alscp
    ralvdcp=thermal%ralvdcp
    ralsdcp=thermal%ralsdcp
    ralfdcp=thermal%ralfdcp
    rtwat=thermal%rtwat
    rtber=thermal%rtber
    rtbercu=thermal%rtbercu
    rtice=thermal%rtice
    rticecu=thermal%rticecu
    rtwat_rtice_r=thermal%rtwat_rtice_r
    rtwat_rticecu_r=thermal%rtwat_rticecu_r
    rkoop1=thermal%rkoop1
    rkoop2=thermal%rkoop2
    ritbl=stability%ritbl
    aritbl=stability%aritbl
    rchba=stability%rchba
    rchbb=stability%rchbb
    rchbc=stability%rchbc
    rchbd=stability%rchbd
    rchb23a=stability%rchb23a
    rchbbcd=stability%rchbbcd
    rchbcd=stability%rchbcd
    rcheta=stability%rcheta
    rchetb=stability%rchetb
    rchbhdl=stability%rchbhdl
    rcdhalf=stability%rcdhalf
    rcdhpi2=stability%rcdhpi2
    rimax=stability%rimax
    dritbl=stability%dritbl
    dri26=stability%dri26
    published=.true.
    status=0_c_int
  end function

  pure function owned_ecmwf_thermal_state_ready() result(ready)
    !! Report whether the serial owner completed all publication stores.
    logical :: ready
    ready=published
  end function
end module owned_ecmwf_thermal_state_port
