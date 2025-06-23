FetchContent_Declare(
    glm
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    URL https://github.com/g-truc/glm/releases/download/1.0.1/glm-1.0.1-light.7z
    URL_HASH MD5=6db43fc749c8acdc8ccb9815b1a57f62
    SOURCE_DIR _deps/the_glm-src/glm
)
FetchContent_MakeAvailable(glm)

add_library(the_glm INTERFACE)
target_include_directories(the_glm SYSTEM INTERFACE ${glm_SOURCE_DIR}/..)
