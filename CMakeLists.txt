#===============================================================================
# 
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#===============================================================================
cmake_minimum_required(VERSION 3.31)

project(gitsemver 
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
    if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
        message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
        set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build.")
    endif()
    set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)
endif()
include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)
include(Dependencies.cmake)
add_library(gitsemver::warnings ALIAS gitsemver_warnings)
add_library(gitsemver::options ALIAS gitsemver_options)

add_subdirectory(src)

# find_program(CLANG_TIDY_EXECUTABLE clang-tidy)
# set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_EXECUTABLE} -p ${CMAKE_BINARY_DIR})

if(gitsemver_ENABLE_TESTING)
    include(CTest)
    enable_testing()
    add_subdirectory(test)
endif()

if(gitsemver_ENABLE_PACKAGING)
    # add_subdirectory(packaging)
endif()
