cmake_minimum_required(VERSION 3.25)

include(ExternalProject)

set(DIR_DOWNLOAD  ${CMAKE_BINARY_DIR}/ext/download)
set(DIR_SRC  ${CMAKE_BINARY_DIR}/ext/src)
set(DIR_INSTALL  ${CMAKE_BINARY_DIR}/ext/dist)

# This option is preffred I think as it allows to install the Externl project first and combind all the include/lib into a single path
# ExternalProject_Add(
#   "ZLIB"
#   PREFIX "external"
#   GIT_REPOSITORY https://github.com/madler/zlib.git
#   DOWNLOAD_DIR ${DIR_DOWNLOAD}
#   SOURCE_DIR ${DIR_SRC}
#   INSTALL_DIR ${DIR_INSTALL}
#   BUILD_COMMAND ""
#   CMAKE_ARGS
#   "-DCMAKE_BUILD_TYPE=Release"
#   "-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}"
# )

message(STATUS ZZZZZZZZZZZZ: ${ZLIB_LOCAL_INSTALL_DIR})


set_cache (ZLIB_LOCAL_BUILD_VERSION v1.3.0 "Zlib version for local builds")

#NOTE: do not speocify -DCMAKE_INSTALL_PREFIX= or ZLIB_REFIND may not detect existing build
build_dependency_with_cmake(ZLIB
    GIT_REPOSITORY "https://github.com/madler/zlib.git"
    GIT_TAG v1.3.1
    CMAKE_ARGS
    -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    )

# Set some things up that we'll need for a subsequent find_package to work
set (ZLIB_ROOT ${ZLIB_LOCAL_INSTALL_DIR})

# Signal to caller that we need to find again at the installed location
set (ZLIB_REFIND TRUE)

