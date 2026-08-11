# NVIDIA Container Toolkit (GPU support)

MochaNet runs on a KVM/QEMU VM (Ubuntu 24.04 x86_64) with an NVIDIA RTX
2080 Ti passed through, not a Raspberry Pi. `worker` and `immich` both need
GPU access inside their containers. This is the one-time host setup that
makes that work, same as the main homelab's `docker.md`.

Docker Engine itself is assumed already installed and working on this
host; this only covers registering the NVIDIA runtime with it.

## 1. Confirm the host driver works

```sh
nvidia-smi
```

This must succeed before continuing. If it does not, install/repair the
host NVIDIA driver first; the container toolkit only bridges an existing
host driver into containers, it does not install one.

## 2. Install the NVIDIA Container Toolkit

```sh
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

This registers the `nvidia` runtime and updates
`/etc/docker/daemon.json` with a `runtimes` block:

```json
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "args": []
    }
  }
}
```

## 3. Verify GPU access in a container

```sh
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

## Compose form used here

Both `worker` (`stacks/worker/docker-compose.yml`) and `immich`
(`stacks/immich/docker-compose.yml`) request the GPU with the
`deploy.resources.reservations.devices` form:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities:
            - gpu
```

There is only one GPU on this host, so neither stack pins a specific
`device_ids`; `count: 1` just makes the card visible to the container, it
does not lock it exclusively, so both stacks can use it concurrently. The
other compose form some images expect, `runtime: nvidia` on the service
directly, is not used by any stack here yet, but would need the same
one-time host setup above.
