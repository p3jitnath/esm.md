! (C) Copyright ECMWF and Meteo-France. Declarations derive from YOMIO_SERV.
! Licensed under Apache License2.0; ECMWF retains its privileges and immunities.
!> Own the source-inactive I/O server namespace through named Fortran members.
!! No server, file, model or numerical procedure is called. Time thresholds
!! are seconds; other counts have no units. Pointer owners start absent.
module forecast_native_io_server_namespace
  use iso_fortran_env, only: int32, int64, real64
  use mpi_f08, only: MPI_Comm, MPI_COMM_NULL
  implicit none
  private
  integer, parameter :: JPOSLEN = 20, NREQIDSIZE = 4, NPREFLEN = 8, NSUFFLEN = 16, NNAMELEN = 16
  integer, parameter :: NIO_SERV_PROCESS_LAST = 5, NIO_SERV_TAG_ZERO = 0
  character(8), parameter :: CIO_SERV_HDR_MAGIC = 'IO_SERV_', CIOFLDDESC_MAGIC = 'IOFLDDES', CIOCPTDESC_MAGIC = 'IOCPTDES'
  public :: native_fp_serv_dinf
  type :: native_fp_serv_dinf
    INTEGER(KIND=int32) :: NPETOT = 0
    INTEGER(KIND=int32) :: NPELOC = 0
    INTEGER(KIND=int32) :: NSIZEG = 0
    INTEGER(KIND=int32) :: NSIZEL = 0
    INTEGER(KIND=int32), POINTER :: ILEVG(:) => NULL()
  end type
  public :: native_io_serv_hdr1
  type :: native_io_serv_hdr1
    SEQUENCE
    CHARACTER(LEN=8) :: CMAGIC = CIO_SERV_HDR_MAGIC
    INTEGER(KIND=int32) :: NTYPE = -1_int32
    INTEGER(KIND=int32) :: ISTEP = 0_int32
    INTEGER(KIND=int32) :: IDATEF(22) = &
  & (/0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, &
  &    0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32/)
    INTEGER(KIND=int32) :: IDOM = 0_int32
    INTEGER(KIND=int32) :: IHH = 0_int32
    INTEGER(KIND=int32) :: IMM = 0_int32
    INTEGER(KIND=int32) :: ISS = 0_int32
    INTEGER(KIND=int32) :: MYPROC = 0_int32
    INTEGER(KIND=int32) :: IPAD = 0_int32
  end type
  public :: native_io_serv_hdr2
  type :: native_io_serv_hdr2
    SEQUENCE
    CHARACTER(LEN=8) :: CMAGIC = CIO_SERV_HDR_MAGIC
    INTEGER(KIND=int32) :: NFLDS = 0_int32
    INTEGER(KIND=int32) :: NSIZEG = 0_int32
    INTEGER(KIND=int32) :: NSIZEL = 0_int32
    INTEGER(KIND=int32) :: MYSETW = 0_int32
    INTEGER(KIND=int32) :: MYSETV = 0_int32
    INTEGER(KIND=int32) :: MYPROC = 0_int32
    INTEGER(KIND=int32) :: MYSETA = 0_int32
    INTEGER(KIND=int32) :: MYSETB = 0_int32
    INTEGER(KIND=int32) :: IHASFLDSC = 0_int32
    INTEGER(KIND=int32) :: ISSPEC = 0_int32
    INTEGER(KIND=int32) :: ITAG = 0_int32
    INTEGER(KIND=int32) :: NPETOT = 0_int32
    INTEGER(KIND=int32) :: NPELOC = 0_int32
    INTEGER(KIND=int32) :: NPESET = 0_int32
  end type
  public :: native_io_serv_hdrg
  type :: native_io_serv_hdrg
    SEQUENCE
    TYPE(native_io_serv_hdr1) :: YH1
    TYPE(native_io_serv_hdr2) :: YH2
    INTEGER(KIND=int32) :: IPAD = 0_int32
    INTEGER(KIND=int32) :: ISPARE = 0_int32
  end type
  public :: native_ioflddesc_wavemodel
  type :: native_ioflddesc_wavemodel
    SEQUENCE
    INTEGER(KIND=int32) :: IANGLE = -1_int32
    INTEGER(KIND=int32) :: IFREQ = -1_int32
    INTEGER(KIND=int32) :: NDATE_TIME_WINDOW_END = 0
    INTEGER(KIND=int32) :: KCOUSTEP = 0
    LOGICAL :: LRSTST0 = .false.
    INTEGER(KIND=int32) :: ITABLE = 0
    INTEGER(KIND=int32) :: IPARAM = 0
    INTEGER(KIND=int32) :: KLEV = 0
    INTEGER(KIND=int32) :: IFCST = 0
    CHARACTER(LEN=2) :: MARSTYPE = repeat(achar(0), 2)
    CHARACTER(LEN=14) :: CDATE = repeat(achar(0), 14)
    INTEGER(KIND=int32) :: NSTEP = 0
  end type
  public :: native_ioflddesc
  type :: native_ioflddesc
    SEQUENCE
    CHARACTER(LEN=8) :: CMAGIC = CIOFLDDESC_MAGIC
    CHARACTER(LEN=NPREFLEN) :: CPREF = ''
    INTEGER(KIND=int32) :: ILEVG = 0_int32
    CHARACTER(LEN=NSUFFLEN) :: CSUFF = ''
    LOGICAL :: LREQD = .TRUE.
    LOGICAL :: LSPEC = .FALSE.
    INTEGER(KIND=int32) :: NFLSZ = -1_int32
    INTEGER(KIND=int32) :: NSIZPK = -1_int32
    INTEGER(KIND=int32) :: NGRIBL = -1_int32
    INTEGER(KIND=int64) :: IFPMASK = 0
    INTEGER(KIND=int32) :: JBITS = -1_int32
    LOGICAL :: LUNDF = .FALSE.
    REAL(KIND=real64) :: XUNDF = 0._real64
    INTEGER(KIND=int32) :: ICPLB = 0_int32
    INTEGER(KIND=int32) :: ICPLS = 0_int32
    INTEGER(KIND=int32) :: ILEVL = 0_int32
    INTEGER(KIND=int32) :: IVSET = 0_int32
    INTEGER(KIND=int32) :: IOLEV = 0_int32
    LOGICAL :: LIOLV = .FALSE.
    REAL(KIND=real64) :: XAUX1 = 0._real64
    INTEGER(KIND=int32) :: IGRIB = 0_int32
    INTEGER(KIND=int32) :: IPREVPP = -1_int32
    TYPE(native_ioflddesc_wavemodel) :: YWAM
  end type
  public :: native_iocptdesc
  type :: native_iocptdesc
    SEQUENCE
    CHARACTER(LEN=8) :: CMAGIC = CIOCPTDESC_MAGIC
    CHARACTER(LEN=NNAMELEN) :: CNOMA = ''
    INTEGER(KIND=int32) :: ILNOMA = 0
    INTEGER(KIND=int32) :: ILONGD = 0
    REAL(KIND=real64) :: ZMIN = +HUGE(1._real64)
    REAL(KIND=real64) :: ZMAX = -HUGE(1._real64)
    REAL(KIND=real64) :: ZAVE = 0._real64
  end type
  public :: native_io_serv_req
  type :: native_io_serv_req
    TYPE(native_io_serv_hdrg) :: YHDR
    INTEGER(KIND=int32) :: ID(NREQIDSIZE) = (/0_int32, 0_int32, 0_int32, 0_int32/)
    LOGICAL :: LARRAY2D = .FALSE.
    REAL(KIND=real64), POINTER :: ZFLBU1(:) => NULL()
    REAL(KIND=real64), POINTER :: ZFLBU2(:, :) => NULL()
    REAL(KIND=real64), POINTER :: ZFLBU3(:, :, :) => NULL()
    TYPE(native_ioflddesc), POINTER :: YFLDSC(:) => NULL()
    TYPE(native_iocptdesc), POINTER :: YCPDSC(:) => NULL()
    INTEGER(KIND=int32), POINTER :: IFLOFF(:) => NULL()
    INTEGER(KIND=int32), POINTER :: IFLDOM(:) => NULL()
    INTEGER(KIND=int32) :: NSIZER = 0_int32
    INTEGER(KIND=int32) :: NSIZED = 0_int32
    LOGICAL :: LHDROK = .FALSE.
    LOGICAL :: LLDONE = .FALSE.
    REAL(KIND=real64) :: ZTIME1 = 0._real64
    REAL(KIND=real64) :: ZTIME2 = 0._real64
    INTEGER(KIND=int32) :: IREQ_CREAT = 0_int32
    INTEGER(KIND=int32) :: IREQ_COMPL = 0_int32
  end type
  public :: native_io_serv_req_ptr
  type :: native_io_serv_req_ptr
    TYPE(native_io_serv_req), POINTER :: P => NULL()
  end type
  public :: native_io_serv_mem_block
  type :: native_io_serv_mem_block
    REAL(KIND=real64), POINTER :: R(:, :) => NULL()
    INTEGER(KIND=int32) :: NREQID = 0
    LOGICAL :: LREQID = .FALSE.
  end type
  public :: native_io_serv_fagiot_args
  type :: native_io_serv_fagiot_args
    INTEGER(KIND=int32) :: INGRIB = -99_int32
    INTEGER(KIND=int32) :: INBPDG = -99_int32
    INTEGER(KIND=int32) :: INBCSP = -99_int32
    INTEGER(KIND=int32) :: ISTRON = -99_int32
    INTEGER(KIND=int32) :: IPUILA = -99_int32
    INTEGER(KIND=int32) :: IDMOPL = -99_int32
  end type
  public :: native_io_serv_faframe
  type :: native_io_serv_faframe
    INTEGER(KIND=int32) :: NTYPTR = -99_int32
    INTEGER(KIND=int32) :: NTRONC = -99_int32
    INTEGER(KIND=int32) :: NNLATI = -99_int32
    INTEGER(KIND=int32) :: NNXLON = -99_int32
    INTEGER(KIND=int32) :: NNIVER = -99_int32
    INTEGER(KIND=int32), POINTER :: NNLOPA(:) => NULL()
    INTEGER(KIND=int32), POINTER :: NNOZPA(:) => NULL()
    REAL(KIND=real64) :: RSLAPO = -99._real64
    REAL(KIND=real64) :: RCLOPO = -99._real64
    REAL(KIND=real64) :: RSLOPO = -99._real64
    REAL(KIND=real64) :: RCODIL = -99._real64
    REAL(KIND=real64) :: RREFER = -99._real64
    REAL(KIND=real64), POINTER :: RSINLA(:) => NULL()
    REAL(KIND=real64), POINTER :: RAHYBR(:) => NULL()
    REAL(KIND=real64), POINTER :: RBHYBR(:) => NULL()
    CHARACTER(LEN=32) :: CNC = ""
  end type
  public :: native_io_serv_ecgrib
  type :: native_io_serv_ecgrib
    INTEGER(KIND=int32) :: NGRIB_HANDLE_SH = -99_int32
    INTEGER(KIND=int32) :: NGRIB_HANDLE_SH_ML = -99_int32
    INTEGER(KIND=int32) :: NGRIB_HANDLE_GG = -99_int32
    INTEGER(KIND=int32) :: NGRIB_HANDLE_GG2 = -99_int32
    INTEGER(KIND=int32) :: NGRIB_HANDLE_GG_ML = -99_int32
    INTEGER(KIND=int32) :: NGRIB_HANDLE_BUDG = -99_int32
    INTEGER(KIND=int32), POINTER :: NSFLEVS(:, :) => NULL()
    INTEGER(KIND=int32) :: NLOCGRB = 0
    INTEGER(KIND=int32) :: NSTREAM = 0
    INTEGER(KIND=int32) :: NLEG = 0
    INTEGER(KIND=int32) :: NREFERENCE = 0
    INTEGER(KIND=int32) :: NWINOFF_4V = 0
    INTEGER(KIND=int32) :: NFCHO_TRUNC_INI = 0
    INTEGER(KIND=int32) :: NFCLENGTH_INI = 0
    LOGICAL :: LVAREPS = .false.
    INTEGER(KIND=int32) :: NSTEPINI = 0
    LOGICAL :: LFDBOP = .false.
    LOGICAL :: LSMSSIG = .false.
    CHARACTER(LEN=25) :: CMETER = repeat(achar(0), 25)
    CHARACTER(LEN=2) :: CTYPE = repeat(achar(0), 2)
    REAL(KIND=real64) :: TSTEP = 0.0_real64
    LOGICAL :: LPPSTEPS = .false.
    INTEGER(KIND=int32), POINTER :: MSERIES(:) => NULL()
    INTEGER(KIND=int32), POINTER :: MSATID(:) => NULL()
    INTEGER(KIND=int32), POINTER :: MINST(:) => NULL()
    INTEGER(KIND=int32), POINTER :: MCHAN(:) => NULL()
    REAL(KIND=real64), POINTER :: RCWN(:) => NULL()
  END TYPE native_io_serv_ecgrib
  TYPE IO_SERV_DMPARAM
    INTEGER(KIND=int32) :: ISZGPG = 0_int32
    INTEGER(KIND=int32) :: ISZSPG = 0_int32
    INTEGER(KIND=int32) :: IADDPK = 0_int32
    CHARACTER(LEN=JPOSLEN) :: CFPDOM = ''
  end type
  public :: native_io_serv_wavemodel
  type :: native_io_serv_wavemodel
    LOGICAL :: LWACTIVE = .false.
    INTEGER(KIND=int32) :: NTOTMX = 0
    INTEGER(KIND=int32) :: NTOTG = 0
    INTEGER(KIND=int32) :: NGX = 0
    INTEGER(KIND=int32) :: NGY = 0
    CHARACTER(LEN=1) :: CLDOMAIN = repeat(achar(0), 1)
    INTEGER(KIND=int32) :: IU06 = 0
    INTEGER(KIND=int32) :: ITEST = 0
    LOGICAL :: LGRHDIFS = .false.
    REAL(KIND=real64) :: PPMISS = 0.0_real64
    REAL(KIND=real64) :: PPEPS = 0.0_real64
    REAL(KIND=real64) :: PPREC = 0.0_real64
    REAL(KIND=real64) :: PPRESOL = 0.0_real64
    REAL(KIND=real64) :: PPMIN_RESET = 0.0_real64
    INTEGER(KIND=int32) :: NTENCODE = 0
    INTEGER(KIND=int32) :: NGRBRESS = 0
    LOGICAL :: LNEWLVTP = .false.
    LOGICAL :: LPADPOLES = .false.
    INTEGER(KIND=int32), ALLOCATABLE :: NLONRGG(:)
    INTEGER(KIND=int32) :: IRGG = 0
    REAL(KIND=real64) :: AMONOP = 0.0_real64
    REAL(KIND=real64) :: AMOSOP = 0.0_real64
    REAL(KIND=real64) :: XDELLA = 0.0_real64
    REAL(KIND=real64) :: ZMISS = 0.0_real64
    INTEGER(KIND=int32) :: NSTPW = 0
    CHARACTER(LEN=256) :: CFDB2DSP = repeat(achar(0), 256)
    INTEGER(KIND=int32) :: NPRECI = 0
    INTEGER(KIND=int32) :: IMDLGRBID_G = 0
    INTEGER(KIND=int32) :: IMDLGRBID_M = 0
    INTEGER(KIND=int32), POINTER :: ISORTL2G(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: IRANKSET(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: ISORTCNT(:) => NULL()
    INTEGER(KIND=int32), POINTER :: ISORTOFF(:) => NULL()
    INTEGER(KIND=int32) :: NGRIB_HANDLE_WAM_S = -99_int32
    INTEGER(KIND=int32) :: NGRIB_HANDLE_WAM_I = -99_int32
  end type
  public :: native_io_serv_modelpar
  type :: native_io_serv_modelpar
    INTEGER(KIND=int32) :: NTIMEFMT = 0
    INTEGER(KIND=int32) :: NSPEC2G = 0
    INTEGER(KIND=int32) :: NSPEC2MX = 0
    INTEGER(KIND=int32) :: NGPTOTG = 0
    INTEGER(KIND=int32) :: NGPTOTMX = 0
    LOGICAL :: LECMWF = .FALSE.
    LOGICAL :: LARPEGEF = .TRUE.
    LOGICAL :: LELAM = .FALSE.
    CHARACTER(LEN=16) :: CNMEXP = ''
    INTEGER(KIND=int32) :: NPRTRW = 0
    INTEGER(KIND=int32) :: NPRTRV = 0
    LOGICAL :: LWRSPECA_GP = .FALSE.
    LOGICAL :: LSUSPECA_GP = .FALSE.
    LOGICAL :: LINC = .FALSE.
    INTEGER(KIND=int32) :: NFPDOM = 0
    INTEGER(KIND=int32) :: NFPRGPLX = 0
    INTEGER(KIND=int32) :: MBX_SIZE = 0
    INTEGER(KIND=int32) :: NSMAX = 0
    CHARACTER(LEN=64) :: CMODEL = ''
    INTEGER(KIND=int32) :: NIDCEN = 0
    LOGICAL :: LEXTERN = .FALSE.
    TYPE(native_io_serv_fagiot_args) :: YFAGIOT_ARGS
    TYPE(native_io_serv_faframe) :: YFRAME
    TYPE(IO_SERV_DMPARAM) :: YPARAM
    TYPE(native_io_serv_faframe), POINTER :: YFRAMEFP(:) => NULL()
    TYPE(IO_SERV_DMPARAM), POINTER :: YPARAMFP(:) => NULL()
    INTEGER(KIND=int32) :: JPXTRO = 0
    INTEGER(KIND=int32) :: JPXLAT = 0
    INTEGER(KIND=int32) :: JPXNIV = 0
    INTEGER(KIND=int32) :: JPNXFA = 0
    INTEGER(KIND=int32) :: JPNXCA = 0
    TYPE(native_io_serv_ecgrib) :: YECGRIB
    TYPE(native_io_serv_wavemodel) :: YWAM
    INTEGER(KIND=int32), POINTER :: ISPSORTL2G(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: ISPRANKSET(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: ISPSORTCNT(:) => NULL()
    INTEGER(KIND=int32), POINTER :: ISPSORTOFF(:) => NULL()
    INTEGER(KIND=int32), POINTER :: IGPSORTL2G(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: IGPRANKSET(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: IGPSORTCNT(:) => NULL()
    INTEGER(KIND=int32), POINTER :: IGPSORTOFF(:) => NULL()
    INTEGER(KIND=int32), POINTER :: IFPSORTL2G(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: IFPRANKSET(:, :) => NULL()
    INTEGER(KIND=int32), POINTER :: IFPSORTCNT(:) => NULL()
    INTEGER(KIND=int32), POINTER :: IFPSORTOFF(:) => NULL()
  end type
  public :: native_io_server_namespace
  type :: native_io_server_namespace
    LOGICAL :: LSENTFLD = .FALSE.
    LOGICAL :: LWARN = .FALSE.
    LOGICAL :: LINFO = .FALSE.
    LOGICAL :: LDBUG = .FALSE.
    LOGICAL :: LLOG_OPEN = .FALSE.
    REAL(KIND=real64) :: ZBTIME = 0.0_real64
    INTEGER(KIND=int32) :: NMSG_LEVEL = 1
    LOGICAL :: LMSG_FLUSH = .TRUE.
    INTEGER(KIND=int32) :: NMSG_LEVEL_SERVER = 0
    INTEGER(KIND=int32) :: NMSG_LEVEL_CLIENT = 0
    LOGICAL :: LMSG_FLUSH_SERVER = .TRUE.
    LOGICAL :: LMSG_FLUSH_CLIENT = .FALSE.
    REAL(KIND=real64) :: WAIT_TIME_THRESHOLD = 0.5_real64
    INTEGER(KIND=int32) :: NPROCESS_LEVEL = NIO_SERV_PROCESS_LAST
    type(MPI_Comm) :: NCOMM_W1IO = MPI_COMM_NULL
    type(MPI_Comm) :: NCOMM_WR = MPI_COMM_NULL
    type(MPI_Comm) :: NCOMM_IO = MPI_COMM_NULL
    type(MPI_Comm) :: NCOMM_WRIO = MPI_COMM_NULL
    INTEGER(KIND=int32) :: MYPROC_WRIO = -1
    INTEGER(KIND=int32) :: MYPROC_IO = -1
    INTEGER(KIND=int32) :: MYPROC_WR = -1
    INTEGER(KIND=int32) :: NPROC_WRIO = -1
    LOGICAL :: LIO_SERVER = .FALSE.
    LOGICAL :: LIO_CLIENT = .FALSE.
    LOGICAL :: LARRAY2D = .FALSE.
    INTEGER(KIND=int32) :: NPROC_IO = 0
    INTEGER(KIND=int32), POINTER :: MYPROCS_IO(:) => NULL()
    INTEGER(KIND=int32) :: NPROC_WR = 0
    INTEGER(KIND=int32), POINTER :: MYPROCS_WR(:) => NULL()
    INTEGER(KIND=int32) :: NTHREAD_IO = 1
    INTEGER(KIND=int32) :: NIO_SERV_TAG = NIO_SERV_TAG_ZERO
    INTEGER(KIND=int32) :: NIO_SERV_METHOD = 2
    INTEGER(KIND=int32) :: NIO_SERV_BUF_MAXSIZE = 10
    INTEGER(KIND=int32) :: NIO_SERV_BUF_CURSIZE = 0
    TYPE(native_io_serv_mem_block), POINTER :: IO_SERV_BUF(:) => NULL()
    INTEGER(KIND=int32) :: ISEND = 0
    INTEGER(KIND=int64) :: ISENDSIZE = 0
    INTEGER(KIND=int32) :: IREQ_CREAT = 0
    INTEGER(KIND=int32) :: IREQ_COMPL = 0
    INTEGER(KIND=int32) :: IRECV = 0
    INTEGER(KIND=int64) :: IRECVSIZE = 0
    LOGICAL :: LFLDDESC_UNIQ = .TRUE.
    LOGICAL :: LFLDDESC_CHECK = .TRUE.
    TYPE(native_io_serv_req_ptr), POINTER :: YREQ_PTR_LIST(:) => NULL()
    TYPE(native_io_serv_modelpar) :: MODELPAR
    REAL(KIND=real64) :: PIOPROCR_MDL = -1._real64
    REAL(KIND=real64) :: PIOPROC1_MDL = -1._real64
    REAL(KIND=real64) :: PIOPROC2_MDL = -1._real64
    REAL(KIND=real64) :: PIOPROC1_FLP = -1._real64
    REAL(KIND=real64) :: PIOPROC2_FLP = -1._real64
    INTEGER(KIND=int32) :: IDATEF(22) = 0
    CHARACTER(LEN=256) :: CIFDIR = ''
    CHARACTER(LEN=256) :: COFDIR = '.'
    CHARACTER(LEN=256) :: COXMLDIR = '.'
    LOGICAL :: LIO_SERV_WR = .FALSE.
    LOGICAL :: LIO_SERV_RD = .FALSE.
    LOGICAL :: LIO_SERV_UVSIF = .TRUE.
    TYPE(native_fp_serv_dinf) :: YGPFSDINF
    REAL(KIND=real64) :: ZTDEC = 0._real64
  end type
  public :: initialize_owned_io_server_namespace
contains
  !> Initialize one fresh final TARGET namespace with its source defaults.
 !! The caller must pass a fresh owner with every nested pointer/array absent.
 !! This creates no payload and performs no MPI initialization or I/O.
  integer(int32) function initialize_owned_io_server_namespace(output) result(status)
    type(native_io_server_namespace), intent(inout) :: output
    output = native_io_server_namespace()
    status = 0
  end function
end module
