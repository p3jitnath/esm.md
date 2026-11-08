!> Borrow named atmospheric arrays without original descriptor offsets.
module forecast_physics_state_views
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: physics_state_views, copy_runtime_physics_state
!> Fields keep their original units; no numerical owner is allocated here.
!! U/V use m/s, T uses K, mass fractions kg/kg, and ECT m2/s2.
!! Each associated field has bounds1:P,1:L; cloud water adds4:64 components.
  type physics_state_views
    logical :: lq = .false., lo3 = .false., la = .false.
    logical :: lliquid = .false., lice = .false., lrain = .false., lsnow = .false., lect = .false.
    real(real64), pointer, contiguous :: u(:, :) => null(), v(:, :) => null(), t(:, :) => null()
    real(real64), pointer, contiguous :: q(:, :) => null(), o3(:, :) => null(), a(:, :) => null(), ect(:, :) => null()
    real(real64), pointer, contiguous :: clv(:, :, :) => null()
  end type
contains
!> Copy all enabled active source fields, preserving inactive cells and flags.
!! Output masks select the fields. Input masks are not used by STATE_COPY.
!! PROFILING must be false. Shapes/masks are checked before any field write.
  integer(int32) function copy_runtime_physics_state(pitch, first, last, levels, input, output, profiling) result(status)
    integer(int32), intent(in) :: pitch, first, last, levels
    type(physics_state_views), intent(in) :: input
    type(physics_state_views), intent(inout) :: output
    logical, intent(in) :: profiling
    integer :: column, level
    status = 2
    if (profiling .or. pitch < 1 .or. pitch > 1024 .or. levels < 0 .or. levels > 512) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (.not. valid_pair(input%u, output%u, pitch, levels)) return
    if (.not. valid_pair(input%v, output%v, pitch, levels)) return
    if (.not. valid_pair(input%t, output%t, pitch, levels)) return
    if (output%lo3) then
      if (.not. valid_pair(input%o3, output%o3, pitch, levels)) return
    end if
    if (output%lq) then
      if (.not. valid_pair(input%q, output%q, pitch, levels)) return
    end if
    if (output%la) then
      if (.not. valid_pair(input%a, output%a, pitch, levels)) return
    end if
    if (output%lect) then
      if (.not. valid_pair(input%ect, output%ect, pitch, levels)) return
    end if
    if (output%lliquid .or. output%lice .or. output%lrain .or. output%lsnow) then
      if (.not. associated(input%clv) .or. .not. associated(output%clv)) return
      if (any(lbound(input%clv) /= 1) .or. any(lbound(output%clv) /= 1)) return
      if (size(input%clv, 1) /= pitch .or. size(input%clv, 2) /= levels) return
      if (size(output%clv, 1) /= pitch .or. size(output%clv, 2) /= levels) return
      if (size(input%clv, 3) < 4 .or. size(input%clv, 3) > 64) return
      if (size(output%clv, 3) < 4 .or. size(output%clv, 3) > 64) return
    end if
    do level = 1, levels
      do column = first, last
        output%u(column, level) = input%u(column, level)
      end do
      do column = first, last
        output%v(column, level) = input%v(column, level)
      end do
      do column = first, last
        output%t(column, level) = input%t(column, level)
      end do
      if (output%lo3) then
        do column = first, last
          output%o3(column, level) = input%o3(column, level)
        end do
      end if
      if (output%lq) then
        do column = first, last
          output%q(column, level) = input%q(column, level)
        end do
      end if
      if (output%la) then
        do column = first, last
          output%a(column, level) = input%a(column, level)
        end do
      end if
      if (output%lliquid) then
        do column = first, last
          output%clv(column, level, 1) = input%clv(column, level, 1)
        end do
      end if
      if (output%lice) then
        do column = first, last
          output%clv(column, level, 2) = input%clv(column, level, 2)
        end do
      end if
      if (output%lrain) then
        do column = first, last
          output%clv(column, level, 3) = input%clv(column, level, 3)
        end do
      end if
      if (output%lsnow) then
        do column = first, last
          output%clv(column, level, 4) = input%clv(column, level, 4)
        end do
      end if
      if (output%lect) then
        do column = first, last
          output%ect(column, level) = input%ect(column, level)
        end do
      end if
    end do
    status = 0
  end function
  logical function valid_pair(input, output, pitch, levels) result(valid)
    real(real64), pointer, contiguous, intent(in) :: input(:, :), output(:, :)
    integer(int32), intent(in) :: pitch, levels
    valid = .false.
    if (.not. associated(input) .or. .not. associated(output)) return
    if (any(lbound(input) /= 1) .or. any(lbound(output) /= 1)) return
    if (size(input, 1) /= pitch .or. size(output, 1) /= pitch) return
    if (size(input, 2) /= levels .or. size(output, 2) /= levels) return
    valid = .true.
  end function
end module
