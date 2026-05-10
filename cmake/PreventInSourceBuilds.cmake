#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================
cmake_minimum_required(VERSION 3.19)

function(assert_out_of_source_build)
    file(REAL_PATH "${CMAKE_SOURCE_DIR}" srcdir)
    file(REAL_PATH "${CMAKE_BINARY_DIR}" bindir)
    if("${srcdir}" STREQUAL "${bindir}")
    message(FATAL_ERROR 
        " ERROR: In-source builds are disabled.\n"
        " CMAKE_BINARY_DIR cannot be set as ${srcdir}. Reconfigure with a"
        " separate build directory (-B <path-to-build> option) to fix this"
        " error."
    )
    endif()
endfunction()

assert_out_of_source_build()
