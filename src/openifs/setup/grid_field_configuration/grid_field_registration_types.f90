module grid_field_registration_types_port
  !! Native plans and counters for the generated selected field helpers.
  !! Counters and indices count fields; all indices are one based and zero
  !! denotes no previous field. No private record offsets or pointer aliases
  !! form part of this interface. Callers own and retain the component array.
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: grid_field_registration_state, field_definition_plan, field_attribute_plan
  type :: grid_field_registration_state
    integer(int32) :: numflds = 0, nders = 0, numspflds = 0, numgpflds = 0
    integer(int32) :: numflds9 = 0, numflds1 = 0, numspflds1 = 0, numflds5 = 0
    integer(int32) :: numfldsphy = 0, numflds_spl = 0, numflds_sl1 = 0, numfldspc = 0
    integer(int32) :: ndim = 0, numfldspt = 0, ndim0 = 0, ndim9 = 0, ndim1 = 0, ndim5 = 0
    integer(int32) :: ndimslp = 0, ndim_spl = 0, ndimpt = 0, ndimpc = 0
    integer(int32) :: last_index = 0
  end type
  type :: field_definition_plan
    character(len=16) :: cname = repeat(achar(0), 16)
    integer(int32) :: igrbcode = 0, ifid = 0, nreqin = 0, lreqout = 0
    integer(int32) :: lgpingp = 0, lmgrid = 0, ltrajio = 0, lthermact = 0, lprecip = 0
    integer(int32) :: lmassfix = 0, lcomad = 0, lnegfix = 0
    real(real64) :: refvali = 0.0_real64, r = 0.0_real64, rcp = 0.0_real64
    real(real64) :: rlzer = 0.0_real64, weno_alpha = 0.0_real64, betamfbc = 0.0_real64
  end type
  type :: field_attribute_plan
    integer(int32) :: adv = 0, mgrid = 0, adv5 = 0, tdiab = 0, hort = 0, lt9 = 0, phy = 0, pt = 0, pc = 0
    integer(int32) :: coupling = 0
    real(real64) :: refvalc = 0.0_real64
    character(len=12) :: cslint = repeat(achar(0), 12)
  end type
end module grid_field_registration_types_port
