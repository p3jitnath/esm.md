module original_callpar_guard_declarations_only
  use iso_c_binding, only: c_loc, c_intptr_t
  use type_model, only: model
  implicit none
contains
  function offset_0(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrephli), value) - transfer(c_loc(m), value)
  end function
  function offset_1(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_aoc%yrmcc), value) - transfer(c_loc(m), value)
  end function
  function offset_2(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecumf), value) - transfer(c_loc(m), value)
  end function
  function offset_3(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrvdf), value) - transfer(c_loc(m), value)
  end function
  function offset_4(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerdi), value) - transfer(c_loc(m), value)
  end function
  function offset_5(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrslphy), value) - transfer(c_loc(m), value)
  end function
  function offset_6(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yregwd), value) - transfer(c_loc(m), value)
  end function
  function offset_7(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph), value) - transfer(c_loc(m), value)
  end function
  function offset_8(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_dyn%yrdyna), value) - transfer(c_loc(m), value)
  end function
  function offset_9(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%yrrip), value) - transfer(c_loc(m), value)
  end function
  function offset_10(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_mf%yrphy2), value) - transfer(c_loc(m), value)
  end function
  function offset_11(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl), value) - transfer(c_loc(m), value)
  end function
  function offset_12(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecldp), value) - transfer(c_loc(m), value)
  end function
  function offset_13(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecuconvca), value) - transfer(c_loc(m), value)
  end function
  function offset_14(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yreuvrad), value) - transfer(c_loc(m), value)
  end function
  function offset_15(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrcumfs), value) - transfer(c_loc(m), value)
  end function
  function offset_16(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrcompo), value) - transfer(c_loc(m), value)
  end function
  function offset_17(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy), value) - transfer(c_loc(m), value)
  end function
  function offset_18(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yreaeratm), value) - transfer(c_loc(m), value)
  end function
  function offset_19(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrphnc), value) - transfer(c_loc(m), value)
  end function
  function offset_20(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yregwwms), value) - transfer(c_loc(m), value)
  end function
  function offset_21(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrozo), value) - transfer(c_loc(m), value)
  end function
  function offset_22(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrchem), value) - transfer(c_loc(m), value)
  end function
  function offset_23(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrdphy), value) - transfer(c_loc(m), value)
  end function
  function offset_24(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad), value) - transfer(c_loc(m), value)
  end function
  function offset_25(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrncl), value) - transfer(c_loc(m), value)
  end function
  function offset_26(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_sppt), value) - transfer(c_loc(m), value)
  end function
  function offset_27(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%yrsppt_config), value) - transfer(c_loc(m), value)
  end function
  function offset_28(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%yrspp_config), value) - transfer(c_loc(m), value)
  end function
  function offset_29(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_spp), value) - transfer(c_loc(m), value)
  end function
  function offset_30(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%nactaero), value) - transfer(c_loc(m), value)
  end function
  function offset_31(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%naero), value) - transfer(c_loc(m), value)
  end function
  function offset_32(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%nchem), value) - transfer(c_loc(m), value)
  end function
  function offset_33(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%laerchem), value) - transfer(c_loc(m), value)
  end function
  function offset_34(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrcompo%laernitrate), value) - transfer(c_loc(m), value)
  end function
  function offset_35(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%nchem_dv), value) - transfer(c_loc(m), value)
  end function
  function offset_36(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ndim), value) - transfer(c_loc(m), value)
  end function
  function offset_37(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ndim1), value) - transfer(c_loc(m), value)
  end function
  function offset_38(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ndimslp), value) - transfer(c_loc(m), value)
  end function
  function offset_39(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ngems), value) - transfer(c_loc(m), value)
  end function
  function offset_40(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ngfl_ext), value) - transfer(c_loc(m), value)
  end function
  function offset_41(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%nghg), value) - transfer(c_loc(m), value)
  end function
  function offset_42(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ya), value) - transfer(c_loc(m), value)
  end function
  function offset_43(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ytke), value) - transfer(c_loc(m), value)
  end function
  function offset_44(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yaero), value) - transfer(c_loc(m), value)
  end function
  function offset_45(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yext), value) - transfer(c_loc(m), value)
  end function
  function offset_46(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yghg), value) - transfer(c_loc(m), value)
  end function
  function offset_47(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yi), value) - transfer(c_loc(m), value)
  end function
  function offset_48(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yl), value) - transfer(c_loc(m), value)
  end function
  function offset_49(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ynogw), value) - transfer(c_loc(m), value)
  end function
  function offset_50(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%nnogw), value) - transfer(c_loc(m), value)
  end function
  function offset_51(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yo3), value) - transfer(c_loc(m), value)
  end function
  function offset_52(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yedrp), value) - transfer(c_loc(m), value)
  end function
  function offset_53(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%nedrp), value) - transfer(c_loc(m), value)
  end function
  function offset_54(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yq), value) - transfer(c_loc(m), value)
  end function
  function offset_55(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yr), value) - transfer(c_loc(m), value)
  end function
  function offset_56(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%ys), value) - transfer(c_loc(m), value)
  end function
  function offset_57(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%ygfl%yuvp), value) - transfer(c_loc(m), value)
  end function
  function offset_58(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrchem%lchem_light), value) - transfer(c_loc(m), value)
  end function
  function offset_59(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrcumfs%lecumfs), value) - transfer(c_loc(m), value)
  end function
  function offset_60(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrdphy%nvextr), value) - transfer(c_loc(m), value)
  end function
  function offset_61(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrdphy%nvextrdyn), value) - transfer(c_loc(m), value)
  end function
  function offset_62(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yreaeratm%laerdiag1), value) - transfer(c_loc(m), value)
  end function
  function offset_63(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yreaeratm%laerinit), value) - transfer(c_loc(m), value)
  end function
  function offset_64(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecldp%naercld), value) - transfer(c_loc(m), value)
  end function
  function offset_65(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecuconvca%lcuconv_ca), value) - transfer(c_loc(m), value)
  end function
  function offset_66(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecuconvca%nlives), value) - transfer(c_loc(m), value)
  end function
  function offset_67(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecumf%lmfcuca), value) - transfer(c_loc(m), value)
  end function
  function offset_68(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecumf%njkt3), value) - transfer(c_loc(m), value)
  end function
  function offset_69(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecumf%njkt4), value) - transfer(c_loc(m), value)
  end function
  function offset_70(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yregwd%ldiag_strato), value) - transfer(c_loc(m), value)
  end function
  function offset_71(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yregwwms%gtphygwwms), value) - transfer(c_loc(m), value)
  end function
  function offset_72(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrephli%lphylin), value) - transfer(c_loc(m), value)
  end function
  function offset_73(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrephli%lphysfclin), value) - transfer(c_loc(m), value)
  end function
  function offset_74(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%leradimpl), value) - transfer(c_loc(m), value)
  end function
  function offset_75(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lbud23), value) - transfer(c_loc(m), value)
  end function
  function offset_76(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lbudcycle), value) - transfer(c_loc(m), value)
  end function
  function offset_77(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%ldiagturb_ec), value) - transfer(c_loc(m), value)
  end function
  function offset_78(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lductdia), value) - transfer(c_loc(m), value)
  end function
  function offset_79(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%leclipcldt0), value) - transfer(c_loc(m), value)
  end function
  function offset_80(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lvextrdynacc), value) - transfer(c_loc(m), value)
  end function
  function offset_81(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lextratend), value) - transfer(c_loc(m), value)
  end function
  function offset_82(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%leclipqt0), value) - transfer(c_loc(m), value)
  end function
  function offset_83(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lecond), value) - transfer(c_loc(m), value)
  end function
  function offset_84(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lecumf), value) - transfer(c_loc(m), value)
  end function
  function offset_85(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%ledcld), value) - transfer(c_loc(m), value)
  end function
  function offset_86(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%legwdg), value) - transfer(c_loc(m), value)
  end function
  function offset_87(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%legwwms), value) - transfer(c_loc(m), value)
  end function
  function offset_88(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lemethox), value) - transfer(c_loc(m), value)
  end function
  function offset_89(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%leo3ch), value) - transfer(c_loc(m), value)
  end function
  function offset_90(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lepcld), value) - transfer(c_loc(m), value)
  end function
  function offset_91(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%leqngt), value) - transfer(c_loc(m), value)
  end function
  function offset_92(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%leradi), value) - transfer(c_loc(m), value)
  end function
  function offset_93(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lerads), value) - transfer(c_loc(m), value)
  end function
  function offset_94(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lslphy), value) - transfer(c_loc(m), value)
  end function
  function offset_95(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lerain), value) - transfer(c_loc(m), value)
  end function
  function offset_96(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lesurf), value) - transfer(c_loc(m), value)
  end function
  function offset_97(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%levdif), value) - transfer(c_loc(m), value)
  end function
  function offset_98(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%levdifsl), value) - transfer(c_loc(m), value)
  end function
  function offset_99(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lemwave), value) - transfer(c_loc(m), value)
  end function
  function offset_100(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%laervisi), value) - transfer(c_loc(m), value)
  end function
  function offset_101(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%lapproxlwupdate), value) - transfer(c_loc(m), value)
  end function
  function offset_102(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%lecsrad), value) - transfer(c_loc(m), value)
  end function
  function offset_103(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%nradfr), value) - transfer(c_loc(m), value)
  end function
  function offset_104(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%ntsw), value) - transfer(c_loc(m), value)
  end function
  function offset_105(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%rccnlnd), value) - transfer(c_loc(m), value)
  end function
  function offset_106(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerad%rccnsea), value) - transfer(c_loc(m), value)
  end function
  function offset_107(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yrerdi%repclc), value) - transfer(c_loc(m), value)
  end function
  function offset_108(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yreuvrad%luvproc), value) - transfer(c_loc(m), value)
  end function
  function offset_109(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_rad%yreuvrad%nraduv), value) - transfer(c_loc(m), value)
  end function
  function offset_110(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_aoc%yrmcc%lnemolimput), value) - transfer(c_loc(m), value)
  end function
  function offset_111(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_aoc%yrmcc%lnemolimthk), value) - transfer(c_loc(m), value)
  end function
  function offset_112(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_aoc%yrmcc%lnemoatmflds), value) - transfer(c_loc(m), value)
  end function
  function offset_113(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrncl%lnclin), value) - transfer(c_loc(m), value)
  end function
  function offset_114(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrphnc%lencld2), value) - transfer(c_loc(m), value)
  end function
  function offset_115(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_slin%yrphnc%lepcld2), value) - transfer(c_loc(m), value)
  end function
  function offset_116(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_gconf%yrrip%nstart), value) - transfer(c_loc(m), value)
  end function
  function offset_117(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrslphy%rslwx), value) - transfer(c_loc(m), value)
  end function
  function offset_118(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_g%yrslphy%nvtend), value) - transfer(c_loc(m), value)
  end function
  function offset_119(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%lextrafields), value) - transfer(c_loc(m), value)
  end function
  function offset_120(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%lforcenl), value) - transfer(c_loc(m), value)
  end function
  function offset_121(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%lstoph_casbs), value) - transfer(c_loc(m), value)
  end function
  function offset_122(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%lstoph_spbs), value) - transfer(c_loc(m), value)
  end function
  function offset_123(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%lvortcon), value) - transfer(c_loc(m), value)
  end function
  function offset_124(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%nforceend), value) - transfer(c_loc(m), value)
  end function
  function offset_125(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_stoch%yrstoph%nforcestart), value) - transfer(c_loc(m), value)
  end function
  function offset_126(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrcompo%aero_scheme), value) - transfer(c_loc(m), value)
  end function
  function offset_127(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrecldp%lcldbud_timeint), value) - transfer(c_loc(m), value)
  end function
  function offset_128(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_chem%yrcompo%laersoa), value) - transfer(c_loc(m), value)
  end function
  function offset_129(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_mf%yrphy2%tsphy), value) - transfer(c_loc(m), value)
  end function
  function offset_130(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lelight), value) - transfer(c_loc(m), value)
  end function
  function offset_131(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%lesnml), value) - transfer(c_loc(m), value)
  end function
  function offset_132(m) result(value)
    type(model), target, intent(in) :: m
    integer(c_intptr_t) :: value
    value = transfer(c_loc(m%yrml_phy_ec%yrephy%nsnmlws), value) - transfer(c_loc(m), value)
  end function
end module
