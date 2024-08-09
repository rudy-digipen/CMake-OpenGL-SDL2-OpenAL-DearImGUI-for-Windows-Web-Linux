FetchContent_Declare(
    gsl
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    URL https://github.com/microsoft/GSL/archive/refs/tags/v4.0.0.tar.gz
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
)
FetchContent_MakeAvailable(gsl)

add_library(the_gsl INTERFACE)
target_include_directories(the_gsl SYSTEM INTERFACE ${gsl_SOURCE_DIR}/include)
