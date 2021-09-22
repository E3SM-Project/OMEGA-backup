function(build_omega)

  # fix for new kokkos version; undo when mpas uses new kokkos build infrastructure
  set(USE_KOKKOS FALSE)

  file(GLOB OMEGACONFS "${BUILDCONF}/omegaconf" "${BUILDCONF}/mpassiconf" "${BUILDCONF}/maliconf")

  foreach(ITEM IN LISTS OMEGACONFS)
	get_filename_component(OMEGACONF ${ITEM} NAME)
	string(REPLACE "conf" "" COMP_NAME "${OMEGACONF}")

    if (COMP_NAME STREQUAL "omega")
      list(APPEND CORES "ocean")
      set(COMP_CLASS "ocn")
    elseif (COMP_NAME STREQUAL "mpassi")
      list(APPEND CORES "seaice")
      set(COMP_CLASS "ice")
    elseif (COMP_NAME STREQUAL "mali")
      list(APPEND CORES "landice")
      set(COMP_CLASS "glc")
    else()
      message(FATAL_ERROR "Unrecognized MPAS model ${COMP_NAME}")
    endif()

    message("Found MPAS component ${COMP_CLASS} model '${COMP_NAME}'")
  endforeach()

  if (USE_ALBANY)
    set(ALBANY True)
  endif()

  # set CIME source path relative to components
  set(CIMESRC_PATH "../cime/src")

  if (CORES)
    add_subdirectory("omega/src")
  endif()

endfunction(build_omega)
