# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/fftw3/FFTW3LibraryDepends.cmake
# Copyright (C) 2026 The T2 SDE Project
# Copyright (C) 2026 René Rebe <rene@exactco.de>
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# FFTW3:: imported targets for the autotools build, which only installs the
# FFTW3*Config.cmake files, of all installed precisions and thread libraries

get_filename_component(_fftw3_libdir "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
get_filename_component(_fftw3_includedir "${_fftw3_libdir}/@FFTW3_INCLUDE_REL@" ABSOLUTE)

foreach(_fftw3_prec "" f l q)
	foreach(_fftw3_variant "" _threads _omp)
		set(_fftw3_name "fftw3${_fftw3_prec}${_fftw3_variant}")
		if(TARGET FFTW3::${_fftw3_name})
			continue()
		endif()

		if(EXISTS "${_fftw3_libdir}/lib${_fftw3_name}.so")
			add_library(FFTW3::${_fftw3_name} SHARED IMPORTED)
			set_target_properties(FFTW3::${_fftw3_name} PROPERTIES
				IMPORTED_LOCATION "${_fftw3_libdir}/lib${_fftw3_name}.so")
		elseif(EXISTS "${_fftw3_libdir}/lib${_fftw3_name}.a")
			add_library(FFTW3::${_fftw3_name} STATIC IMPORTED)
			set_target_properties(FFTW3::${_fftw3_name} PROPERTIES
				IMPORTED_LOCATION "${_fftw3_libdir}/lib${_fftw3_name}.a"
				INTERFACE_LINK_LIBRARIES "m")
		else()
			continue()
		endif()

		set_target_properties(FFTW3::${_fftw3_name} PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES "${_fftw3_includedir}")
		if(_fftw3_variant)
			set_property(TARGET FFTW3::${_fftw3_name} APPEND PROPERTY
				INTERFACE_LINK_LIBRARIES FFTW3::fftw3${_fftw3_prec})
		endif()
	endforeach()
endforeach()

unset(_fftw3_name)
unset(_fftw3_variant)
unset(_fftw3_prec)
unset(_fftw3_includedir)
unset(_fftw3_libdir)
