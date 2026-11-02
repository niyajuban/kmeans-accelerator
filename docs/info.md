## How it works
This chip is a custom hardware accelerator for the K-Means clustering algorithm.
It evaluates distances to two cluster centroids concurrently using pipelined subtract-square-accumulate units, then uses a comparator to output the closest cluster ID.

## How to test
Apply a clock and release reset. Feed coordinate Px on `ui_in` and Py on `uio_in`. After a 4-cycle pipeline latency, `uo_out[0]` indicates the cluster assignment (0 or 1).
