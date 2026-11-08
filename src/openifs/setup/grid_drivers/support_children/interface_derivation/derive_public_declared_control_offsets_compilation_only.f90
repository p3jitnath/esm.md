module declaration_offset_derivation
  use type_model, only: model
  use model_physics_mf_mod, only: model_physics_mf_type
  use yomdyn, only: tdyn
  use geometry_mod, only: geometry
  use iso_fortran_env, only: int64
  implicit none
contains
  function model_lsddh(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_diag%yrlddh%lsddh) - loc(p)
  end function
  function model_lflexdia(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_diag%yrlddh%lflexdia) - loc(p)
  end function
  function model_lagphy(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_ec%yrephy%lagphy) - loc(p)
  end function
  function model_lsimph(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_mf%yrsimphl%lsimph) - loc(p)
  end function
  function model_ltrajps(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_mf%yrsimphl%ltrajps) - loc(p)
  end function
  function model_ldirclsmod(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_g%yrdphy%ldirclsmod) - loc(p)
  end function
  function model_nfrcpl(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_aoc%yrmcc%nfrcpl) - loc(p)
  end function
  function mf_ltrajps(p) result(offset)
    type(model_physics_mf_type), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrsimphl%ltrajps) - loc(p)
  end function
  function mf_lmse(p) result(offset)
    type(model_physics_mf_type), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrarphy%lmse) - loc(p)
  end function
  function mf_ngpar(p) result(offset)
    type(model_physics_mf_type), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrparar%ngpar) - loc(p)
  end function
  function dyn_ncurrent_iter(p) result(offset)
    type(tdyn), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%ncurrent_iter) - loc(p)
  end function
  function geometry_rstret(p) result(offset)
    type(geometry), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrgem%rstret) - loc(p)
  end function
end module
