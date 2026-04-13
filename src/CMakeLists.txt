#===============================================================================
# 
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#===============================================================================
add_executable(git-semver
    GitSemver.cpp
)

target_include_directories(git-semver
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

set_target_properties(git-semver
    PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)

install(TARGETS git-semver)
