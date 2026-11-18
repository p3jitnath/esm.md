// Host-only CUDA driver glue: allocation, copies, ordered launches and events.
// This file contains no model arithmetic or boundary calculation.
#include <cuda.h>
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <stdexcept>
#include <string>

static CUcontext context;
static CUstream stream;
static CUevent started, stopped;
static std::string error;
static CUdevice selected;

static void check(CUresult result) {
    if (result == CUDA_SUCCESS) return;
    const char *name = nullptr, *description = nullptr;
    cuGetErrorName(result, &name);
    cuGetErrorString(result, &description);
    throw std::runtime_error(std::string(name ? name : "CUDA error") + ": " +
                             (description ? description : "unknown"));
}
#define API_BEGIN try { check(cuCtxSetCurrent(context));
#define API_END return 0; } catch (const std::exception &e) { error=e.what(); return 1; }

struct Model {
    CUmodule module;
    CUfunction halo, prepare, faces, update, persistent, complete, temporal, publish, components, small, medium, small_fused, temporal_eight;
    int model, fused, block;
    bool xy, clean;
    CUfunction small_tiled=nullptr; unsigned small_tile=0,small_threads=0;
    bool temporal_dynamic=false,large_dynamic=false;
    unsigned temporal_block=128, temporal_max=8, temporal_owned=96;
    CUfunction temporal_large=nullptr;
    unsigned large_block=256, large_max=16, large_owned=192;
};
struct Graph { CUgraph graph; CUgraphExec execution; };
struct Probe { CUmodule module; CUfunction function; };

