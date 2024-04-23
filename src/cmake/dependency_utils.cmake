# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO


set_cache (${PROJECT_NAME}_REQUIRED_DEPS ""
     "Additional dependencies to consider required (semicolon-separated list, or ALL)")
set_cache (${PROJECT_NAME}_OPTIONAL_DEPS ""
     "Additional dependencies to consider optional (semicolon-separated list, or ALL)")
set_option (${PROJECT_NAME}_ALWAYS_PREFER_CONFIG "Prefer a dependency's exported config file if it's available" OFF)

# Track all build deps we find with checked_find_package
set (CFP_ALL_BUILD_DEPS_FOUND "")

# Utility function to list the names and values of all variables matching
# the pattern (case-insensitive)
function (dump_matching_variables pattern)
    string (TOLOWER ${pattern} _pattern_lower)
    get_cmake_property(_allvars VARIABLES)
    list (SORT _allvars)
    foreach (_var IN LISTS _allvars)
        string (TOLOWER ${_var} _var_lower)
        if (_var_lower MATCHES ${_pattern_lower})
            message (STATUS "    ${_var} = ${${_var}}")
        endif ()
    endforeach ()
endfunction ()


# Helper: called if a package is not found, print error messages, including
# a fatal error if the package was required.
function (handle_package_notfound pkgname required)
    message (STATUS "${ColorRed}${pkgname} library not found ${ColorReset}")
    if (${pkgname}_ROOT)
        message (STATUS "${ColorRed}    ${pkgname}_ROOT was: ${${pkgname}_ROOT} ${ColorReset}")
    elseif ($ENV{${pkgname}_ROOT})
        message (STATUS "${ColorRed}    ENV ${pkgname}_ROOT was: ${${pkgname}_ROOT} ${ColorReset}")
    else ()
        message (STATUS "${ColorRed}    Try setting ${pkgname}_ROOT ? ${ColorReset}")
    endif ()
    if (EXISTS "${PROJECT_SOURCE_DIR}/src/build-scripts/build_${pkgname}.bash")
        message (STATUS "${ColorRed}    Maybe this will help:  src/build-scripts/build_${pkgname}.bash ${ColorReset}")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/src/build-scripts/build_${pkgname_upper}.bash")
        message (STATUS "${ColorRed}    Maybe this will help:  src/build-scripts/build_${pkgname_upper}.bash ${ColorReset}")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/src/build-scripts/build_${pkgname_lower}.bash")
            message (STATUS "${ColorRed}    Maybe this will help:  src/build-scripts/build_${pkgname_lower}.bash ${ColorReset}")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/src/build-scripts/build_lib${pkgname_lower}.bash")
            message (STATUS "${ColorRed}    Maybe this will help:  src/build-scripts/build_lib${pkgname_lower}.bash ${ColorReset}")
    endif ()
    if (required)
        message (FATAL_ERROR "${ColorRed}${pkgname} is required, aborting.${ColorReset}")
    endif ()
endfunction ()


