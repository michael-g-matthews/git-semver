#===============================================================================
# 
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#===============================================================================
add_executable(gitsemver
    GitSemver.cpp
)

target_include_directories(gitsemver
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

set_target_properties(gitsemver
    PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
        OUTPUT_NAME "git-semver"
)

target_link_libraries(gitsemver
    PRIVATE
        gitsemver::warnings
        gitsemver::options
)

install(TARGETS gitsemver)
