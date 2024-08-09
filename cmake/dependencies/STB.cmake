FetchContent_Declare(
    stb_github
    GIT_REPOSITORY https://github.com/nothings/stb.git
    GIT_TAG master
    GIT_SHALLOW TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
)

FetchContent_MakeAvailable(stb_github)

if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/stb_implementation.cpp)
    set(STB_IMPLEMENTATION_CODE "// This file is auto-generated from cmake/depenendencies/STB.cmake
    #define STB_IMAGE_IMPLEMENTATION
    #include \"stb_image.h\"
    #include \"stb_vorbis.c\"
    ")

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/stb_implementation.cpp ${STB_IMPLEMENTATION_CODE})
    set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/stb_implementation.cpp PROPERTIES GENERATED TRUE)
endif()

add_library(the_stb STATIC ${CMAKE_CURRENT_BINARY_DIR}/stb_implementation.cpp)
target_include_directories(the_stb SYSTEM PUBLIC ${stb_github_SOURCE_DIR})

