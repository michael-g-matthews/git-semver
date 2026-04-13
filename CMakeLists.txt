#===============================================================================
# 
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#===============================================================================
cmake_minimum_required(VERSION 3.31)

project(git-semver 
    LANGUAGES CXX
    VERSION 0.0.1
)

if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
endif()

set(CMAKE_CXX_EXTENSIONS OFF)

# Print helpful information
if (PROJECT_IS_TOP_LEVEL)
    message(STATUS "${PROJECT_NAME} v${PROJECT_VERSION}")
    message(STATUS "${PROJECT_NAME} -- Build type: ${CMAKE_BUILD_TYPE}")
endif()

add_subdirectory(src)

# set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
# find_program(CLANG_TIDY_EXECUTABLE clang-tidy)
# set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_EXECUTABLE} -p ${CMAKE_BINARY_DIR})
