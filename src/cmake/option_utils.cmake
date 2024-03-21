# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO


# Wrapper for CMake `set()` functionality with extensions:
# - If an env variable of the same name exists, it overrides the default
#   value.
# - In verbose mode, print the value and whether it came from the env.
# - CACHE optional token makes it a cache variable.
# - ADVANCED optional token sets it as "mark_as_advanced" without the need
#   for a separate call (only applies to cache variables.)
# - FILEPATH, PATH, BOOL, STRING optional token works as usual (only applies
#   to cache variables).
# - `DOC <docstring>` specifies a doc string for cache variables. If omitted,
#   an empty doc string will be used.
# Other extensions may be added in the future.
macro (super_set name value)
    cmake_parse_arguments(_sce   # prefix
        # noValueKeywords:
        "FORCE;ADVANCED;FILEPATH;PATH;BOOL;STRING;CACHE"
        # singleValueKeywords:
        "DOC"
        # multiValueKeywords:
        ""
        # argsToParse:
        ${ARGN})
    set (_sce_extra_args "")
    if (_sce_FILEPATH)
        set (_sce_type "FILEPATH")
    elseif (_sce_PATH)
        set (_sce_type "PATH")
    elseif (_sce_BOOL)
        set (_sce_type "BOOL")
    else ()
        set (_sce_type "STRING")
    endif ()
    if (_sce_FORCE)
        list (APPEND _sce_extra_args FORCE)
    endif ()
    if (NOT _sce_DOC)
        set (_sce_DOC "empty")
    endif ()
    if (DEFINED ENV{${name}} AND NOT "$ENV{${name}}" STREQUAL "")
        set (_sce_val $ENV{${name}})
        message (VERBOSE "set ${ColorBoldWhite}Option${ColorReset} ${name} = ${_sce_val} (from env)")
    else ()
        set (_sce_val ${value})
        message (VERBOSE "set ${ColorBoldWhite}Option${ColorReset} ${name} = ${_sce_val}")
    endif ()
    if (_sce_CACHE)
        message (STATUS "set (${name} ${_sce_val} CACHE ${_sce_type} ${_sce_DOC} ${_sce_extra_args})")
        set (${name} ${_sce_val} CACHE ${_sce_type} ${_sce_DOC} ${_sce_extra_args})
        # set (${name} ${_sce_val} CACHE ${_sce_type} ${_sce_DOC} ${_sce_extra_args})
    else ()
        set (${name} ${_sce_val} ${_sce_extra_args})
    endif ()
    if (_sce_ADVANCED)
        mark_as_advanced (${name})
    endif ()
    unset (_sce_extra_args)
    unset (_sce_type)
    unset (_sce_val)
endmacro ()


# `set(... CACHE ...)` workalike using super_set underneath.
macro (set_cache name value docstring)
    super_set (${name} "${value}" DOC ${docstring} ${ARGN})
endmacro ()


# `option()` workalike using super_set underneath.
macro (set_option name docstring value)
    set_cache (${name} "${value}" ${docstring} BOOL ${ARGN})
endmacro ()
