!> Own the Fullpos point distribution through canonical TFPGEO arrays.
module forecast_fullpos_distribution
  use iso_fortran_env, only: int32, int64
  use yomfpgeo, only: tfpgeo
  implicit none
  private
  public :: initialize_native_fullpos_distribution, release_native_fullpos_distribution
contains
  !> Assign each global point to its explicit one-based owner process.
 !! rank_map has one word per global point. KPROMA is a signed requested block
 !! width. Negative widths stay exact; positive widths become odd, as in SUMPFPOS.
 !! Status2 retains output. Status1 releases only the three newly acquired arrays.
  integer(int32) function initialize_native_fullpos_distribution(rank_map, processes, rank, kproma, output, budget) result(status)
    integer(int32), intent(in) :: rank_map(:), processes, rank, kproma
    type(tfpgeo), intent(inout) :: output
    integer(int64), intent(in) :: budget
    integer(int32), allocatable :: counts(:), indices(:, :), ends(:), positions(:)
    integer :: n, maximum, local, width, blocks, j, proc, ierr
    status = 2; n = size(rank_map)
    if (n < 1 .or. processes < 1 .or. processes > 4096 .or. rank < 1 .or. rank > processes) return
    if (kproma == 0 .or. kproma == -huge(kproma) - 1) return
    if (any(rank_map < 1) .or. any(rank_map > processes)) return
    if (allocated(output%nfprgpnum) .or. allocated(output%nfprgpind) .or. allocated(output%nfpend)) return
    allocate (counts(processes), stat=ierr); if (ierr /= 0) goto900
    do j = 1, processes
      counts(j) = count(rank_map == j)
    end do
    local = counts(rank); maximum = maxval(counts)
    if (4_int64*maximum*processes + 8_int64*processes + 4_int64*max(1, local) > budget) goto910
    allocate (indices(maximum, processes), stat=ierr); if (ierr /= 0) goto900
    if (processes == 1) then
    do j = 1, n
      indices(j, 1) = j
    end do
    else
    indices = huge(0_int32)
    allocate (positions(processes), stat=ierr); if (ierr /= 0) goto900
    positions = 0
    do j = 1, n
      proc = rank_map(j); positions(proc) = positions(proc) + 1
      indices(positions(proc), proc) = j
    end do
    deallocate (positions)
    end if
    if (kproma < 0) then
      width = -kproma
    else
      width = kproma + 1 - mod(kproma, 2)
    end if
    width = max(1, min(width, local))
    blocks = 0
    if (local > 0) blocks = (local - 1)/width + 1
    allocate (ends(blocks), stat=ierr); if (ierr /= 0) goto900
    do j = 1, blocks - 1
      ends(j) = width
    end do
    if (blocks > 0) ends(blocks) = local - width*(blocks - 1)
    call move_alloc(counts, output%nfprgpnum)
    call move_alloc(indices, output%nfprgpind)
    call move_alloc(ends, output%nfpend)
    output%nfprgpl = local; output%nfprgplx = maximum
    output%nfproma = width; output%nfpblocs = blocks
    status = 0; return
910 status = 2; return
900 status = 1
  end function
  !> Release only the three owners acquired by SUMPFPOS, in source order.
  subroutine release_native_fullpos_distribution(output)
    type(tfpgeo), intent(inout) :: output
    if (allocated(output%nfprgpnum)) deallocate (output%nfprgpnum)
    if (allocated(output%nfprgpind)) deallocate (output%nfprgpind)
    if (allocated(output%nfpend)) deallocate (output%nfpend)
  end subroutine
end module
