# First try to locate nf-config.
find_program( NetCDF_CONFIG_EXECUTABLE
   NAMES nf-config
   HINTS ENV NetCDF_ROOT
   PATH_SUFFIXES bin Bin
   DOC "NetCDF config program. Used to detect NetCDF include directory and linker flags." )
mark_as_advanced(NetCDF_CONFIG_EXECUTABLE)

if(NetCDF_CONFIG_EXECUTABLE)

# Found nf-config - use it to retrieve include directory and linking flags.
# Mark NetCDF paths as advanced configuration options in CMake (hidden by default).
execute_process(COMMAND ${NetCDF_CONFIG_EXECUTABLE} --includedir
                OUTPUT_VARIABLE includedir
                OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${NetCDF_CONFIG_EXECUTABLE} --flibs
                OUTPUT_VARIABLE flibs
                OUTPUT_STRIP_TRAILING_WHITESPACE)
set(NetCDF_INCLUDE_DIRS ${includedir} CACHE STRING "NetCDF include directories")
set(NetCDF_LIBRARIES ${flibs} CACHE STRING "NetCDF linking flags")
mark_as_advanced(NetCDF_INCLUDE_DIRS NetCDF_LIBRARIES)

elseif (WIN32)

set(GOTMDIR "${CMAKE_CURRENT_LIST_DIR}/../../..")

# On Windows: use CMake to locate paths; default to NetCDF static library provided with GOTM.
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
message("NetCDF 64 bit")
find_library(NetCDF_LIBRARIES NAMES netcdfs
             HINTS ${GOTMDIR}/extras/netcdf/Win64/3.6.3/lib
             DOC "NetCDF 64bit library")
find_path(NetCDF_INCLUDE_DIRS netcdf.mod
          HINTS ${GOTMDIR}/extras/netcdf/Win64/3.6.3/include ENV NetCDFINC
          DOC "NetCDF 64bit include directory")
get_filename_component(NetCDF_LIBRARIES_default_full "${GOTMDIR}/extras/netcdf/Win64/3.6.3/lib/netcdfs.lib" ABSOLUTE)
else()
message("NetCDF 32bit")
find_library(NetCDF_LIBRARIES NAMES netcdfs
             HINTS ${GOTMDIR}/extras/netcdf/Win32/3.6.3/lib
             DOC "NetCDF 32bit library")
find_path(NetCDF_INCLUDE_DIRS netcdf.mod
          HINTS ${GOTMDIR}/extras/netcdf/Win32/3.6.3/include ENV NetCDFINC
          DOC "NetCDF 32bit include directory")
get_filename_component(NetCDF_LIBRARIES_default_full "${GOTMDIR}/extras/netcdf/Win32/3.6.3/lib/netcdfs.lib" ABSOLUTE)
endif()

list(LENGTH NetCDF_LIBRARIES LIBCOUNT)
if(LIBCOUNT EQUAL 1)
get_filename_component(NetCDF_LIBRARIES_full ${NetCDF_LIBRARIES} ABSOLUTE)
if(MSVC AND NetCDF_LIBRARIES_full STREQUAL NetCDF_LIBRARIES_default_full)
  # Win32 NetCDF library provided with GOTM is statically built against release libraries.
  # Dependent projects need to do the same in release mode to prevent linking conflicts.
  set(NetCDF_STATIC_MSVC_BUILD TRUE)
endif()
endif()

message("${NetCDF_STATIC_MSVC_BUILD}")

else()

# Use GOTM environment variables: NETCDFLIBNAME, NETCDFLIBDIR, NETCDFINC
if(DEFINED ENV{NETCDFLIBNAME})
  set(flibs $ENV{NETCDFLIBNAME})
else()
  set(flibs "-lnetcdf")
endif()
if(DEFINED ENV{NETCDFLIBDIR})
  set(flibs "-L$ENV{NETCDFLIBDIR} ${flibs}")
endif()
set(NetCDF_LIBRARIES ${flibs} CACHE STRING "NetCDF linking flags")
find_path(NetCDF_INCLUDE_DIRS netcdf.mod
          HINTS ENV NETCDFINC
          DOC "NetCDF include directory")

endif()

# Process default arguments (QUIET, REQUIRED)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args (NetCDF DEFAULT_MSG NetCDF_LIBRARIES NetCDF_INCLUDE_DIRS)

# For backward compatibility:
set(NetCDF_LIBRARY NetCDF_LIBRARIES)
set(NetCDF_INCLUDE_DIR NetCDF_INCLUDE_DIRS)
