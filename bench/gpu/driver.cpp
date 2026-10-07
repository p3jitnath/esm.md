// Host-only CUDA driver glue: allocation, copies, ordered launches and events.
// This file contains no model arithmetic or boundary calculation.
#include <cuda.h>
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
    CUfunction halo, prepare, faces, update;
    int model, fused, block;
};
struct Graph { CUgraph graph; CUgraphExec execution; };

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
    check(cuModuleGetFunction(&m->update, m->module, (prefix+"update").c_str()));
    if (!model) check(cuModuleGetFunction(&m->prepare, m->module, "sw_prepare"));
    if (model && !fused) check(cuModuleGetFunction(&m->faces, m->module, "eb_faces"));
    *result=m;
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
static void step(Model *m, unsigned nx, unsigned ny, CUdeviceptr q, CUdeviceptr stage,
                 CUdeviceptr out, CUdeviceptr work, CUdeviceptr coeff, CUdeviceptr par) {
    if (m->model) {
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
        void *halo_q[]={&nx,&ny,&q};
        if (!m->fused) launch(m->halo,3*size,m->block,halo_q);
        CUdeviceptr input=q, output=stage;
        for (unsigned final=0; final<2; ++final) {
            void *prepare[]={&nx,&ny,&input,&work,&par};
            launch(m->prepare,size,m->block,prepare);
            void *args[]={&nx,&ny,&input,&q,&output,&work,&par,&final};
            launch(m->update,nx*ny,m->block,args);
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
    for (unsigned k=0; k<steps; ++k) {
        step(m,nx,ny,q,stage,out,work,coeff,par);
        std::swap(q,out);
    }
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
