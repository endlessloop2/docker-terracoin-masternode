IoPd for Docker
===================

Docker image that runs the IoP daemon

Quick Start
-----------

```bash
docker run \
  -d \
  -v /some/directory:/iopd \
  -p 8333:8333 \
  -p 8332:8332 \
  -p 4877:4877 \
  -e DISABLEWALLET=0 \
  --name=iopd \
  guggero/iopd
```
