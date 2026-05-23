
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was QmlAdvCoreConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

# Snapshot our own package paths BEFORE find_dependency(Qt6),
# because Qt6Config.cmake also calls 
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was QmlAdvCoreConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

#################################################################################### and overwrites
# PACKAGE_PREFIX_DIR. set_and_check() can't be used here for the same
# reason — the  tokens are expanded once at install time
# using OUR PACKAGE_PREFIX_DIR, but EXISTS checks must happen against
# absolute paths, which we hold onto in local variables.
set(_QmlAdvCore_lib_dir "${PACKAGE_PREFIX_DIR}/lib")
set(_QmlAdvCore_inc_dir "${PACKAGE_PREFIX_DIR}/include/QmlAdvCore")

include(CMakeFindDependencyMacro)
find_dependency(Qt6 REQUIRED COMPONENTS Quick)

if(NOT EXISTS "${_QmlAdvCore_lib_dir}")
    message(FATAL_ERROR
        "QmlAdvCore: library dir not found at ${_QmlAdvCore_lib_dir}")
endif()
if(NOT EXISTS "${_QmlAdvCore_inc_dir}")
    message(FATAL_ERROR
        "QmlAdvCore: include dir not found at ${_QmlAdvCore_inc_dir}")
endif()

# Backing library target
if(NOT TARGET QmlAdvCore::QmlAdvCore)
    add_library(QmlAdvCore::QmlAdvCore STATIC IMPORTED)
    set_target_properties(QmlAdvCore::QmlAdvCore PROPERTIES
        IMPORTED_LOCATION
            "${_QmlAdvCore_lib_dir}/${CMAKE_STATIC_LIBRARY_PREFIX}QmlAdvCore${CMAKE_STATIC_LIBRARY_SUFFIX}"
        INTERFACE_INCLUDE_DIRECTORIES "${_QmlAdvCore_inc_dir}"
        INTERFACE_LINK_LIBRARIES "Qt6::Quick"
    )
endif()

# QML plugin target — must also be linked to register QML types at runtime
if(NOT TARGET QmlAdvCore::QmlAdvCoreplugin)
    add_library(QmlAdvCore::QmlAdvCoreplugin STATIC IMPORTED)
    set_target_properties(QmlAdvCore::QmlAdvCoreplugin PROPERTIES
        IMPORTED_LOCATION
            "${_QmlAdvCore_lib_dir}/${CMAKE_STATIC_LIBRARY_PREFIX}QmlAdvCoreplugin${CMAKE_STATIC_LIBRARY_SUFFIX}"
        INTERFACE_LINK_LIBRARIES "QmlAdvCore::QmlAdvCore"
    )
endif()

check_required_components(QmlAdvCore)
