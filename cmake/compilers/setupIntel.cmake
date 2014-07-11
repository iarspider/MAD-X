
###
#
# This file sets up specific flags for the Intel compilers
#
###
if(NOT WIN32)
   set(_INTEL_FLAGS "-Wcheck -Wp64 -diag-disable 2259,1572,981 -mp1 -fp-model strict")
else()
   set(_INTEL_FLAGS "-Wcheck -Wp64 /fp:strict")
endif()

if(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
   if(UNIX)
      set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -assume noold_unit_star -fp-model strict -fpp")
      set(CMAKE_Fortran_FLAGS_RELEASE "-funroll-loops -O3")
      set(CMAKE_Fortran_FLAGS_DEBUG   "-f77rtl -O3 -g")
      set(CMAKE_Fortran_LINK_FLAGS   "${CMAKE_Fortran_LINK_FLAGS} -nofor_main")
   else()
      set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}  /Qprec /fp:source /fpp /names:lowercase /assume:underscore /assume:noold_unit_star")
      set(CMAKE_Fortran_LINK_FLAGS   "${CMAKE_Fortran_LINK_FLAGS} /extlnk:.o")
   endif()
   if ( MADX_STATIC )
      set(CMAKE_Fortran_LINK_FLAGS   "${CMAKE_Fortran_LINK_FLAGS} -static")
      # cmake is adding unavailable shared libs to link against:
      set(CMAKE_C_IMPLICIT_LINK_LIBRARIES "")
      set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES "")
   endif ()
   if(IS32BIT)
      set (CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -m32")
   endif()
   add_definitions(-D_IFORT -D_INTEL_IFORT_SET_RECL)
   if(NOT MADX_STATIC)
      if(UNIX)
         set(CMAKE_Fortran_LINK_FLAGS   "${CMAKE_Fortran_LINK_FLAGS} -static-intel")
      endif()
      # remove -i_dynamic
      set(CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS "")
      set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "-shared -nofor_main")
   endif()
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x ${_INTEL_FLAGS}")
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "Intel")
   if(WIN32)
      add_definitions(/D_ICL)
   endif()
   add_definitions(-D_ICC)
   set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${_INTEL_FLAGS}")
   if(UNIX)
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
   else()
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /Qstd=c99")
   endif()
endif()