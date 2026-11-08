!> Set the VAL923 reference values for interpreting land data.
module land_surface_reference_setup_port
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_int32_t
  implicit none
  private
  public :: land_surface_reference_record
  public :: initialize_land_surface_reference_parameters, set_land_surface_reference_parameters_raw
  !> Caller-owned original-name land reference scalars, with no heap owner.
  !! Roughness lengths and depths are in metres; clay and sand are percent.
  !! Surface resistance is in s/m. Albedo, emissivity and masks are
  !! dimensionless. Integer fields hold the original land classification.
  !! The compiler owns this C-interoperable record and its alignment.
  type, bind(C) :: land_surface_reference_record
    real(c_double) :: smask
    real(c_double) :: smanq
    integer(c_int32_t) :: ntpmer
    integer(c_int32_t) :: ntpgla
    integer(c_int32_t) :: ntpdes
    integer(c_int32_t) :: ntplac
    real(c_double) :: szz0n
    real(c_double) :: szz0m
    real(c_double) :: szz0b
    real(c_double) :: szz0u
    real(c_double) :: szz0d
    real(c_double) :: sther
    real(c_double) :: salbn
    real(c_double) :: salbx
    real(c_double) :: salbm
    real(c_double) :: salbg
    real(c_double) :: salbb
    real(c_double) :: salbd
    real(c_double) :: semin
    real(c_double) :: semix
    real(c_double) :: semim
    real(c_double) :: semig
    real(c_double) :: semib
    real(c_double) :: semid
    real(c_double) :: sdepn
    real(c_double) :: sdepx
    real(c_double) :: sdepd
    real(c_double) :: sargn
    real(c_double) :: sargx
    real(c_double) :: sargd
    real(c_double) :: ssabn
    real(c_double) :: ssabx
    real(c_double) :: ssabd
    real(c_double) :: srsmx
    real(c_double) :: srsmn
    real(c_double) :: srsmd
  end type land_surface_reference_record
contains
  !> Apply all VAL923 constants, using the source old/new data switch.
  !! OUTPUT is the caller-owned INOUT record. NEW_DATA is readonly logical
  !! input, normally the original TPHY%LSOLV. Return 0 on success or 2
  !! before mutation for a noncanonical logical representation.
  !! This entry has no arithmetic or floating-mode requirement.
  integer(int32) function initialize_land_surface_reference_parameters(output, new_data) result(status)
    type(land_surface_reference_record), intent(inout) :: output
    logical, intent(in) :: new_data
    integer(int32) :: word
    status = 2_int32
    word = transfer(new_data, 0_int32)
    if (word /= 0_int32 .and. word /= 1_int32) return
    call set_land_surface_reference_parameters_raw(output, new_data)
    status = 0_int32
  end function initialize_land_surface_reference_parameters

  !> Store the source literal bits and the two selected albedo overrides.
  !! OUTPUT is INOUT; NEW_DATA is IN with the admitted native logical value.
  !! All 36 fields are written and no allocation or numerical stage is used.
  subroutine set_land_surface_reference_parameters_raw(output, new_data)
    type(land_surface_reference_record), intent(inout) :: output
    logical, intent(in) :: new_data
    output%smask = transfer(int(z'3FE0000000000000', int64), 0.0_real64)
    output%smanq = transfer(int(z'C0C3870000000000', int64), 0.0_real64)
    output%ntpmer = int(z'00000001', int32)
    output%ntpgla = int(z'00000002', int32)
    output%ntpdes = int(z'00000003', int32)
    output%ntplac = int(z'00000005', int32)
    output%szz0n = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%szz0m = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%szz0b = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%szz0u = transfer(int(z'4004000000000000', int64), 0.0_real64)
    output%szz0d = transfer(int(z'3F50624DD2F1A9FC', int64), 0.0_real64)
    output%sther = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%salbn = transfer(int(z'3FB1EB851EB851EC', int64), 0.0_real64)
    output%salbx = transfer(int(z'3FE6666666666666', int64), 0.0_real64)
    output%salbm = transfer(int(z'3FB1EB851EB851EC', int64), 0.0_real64)
    output%salbg = transfer(int(z'3FE8000000000000', int64), 0.0_real64)
    output%salbb = transfer(int(z'3FE4CCCCCCCCCCCD', int64), 0.0_real64)
    output%salbd = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%semin = transfer(int(z'3FECCCCCCCCCCCCD', int64), 0.0_real64)
    output%semix = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%semim = transfer(int(z'3FEEB851EB851EB8', int64), 0.0_real64)
    output%semig = transfer(int(z'3FEF5C28F5C28F5C', int64), 0.0_real64)
    output%semib = transfer(int(z'3FEF0A3D70A3D70A', int64), 0.0_real64)
    output%semid = transfer(int(z'3FEE2D0E56041893', int64), 0.0_real64)
    output%sdepn = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%sdepx = transfer(int(z'4020000000000000', int64), 0.0_real64)
    output%sdepd = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%sargn = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%sargx = transfer(int(z'404D000000000000', int64), 0.0_real64)
    output%sargd = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%ssabn = transfer(int(z'4018000000000000', int64), 0.0_real64)
    output%ssabx = transfer(int(z'4057000000000000', int64), 0.0_real64)
    output%ssabd = transfer(int(z'4057000000000000', int64), 0.0_real64)
    output%srsmx = transfer(int(z'40B3880000000000', int64), 0.0_real64)
    output%srsmn = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%srsmd = transfer(int(z'40B3880000000000', int64), 0.0_real64)
    if (new_data) then
      output%salbn = transfer(int(z'3FA999999999999A', int64), 0.0_real64)
      output%salbx = transfer(int(z'3FE999999999999A', int64), 0.0_real64)
    end if
  end subroutine set_land_surface_reference_parameters_raw
end module land_surface_reference_setup_port
