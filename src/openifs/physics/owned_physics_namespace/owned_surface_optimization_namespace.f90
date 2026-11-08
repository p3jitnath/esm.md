!> Expose the same eighteen native optimization owners used by SUOPTSURF.
module forecast_owned_surface_optimization_namespace
  use iso_fortran_env, only: int32
 use surface_optimization_parameters_mod,only:rvr0vt,rvcmax25,rhumrel,ra1,rb1,rg0,rgm25,re_vcmax,re_jmax,ovr0vt,ovcmax25,ohumrel,oa1,ob1,og0,ogm25,oe_vcmax,oe_jmax,release_surface_optimization_parameters
  implicit none
  private
  public::rvr0vt,rvcmax25,rhumrel,ra1,rb1,rg0,rgm25,re_vcmax,re_jmax,ovr0vt,ovcmax25,ohumrel,oa1,ob1,og0,ogm25,oe_vcmax,oe_jmax
  public :: admit_fresh_owned_surface_optimization_namespace, release_owned_surface_optimization_namespace
contains
  !> Admit the compiler-created absent descriptors before the actual producer.
 !! There is no second array owner and no raw descriptor initialization.
  integer(int32) function admit_fresh_owned_surface_optimization_namespace() result(status)
    status = 2
    if (allocated(rvr0vt)) return
    if (allocated(rvcmax25)) return
    if (allocated(rhumrel)) return
    if (allocated(ra1)) return
    if (allocated(rb1)) return
    if (allocated(rg0)) return
    if (allocated(rgm25)) return
    if (allocated(re_vcmax)) return
    if (allocated(re_jmax)) return
    if (allocated(ovr0vt)) return
    if (allocated(ovcmax25)) return
    if (allocated(ohumrel)) return
    if (allocated(oa1)) return
    if (allocated(ob1)) return
    if (allocated(og0)) return
    if (allocated(ogm25)) return
    if (allocated(oe_vcmax)) return
    if (allocated(oe_jmax)) return
    status = 0
  end function
  !> Delegate retirement to the same canonical native owner and source order.
  integer(int32) function release_owned_surface_optimization_namespace() result(status)
    status = release_surface_optimization_parameters()
  end function
end module
