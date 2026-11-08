!> Transactional portable shortwave column controller.
module md2asm_shortwave_column_team
  use iso_fortran_env, only: int32, real64
  use radiation_config, only: config_type
  use radiation_single_level, only: single_level_type
  use radiation_cloud, only: cloud_type
  use radiation_flux, only: flux_type
  use md2asm_shortwave_cloud_solver, only: solver_mcica_sw
  implicit none
  private
  integer, parameter :: jprb = real64
  public :: solver_mcica_sw_team
contains
!> Clone every mutable shortwave owner before the complete selected update.
!! Requested workers1or8 use the deterministic one-worker fallback. All actual
!! numerical stages are owned by the linked native solver and its children.
!! Complete outputs commit only after success. Inactive cells and unrelated
!! flux fields retain their entry bytes and allocation identities. Failed
!! private allocation returns1 with caller-owned fields unchanged.
subroutine solver_mcica_sw_team(nlev,istartcol,iendcol,config,single_level,cloud,od,ssa,g,od_cloud,ssa_cloud,g_cloud,albedo_direct,albedo_diffuse,incoming_sw,flux,status,requested_workers)
    ! Inputs
    integer, intent(in) :: nlev               ! number of model levels
    integer, intent(in) :: istartcol, iendcol ! range of columns to process
    type(config_type), intent(in), target :: config
    type(single_level_type), intent(in) :: single_level
    type(cloud_type), intent(in) :: cloud

    ! Gas and aerosol optical depth, single-scattering albedo and
    ! asymmetry factor at each shortwave g-point
    real(jprb), intent(in), dimension(config%n_g_sw, nlev, istartcol:iendcol) :: &
         &  od, ssa, g

    ! Cloud and precipitation optical depth, single-scattering albedo and
    ! asymmetry factor in each shortwave band
    real(jprb), intent(in), dimension(config%n_bands_sw, nlev, istartcol:iendcol) :: &
         &  od_cloud, ssa_cloud, g_cloud

    ! Direct and diffuse surface albedos, and the incoming shortwave
    ! flux into a plane perpendicular to the incoming radiation at
    ! top-of-atmosphere in each of the shortwave g points
    real(jprb), intent(in), dimension(config%n_g_sw, istartcol:iendcol) :: &
         &  albedo_direct, albedo_diffuse, incoming_sw

    ! Output
    type(flux_type), intent(inout) :: flux
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: requested_workers

    type(flux_type) :: working
    integer :: allocation_status, workers
    status = 2
    workers = 1; if (present(requested_workers)) workers = requested_workers
    if (workers /= 1 .and. workers /= 8) return
    if (nlev < 1 .or. nlev > 512 .or. config%n_g_sw < 1 .or. config%n_g_sw > 4096) return
    if (istartcol < 1 .or. iendcol < istartcol - 1) return
    if (config%i_overlap_scheme /= 1 .or. .not. config%do_clear) return
    if (.not. allocated(flux%sw_up)) return
    if (.not. allocated(flux%sw_dn)) return
    if (.not. allocated(flux%sw_up_clear)) return
    if (.not. allocated(flux%sw_dn_clear)) return
    if (.not. allocated(flux%sw_dn_diffuse_surf_g)) return
    if (.not. allocated(flux%sw_dn_direct_surf_g)) return
    if (.not. allocated(flux%sw_dn_diffuse_surf_clear_g)) return
    if (.not. allocated(flux%sw_dn_direct_surf_clear_g)) return
    if (.not. allocated(flux%cloud_cover_sw)) return
    if (allocated(flux%sw_dn_direct) .and. .not. allocated(flux%sw_dn_direct_clear)) return
    allocate (working%sw_up, source=flux%sw_up, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_dn, source=flux%sw_dn, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_up_clear, source=flux%sw_up_clear, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_dn_clear, source=flux%sw_dn_clear, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_dn_diffuse_surf_g, source=flux%sw_dn_diffuse_surf_g, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_dn_direct_surf_g, source=flux%sw_dn_direct_surf_g, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_dn_diffuse_surf_clear_g, source=flux%sw_dn_diffuse_surf_clear_g, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%sw_dn_direct_surf_clear_g, source=flux%sw_dn_direct_surf_clear_g, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    allocate (working%cloud_cover_sw, source=flux%cloud_cover_sw, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    if (allocated(flux%sw_dn_direct)) then
      allocate (working%sw_dn_direct, source=flux%sw_dn_direct, stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1; return
      end if
    end if
    if (allocated(flux%sw_dn_direct_clear)) then
      allocate (working%sw_dn_direct_clear, source=flux%sw_dn_direct_clear, stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1; return
      end if
    end if
 call solver_mcica_sw(nlev,istartcol,iendcol,config,single_level,cloud,od,ssa,g,od_cloud,ssa_cloud,g_cloud,albedo_direct,albedo_diffuse,incoming_sw,working,status)
    if (status /= 0) return
    flux%sw_up = working%sw_up
    flux%sw_dn = working%sw_dn
    flux%sw_up_clear = working%sw_up_clear
    flux%sw_dn_clear = working%sw_dn_clear
    flux%sw_dn_diffuse_surf_g = working%sw_dn_diffuse_surf_g
    flux%sw_dn_direct_surf_g = working%sw_dn_direct_surf_g
    flux%sw_dn_diffuse_surf_clear_g = working%sw_dn_diffuse_surf_clear_g
    flux%sw_dn_direct_surf_clear_g = working%sw_dn_direct_surf_clear_g
    flux%cloud_cover_sw = working%cloud_cover_sw
    if (allocated(flux%sw_dn_direct)) flux%sw_dn_direct = working%sw_dn_direct
    if (allocated(flux%sw_dn_direct_clear)) flux%sw_dn_direct_clear = working%sw_dn_direct_clear
    status = 0
  end subroutine
end module
