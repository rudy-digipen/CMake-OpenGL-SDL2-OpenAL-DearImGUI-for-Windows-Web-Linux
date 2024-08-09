find_package(OpenGL REQUIRED)

add_library(the_opengl INTERFACE)
target_link_libraries(the_opengl INTERFACE ${OPENGL_LIBRARIES})

if(EMSCRIPTEN)

    target_link_options(the_opengl INTERFACE -sMIN_WEBGL_VERSION=2 -sMAX_WEBGL_VERSION=2)
    target_compile_definitions(the_opengl INTERFACE IS_WEBGL)

endif()

