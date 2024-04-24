# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO

######################################################################
# OpenColorIO by hand!
######################################################################

set_cache (OpenColorIO_LOCAL_BUILD_VERSION 2.3.2 "OpenColorIO version for local builds")
set (OpenColorIO_GIT_REPOSITORY "https://github.com/AcademySoftwareFoundation/OpenColorIO")
set (OpenColorIO_GIT_TAG "v${OpenColorIO_LOCAL_BUILD_VERSION}")

build_dependency_with_cmake(OpenColorIO
    VERSION         ${OpenColorIO_LOCAL_BUILD_VERSION}
    GIT_REPOSITORY  ${OpenColorIO_GIT_REPOSITORY}
    GIT_TAG         ${OpenColorIO_GIT_TAG}
    CMAKE_ARGS
        # We would prefer to build a static OCIO, but haven't figured out how
        # to make it all work with the static dependencies, it just makes
        # things complicated downstream.
        -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -D BUILD_SHARED_LIBS=ON
        -D CMAKE_INSTALL_LIBDIR=lib
        # Don't built unnecessary parts of OCIO
        -D OCIO_BUILD_APPS=OFF
        -D OCIO_BUILD_GPU_TESTS=OFF
        -D OCIO_BUILD_PYTHON=OFF
        -D OCIO_BUILD_TESTS=OFF
        -D OCIO_USE_OIIO_FOR_APPS=OFF
        -D OCIO_INSTALL_DOCS=OFF
        # Make OCIO build all its dependencies statically
        -D OCIO_INSTALL_EXT_PACKAGES=ALL
        # Give the library a custom name and symbol namespace so it can't
        # conflict with any others in the system or linked into the same app.
        -D OCIO_NAMESPACE=OIIO_OpenColorIO
        -D OCIO_LIBNAME_SUFFIX=_${PROJ_NAME}_${PROJECT_VERSION_MAJOR}_${PROJECT_VERSION_MINOR}_
    )

# Set some things up that we'll need for a subsequent find_package to work
#list (APPEND CMAKE_PREFIX_PATH ${OpenColorIO_LOCAL_INSTALL_DIR})
#set (OpenColorIO_ROOT ${OpenColorIO_LOCAL_INSTALL_DIR})
set (OpenColorIO_DIR ${OpenColorIO_LOCAL_INSTALL_DIR})

# Signal to caller that we need to find again at the installed location
set (OpenColorIO_REFIND TRUE)

# We need to include the OpenColorIO dynamic libraries in our own install.
file (GLOB _ocio_lib_files "${OpenColorIO_LOCAL_INSTALL_DIR}/lib/*OpenColorIO*"
                           "${OpenColorIO_LOCAL_INSTALL_DIR}/lib/${CMAKE_BUILD_TYPE}/*OpenColorIO*")
install (FILES ${_ocio_lib_files} TYPE LIB)
