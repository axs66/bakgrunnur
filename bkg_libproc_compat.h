// Minimal libproc compatibility declarations for build without SDK headers
// Use at your own risk; these are private APIs on iOS.
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Action values for CPU throttling API (private)
#ifndef PROC_SETCPU_ACTION_THROTTLE
#define PROC_SETCPU_ACTION_THROTTLE 1
#endif

// Throttle a process by percentage (0-100). Returns 0 on success.
int proc_setcpu_percentage(int pid, int action, int percentage);

// Clear CPU limits for a process. Returns 0 on success.
int proc_clear_cpulimits(int pid);

#ifdef __cplusplus
}
#endif


