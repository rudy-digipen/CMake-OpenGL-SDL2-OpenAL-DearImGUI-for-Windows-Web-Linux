cmake_minimum_required(VERSION 3.21)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)

project(programming_fun_too)

include(cmake/StandardProjectSettings.cmake)

include(cmake/CompilerWarnings.cmake)
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)
set_project_warnings(project_options)

include(cmake/Dependencies.cmake)

add_subdirectory(source)
