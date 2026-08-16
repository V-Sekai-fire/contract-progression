#ifndef COMMIT_SINK_H
#define COMMIT_SINK_H
#include <stdint.h>
/* Driven port. A durable write of the profile and the inventory. Adapters:
   zone-backend + cockroach (the durable store) or feat/module-sqlite (the
   instance cache and the degraded commit). */
typedef struct commit_sink {
  void *ctx;
  int (*commit)(void *ctx, const uint8_t *profile_bytes, uint32_t len);
} commit_sink;
#endif
