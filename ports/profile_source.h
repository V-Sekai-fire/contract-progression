#ifndef PROFILE_SOURCE_H
#define PROFILE_SOURCE_H
#include <stdint.h>
/* Driving port. A profile load at login. */
typedef struct profile_source {
  void *ctx;
  int (*load)(void *ctx, uint8_t *out, uint32_t cap, uint32_t *len);
} profile_source;
#endif
