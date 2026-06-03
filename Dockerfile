#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Developer environment for building git-semver
#
#===============================================================================
ARG LIBGIT2_VERSION="1.9.4"
ARG CMAKE_VERSION="3.25.2"
ARG LLVM_VERSION_MAJOR="14"

FROM ubuntu:22.04 AS ppa-config
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    wget

# LLVM Clang
RUN mkdir -p /etc/apt/keyrings && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/llvm.gpg

ARG CLANG_VERSION_MAJOR
RUN mkdir -p /etc/apt/sources.list.d && \
    cat <<EOF > /etc/apt/sources.list.d/llvm.sources
Types: deb
URIs: https://apt.llvm.org/$(lsb_release -sc)/
Suites: llvm-toolchain-$(lsb_release -sc)-${CLANG_VERSION_MAJOR}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/llvm.gpg
EOF

# KitWare CMake
RUN test -f /usr/share/doc/kitware-archive-keyring-copyright || \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc |\
    gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' |\
    tee /etc/apt/sources.list.d/kitware.list


FROM ubuntu:22.04 AS libgit2-builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /libgit2
COPY external/libgit2 .

RUN cmake -B build -DBUILD_TESTS=OFF \
    && cmake --build build \
    && cmake --install build --prefix staging

FROM ubuntu:22.04 AS gitsemver
ENV DEBIAN_FRONTEND=noninteractive

# Need ca-certificates for https certificate handshakes
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ppa-config /usr/share/keyrings/kitware-archive-keyring.gpg /usr/share/keyrings/
COPY --from=ppa-config /etc/apt/sources.list.d/kitware.list /etc/apt/sources.list.d/

ARG CMAKE_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    clang-tidy \
    cmake=${CMAKE_VERSION}-0kitware1ubuntu22.04.1 \
    cmake-data=${CMAKE_VERSION}-0kitware1ubuntu22.04.1 \
    git \
    libssl-dev \
    llvm \
    ninja-build \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=libgit2-builder /libgit2/staging /usr/local
