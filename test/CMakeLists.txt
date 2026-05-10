#===============================================================================
# 
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#===============================================================================
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        52eb8108c5bdec04579160ae17225d66034bd723 # version 1.17
    SYSTEM
    FIND_PACKAGE_ARGS
        NAMES GTest
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)


add_executable(gtest_smoke_test
    GoogleTestSmokeTest.cpp
)

target_link_libraries(gtest_smoke_test
    PRIVATE
        GTest::gtest_main
        gitsemver::warnings
        gitsemver::options
)

include(GoogleTest)
gtest_discover_tests(gtest_smoke_test)
