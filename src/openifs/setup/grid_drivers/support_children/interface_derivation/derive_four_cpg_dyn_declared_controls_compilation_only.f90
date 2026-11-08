module declaration_offset_derivation_extension
  use type_model, only: model
  use iso_fortran_env, only: int64
  implicit none
contains
  function model_lslag(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_dyn%yrdyna%lslag) - loc(p)
  end function
  function model_lephys(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_ec%yrephy%lephys) - loc(p)
  end function
  function model_lmphys(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_mf%yrphy%lmphys) - loc(p)
  end function
  function model_lsphlc(p) result(offset)
    type(model), target, intent(in) :: p
    integer(int64) :: offset
    offset = loc(p%yrml_phy_slin%yrphlc%lsphlc) - loc(p)
  end function
end module
