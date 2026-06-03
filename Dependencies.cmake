#===============================================================================
#
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#===============================================================================

include(FetchContent)

FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG 79524ddd08a4ec981b7fea76afd08ee05f83755d # tag: v1.17.0
    SYSTEM # SYSTEM keyword is broken prior to 3.25.2 #(https://gitlab.kitware.com/cmake/cmake/-/work_items/24201)
)
FetchContent_MakeAvailable(spdlog)

# libgit2 does not build as part of a super-project, so it must be installed
# prior to building this project. If libgit2 is not installed on your system,
# the source code is available in external/libgit2. It can be used via the
# Docker image created by Dockerfile, or may be built and installed to your
# system.
find_package(libgit2 1.9.4)
if (NOT libgit2_FOUND)
    message(FATAL_ERROR
        "ERROR: The required libgit2 dependency could not be found.\n"
        "A copy of the required library is provided at\n"
        "\t${gitsemver_SOURCE_DIR}/external/libgit2.\n"
        "To clone the source code, run\n"
        "\tgit submodule update --init external/libgit2\n"
        "You may install libgit2 with CMake or use the provided Docker image "
        " as a development environment.\n"
    )
endif()

