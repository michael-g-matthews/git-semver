#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================

include(CMakeDependentOption)

option(git-semver_ENABLE_HARDENING "Enable hardening" ON)
option(git-semver_ENABLE_COVERAGE "Enable coverage reporting" OFF)
cmake_dependent_option(
    git-semver_ENABLE_GLOBAL_HARDENING
    "Attempt to apply hardening options to built dependencies"
    ON
    git-semver_ENABLE_HARDENING
    OFF
)

include(cmake/Sanitizers.cmake)
check_sanitizer_support(UBSAN_SUPPORTED ADDRSAN_SUPPORTED)

cmake_dependent_option(
    git-semver_ENABLE_SANITIZER_ADDRESS
    "Enable address sanitizier"
    ${git-semver_IS_TOP_LEVEL}
    ADDRSAN_SUPPORTED
    OFF
)
cmake_dependent_option(
    git-semver_ENABLE_SANITIZER_UB
    "Enable undefined behavior sanitizer"
    ${git-semver_IS_TOP_LEVEL}
    UBSAN_SUPPORTED
    OFF
)

option(git-semver_ENABLE_IPO 
    "Enable Interprocedural Optimization and Link-Time Optimization" 
    "${git-semver_IS_TOP_LEVEL}"
)
option(git-semver_WARNINGS_AS_ERRORS 
    "Treat Warnings as Errors" 
    "${git-semver_IS_TOP_LEVEL}"
)
option(git-semver_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
option(git-semver_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
option(git-semver_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
option(git-semver_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
option(git-semver_ENABLE_CLANG_TIDY "Enable clang-tidy" ${git-semver_IS_TOP_LEVEL})
option(git-semver_ENABLE_PCH "Enable precompiled headers" OFF)
# cpp-check and ccache are unsupported at this time

if(NOT git-semver_IS_TOP_LEVEL)
    mark_as_advanced(
        git-semver_ENABLE_HARDENING
        git-semver_ENABLE_COVERAGE
        git-semver_ENABLE_IPO
        git-semver_WARNINGS_AS_ERRORS
        git-semver_ENABLE_SANITIZER_ADDRESS
        git-semver_ENABLE_SANITIZER_LEAK
        git-semver_ENABLE_SANITIZER_UB
        git-semver_ENABLE_SANITIZER_THREAD
        git-semver_ENABLE_SANITIZER_MEMORY
        git-semver_ENABLE_UNITY_BUILD
        git-semver_ENABLE_CLANG_TIDY
        git-semver_ENABLE_PCH
    )
endif()

option(git-semver_ENABLE_TESTING "Build tests for git-semver" ${git-semver_IS_TOP_LEVEL})
option(git-semver_ENABLE_PACKAGING "Build git-semver packages" ${git-semver_IS_TOP_LEVEL})

include(cmake/LibFuzzer.cmake)
check_libfuzzer_support(LIBFUZZER_SUPPORTED)
cmake_dependent_option(
    git-semver_BUILD_FUZZ_TESTS
    "Build fuzz-testing executable"
    "${git-semver_ENABLE_SANITIZER_ADDRESS} OR ${git-semver_ENABLE_SANITIZER_THREAD} OR ${git-semver_ENABLE_SANITIZER_UB}"
    LIBFUZZER_SUPPORTED
    OFF
)

# Global Options
if(git-semver_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    enable_ipo()
endif()
# git-semver_check_sanitizer_support(UBSAN_SUPPORTED ADDRSAN_SUPPORTED)
if(git-semver_ENABLE_HARDENING AND git-semver_ENABLE_GLOBAL_HARDENING)
    # include(cmake/Hardening.cmake)

endif()

add_library(git-semver_warnings INTERFACE)
include(cmake/CompilerOptions.cmake)
set(_wae "")
if(git-semver_WARNINGS_AS_ERRORS)
    set(_wae WARNINGS_AS_ERRORS)
endif()
configure_standard_compiler_warnings(git-semver_warnings
    ${_wae}
)
colorize_compiler_diagnostics(git-semver_warnings)

# include(cmake/Linker.cmake)

