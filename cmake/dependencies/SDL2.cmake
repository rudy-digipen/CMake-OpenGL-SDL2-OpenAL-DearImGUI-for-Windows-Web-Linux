add_library(the_sdl2 INTERFACE)

if(WIN32)
    FetchContent_Declare(
        sdl2
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        URL "https://github.com/libsdl-org/SDL/releases/download/release-2.30.5/SDL2-devel-2.30.5-VC.zip"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
    )
    FetchContent_MakeAvailable(sdl2)

    target_include_directories(the_sdl2 SYSTEM INTERFACE ${sdl2_SOURCE_DIR}/include)

    target_link_directories(the_sdl2 INTERFACE ${sdl2_SOURCE_DIR}/lib/x64)
    target_link_libraries(the_sdl2 INTERFACE SDL2)
    target_compile_definitions(the_sdl2 INTERFACE SDL_MAIN_HANDLED)

    set(TEMP_EXE_FOLDER $<IF:$<BOOL:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}>,${CMAKE_RUNTIME_OUTPUT_DIRECTORY},${CMAKE_BINARY_DIR}>)
    add_custom_target(copy_sdl2_dll
    COMMAND ${CMAKE_COMMAND} -E copy
            ${sdl2_SOURCE_DIR}/lib/x64/SDL2.dll
            ${TEMP_EXE_FOLDER}/SDL2.dll
            DEPENDS ${sdl2_SOURCE_DIR}/lib/x64/SDL2.dll
            COMMENT "Copying SDL2.dll to executable directory"
    )
    add_dependencies(the_sdl2 copy_sdl2_dll)
else()

    find_package(SDL2 REQUIRED)

    target_include_directories(the_sdl2 SYSTEM INTERFACE ${SDL2_INCLUDE_DIRS})
    target_link_libraries(the_sdl2 INTERFACE ${SDL2_LIBRARIES})

    if(EMSCRIPTEN)
        target_compile_options(the_sdl2 INTERFACE -sUSE_SDL=2)
    endif()

endif()
