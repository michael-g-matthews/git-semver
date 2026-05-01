#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================

include(CMakeDependentOption)

option(gitsemver_ENABLE_HARDENING "Enable hardening" ON)
option(gitsemver_ENABLE_COVERAGE "Enable coverage reporting" OFF)
cmake_dependent_option(
    gitsemver_ENABLE_GLOBAL_HARDENING
    "Attempt to apply hardening options to built dependencies"
    ON
    gitsemver_ENABLE_HARDENING
    OFF
)

include(cmake/Sanitizers.cmake)
check_ub_sanitizer_support(UBSAN_SUPPORTED)
check_address_sanitizer_support(ADDRSAN_SUPPORTED)

cmake_dependent_option(
    gitsemver_ENABLE_SANITIZER_ADDRESS
    "Enable address sanitizier"
    ${gitsemver_IS_TOP_LEVEL}
    ADDRSAN_SUPPORTED
    OFF
)
cmake_dependent_option(
    gitsemver_ENABLE_SANITIZER_UB
    "Enable undefined behavior sanitizer"
    ${gitsemver_IS_TOP_LEVEL}
    UBSAN_SUPPORTED
    OFF
)

option(gitsemver_ENABLE_IPO
    "Enable Interprocedural Optimization and Link-Time Optimization"
    "${gitsemver_IS_TOP_LEVEL}"
)
option(gitsemver_WARNINGS_AS_ERRORS
    "Treat Warnings as Errors"
    "${gitsemver_IS_TOP_LEVEL}"
)
option(gitsemver_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
option(gitsemver_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
option(gitsemver_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
option(gitsemver_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
option(gitsemver_ENABLE_CLANG_TIDY "Enable clang-tidy" ${gitsemver_IS_TOP_LEVEL})
option(gitsemver_ENABLE_PCH "Enable precompiled headers" OFF)
# cpp-check and ccache are unsupported at this time

if(NOT gitsemver_IS_TOP_LEVEL)
    mark_as_advanced(
        gitsemver_ENABLE_HARDENING
        gitsemver_ENABLE_COVERAGE
        gitsemver_ENABLE_IPO
        gitsemver_WARNINGS_AS_ERRORS
        gitsemver_ENABLE_SANITIZER_ADDRESS
        gitsemver_ENABLE_SANITIZER_LEAK
        gitsemver_ENABLE_SANITIZER_UB
        gitsemver_ENABLE_SANITIZER_THREAD
        gitsemver_ENABLE_SANITIZER_MEMORY
        gitsemver_ENABLE_UNITY_BUILD
        gitsemver_ENABLE_CLANG_TIDY
        gitsemver_ENABLE_PCH
    )
endif()

option(gitsemver_ENABLE_TESTING "Build tests for gitsemver" ${gitsemver_IS_TOP_LEVEL})
option(gitsemver_ENABLE_PACKAGING "Build gitsemver packages" ${gitsemver_IS_TOP_LEVEL})

include(cmake/LibFuzzer.cmake)
check_libfuzzer_support(LIBFUZZER_SUPPORTED)
cmake_dependent_option(
    gitsemver_BUILD_FUZZ_TESTS
    "Build fuzz-testing executable"
    "${gitsemver_ENABLE_SANITIZER_ADDRESS} OR ${gitsemver_ENABLE_SANITIZER_THREAD} OR ${gitsemver_ENABLE_SANITIZER_UB}"
    LIBFUZZER_SUPPORTED
    OFF
)

# Global Options
if(gitsemver_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    enable_ipo()
endif()
if(gitsemver_ENABLE_HARDENING AND gitsemver_ENABLE_GLOBAL_HARDENING)
    # include(cmake/Hardening.cmake)
    if(NOT UBSAN_SUPPORTED
        OR gitsemver_ENABLE_SANITIZER_UB
        OR gitsemver_ENABLE_SANITIZER_ADDRESS
        OR gitsemver_ENABLE_SANITIZER_THREAD
        OR gitsemver_ENABLE_SANITIZER_LEAK)
        set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
        set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    # message(DEBUG "${myproject_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${myproject_ENABLE_SANITIZER_UNDEFINED}")
    # myproject_enable_hardening(myproject_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})

endif()

# Local Options
add_library(gitsemver_warnings INTERFACE)
include(cmake/CompilerOptions.cmake)
set(_wae "")
if(gitsemver_WARNINGS_AS_ERRORS)
    set(_wae WARNINGS_AS_ERRORS)
endif()
configure_standard_compiler_warnings(gitsemver_warnings
    ${_wae}
)
add_library(gitsemver_options INTERFACE)
colorize_compiler_diagnostics(gitsemver_options)

if(gitsemver_ENABLE_COVERAGE)
    include(cmake/CodeCoverage.cmake)
    enable_code_coverage(gitsemver_options)
endif()

if(gitsemver_ENABLE_PCH)
    target_precompile_headers(gitsemver_options
        INTERFACE
        <string>
        <utility>
        <vector>
    )
endif()

if(gitsemver_ENABLE_CLANG_TIDY)
    include(cmake/StaticAnalysis.cmake)
    gitsemver_enable_clang_tidy(gitsemver_options ${gitsemver_WARNINGS_AS_ERRORS})
endif()
