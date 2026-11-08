!> Own the source coupling buffers and their named Fortran views.
!> Q is the local point count, T the number of tiles including tile zero's
!> source slot, and X/Y the explicit coupled-grid extents. Each owner uses one
!> contiguous FP64 payload. Views borrow this payload until its release.
module forecast_runtime_coupling_storage
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  implicit none
  private
  public :: native_coupled_field_accumulators, native_surface_coupling_diagnostics
  public :: initialize_runtime_coupled_field_accumulators, release_runtime_coupled_field_accumulators
  public :: initialize_runtime_surface_coupling_diagnostics, release_runtime_surface_coupling_diagnostics
  public :: coupled_surface_flux_inputs, accumulate_runtime_coupled_surface_fluxes
  type native_coupled_field_accumulators
    real(real64), pointer, contiguous :: payload(:) => null()
    integer(int64) :: payload_bytes = 0
    integer(int32) :: q = 0, tiles = 0, x = 0, y = 0
    logical :: ready = .false.
    real(real64), pointer, contiguous :: FCSTSU(:) => null()
    real(real64), pointer, contiguous :: FCSTSV(:) => null()
    real(real64), pointer, contiguous :: FCCHAS(:, :) => null()
    real(real64), pointer, contiguous :: FCRSOS(:, :) => null()
    real(real64), pointer, contiguous :: FCHUMS(:, :) => null()
    real(real64), pointer, contiguous :: FCRUIS(:) => null()
    real(real64), pointer, contiguous :: FCCHSS(:, :) => null()
    real(real64), pointer, contiguous :: FCHUML(:) => null()
    real(real64), pointer, contiguous :: FCHUMN(:) => null()
    real(real64), pointer, contiguous :: FCTSUR2(:) => null()
    real(real64), pointer, contiguous :: FCTSTS(:) => null()
    real(real64), pointer, contiguous :: FCTSFL(:) => null()
    real(real64), pointer, contiguous :: FCCHLL(:, :) => null()
    real(real64), pointer, contiguous :: FCCHLN(:, :) => null()
    real(real64), pointer, contiguous :: FCWIMO(:) => null()
    real(real64), pointer, contiguous :: FCSUBL(:) => null()
  end type
  type native_surface_coupling_diagnostics
    real(real64), pointer, contiguous :: payload(:) => null()
    integer(int64) :: payload_bytes = 0
    integer(int32) :: q = 0, tiles = 0, x = 0, y = 0
    logical :: ready = .false.
    real(real64), pointer, contiguous :: STRSU(:) => null()
    real(real64), pointer, contiguous :: STRSV(:) => null()
    real(real64), pointer, contiguous :: FCHAS(:, :) => null()
    real(real64), pointer, contiguous :: FRSOS(:, :) => null()
    real(real64), pointer, contiguous :: FHUMS(:, :) => null()
    real(real64), pointer, contiguous :: RUIST(:) => null()
    real(real64), pointer, contiguous :: FCHLL(:, :) => null()
    real(real64), pointer, contiguous :: FCHLN(:, :) => null()
    real(real64), pointer, contiguous :: FCHSS(:, :) => null()
    real(real64), pointer, contiguous :: FHUML(:) => null()
    real(real64), pointer, contiguous :: FHUMN(:) => null()
    real(real64), pointer, contiguous :: FRLDS(:) => null()
    real(real64), pointer, contiguous :: QWPRO(:) => null()
    real(real64), pointer, contiguous :: TMAX2(:) => null()
    real(real64), pointer, contiguous :: TMIN2(:) => null()
    real(real64), pointer, contiguous :: HSNOW(:) => null()
    real(real64), pointer, contiguous :: TSUR2(:) => null()
    real(real64), pointer, contiguous :: TSTS(:) => null()
    real(real64), pointer, contiguous :: TSFL(:) => null()
    real(real64), pointer, contiguous :: XPUQ(:) => null()
    real(real64), pointer, contiguous :: XPVQ(:) => null()
    real(real64), pointer, contiguous :: FCRFTH(:, :) => null()
    real(real64), pointer, contiguous :: FCRFSO(:, :) => null()
  end type
  type coupled_surface_flux_inputs
    real(real64), pointer, contiguous :: PSTRTU(:) => null()
    real(real64), pointer, contiguous :: PSTRTV(:) => null()
    real(real64), pointer, contiguous :: PFRTH(:) => null()
    real(real64), pointer, contiguous :: PFRSO(:) => null()
    real(real64), pointer, contiguous :: PFCLL(:) => null()
    real(real64), pointer, contiguous :: PFCLN(:) => null()
    real(real64), pointer, contiguous :: PFCS(:) => null()
    real(real64), pointer, contiguous :: PDIFTQ(:) => null()
    real(real64), pointer, contiguous :: PFPLCL(:) => null()
    real(real64), pointer, contiguous :: PFPLCN(:) => null()
    real(real64), pointer, contiguous :: PFPLSL(:) => null()
    real(real64), pointer, contiguous :: PFPLSN(:) => null()
    real(real64), pointer, contiguous :: PRUISS(:) => null()
    real(real64), pointer, contiguous :: PRUISP(:) => null()
  end type
