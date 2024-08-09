add_library(the_openal INTERFACE)

if(WIN32)
    FetchContent_Declare(
        openalsoft
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        URL "https://github.com/kcat/openal-soft/releases/download/1.23.1/openal-soft-1.23.1-bin.zip"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
    )
    FetchContent_MakeAvailable(openalsoft)

    target_include_directories(the_openal SYSTEM INTERFACE ${openalsoft_SOURCE_DIR}/include/AL)
    target_link_directories(the_openal INTERFACE ${openalsoft_SOURCE_DIR}/libs/Win64)
    target_link_libraries(the_openal INTERFACE OpenAL32)

    set(TEMP_EXE_FOLDER $<IF:$<BOOL:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}>,${CMAKE_RUNTIME_OUTPUT_DIRECTORY},${CMAKE_BINARY_DIR}>)

    add_custom_target(copy_openal_dll
        COMMAND ${CMAKE_COMMAND} -E copy
                ${openalsoft_SOURCE_DIR}/bin/Win64/soft_oal.dll
                ${TEMP_EXE_FOLDER}/soft_oal.dll
        COMMAND ${CMAKE_COMMAND} -E copy
                ${openalsoft_SOURCE_DIR}/router/Win64/OpenAL32.dll
                ${TEMP_EXE_FOLDER}/OpenAL32.dll
        DEPENDS ${openalsoft_SOURCE_DIR}/bin/Win64/soft_oal.dll ${openalsoft_SOURCE_DIR}/router/Win64/OpenAL32.dll
        COMMENT "Copying OpenAL Soft DLL files to executable directory"
    )
    add_dependencies(the_openal copy_openal_dll)

else()
    find_package(OpenAL REQUIRED)
    target_link_libraries(the_openal INTERFACE ${OPENAL_LIBRARY})
    target_include_directories(the_openal SYSTEM INTERFACE ${OPENAL_INCLUDE_DIR})

    if(EMSCRIPTEN)
        target_include_directories(the_openal SYSTEM INTERFACE ${OPENAL_INCLUDE_DIR}/AL)
        target_link_options(the_openal INTERFACE -lopenal)
    endif()

endif()
