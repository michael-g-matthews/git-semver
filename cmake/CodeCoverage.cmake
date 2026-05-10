function(enable_code_coverage target)
  target_compile_options(${target}
    INTERFACE
    $<$<CXX_COMPILER_ID:Clang,GNU,AppleClang>:--coverage -g>
  )
  target_link_libraries(${target}
    INTERFACE
    $<$<CXX_COMPILER_ID:Clang,GNU,AppleClang>:--coverage>
  )
endfunction()
