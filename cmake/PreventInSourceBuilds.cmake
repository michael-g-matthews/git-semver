#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================
function(assert_out_of_source_build)
    file(REAL_PATH "${CMAKE_SOURCE_DIR}" srcdir)
    file(REAL_PATH "${CMAKE_BINARY_DIR}" bindir)
    if("${srcdir}" STREQUAL "${bindir}")
    message(FATAL_ERROR 
        " ERROR: In-source builds are disabled.\n"
        " Reconfigure with a separate build directory to prevent this error."
    )
    endif()
endfunction()
