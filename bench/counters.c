// Read a per-thread PMU group around the numerical operation, excluding operating-system work.
// The seven output words are count, enabled time, running time, and four events.
#define _GNU_SOURCE
#include <errno.h>
#include <linux/perf_event.h>
#include <stdint.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>

static int descriptors[4] = {-1, -1, -1, -1};
static uint64_t previous_time[2];

int counters_open(void) {
    if (descriptors[0] >= 0) return 0;
    const uint32_t types[4] = {PERF_TYPE_HARDWARE, PERF_TYPE_HARDWARE,
                               PERF_TYPE_RAW, PERF_TYPE_RAW};
    const uint64_t events[4] = {PERF_COUNT_HW_CPU_CYCLES,
                                PERF_COUNT_HW_INSTRUCTIONS, 0x03, 0x17};
    for (int i = 0; i < 4; ++i) {
        struct perf_event_attr attr;
        memset(&attr, 0, sizeof(attr));
        attr.size = sizeof(attr);
        attr.type = types[i];
        attr.config = events[i];
        attr.disabled = (i == 0);
        attr.exclude_kernel = 1;
        attr.exclude_hv = 1;
        attr.read_format = PERF_FORMAT_GROUP | PERF_FORMAT_TOTAL_TIME_ENABLED |
                           PERF_FORMAT_TOTAL_TIME_RUNNING;
        descriptors[i] = syscall(SYS_perf_event_open, &attr, 0, -1,
                                 i ? descriptors[0] : -1, PERF_FLAG_FD_CLOEXEC);
        if (descriptors[i] < 0) {
            const int saved = errno;
            for (int j = 0; j < i; ++j) {
                close(descriptors[j]);
                descriptors[j] = -1;
            }
            errno = saved;
            return -1;
        }
    }
    return 0;
}

int counters_begin(void) {
    if (counters_open() < 0) return -1;
    if (ioctl(descriptors[0], PERF_EVENT_IOC_RESET, PERF_IOC_FLAG_GROUP) < 0)
        return -1;
    uint64_t baseline[7];
    if (read(descriptors[0], baseline, sizeof(baseline)) != sizeof(baseline)
        || baseline[0] != 4) {
        errno = EIO;
        return -1;
    }
    // Reset clears event counts but leaves cumulative enabled and running time.
    previous_time[0] = baseline[1];
    previous_time[1] = baseline[2];
    return ioctl(descriptors[0], PERF_EVENT_IOC_ENABLE, PERF_IOC_FLAG_GROUP);
}

int counters_end(uint64_t result[7]) {
    if (ioctl(descriptors[0], PERF_EVENT_IOC_DISABLE, PERF_IOC_FLAG_GROUP) < 0)
        return -1;
    if (read(descriptors[0], result, 7 * sizeof(uint64_t)) != 7 * sizeof(uint64_t)
        || result[0] != 4) {
        errno = EIO;
        return -1;
    }
    result[1] -= previous_time[0];
    result[2] -= previous_time[1];
    if (result[1] != result[2]) {
        errno = EAGAIN;
        return -1;
    }
    return 0;
}
