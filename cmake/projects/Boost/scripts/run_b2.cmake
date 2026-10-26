# Runs b2 and downgrades its "error:" output lines when b2 itself succeeded.
# Visual Studio's custom build step fails on any output line that looks like "error: ...",
# even if the tool exits with 0. Boost 1.90+ prints such a line for the header-only
# Boost.Histogram install under MSVC.
#
# Usage: cmake -P run_b2.cmake -- <b2> <b2 args...>

set(command "")
set(after_separator FALSE)
math(EXPR last_index "${CMAKE_ARGC} - 1")
foreach(index RANGE 0 ${last_index})
  if(after_separator)
    list(APPEND command "${CMAKE_ARGV${index}}")
  elseif("${CMAKE_ARGV${index}}" STREQUAL "--")
    set(after_separator TRUE)
  endif()
endforeach()

if("${command}" STREQUAL "")
  message(FATAL_ERROR "No command given, usage: cmake -P run_b2.cmake -- <b2> <args>")
endif()

execute_process(
    COMMAND ${command}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error_output
)

if(NOT result EQUAL 0)
  message("${output}")
  message("${error_output}")
  message(FATAL_ERROR "Command failed with ${result}: ${command}")
endif()

string(REGEX REPLACE "(^|\n)([ \t]*)error:" "\\1\\2note:" output "${output}")
string(REGEX REPLACE "(^|\n)([ \t]*)error:" "\\1\\2note:" error_output "${error_output}")
message("${output}")
message("${error_output}")
