module forecast_model_clock_port
  !! Build the generated model clocks with native, named Fortran fields.
  !! Calendar dates use YYYYMMDD. Time values use seconds.
  use, intrinsic :: iso_c_binding
  implicit none
  private
  public :: forecast_clock_input,forecast_clock,forecast_time_state
  public :: initialize_model_clock,initialize_operational_model_clock

  type, bind(c) :: forecast_clock_input
    integer(c_int) :: date,seconds
    real(c_double) :: dt
    character(c_char) :: stop(8)
    integer(c_int) :: initial_condition,unused
    real(c_double) :: trajectory_dt
  end type

  type, bind(c) :: forecast_time_state
    integer(c_int) :: first_step,total_steps
    character(c_char) :: stop(8)
    integer(c_int) :: date_time_flags(2),initial_iteration,reserved
    real(c_double) :: relative_seconds,initial_seconds_j2000
    real(c_double) :: initial_solar(11),retained_solar(4)
    real(c_double) :: initial_orbit(4),first_dt,second_dt,work(12)
  end type

  type, bind(c) :: forecast_clock
    integer(c_int) :: initial_date,initial_seconds
    real(c_double) :: initial_seconds_j2000
    integer(c_int) :: control,first_step,total_steps,model_number
    integer(c_int) :: retained_control,current_step
    real(c_double) :: dt
    type(forecast_time_state) :: integration
  end type

contains

  function initialize_model_clock(input,clock) &
      bind(c,name="md2asm_initialize_model_clock_fortran") result(status)
    !! Port model_clock_initialization.S, with a 3600-second time step
    !! and a stop count from t1 through t25. Caller-owned unused fields
    !! retain their bytes. Invalid input changes no clock field.
    type(forecast_clock_input), intent(in) :: input
    type(forecast_clock), intent(inout) :: clock
    integer(c_int) :: status
    status=initialize_clock(input,clock,.false.)
  end function

  function initialize_operational_model_clock(input,clock) &
      bind(c,name="md2asm_initialize_operational_model_clock_fortran") result(status)
    !! Port operational_model_clock.S, with a 450-second time step
    !! and a stop duration from h1 through h72.
    type(forecast_clock_input), intent(in) :: input
    type(forecast_clock), intent(inout) :: clock
    integer(c_int) :: status
    status=initialize_clock(input,clock,.true.)
  end function

  function initialize_clock(input,clock,hours) result(status)
    type(forecast_clock_input), intent(in) :: input
    type(forecast_clock), intent(inout) :: clock
    logical, intent(in) :: hours
    integer(c_int) :: status,year,month,day,days,century,adjusted_year,adjusted_month
    integer(c_int) :: whole_days,stop_value,total_steps
    integer(c_int), parameter :: month_lengths(12)=[31,28,31,30,31,30,31,31,30,31,30,31]
    integer(c_int64_t) :: dt_word,trajectory_word,required_word
    integer :: j,digit,digits
    logical :: spaces
    real(c_double) :: work,initial_time,required_dt

    status=2
    if(clock%control/=0 .or. input%initial_condition/=0) return
    year=input%date/10000
    if(year<1901 .or. year>2099) return
    month=modulo(input%date,10000_c_int)/100
    day=modulo(input%date,100_c_int)
    if(month<1 .or. month>12) return
    days=month_lengths(month)
    if(month==2) then
      if(modulo(year,4_c_int)==0) then
        if(modulo(year,100_c_int)/=0 .or. modulo(year/100,4_c_int)==0) days=days+1
      end if
    end if
    if(day<1 .or. day>days .or. input%seconds<0 .or. input%seconds>=86400) return
    required_dt=3600.0_c_double
    if(hours) required_dt=450.0_c_double
    required_word=transfer(required_dt,required_word)
    dt_word=transfer(input%dt,dt_word)
    trajectory_word=transfer(input%trajectory_dt,trajectory_word)
    if(dt_word/=required_word) return
    if(trajectory_word/=required_word .and. trajectory_word/=int(z'bff0000000000000',c_int64_t)) return
    if(hours) then
      if(input%stop(1)/='h') return
    else
      if(input%stop(1)/='t') return
    end if
    stop_value=0
    digits=0
    spaces=.false.
    do j=2,8
      if(input%stop(j)==' ') then
        spaces=.true.
      else
        if(spaces) return
        digit=iachar(input%stop(j))-iachar('0')
        if(digit<0 .or. digit>9) return
        digits=digits+1
        if(digits>2) return
        stop_value=stop_value*10+digit
      end if
    end do
    if(digits==0 .or. stop_value<1) return
    total_steps=stop_value
    if(hours) then
      if(stop_value>72) return
      work=real(stop_value*3600,c_double)/required_dt
      total_steps=nint(work,c_int)
    else
      if(stop_value>25) return
    end if

    adjusted_year=year
    adjusted_month=month
    if(month<3) then
      adjusted_year=year-1
      adjusted_month=month+12
    end if
    century=adjusted_year/100
    whole_days=century/4-century
    whole_days=whole_days+2
    work=real(adjusted_year,c_double)*365.25_c_double
    whole_days=whole_days+int(work,c_int)
    work=real(adjusted_month+1,c_double)*30.601_c_double
    whole_days=whole_days+int(work,c_int)
    whole_days=whole_days+day
    initial_time=1720994.5_c_double+real(whole_days,c_double)
    initial_time=initial_time-2451545.0_c_double
    initial_time=initial_time*86400.0_c_double
    initial_time=initial_time+real(input%seconds,c_double)

    clock%initial_date=input%date
    clock%initial_seconds=input%seconds
    clock%initial_seconds_j2000=initial_time
    clock%first_step=0
    clock%total_steps=total_steps
    clock%model_number=1
    clock%current_step=-999
    clock%dt=input%dt
    clock%integration%first_step=0
    clock%integration%total_steps=total_steps
    clock%integration%stop=input%stop
    clock%integration%date_time_flags=0
    clock%integration%initial_iteration=0
    clock%integration%relative_seconds=0.0_c_double
    clock%integration%initial_seconds_j2000=initial_time
    clock%integration%initial_solar=0.0_c_double
    clock%integration%initial_orbit=0.0_c_double
    clock%integration%first_dt=input%dt
    clock%integration%second_dt=input%dt
    clock%integration%work=0.0_c_double
    status=0
  end function
end module
