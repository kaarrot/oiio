# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO

######################################################################
# Imath by hand!
######################################################################

set_cache (Imath_LOCAL_BUILD_VERSION 3.1.10 "Imath version for local builds")
set (Imath_GIT_REPOSITORY "https://github.com/AcademySoftwareFoundation/Imath")
set (Imath_GIT_TAG "v${Imath_LOCAL_BUILD_VERSION}")

build_dependency_with_cmake(Imath
    VERSION         ${Imath_LOCAL_BUILD_VERSION}
    GIT_REPOSITORY  ${Imath_GIT_REPOSITORY}
    GIT_TAG         ${Imath_GIT_TAG}
    CMAKE_ARGS
        # Build static libs
        -D BUILD_SHARED_LIBS=OFF
        # Don't built unnecessary parts of Imath
        -D BUILD_TESTING=OFF
        -D IMATH_BUILD_EXAMPLES=OFF
        -D IMATH_BUILD_PYTHON=OFF
        -D IMATH_BUILD_TESTING=OFF
        -D IMATH_BUILD_TOOLS=OFF
        -D IMATH_INSTALL_DOCS=OFF
        -D IMATH_INSTALL_PKG_CONFIG=OFF
        -D IMATH_INSTALL_TOOLS=OFF
    )


# Set some things up that we'll need for a subsequent find_package to work

# Signal to caller that we need to find again at the installed location
set (Imath_REFIND TRUE)
