!> Own the automatic source CPG workspace during one column call.
!! These arrays are scientific outputs of CPG children, never startup inputs.
module forecast_cpg_private_workspace
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  implicit none
  private
  public :: native_cpg_private_workspace, allocate_cpg_private_workspace, release_cpg_private_workspace
  !> Source names and physical bounds follow original CPG declarations.
  !! P is block capacity,L is level count,F is the produced NFLDSLB1.
  !! ZPRE0 retains half-level bound0. Other arrays start at1.
  !! Pressure slots follow SUINTDYN SUPTR_TXYB(true); tendencies use its
  !! hydrostatic SUPTR_TTND(false,false) order. No weather is initialized here.
  type :: native_cpg_private_workspace
    real(real64), allocatable :: zorogl(:)
    real(real64), allocatable :: zorogm(:)
    real(real64), allocatable :: zpre0(:, :)
    real(real64), allocatable :: zpre0l(:)
    real(real64), allocatable :: zpre0m(:)
    real(real64), allocatable :: zxyb0(:, :, :)
    real(real64), allocatable :: zkene0(:, :)
    real(real64), allocatable :: zatnd(:, :, :)
    real(real64), allocatable :: zqli(:, :), zqice(:, :), zqrain(:, :), zqsnow(:, :)
    real(real64), allocatable :: zgpar(:, :)
    real(real64), allocatable :: zslbuf1au(:, :)
  end type
  interface
    function source_errno() bind(C, name='__errno_location') result(a)
      import c_ptr
      type(c_ptr) :: a
    end function
  end interface
contains
  !> Acquire the source-private owner prefix without writing its payload.
  !! The admitted hydrostatic layout has seven pressure slots,five tendencies
  !! and inactive NGPAR0. Status1 frees acquired owners;status2 refuses bounds.
  subroutine allocate_cpg_private_workspace(w, p, l, f, status)
    type(native_cpg_private_workspace), intent(inout) :: w
    integer(int32), intent(in) :: p, l, f
    integer(int32), intent(out) :: status
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    integer :: code
    integer(int64) :: bytes
    status = 2
    if (p < 1 .or. p > 256 .or. l < 4 .or. l > 256 .or. f < 1 .or. f > 65536) return
    bytes = 8_int64*p*(int(f, int64) + 18_int64*l + 6_int64)
    if (bytes > 536870912_int64) return
    if (allocated(w%zorogl) .or. allocated(w%zorogm) .or. allocated(w%zpre0)) return
    if (allocated(w%zpre0l) .or. allocated(w%zpre0m) .or. allocated(w%zxyb0)) return
    if (allocated(w%zkene0) .or. allocated(w%zatnd) .or. allocated(w%zgpar)) return
    if (allocated(w%zslbuf1au) .or. allocated(w%zqli) .or. allocated(w%zqice)) return
    if (allocated(w%zqrain) .or. allocated(w%zqsnow)) return
    call c_f_pointer(source_errno(), ep); saved = ep
    allocate (w%zorogl(p), stat=code)
    if (code /= 0) goto800
    allocate (w%zorogm(p), stat=code)
    if (code /= 0) goto800
    allocate (w%zpre0(p, 0:l), stat=code)
    if (code /= 0) goto800
    allocate (w%zpre0l(p), stat=code)
    if (code /= 0) goto800
    allocate (w%zpre0m(p), stat=code)
    if (code /= 0) goto800
    allocate (w%zxyb0(p, l, 7), stat=code)
    if (code /= 0) goto800
    allocate (w%zkene0(p, l), stat=code)
    if (code /= 0) goto800
    allocate (w%zatnd(p, l, 5), stat=code)
    if (code /= 0) goto800
    allocate (w%zqli(p, l), stat=code)
    if (code /= 0) goto800
    allocate (w%zqice(p, l), stat=code)
    if (code /= 0) goto800
    allocate (w%zqrain(p, l), stat=code)
    if (code /= 0) goto800
    allocate (w%zqsnow(p, l), stat=code)
    if (code /= 0) goto800
    allocate (w%zgpar(p, 1), stat=code)
    if (code /= 0) goto800
    allocate (w%zslbuf1au(p, f), stat=code)
    if (code /= 0) goto800
    ep = saved; status = 0
    return
800 continue
    call release_cpg_private_workspace(w)
    ep = saved; status = 1
  end subroutine
  !> Release the source-private arrays only after their final CPG consumer.
  subroutine release_cpg_private_workspace(w)
    type(native_cpg_private_workspace), intent(inout) :: w
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved
    call c_f_pointer(source_errno(), ep); saved = ep
    if (allocated(w%zorogl)) deallocate (w%zorogl)
    if (allocated(w%zorogm)) deallocate (w%zorogm)
    if (allocated(w%zpre0)) deallocate (w%zpre0)
    if (allocated(w%zpre0l)) deallocate (w%zpre0l)
    if (allocated(w%zpre0m)) deallocate (w%zpre0m)
    if (allocated(w%zxyb0)) deallocate (w%zxyb0)
    if (allocated(w%zkene0)) deallocate (w%zkene0)
    if (allocated(w%zatnd)) deallocate (w%zatnd)
    if (allocated(w%zqli)) deallocate (w%zqli)
    if (allocated(w%zqice)) deallocate (w%zqice)
    if (allocated(w%zqrain)) deallocate (w%zqrain)
    if (allocated(w%zqsnow)) deallocate (w%zqsnow)
    if (allocated(w%zgpar)) deallocate (w%zgpar)
    if (allocated(w%zslbuf1au)) deallocate (w%zslbuf1au)
    ep = saved
  end subroutine
end module forecast_cpg_private_workspace
