#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================

function(check_ub_sanitizer_support supports_ubsan)
    include(CheckCXXCompilerFlag)
    include(CheckCXXSourceCompiles)
    if(CMAKE_CXX_COMPILER_ID MATCHES ".*(Clang|GNU).*" AND NOT WIN32)
        message(STATUS
            "Verifying support for Undefined Behavior Sanitizer..."
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
            # Unexpected lack of support
            message(WARNING "Undefined Behavior Sanitizer is NOT supported.")
        endif()
        set(${supports_ubsan} "${supports_linking_undefined_behavior_sanitizer}" PARENT_SCOPE)
    else()
        message(STATUS "Undefined Behavior Sanitizer is NOT supported.")
        set(${supports_ubsan} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(check_address_sanitizer_support supports_addrsan)
    include(CheckCXXCompilerFlag)
    include(CheckCXXSourceCompiles)
    if(WIN32)
        if(CMAKE_CXX_COMPILER_ID MATCHES ".*(Clang|GNU).*")
            message(STATUS "Address Sanitizer is NOT supported.")
            set(${supports_addrsan} FALSE PARENT_SCOPE)
        else()
            message(STATUS "Address Sanitizer is supported.")
            set(${supports_addrsan} TRUE PARENT_SCOPE)
        endif()
    else()
        message(STATUS "Verifying support for Address Sanitizer...")
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
            # Unexpected lack of support
            message(WARNING "Address Sanitizer is NOT supported.")
        endif()
        set(${supports_addrsan} "${supports_linking_address_sanitizer}" PARENT_SCOPE)
    endif()
endfunction()

function(enable_sanitizers target)
    set(options 
        ADDRESS
        LEAK
        UNDEFINED_BEHAVIOR
        THREAD
        MEMORY
    )
    set(oneValueArgs) # none
    set(multiValueArgs) # none

    cmake_parse_arguments(PARSE_ARGV 1 sanitize 
        "${options}" 
        "${oneValueArgs}" 
        "${multiValueArgs}"
    )
    set(sanitizers "")
    if(MSVC)
        if(sanitize_LEAK 
        OR sanitize_UNDEFINED_BEHAVIOR 
        OR sanitize_THREAD 
        OR sanitize_MEMORY)
           message(WARNING "MSVC only supports address sanitizer")
        endif()
        if (sanitize_ADDRESS)
            string(FIND "$ENV{PATH}" "$ENV{VSINSTALLDIR}" index_of_vs_install_dir)
            if("${index_of_vs_install_dir}" STREQUAL "-1")
            message(
                SEND_ERROR
                "Using MSVC sanitizers requires setting the MSVC environment "
                "before building the project. Please manually open the MSVC "
                "command prompt and rebuild the project."
            )
            endif()
            target_compile_options(${target} 
                INTERFACE 
                    /fsanitize=address 
                    /Zi
                    /INCREMENTAL:NO
            )
            target_compile_definitions(${target} 
                INTERFACE 
                    _DISABLE_VECTOR_ANNOTATION 
                    _DISABLE_STRING_ANNOTATION
            )
            target_link_options(${target} INTERFACE /INCREMENTAL:NO)
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|.*Clang")
        target_compile_options(${target} INTERFACE -fsanitize=${sanitizers})
        target_link_options(${target} INTERFACE -fsanitize=${sanitizers})
    endif()

endfunction()
