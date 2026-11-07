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
        libcriterion-dev \
        # Python
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
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
    ; \
    apt-get clean

# Bake the post-create script into the image so it does not depend on the
# workspace copy (which may lose its execute bit, or not exist at all if the
# configuration is stored in the user data folder)
COPY setup-extra.sh /usr/local/bin/setup-extra.sh
RUN chmod 755 /usr/local/bin/setup-extra.sh
