FROM ubuntu:24.04

# Install dependencies
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        # Basic tools
		ca-certificates \
		curl \
		wget \
        # C/C**    
        make \
        build-essential \
        cmake \
        cppcheck \
        valgrind \
        clang \
        lldb \
        llvm \
        gdb \
        # Python
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        # Git
        git \
    ; \
    apt-get clean