extern "C" const char *gpu_error() { return error.c_str(); }
extern "C" int gpu_init(int device) {
    try {
        check(cuInit(0));
        check(cuDeviceGet(&selected, device));
        check(cuDevicePrimaryCtxRetain(&context, selected));
        check(cuCtxSetCurrent(context));
        check(cuStreamCreate(&stream, CU_STREAM_NON_BLOCKING));
        check(cuEventCreate(&started, CU_EVENT_DEFAULT));
        check(cuEventCreate(&stopped, CU_EVENT_DEFAULT));
        return 0;
    } catch (const std::exception &e) { error=e.what(); return 1; }
}
extern "C" std::uint64_t gpu_stream() { return reinterpret_cast<std::uint64_t>(stream); }
extern "C" int gpu_info(char *name, char *uuid) {
    API_BEGIN
    CUuuid id; check(cuDeviceGetUuid(&id,selected)); check(cuDeviceGetName(name,128,selected));
    const auto *b=reinterpret_cast<const unsigned char *>(id.bytes);
    std::snprintf(uuid,41,"GPU-%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
                  b[0],b[1],b[2],b[3],b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11],b[12],b[13],b[14],b[15]);
    API_END
}
extern "C" int gpu_set_stream(std::uint64_t value) {
    API_BEGIN
    check(cuStreamSynchronize(stream));
    check(cuStreamDestroy(stream));
    stream=reinterpret_cast<CUstream>(value);
    API_END
}
extern "C" int gpu_alloc(std::uint64_t bytes, std::uint64_t *pointer) {
    API_BEGIN
    check(cuMemAlloc(reinterpret_cast<CUdeviceptr *>(pointer), bytes));
    API_END
}
extern "C" int gpu_free(std::uint64_t pointer) {
    API_BEGIN
    check(cuMemFree(pointer));
    API_END
}
extern "C" int gpu_upload(std::uint64_t pointer, const void *host, std::uint64_t bytes) {
    API_BEGIN
    check(cuMemcpyHtoD(pointer, host, bytes));
    API_END
}
extern "C" int gpu_download(void *host, std::uint64_t pointer, std::uint64_t bytes) {
    API_BEGIN
    check(cuStreamSynchronize(stream));
    check(cuMemcpyDtoH(host, pointer, bytes));
    API_END
}
extern "C" int gpu_sync() { API_BEGIN check(cuStreamSynchronize(stream)); API_END }
extern "C" int gpu_model_open(const char *path, int model, int fused, int block, void **result) {
    API_BEGIN
    Model *m=new Model{};
    m->model=model; m->fused=fused; m->block=block;
    check(cuModuleLoad(&m->module, path));
    const std::string prefix=model ? "eb_" : "sw_";
    check(cuModuleGetFunction(&m->halo, m->module, (prefix+"halo").c_str()));
    if (!model && cuModuleGetFunction(&m->update,m->module,"sw_update_xy") == CUDA_SUCCESS) {
        m->xy=true;
    } else {
        check(cuModuleGetFunction(&m->update, m->module, (prefix+"update").c_str()));
    }
    if (!model) {
        if (cuModuleGetFunction(&m->prepare,m->module,"sw_prepare_clean") == CUDA_SUCCESS) {
            m->clean=true;
            check(cuModuleGetFunction(&m->halo,m->module,"sw_edges"));
        } else check(cuModuleGetFunction(&m->prepare,m->module,m->xy ? "sw_prepare_xy" : "sw_prepare"));
        if (cuModuleGetFunction(&m->components,m->module,"sw_update_components") != CUDA_SUCCESS) m->components=nullptr;
        if (cuModuleGetFunction(&m->small,m->module,"sw_update_small") != CUDA_SUCCESS) m->small=nullptr;
        if (cuModuleGetFunction(&m->small_fused,m->module,"sw_update_small_fused") != CUDA_SUCCESS) m->small_fused=nullptr;
        CUfunction tile_function=nullptr;
        if (cuModuleGetFunction(&tile_function,m->module,"sw_update_small_tiled4")==CUDA_SUCCESS) {
            m->small_tiled=tile_function; m->small_tile=4; m->small_threads=64;
        }
        if (cuModuleGetFunction(&tile_function,m->module,"sw_update_small_tiled8")==CUDA_SUCCESS) {
            m->small_tiled=tile_function; m->small_tile=8; m->small_threads=256;
        }
        if (cuModuleGetFunction(&tile_function,m->module,"sw_update_small_tiled2")==CUDA_SUCCESS) {
            m->small_tiled=tile_function; m->small_tile=2; m->small_threads=32;
        }
        if (cuModuleGetFunction(&m->medium,m->module,"sw_update_medium") != CUDA_SUCCESS) m->medium=nullptr;
    }
    if (model && fused) {
        if (cuModuleGetFunction(&m->persistent,m->module,"eb_persistent") != CUDA_SUCCESS) m->persistent=nullptr;
        if (cuModuleGetFunction(&m->complete,m->module,"eb_complete") != CUDA_SUCCESS) m->complete=nullptr;
        if (cuModuleGetFunction(&m->temporal,m->module,"eb_temporal") != CUDA_SUCCESS) m->temporal=nullptr;
        if (cuModuleGetFunction(&m->temporal_eight,m->module,"eb_temporal_eight") != CUDA_SUCCESS) m->temporal_eight=nullptr;
        struct Tile { const char *name; unsigned block, maximum, owned; };
        const Tile candidates[] = {{"eb_temporal_128_16",128,16,64},{"eb_temporal_256_8",256,8,224},{"eb_temporal_256_16",256,16,192},{"eb_temporal_256_32",256,32,128},{"eb_temporal_512_16",512,16,448},{"eb_temporal_512_32",512,32,384},{"eb_temporal_128_24",128,24,32},{"eb_temporal_128_28",128,28,16},{"eb_temporal_256_24",256,24,160},{"eb_temporal_256_48",256,48,64},{"eb_temporal_512_64",512,64,256},{"eb_temporal_256_40",256,40,96},{"eb_temporal_256_50",256,50,56},{"eb_temporal_256_56",256,56,32},{"eb_temporal_512_48",512,48,320},{"eb_temporal_512_96",512,96,128},{"eb_temporal_1024_64",1024,64,768},{"eb_temporal_1024_128",1024,128,512}};
        for (const auto &candidate : candidates) {
            CUfunction function=nullptr;
            if (cuModuleGetFunction(&function,m->module,candidate.name)==CUDA_SUCCESS) {
                m->temporal_eight=function;
                m->temporal_block=candidate.block;
                m->temporal_max=candidate.maximum;
                m->temporal_owned=candidate.owned;
            }
        }
        CUfunction short_tile=nullptr,large_tile=nullptr;
        if (cuModuleGetFunction(&short_tile,m->module,"eb_temporal_256_32")==CUDA_SUCCESS &&
            cuModuleGetFunction(&large_tile,m->module,"eb_temporal_256_16")==CUDA_SUCCESS) {
            m->temporal_eight=short_tile;
            m->temporal_block=256; m->temporal_max=32; m->temporal_owned=128;
            m->temporal_large=large_tile;
        }
        CUfunction short_final=nullptr,large_final=nullptr;
        if (cuModuleGetFunction(&short_final,m->module,"eb_temporal_256_56")==CUDA_SUCCESS &&
            cuModuleGetFunction(&large_final,m->module,"eb_temporal_1024_128")==CUDA_SUCCESS) {
            m->temporal_eight=short_final;
            m->temporal_block=256; m->temporal_max=56; m->temporal_owned=32;
            m->temporal_large=large_final;
            m->large_block=1024; m->large_max=128; m->large_owned=512;
        }
        CUfunction short_dynamic=nullptr,large_dynamic=nullptr;
        if (cuModuleGetFunction(&short_dynamic,m->module,"eb_temporal_dynamic_256_56")==CUDA_SUCCESS &&
            cuModuleGetFunction(&large_dynamic,m->module,"eb_temporal_dynamic_1024_128")==CUDA_SUCCESS) {
            m->temporal_eight=short_dynamic;
            m->temporal_block=256; m->temporal_max=56; m->temporal_owned=32;
            m->temporal_large=large_dynamic;
            m->large_block=1024; m->large_max=128; m->large_owned=512;
            m->temporal_dynamic=true; m->large_dynamic=true;
        }
        if (cuModuleGetFunction(&m->publish,m->module,"eb_publish") != CUDA_SUCCESS) m->publish=nullptr;
        if ((m->temporal || m->temporal_eight) && !m->publish) throw std::runtime_error("Temporal integration requires its publication kernel");
    }
    if (model && !fused) check(cuModuleGetFunction(&m->faces, m->module, "eb_faces"));
    *result=m;
    API_END
}
extern "C" int gpu_model_temporal_layout(void *value, unsigned nx, unsigned *threads, unsigned *maximum, unsigned *owned) {
    API_BEGIN
    auto *m=static_cast<Model *>(value);
    *maximum=0; *owned=0; *threads=m->block;
    if (m->model && nx>128 && (m->temporal || m->temporal_eight)) {
        const bool large=nx>8192 && m->temporal_large;
        *maximum=large ? m->large_max : m->temporal_eight ? m->temporal_max : 4u;
        *owned=large ? m->large_owned : m->temporal_eight ? m->temporal_owned : 112u;
        *threads=large ? m->large_block : m->temporal_block;
    }
    API_END
}
extern "C" int gpu_model_layout_flags(void *value,unsigned nx,unsigned ny,unsigned *tile,unsigned *dynamic) {
    API_BEGIN
    auto *m=static_cast<Model *>(value);
    *tile=!m->model && nx*ny<=4096 ? m->small_tile : 0;
    *dynamic=m->model && nx>128 ? (nx>8192 && m->temporal_large ? m->large_dynamic : m->temporal_dynamic) : 0;
    API_END
}
extern "C" int gpu_model_close(void *value) {
    API_BEGIN
    auto *m=static_cast<Model *>(value);
    check(cuStreamSynchronize(stream)); check(cuModuleUnload(m->module)); delete m;
    API_END
}
static void launch(CUfunction f, unsigned count, unsigned block, void **args) {
    check(cuLaunchKernel(f, (count+block-1)/block,1,1,block,1,1,0,stream,args,nullptr));
}
static void launch_xy(CUfunction f, unsigned columns, unsigned rows, unsigned block, void **args) {
    check(cuLaunchKernel(f,(columns+block-1)/block,rows,1,block,1,1,0,stream,args,nullptr));
}
static void step(Model *m, unsigned nx, unsigned ny, CUdeviceptr q, CUdeviceptr stage,
                 CUdeviceptr out, CUdeviceptr work, CUdeviceptr coeff, CUdeviceptr par) {
    if (m->model) {
        if (m->complete) {
            void *args[]={&nx,&q,&stage,&out,&work,&coeff,&par};
            launch(m->complete,nx,m->block,args);
            return;
        }
        void *halo_q[]={&nx,&q};
        if (m->fused != 1) launch(m->halo,2,32,halo_q);
        CUdeviceptr input=q, output=stage;
        for (unsigned final=0; final<2; ++final) {
            if (!m->fused) {
                void *face_args[]={&nx,&input,&work,&coeff};
                launch(m->faces,nx+1,m->block,face_args);
            }
            void *args[]={&nx,&input,&q,&output,&work,&coeff,&par,&final};
            launch(m->update,nx,m->block,args);
            void *halo[]={&nx,&output};
            if (m->fused != 1) launch(m->halo,2,32,halo);
            input=stage; output=out;
        }
    } else {
        const unsigned size=(nx+2)*(ny+2);
        const bool small=(m->small || m->small_fused || m->small_tiled) && nx*ny <= 4096;
        const bool medium=m->medium && nx*ny > 4096 && nx*ny <= 65536;
        const unsigned block=small && m->small_tiled ? m->small_threads : medium || (small && m->small_fused) ? 128 : m->block;
        void *halo_q[]={&nx,&ny,&q};
        if (!m->fused) launch(m->halo,3*size,m->block,halo_q);
        CUdeviceptr input=q, output=stage;
        for (unsigned final=0; final<2; ++final) {
            void *prepare[]={&nx,&ny,&input,&work,&par};
            if (!(small && (m->small_fused || m->small_tiled))) {
                if (m->xy && !m->clean) launch_xy(m->prepare,nx+2,ny+2,m->block,prepare);
                else launch(m->prepare,size,block,prepare);
            }
            void *args[]={&nx,&ny,&input,&q,&output,&work,&par,&final};
            if (small && m->small_tiled) check(cuLaunchKernel(m->small_tiled,(nx+m->small_tile-1)/m->small_tile,(ny+m->small_tile-1)/m->small_tile,1,block,1,1,0,stream,args,nullptr));
            else if (small) check(cuLaunchKernel(m->small_fused ? m->small_fused : m->small,(nx*ny+block-1)/block,1,3,block,1,1,0,stream,args,nullptr));
            else if (medium) launch_xy(m->medium,nx,ny,block,args);
            else if (m->components) check(cuLaunchKernel(m->components,(nx*ny+m->block-1)/m->block,1,3,m->block,1,1,0,stream,args,nullptr));
            else if (m->xy) launch_xy(m->update,nx,ny,m->block,args);
            else launch(m->update,nx*ny,m->block,args);
            void *halo[]={&nx,&ny,&output};
            if (!m->fused) launch(m->halo,3*size,m->block,halo);
            input=stage; output=out;
        }
    }
}
extern "C" int gpu_enqueue(void *model, unsigned nx, unsigned ny, std::uint64_t q,
    std::uint64_t stage, std::uint64_t out, std::uint64_t work, std::uint64_t coeff,
    std::uint64_t par, unsigned steps) {
    API_BEGIN
    auto *m=static_cast<Model *>(model);
    const unsigned block=m->small_tiled && nx*ny<=4096 ? m->small_threads : (m->medium && nx*ny > 4096 && nx*ny <= 65536) || (m->small_fused && nx*ny<=4096) ? 128 : m->block;
    if (steps && m->clean) {
        void *args[]={&nx,&ny,&q};
        launch(m->halo,3*(2*(nx+2)+2*ny),block,args);
    }
    if (steps && m->persistent && nx <= 128) {
        void *args[]={&nx,&q,&stage,&out,&work,&coeff,&par,&steps};
        launch(m->persistent,128,128,args);
        return 0;
    }
    if (steps && (m->temporal || m->temporal_eight)) {
        // Each tile keeps q immutable until every block has finished.
        // Publication restores the required physical q/out parity on the GPU.
        const bool large=nx>8192 && m->temporal_large;
        const unsigned maximum=large ? m->large_max : m->temporal_eight ? m->temporal_max : 4u;
        const unsigned owned=large ? m->large_owned : m->temporal_eight ? m->temporal_owned : 112u;
        const CUfunction temporal=large ? m->temporal_large : m->temporal_eight ? m->temporal_eight : m->temporal;
        const unsigned threads=large ? m->large_block : m->temporal_block;
        for (unsigned first=0; first<steps; first+=maximum) {
            unsigned count=std::min(maximum,steps-first);
            void *args[]={&nx,&q,&stage,&out,&work,&coeff,&par,&count};
            const bool dynamic=large ? m->large_dynamic : m->temporal_dynamic;
            const unsigned batch_owned=dynamic ? threads-4*count : owned;
            check(cuLaunchKernel(temporal,(nx+batch_owned-1)/batch_owned,1,1,threads,1,1,0,stream,args,nullptr));
            void *publish[]={&nx,&q,&out,&work,&count};
            launch(m->publish,nx,128,publish);
        }
        return 0;
    }
    for (unsigned k=0; k<steps; ++k) {
        step(m,nx,ny,q,stage,out,work,coeff,par);
        std::swap(q,out);
    }
    API_END
}
extern "C" int gpu_model_layout(void *model,unsigned nx,unsigned ny,int *block,int *grid_y,int *grid_z) {
    API_BEGIN
    auto *m=static_cast<Model *>(model);
    *block=m->block; *grid_y=1; *grid_z=1;
    if (m->model && m->persistent && nx <= 128) *block=128;
    else if (!m->model && m->small_tiled && nx*ny<=4096) { *block=m->small_threads; *grid_y=(ny+m->small_tile-1)/m->small_tile; }
    else if (!m->model && (m->small || m->small_fused) && nx*ny <= 4096) { *block=m->small_fused ? 128 : m->block; *grid_z=3; }
    else if (!m->model && m->medium && nx*ny <= 65536) { *block=128; *grid_y=ny; }
    else if (m->components) *grid_z=3;
    else if (m->xy) *grid_y=ny;
    API_END
}
extern "C" int gpu_capture_begin() {
    API_BEGIN check(cuStreamBeginCapture(stream, CU_STREAM_CAPTURE_MODE_GLOBAL)); API_END
}
extern "C" int gpu_capture_end(void **value) {
    API_BEGIN
    auto *g=new Graph{};
    check(cuStreamEndCapture(stream, &g->graph));
    check(cuGraphInstantiate(&g->execution,g->graph,0));
    *value=g;
    API_END
}
extern "C" int gpu_graph_nodes(void *value, std::uint64_t *count) {
    API_BEGIN
    std::size_t n=0; check(cuGraphGetNodes(static_cast<Graph *>(value)->graph,nullptr,&n));
    *count=n;
    API_END
}
extern "C" int gpu_graph_launch(void *value) {
    API_BEGIN check(cuGraphLaunch(static_cast<Graph *>(value)->execution,stream)); API_END
}
extern "C" int gpu_graph_time(void *value, float *milliseconds) {
    API_BEGIN
    check(cuEventRecord(started,stream));
    check(cuGraphLaunch(static_cast<Graph *>(value)->execution,stream));
    check(cuEventRecord(stopped,stream)); check(cuEventSynchronize(stopped));
    check(cuEventElapsedTime(milliseconds,started,stopped));
    API_END
}
extern "C" int gpu_graph_close(void *value) {
    API_BEGIN
    auto *g=static_cast<Graph *>(value);
    check(cuStreamSynchronize(stream)); check(cuGraphExecDestroy(g->execution));
    check(cuGraphDestroy(g->graph)); delete g;
    API_END
}
extern "C" int gpu_probe_open(const char *path,const char *symbol,void **value) {
    API_BEGIN
    auto *p=new Probe{};
    check(cuModuleLoad(&p->module,path));
    check(cuModuleGetFunction(&p->function,p->module,symbol));
    *value=p;
    API_END
}
extern "C" int gpu_probe_launch(void *value,unsigned n,unsigned iterations,
    std::uint64_t a,std::uint64_t b,std::uint64_t out,unsigned block) {
    API_BEGIN
    if (n) {
        void *args[]={&n,&iterations,&a,&b,&out};
        launch(static_cast<Probe *>(value)->function,n,block,args);
    }
    API_END
}
extern "C" int gpu_probe_close(void *value) {
    API_BEGIN
    auto *p=static_cast<Probe *>(value);
    check(cuStreamSynchronize(stream)); check(cuModuleUnload(p->module)); delete p;
    API_END
}
extern "C" int gpu_probe_attributes(void *value,int *registers,int *shared,int *multiprocessors) {
    API_BEGIN
    auto *p=static_cast<Probe *>(value);
    check(cuFuncGetAttribute(registers,CU_FUNC_ATTRIBUTE_NUM_REGS,p->function));
    check(cuFuncGetAttribute(shared,CU_FUNC_ATTRIBUTE_SHARED_SIZE_BYTES,p->function));
    check(cuDeviceGetAttribute(multiprocessors,CU_DEVICE_ATTRIBUTE_MULTIPROCESSOR_COUNT,selected));
    API_END
}
