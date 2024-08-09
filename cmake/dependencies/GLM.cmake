FetchContent_Declare(
    glm
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    URL https://github.com/g-truc/glm/releases/download/1.0.0/glm-1.0.0-light.7z
    SOURCE_DIR _deps/the_glm-src/glm
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
)
FetchContent_MakeAvailable(glm)

add_library(the_glm INTERFACE)
target_include_directories(the_glm SYSTEM INTERFACE ${glm_SOURCE_DIR}/..)