# checked_find_package(Pkgname ...) is a wrapper for find_package, with the
# following extra features:
#   * If either `USE_Pkgname` or the all-uppercase `USE_PKGNAME` (or
#     `ENABLE_Pkgname` or `ENABLE_PKGNAME`) exists as either a CMake or
#     environment variable, is nonempty by contains a non-true/nonzero
#     value, do not search for or use the package. The optional ENABLE <var>
#     arguments allow you to override the name of the enabling variable. In
#     other words, support for the dependency is presumed to be ON, unless
#     turned off explicitly from one of these sources.
#   * Print a message if the package is enabled but not found. This is based
#     on ${Pkgname}_FOUND or $PKGNAME_FOUND.
#   * Optional DEFINITIONS <string>... are passed to
#     proj_add_compile_definitions if the package is found.
#   * Optional SETVARIABLES <id>... is a list of CMake variables to set to
#     TRUE if the package is found (they will not be set or changed if the
#     package is not found).
#   * Optional PRINT <list> is a list of variables that will be printed
#     if the package is found, if VERBOSE is on.
#   * Optional DEPS <list> is a list of hard dependencies; for each one, if
#     dep_FOUND is not true, disable this package with an error message.
#   * Optional ISDEPOF <downstream> names another package for which the
#     present package is only needed because it's a dependency, and
#     therefore if <downstream> is disabled, we don't bother with this
#     package either.
#   * Optional VERSION_MIN and VERSION_MAX, if supplied, give minimum and
#     maximum versions that will be accepted. The min is inclusive, the max
#     is exclusive (i.e., check for min <= version < max). Note that this is
#     not the same as providing a version number to find_package, which
#     checks compatibility, not minimum. Sometimes we really do just want to
#     say a minimum or a range. (N.B. When our minimum CMake >= 3.19, the
#     built-in way to do this is with version ranges passed to
#     find_package.)
#   * Optional RECOMMEND_MIN, if supplied, gives a minimum recommended
#     version, accepting but warning if it is below this number (even
#     if above the true minimum version accepted). The warning message
#     can give an optional explanation, passed as RECOMMEND_MIN_REASON.
#   * Optional CONFIG, if supplied, only accepts the package from an
#     exported config and never uses a FindPackage.cmake module.
#   * Optional PREFER_CONFIG, if supplied, tries to use an exported config
#     file from the package before using a FindPackage.cmake module.
#   * Optional DEBUG turns on extra debugging information related to how
#     this package is found.
#   * Found package "name version" or "name NONE" are accumulated in the list
#     CFP_ALL_BUILD_DEPS_FOUND. If the optional NO_RECORD_NOTFOUND is
#     supplied, un-found packags will not be recorded.
#   * Optional BUILD_LOCAL, if supplied, if followed by a token that specifies
#     the conditions under which to build the package locally by including a
#     script included in src/cmake/build_${pkgname}.cmake. If the condition is
#     "always", it will attempt to do so unconditionally. If "missing", it
#     will only do so if the package is not found. Also note that if the
#     global ${PROJECT_NAME}_BUILD_LOCAL_DEPS contains the package name or
#     is "all", it will behave as if set to "always", and if the variable
#     ${PROJECT_NAME}_BUILD_MISSING_DEPS contains the package name or is
#     "all", it will behave as if set to "missing".
#
# N.B. This needs to be a macro, not a function, because the find modules
# will set(blah val PARENT_SCOPE) and we need that to be the global scope,
# not merely the scope for this function.
macro (checked_find_package pkgname)
    #
    # Various setup logic
    #
    cmake_parse_arguments(_pkg   # prefix
        # noValueKeywords:
        "REQUIRED;CONFIG;PREFER_CONFIG;DEBUG;NO_RECORD_NOTFOUND"
        # singleValueKeywords:
        "ENABLE;ISDEPOF;VERSION_MIN;VERSION_MAX;RECOMMEND_MIN;RECOMMEND_MIN_REASON;BUILD_LOCAL"
        # multiValueKeywords:
        "DEFINITIONS;PRINT;DEPS;SETVARIABLES"
        # argsToParse:
        ${ARGN})
    string (TOLOWER ${pkgname} pkgname_lower)
    string (TOUPPER ${pkgname} pkgname_upper)
    set (_pkg_VERBOSE ${VERBOSE})
    if (_pkg_DEBUG)
        set (_pkg_VERBOSE ON)
    endif ()
    if (NOT _pkg_VERBOSE)
        set (${pkgname}_FIND_QUIETLY true)
        set (${pkgname_upper}_FIND_QUIETLY true)
    endif ()
    if ("${pkgname}" IN_LIST ${PROJECT_NAME}_REQUIRED_DEPS OR "ALL" IN_LIST ${PROJECT_NAME}_REQUIRED_DEPS)
        set (_pkg_REQUIRED 1)
    endif ()
    if ("${pkgname}" IN_LIST ${PROJECT_NAME}_OPTIONAL_DEPS OR "ALL" IN_LIST ${PROJECT_NAME}_OPTIONAL_DEPS)
        set (_pkg_REQUIRED 0)
    endif ()
    # string (TOLOWER "${_pkg_BUILD_LOCAL}" _pkg_BUILD_LOCAL)
    if ("${pkgname}" IN_LIST ${PROJECT_NAME}_BUILD_LOCAL_DEPS
        OR ${PROJECT_NAME}_BUILD_LOCAL_DEPS STREQUAL "all")
        set (_pkg_BUILD_LOCAL "always")
    elseif ("${pkgname}" IN_LIST ${PROJECT_NAME}_BUILD_MISSING_DEPS
            OR ${PROJECT_NAME}_BUILD_MISSING_DEPS STREQUAL "all")
        set_if_not (_pkg_BUILD_LOCAL "missing")
    endif ()
    if (_pkg_BUILD_LOCAL AND NOT EXISTS "${PROJECT_SOURCE_DIR}/src/cmake/build_${pkgname}.cmake")
        unset (_pkg_BUILD_LOCAL)
    endif ()
    set (_quietskip false)
    check_is_enabled (${pkgname} _enable)
    set (_disablereason "")
    foreach (_dep ${_pkg_DEPS})
        if (_enable AND NOT ${_dep}_FOUND)
            set (_enable false)
            set (ENABLE_${pkgname} OFF PARENT_SCOPE)
            set (_disablereason "(because ${_dep} was not found)")
        endif ()
    endforeach ()
    if (_pkg_ISDEPOF)
        check_is_enabled (${_pkg_ISDEPOF} _dep_enabled)
        if (NOT _dep_enabled)
            set (_enable false)
            set (_quietskip true)
        endif ()
    endif ()
    set (_config_status "")
    unset (_${pkgname}_version_range)
    if (_pkg_BUILD_LOCAL)
        if (_pkg_VERSION_MIN AND _pkg_VERSION_MAX AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.19)
            set (_${pkgname}_version_range "${_pkg_VERSION_MIN}...<${_pkg_VERSION_MAX}")
        elseif (_pkg_VERSION_MIN)
            set (_${pkgname}_version_range "${_pkg_VERSION_MIN}")
        endif ()
    endif ()
    #
    # Now we try to find or build
    #
    if (_enable OR _pkg_REQUIRED)
        # Unless instructed not to, try to find the package externally
        # installed.
        if (${pkgname}_FOUND OR ${pkgname_upper}_FOUND OR _pkg_BUILD_LOCAL STREQUAL "always")
            # was already found, or we're forcing a local build
        elseif (_pkg_CONFIG OR _pkg_PREFER_CONFIG OR ${PROJECT_NAME}_ALWAYS_PREFER_CONFIG)
            find_package (${pkgname} ${_${pkgname}_version_range} CONFIG ${_pkg_UNPARSED_ARGUMENTS})
            if (${pkgname}_FOUND OR ${pkgname_upper}_FOUND)
                set (_config_status "from CONFIG")
            endif ()
        endif ()
        if (NOT ${pkgname}_FOUND AND NOT ${pkgname_upper}_FOUND AND NOT _pkg_BUILD_LOCAL STREQUAL "always" AND NOT _pkg_CONFIG)
            find_package (${pkgname} ${_${pkgname}_version_range} ${_pkg_UNPARSED_ARGUMENTS})
        endif()
        # If the package was found but the version is outside the required
        # range, unset the relevant variables so that we can try again fresh.
        if ((${pkgname}_FOUND OR ${pkgname_upper}_FOUND)
              AND ${pkgname}_VERSION
              AND (_pkg_VERSION_MIN OR _pkg_VERSION_MAX))
            if ((_pkg_VERSION_MIN AND ${pkgname}_VERSION VERSION_LESS _pkg_VERSION_MIN)
                  OR (_pkg_VERSION_MAX AND ${pkgname}_VERSION VERSION_GREATER _pkg_VERSION_MAX))
                message (STATUS "${ColorRed}${pkgname} ${${pkgname}_VERSION} is outside the required range ${_pkg_VERSION_MIN}...${_pkg_VERSION_MAX} ${ColorReset}")
                unset (${pkgname}_FOUND)
                unset (${pkgname}_VERSION)
                unset (${pkgname}_INCLUDE)
                unset (${pkgname}_INCLUDES)
                unset (${pkgname}_LIBRARY)
                unset (${pkgname}_LIBRARIES)
                unset (${pkgname_upper}_FOUND)
                unset (${pkgname_upper}_VERSION)
                unset (${pkgname_upper}_INCLUDE)
                unset (${pkgname_upper}_INCLUDES)
                unset (${pkgname_upper}_LIBRARY)
                unset (${pkgname_upper}_LIBRARIES)
            endif ()
        endif ()
        # If we haven't found the package yet and are allowed to build a local
        # version, and a build_<pkgname>.cmake exists, include it to build the
        # package locally.
        if (NOT ${pkgname}_FOUND AND NOT ${pkgname_upper}_FOUND
            AND (_pkg_BUILD_LOCAL STREQUAL "always" OR _pkg_BUILD_LOCAL STREQUAL "missing")
            AND EXISTS "${PROJECT_SOURCE_DIR}/src/cmake/build_${pkgname}.cmake")
            message (STATUS "${ColorMagenta}Building package ${pkgname} ${${pkgname}_VERSION} locally${ColorReset}")
            list(APPEND CMAKE_MESSAGE_INDENT "        ")
            include(${PROJECT_SOURCE_DIR}/src/cmake/build_${pkgname}.cmake)
            list(POP_BACK CMAKE_MESSAGE_INDENT)
            set (${pkgname}_FOUND TRUE)
            set (${pkgname}_LOCAL_BUILD TRUE)
        endif()
        # If the local build instrctions set <pkgname>_REFIND, then try a find
        # again to pick up the local one, at which point we can proceed as if
        # it had been found externally all along.
        if (${pkgname}_REFIND)
            message (STATUS "Refinding ${pkgname}")
            find_package (${pkgname} ${_${pkgname}_version_range} ${_pkg_UNPARSED_ARGUMENTS} ${${pkgname}_REFIND_ARGS})
            unset (${pkgname}_REFIND)
        endif()
        # It's all downhill from here: if we found the package, follow the
        # various instructions we got about variables to set, compile
        # definitions to add, etc.
        if (${pkgname}_FOUND OR ${pkgname_upper}_FOUND)
            foreach (_vervar ${pkgname_upper}_VERSION ${pkgname}_VERSION_STRING
                             ${pkgname_upper}_VERSION_STRING)
                if (NOT ${pkgname}_VERSION AND ${_vervar})
                    set (${pkgname}_VERSION ${${_vervar}})
                endif ()
            endforeach ()
            message (STATUS "${ColorGreen}Found ${pkgname} ${${pkgname}_VERSION} ${_config_status}${ColorReset}")
            proj_add_compile_definitions (${_pkg_DEFINITIONS})
            foreach (_v IN LISTS _pkg_SETVARIABLES)
                set (${_v} TRUE)
            endforeach ()
            if (_pkg_RECOMMEND_MIN)
                if (${${pkgname}_VERSION} VERSION_LESS ${_pkg_RECOMMEND_MIN})
                    message (STATUS "${ColorYellow}Recommend ${pkgname} >= ${_pkg_RECOMMEND_MIN} ${_pkg_RECOMMEND_MIN_REASON} ${ColorReset}")
                endif ()
            endif ()
            string (STRIP "${pkgname} ${${pkgname}_VERSION}" app_)
            list (APPEND CFP_ALL_BUILD_DEPS_FOUND "${app_}")
        else ()
            handle_package_notfound (${pkgname} ${_pkg_REQUIRED})
            if (NOT _pkg_NO_RECORD_NOTFOUND)
                list (APPEND CFP_ALL_BUILD_DEPS_FOUND "${pkgname} NONE")
            endif ()
        endif()
        if (_pkg_VERBOSE AND (${pkgname}_FOUND OR ${pkgname_upper}_FOUND OR _pkg_DEBUG))
            if (_pkg_DEBUG)
                dump_matching_variables (${pkgname})
            endif ()
            set (_vars_to_print ${pkgname}_INCLUDES ${pkgname_upper}_INCLUDES
                                ${pkgname}_INCLUDE_DIR ${pkgname_upper}_INCLUDE_DIR
                                ${pkgname}_INCLUDE_DIRS ${pkgname_upper}_INCLUDE_DIRS
                                ${pkgname}_LIBRARIES ${pkgname_upper}_LIBRARIES
                                ${_pkg_PRINT})
            list (REMOVE_DUPLICATES _vars_to_print)
            foreach (_v IN LISTS _vars_to_print)
                if (NOT "${${_v}}" STREQUAL "")
                    message (STATUS "    ${_v} = ${${_v}}")
                endif ()
            endforeach ()
        endif ()
    else ()
        if (NOT _quietskip)
            message (STATUS "${ColorRed}Not using ${pkgname} -- disabled ${_disablereason} ${ColorReset}")
        endif ()
    endif ()
    unset (_${pkgname}_version_range)
