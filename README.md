# debug-tools

Small image to debug issues in Kubernetes environment.

> The debug tools image is rebuilt every week. You can find the latest in [ghcr.io registry](https://github.com/users/mchmarny/packages/container/debug-tools/457818382?tag=latest). 

## usage 

To use this image in your cluster on specific node:

```shell
kubectl run -it --rm debug \
  --image=ghcr.io/mchmarny/debug-tools:latest \
  --restart=Never \
  --overrides='{ "apiVersion": "v1", "spec": { "nodeName": "10.0.130.223" } }' \
  -- bash
```

## verification

The `debug-tools` images comes with SLSA provenance using cosign attestation


## disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.