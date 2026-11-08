!> Borrow actual transform table owners and own only controller work buffers.
module forecast_native_transform_controller_state
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_transform_types, only: transform_fourier_layout, transform_spectral_tables
  use md2asm_inverse_spectral_transform, only: inverse_spectral_preparation
  implicit none
  private
  public :: native_transform_controller_state, serial_transform_ready, ensure_transform_buffer
  type :: native_transform_controller_state
    type(transform_fourier_layout), pointer :: layout => null()
    type(transform_spectral_tables), pointer :: spectral => null()
    type(inverse_spectral_preparation), pointer :: inverse => null()
    ! These dimensionless values are readonly projections of the actual public setup.
    integer(int32) :: nproc = 0, myproc = 0, nprtrns = 0, mysetw = 0, mysetv = 0, region_ns = 0, region_ew = 0
    integer(int32) :: nproma = 0, ngpblks = 0, ndgl_fs = 0, ndgl_gp = 0, nlengt_f = 0, nlengt0b = 0
    integer(int32) :: nfrstloff = 0, nptrfloff = 0, ngptot = 0, ntrans_sync_level = 0
    integer(int32) :: nf_sc2 = 0, nf_sc3a = 0, nf_sc3b = 0
    logical :: latlon = .false., luvder = .false., lvorgp = .false., ldivgp = .false., lscders = .false.
    logical :: lgpnorm = .false., lalloperm = .false., ldll = .false.
    integer(int32), pointer :: nfrstlat(:) => null(), nlstlat(:) => null(), nptrfrstlat(:) => null(), nultpp(:) => null()
    integer(int32), pointer :: nsta(:, :) => null(), nonl(:, :) => null(), myms(:) => null()
    integer(int32), pointer :: nltsgtb(:) => null(), nstagt0b(:) => null(), nstagt1b(:) => null()
    real(real64), pointer :: racthe(:) => null(), weights(:) => null()
    ! Buffers replace the original two allocatable module variables. Other tables are borrowed.
    real(real64), allocatable :: foubuf(:), foubuf_in(:)
  end type
contains
!> Check the selected serial route without changing fields, flags or table owners.
  logical function serial_transform_ready(c)
    type(native_transform_controller_state), intent(in) :: c
    serial_transform_ready = .false.
    if (.not. associated(c%layout)) return
    if (c%nproc /= 1 .or. c%myproc /= 1 .or. c%nprtrns /= 1 .or. c%mysetw /= 1 .or. c%mysetv /= 1) return
    if (c%region_ns /= 1 .or. c%region_ew /= 1) return
    if (c%ndgl_fs /= 32 .or. c%nlengt_f /= 2144 .or. c%latlon) return
    serial_transform_ready = .true.
  end function
!> Retain capacity; on growth release first, then allocate native real64 words.
!! Status 0 succeeds, 1 means allocation failure. First-only zeroing follows LTINV_CTL.
  subroutine ensure_transform_buffer(buffer, words, zero_first, status)
    real(real64), allocatable, intent(inout) :: buffer(:)
    integer(int64), intent(in) :: words
    logical, intent(in) :: zero_first
    integer(int32), intent(out) :: status
    logical :: first
    integer :: a
    integer(int64) :: n
    status = 2
    n = max(1_int64, words)
    if (words < 0 .or. n > huge(1_int32)) return
    first = .not. allocated(buffer)
    if (allocated(buffer)) then
      if (size(buffer, kind=int64) >= n) then
        status = 0; return
      end if
      deallocate (buffer)
    end if
    allocate (buffer(n), stat=a)
    if (a /= 0) then
      status = 1; return
    end if
    if (first .and. zero_first) buffer = 0.0_real64
    status = 0
  end subroutine
end module