contains
  integer(int32) function initialize_runtime_coupled_field_accumulators(state, q, ntssg, x, y, byte_limit) result(status)
    type(native_coupled_field_accumulators), intent(inout) :: state
    type(native_coupled_field_accumulators) :: pending
    integer(int32), intent(in) :: q, ntssg
    integer(int64), intent(in) :: byte_limit
    integer(int64) :: needed, count, at, part
    integer :: t, ierr
    integer(int32), intent(in) :: x, y
    status = 2
    if (q < 1 .or. ntssg < 0 .or. ntssg > 32) return
    if (byte_limit < 1_int64 .or. byte_limit > 68719476736_int64) return
    if (state%ready .or. associated(state%payload)) return
    if (associated(state%FCSTSU)) return
    if (associated(state%FCSTSV)) return
    if (associated(state%FCCHAS)) return
    if (associated(state%FCRSOS)) return
    if (associated(state%FCHUMS)) return
    if (associated(state%FCRUIS)) return
    if (associated(state%FCCHSS)) return
    if (associated(state%FCHUML)) return
    if (associated(state%FCHUMN)) return
    if (associated(state%FCTSUR2)) return
    if (associated(state%FCTSTS)) return
    if (associated(state%FCTSFL)) return
    if (associated(state%FCCHLL)) return
    if (associated(state%FCCHLN)) return
    if (associated(state%FCWIMO)) return
    if (associated(state%FCSUBL)) return
    t = ntssg + 1
    if (x < 1 .or. x > 32768 .or. y < 1 .or. y > 32768) return
    needed = 8_int64*(10_int64*q + 4_int64*q*t + 2_int64*x*y)
    pending%x = x; pending%y = y
    if (needed > byte_limit) return
    count = needed/8_int64
    allocate (pending%payload(count), stat=ierr)
    if (ierr /= 0) then
      status = 1; return
    end if
    pending%q = q; pending%tiles = t; pending%payload_bytes = needed; pending%ready = .true.
    at = 1_int64
    part = int(q, int64)
    pending%FCSTSU(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCSTSV(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCCHAS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCRSOS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCHUMS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCRUIS(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCCHSS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCHUML(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCHUMN(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCTSUR2(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCTSTS(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCTSFL(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(x, int64)*y
    pending%FCCHLL(1:x, 1:y) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(x, int64)*y
    pending%FCCHLN(1:x, 1:y) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCWIMO(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FCSUBL(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    pending%FCCHAS = 0.0_real64
    pending%FCRSOS = 0.0_real64
    pending%FCHUMS = 0.0_real64
    pending%FCCHSS = 0.0_real64
    pending%FCSTSU = 0.0_real64
    pending%FCSTSV = 0.0_real64
    pending%FCRUIS = 0.0_real64
    pending%FCHUML = 0.0_real64
    pending%FCHUMN = 0.0_real64
    pending%FCTSUR2 = 0.0_real64
    pending%FCTSTS = 0.0_real64
    pending%FCTSFL = 0.0_real64
    pending%FCWIMO = 0.0_real64
    pending%FCSUBL = 0.0_real64
    state = pending
    status = 0
  end function
  integer(int32) function release_runtime_coupled_field_accumulators(state) result(status)
    type(native_coupled_field_accumulators), intent(inout) :: state
    if (associated(state%payload)) deallocate (state%payload)
    nullify (state%payload)
    nullify (state%FCSTSU)
    nullify (state%FCSTSV)
    nullify (state%FCCHAS)
    nullify (state%FCRSOS)
    nullify (state%FCHUMS)
    nullify (state%FCRUIS)
    nullify (state%FCCHSS)
    nullify (state%FCHUML)
    nullify (state%FCHUMN)
    nullify (state%FCTSUR2)
    nullify (state%FCTSTS)
    nullify (state%FCTSFL)
    nullify (state%FCCHLL)
    nullify (state%FCCHLN)
    nullify (state%FCWIMO)
    nullify (state%FCSUBL)
    state%ready = .false.; state%payload_bytes = 0_int64
    status = 0
  end function
  integer(int32) function initialize_runtime_surface_coupling_diagnostics(state, q, ntssg, byte_limit) result(status)
    type(native_surface_coupling_diagnostics), intent(inout) :: state
    type(native_surface_coupling_diagnostics) :: pending
    integer(int32), intent(in) :: q, ntssg
    integer(int64), intent(in) :: byte_limit
    integer(int64) :: needed, count, at, part
    integer :: t, ierr
    status = 2
    if (q < 1 .or. ntssg < 0 .or. ntssg > 32) return
    if (byte_limit < 1_int64 .or. byte_limit > 68719476736_int64) return
    if (state%ready .or. associated(state%payload)) return
    if (associated(state%STRSU)) return
    if (associated(state%STRSV)) return
    if (associated(state%FCHAS)) return
    if (associated(state%FRSOS)) return
    if (associated(state%FHUMS)) return
    if (associated(state%RUIST)) return
    if (associated(state%FCHLL)) return
    if (associated(state%FCHLN)) return
    if (associated(state%FCHSS)) return
    if (associated(state%FHUML)) return
    if (associated(state%FHUMN)) return
    if (associated(state%FRLDS)) return
    if (associated(state%QWPRO)) return
    if (associated(state%TMAX2)) return
    if (associated(state%TMIN2)) return
    if (associated(state%HSNOW)) return
    if (associated(state%TSUR2)) return
    if (associated(state%TSTS)) return
    if (associated(state%TSFL)) return
    if (associated(state%XPUQ)) return
    if (associated(state%XPVQ)) return
    if (associated(state%FCRFTH)) return
    if (associated(state%FCRFSO)) return
    t = ntssg + 1
    needed = 8_int64*q*(19_int64 + 6_int64*t)
    if (needed > byte_limit) return
    count = needed/8_int64
    allocate (pending%payload(count), stat=ierr)
    if (ierr /= 0) then
      status = 1; return
    end if
    pending%q = q; pending%tiles = t; pending%payload_bytes = needed; pending%ready = .true.
    at = 1_int64
    part = int(q, int64)
    pending%STRSU(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%STRSV(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCHAS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FRSOS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FHUMS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%RUIST(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCHLL(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCHLN(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)*t
    pending%FCHSS(1:q, 1:t) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FHUML(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FHUMN(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%FRLDS(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%QWPRO(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%TMAX2(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%TMIN2(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%HSNOW(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%TSUR2(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%TSTS(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%TSFL(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%XPUQ(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = int(q, int64)
    pending%XPVQ(1:q) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = 2_int64*q
    pending%FCRFTH(1:q, 0:1) => pending%payload(at:at + part - 1_int64)
    at = at + part
    part = 2_int64*q
    pending%FCRFSO(1:q, 0:1) => pending%payload(at:at + part - 1_int64)
    at = at + part
    pending%STRSU = 0.0_real64
    pending%STRSV = 0.0_real64
    pending%FCHAS = 0.0_real64
    pending%FRSOS = 0.0_real64
    pending%FHUMS = 0.0_real64
    pending%RUIST = 0.0_real64
    pending%FCHLL = 0.0_real64
    pending%FCHLN = 0.0_real64
    pending%FCHSS = 0.0_real64
    pending%FHUML = 0.0_real64
    pending%FHUMN = 0.0_real64
    pending%FRLDS = 0.0_real64
    pending%QWPRO = 0.0_real64
    pending%TMAX2 = -1000.0_real64
    pending%TMIN2 = 1000.0_real64
    pending%HSNOW = 0.0_real64
    pending%TSUR2 = 0.0_real64
    pending%TSTS = 0.0_real64
    pending%TSFL = 0.0_real64
    pending%XPUQ = 0.0_real64
    pending%XPVQ = 0.0_real64
    pending%FCRFTH = 0.0_real64
    pending%FCRFSO = 0.0_real64
    state = pending
    status = 0
  end function
  integer(int32) function release_runtime_surface_coupling_diagnostics(state) result(status)
    type(native_surface_coupling_diagnostics), intent(inout) :: state
    if (associated(state%payload)) deallocate (state%payload)
    nullify (state%payload)
    nullify (state%STRSU)
    nullify (state%STRSV)
    nullify (state%FCHAS)
    nullify (state%FRSOS)
    nullify (state%FHUMS)
    nullify (state%RUIST)
    nullify (state%FCHLL)
    nullify (state%FCHLN)
    nullify (state%FCHSS)
    nullify (state%FHUML)
    nullify (state%FHUMN)
    nullify (state%FRLDS)
    nullify (state%QWPRO)
    nullify (state%TMAX2)
    nullify (state%TMIN2)
    nullify (state%HSNOW)
    nullify (state%TSUR2)
    nullify (state%TSTS)
    nullify (state%TSFL)
    nullify (state%XPUQ)
    nullify (state%XPVQ)
    nullify (state%FCRFTH)
    nullify (state%FCRFSO)
    state%ready = .false.; state%payload_bytes = 0_int64
    status = 0
  end function
  !> Integrate stress, runoff, water and heat fluxes over dt seconds.
  !> Input vectors have P cells, bound1, and may alias one another; they must
  !> stay separate from the owner payload. Output point is global_start+j-1.
  integer(int32) function accumulate_runtime_coupled_surface_fluxes(state, dt, p, first, last, global_start, input) result(status)
    type(native_surface_coupling_diagnostics), intent(inout) :: state
    real(real64), intent(in) :: dt
    integer(int32), intent(in) :: p, first, last, global_start
    type(coupled_surface_flux_inputs), intent(in) :: input
    integer(int64) :: word, magnitude, base, finish, address, bytes
    integer :: j, g
    real(real64), volatile :: term, product
    status = 2
    if (.not. state%ready .or. .not. associated(state%payload)) return
    if (state%q < 1 .or. state%tiles < 1) return
    bytes = 8_int64*state%q*(19_int64 + 6_int64*state%tiles)
    if (state%payload_bytes /= bytes) return
    if (size(state%payload, kind=int64) /= bytes/8_int64) return
    if (p < 1 .or. p > 128 .or. first < 1 .or. first > p + 1 .or. last < 0 .or. last > p .or. global_start < 1) return
    if (first <= last) then
      if (int(global_start, int64) + last - 1_int64 > state%q) return
    end if
    word = transfer(dt, 0_int64); magnitude = iand(word, huge(0_int64))
    if (btest(word, 63) .and. magnitude /= 0_int64) return
    if (magnitude > int(z'40d5180000000000', int64)) return
    base = int(transfer(c_loc(state%payload(1)), 0_c_intptr_t), int64)
    finish = base + bytes
    if (.not. associated(input%PSTRTU)) return
    if (.not. is_contiguous(input%PSTRTU)) return
    if (lbound(input%PSTRTU, 1) /= 1 .or. size(input%PSTRTU, kind=int64) < p) return
    address = int(transfer(c_loc(input%PSTRTU(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PSTRTV)) return
    if (.not. is_contiguous(input%PSTRTV)) return
    if (lbound(input%PSTRTV, 1) /= 1 .or. size(input%PSTRTV, kind=int64) < p) return
    address = int(transfer(c_loc(input%PSTRTV(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFRTH)) return
    if (.not. is_contiguous(input%PFRTH)) return
    if (lbound(input%PFRTH, 1) /= 1 .or. size(input%PFRTH, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFRTH(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFRSO)) return
    if (.not. is_contiguous(input%PFRSO)) return
    if (lbound(input%PFRSO, 1) /= 1 .or. size(input%PFRSO, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFRSO(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFCLL)) return
    if (.not. is_contiguous(input%PFCLL)) return
    if (lbound(input%PFCLL, 1) /= 1 .or. size(input%PFCLL, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFCLL(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFCLN)) return
    if (.not. is_contiguous(input%PFCLN)) return
    if (lbound(input%PFCLN, 1) /= 1 .or. size(input%PFCLN, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFCLN(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFCS)) return
    if (.not. is_contiguous(input%PFCS)) return
    if (lbound(input%PFCS, 1) /= 1 .or. size(input%PFCS, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFCS(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PDIFTQ)) return
    if (.not. is_contiguous(input%PDIFTQ)) return
    if (lbound(input%PDIFTQ, 1) /= 1 .or. size(input%PDIFTQ, kind=int64) < p) return
    address = int(transfer(c_loc(input%PDIFTQ(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFPLCL)) return
    if (.not. is_contiguous(input%PFPLCL)) return
    if (lbound(input%PFPLCL, 1) /= 1 .or. size(input%PFPLCL, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFPLCL(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFPLCN)) return
    if (.not. is_contiguous(input%PFPLCN)) return
    if (lbound(input%PFPLCN, 1) /= 1 .or. size(input%PFPLCN, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFPLCN(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFPLSL)) return
    if (.not. is_contiguous(input%PFPLSL)) return
    if (lbound(input%PFPLSL, 1) /= 1 .or. size(input%PFPLSL, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFPLSL(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PFPLSN)) return
    if (.not. is_contiguous(input%PFPLSN)) return
    if (lbound(input%PFPLSN, 1) /= 1 .or. size(input%PFPLSN, kind=int64) < p) return
    address = int(transfer(c_loc(input%PFPLSN(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PRUISS)) return
    if (.not. is_contiguous(input%PRUISS)) return
    if (lbound(input%PRUISS, 1) /= 1 .or. size(input%PRUISS, kind=int64) < p) return
    address = int(transfer(c_loc(input%PRUISS(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(input%PRUISP)) return
    if (.not. is_contiguous(input%PRUISP)) return
    if (lbound(input%PRUISP, 1) /= 1 .or. size(input%PRUISP, kind=int64) < p) return
    address = int(transfer(c_loc(input%PRUISP(1)), 0_c_intptr_t), int64)
    if (address < finish .and. address + 8_int64*p > base) return
    if (.not. associated(state%STRSU)) return
    if (.not. is_contiguous(state%STRSU)) return
    if (lbound(state%STRSU, 1) /= 1 .or. size(state%STRSU, 1, kind=int64) < state%q) return
    address = int(transfer(c_loc(state%STRSU(1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%STRSV)) return
    if (.not. is_contiguous(state%STRSV)) return
    if (lbound(state%STRSV, 1) /= 1 .or. size(state%STRSV, 1, kind=int64) < state%q) return
    address = int(transfer(c_loc(state%STRSV(1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%RUIST)) return
    if (.not. is_contiguous(state%RUIST)) return
    if (lbound(state%RUIST, 1) /= 1 .or. size(state%RUIST, 1, kind=int64) < state%q) return
    address = int(transfer(c_loc(state%RUIST(1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FHUML)) return
    if (.not. is_contiguous(state%FHUML)) return
    if (lbound(state%FHUML, 1) /= 1 .or. size(state%FHUML, 1, kind=int64) < state%q) return
    address = int(transfer(c_loc(state%FHUML(1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FHUMN)) return
    if (.not. is_contiguous(state%FHUMN)) return
    if (lbound(state%FHUMN, 1) /= 1 .or. size(state%FHUMN, 1, kind=int64) < state%q) return
    address = int(transfer(c_loc(state%FHUMN(1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FRSOS)) return
    if (.not. is_contiguous(state%FRSOS)) return
    if (lbound(state%FRSOS, 1) /= 1 .or. size(state%FRSOS, 1, kind=int64) < state%q) return
    if (lbound(state%FRSOS, 2) > 1 .or. ubound(state%FRSOS, 2) < 1) return
    address = int(transfer(c_loc(state%FRSOS(1, 1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FCHLL)) return
    if (.not. is_contiguous(state%FCHLL)) return
    if (lbound(state%FCHLL, 1) /= 1 .or. size(state%FCHLL, 1, kind=int64) < state%q) return
    if (lbound(state%FCHLL, 2) > 1 .or. ubound(state%FCHLL, 2) < 1) return
    address = int(transfer(c_loc(state%FCHLL(1, 1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FCHLN)) return
    if (.not. is_contiguous(state%FCHLN)) return
    if (lbound(state%FCHLN, 1) /= 1 .or. size(state%FCHLN, 1, kind=int64) < state%q) return
    if (lbound(state%FCHLN, 2) > 1 .or. ubound(state%FCHLN, 2) < 1) return
    address = int(transfer(c_loc(state%FCHLN(1, 1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FCHSS)) return
    if (.not. is_contiguous(state%FCHSS)) return
    if (lbound(state%FCHSS, 1) /= 1 .or. size(state%FCHSS, 1, kind=int64) < state%q) return
    if (lbound(state%FCHSS, 2) > 1 .or. ubound(state%FCHSS, 2) < 1) return
    address = int(transfer(c_loc(state%FCHSS(1, 1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FCHAS)) return
    if (.not. is_contiguous(state%FCHAS)) return
    if (lbound(state%FCHAS, 1) /= 1 .or. size(state%FCHAS, 1, kind=int64) < state%q) return
    if (lbound(state%FCHAS, 2) > 1 .or. ubound(state%FCHAS, 2) < 1) return
    address = int(transfer(c_loc(state%FCHAS(1, 1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    if (.not. associated(state%FHUMS)) return
    if (.not. is_contiguous(state%FHUMS)) return
    if (lbound(state%FHUMS, 1) /= 1 .or. size(state%FHUMS, 1, kind=int64) < state%q) return
    if (lbound(state%FHUMS, 2) > 1 .or. ubound(state%FHUMS, 2) < 1) return
    address = int(transfer(c_loc(state%FHUMS(1, 1)), 0_c_intptr_t), int64)
    if (address < base .or. address + 8_int64*state%q > finish) return
    do j = first, last
      g = global_start + j - 1
      term = input%PSTRTU(j)
      product = term*dt
      state%STRSU(g) = state%STRSU(g) + product
      term = input%PSTRTV(j)
      product = term*dt
      state%STRSV(g) = state%STRSV(g) + product
      term = input%PRUISS(j)
      term = term + input%PRUISP(j)
      product = term*dt
      state%RUIST(g) = state%RUIST(g) + product
      term = input%PFPLCL(j)
      term = term + input%PFPLSL(j)
      product = term*dt
      state%FHUML(g) = state%FHUML(g) + product
      term = input%PFPLCN(j)
      term = term + input%PFPLSN(j)
      product = term*dt
      state%FHUMN(g) = state%FHUMN(g) + product
      term = input%PFRSO(j)
      product = term*dt
      state%FRSOS(g, 1) = state%FRSOS(g, 1) + product
      term = input%PFCLL(j)
      product = term*dt
      state%FCHLL(g, 1) = state%FCHLL(g, 1) + product
      term = input%PFCLN(j)
      product = term*dt
      state%FCHLN(g, 1) = state%FCHLN(g, 1) + product
      term = input%PFCS(j)
      product = term*dt
      state%FCHSS(g, 1) = state%FCHSS(g, 1) + product
      term = input%PFRTH(j)
      term = term + input%PFCLL(j)
      term = term + input%PFCLN(j)
      term = term + input%PFCS(j)
      product = term*dt
      state%FCHAS(g, 1) = state%FCHAS(g, 1) + product
      term = input%PFPLCL(j)
      term = term + input%PFPLCN(j)
      term = term + input%PFPLSL(j)
      term = term + input%PFPLSN(j)
      term = term + input%PDIFTQ(j)
      product = term*dt
      state%FHUMS(g, 1) = state%FHUMS(g, 1) + product
    end do
    status = 0
  end function
end module forecast_runtime_coupling_storage
