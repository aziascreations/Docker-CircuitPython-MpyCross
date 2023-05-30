# Docker - CircuitPython's mpy-cross
Containerized version of [CircuitPython](https://github.com/adafruit/circuitpython)'s version of mpy-cross that
automatically compiles any script you give it.

## Usage
These examples assume you are using `./input` and `./output` as your input and output folders.

### Available versions
| Image & Tag                          | CircuitPython's release tag                                           |
|--------------------------------------|-----------------------------------------------------------------------|
| `aziascreations/mpy-cross-cpy:8.1.0` | [8.1.0](https://github.com/adafruit/circuitpython/releases/tag/8.1.0) |

All these images are also available for the following architectures:<br>
&nbsp;&nbsp;&nbsp;&nbsp;`linux/amd64`, `linux/arm64/v8`

### Docker CLI
Simply run the following command:
```bash
docker run \
    -v ./input:/data/input \
    -v ./output:/data/output \
    -e PUID=1000 \
    -e PGID=1000 \
    -e MPY_CROSS_EXTRA_ARGS=-O1 \
    aziascreations/cpy-mpy-cross:8.1.0
```

### Docker-compose
Prepare your `docker-compose.yml` file like so:
```yaml
version: "3"

services:
  mpy-cross-cpy:
    container_name: mpy-cross-cpy
    image: aziascreations/cpy-mpy-cross:8.1.0
    environment:
      # Custom UID and GID used when setting the ownership of the output files.
      # If not defined, UID=0 and GID=0 will be used.
      - PUID=1000
      - PGID=1000
      # Custom launch arguments passed as-is to `mpy-cross` for each file.
      # If only "-h" or "--help" is used, only the usage text will be shown.
      - "MPY_CROSS_EXTRA_ARGS=-O1"
    volumes:
      - ./input:/data/input
      - ./output:/data/output
    restart: "no"
```

And run the following command:
```bash
docker-compose up
```

### Environment variables
| Variable               | Description                                                           |
|------------------------|-----------------------------------------------------------------------|
| `PUID`                 | Custom UID to which the generated folders and files will be chown'ed. |
| `PGID`                 | Custom GID to which the generated folders and files will be chown'ed. |
| `MPY_CROSS_EXTRA_ARGS` | Custom launch arguments passed as-is to `mpy-cross` for each file.<br>If only "-h" or "--help" is used, only the usage text will be shown. |

## Building Locally

### Requirements
* ~6 GB of HDD space  *(Final image is <16 MiB)*
* ~500 MB of RAM
* A stable internet connection  *(See Dockerfile comments)*

### Cloning
```bash
git clone https://github.com/aziascreations/Docker-CircuitPython-MpyCross.git
cd Docker-CircuitPython-MpyCross
```

### Customization
If you want a specific or different version of CircuitPython's repository you will need to modify
the `CIRCUITPYTHON_GIT_TAG` build argument in [docker-compose.yml](docker-compose.yml).

### Building the image
Firstly, run the following command:
```
docker-compose up --build
```

Finally, wait for it to finish downloading and compiling everything.

This step can take a **long** time, here are some real-world examples:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&#126;10-12 minutes on an Intel i5-3470  *(Ubuntu 22.04.2 LTS x86_64)*<br>
&nbsp;&nbsp;&nbsp;&nbsp;&#126;? minutes on a Rockchip RK3399  *(Armbian 23.02.2 aarch64)*

### Failures
If you see an error message stating that `mpy-cross` cannot be compiled because of a missing module or dependency, you'll
need to restart the building process.

This is a not-so-uncommon issue caused by one of the steps failing silently for whatever reason when it cannot download
something in the `make fetch-submodules` command.

On my end, I get a ~15% failure rate at best and a ~75% one on bad days.<br>
My ISP is partly to blame with its frequent "micro cut-offs", but having to re-run the aforementionned command 20+
times to finally have a "complete" repo shouldn't have to be a solution, ever.

## License
The [Dockerfile](Dockerfile) and [docker-compose.yml](docker-compose.yml) files are licensed under the [Unlicense](LICENSE) license.

This license does not apply to mpy-cross as it is licensed under the [MIT License](LICENSE_CircuitPython).
