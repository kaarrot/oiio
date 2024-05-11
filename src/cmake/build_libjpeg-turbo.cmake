cmake_minimum_required(VERSION 3.25)

include(ExternalProject)

set(DIR_DOWNLOAD  ${CMAKE_BINARY_DIR}/ext/download)
set(DIR_SRC  ${CMAKE_BINARY_DIR}/ext/src)
set(DIR_INSTALL  ${CMAKE_BINARY_DIR}/ext/dist)

set(VERSION 3.0.0)

# ExternalProject_Add(
#   "libjpeg-turbo"
#   PREFIX "external"
#   GIT_REPOSITORY https://github.com/libjpeg-turbo/libjpeg-turbo.git
#   GIT_TAG ${VERSION}
#   DOWNLOAD_DIR ${DIR_DOWNLOAD}
#   SOURCE_DIR ${DIR_SRC}
#   INSTALL_DIR ${DIR_INSTALL}
#   BUILD_COMMAND ""
#   CMAKE_ARGS
#   "-DCMAKE_BUILD_TYPE=Release"
#   "-DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}"
# )


build_dependency_with_cmake(libjpeg-turbo
    VERSION         ${VERSION}
    GIT_REPOSITORY  https://github.com/libjpeg-turbo/libjpeg-turbo.git
    GIT_TAG         ${VERSION}
    CMAKE_ARGS
    -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    )

# Set some things up that we'll need for a subsequent find_package to work
set (libjpeg-turbo_ROOT ${libjpeg-turbo_LOCAL_INSTALL_DIR})

# Signal to caller that we need to find again at the installed location
set (libjpeg_REFIND TRUE)