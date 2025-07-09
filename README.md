# debug-tools

Small image to debug issues in Kubernetes environment.

## Image 

Created by this repo:

```shell
export DEBUG_IMAGE="ghcr.io/mchmarny/debug-tools"
export IMAGE_DIGEST="sha256:f3dd06e39557e4786377ecf56e3b806795bf04518533612251ad2496934f6f76"
export IMAGE_URI="${DEBUG_IMAGE}@${IMAGE_DIGEST}"
```

## Verify 

To verify attestation (SBOM) and download it locally to review: 

> The public key used to sign the image attestation is located in the root of this repo.

```shell
cosign verify-attestation --type cyclonedx --key cosign.pub $IMAGE_URI \
		| jq -r '.payload | @base64d | fromjson | .predicate' > ./sbom.json
```

The `sbom.json` file output by the above command will include the complete [CycloneDX](https://cyclonedx.org/) v1.6 formatted SBOM wrapped in a CNCF [in-toto](in-toto.io) envelope.

Since CycloneDX files are JSON based, you can use `jq` to query over the SBOM file to list all the installed components: 

```shell
jq -r '{
  bomFormat: .bomFormat,
  schema: ."$schema",
  totalComponents: (.components | length),
  componentTypes: (.components | map(.type) | unique),
  packages: (.components | map({
    name: .name,
    version: .version,
    type: .type,
    purl: .purl
  }))
}' sbom.json
```

## Launch 

To use this image in your cluster on specific node:

```shell
kubectl run -it --rm debug --image=$IMAGE_URI --restart=Never --overrides='
{
  "apiVersion": "v1",
  "spec": {
    "nodeName": "10.0.130.223"
  }
}' -- bash
```

## disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.