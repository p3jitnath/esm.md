!> Own only named source partition arrays and their local scalar results.
module forecast_distributed_partition_types
  use iso_c_binding, only: c_int
  implicit none
  private
  public :: native_distributed_partition
!> Counts are dimensionless. Array bounds follow SUALMP1,SUALMP2 and SUMP.
!! The parent owns canonical global dimensions, stream and public context.
!! PHASE and borrowed_resolution record lifetime; no geometry pointer is kept.
  type :: native_distributed_partition
    integer(c_int) :: phase = 0, borrowed_resolution = 0
    integer(c_int) :: npsp, nspec2v, nspec2vf, nspec2vddh, nspec2v_nh
    integer(c_int) :: nbsetsp, nfrstloff, myfrstactlat, mylstactlat, nptrfloff
    integer(c_int) :: nump, numcp, nspec, nspec2, nspec2mx
    integer(c_int) :: nflevl, nflevlmx, nflsur, ndgll, ndgsal
    integer(c_int) :: ndgenl, ndguxl, ndgunl, ngptot, ngptotg
    integer(c_int) :: ngptotmx, ngptot_cap, ngpblks, npromm, npromnh
    integer(c_int), allocatable :: numpp(:)
    integer(c_int), allocatable :: nprocm(:)
    integer(c_int), allocatable :: nptrms(:)
    integer(c_int), allocatable :: nallms(:)
    integer(c_int), allocatable :: nptrls(:)
    integer(c_int), allocatable :: nptrsv(:)
    integer(c_int), allocatable :: nptrsvf(:)
    integer(c_int), allocatable :: nptrmf(:)
    integer(c_int), allocatable :: nspstaf(:)
    integer(c_int), allocatable :: numll(:)
    integer(c_int), allocatable :: nptrll(:)
    integer(c_int), allocatable :: mylevs(:)
    integer(c_int), allocatable :: npsurf(:)
    integer(c_int), allocatable :: nptrfrstlat(:)
    integer(c_int), allocatable :: nptrlstlat(:)
    integer(c_int), allocatable :: nptrlat(:)
    integer(c_int), allocatable :: nfrstlat(:)
    integer(c_int), allocatable :: nlstlat(:)
    integer(c_int), allocatable :: nbsetlev(:)
    integer(c_int), allocatable :: nglobalindex(:)
    integer(c_int), allocatable :: nglobalat(:)
    integer(c_int), allocatable :: nglobalproc(:)
    integer(c_int), allocatable :: nlocalindex(:)
    integer(c_int), allocatable :: mylats(:)
    integer(c_int), allocatable :: npossp(:)
    integer(c_int), allocatable :: ndim0g(:)
    integer(c_int), allocatable :: nsta(:, :)
    integer(c_int), allocatable :: nonl(:, :)
    integer(c_int), allocatable :: nlatgpp(:, :)
    integer(c_int), allocatable :: nlongpp(:, :)
    integer(c_int), allocatable :: ndlunl(:, :)
    integer(c_int), allocatable :: ndluxl(:, :)
    integer(c_int), allocatable :: ngptotl(:, :)
    integer(c_int) :: my_region_ns, my_region_ew
    logical, allocatable :: lsplitlat(:)
  end type
end module forecast_distributed_partition_types
