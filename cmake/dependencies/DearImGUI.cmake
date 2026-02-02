# Depends on SDL2 and OpenGL

CachedFetchContent_Declare(
    dearimgui
    URL https://github.com/ocornut/imgui/archive/refs/tags/v1.92.3-docking.tar.gz
    URL_HASH MD5=3f7c5bb4e34e4fa9143baac62efbc883
)
FetchContent_MakeAvailable(dearimgui)

add_library(the_imgui STATIC
    ${dearimgui_SOURCE_DIR}/imgui.cpp ${dearimgui_SOURCE_DIR}/imgui.h
    ${dearimgui_SOURCE_DIR}/imconfig.h ${dearimgui_SOURCE_DIR}/imgui_internal.h
    ${dearimgui_SOURCE_DIR}/imgui_draw.cpp
    ${dearimgui_SOURCE_DIR}/imgui_tables.cpp
    ${dearimgui_SOURCE_DIR}/imgui_widgets.cpp
    ${dearimgui_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp ${dearimgui_SOURCE_DIR}/backends/imgui_impl_opengl3.h
    ${dearimgui_SOURCE_DIR}/backends/imgui_impl_sdl2.cpp
    ${dearimgui_SOURCE_DIR}/backends/imgui_impl_sdl2.h
)

target_include_directories(the_imgui SYSTEM PUBLIC ${dearimgui_SOURCE_DIR} ${dearimgui_SOURCE_DIR}/backends)
target_link_libraries(the_imgui PRIVATE the_sdl2)
