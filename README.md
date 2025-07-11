# debug-tools

Small container image with common network, storage, kernel, k8s debug tools.

> This image is rebuilt weekly. The latest version is available in the [ghcr.io registry](https://github.com/users/mchmarny/packages/container/debug-tools/457818382?tag=latest). 

## tools

### networking
- [bind-tools](https://wiki.alpinelinux.org/wiki/Bind) – DNS utilities like `dig`, `nslookup`
- [curl](https://curl.se/docs/) – Transfer data with URLs
- [dhcping](https://github.com/troglobit/dhcping) – Ping DHCP servers
- [ethtool](https://man7.org/linux/man-pages/man8/ethtool.8.html) – Display/change NIC settings
- [fping](https://fping.org/) – Ping multiple hosts
- [iftop](http://www.ex-parrot.com/pdw/iftop/) – Display bandwidth usage
- [iperf3](https://iperf.fr/) – Network performance testing
- [iputils](https://wiki.linuxfoundation.org/networking/iputils) – Tools like `ping`, `traceroute`
- [mtr](https://github.com/traviscross/mtr) – `traceroute` + `ping` combined
- [netcat-openbsd](https://man.openbsd.org/nc.1) – TCP/UDP debugging tool
- [nmap](https://nmap.org/) – Network scanner
- [socat](http://www.dest-unreach.org/socat/) – Bidirectional data relay
- [tcpdump](https://www.tcpdump.org/) – Capture network traffic
- [tshark](https://tshark.dev/) – CLI packet capture
- [httpie](https://httpie.io/) – User-friendly HTTP client

### storage
- [file](https://man7.org/linux/man-pages/man1/file.1.html) – Identify file types
- [util-linux](https://en.wikipedia.org/wiki/Util-linux) – Disk tools (`lsblk`, `mount`, etc.)
- [lsof](https://man7.org/linux/man-pages/man8/lsof.8.html) – List open files
- [iotop](https://linux.die.net/man/1/iotop) – Monitor disk I/O
- [hdparm](https://linux.die.net/man/8/hdparm) – Disk performance tuning
- [smartmontools](https://www.smartmontools.org/) – Disk health monitoring
- [ncdu](https://dev.yorhel.nl/ncdu) – Disk usage analyzer
- [tar](https://www.gnu.org/software/tar/) – Archiving utility

### kernel/system
- [strace](https://strace.io/) – Trace system calls
- [procps](https://gitlab.com/procps-ng/procps) – Utilities like `ps`, `top`, `vmstat`
- [sysstat](https://github.com/sysstat/sysstat) – Tools like `iostat`, `mpstat`
- [htop](https://htop.dev/) – Interactive process viewer
- [lshw](https://ezix.org/project/wiki/HardwareLiSter) – Hardware inventory
- [dmidecode](https://linux.die.net/man/8/dmidecode) – BIOS/system info
- [numactl](https://man7.org/linux/man-pages/man8/numactl.8.html) – NUMA tuning

### kubernetes/cloud-native
- [jq](https://stedolan.github.io/jq/) – JSON processor
- [yq](https://mikefarah.gitbook.io/yq/) – YAML processor
- [openssh-client](https://www.openssh.com/) – SSH client
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) – Kubernetes CLI
- [helm](https://helm.sh/) – Kubernetes package manager
- [k9s](https://k9scli.io/) – Kubernetes TUI
- [cosign](https://docs.sigstore.dev/cosign/overview) – Container signing/verification
- [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) – OCI image operations

### amd64-only
- [dstat](https://github.com/dagwieers/dstat) – Resource statistics
- [stern](https://github.com/stern/stern) – Tail logs from multiple pods
- [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html) – NVIDIA GPU containers
- [nvidia-smi](https://developer.nvidia.com/nvidia-system-management-interface) – GPU monitoring tool
- [nvtop](https://github.com/Syllo/nvtop) – Top-like GPU monitoring

## usage 

To run this image in your cluster on a specific node:

```shell
kubectl run -it --rm debug \
  --image=ghcr.io/mchmarny/debug-tools:latest \
  --restart=Never \
  --overrides='{ "apiVersion": "v1", "spec": { "nodeName": "10.0.130.223" } }' \
  -- bash
```

> Note: This image runs as root to support system-level debugging (network, storage, kernel).

## verification

This image includes [SBOM](https://www.cisa.gov/sbom) in [SPDX v2.3](https://spdx.github.io/spdx-spec/v2.3/) and [SLSA provenance attestation](https://slsa.dev/spec/v1.0/provenance) embedded in the container itself to enable you to verify that it was:

* Built in a trusted GitHub Actions workflow
* Free from tampering after the build
* Pushed to the intended registry by the owner of this repository

> Note, requires [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) and [jq](https://jqlang.github.io/jq/)

Start by capturing the digest of the image: 

```shell
export IMAGE=$(crane digest --full-ref ghcr.io/mchmarny/debug-tools:latest)
```

Inspect the image manifest:

```shell
crane manifest "$IMAGE" | jq .
```

The output will have multiple manifests. For each supported architecture there will be manifests for both the image itself and its attestation:

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "manifests": [
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "digest": "sha256:4ca77c3df87bc41791220d1760dd1ec2cb3629fd64f86e16d98223dde5bd7b88",
      "size": 1596,
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "digest": "sha256:775966c9516a426a1c55a37a96554bc262deb01550986cd11cde3c2bd5e432a0",
      "size": 1596,
      "platform": {
        "architecture": "arm64",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "digest": "sha256:148926e1cbb3b259010ab29bebe15fd11c171bcdfd33336fcb76d87dafb42a31",
      "size": 841,
      "annotations": {
        "vnd.docker.reference.digest": "sha256:4ca77c3df87bc41791220d1760dd1ec2cb3629fd64f86e16d98223dde5bd7b88",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      }
    },
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "digest": "sha256:49fc792fe19f8e694bce1579f8fab6697294455f878a1b095487093c99b3884c",
      "size": 841,
      "annotations": {
        "vnd.docker.reference.digest": "sha256:775966c9516a426a1c55a37a96554bc262deb01550986cd11cde3c2bd5e432a0",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      }
    }
  ],
  "annotations": {
    "org.opencontainers.image.created": "2025-07-11T11:54:59.934Z",
    "org.opencontainers.image.description": "",
    "org.opencontainers.image.licenses": "Apache-2.0",
    "org.opencontainers.image.revision": "6d77e40b7160fda17267414e5e48cdbd32de9a0e",
    "org.opencontainers.image.source": "https://github.com/mchmarny/debug-tools",
    "org.opencontainers.image.title": "debug-tools",
    "org.opencontainers.image.url": "https://github.com/mchmarny/debug-tools",
    "org.opencontainers.image.version": "main"
  }
}
```

Choose the architecture you want to verify attestation for (e.g. `arm64`) and download its manifest:

```shell
crane manifest ghcr.io/mchmarny/debug-tools@sha256:49fc792fe19f8e694bce1579f8fab6697294455f878a1b095487093c99b3884c
```

This will output something like this: 

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": {
    "mediaType": "application/vnd.oci.image.config.v1+json",
    "digest": "sha256:4da59e7c073c571e70938916bb0460182c72d39d4a5cd6610cf396e2bd48d802",
    "size": 241
  },
  "layers": [
    {
      "mediaType": "application/vnd.in-toto+json",
      "digest": "sha256:618f763df8b0bc534dbc513a32d9563c6b13994fdf6bc7cf686e33356c1b06f6",
      "size": 7434213,
      "annotations": {
        "in-toto.io/predicate-type": "https://spdx.dev/Document"
      }
    },
    {
      "mediaType": "application/vnd.in-toto+json",
      "digest": "sha256:2205730e8243c2f26e8d8b4911af75454fb73c4756804abd03ab4e6178ddaf8e",
      "size": 11770,
      "annotations": {
        "in-toto.io/predicate-type": "https://slsa.dev/provenance/v0.2"
      }
    }
  ]
}
```

Now you can download the actual [SBOM](https://www.cisa.gov/sbom) in [SPDX v2.3](https://spdx.github.io/spdx-spec/v2.3/) (using digest for annotations predicate: `https://spdx.dev/Document`) which includes:

* Packages (e.g. `bash`, `curl`, `jq`, etc.)
* Versions (e.g. `bash:5.2.15`, `curl:8.5.0`, etc.)
* Licenses (e.g. `GPL-2.0`, `Apache-2.0`, etc.)
* Source (e.g. `Alpine package repository`)
* Hashes - SHA256 checksums for individual files
* Dependencies - Which packages depend on which others

```shell
crane blob ghcr.io/mchmarny/debug-tools@sha256:618f763df8b0bc534dbc513a32d9563c6b13994fdf6bc7cf686e33356c1b06f6 > sbom.json
```

And the [SLSA provenance attestation](https://slsa.dev/spec/v1.0/provenance) (using digest for annotations predicate: `https://slsa.dev/provenance/v0.2`) which includes:

* The details of the trusted GitHub Actions workflow where the image was built
* The exact source repo, commit, and builder information
* The Dockerfile that was used to build that image

```shell
crane blob ghcr.io/mchmarny/debug-tools@sha256:2205730e8243c2f26e8d8b4911af75454fb73c4756804abd03ab4e6178ddaf8e > provenance.json
```

## disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.