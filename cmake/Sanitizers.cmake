#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================

function(check_sanitizer_support supports_ubsan supports_addrsan)
    include(CheckCXXCompilerFlag)
    include(CheckCXXSourceCompiles)
    # Undefined Behavior Sanitizer
    if(CMAKE_CXX_COMPILER_ID MATCHES ".*(Clang|GNU).*" AND NOT WIN32)
        message(STATUS 
            "Undefined Behavior Sanitizer should be supported. Verifying..."
        )
        set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
        set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")
        check_cxx_source_compiles([[
            int main() {
                return 0;
            }
        ]] supports_linking_undefined_behavior_sanitizer)

        if(supports_linking_undefined_behavior_sanitizer)
            message(STATUS "Undefined Behavior Sanitizer is supported.")
        else()
            message(WARNING 
                "Undefined Behavior Sanitizer is NOT supported at link time."
            )
        endif()
        set(${supports_ubsan} "${supports_linking_undefined_behavior_sanitizer}" PARENT_SCOPE)
    else()
        set(${supports_ubsan} FALSE PARENT_SCOPE)
    endif()

    # Address Sanitizer
    if(WIN32)
        if(CMAKE_CXX_COMPILER_ID MATCHES ".*(Clang|GNU).*")
            set(${supports_addrsan} FALSE PARENT_SCOPE)
        else()
            set(${supports_addrsan} TRUE PARENT_SCOPE)
        endif()
    else()
        message(STATUS "Address Sanitizer should be supported. Verifying...")
        set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
        set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")
        check_cxx_source_compiles([[
            int main() {
                return 0;
            }
        ]] supports_linking_address_sanitizer)
        if(supports_linking_address_sanitizer)
            message(STATUS "Address Sanitizer is supported.")
        else()
            message(WARNING "Address Sanitizer is NOT supported at link time.")
        endif()
        set(${supports_addrsan} "${supports_linking_address_sanitizer}" PARENT_SCOPE)
    endif()
endfunction()

function(enable_sanitizers target)
endfunction()
