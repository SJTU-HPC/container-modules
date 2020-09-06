# Container Environment Modules for SJTU PI

> This repo is originated from [ngc-container-environment-modules](https://github.com/NVIDIA/ngc-container-environment-modules).

Container environment modules are lightweight wrappers that make
it possible to transparently use containers as environment modules.

- Use familiar environment module commands, ensuring a minimal
  learning curve or change to existing workflows

- Leverage all the benefits of containers, including portability and
  reproducibility

- Take advantage of the optimized HPC and Deep Learning containers

## Prerequisites

- [Lmod](https://lmod.readthedocs.io/en/latest/)
- [Singularity](https://sylabs.io/guides/latest/user-guide/) 3.6.0 or later

## Management

You can run the command below to pull and update all container images.

```shell
./manage.py update
```

Or, you can pull and update selected container images.

```shell
./manage.py update -n pytorch -t 1.6.0
```