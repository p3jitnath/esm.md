module spline_operator_components
  !! Native spline pieces and matrices. All real coordinates are dimensionless FP64.
  use iso_c_binding, only: c_int, c_double, c_int64_t
  use spline_polynomial_operations
  use vertical_spline_basis_port, only: evaluate_spline_basis
  use vertical_interval_coordinate_port, only: interval_coordinate
  implicit none
  private
  public :: piece_coefficients, value_boundaries, evaluation_matrix, operator_matrix
  public :: knot_intervals, spline_interval
  type, bind(C) :: spline_interval
    real(c_double) :: lower, upper, width
    integer(c_int) :: input_index, weight_index
  end type
contains
  function piece_coefficients(transform, knots, minimum_interval, pieces, centres) result(status)
    !! Read knots and a sampling transform; replace all basis-by-4-by-4 pieces and centres.
    real(c_double), intent(in) :: transform(4, 4), knots(:), minimum_interval
    real(c_double), intent(inout) :: pieces(:, :, :), centres(:)
    integer(c_int) :: status, child
    integer :: n, interval, sample, basis, degree, k, first, last
    real(c_double) :: local_samples(4), weights(size(pieces, 1)), samples(4, size(pieces, 1))
    real(c_double) :: width, coordinate, value, term, total
    status = 2
    n = size(pieces, 1)
    if (.not. valid_basis(n)) return
    if (size(pieces, 2) /= 4 .or. size(pieces, 3) /= 4) return
    if (size(knots) /= n + 4 .or. size(centres) /= n) return
    if (.not. finite_real(minimum_interval)) return
    if (minimum_interval < 0.0_c_double) return
    pieces = 0.0_c_double
    do sample = 1, 4
      local_samples(sample) = spline_sample_position(4_c_int, int(sample, c_int), [0.0_c_double, 1.0_c_double])
    end do
    do interval = 1, n + 3
      width = knots(interval + 1) - knots(interval)
      if (abs(width) <= minimum_interval) cycle
      do sample = 1, 4
        coordinate = coordinate_from_local(knots(interval), knots(interval + 1), local_samples(sample))
        child = evaluate_spline_basis(4_c_int, coordinate, int(n, c_int), knots, weights)
        if (child /= 0) then
          status = 3
          return
        end if
        do basis = 1, n
          samples(sample, basis) = weights(basis)
        end do
      end do
      first = max(interval - 3, 1)
      last = min(interval, n)
      do basis = first, last
        do degree = 1, 4
          value = 0.0_c_double
          do k = 1, 4
            term = transform(degree, k)*samples(k, basis)
            value = value + term
          end do
          pieces(basis, interval - basis + 1, degree) = value
        end do
      end do
    end do
    do basis = 1, n
      total = 0.0_c_double
      do k = 1, 3
        total = total + knots(basis + k)
      end do
      centres(basis) = total/3.0_c_double
    end do
    status = 0
  end function
  function value_boundaries(top, bottom, pieces) result(status)
    integer(c_int), intent(in) :: top, bottom
    real(c_double), intent(inout) :: pieces(:, :, :)
    integer(c_int) :: status
    integer :: n, interval, degree
    status = 2
    n = size(pieces, 1)
    if (.not. valid_basis(n)) return
    if (size(pieces, 2) /= 4 .or. size(pieces, 3) /= 4) return
    if (top < 0 .or. top > 1 .or. bottom < 0 .or. bottom > 1) return
    do degree = 1, 4
      do interval = 1, 4
        if (top == 1) pieces(1, interval, degree) = 0.0_c_double
        if (bottom == 1) pieces(n, interval, degree) = 0.0_c_double
      end do
    end do
    status = 0
  end function
  function evaluation_matrix(offset, points, types, knots, pieces, matrix) result(status)
    integer(c_int), intent(in) :: offset, types(:)
    real(c_double), intent(in) :: points(:), knots(:), pieces(:, :, :)
    real(c_double), intent(inout) :: matrix(:, :)
    integer(c_int) :: status
    integer :: n, dimension, rows, i, j, interval, chosen, first, last, column
    real(c_double) :: width, inverse_width, coordinate, coefficients(4), derivative(3), value
    status = 2
    n = size(pieces, 1); rows = size(points); dimension = size(matrix, 2)
    if (dimension /= 21 .and. dimension /= 139) return
    if (size(matrix, 1) /= rows .or. size(types) /= rows) return
    if (size(pieces, 2) /= 4 .or. size(pieces, 3) /= 4 .or. size(knots) /= n + 4) return
    if (dimension == 21) then
      if (rows < 19 .or. rows > 21 .or. n < 21 .or. n > 24) return
      if (offset < 0 .or. offset > n - 21) return
    else
      if (rows == 139) then
        if (n /= 139 .or. offset /= 0) return
      else if (rows == 138) then
        if (n /= 140 .or. offset /= 1) return
      else if (rows == 137) then
        if (n == 139) then
          if (offset /= 0) return
        else if (n == 140) then
          if (offset < 0 .or. offset > 1) return
        else
          return
        end if
      else
        return
      end if
    end if
    if (any(types < 0) .or. any(types > 1)) return
    if (any(.not. finite_real(points))) return
    if (any(points < 0.0_c_double) .or. any(points > 1.0_c_double)) return
    if (.not. valid_knots(knots)) return
    if (any(transfer(knots(1:4), [0_c_int64_t, 0_c_int64_t, 0_c_int64_t, 0_c_int64_t]) /= 0_c_int64_t)) return
    if (any(knots(n + 1:n + 4) /= 1.0_c_double)) return
    matrix = 0.0_c_double
    do i = 1, rows
      chosen = -1
      do interval = 1, n + 3
        width = knots(interval + 1) - knots(interval)
        if (abs(width) <= 0.0_c_double) cycle
        if (points(i) < knots(interval) .or. points(i) > knots(interval + 1)) cycle
        chosen = interval
      end do
      first = max(offset + 1, chosen - 3)
      last = min(offset + dimension, chosen)
      width = knots(chosen + 1) - knots(chosen)
      inverse_width = 1.0_c_double/width
      coordinate = interval_coordinate(knots(chosen), knots(chosen + 1), points(i))
      do j = first, last
        coefficients = pieces(j, chosen - j + 1, :)
        if (types(i) == 0) then
          value = polynomial_value(coefficients, coordinate)
        else
          derivative = 0.0_c_double
          call polynomial_derivative(coefficients, derivative)
          value = polynomial_value(derivative, coordinate)
          value = value*inverse_width
        end if
        column = j - offset
        matrix(i, column) = value
      end do
    end do
    status = 0
  end function
  function knot_intervals(input_knots, weight_knots, threshold, records, record_count) result(status)
    real(c_double), intent(in) :: input_knots(:), weight_knots(:), threshold
    type(spline_interval), intent(inout) :: records(:)
    integer(c_int), intent(inout) :: record_count
    integer(c_int) :: status
    integer :: ni, nw, i, j, count
    real(c_double) :: current, next, width
    status = 2
    ni = size(input_knots); nw = size(weight_knots)
    if (ni >= 25 .and. ni <= 28) then
      if (nw < 25 .or. nw > 28) return
    else if (ni == 143 .or. ni == 144) then
      if (nw < 143 .or. nw > 144) return
      if (ni == 144 .and. nw /= 144) return
    else
      return
    end if
    if (size(records) < ni + nw - 1) return
    if (.not. valid_knots(input_knots) .or. .not. valid_knots(weight_knots)) return
    if (.not. finite_real(threshold)) return
    if (btest(transfer(threshold, 0_c_int64_t), 63)) return
    i = 1; j = 1; count = 0; current = 0.0_c_double
    do
      do while (i <= ni)
        if (transfer(input_knots(i), 0_c_int64_t) /= transfer(current, 0_c_int64_t)) exit
        i = i + 1
      end do
      do while (j <= nw)
        if (transfer(weight_knots(j), 0_c_int64_t) /= transfer(current, 0_c_int64_t)) exit
        j = j + 1
      end do
      if (i > ni) then
        if (j > nw) exit
        next = weight_knots(j)
      else
        next = input_knots(i)
        if (j <= nw) then
          if (weight_knots(j) < next) next = weight_knots(j)
        end if
      end if
      width = next - current
      if (abs(width) > threshold) then
        count = count + 1
        records(count)%lower = current
        records(count)%upper = next
        records(count)%width = width
        records(count)%input_index = int(i - 1, c_int)
        records(count)%weight_index = int(j - 1, c_int)
      end if
      current = next
    end do
    record_count = int(count, c_int)
    status = 0
  end function
  function operator_matrix(kind, input_offset, weight_offset, input_transform, weight_transform, &
                           input_knots, weight_knots, input_pieces, weight_pieces, matrix) result(status)
    integer(c_int), intent(in) :: kind, input_offset, weight_offset
    real(c_double), intent(in) :: input_transform(4, 4), weight_transform(4, 4)
    real(c_double), intent(in) :: input_knots(:), weight_knots(:), input_pieces(:, :, :), weight_pieces(:, :, :)
    real(c_double), intent(inout) :: matrix(:, :)
    integer(c_int) :: status, child, count
    type(spline_interval) :: records(size(input_knots) + size(weight_knots) - 1)
    integer :: ni, nw, dim, total, step, record, ib, wb, ifirst, ilast, wfirst, wlast, row, col
    real(c_double) :: cumulative_input(size(input_pieces, 1), size(input_knots) + size(weight_knots))
    real(c_double) :: input_amount(size(input_pieces, 1)), weight_amount(size(weight_pieces, 1))
    real(c_double), volatile :: cumulative_weight(size(weight_pieces, 1), size(input_knots) + size(weight_knots))
    real(c_double) :: ibounds(2), wbounds(2), iwidth, wwidth, width
    real(c_double) :: coeff(4), integral(5), local_input(4), local_weight(4)
    real(c_double) :: low, high, difference, contribution, term
    real(c_double), volatile :: discarded_widths(2)
    status = 2
    ni = size(input_pieces, 1); nw = size(weight_pieces, 1); dim = size(matrix, 1)
    if (size(matrix, 2) /= dim .or. (dim /= 21 .and. dim /= 139)) return
    if (kind < -1 .or. kind > 1) return
    if (size(input_knots) /= ni + 4 .or. size(weight_knots) /= nw + 4) return
    if (size(input_pieces, 2) /= 4 .or. size(input_pieces, 3) /= 4) return
    if (size(weight_pieces, 2) /= 4 .or. size(weight_pieces, 3) /= 4) return
    if (dim == 21) then
      if (ni < 21 .or. ni > 24 .or. nw < 21 .or. nw > 24) return
      if (input_offset < 0 .or. input_offset > ni - 21) return
      if (weight_offset < 0 .or. weight_offset > nw - 21) return
    else
      if (.not. large_matrix_tuple(kind, ni, input_offset, nw, weight_offset)) return
    end if
    count = 0
    child = knot_intervals(input_knots, weight_knots, 0.0_c_double, records, count)
    if (child /= 0) return
    matrix = 0.0_c_double
    total = size(input_knots) + size(weight_knots)
    if (kind == -1) then
      cumulative_input = 0.0_c_double
      record = 1
      do step = 1, total - 1
        input_amount = 0.0_c_double
        if (record <= count) then
          if (step == records(record)%input_index + records(record)%weight_index) then
            call interval_bounds(input_knots, records(record)%input_index, records(record), ibounds, iwidth)
            ifirst = max(records(record)%input_index - 3, input_offset + 1)
            ilast = min(records(record)%input_index, input_offset + dim)
            do ib = ifirst, ilast
              coeff = input_pieces(ib, records(record)%input_index - ib + 1, :)
              call polynomial_integral(coeff, 0.0_c_double, integral)
              low = polynomial_value(integral, ibounds(1))
              high = polynomial_value(integral, ibounds(2))
              difference = high - low
              input_amount(ib) = difference*iwidth
            end do
            record = record + 1
          end if
        end if
        do ib = 1, ni
          cumulative_input(ib, step + 1) = cumulative_input(ib, step) + input_amount(ib)
        end do
      end do
      cumulative_weight = 0.0_c_double
    end if
    record = 1
    do step = 1, total - 1
      if (kind == -1) weight_amount = 0.0_c_double
      if (record <= count) then
        if (step == records(record)%input_index + records(record)%weight_index) then
          width = records(record)%width
          call interval_bounds(weight_knots, records(record)%weight_index, records(record), wbounds, wwidth)
          call interval_bounds(input_knots, records(record)%input_index, records(record), ibounds, iwidth)
          discarded_widths(1) = ibounds(2) - ibounds(1)
          discarded_widths(2) = wbounds(2) - wbounds(1)
          ifirst = max(records(record)%input_index - 3, input_offset + 1)
          ilast = min(records(record)%input_index, input_offset + dim)
          wfirst = max(records(record)%weight_index - 3, weight_offset + 1)
          wlast = min(records(record)%weight_index, weight_offset + dim)
          do wb = wfirst, wlast
            coeff = weight_pieces(wb, records(record)%weight_index - wb + 1, :)
            if (kind == -1) then
              call polynomial_integral(coeff, 0.0_c_double, integral)
              low = polynomial_value(integral, wbounds(1))
              high = polynomial_value(integral, wbounds(2))
              difference = high - low
              weight_amount(wb) = difference*wwidth
            end if
            child = local_polynomial(weight_transform, wbounds(1), wbounds(2), coeff, local_weight)
            if (child /= 0) then
              status = 3
              return
            end if
            do ib = ifirst, ilast
              coeff = input_pieces(ib, records(record)%input_index - ib + 1, :)
              child = local_polynomial(input_transform, ibounds(1), ibounds(2), coeff, local_input)
              if (child /= 0) then
                status = 3
                return
              end if
              child = interval_contribution(kind, local_input, local_weight, width, contribution)
              if (child /= 0) then
                status = 3
                return
              end if
              row = wb - weight_offset; col = ib - input_offset
              matrix(row, col) = matrix(row, col) + contribution
              if (kind == -1) then
                term = weight_amount(wb)*cumulative_input(ib, step)
                matrix(row, col) = matrix(row, col) + term
              end if
            end do
            if (kind == -1) then
              do ib = input_offset + 1, ifirst - 1
                row = wb - weight_offset; col = ib - input_offset
                term = weight_amount(wb)*cumulative_input(ib, step)
                matrix(row, col) = matrix(row, col) + term
              end do
            end if
          end do
          record = record + 1
        end if
      end if
      if (kind == -1) then
        do wb = 1, nw
          cumulative_weight(wb, step + 1) = cumulative_weight(wb, step) + weight_amount(wb)
        end do
      end if
    end do
    status = 0
  end function
  subroutine interval_bounds(knots, index, record, bounds, width)
    real(c_double), intent(in) :: knots(:)
    integer(c_int), intent(in) :: index
    type(spline_interval), intent(in) :: record
    real(c_double), intent(out) :: bounds(2), width
    bounds(1) = interval_coordinate(knots(index), knots(index + 1), record%lower)
    bounds(2) = interval_coordinate(knots(index), knots(index + 1), record%upper)
    width = knots(index + 1) - knots(index)
  end subroutine
  function large_matrix_tuple(kind, ni, oi, nw, ow) result(valid)
    integer(c_int), intent(in) :: kind, oi, ow
    integer, intent(in) :: ni, nw
    logical :: valid
    integer :: i
    integer, parameter :: tuples(5, 7) = reshape([0, 139, 0, 139, 0, 0, 140, 0, 140, 0, 0, 140, 1, 140, 1, &
                                                  -1, 139, 0, 140, 1, 1, 139, 0, 139, 0, 1, 139, 0, 140, 0, 1, 139, 0, 140, &
                                                  1], [5, 7])
    valid = .false.
    do i = 1, 7
      if (all([kind, ni, oi, nw, ow] == tuples(:, i))) valid = .true.
    end do
  end function
  elemental function valid_basis(n) result(valid)
    integer, intent(in) :: n
    logical :: valid
    valid = (n >= 21 .and. n <= 24) .or. n == 139 .or. n == 140
  end function
  function valid_knots(knots) result(valid)
    real(c_double), intent(in) :: knots(:)
    logical :: valid
    integer :: i
    integer(c_int64_t) :: bits, previous
    valid = .false.; previous = 0_c_int64_t
    do i = 1, size(knots)
      bits = transfer(knots(i), bits)
      if (bits < previous .or. bits > int(z'3ff0000000000000', c_int64_t)) return
      previous = bits
    end do
    if (transfer(knots(1), 0_c_int64_t) /= 0_c_int64_t) return
    if (previous /= int(z'3ff0000000000000', c_int64_t)) return
    valid = .true.
  end function
  elemental function finite_real(value) result(finite)
    real(c_double), intent(in) :: value
    logical :: finite
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    finite = ibits(bits, 52, 11) /= 2047_c_int64_t
  end function
end module
