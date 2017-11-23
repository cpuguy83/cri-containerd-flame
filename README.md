# cri-containerd-flame
Generate flamegraphs from cri-containerd using bucketbench to drive workloads

Requirements:

- Docker >= 17.09
- make

### Usage:

```
make
```

This will both output the bucketbench results to stdout and create a flamegraph in `./run/torch.svg`

To modify the workload being used, customize the `bench.yaml` file. This is a configuration for [bucketbench](github.com/estesp/bucketbench).
You can also customize the repos/commits used for containerd and cri-containerd like so:

```
$ make \
  cri_build_args="--build-arg CRI_CONTAINERD_REPO=<repo> CRI_CONTAINERD_BRANCH=<branch> CRI_CONTAINERD_COMMIT=<sha>" \
  c8d_build_args="--build-arg CONTAINERD_REPO=<repo> CCONTAINERD_BRANCH=<branch> CONTAINERD_COMMIT=<sha>"
```

Clean up with `make clean`

You can change the output dir of the flamegraph by setting `PREFIX`.
You can change the timing of the CPU profile used to generate the flamegraph with `PROFILE_SECONDS`. Note that you'll need to make sure the bucketbench run is going to run for as long as you need.
