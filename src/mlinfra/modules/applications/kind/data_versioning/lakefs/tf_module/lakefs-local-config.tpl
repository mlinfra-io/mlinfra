database:
  type: "local"
  local:
    path: "~/lakefs/metadata"
    sync_writes: true
    prefetch_size: 256
    enable_logging: true

blockstore:
  type: "local"
  local:
    path: "~/lakefs/data"
