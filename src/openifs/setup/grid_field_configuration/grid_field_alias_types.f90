module grid_field_alias_types_port
  !! Native component associations use owner indices and lengths.
  !! They borrow the caller-owned array without owning or freeing its fields.
  !! Scalar indices are one based; zero means no association.
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private
  public :: grid_field_alias_controls, grid_field_aliases, component_alias_span
  type :: component_alias_span
    integer(int32) :: first_index = 0, count = 0
  end type
  type :: grid_field_alias_controls
    integer(int32) :: nnogw = 0
    integer(int32) :: ngfl_ext = 0
    integer(int32) :: ngfl_forc = 0
    integer(int32) :: ngfl_ezdiag = 0
    integer(int32) :: nghg = 0
    integer(int32) :: nchem = 0
    integer(int32) :: naero = 0
    integer(int32) :: nera40 = 0
    integer(int32) :: nemis3d = 0
    integer(int32) :: nedrp = 0
    integer(int32) :: naerout = 0
    integer(int32) :: naeroclim = 0
    integer(int32) :: nuvp = 0
    integer(int32) :: nsldia = 0
    integer(int32) :: nlima = 0
    integer(int32) :: laerlisi = 0
  end type
  type :: grid_field_aliases
    integer(int32) :: yq = 0
    integer(int32) :: yl = 0
    integer(int32) :: yi = 0
    integer(int32) :: ys = 0
    integer(int32) :: yr = 0
    integer(int32) :: yg = 0
    integer(int32) :: yh = 0
    integer(int32) :: ytke = 0
    integer(int32) :: yefb1 = 0
    integer(int32) :: yefb2 = 0
    integer(int32) :: yefb3 = 0
    integer(int32) :: ya = 0
    integer(int32) :: yo3 = 0
    integer(int32) :: ycpf = 0
    integer(int32) :: yspf = 0
    integer(int32) :: ysrc = 0
    integer(int32) :: ycvgq = 0
    integer(int32) :: ylconv = 0
    integer(int32) :: yiconv = 0
    integer(int32) :: yrconv = 0
    integer(int32) :: ysconv = 0
    integer(int32) :: ylrad = 0
    integer(int32) :: yirad = 0
    integer(int32) :: ysdsat = 0
    integer(int32) :: ycvv = 0
    integer(int32) :: yqva = 0
    integer(int32) :: yuom = 0
    integer(int32) :: yual = 0
    integer(int32) :: ydom = 0
    integer(int32) :: ydal = 0
    integer(int32) :: yuen = 0
    integer(int32) :: yunebh = 0
    integer(int32) :: ytte = 0
    integer(int32) :: ymxl = 0
    integer(int32) :: yshtur = 0
    integer(int32) :: yfqtur = 0
    integer(int32) :: yfstur = 0
    integer(int32) :: yrkth = 0
    integer(int32) :: yrspec = 0
    integer(int32) :: yrktqv = 0
    integer(int32) :: yrktqc = 0
    integer(int32) :: ylrch4 = 0
    integer(int32) :: yphycty = 0
    integer(int32) :: yfsd = 0
    type(component_alias_span) :: yext
    type(component_alias_span) :: yforc
    type(component_alias_span) :: yezdiag
    type(component_alias_span) :: yghg
    type(component_alias_span) :: ychem
    type(component_alias_span) :: yaero
    type(component_alias_span) :: yera40
    type(component_alias_span) :: ynogw
    type(component_alias_span) :: yemis3d
    type(component_alias_span) :: yedrp
    type(component_alias_span) :: yaeraot
    type(component_alias_span) :: yaerlisi
    type(component_alias_span) :: yaerout
    type(component_alias_span) :: yaeroclim
    type(component_alias_span) :: yuvp
    type(component_alias_span) :: ysldia
    type(component_alias_span) :: ylima
  end type
end module grid_field_alias_types_port
