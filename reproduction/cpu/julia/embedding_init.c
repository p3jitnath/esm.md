#include <julia.h>
#include <stdlib.h>
#include <string.h>
void fresh_julia_init(void) {
    int argc=6;
    char **argv=(char **)calloc(7,sizeof(char *));
    const char *args[]={"julia","-O3","--math-mode=ieee","--cpu-target=neoverse-v2","--threads=1","--gcthreads=1"};
    for(int i=0;i<argc;i++) argv[i]=strdup(args[i]);
    jl_parse_opts(&argc,&argv);
    jl_init();
}
