!> Serial unsplit INV_TRANS_CTL and DIR_TRANS_CTL source decisions.
module md2asm_transform_controllers
  use iso_fortran_env, only: int32
  use md2asm_model_transform_views, only: transform_call_controls, transform_field_views
  use md2asm_external_transform_services, only: inverse_transform_service, direct_transform_service
  implicit none
  private
  public::inverse_transform_controller,direct_transform_controller,submit_inverse_transform_request,submit_direct_transform_request
contains
!> Preserve the complete inverse request and its absent optional owners.
!! The public ECTRANS service performs its Legendre stage before its Fourier stage.
  subroutine inverse_transform_controller(c, v, status)
    type(transform_call_controls), intent(in) :: c
    type(transform_field_views), intent(inout) :: v
    integer(int32), intent(out) :: status
    status = 2
    if (c%processes /= 1 .or. c%split_fields > 0) return
    call submit_inverse_transform_request(c, v, status)
  end subroutine
!> Forward one complete native inverse request to its public service.
  subroutine submit_inverse_transform_request(c, v, status)
    type(transform_call_controls), intent(in) :: c
    type(transform_field_views), intent(inout) :: v
    integer(int32), intent(out) :: status
    call inverse_transform_service(PSPVOR=v%vorticity, PSPDIV=v%divergence, PSPSCALAR=v%scalar, &
                                   PSPSC3A=v%scalar3a, PSPSC3B=v%scalar3b, PSPSC2=v%scalar2, LDSCDERS=c%scalar_derivatives, &
                                   LDVORGP=c%grid_vorticity, LDDIVGP=c%grid_divergence, LDUVDER=c%wind_derivatives, &
                                   LDLATLON=c%latitude_longitude, KPROMA=c%block_rows, KVSETUV=v%set_wind, KVSETSC=v%set_scalar, &
                                  KRESOL=c%resolution, KVSETSC3A=v%set_scalar3a, KVSETSC3B=v%set_scalar3b, KVSETSC2=v%set_scalar2, &
                                   PGP=v%grid, PGPUV=v%grid_wind, PGP3A=v%grid3a, PGP3B=v%grid3b, PGP2=v%grid2, status=status)
  end subroutine
!> Preserve the complete direct request and its absent optional owners.
!! The public ECTRANS service performs its Fourier stage before its Legendre stage.
  subroutine direct_transform_controller(c, v, status)
    type(transform_call_controls), intent(in) :: c
    type(transform_field_views), intent(inout) :: v
    integer(int32), intent(out) :: status
    status = 2
    if (c%processes /= 1 .or. c%split_fields > 0) return
    call submit_direct_transform_request(c, v, status)
  end subroutine
!> Forward one complete native direct request to its public service.
  subroutine submit_direct_transform_request(c, v, status)
    type(transform_call_controls), intent(in) :: c
    type(transform_field_views), intent(inout) :: v
    integer(int32), intent(out) :: status
    call direct_transform_service(PSPVOR=v%vorticity, PSPDIV=v%divergence, PSPSCALAR=v%scalar, &
                                  PSPSC3A=v%scalar3a, PSPSC3B=v%scalar3b, PSPSC2=v%scalar2, LDLATLON=c%latitude_longitude, &
                                  KPROMA=c%block_rows, KVSETUV=v%set_wind, KVSETSC=v%set_scalar, KRESOL=c%resolution, &
                                  KVSETSC3A=v%set_scalar3a, KVSETSC3B=v%set_scalar3b, KVSETSC2=v%set_scalar2, &
                                  PGP=v%grid, PGPUV=v%grid_wind, PGP3A=v%grid3a, PGP3B=v%grid3b, PGP2=v%grid2, status=status)
  end subroutine
end module
