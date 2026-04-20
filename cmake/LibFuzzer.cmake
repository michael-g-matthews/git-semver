#===============================================================================
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2026 Mike Matthews <michael.g.matthews3@gmail.com>
#
# Adapted from Jason Turner's CPP Best Practices
# (https://github.com/cpp-best-practices/cmake_template.git)
#===============================================================================

function(check_libfuzzer_support supports_fuzzer)
    include(CheckCXXSourceCompiles)
    set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=fuzzer")
    check_cxx_source_compiles([[
        #include <cstdint>
        extern "C" int LLVMFuzzerTestOneInput(const std::uint8_t* data, std::size_t size) {
            return 0;
        }
    ]] has_fuzz_support)
    set(${supports_fuzzer} "${has_fuzz_support}" PARENT_SCOPE)
endfunction()
