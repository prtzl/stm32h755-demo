cmake_minimum_required(VERSION 3.12)
include_guard(GLOBAL)

set(MCU_FAMILY STM32H7xx)

get_filename_component(PROJECT_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.." ABSOLUTE)

set(CUBEMX_DRIVERS_DIR ${PROJECT_BASE_DIR}/Drivers)
set(CUBEMX_COMMON_DIR ${PROJECT_BASE_DIR}/Common)

set(CUBEMX_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/Inc
    ${CUBEMX_DRIVERS_DIR}/${MCU_FAMILY}_HAL_Driver/Inc
    ${CUBEMX_DRIVERS_DIR}/${MCU_FAMILY}_HAL_Driver/Inc/Legacy
    ${CUBEMX_DRIVERS_DIR}/CMSIS/Device/ST/${MCU_FAMILY}/Include
    ${CUBEMX_DRIVERS_DIR}/CMSIS/Include)

file(GLOB_RECURSE CUBEMX_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/*.c
    ${CUBEMX_DRIVERS_DIR}/*.c
    ${CUBEMX_COMMON_DIR}/*.c)

set(DEFAULT_COMPILE_DEFINITIONS
    USE_HAL_DRIVER
    $<$<CONFIG:Debug>:DEBUG>)

enable_language(C CXX ASM)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

set(DEFAULT_COMPILER_OPTIONS
    -Wall
    -Wextra
    -Wpedantic
    -Wno-unused-parameter
    $<$<COMPILE_LANGUAGE:CXX>:
        -Wno-volatile
        -Wold-style-cast
        -Wuseless-cast
        -Wsuggest-override>
    $<$<CONFIG:Debug>:-Os -g3 -ggdb>
    $<$<CONFIG:Release>:-Og -g0>)

set(DEFAULT_LINKER_OPTIONS
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map
    --specs=nosys.specs
    -Wl,--start-group
    -lc
    -lm
    -lstdc++
    -Wl,--end-group
    -Wl,--print-memory-usage)

# include(gcc-arm-embedded.cmake)
