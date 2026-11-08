module initial_field_placement_port
  !! Place decoded initial fields into the forecast's owned arrays.
  !! Values keep their decoded units and bits. Integer maps select owners.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: spectral_initial_partition, upper_air_initial_partition
  public :: place_partitioned_spectral_fields, bind_upper_air_initial_partition
  public :: place_partitioned_upper_air_fields

  type :: spectral_initial_partition
    integer(int32) :: degree = 0, global_levels = 0, local_levels = 0, surface_fields = 0
    integer(int32) :: local_coefficients = 0, global_coefficients = 0
    integer(int32), allocatable :: waves(:), levels(:)
    integer(int32), allocatable :: local_first(:), global_first(:)
    integer(int32) :: field_codes(5) = 0
  end type

  type :: upper_air_initial_partition
    integer(int32) :: local_points = 0, global_points = 0, block_width = 0, levels = 0, blocks = 0
    integer(int32), pointer :: global_index(:) => null()
  end type

contains

  subroutine place_partitioned_spectral_fields(partition, values, metadata, spectral, surface, status)
    !! Port the qualified T1279/L137 two-way spectral placement.
    !! values has shape(1639680,at least413); metadata has three int64 rows.
    !! spectral has shape(local_levels,819840,3). surface has zero or two
    !! columns. The caller owns disjoint arrays and complete one-based maps.
    type(spectral_initial_partition), intent(in) :: partition
    real(real64), intent(in) :: values(:, :)
    integer(int64), intent(in) :: metadata(:, :)
    real(real64), intent(inout) :: spectral(:, :, :), surface(:, :)
    integer(int32), intent(out) :: status
    integer(int32), parameter :: expected_codes(5) = [138, 155, 130, 152, 129]
    integer :: wave, j, m, length, level, global_level, first_level, field, record
    integer :: local_first, global_first, k, expected_parameter, expected_level

    status = 1
    if (size(values, 1) /= 1639680 .or. size(values, 2) < 413) return
    if (size(metadata, 1) /= 3 .or. size(metadata, 2) < 413) return
    status = 3
    if (partition%degree /= 1279 .or. partition%global_levels /= 137) return
    if (partition%local_coefficients /= 819840 .or. partition%global_coefficients /= 1639680) return
    if (partition%local_levels == 69) then
      if (partition%surface_fields /= 0) return
      first_level = 1
    else if (partition%local_levels == 68) then
      if (partition%surface_fields /= 2) return
      first_level = 70
    else
      return
    end if
    if (any(shape(spectral) /= [partition%local_levels, 819840, 3])) return
    if (any(shape(surface) /= [819840, partition%surface_fields])) return
    if (.not. allocated(partition%waves) .or. .not. allocated(partition%levels)) return
    if (.not. allocated(partition%local_first) .or. .not. allocated(partition%global_first)) return
    if (size(partition%waves) /= 640 .or. size(partition%levels) /= partition%local_levels) return
    if (lbound(partition%local_first, 1) /= 0 .or. ubound(partition%local_first, 1) < 1279) return
    if (lbound(partition%global_first, 1) /= 0 .or. ubound(partition%global_first, 1) < 1279) return
    if (any(partition%field_codes /= expected_codes)) return
    do j = 1, 640
      m = partition%waves(j)
      if (m < 0 .or. m > 1279) return
      length = 2*(1280 - m)
      local_first = partition%local_first(m)
      global_first = partition%global_first(m)
      if (local_first < 1 .or. local_first > 819840 - length + 1) return
      if (global_first < 1 .or. global_first > 1639680 - length + 1) return
    end do
    do level = 1, partition%local_levels
      if (partition%levels(level) /= first_level + level - 1) return
    end do
    status = 2
    do record = 1, 413
      if (record == 1) then
        expected_parameter = 152
        expected_level = 1
      else if (record == 413) then
        expected_parameter = 129
        expected_level = 0
      else
        expected_parameter = expected_codes(mod(record - 2, 3) + 1)
        expected_level = (record - 2)/3 + 1
      end if
      if (metadata(1, record) /= expected_parameter .or. metadata(2, record) /= expected_level) return
      if (metadata(3, record) /= 1639680) return
    end do

    do field = 1, 3
      do wave = 1, 640
        m = partition%waves(wave)
        length = 2*(1280 - m)
        local_first = partition%local_first(m)
        global_first = partition%global_first(m)
        do level = 1, partition%local_levels
          global_level = partition%levels(level)
          record = 3*(global_level - 1) + field + 1
          do k = 0, length - 1
            spectral(level, local_first + k, field) = values(global_first + k, record)
          end do
        end do
      end do
    end do
    if (partition%surface_fields /= 0) then
      do field = 1, 2
        record = 1
        if (field == 2) record = 413
        do wave = 1, 640
          m = partition%waves(wave)
          length = 2*(1280 - m)
          local_first = partition%local_first(m)
          global_first = partition%global_first(m)
          do k = 0, length - 1
            surface(local_first + k, field) = values(global_first + k, record)
          end do
        end do
      end do
    end if
    status = 0
  end subroutine

  subroutine bind_upper_air_initial_partition(block_width, levels, north_rows, maximum_longitudes, &
                                              global_index, partition, status)
    !! Derive the live grid dimensions and borrow its global point map.
    !! north_rows contains one positive count per northern latitude.
    !! The caller keeps global_index alive until its last placement.
    integer(int32), intent(in) :: block_width, levels, north_rows(:), maximum_longitudes
    integer(int32), target, intent(in) :: global_index(:)
    type(upper_air_initial_partition), intent(inout) :: partition
    integer(int32), intent(out) :: status
    integer(int64) :: global_points
    integer :: j
    status = 2
    if (block_width < 1 .or. block_width > 1024 .or. levels < 1 .or. levels > 256) return
    if (size(north_rows) < 1 .or. size(north_rows) > 1280) return
    global_points = 0
    do j = 1, size(north_rows)
      if (north_rows(j) < 1) return
      global_points = global_points + int(north_rows(j), int64)
    end do
    global_points = 2*global_points
    if (global_points > 2147483647_int64) return
    if (maxval(north_rows) /= maximum_longitudes) return
    if (size(global_index) < 1 .or. int(size(global_index), int64) > global_points) return
    partition%local_points = int(size(global_index), int32)
    partition%global_points = int(global_points, int32)
    partition%block_width = block_width
    partition%levels = levels
    partition%blocks = (partition%local_points - 1)/block_width + 1
    partition%global_index => global_index
    status = 0
  end subroutine

  subroutine place_partitioned_upper_air_fields(partition, values, metadata, fields, status)
    !! Port the complete runtime SUGRIDUG copy order. values has shape
    !! (global_points,at least7*levels), metadata has five int64 rows,
    !! and fields has shape(block_width,levels,9,blocks).
    !! Only active cells of seven fields change. Both diagnostic fields
    !! become positive zero, including their inactive final-block cells.
    type(upper_air_initial_partition), intent(in) :: partition
    real(real64), intent(in) :: values(:, :)
    integer(int64), intent(in) :: metadata(:, :)
    real(real64), intent(inout) :: fields(:, :, :, :)
    integer(int32), intent(out) :: status
    integer(int32), parameter :: codes(7) = [133, 203, 75, 76, 246, 247, 248]
    integer, parameter :: positions(7) = [1, 7, 5, 4, 2, 3, 6]
    integer :: record, family, level, j, cell, block, source_index, l, width
    status = 1
    l = partition%levels
    width = partition%block_width
    if (l < 1 .or. l > 256 .or. width < 1 .or. width > 1024) return
    if (partition%local_points < 1 .or. partition%global_points < 1) return
    if (partition%local_points > partition%global_points) return
    if (.not. associated(partition%global_index)) return
    if (size(partition%global_index) /= partition%local_points) return
    if (partition%blocks /= (partition%local_points - 1)/width + 1) return
    if (size(values, 1) /= partition%global_points .or. size(values, 2) < 7*l) return
    if (size(metadata, 1) /= 5 .or. size(metadata, 2) < 7*l) return
    if (any(shape(fields) /= [width, l, 9, partition%blocks])) return
    status = 3
    do j = 1, partition%local_points
      if (partition%global_index(j) < 1 .or. partition%global_index(j) > partition%global_points) return
    end do
    status = 2
    do record = 1, 7*l
      call locate(record, l, level, family)
      if (metadata(1, record) /= codes(family) .or. metadata(2, record) /= level) return
      if (metadata(3, record) /= partition%global_points) return
    end do
    fields(:, :, 8:9, :) = 0.0_real64
    do record = 1, 7*l
      call locate(record, l, level, family)
      do j = 1, partition%local_points
        block = (j - 1)/width + 1
        cell = mod(j - 1, width) + 1
        source_index = partition%global_index(j)
        fields(cell, level, positions(family), block) = values(source_index, record)
      end do
    end do
    status = 0
  end subroutine

  pure subroutine locate(record, levels, level, family)
    integer, intent(in) :: record, levels
    integer, intent(out) :: level, family
    if (record <= 2*levels) then
      level = (record - 1)/2 + 1
      family = mod(record - 1, 2) + 1
    else
      level = (record - 2*levels - 1)/5 + 1
      family = mod(record - 2*levels - 1, 5) + 3
    end if
  end subroutine
end module
