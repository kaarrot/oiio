

cmake_minimum_required(VERSION 3.25)

include(ExternalProject)

set(DIR_DOWNLOAD  ${CMAKE_BINARY_DIR}/ext/download)
set(DIR_SRC  ${CMAKE_BINARY_DIR}/ext/src)
set(DIR_INSTALL  ${CMAKE_BINARY_DIR}/ext/dist)

# ExternalProject_Add(
#   "JPEG"
#   PREFIX "external"
#   GIT_REPOSITORY https://github.com/csparker247/jpeg-cmake.git
#   DOWNLOAD_DIR ${DIR_DOWNLOAD}
#   SOURCE_DIR ${DIR_SRC}
#   INSTALL_DIR ${DIR_INSTALL}
#   BUILD_COMMAND ""
#   CMAKE_ARGS
#   "-DCMAKE_BUILD_TYPE=Release"
#   "-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}"
# )

set(VERSION v1.3.0)

build_dependency_with_cmake(JPEG
    GIT_REPOSITORY https://github.com/csparker247/jpeg-cmake.git
    GIT_TAG ${VERSION}
    CMAKE_ARGS
    -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
)

set (JPEG_ROOT ${JPEG_LOCAL_INSTALL_DIR})
set (JPEG_REFIND TRUE)
