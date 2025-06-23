FetchContent_Declare(
    gsl
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    URL https://github.com/microsoft/GSL/archive/refs/tags/v4.1.0.tar.gz
    URL_HASH MD5=7e6883a254e73a8b2368a0d26efe68a7
)
FetchContent_MakeAvailable(gsl)

add_library(the_gsl INTERFACE)
target_include_directories(the_gsl SYSTEM INTERFACE ${gsl_SOURCE_DIR}/include)
