cmake_minimum_required(VERSION 3.25)

include(ExternalProject)

set(DIR_DOWNLOAD  ${CMAKE_BINARY_DIR}/ext/download)
set(DIR_SRC  ${CMAKE_BINARY_DIR}/ext/src)
set(DIR_INSTALL  ${CMAKE_BINARY_DIR}/ext/dist)

set(VERSION v4.3.0)

# ExternalProject_Add(
#   "TIFF"
#   PREFIX "external"
#   GIT_REPOSITORY https://gitlab.com/libtiff/libtiff.git
#   GIT_TAG ${VERSION}
#   DOWNLOAD_DIR ${DIR_DOWNLOAD}
#   SOURCE_DIR ${DIR_SRC}
#   INSTALL_DIR ${DIR_INSTALL}
#   BUILD_COMMAND ""
#   CMAKE_ARGS
#   "-DCMAKE_BUILD_TYPE=Release"
#   "-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}"
#   "-DBUILD_SHARED_LIBS=ON"
#   "-Dtiff-tests=OFF"
#   "-Dtiff-docs=OFF"
#   "-Dlibdeflate=ON"
# )


build_dependency_with_cmake(TIFF
    GIT_REPOSITORY https://gitlab.com/libtiff/libtiff.git
    GIT_TAG ${VERSION}
    CMAKE_ARGS
    -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    "-DBUILD_SHARED_LIBS=ON"
    "-Dtiff-tests=OFF"
    "-Dtiff-docs=OFF"
    "-Dlibdeflate=ON"
    )

# Set some things up that we'll need for a subsequent find_package to work
set (TIFF_ROOT ${TIFF_LOCAL_INSTALL_DIR})

set(TIFF_VERSION ${VERSION})
set (TIFF_REFIND TRUE) 