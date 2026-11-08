!> Release a complete native registry after every view consumer has finished.
!> The graph owns metadata and declared temporary targets. Weather arrays
!> borrowed from other model owners remain opaque throughout this procedure.
module forecast_registry_release
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_ptr, c_loc, c_associated, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_registry_field_types
  use forecast_native_field_variable_types, only: native_field_variables, native_surface_variables
  implicit none
  private
  public :: release_registry_graph
  interface release_variable
    module procedure release_variable_2d, release_variable_3d, release_variable_4d
  end interface
  interface release_payload
    module procedure release_payload_2d, release_payload_3d, release_payload_4d
  end interface
  interface
    function registry_errno_address() bind(c, name='__errno_location') result(address)
      import :: c_ptr
      type(c_ptr) :: address
    end function registry_errno_address
  end interface
contains
  !> Release both roots and nullify their caller pointers. Status 0 is success.
  !> Status 2 refuses exactly one root or mismatched shared/private bases
  !> before any mutation. All metadata targets must be live and disjoint.
  !> This entry releases complete successful constructions, not partial ones.
  integer(c_int) function release_registry_graph(variables, surface) result(status)
    type(native_field_variables), pointer, intent(inout) :: variables
    type(native_surface_variables), pointer, intent(inout) :: surface
    integer(c_int), pointer, volatile :: errno_word
    integer(c_int) :: incoming_errno
    type(ieee_status_type) :: incoming_status
    integer :: i, j
    type(native_surface_variables), pointer :: surface_owner
    type(native_field_variables), pointer :: variable_owner
    type(native_registry_variable_3d), pointer :: group_owner(:)
    type(native_registry_variable_2d), allocatable :: surface_array1(:), surface_array2(:, :)
    status = 0_c_int
    if (.not. associated(variables) .and. .not. associated(surface)) return
    status = 2_c_int
    if (.not. associated(variables) .or. .not. associated(surface)) return

    if (.not. same_group_base(variables%ghg_g, variables%ghg)) return
    if (.not. same_group_base(variables%chem_g, variables%chem)) return
    if (.not. same_group_base(variables%aero_g, variables%aero)) return
    if (.not. same_group_base(variables%forc_g, variables%forc)) return
    if (.not. same_group_base(variables%ezdiag_g, variables%ezdiag)) return
    if (.not. same_group_base(variables%era40_g, variables%era40)) return
    if (.not. same_group_base(variables%nogw_g, variables%nogw)) return
    if (.not. same_group_base(variables%emis3d_g, variables%emis3d)) return
    if (.not. same_group_base(variables%edrp_g, variables%edrp)) return
    if (.not. same_group_base(variables%sldia_g, variables%sldia)) return
    if (.not. same_group_base(variables%aeraot_g, variables%aeraot)) return
    if (.not. same_group_base(variables%aerlisi_g, variables%aerlisi)) return
    if (.not. same_group_base(variables%aerout_g, variables%aerout)) return
    if (.not. same_group_base(variables%aeroclim_g, variables%aeroclim)) return
    if (.not. same_group_base(variables%uvp_g, variables%uvp)) return
    if (.not. same_group_base(variables%phys_g, variables%phys)) return
    if (.not. same_group_base(variables%lima_g, variables%lima)) return
    if (.not. same_group_base(variables%ext_g, variables%ext)) return
    call c_f_pointer(registry_errno_address(), errno_word)
    incoming_errno = errno_word
    call ieee_get_status(incoming_status)
    ! Surface declarations follow their original table order.

    call release_variable(surface%gsp_sb%vt)
    call release_variable(surface%gsp_sb%vq)
    call release_variable(surface%gsp_sb%vtl)
    call release_variable(surface%gsp_sg%vf)
    call release_variable(surface%gsp_sg%va)
    call release_variable(surface%gsp_sg%vr)
    call release_variable(surface%gsp_sg%vt)
    call release_variable(surface%gsp_sg%vw)
    call release_variable(surface%gsp_sl%vlict)
    call release_variable(surface%gsp_sl%vlmlt)
    call release_variable(surface%gsp_sl%vltlt)
    call release_variable(surface%gsp_sl%vlblt)
    call release_variable(surface%gsp_sl%vlshf)
    call release_variable(surface%gsp_sl%vlicd)
    call release_variable(surface%gsp_sl%vlmld)
    call release_variable(surface%gsp_rr%vt)
    call release_variable(surface%gsp_rr%vw)
    call release_variable(surface%gsp_rr%vfc)
    call release_variable(surface%gsp_rr%vic)
    call release_variable(surface%gsp_rr%vfp1)
    call release_variable(surface%gsp_cl%vtcls)
    call release_variable(surface%gsp_cl%vhucls)
    call release_variable(surface%gsp_cl%vucls)
    call release_variable(surface%gsp_cl%vvcls)
    call release_variable(surface%gsp_cl%vnucls)
    call release_variable(surface%gsp_cl%vnvcls)
    call release_variable(surface%gsp_om%vto)
    call release_variable(surface%gsp_om%vso)
    call release_variable(surface%gsp_om%vuo)
    call release_variable(surface%gsp_om%vvo)
    call release_variable(surface%gsd_vf%vz0f)
    call release_variable(surface%gsd_vf%valbf)
    call release_variable(surface%gsd_vf%vemisf)
    call release_variable(surface%gsd_vf%vgetrl)
    call release_variable(surface%gsd_vf%vlsm)
    call release_variable(surface%gsd_vf%vveg)
    call release_variable(surface%gsd_vf%vvrlan)
    call release_variable(surface%gsd_vf%vvrldi)
    call release_variable(surface%gsd_vf%vsig)
    call release_variable(surface%gsd_vf%valbsf)
    call release_variable(surface%gsd_vf%vlan)
    call release_variable(surface%gsd_vf%vsst)
    call release_variable(surface%gsd_vf%vsss)
    call release_variable(surface%gsd_vf%vlz0h)
    call release_variable(surface%gsd_vf%vcvl)
    call release_variable(surface%gsd_vf%vco2typ)
    call release_variable(surface%gsd_vf%vcvh)
    call release_variable(surface%gsd_vf%vcur)
    call release_variable(surface%gsd_vf%vtvl)
    call release_variable(surface%gsd_vf%vtvh)
    call release_variable(surface%gsd_vf%vlail)
    call release_variable(surface%gsd_vf%vlaih)
    call release_variable(surface%gsd_vf%vfwet)
    call release_variable(surface%gsd_vf%vsoty)
    call release_variable(surface%gsd_vf%vclk)
    call release_variable(surface%gsd_vf%vdl)
    call release_variable(surface%gsd_vf%vci)
    call release_variable(surface%gsd_vf%vucur)
    call release_variable(surface%gsd_vf%vvcur)
    call release_variable(surface%gsd_vf%vz0rlf)
    call release_variable(surface%gsd_vf%vcgpp)
    call release_variable(surface%gsd_vf%vcrec)
    call release_variable(surface%gsd_vf%vsdfor)
    call release_variable(surface%gsd_vf%valuvp)
    call release_variable(surface%gsd_vf%valuvd)
    call release_variable(surface%gsd_vf%valnip)
    call release_variable(surface%gsd_vf%valnid)
    call release_variable(surface%gsd_vf%vfp1)
    call release_variable(surface%gsd_vf%vso2dd)
    call release_variable(surface%gsd_vf%vdmso)
    call release_variable(surface%gsd_vf%vurbf)
    call release_variable(surface%gsd_vf%vfca1)
    call release_variable(surface%gsd_vf%vfca2)
    call release_variable(surface%gsd_vf%vaerdep)
    call release_variable(surface%gsd_vf%vaerlts)
    call release_variable(surface%gsd_vf%vaerscc)
    call release_variable(surface%gsd_vf%vdsf)
    if (allocated(surface%gsd_vf%vchemflxo)) then
      do i = lbound(surface%gsd_vf%vchemflxo, 1), ubound(surface%gsd_vf%vchemflxo, 1)
        call release_variable(surface%gsd_vf%vchemflxo(i))
      end do
      call move_alloc(surface%gsd_vf%vchemflxo, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vf%vchemwdflx)) then
      do i = lbound(surface%gsd_vf%vchemwdflx, 1), ubound(surface%gsd_vf%vchemwdflx, 1)
        call release_variable(surface%gsd_vf%vchemwdflx(i))
      end do
      call move_alloc(surface%gsd_vf%vchemwdflx, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vf%vchemddflx)) then
      do i = lbound(surface%gsd_vf%vchemddflx, 1), ubound(surface%gsd_vf%vchemddflx, 1)
        call release_variable(surface%gsd_vf%vchemddflx(i))
      end do
      call move_alloc(surface%gsd_vf%vchemddflx, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vf%vchemdv)) then
      do i = lbound(surface%gsd_vf%vchemdv, 1), ubound(surface%gsd_vf%vchemdv, 1)
        call release_variable(surface%gsd_vf%vchemdv(i))
      end do
      call move_alloc(surface%gsd_vf%vchemdv, surface_array1)
      deallocate (surface_array1)
    end if
    call release_variable(surface%gsd_vf%vnudm)
    if (allocated(surface%gsd_vf%vemis2d)) then
      do i = lbound(surface%gsd_vf%vemis2d, 1), ubound(surface%gsd_vf%vemis2d, 1)
        call release_variable(surface%gsd_vf%vemis2d(i))
      end do
      call move_alloc(surface%gsd_vf%vemis2d, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vf%vemis2daux)) then
      do i = lbound(surface%gsd_vf%vemis2daux, 1), ubound(surface%gsd_vf%vemis2daux, 1)
        call release_variable(surface%gsd_vf%vemis2daux(i))
      end do
      call move_alloc(surface%gsd_vf%vemis2daux, surface_array1)
      deallocate (surface_array1)
    end if
    call release_variable(surface%gsd_vn%vtop)
    call release_variable(surface%gsd_vn%vbas)
    call release_variable(surface%gsd_vn%vacpr)
    call release_variable(surface%gsd_vn%vaccpr)
    call release_variable(surface%gsd_vn%vaccpr5)
    call release_variable(surface%gsd_v2%vocdep)
    call release_variable(surface%gsd_v2%vustrc)
    call release_variable(surface%gsd_v2%vvstrc)
    call release_variable(surface%gsd_v3%vdifm)
    call release_variable(surface%gsd_v3%vdift)
    call release_variable(surface%gsd_v3%vdifs)
    call release_variable(surface%gsd_v3%vadvt)
    call release_variable(surface%gsd_v3%vadvs)
    call release_variable(surface%gsd_v3%vtri0)
    call release_variable(surface%gsd_v3%vtri1)
    call release_variable(surface%gsd_v3%vswdk)
    call release_variable(surface%gsd_v3%vzo)
    call release_variable(surface%gsd_v3%vho)
    call release_variable(surface%gsd_v3%vdo)
    call release_variable(surface%gsd_v3%vho_inv)
    call release_variable(surface%gsd_v3%vuoc)
    call release_variable(surface%gsd_v3%vvoc)
    call release_variable(surface%gsd_v3%votke)
    call release_variable(surface%gsd_vd%vlsp)
    call release_variable(surface%gsd_vd%vcp)
    call release_variable(surface%gsd_vd%vsf)
    call release_variable(surface%gsd_vd%vfzra)
    call release_variable(surface%gsd_vd%vbld)
    call release_variable(surface%gsd_vd%vsshf)
    call release_variable(surface%gsd_vd%vslhf)
    call release_variable(surface%gsd_vd%vnee)
    call release_variable(surface%gsd_vd%vgpp)
    call release_variable(surface%gsd_vd%vrec)
    call release_variable(surface%gsd_vd%vmsl)
    call release_variable(surface%gsd_vd%vsp)
    call release_variable(surface%gsd_vd%vtcc)
    call release_variable(surface%gsd_vd%v10u)
    call release_variable(surface%gsd_vd%v10v)
    call release_variable(surface%gsd_vd%v2t)
    call release_variable(surface%gsd_vd%v2d)
    call release_variable(surface%gsd_vd%v2sh)
    call release_variable(surface%gsd_vd%vssr)
    call release_variable(surface%gsd_vd%vstr)
    call release_variable(surface%gsd_vd%vtsr)
    call release_variable(surface%gsd_vd%vttr)
    call release_variable(surface%gsd_vd%vewss)
    call release_variable(surface%gsd_vd%vnsss)
    call release_variable(surface%gsd_vd%ve)
    call release_variable(surface%gsd_vd%vpev)
    call release_variable(surface%gsd_vd%vccc)
    call release_variable(surface%gsd_vd%vlcc)
    call release_variable(surface%gsd_vd%vmcc)
    call release_variable(surface%gsd_vd%vhcc)
    call release_variable(surface%gsd_vd%vlgws)
    call release_variable(surface%gsd_vd%vmgws)
    call release_variable(surface%gsd_vd%vgwd)
    call release_variable(surface%gsd_vd%vmx2t)
    call release_variable(surface%gsd_vd%vmn2t)
    if (allocated(surface%gsd_vd%vmx2t6)) then
      do i = lbound(surface%gsd_vd%vmx2t6, 1), ubound(surface%gsd_vd%vmx2t6, 1)
        call release_variable(surface%gsd_vd%vmx2t6(i))
      end do
      call move_alloc(surface%gsd_vd%vmx2t6, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vmn2t6)) then
      do i = lbound(surface%gsd_vd%vmn2t6, 1), ubound(surface%gsd_vd%vmn2t6, 1)
        call release_variable(surface%gsd_vd%vmn2t6(i))
      end do
      call move_alloc(surface%gsd_vd%vmn2t6, surface_array1)
      deallocate (surface_array1)
    end if
    call release_variable(surface%gsd_vd%vro)
    call release_variable(surface%gsd_vd%vsro)
    call release_variable(surface%gsd_vd%vssro)
    call release_variable(surface%gsd_vd%valb)
    call release_variable(surface%gsd_vd%viewss)
    call release_variable(surface%gsd_vd%vinsss)
    call release_variable(surface%gsd_vd%visshf)
    call release_variable(surface%gsd_vd%vie)
    call release_variable(surface%gsd_vd%vinee)
    call release_variable(surface%gsd_vd%vigpp)
    call release_variable(surface%gsd_vd%virec)
    call release_variable(surface%gsd_vd%vich4)
    call release_variable(surface%gsd_vd%vcsf)
    call release_variable(surface%gsd_vd%vlssf)
    call release_variable(surface%gsd_vd%vmxtpr)
    call release_variable(surface%gsd_vd%vmntpr)
    if (allocated(surface%gsd_vd%vmxtpr6)) then
      do i = lbound(surface%gsd_vd%vmxtpr6, 1), ubound(surface%gsd_vd%vmxtpr6, 1)
        call release_variable(surface%gsd_vd%vmxtpr6(i))
      end do
      call move_alloc(surface%gsd_vd%vmxtpr6, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vmntpr6)) then
      do i = lbound(surface%gsd_vd%vmntpr6, 1), ubound(surface%gsd_vd%vmntpr6, 1)
        call release_variable(surface%gsd_vd%vmntpr6(i))
      end do
      call move_alloc(surface%gsd_vd%vmntpr6, surface_array1)
      deallocate (surface_array1)
    end if
    call release_variable(surface%gsd_vd%vtpr)
    call release_variable(surface%gsd_vd%vlsrr)
    call release_variable(surface%gsd_vd%vcrr)
    call release_variable(surface%gsd_vd%vlssfr)
    call release_variable(surface%gsd_vd%vcsfr)
    call release_variable(surface%gsd_vd%vptype)
    call release_variable(surface%gsd_vd%vilspf)
    call release_variable(surface%gsd_vd%vz0f)
    call release_variable(surface%gsd_vd%vlz0h)
    call release_variable(surface%gsd_vd%vviwve)
    call release_variable(surface%gsd_vd%vviwvn)
    call release_variable(surface%gsd_vd%vtcw)
    call release_variable(surface%gsd_vd%vtcwv)
    call release_variable(surface%gsd_vd%vtclw)
    call release_variable(surface%gsd_vd%vtciw)
    call release_variable(surface%gsd_vd%vtcrw)
    call release_variable(surface%gsd_vd%vtcsw)
    call release_variable(surface%gsd_vd%vtcslw)
    call release_variable(surface%gsd_vd%vssrd)
    call release_variable(surface%gsd_vd%vstrd)
    call release_variable(surface%gsd_vd%vssrdc)
    call release_variable(surface%gsd_vd%vstrdc)
    call release_variable(surface%gsd_vd%vblh)
    call release_variable(surface%gsd_vd%vsund)
    call release_variable(surface%gsd_vd%vspar)
    call release_variable(surface%gsd_vd%vsuvb)
    call release_variable(surface%gsd_vd%vsfdir)
    call release_variable(surface%gsd_vd%vscdir)
    call release_variable(surface%gsd_vd%vsdsrp)
    call release_variable(surface%gsd_vd%vcape)
    call release_variable(surface%gsd_vd%vmucape)
    call release_variable(surface%gsd_vd%vmlcape50)
    call release_variable(surface%gsd_vd%vmlcape100)
    call release_variable(surface%gsd_vd%vpdepl)
    call release_variable(surface%gsd_vd%vcapes)
    if (allocated(surface%gsd_vd%vmxcap6)) then
      do i = lbound(surface%gsd_vd%vmxcap6, 1), ubound(surface%gsd_vd%vmxcap6, 1)
        call release_variable(surface%gsd_vd%vmxcap6(i))
      end do
      call move_alloc(surface%gsd_vd%vmxcap6, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vmxcaps6)) then
      do i = lbound(surface%gsd_vd%vmxcaps6, 1), ubound(surface%gsd_vd%vmxcaps6, 1)
        call release_variable(surface%gsd_vd%vmxcaps6(i))
      end do
      call move_alloc(surface%gsd_vd%vmxcaps6, surface_array1)
      deallocate (surface_array1)
    end if
    call release_variable(surface%gsd_vd%vtropotp)
    call release_variable(surface%gsd_vd%vtsrc)
    call release_variable(surface%gsd_vd%vttrc)
    call release_variable(surface%gsd_vd%vssrc)
    call release_variable(surface%gsd_vd%vstrc)
    call release_variable(surface%gsd_vd%ves)
    call release_variable(surface%gsd_vd%vsmlt)
    call release_variable(surface%gsd_vd%v10fg)
    if (allocated(surface%gsd_vd%v10fg6)) then
      do i = lbound(surface%gsd_vd%v10fg6, 1), ubound(surface%gsd_vd%v10fg6, 1)
        call release_variable(surface%gsd_vd%v10fg6(i))
      end do
      call move_alloc(surface%gsd_vd%v10fg6, surface_array1)
      deallocate (surface_array1)
    end if
    call release_variable(surface%gsd_vd%v10fgcv)
    call release_variable(surface%gsd_vd%vi10fg)
    call release_variable(surface%gsd_vd%vlspf)
    call release_variable(surface%gsd_vd%vtco3)
    call release_variable(surface%gsd_vd%vvimd)
    call release_variable(surface%gsd_vd%vsparc)
    call release_variable(surface%gsd_vd%vstinc)
    call release_variable(surface%gsd_vd%vcbase)
    call release_variable(surface%gsd_vd%v0degl)
    call release_variable(surface%gsd_vd%vm10degl)
    call release_variable(surface%gsd_vd%vvisih)
    call release_variable(surface%gsd_vd%vcin)
    call release_variable(surface%gsd_vd%vmlcin50)
    call release_variable(surface%gsd_vd%vmlcin100)
    call release_variable(surface%gsd_vd%vkindex)
    call release_variable(surface%gsd_vd%vttindex)
    call release_variable(surface%gsd_vd%vcbasea)
    call release_variable(surface%gsd_vd%vctopc)
    call release_variable(surface%gsd_vd%vztwetb0)
    call release_variable(surface%gsd_vd%vztwetb1)
    if (allocated(surface%gsd_vd%vtcghg)) then
      do i = lbound(surface%gsd_vd%vtcghg, 1), ubound(surface%gsd_vd%vtcghg, 1)
        call release_variable(surface%gsd_vd%vtcghg(i))
      end do
      call move_alloc(surface%gsd_vd%vtcghg, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vtcchem)) then
      do i = lbound(surface%gsd_vd%vtcchem, 1), ubound(surface%gsd_vd%vtcchem, 1)
        call release_variable(surface%gsd_vd%vtcchem(i))
      end do
      call move_alloc(surface%gsd_vd%vtcchem, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vaerodiag)) then
      do j = lbound(surface%gsd_vd%vaerodiag, 2), ubound(surface%gsd_vd%vaerodiag, 2)
        do i = lbound(surface%gsd_vd%vaerodiag, 1), ubound(surface%gsd_vd%vaerodiag, 1)
          call release_variable(surface%gsd_vd%vaerodiag(i, j))
        end do
      end do
      call move_alloc(surface%gsd_vd%vaerodiag, surface_array2)
      deallocate (surface_array2)
    end if
    if (allocated(surface%gsd_vd%vaero_wvl_diag)) then
      do j = lbound(surface%gsd_vd%vaero_wvl_diag, 2), ubound(surface%gsd_vd%vaero_wvl_diag, 2)
        do i = lbound(surface%gsd_vd%vaero_wvl_diag, 1), ubound(surface%gsd_vd%vaero_wvl_diag, 1)
          call release_variable(surface%gsd_vd%vaero_wvl_diag(i, j))
        end do
      end do
      call move_alloc(surface%gsd_vd%vaero_wvl_diag, surface_array2)
      deallocate (surface_array2)
    end if
    call release_variable(surface%gsd_vd%v100u)
    call release_variable(surface%gsd_vd%v100v)
    call release_variable(surface%gsd_vd%v200u)
    call release_variable(surface%gsd_vd%v200v)
    call release_variable(surface%gsd_vd%vzust)
    call release_variable(surface%gsd_vd%v10nu)
    call release_variable(surface%gsd_vd%v10nv)
    call release_variable(surface%gsd_vd%vdndzn)
    call release_variable(surface%gsd_vd%vdndza)
    call release_variable(surface%gsd_vd%vdctb)
    call release_variable(surface%gsd_vd%vtplb)
    call release_variable(surface%gsd_vd%vtplt)
    call release_variable(surface%gsd_vd%vodss)
    call release_variable(surface%gsd_vd%voddu)
    call release_variable(surface%gsd_vd%vodom)
    call release_variable(surface%gsd_vd%vodbc)
    call release_variable(surface%gsd_vd%vodsu)
    call release_variable(surface%gsd_vd%vodni)
    call release_variable(surface%gsd_vd%vodam)
    call release_variable(surface%gsd_vd%vodsoa)
    call release_variable(surface%gsd_vd%vodvfa)
    call release_variable(surface%gsd_vd%vodvsu)
    call release_variable(surface%gsd_vd%vodtoacc)
    call release_variable(surface%gsd_vd%vaepm1)
    call release_variable(surface%gsd_vd%vaepm25)
    call release_variable(surface%gsd_vd%vaepm10)
    call release_variable(surface%gsd_vd%vuvbed)
    call release_variable(surface%gsd_vd%vuvbedcs)
    call release_variable(surface%gsd_vd%vlitoti)
    call release_variable(surface%gsd_vd%vlicgi)
    if (allocated(surface%gsd_vd%vlitota6)) then
      do i = lbound(surface%gsd_vd%vlitota6, 1), ubound(surface%gsd_vd%vlitota6, 1)
        call release_variable(surface%gsd_vd%vlitota6(i))
      end do
      call move_alloc(surface%gsd_vd%vlitota6, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vlicga6)) then
      do i = lbound(surface%gsd_vd%vlicga6, 1), ubound(surface%gsd_vd%vlicga6, 1)
        call release_variable(surface%gsd_vd%vlicga6(i))
      end do
      call move_alloc(surface%gsd_vd%vlicga6, surface_array1)
      deallocate (surface_array1)
    end if
    if (allocated(surface%gsd_vd%vptypeocc6)) then
      do j = lbound(surface%gsd_vd%vptypeocc6, 2), ubound(surface%gsd_vd%vptypeocc6, 2)
        do i = lbound(surface%gsd_vd%vptypeocc6, 1), ubound(surface%gsd_vd%vptypeocc6, 1)
          call release_variable(surface%gsd_vd%vptypeocc6(i, j))
        end do
      end do
      call move_alloc(surface%gsd_vd%vptypeocc6, surface_array2)
      deallocate (surface_array2)
    end if
    call release_variable(surface%gsd_sm%vclbt)
    call release_variable(surface%gsd_sm%vcsbt)
    call release_variable(surface%gsd_ws%vchar)
    call release_variable(surface%gsd_ws%vcharhq)
    call release_variable(surface%gsd_ws%vustokes)
    call release_variable(surface%gsd_ws%vvstokes)
    call release_variable(surface%gsd_ws%vtauocx)
    call release_variable(surface%gsd_ws%vtauocy)
    call release_variable(surface%gsd_ws%vphioc)
    call release_variable(surface%gsd_ws%vwsemean)
    call release_variable(surface%gsd_ws%vwsfmean)
    call release_variable(surface%gsd_ww%vu10n)
    call release_variable(surface%gsd_ww%vv10n)
    call release_variable(surface%gsd_ww%vrho)
    call release_variable(surface%gsd_ww%vzil)
    call release_variable(surface%gsd_ww%vcif)
    call release_variable(surface%gsd_ww%vclk)
    call release_variable(surface%gsd_ww%vucurw)
    call release_variable(surface%gsd_ww%vvcurw)
    ! Embedded group metadata stays in the surface root; release payloads only.
    call release_payload(surface%gsp_sb%f_group)
    call release_payload(surface%gsp_sg%f_group)
    call release_payload(surface%gsp_sl%f_group)
    call release_payload(surface%gsp_rr%f_group)
    call release_payload(surface%gsp_cl%f_group)
    call release_payload(surface%gsp_om%f_group)
    call release_payload(surface%gsp_ep%f_group)
    call release_payload(surface%gsp_x2%f_group)
    call release_payload(surface%gsp_ci%f_group)
    call release_payload(surface%gsd_vf%f_group)
    call release_payload(surface%gsd_vn%f_group)
    call release_payload(surface%gsd_v2%f_group)
    call release_payload(surface%gsd_v3%f_group)
    call release_payload(surface%gsd_vd%f_group)
    call release_payload(surface%gsd_sm%f_group)
    call release_payload(surface%gsd_ws%f_group)
    call release_payload(surface%gsd_ww%f_group)
    call release_payload(surface%gsd_xa%f_group)
    call release_payload(surface%gsd_x2%f_group)
    surface_owner => surface
    nullify (surface)
    deallocate (surface_owner)
    ! Main and EC physics rows use the release view-table order.

    call release_variable(variables%u)
    call release_variable(variables%v)
    call release_variable(variables%t)
    call release_variable(variables%div)
    call release_variable(variables%vor)
    call release_variable(variables%spd)
    call release_variable(variables%svd)
    call release_variable(variables%nhx)
    call release_variable(variables%edot)
    call release_variable(variables%sgrtl)
    call release_variable(variables%sgrtm)
    call release_variable(variables%sp)
    call release_variable(variables%q)
    call release_variable(variables%i)
    call release_variable(variables%l)
    call release_variable(variables%lconv)
    call release_variable(variables%iconv)
    call release_variable(variables%rconv)
    call release_variable(variables%sconv)
    call release_variable(variables%irad)
    call release_variable(variables%lrad)
    call release_variable(variables%s)
    call release_variable(variables%r)
    call release_variable(variables%g)
    call release_variable(variables%h)
    call release_variable(variables%tke)
    call release_variable(variables%tte)
    call release_variable(variables%efb1)
    call release_variable(variables%efb2)
    call release_variable(variables%efb3)
    call release_variable(variables%a)
    call release_variable(variables%o3)
    call release_variable(variables%src)
    call release_variable(variables%mxl)
    call release_variable(variables%shtur)
    call release_variable(variables%fqtur)
    call release_variable(variables%fstur)
    call release_variable(variables%cpf)
    call release_variable(variables%spf)
    call release_variable(variables%cvgq)
    call release_variable(variables%qva)
    nullify (variables%ghg)
    if (associated(variables%ghg_g)) then
      do i = lbound(variables%ghg_g, 1), ubound(variables%ghg_g, 1)
        call release_variable(variables%ghg_g(i))
      end do
      group_owner => variables%ghg_g
      nullify (variables%ghg_g)
      deallocate (group_owner)
    end if
    nullify (variables%chem)
    if (associated(variables%chem_g)) then
      do i = lbound(variables%chem_g, 1), ubound(variables%chem_g, 1)
        call release_variable(variables%chem_g(i))
      end do
      group_owner => variables%chem_g
      nullify (variables%chem_g)
      deallocate (group_owner)
    end if
    nullify (variables%aero)
    if (associated(variables%aero_g)) then
      do i = lbound(variables%aero_g, 1), ubound(variables%aero_g, 1)
        call release_variable(variables%aero_g(i))
      end do
      group_owner => variables%aero_g
      nullify (variables%aero_g)
      deallocate (group_owner)
    end if
    call release_variable(variables%lrch4)
    nullify (variables%forc)
    if (associated(variables%forc_g)) then
      do i = lbound(variables%forc_g, 1), ubound(variables%forc_g, 1)
        call release_variable(variables%forc_g(i))
      end do
      group_owner => variables%forc_g
      nullify (variables%forc_g)
      deallocate (group_owner)
    end if
    nullify (variables%ezdiag)
    if (associated(variables%ezdiag_g)) then
      do i = lbound(variables%ezdiag_g, 1), ubound(variables%ezdiag_g, 1)
        call release_variable(variables%ezdiag_g(i))
      end do
      group_owner => variables%ezdiag_g
      nullify (variables%ezdiag_g)
      deallocate (group_owner)
    end if
    nullify (variables%era40)
    if (associated(variables%era40_g)) then
      do i = lbound(variables%era40_g, 1), ubound(variables%era40_g, 1)
        call release_variable(variables%era40_g(i))
      end do
      group_owner => variables%era40_g
      nullify (variables%era40_g)
      deallocate (group_owner)
    end if
    nullify (variables%nogw)
    if (associated(variables%nogw_g)) then
      do i = lbound(variables%nogw_g, 1), ubound(variables%nogw_g, 1)
        call release_variable(variables%nogw_g(i))
      end do
      group_owner => variables%nogw_g
      nullify (variables%nogw_g)
      deallocate (group_owner)
    end if
    nullify (variables%emis3d)
    if (associated(variables%emis3d_g)) then
      do i = lbound(variables%emis3d_g, 1), ubound(variables%emis3d_g, 1)
        call release_variable(variables%emis3d_g(i))
      end do
      group_owner => variables%emis3d_g
      nullify (variables%emis3d_g)
      deallocate (group_owner)
    end if
    nullify (variables%edrp)
    if (associated(variables%edrp_g)) then
      do i = lbound(variables%edrp_g, 1), ubound(variables%edrp_g, 1)
        call release_variable(variables%edrp_g(i))
      end do
      group_owner => variables%edrp_g
      nullify (variables%edrp_g)
      deallocate (group_owner)
    end if
    nullify (variables%sldia)
    if (associated(variables%sldia_g)) then
      do i = lbound(variables%sldia_g, 1), ubound(variables%sldia_g, 1)
        call release_variable(variables%sldia_g(i))
      end do
      group_owner => variables%sldia_g
      nullify (variables%sldia_g)
      deallocate (group_owner)
    end if
    nullify (variables%aeraot)
    if (associated(variables%aeraot_g)) then
      do i = lbound(variables%aeraot_g, 1), ubound(variables%aeraot_g, 1)
        call release_variable(variables%aeraot_g(i))
      end do
      group_owner => variables%aeraot_g
      nullify (variables%aeraot_g)
      deallocate (group_owner)
    end if
    nullify (variables%aerlisi)
    if (associated(variables%aerlisi_g)) then
      do i = lbound(variables%aerlisi_g, 1), ubound(variables%aerlisi_g, 1)
        call release_variable(variables%aerlisi_g(i))
      end do
      group_owner => variables%aerlisi_g
      nullify (variables%aerlisi_g)
      deallocate (group_owner)
    end if
    nullify (variables%aerout)
    if (associated(variables%aerout_g)) then
      do i = lbound(variables%aerout_g, 1), ubound(variables%aerout_g, 1)
        call release_variable(variables%aerout_g(i))
      end do
      group_owner => variables%aerout_g
      nullify (variables%aerout_g)
      deallocate (group_owner)
    end if
    nullify (variables%aeroclim)
    if (associated(variables%aeroclim_g)) then
      do i = lbound(variables%aeroclim_g, 1), ubound(variables%aeroclim_g, 1)
        call release_variable(variables%aeroclim_g(i))
      end do
      group_owner => variables%aeroclim_g
      nullify (variables%aeroclim_g)
      deallocate (group_owner)
    end if
    nullify (variables%uvp)
    if (associated(variables%uvp_g)) then
      do i = lbound(variables%uvp_g, 1), ubound(variables%uvp_g, 1)
        call release_variable(variables%uvp_g(i))
      end do
      group_owner => variables%uvp_g
      nullify (variables%uvp_g)
      deallocate (group_owner)
    end if
    nullify (variables%phys)
    if (associated(variables%phys_g)) then
      do i = lbound(variables%phys_g, 1), ubound(variables%phys_g, 1)
        call release_variable(variables%phys_g(i))
      end do
      group_owner => variables%phys_g
      nullify (variables%phys_g)
      deallocate (group_owner)
    end if
    call release_variable(variables%phycty)
    call release_variable(variables%rspec)
    call release_variable(variables%sdsat)
    call release_variable(variables%cvv)
    call release_variable(variables%rkth)
    call release_variable(variables%rktqv)
    call release_variable(variables%rktqc)
    call release_variable(variables%uom)
    call release_variable(variables%ual)
    call release_variable(variables%dom)
    call release_variable(variables%dal)
    call release_variable(variables%uen)
    call release_variable(variables%unebh)
    nullify (variables%lima)
    if (associated(variables%lima_g)) then
      do i = lbound(variables%lima_g, 1), ubound(variables%lima_g, 1)
        call release_variable(variables%lima_g(i))
      end do
      group_owner => variables%lima_g
      nullify (variables%lima_g)
      deallocate (group_owner)
    end if
    call release_variable(variables%fsd)
    nullify (variables%ext)
    if (associated(variables%ext_g)) then
      do i = lbound(variables%ext_g, 1), ubound(variables%ext_g, 1)
        call release_variable(variables%ext_g(i))
      end do
      group_owner => variables%ext_g
      nullify (variables%ext_g)
      deallocate (group_owner)
    end if
    call release_variable(variables%ecphys%ustrti)
    call release_variable(variables%ecphys%vstrti)
    call release_variable(variables%ecphys%ahfsti)
    call release_variable(variables%ecphys%evapti)
    call release_variable(variables%ecphys%tskti)
    ! Geometry declarations retain their own source order.
    call release_variable(variables%geometry%rcori)
    call release_variable(variables%geometry%rcoric)
    call release_variable(variables%geometry%gemu)
    call release_variable(variables%geometry%gsqm2)
    call release_variable(variables%geometry%gelam)
    call release_variable(variables%geometry%gelat)
    call release_variable(variables%geometry%geclo)
    call release_variable(variables%geometry%geslo)
    call release_variable(variables%geometry%gm)
    call release_variable(variables%geometry%gmappa)
    call release_variable(variables%geometry%gomvrl)
    call release_variable(variables%geometry%gomvrm)
    call release_variable(variables%geometry%gnordl)
    call release_variable(variables%geometry%gnordm)
    call release_variable(variables%geometry%gnordlcl)
    call release_variable(variables%geometry%gnordmcl)
    call release_variable(variables%geometry%gnordmcm)
    call release_variable(variables%geometry%gaw)
    call release_variable(variables%geometry%orog)
    call release_variable(variables%geometry%orogl)
    call release_variable(variables%geometry%orogm)
    ! Radiation declarations retain their own source order.
    call release_variable(variables%radiation%emtd)
    call release_variable(variables%radiation%trsw)
    call release_variable(variables%radiation%emtc)
    call release_variable(variables%radiation%trsc)
    call release_variable(variables%radiation%emtu)
    call release_variable(variables%radiation%tauaer)
    call release_variable(variables%radiation%srswd)
    call release_variable(variables%radiation%srlwdc)
    call release_variable(variables%radiation%srlwd)
    call release_variable(variables%radiation%srswdc)
    call release_variable(variables%radiation%srswdcs)
    call release_variable(variables%radiation%srlwdcs)
    call release_variable(variables%radiation%srswdv)
    call release_variable(variables%radiation%srswduv)
    call release_variable(variables%radiation%edro)
    call release_variable(variables%radiation%srswpar)
    call release_variable(variables%radiation%srswuvb)
    call release_variable(variables%radiation%srswparc)
    call release_variable(variables%radiation%srswtinc)
    call release_variable(variables%radiation%srfdir)
    call release_variable(variables%radiation%srcdir)
    call release_variable(variables%radiation%rmoon)
    call release_variable(variables%radiation%derivativelw)
    variable_owner => variables
    nullify (variables)
    deallocate (variable_owner)
    call ieee_set_status(incoming_status)
    errno_word = incoming_errno
    status = 0_c_int
  end function release_registry_graph

  !> Compare only the actual native array bases, without reading array values.
  !> Shape and stride differences are not an additional source admission rule.
  logical function same_group_base(owner, alias) result(same)
    type(native_registry_variable_3d), pointer, intent(in) :: owner(:), alias(:)
    same = .false.
    if (.not. associated(owner) .and. .not. associated(alias)) then
      same = .true.
    else if (associated(owner) .and. associated(alias)) then
      same = c_associated(c_loc(owner), c_loc(alias))
    end if
  end function same_group_base

  !> Free DATA first. PTR is an additional owner only when explicitly marked.
  !> A borrowed field does not read, modify or free either numerical pointer.
  subroutine release_payload_2d(field)
    type(native_registry_field_2d), intent(inout) :: field
    real(c_double), pointer :: extra(:, :), owned_data(:, :)
    if (.not. field%owned) return
    nullify (extra)
    if (field%ptr_owned) extra => field%ptr
    owned_data => field%data
    nullify (field%view, field%ptr, field%data)
    if (associated(owned_data)) deallocate (owned_data)
    if (field%ptr_owned) then
      if (associated(extra)) deallocate (extra)
    end if
    nullify (field%data)
    field%ptr_owned = .false.
  end subroutine release_payload_2d

  !> Release the six unique FIELD metadata owners in source order.
  !> Block views P/T0/T1/T9/PH9/DL/DM are opaque and remain unread.
  subroutine release_variable_2d(variable)
    type(native_registry_variable_2d), intent(inout) :: variable
    type(native_registry_field_2d), pointer :: child

    child => variable%ft0
    nullify (variable%ft0)
    if (associated(child)) then
      call release_payload_2d(child)
      deallocate (child)
    end if
    child => variable%ft1
    nullify (variable%ft1)
    if (associated(child)) then
      call release_payload_2d(child)
      deallocate (child)
    end if
    child => variable%ft9
    nullify (variable%ft9)
    if (associated(child)) then
      call release_payload_2d(child)
      deallocate (child)
    end if
    child => variable%fph9
    nullify (variable%fph9)
    if (associated(child)) then
      call release_payload_2d(child)
      deallocate (child)
    end if
    child => variable%fdl
    nullify (variable%fdl)
    if (associated(child)) then
      call release_payload_2d(child)
      deallocate (child)
    end if
    child => variable%fdm
    nullify (variable%fdm)
    if (associated(child)) then
      call release_payload_2d(child)
      deallocate (child)
    end if
  end subroutine release_variable_2d

  !> Free DATA first. PTR is an additional owner only when explicitly marked.
  !> A borrowed field does not read, modify or free either numerical pointer.
  subroutine release_payload_3d(field)
    type(native_registry_field_3d), intent(inout) :: field
    real(c_double), pointer :: extra(:, :, :), owned_data(:, :, :)
    if (.not. field%owned) return
    nullify (extra)
    if (field%ptr_owned) extra => field%ptr
    owned_data => field%data
    nullify (field%view, field%ptr, field%data)
    if (associated(owned_data)) deallocate (owned_data)
    if (field%ptr_owned) then
      if (associated(extra)) deallocate (extra)
    end if
    nullify (field%data)
    field%ptr_owned = .false.
  end subroutine release_payload_3d

  !> Release the six unique FIELD metadata owners in source order.
  !> Block views P/T0/T1/T9/PH9/DL/DM are opaque and remain unread.
  subroutine release_variable_3d(variable)
    type(native_registry_variable_3d), intent(inout) :: variable
    type(native_registry_field_3d), pointer :: child

    child => variable%ft0
    nullify (variable%ft0)
    if (associated(child)) then
      call release_payload_3d(child)
      deallocate (child)
    end if
    child => variable%ft1
    nullify (variable%ft1)
    if (associated(child)) then
      call release_payload_3d(child)
      deallocate (child)
    end if
    child => variable%ft9
    nullify (variable%ft9)
    if (associated(child)) then
      call release_payload_3d(child)
      deallocate (child)
    end if
    child => variable%fph9
    nullify (variable%fph9)
    if (associated(child)) then
      call release_payload_3d(child)
      deallocate (child)
    end if
    child => variable%fdl
    nullify (variable%fdl)
    if (associated(child)) then
      call release_payload_3d(child)
      deallocate (child)
    end if
    child => variable%fdm
    nullify (variable%fdm)
    if (associated(child)) then
      call release_payload_3d(child)
      deallocate (child)
    end if
  end subroutine release_variable_3d

  !> Free DATA first. PTR is an additional owner only when explicitly marked.
  !> A borrowed field does not read, modify or free either numerical pointer.
  subroutine release_payload_4d(field)
    type(native_registry_field_4d), intent(inout) :: field
    real(c_double), pointer :: extra(:, :, :, :), owned_data(:, :, :, :)
    if (.not. field%owned) return
    nullify (extra)
    if (field%ptr_owned) extra => field%ptr
    owned_data => field%data
    nullify (field%view, field%ptr, field%data)
    if (associated(owned_data)) deallocate (owned_data)
    if (field%ptr_owned) then
      if (associated(extra)) deallocate (extra)
    end if
    nullify (field%data)
    field%ptr_owned = .false.
  end subroutine release_payload_4d

  !> Release the six unique FIELD metadata owners in source order.
  !> Block views P/T0/T1/T9/PH9/DL/DM are opaque and remain unread.
  subroutine release_variable_4d(variable)
    type(native_registry_variable_4d), intent(inout) :: variable
    type(native_registry_field_4d), pointer :: child

    child => variable%ft0
    nullify (variable%ft0)
    if (associated(child)) then
      call release_payload_4d(child)
      deallocate (child)
    end if
    child => variable%ft1
    nullify (variable%ft1)
    if (associated(child)) then
      call release_payload_4d(child)
      deallocate (child)
    end if
    child => variable%ft9
    nullify (variable%ft9)
    if (associated(child)) then
      call release_payload_4d(child)
      deallocate (child)
    end if
    child => variable%fph9
    nullify (variable%fph9)
    if (associated(child)) then
      call release_payload_4d(child)
      deallocate (child)
    end if
    child => variable%fdl
    nullify (variable%fdl)
    if (associated(child)) then
      call release_payload_4d(child)
      deallocate (child)
    end if
    child => variable%fdm
    nullify (variable%fdm)
    if (associated(child)) then
      call release_payload_4d(child)
      deallocate (child)
    end if
  end subroutine release_variable_4d

end module forecast_registry_release
