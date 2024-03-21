# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO


set_cache (OpenEXR_LOCAL_BUILD_VERSION 3.2.3 "OpenEXR version for local builds")
set (OpenEXR_GIT_REPOSITORY "https://github.com/AcademySoftwareFoundation/OpenEXR")
set (OpenEXR_GIT_TAG "v${OpenEXR_LOCAL_BUILD_VERSION}")

build_dependency_with_cmake(OpenEXR
    VERSION         ${OpenEXR_LOCAL_BUILD_VERSION}
    GIT_REPOSITORY  ${OpenEXR_GIT_REPOSITORY}
    GIT_TAG         ${OpenEXR_GIT_TAG}
    CMAKE_ARGS
        -D BUILD_SHARED_LIBS=OFF
        -D OPENEXR_FORCE_INTERNAL_DEFLATE=ON
        # Don't built unnecessary parts of OpenEXR
        -D BUILD_TESTING=OFF
        -D BUILD_WEBSITE=OFF
        -D OPENEXR_BUILD_EXAMPLES=OFF
        -D OPENEXR_BUILD_PYTHON=OFF
        -D OPENEXR_BUILD_SHARED_LIBS=OFF
        -D OPENEXR_BUILD_TOOLS=OFF
        -D OPENEXR_BUILD_WEBSITE=OFF
        -D OPENEXR_INSTALL_DOCS=OFF
        -D OPENEXR_INSTALL_PKG_CONFIG=OFF
        -D OPENEXR_INSTALL_TOOLS=OFF
    )

# Signal to caller that we need to find again at the installed location
set (OpenEXR_REFIND TRUE)
