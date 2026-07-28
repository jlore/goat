cmake_minimum_required(VERSION 3.18)

project(GOAT LANGUAGES C Fortran)

set(GOAT_OUTPUT_NAME "goat.exe" CACHE STRING "GOAT executable filename")

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(OpenMP REQUIRED)
find_package(BLAS REQUIRED)

find_path(SUITESPARSE_INCLUDE_DIR
  NAMES umfpack.h
  PATH_SUFFIXES suitesparse
)

find_library(UMFPACK_LIBRARY NAMES umfpack)
find_library(CXSPARSE_LIBRARY NAMES cxsparse)

if(NOT SUITESPARSE_INCLUDE_DIR OR NOT UMFPACK_LIBRARY OR NOT CXSPARSE_LIBRARY)
  message(FATAL_ERROR "SuiteSparse headers/libraries not found. Install libsuitesparse-dev.")
endif()

set(GOAT_C_SOURCES
  src/Clayer/ConstructMyCSparse.c
  src/Clayer/ConvertMyCSparseToCS.c
  src/Clayer/ParseTest.c
  src/Clayer/ParseTestP2.c
  src/Clayer/SpMM.c
  src/Clayer/SpMMBasic.c
  src/Clayer/SpMMV.c
)

set(GOAT_FORTRAN_SOURCES
  src/Clayer/CUtilities.F90
  src/Clayer/CSparseF.F90
  src/Clayer/Clayer.F90

  src/Constants/mod_global_environment.F90
  src/Constants/mod_precision.F90
  src/Constants/mod_constants.F90
  src/Constants/mod_definitions.F90
  src/Constants/mod_specialchars.F90
  src/Constants/mod_std_formatspecs.F90

  src/General/mod_errorhandler.F90
  src/General/mod_readwrite.F90
  src/General/mod_inputfileparser.F90
  src/General/mod_plotter.F90
  src/General/mod_sparseinterface.F90
  src/General/mod_sort.F90
  src/General/mod_diagnostics.F90
  src/General/mod_dynamicarrays.F90
  src/General/mod_linearsolverinterface.F90
  src/General/mod_polygon.F90
  src/General/mod_search.F90
  src/General/mod_utility.F90

  src/Auxiliary/mod_structured2Dgridding.F90
  src/Auxiliary/PolygonShapeFunction.F90
  src/Auxiliary/mod_gradient.F90
  src/Auxiliary/mod_streamlinetracing2D.F90
  src/Auxiliary/mod_triangulation.F90
  src/Auxiliary/Interpolation/Interpolant2D_auxiliaries.F90
  src/Auxiliary/Interpolation/Interpolant2D.F90
  src/Auxiliary/Interpolation/Interpolant1D.F90
  src/Auxiliary/Interpolation/BicubicSplineInterpolant.F90
  src/Auxiliary/Interpolation/StructuredInterpolant2D.F90
  src/Auxiliary/Interpolation/Interpolant.F90
  src/Auxiliary/Interpolation/UnstructuredInterpolation2D.F90
  src/Auxiliary/Contour/mod_contour2D.F90
  src/Auxiliary/Graphs/mod_graph.F90

  src/Numerics/PolygonLevelsetFunction2D.F90
  src/Numerics/ComputeGradient2DStructured.F90
  src/Numerics/DistributionFunction.F90
  src/Numerics/mod_lagrangefunction.F90

  src/Optimization/optmod_designvariables.F90
  src/Optimization/optmod_costfunction.F90
  src/Optimization/optmod_constraints.F90
  src/Optimization/optmod_monitor.F90
  src/Optimization/optmod_numerics.F90
  src/Optimization/optmod_hessapprox.F90
  src/Optimization/optmod_optimizationengine.F90
  src/Optimization/optmod_qp.F90

  src/Modules/Goat/goatmod_userinput.F90
  src/Modules/Goat/goatmod_types.F90

  src/Modules/GD/gdmod_types.F90
  src/Modules/GD/gdmod_userinput.F90
  src/Modules/GD/gdmod_plots.F90
  src/Modules/GD/gdmod_designvariables.F90
  src/Modules/GD/gdmod_utility_optimization.F90
  src/Modules/GD/gdmod_constraints.F90
  src/Modules/GD/gdmod_costfunction.F90
  src/Modules/GD/gdmod_optimizationengine.F90

  src/Modules/GA/gamod_math.F90
  src/Modules/GA/gamod_types.F90
  src/Modules/GA/gamod_utility.F90
  src/Modules/GA/gamod_driver.F90

  src/Modules/GG/ggmod_topology2D.F90
  src/Modules/GG/ggmod_vertexdistribution2D.F90
  src/Modules/GG/ggmod_gridgeneration2D.F90
  src/Modules/GG/ggmod_gridgenerator.F90

  src/Drivers/Goat/GADriver.F90
  src/Drivers/Goat/GAGDDriver.F90
  src/Drivers/Goat/GDDriver.F90
  src/Drivers/Goat/GDinitialize.F90
  src/Drivers/Goat/GDtestdriver.F90
  src/Drivers/Goat/GGDriver.F90
  src/Drivers/Goat/GGGDDriver.F90
  src/Drivers/Goat/RunGridOptimization.F90

  Runfiles/Goat.F90
)

add_executable(goat ${GOAT_C_SOURCES} ${GOAT_FORTRAN_SOURCES})

set_target_properties(goat PROPERTIES
  OUTPUT_NAME "${GOAT_OUTPUT_NAME}"
  Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mod"
)

target_include_directories(goat PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src/Clayer/Include"
  "${SUITESPARSE_INCLUDE_DIR}"
  "${CMAKE_CURRENT_BINARY_DIR}/mod"
)

if(DEFINED ENV{SOLPSTOP} AND NOT DEFINED ENV{GOAT_DISABLE_SOLPS})
  target_compile_definitions(goat PRIVATE SOLPS)
endif()

target_compile_options(goat PRIVATE
  $<$<COMPILE_LANGUAGE:Fortran>:-fopenmp>
  $<$<COMPILE_LANGUAGE:C>:-g>
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Release>>:-O3>
  $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:Release>>:-O3>
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-g;-O0;-Wall;-Wno-unused-dummy-argument;-Wno-maybe-uninitialized;-fcheck=all;-Wno-uninitialized>
  $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:Debug>>:-g;-Wall;-O0>
)

target_link_options(goat PRIVATE
  $<$<LINK_LANG_AND_ID:Fortran,GNU>:-fcheck=all>
)

target_link_libraries(goat PRIVATE
  OpenMP::OpenMP_Fortran
  OpenMP::OpenMP_C
  BLAS::BLAS
  "${UMFPACK_LIBRARY}"
  "${CXSPARSE_LIBRARY}"
)
