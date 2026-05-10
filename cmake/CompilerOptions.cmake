function(configure_standard_compiler_warnings target)
    # Warn if compiler is not supported
    set(supported_cxx_compilers
        AppleClang
        Clang
        GNU
        MSVC
    )
    
    if(NOT CMAKE_CXX_COMPILER_ID IN_LIST supported_cxx_compilers)
        message(AUTHOR_WARNING "Compiler warnings were not set for CXX compiler: '${CMAKE_CXX_COMPILER_ID}'")
    endif()

    set(options WARNINGS_AS_ERRORS)
    set(oneValueArgs) # none
    set(multiValueArgs
        CLANG_WARNINGS
        GCC_WARNINGS
        MSVC_WARNINGS
    )

    cmake_parse_arguments(PARSE_ARGV 1 arg 
        "${options}" 
        "${oneValueArgs}" 
        "${multiValueArgs}"
    )

    # Default arg values if not set
    if(NOT arg_CLANG_WARNINGS)
        set(arg_CLANG_WARNINGS
            -Wall
            -Wextra # reasonable and standard
            -Wshadow # warn the user if a variable declaration shadows one from 
                     # a parent context
            -Wnon-virtual-dtor # warn the user if a class with virtual functions
                               # has a non-virtual destructor. This helps catch 
                               # hard to track down memory errors
            -Wold-style-cast # warn for c-style casts
            -Wcast-align # warn for potential performance problem casts
            -Wunused # warn on anything being unused
            -Woverloaded-virtual # warn if you overload (not override) a virtual
                                 # function
            -Wpedantic # warn if non-standard C++ is used
            -Wconversion # warn on type conversions that may lose data
            -Wsign-conversion # warn on sign conversions
            -Wnull-dereference # warn if a null dereference is detected
            -Wdouble-promotion # warn if float is implicitly promoted to double
            -Wformat=2 # warn on security issues around functions that format 
                       # output (ie printf)
            -Wimplicit-fallthrough # warn on statements that fallthrough without
                                   # an explicit annotation
        )
    endif()

    if(NOT arg_GCC_WARNINGS)
        set(arg_GCC_WARNINGS
            ${arg_CLANG_WARNINGS}
            -Wmisleading-indentation # warn if indentation implies blocks where 
                                     # blocks do not exist
            -Wduplicated-cond # warn if if / else chain has duplicated 
                              # conditions
            -Wduplicated-branches # warn if if / else branches have duplicated 
                                  # code
            -Wlogical-op # warn about logical operations being used where 
                         # bitwise were probably wanted
            -Wuseless-cast # warn if you perform a cast to the same type
            -Wsuggest-override # warn if an overridden member function is not 
                               # marked 'override' or 'final'
        )
    endif()

    if(NOT arg_MSVC_WARNINGS)
        set(arg_MSVC_WARNINGS
            /W4 # baseline warnings
            /permissive- # standards conformance
            /w14242 # 'identifier': conversion from 'type1' to 'type2', possible
                    # loss of data
            /w14254 # 'operator': conversion from 'type1:field_bits' to 
                    # 'type2:field_bits', possible loss of data
            /w14263 # 'function': member function does not override any base 
                    # class virtual member function
            /w14265 # 'classname': class has virtual functions, but destructor 
                    # is not virtual instances of this class may not be 
                    # destructed correctly
            /w14287 # 'operator': unsigned/negative constant mismatch
            /we4289 # nonstandard extension used: 'variable': loop control 
                    # variable declared in the for-loop is used outside the 
                    # for-loop scope
            /w14296 # 'operator': expression is always 'boolean_value'
            /w14311 # 'variable': pointer truncation from 'type1' to 'type2'
            /w14545 # expression before comma evaluates to a function which is 
                    # missing an argument list
            /w14546 # function call before comma missing argument list
            /w14547 # 'operator': operator before comma has no effect; expected 
                    # operator with side-effect
            /w14549 # 'operator': operator before comma has no effect; did you 
                    # intend 'operator'?
            /w14555 # expression has no effect; expected expression with 
                    # side-effect
            /w14619 # pragma warning: there is no warning number 'number'
            /w14640 # Enable warning on thread un-safe static member 
                    # initialization
            /w14826 # Conversion from 'type1' to 'type2' is sign-extended. This 
                    # may cause unexpected runtime behavior.
            /w14905 # wide string literal cast to 'LPSTR'
            /w14906 # string literal cast to 'LPWSTR'
            /w14928 # illegal copy-initialization; more than one user-defined 
                    # conversion has been implicitly applied
        )
    endif()

    if(arg_WARNINGS_AS_ERRORS)
        message(TRACE "Warnings are treated as errors")
        list(APPEND arg_CLANG_WARNINGS "-Werror")
        list(APPEND arg_GCC_WARNINGS "-Werror")
        list(APPEND arg_MSVC_WARNINGS "/WX")
    endif()

    target_compile_options(${target}
        INTERFACE
            $<$<COMPILE_LANG_AND_ID:CXX,Clang,AppleClang>:${arg_CLANG_WARNINGS}>
            $<$<COMPILE_LANG_AND_ID:CXX,GNU>:${arg_GCC_WARNINGS}>
            $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:${arg_MSVC_WARNINGS}>
    )
endfunction()

function(colorize_compiler_diagnostics target)
    # Warn if compiler is not supported
    set(supported_cxx_compilers
        AppleClang
        Clang
        GNU
        MSVC
    )
    if(NOT CMAKE_CXX_COMPILER_ID IN_LIST supported_cxx_compilers)
        message(AUTHOR_WARNING "No colored compiler diagnostic set for CXX compiler: '${CMAKE_CXX_COMPILER_ID}'")
        return()
    endif()

    target_compile_options(${target}
        INTERFACE
            $<$<COMPILE_LANG_AND_ID:CXX,Clang,AppleClang>:-fcolor-diagnostics>
            $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-fdiagnostics-color=always>
            $<$<AND:$<COMPILE_LANG_AND_ID:CXX,MVSC>,$<VERSION_GREATER:$<CXX_COMPILER_VERSION>,1900>>:/diagnostics:column>
    )
endfunction()


    
