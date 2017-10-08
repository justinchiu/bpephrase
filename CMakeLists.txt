###############################################################################
cmake_minimum_required(VERSION 2.8)
project(Bpephrase)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

###############################################################################

if(${CMAKE_VERSION} VERSION_LESS "2.8.12")
  set(cmake_cxx_flags "${CMAKE_CXX_FLAGS} -std=c++11")
else(${CMAKE_VERSION} VERSION_LESS "2.8.12")
  if(${CMAKE_VERSION} VERSION_LESS "3.1")
    add_compile_options(-std=c++11) # cmake 2.8.12 to 3.1
  endif(${CMAKE_VERSION} VERSION_LESS "3.1")
endif(${CMAKE_VERSION} VERSION_LESS "2.8.12")

if(NOT MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -Wno-vla")
endif(NOT MSVC)

###############################################################################

set (CMAKE_CXX_STANDARD 11)

###############################################################################

#find_package(Boost REQUIRED)


###############################################################################

find_package(Cxxopts REQUIRED)
include_directories( ${CXXOPTS_INCLUDE_DIR} )

###############################################################################

include_directories( ${CMAKE_SOURCE_DIR}/include )

add_subdirectory(src)
