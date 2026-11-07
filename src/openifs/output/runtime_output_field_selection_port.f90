module runtime_output_field_selection_port
  !! Select source-ordered output labels and contiguous field values.
  !! Blocked input has shape (block_width,field_capacity,block_count).
  !! Dense output has shape (local_points,selected_field_capacity).
  use, intrinsic :: iso_fortran_env, only: int32,int64,real64
  use runtime_synchronous_grib_file_backend_port, only: output_field_selection
  implicit none
  private
  public :: build_spectral_output_selection,pack_spectral_output_fields
  public :: select_physical_output_fields,select_upper_grid_output_fields

contains

  function build_spectral_output_selection(level_kind,parameters,integrated, &
      levels,vertical_sets,local_slots,local_field_count,local_vertical_set, &
      fields,local_indices,global_count,local_count) result(status)
    !! Preserve skipped pressure geopotential and compacted source indices.
    !! Level labels use nearest-integer rounding with ties away from zero.
    character, intent(in) :: level_kind
    integer(int32), intent(in) :: parameters(:),vertical_sets(:),local_slots(:)
    logical, intent(in) :: integrated(:)
    real(real64), intent(in) :: levels(:)
    integer(int32), intent(in) :: local_field_count,local_vertical_set
    type(output_field_selection), intent(inout) :: fields(:)
    integer(int32), intent(inout) :: local_indices(:),global_count,local_count
    integer(int32) :: status
    integer :: n,pass,j,global_selected,local_selected,compact,selected_level
    logical :: selected_flag
    real(real64) :: value

    status=2_int32
    n=size(parameters)
    if(index('mpvt',level_kind)==0) return
    if(n>65536.or.local_field_count<0.or.local_field_count>65536.or.local_vertical_set<1) return
    if(n==0) then
      global_count=0
      local_count=0
      status=0
      return
    end if
    if(size(integrated)<n.or.size(levels)<n.or.size(vertical_sets)<n.or.size(local_slots)<n) return
    do pass=1,2
      global_selected=0
      local_selected=0
      do j=1,n
        selected_flag=integrated(j)
        if(level_kind=='p'.and.parameters(j)==129.and.selected_flag) cycle
        compact=global_selected+1
        if(level_kind/='m') selected_flag=integrated(compact)
        if(level_kind=='m'.and.selected_flag) then
          selected_level=1
        else if(level_kind=='p'.and.selected_flag) then
          selected_level=100000
        else
          if(level_kind=='m'.or.level_kind=='p') then
            value=levels(j)
          else
            value=levels(compact)
          end if
          if(pass==1) then
            if(level_kind=='v') then
              if(.not.valid_positive_level(value,2.0_real64)) return
            else
              if(.not.valid_positive_level(value,2147483647.0_real64)) return
            end if
            selected_level=0
          else
            if(level_kind=='v') value=value*1000000000.0_real64
            selected_level=nint(value,int32)
          end if
        end if
        if(vertical_sets(j)<1.or.local_slots(j)<1) return
        if(vertical_sets(j)==local_vertical_set) then
          if(local_slots(j)>local_field_count) return
          local_selected=local_selected+1
          if(pass==2) local_indices(local_selected)=local_slots(j)
        end if
        global_selected=global_selected+1
        if(pass==2) then
          fields(global_selected)%parameter_id=parameters(j)
          fields(global_selected)%level=selected_level
          fields(global_selected)%vertical_group=vertical_sets(j)
        end if
      end do
      if(pass==1) then
        if(global_selected>size(fields).or.local_selected>size(local_indices)) return
      end if
    end do
    global_count=int(global_selected,int32)
    local_count=int(local_selected,int32)
    status=0_int32
  end function build_spectral_output_selection

  function pack_spectral_output_fields(spectrum,local_indices,dense) result(status)
    !! Copy each selected field from a (field,coefficient) source matrix.
    real(real64), intent(in) :: spectrum(:,:)
    integer(int32), intent(in) :: local_indices(:)
    real(real64), intent(inout) :: dense(:,:)
    integer(int32) :: status
    integer :: field,coefficient

    status=2_int32
    if(size(local_indices)==0) then
      status=0
      return
    end if
    if(size(local_indices)>65536.or.size(spectrum,1)<1.or.size(spectrum,2)<1) return
    if(size(dense,1)/=size(spectrum,2).or.size(dense,2)<size(local_indices)) return
    do field=1,size(local_indices)
      if(local_indices(field)<1.or.local_indices(field)>size(spectrum,1)) return
    end do
    do field=1,size(local_indices)
      do coefficient=1,size(spectrum,2)
        dense(coefficient,field)=spectrum(local_indices(field),coefficient)
      end do
    end do
    status=0
  end function pack_spectral_output_fields

  function select_physical_output_fields(parameters,blocked,local_points, &
      gravity,water_density,fields,dense) result(status)
    !! IOGRIDE: retain source layer counters and field-unit conversion.
    !! gravity is m/s**2 and water_density is kg/m**3.
    integer(int32), intent(in) :: parameters(:),local_points
    real(real64), intent(in) :: blocked(:,:,:),gravity,water_density
    type(output_field_selection), intent(inout) :: fields(:)
    real(real64), intent(inout) :: dense(:,:)
    integer(int32) :: status
    integer(int32), parameter :: layer_codes(6)=[260510,260511,228141,228038,33,238]
    integer(int32), parameter :: water_codes(14)=[141,142,143,228,144,228216,182,228251,198,205,9,8,239,240]
    integer(int32), parameter :: gravity_codes(3)=[173,244,160]
    integer :: j,k,row,label
    integer :: layer_count(6)
    real(real64) :: factor

    status=2_int32
    if(local_points<1.or.local_points>6599680.or.size(blocked,1)<1.or.size(blocked,1)>1024) return
    if(size(parameters)>1639) return
    if(size(parameters)==0) then
      status=0
      return
    end if
    if(.not.valid_blocked(blocked,local_points,size(parameters))) return
    if(size(fields)<size(parameters).or.size(dense,1)/=local_points.or.size(dense,2)<size(parameters)) return
    if(.not.valid_positive_level(gravity,huge(0.0_real64)).or.transfer(gravity,0_int64)==0) return
    if(.not.valid_positive_level(water_density,huge(0.0_real64)).or.transfer(water_density,0_int64)==0) return
    layer_count=0
    do j=1,size(parameters)
      label=0
      do k=1,6
        if(parameters(j)/=layer_codes(k)) cycle
        label=layer_count(k)
        if(k<=4) label=label+1
        layer_count(k)=layer_count(k)+1
        exit
      end do
      fields(j)%parameter_id=parameters(j)
      fields(j)%level=label
      fields(j)%vertical_group=1
      call copy_blocked_field(blocked,j,local_points,dense(:,j))
      factor=1.0_real64
      if(any(parameters(j)==water_codes)) then
        factor=1.0_real64/water_density
      else if(any(parameters(j)==gravity_codes)) then
        factor=1.0_real64/gravity
      end if
      if(factor/=1.0_real64) then
        do row=1,local_points
          dense(row,j)=dense(row,j)*factor
        end do
      end if
    end do
    status=0
  end function select_physical_output_fields

  function select_upper_grid_output_fields(level_kind,parameters,integrated,levels, &
      blocked,local_points,cloud_cover_precision,cloud_water_precision,fields,dense, &
      selected_input_fields,selected_count) result(status)
    !! IOGRIDUE: preserve integrated-field skips and model cloud quantization.
    !! The two positive cloud precisions are in the associated field units.
    !! selected_input_fields retains each selected one-based input column.
    character, intent(in) :: level_kind
    integer(int32), intent(in) :: parameters(:),local_points
    logical, intent(in) :: integrated(:)
    real(real64), intent(in) :: levels(:),blocked(:,:,:)
    real(real64), intent(in) :: cloud_cover_precision,cloud_water_precision
    type(output_field_selection), intent(inout) :: fields(:)
    real(real64), intent(inout) :: dense(:,:)
    integer(int32), intent(inout) :: selected_input_fields(:),selected_count
    integer(int32) :: status
    integer :: n,j,row,selected,label
    integer(int64) :: bits,magnitude,integer_limit_bits
    real(real64) :: level,precision,inverse_precision,value
    integer(int32) :: quantized

    status=2_int32
    n=size(parameters)
    if(index('mpvt',level_kind)==0) return
    if(local_points<1.or.local_points>6599680.or.size(blocked,1)<1.or.size(blocked,1)>1024) return
    if(n>65536) return
    if(n==0) then
      selected_count=0
      status=0
      return
    end if
    if(.not.valid_blocked(blocked,local_points,n)) return
    if(size(fields)<n.or.size(dense,1)/=local_points.or.size(dense,2)<n) return
    if(size(selected_input_fields)<n.or.size(integrated)<n.or.size(levels)<n) return
    if(level_kind=='m') then
      if(.not.valid_positive_level(cloud_cover_precision,huge(0.0_real64)).or. &
          transfer(cloud_cover_precision,0_int64)==0) return
      if(.not.valid_positive_level(cloud_water_precision,huge(0.0_real64)).or. &
          transfer(cloud_water_precision,0_int64)==0) return
    end if
    do j=1,n
      if(level_kind=='v') then
        if(.not.valid_positive_level(levels(j),2.0_real64)) return
      else
        if(.not.valid_positive_level(levels(j),2147483647.0_real64)) return
      end if
    end do
    selected=0
    integer_limit_bits=transfer(2147483648.0_real64,0_int64)
    do j=1,n
      level=levels(j)
      if(level_kind=='v') level=level*1000000000.0_real64
      label=nint(level,int32)
      if(level_kind/='m'.and.integrated(j)) then
        if(parameters(j)==152.or.parameters(j)==134.or.parameters(j)==129.or.parameters(j)==151) cycle
      end if
      selected=selected+1
      fields(selected)%parameter_id=parameters(j)
      fields(selected)%level=label
      fields(selected)%vertical_group=1
      selected_input_fields(selected)=int(j,int32)
      call copy_blocked_field(blocked,j,local_points,dense(:,selected))
      if(level_kind/='m') cycle
      if(parameters(j)==248) then
        precision=cloud_cover_precision
      else if(parameters(j)==246.or.parameters(j)==247) then
        precision=cloud_water_precision
      else
        cycle
      end if
      if(precision==1.0_real64) cycle
      inverse_precision=1.0_real64/precision
      do row=1,local_points
        value=dense(row,selected)*inverse_precision
        bits=transfer(value,0_int64)
        magnitude=iand(bits,huge(0_int64))
        if(magnitude>integer_limit_bits) return
        if(magnitude==integer_limit_bits.and..not.btest(bits,63)) return
        quantized=int(value,int32)
        value=real(quantized,real64)
        dense(row,selected)=value*precision
      end do
    end do
    selected_count=int(selected,int32)
    status=0
  end function select_upper_grid_output_fields

  pure logical function valid_positive_level(value,maximum)
    !! Compare positive IEEE binary64 encodings without numerical conversion.
    real(real64), intent(in) :: value,maximum
    integer(int64) :: bits,limit
    bits=transfer(value,0_int64)
    limit=transfer(maximum,0_int64)
    valid_positive_level=.not.btest(bits,63).and.bits<=limit
  end function valid_positive_level

  pure logical function valid_blocked(blocked,points,fields)
    real(real64), intent(in) :: blocked(:,:,:)
    integer, intent(in) :: points,fields
    integer :: blocks
    valid_blocked=.false.
    if(size(blocked,1)<1) return
    blocks=(points-1)/size(blocked,1)+1
    valid_blocked=size(blocked,2)>=fields.and.size(blocked,3)==blocks
  end function valid_blocked

  subroutine copy_blocked_field(blocked,field,points,dense)
    real(real64), intent(in) :: blocked(:,:,:)
    integer, intent(in) :: field,points
    real(real64), intent(inout) :: dense(:)
    integer :: block,cell,position,count
    position=0
    do block=1,size(blocked,3)
      count=min(size(blocked,1),points-position)
      do cell=1,count
        dense(position+cell)=blocked(cell,field,block)
      end do
      position=position+count
    end do
  end subroutine copy_blocked_field
end module runtime_output_field_selection_port
