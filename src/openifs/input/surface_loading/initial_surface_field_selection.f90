module initial_surface_field_selection_port
  !! Select the first source record for every requested surface field.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: select_initial_surface_fields, surface_parameter_codes
  integer(int32), parameter :: common_codes(47) = [139, 170, 183, 236, 39, 40, 41, 42, 35, 36, 37, 38, &
                         228008, 228009, 228010, 228011, 228012, 228013, 228014, 235, 198, 173, 174, 160, 172, 161, 162, 163, 234, &
                                                 27, 129172, 28, 200199, 29, 30, 66, 67, 43, 26, 228007, 31, 34, 74, 15, 16, 17, 18]
  integer(int32), parameter :: operational_tail(7) = [210186, 210187, 210188, 210189, 210190, 210191, 148]
  integer(int32), parameter :: snow_codes(5) = [228141, 32, 33, 238, 228038]
contains
  pure subroutine surface_parameter_codes(ordinary_count, parameters, status)
    !! Write F ordinary identifiers followed by five layered identifiers.
    !! Only F47 or50 is supported. Refusal1 leaves parameters unchanged.
    integer(int32), intent(in) :: ordinary_count
    integer(int32), intent(inout) :: parameters(:)
    integer(int32), intent(out) :: status
    status = 1
    if (ordinary_count /= 47 .and. ordinary_count /= 50) return
    if (size(parameters) /= ordinary_count + 5) return
    parameters(1:43) = common_codes(1:43)
    if (ordinary_count == 47) then
      parameters(44:47) = common_codes(44:47)
    else
      parameters(44:50) = operational_tail
    end if
    parameters(ordinary_count + 1:ordinary_count + 5) = snow_codes
    status = 0
  end subroutine
  integer(int32) function select_initial_surface_fields(values, metadata, ordinary, layered) result(status)
    !! values(N,R) and metadata(5,R) are readonly and disjoint from both
    !! contiguous outputs ordinary(N,F),layered(N,5,5). Supported N/R/F are
    !!2048/140/47 and6599680/81/50. Metadata rows are parameter, level,
    !! value count, date and time. Raw FP64 bits and units are copied.
    !! All metadata and first-match indices pass before any output changes.
    !! Return1 for shape,2 for count,3 for a missing requested record,0 for success.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: ordinary(:, :), layered(:, :, :)
    integer :: n, f, r, k, record, level, remaining, indices(75), index, source
    integer(int32) :: parameters(55), code_status
    logical :: selected
    n = size(ordinary, 1); f = size(ordinary, 2); r = size(values, 2)
    status = 1
    if (.not. ((n == 2048 .and. r == 140 .and. f == 47) .or. (n == 6599680 .and. r == 81 .and. f == 50))) return
    if (size(values, 1) /= n .or. any(shape(metadata) /= [5, r])) return
    if (any(shape(layered) /= [n, 5, 5])) return
    call surface_parameter_codes(int(f, int32), parameters(1:f + 5), code_status)
    status = 2
    do record = 1, r
      if (metadata(3, record) /= n) return
    end do
    indices = 0; remaining = f + 25
    do record = 1, r
      if (remaining == 0) exit
      selected = .false.
      do k = 1, f
        if (metadata(1, record) /= parameters(k)) cycle
        if (indices(k) == 0) then
          indices(k) = record
          remaining = remaining - 1
          selected = .true.
        end if
        exit
      end do
      if (selected) cycle
      if (metadata(2, record) < 1 .or. metadata(2, record) > 5) cycle
      level = int(metadata(2, record))
      do k = 1, 5
        if (metadata(1, record) /= snow_codes(k)) cycle
        index = f + 5*(k - 1) + level
        if (indices(index) == 0) then
          indices(index) = record
          remaining = remaining - 1
        end if
        exit
      end do
    end do
    status = 3
    if (remaining /= 0) return
    ordinary = 0.0_real64; layered = 0.0_real64
    do k = 1, f
      source = indices(k)
      ordinary(:, k) = values(:, source)
    end do
    do k = 1, 5
      do level = 1, 5
        source = indices(f + 5*(k - 1) + level)
        layered(:, level, k) = values(:, source)
      end do
    end do
    status = 0
  end function
end module
