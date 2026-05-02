#NWTC_SPECFUN.f90
function(netlib_clean_fortran out_var)
  set(cleaned "")
  foreach(src IN LISTS ARGN)
    get_filename_component(src_name "${src}" NAME)
    set(out_file "${CMAKE_CURRENT_BINARY_DIR}/clean_${src_name}")

    file(READ "${src}" content)

    if(DOUBLE_PRECISION)
      # Strip "CD" on first line
      string(REGEX REPLACE "^CD" "  " content "${content}")
      # Strip "CD" after newlines (keep indentation)
      string(REGEX REPLACE "\nCD" "\n  " content "${content}")
    else()
      # Strip "CS" on first line
      string(REGEX REPLACE "^CS" "  " content "${content}")
      # Strip "CS" after newlines (keep indentation)
      string(REGEX REPLACE "\nCS" "\n  " content "${content}")
    endif()

    file(WRITE "${out_file}" "${content}")
    list(APPEND cleaned "${out_file}")
  endforeach()
  set(${out_var} "${cleaned}" PARENT_SCOPE)
endfunction()

function(netlib_specfun_add name src)
    netlib_clean_fortran(CLEANED_SOURCES "${src}")

    add_library(netlib_specfun_${name} OBJECT ${CLEANED_SOURCES})
    set_target_properties(netlib_specfun_${name} PROPERTIES
      POSITION_INDEPENDENT_CODE ON
      OUTPUT_NAME netlib_specfun_${name}
    )

    set_property(GLOBAL APPEND PROPERTY NETLIB_SPECFUN_LIB_TARGETS netlib_specfun_${name})

endfunction()

netlib_specfun_add(algama  algama.f)
netlib_specfun_add(daw     daw.f)
netlib_specfun_add(ei      ei.f)
netlib_specfun_add(erf     erf.f)
netlib_specfun_add(gamma   gamma.f)
netlib_specfun_add(i0      i0.f)
netlib_specfun_add(i1      i1.f)
netlib_specfun_add(j0y0    j0y0.f)
netlib_specfun_add(j1y1    j1y1.f)
netlib_specfun_add(k0      k0.f)
netlib_specfun_add(k1      k1.f)
netlib_specfun_add(psi     psi.f)
netlib_specfun_add(ren     ren.f)
netlib_specfun_add(ribesl  ribesl.f)
netlib_specfun_add(rjbesl  rjbesl.f)
target_link_libraries(netlib_specfun_rjbesl PRIVATE netlib_specfun_gamma)
netlib_specfun_add(rkbesl  rkbesl.f)
netlib_specfun_add(rybesl  rybesl.f)

get_property(_specfun_libs  GLOBAL PROPERTY NETLIB_SPECFUN_LIB_TARGETS)
add_custom_target(netlib_specfun DEPENDS ${_specfun_libs})

if(BUILD_TESTS)
  # Helper: build one test exe and link to exactly one object library
  function(netlib_specfun_add_test testname testsrc libname)
    netlib_clean_fortran(CLEANED_TEST_SRC "${testsrc}")
  
    add_executable(${testname} ${CLEANED_TEST_SRC})
    target_link_libraries(${testname} PRIVATE netlib_specfun_${libname})
  
    # Disable optimizations for tests only (Fortran)
    target_compile_options(${testname} PRIVATE
      $<$<BOOL:${WIN32}>:
        $<$<STREQUAL:${CMAKE_Fortran_COMPILER_ID},Intel>:/Od>
        $<$<STREQUAL:${CMAKE_Fortran_COMPILER_ID},IntelLLVM>:/Od>
        $<$<NOT:$<OR:
              $<STREQUAL:${CMAKE_Fortran_COMPILER_ID},Intel>,
              $<STREQUAL:${CMAKE_Fortran_COMPILER_ID},IntelLLVM>
            >>:-O0>
      >
      $<$<NOT:$<BOOL:${WIN32}>>:-O0>
    )
  
    set_property(GLOBAL APPEND PROPERTY NETLIB_SPECFUN_TEST_TARGETS ${testname})
  
    add_test(NAME ${testname} COMMAND ${testname})
    set_tests_properties(${testname} PROPERTIES LABELS "netlib_specfun")
  
  endfunction()
  
  # Map tests -> library they are intended to validate
  netlib_specfun_add_test(eitest  eitest.f  ei)
  
  netlib_specfun_add_test(i0test  i0test.f  i0)
  netlib_specfun_add_test(i1test  i1test.f  i1)
  
  netlib_specfun_add_test(j0test  j0test.f  j0y0)
  netlib_specfun_add_test(j1test  j1test.f  j1y1)
  
  netlib_specfun_add_test(k0test  k0test.f  k0)
  netlib_specfun_add_test(k1test  k1test.f  k1)
  
  netlib_specfun_add_test(ritest  ritest.f  ribesl)
  netlib_specfun_add_test(rjtest  rjtest.f  rjbesl)
  
  target_link_libraries(rjtest PRIVATE netlib_specfun_gamma)
  netlib_specfun_add_test(rktest  rktest.f  rkbesl)
  netlib_specfun_add_test(rytest  rytest.f  rybesl)
  
  netlib_specfun_add_test(y0test  y0test.f  j0y0)
  netlib_specfun_add_test(y1test  y1test.f  j1y1)
endif()
