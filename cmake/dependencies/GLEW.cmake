add_library(the_glew INTERFACE)

if(NOT WIN32 AND NOT EMSCRIPTEN)
    set(GLEW_STATIC_LIBS TRUE)
    find_package(GLEW REQUIRED)
    target_link_libraries(the_glew INTERFACE ${GLEW_STATIC_LIBRARIES} $<$<PLATFORM_ID:Linux>:GL>)
    target_include_directories(the_glew SYSTEM INTERFACE ${GLEW_INCLUDE_DIRS})
elseif(WIN32)
    FetchContent_Declare(
        glew
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        URL "https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0-win32.zip"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
    )
    FetchContent_MakeAvailable(glew)

    target_link_directories(the_glew INTERFACE ${glew_SOURCE_DIR}/lib/Release/x64)
    target_link_libraries(the_glew INTERFACE glew32s)
    target_include_directories(the_glew SYSTEM INTERFACE ${glew_SOURCE_DIR}/include)
    target_compile_definitions(the_glew INTERFACE GLEW_STATIC)
endif()
