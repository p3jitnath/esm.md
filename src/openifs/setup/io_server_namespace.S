// Source declaration defaults for the selected inactive IO_SERV_C001.
// Contract: io_server_namespace_contract.md. All offsets are typed metadata.
.data
.p2align 3
.global md2asm_owned_io_server_namespace
.type md2asm_owned_io_server_namespace,%object
md2asm_owned_io_server_namespace:
.org md2asm_owned_io_server_namespace+32
.word 1,1 // NMSG_LEVEL, LMSG_FLUSH
.org md2asm_owned_io_server_namespace+48
.word 1 // LMSG_FLUSH_SERVER
.org md2asm_owned_io_server_namespace+56
.double 0.5 // WAIT_TIME_THRESHOLD, seconds
.word 5 // NPROCESS_LEVEL=NIO_SERV_PROCESS_LAST
.word 67108864,67108864,67108864,67108864 // Four MPI_COMM_NULL handles
.word -1,-1,-1,-1 // MYPROC_WRIO/MYPROC_IO/MYPROC_WR/NPROC_WRIO
.org md2asm_owned_io_server_namespace+256
.word 1,0,2,10 // NTHREAD_IO, NIO_SERV_TAG, NIO_SERV_METHOD, BUF_MAXSIZE
.org md2asm_owned_io_server_namespace+384
.word 1,1 // LFLDDESC_UNIQ, LFLDDESC_CHECK
.org md2asm_owned_io_server_namespace+480
.word 1 // MODELPAR.LARPEGEF
.org md2asm_owned_io_server_namespace+488
.fill 16,1,32 // MODELPAR.CNMEXP
.org md2asm_owned_io_server_namespace+540
.fill 64,1,32 // MODELPAR.CMODEL
.org md2asm_owned_io_server_namespace+612
.word -99,-99,-99,-99,-99,-99 // MODELPAR.YFAGIOT_ARGS six integers
.org md2asm_owned_io_server_namespace+640
.word -99,-99,-99,-99,-99 // MODELPAR.YFRAME five integer parameters
.org md2asm_owned_io_server_namespace+792
.double -99.0,-99.0,-99.0,-99.0,-99.0 // YFRAME.RSLAPO/RCLOPO/RSLOPO/RCODIL/RREFER
.org md2asm_owned_io_server_namespace+1024
.fill 32,1,32 // MODELPAR.YFRAME.CNC
.org md2asm_owned_io_server_namespace+1068
.fill 20,1,32 // MODELPAR.YPARAM.CFPDOM
.org md2asm_owned_io_server_namespace+1240
.word -99,-99,-99,-99,-99,-99 // MODELPAR.YECGRIB six handle identifiers
.org md2asm_owned_io_server_namespace+2536
.word -99,-99 // MODELPAR.YWAM two handle identifiers
.org md2asm_owned_io_server_namespace+3456
.double -1.0,-1.0,-1.0,-1.0,-1.0 // PIOPROCR_MDL/PIOPROC1_MDL/PIOPROC2_MDL/PIOPROC1_FLP/PIOPROC2_FLP
.org md2asm_owned_io_server_namespace+3584
.fill 256,1,32 // CIFDIR
.ascii "."
.fill 255,1,32 // COFDIR
.ascii "."
.fill 255,1,32 // COXMLDIR
.org md2asm_owned_io_server_namespace+4360
.word 1 // LIO_SERV_UVSIF
.org md2asm_owned_io_server_namespace+4456
.size md2asm_owned_io_server_namespace,4456
.global __yomio_serv_MOD_io_serv_c001
.type __yomio_serv_MOD_io_serv_c001,%object
.set __yomio_serv_MOD_io_serv_c001,md2asm_owned_io_server_namespace
.size __yomio_serv_MOD_io_serv_c001,4456
.section .note.GNU-stack,"",%progbits
