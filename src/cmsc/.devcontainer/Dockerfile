# Build stage for Criterion; only the installed files are copied into the
# final image below, so the build tools do not end up in the dev container.
FROM ubuntu:24.04 AS criterion-build

ARG CRITERION_VERSION=2.4.3
ARG CRITERION_SHA256=8ec64e482a70b3bfc1836ace0988b3316e6c3cfeac883fb5a674dcea5083ea16

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        xz-utils \
        build-essential \
        cmake \
        meson \
        ninja-build \
        pkg-config \
        libffi-dev \
        libgit2-dev

# Ubuntu's Criterion package (2.4.1) crashes when running chiTCP's tests
# ("Re-entering criterion from a test worker"), so build Criterion 2.4.3 from
# source instead. Upstream only provides prebuilt binaries for x86_64, and
# building from source also works on ARM (e.g., Apple Silicon Macs).
WORKDIR /tmp/criterion
RUN wget -q "https://github.com/Snaipe/Criterion/releases/download/v${CRITERION_VERSION}/criterion-${CRITERION_VERSION}.tar.xz" && \
    echo "${CRITERION_SHA256}  criterion-${CRITERION_VERSION}.tar.xz" | sha256sum -c - && \
    tar xf "criterion-${CRITERION_VERSION}.tar.xz" && \
    cd "criterion-${CRITERION_VERSION}" && \
    meson setup build --prefix=/usr/local --buildtype=release -Dtests=false -Dsamples=false && \
    meson compile -C build && \
    DESTDIR=/criterion-install meson install -C build


FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Basic tools
		ca-certificates \
		curl \
		wget \
        # C/C++    
        make \
        build-essential \
        cmake \
        cppcheck \
        valgrind \
        clang \
        lldb \
        llvm \
        gdb \
        pkg-config \
        # Runtime dependencies of Criterion (built above)
        libffi8 \
        libgit2-1.7 \
        # chiTCP
        protobuf-c-compiler \
        libprotobuf-c-dev \
        # Python
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        python-is-python3 \
        # Git
        git \
        # Utilities
        vim \ 
        emacs \
        tmux \
        figlet \
        imagemagick \
        graphviz \
        tldr \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=criterion-build /criterion-install/usr/local/ /usr/local/
RUN ldconfig

# Python packages needed to run the chirc tests. Ubuntu does not allow
# installing packages system-wide with pip by default, so we have to
# explicitly allow it. Versions match those used in the chirouter container.
RUN pip3 install --no-cache-dir --break-system-packages \
        pytest==9.2.0 \
        pytest-json-report==1.5.0 \
        click==8.5.0

# Bake the post-create script into the image so it does not depend on the
# workspace copy (which may lose its execute bit, or not exist at all if the
# configuration is stored in the user data folder)
COPY setup-extra.sh /usr/local/bin/setup-extra.sh
RUN chmod 755 /usr/local/bin/setup-extra.sh