endmacro()



# Helper to build a dependency with CMake. Given a package name, git repo and
# tag, and optional cmake args, it will clone the repo into the surrounding
# project's build area, configures, and build sit, and installs it into a
# special dist area (unless the NOINSTALL option is given).
#
# After running, it leaves the following variables set:
#   ${pkgname}_LOCAL_SOURCE_DIR
#   ${pkgname}_LOCAL_BUILD_DIR
#   ${pkgname}_LOCAL_INSTALL_DIR
#
# Unless NOINSTALL is specified, the after the installation step, the
# installation directory will be added to the CMAKE_PREFIX_PATH and also will
# be stored in the ${pkgname}_ROOT variable.
#
macro (build_dependency_with_cmake pkgname)
    cmake_parse_arguments(_pkg   # prefix
        # noValueKeywords:
        "NOINSTALL"
        # singleValueKeywords:
        "GIT_REPOSITORY;GIT_TAG;VERSION"
        # multiValueKeywords:
        "CMAKE_ARGS"
        # argsToParse:
        ${ARGN})

    message (STATUS "Building local ${pkgname} ${_pkg_VERSION} from ${_pkg_GIT_REPOSITORY}")

    set (${pkgname}_LOCAL_SOURCE_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}")
    set (${pkgname}_LOCAL_BUILD_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}-build")
    set (${pkgname}_LOCAL_INSTALL_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/dist")
    message (STATUS "Downloading local ${_pkg_GIT_REPOSITORY}")

    # Clone the repo if we don't already have it
    find_package (Git REQUIRED)
    if (NOT IS_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})
        execute_process(COMMAND ${GIT_EXECUTABLE} clone ${_pkg_GIT_REPOSITORY}
                                -b ${_pkg_GIT_TAG} --depth 1
                                ${${pkgname}_LOCAL_SOURCE_DIR})
        if (NOT IS_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})
            message (FATAL_ERROR "Could not download ${_pkg_GIT_REPOSITORY}")
        endif ()
    endif ()
    execute_process(COMMAND ${GIT_EXECUTABLE} checkout ${_pkg_GIT_TAG}
                    WORKING_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})

    set (_pkg_quiet OUTPUT_QUIET)

    # Configure the package
    execute_process (COMMAND
        ${CMAKE_COMMAND}
            # Put things in our special local build areas
                -S ${${pkgname}_LOCAL_SOURCE_DIR}
                -B ${${pkgname}_LOCAL_BUILD_DIR}
                -DCMAKE_INSTALL_PREFIX=${${pkgname}_LOCAL_INSTALL_DIR}
            # Same build type as us
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            # Shhhh
                -DCMAKE_MESSAGE_INDENT="        "
                -DCMAKE_MESSAGE_LOG_LEVEL=WARNING
                -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF
                -DCMAKE_VERBOSE_MAKEFILE=OFF
                -DCMAKE_RULE_MESSAGES=OFF
            # Build args passed by caller
                ${_pkg_CMAKE_ARGS}
        ${pkg_quiet}
        )

    # Build the package
    execute_process (COMMAND ${CMAKE_COMMAND}
                        --build ${${pkgname}_LOCAL_BUILD_DIR}
                     ${pkg_quiet}
                    )

    # Install the project, unless instructed not to do so
    if (NOT _pkg_NOINSTALL)
        execute_process (COMMAND ${CMAKE_COMMAND}
                            --build ${${pkgname}_LOCAL_BUILD_DIR}
                            --target install
                         ${pkg_quiet}
                        )
        set (${pkgname}_ROOT ${${pkgname}_LOCAL_INSTALL_DIR})
        list (APPEND CMAKE_PREFIX_PATH ${${pkgname}_LOCAL_INSTALL_DIR})
    endif ()
endmacro ()
