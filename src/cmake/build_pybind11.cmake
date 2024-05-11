

cmake_minimum_required(VERSION 3.25)

include(ExternalProject)
include(FetchContent)

set(DIR_DOWNLOAD  ${CMAKE_BINARY_DIR}/ext/download)
set(DIR_SRC  ${CMAKE_BINARY_DIR}/ext/src)
set(DIR_INSTALL  ${CMAKE_BINARY_DIR}/ext/dist)

set(VERSION v2.12.0)

# ExternalProject_Add(
#   "pybind11"
#   PREFIX "external"
#   GIT_REPOSITORY https://github.com/pybind/pybind11.git
#   GIT_TAG ${VERSION}
#   DOWNLOAD_DIR ${DIR_DOWNLOAD}
#   SOURCE_DIR ${DIR_SRC}
#   INSTALL_DIR ${DIR_INSTALL}
#   BUILD_COMMAND ""
#   CMAKE_ARGS
#   "-DCMAKE_BUILD_TYPE=Release"
#   "-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}"
#   -DPYBIND11_INSTALL=ON
#   -DPYBIND11_TEST=OFF
# )

# Unknown CMake command "pybind11_add_module".
# list (APPEND CMAKE_MODULE_PATH
#       "${PROJECT_SOURCE_DIR}/src/cmake/modules"
#       "${PROJECT_SOURCE_DIR}/src/cmake"

# pybind11_ROOT=




# FetchContent_GetProperties(pybind11)
# message("BBBBBBBBBBBB", "${pybind11_SOURCE_DIR}/tools")
# # if (NOT pybind11_POPULATED)

#     FetchContent_Populate(pybind11
#     GIT_REPOSITORY  https://github.com/pybind/pybind11.git
#     GIT_TAG        ${VERSION}
#     SOURCE_DIR ./ext/pybind11
#     )
#     # TODO set source ./ext/src/pybind11

#     add_subdirectory(${pybind11_SOURCE_DIR} ${pybind11_BINARY_DIR})
#     message("AAAAAAAAAAAAAA", "${pybind11_SOURCE_DIR}/tools")
#     list (APPEND CMAKE_MODULE_PATH
#        "${pybind11_SOURCE_DIR}/tools")
# # endif()



build_dependency_with_cmake(pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11.git
    GIT_TAG ${VERSION}
    CMAKE_ARGS
    -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DPYBIND11_INSTALL=ON
    -DPYBIND11_TEST=OFF
)

set (pybind11_ROOT ${pybind11_LOCAL_INSTALL_DIR})
set (pybind11_REFIND TRUE)
