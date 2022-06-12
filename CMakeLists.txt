# STM32 Minimal CMake project for C/C++ projects
cmake_minimum_required(VERSION 3.12)
###############################################################################
# Set project name and source code folder location

project(${PROJECT_NAME})
set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Project)
set(CM4-dir ${CMAKE_CURRENT_SOURCE_DIR}/CM4)
set(CM7-dir ${CMAKE_CURRENT_SOURCE_DIR}/CM7)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE Debug)
endif()
message("Build type: ${CMAKE_BUILD_TYPE}")
option(DUMP_ASM "Create full assembly of final executable" OFF)

# Set microcontroller information
set(MCU_FAMILY STM32H7xx)

set(CM4_MCU_MODEL STM32H755xx CORE_CM4)
set(CM4_CPU_PARAMETERS
    -mcpu=cortex-m4
    -mthumb
    -mfpu=fpv4-sp-d16
    -mfloat-abi=hard)

set(CM7_MCU_MODEL STM32H755xx CORE_CM7)
set(CM7_CPU_PARAMETERS
    -mcpu=cortex-m7
    -mthumb
    -mfpu=fpv5-d16
    -mfloat-abi=hard)

set(CM4_STARTUP_SCRIPT  ${CM4-dir}/Core/Startup/startup_stm32h755zitx.s)
set(CM4_LINKER_SCRIPT   ${CM4-dir}/STM32H755ZITX_FLASH.ld)
set(CM7_STARTUP_SCRIPT  ${CM7-dir}/Core/Startup/startup_stm32h755zitx.s)
set(CM7_LINKER_SCRIPT   ${CM7-dir}/STM32H755ZITX_FLASH.ld)

###############################################################################

set(CM4-executable ${CMAKE_PROJECT_NAME}-cm4)
set(CM7-executable ${CMAKE_PROJECT_NAME}-cm7)

enable_language(C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

###############################################################################

set(STM32CUBEMX_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/${MCU_FAMILY}_HAL_Driver/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/${MCU_FAMILY}_HAL_Driver/Inc/Legacy
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Device/ST/${MCU_FAMILY}/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Include)

set(PROJECT_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE STM32CUBEMX_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/Common/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/*.c)

################################

file(GLOB_RECURSE CM4_SOURCES CONFIGURE_DEPENDS
    ${CM4-dir}/Core/*.c)

file(GLOB_RECURSE CM7_SOURCES CONFIGURE_DEPENDS
    ${CM7-dir}/Core/*.c)

add_executable(${CM4-executable}
    ${STM32CUBEMX_SOURCES} 
    ${CM4_SOURCES}
    ${CM4_STARTUP_SCRIPT})

add_executable(${CM7-executable}
    ${STM32CUBEMX_SOURCES} 
    ${CM7_SOURCES}
    ${CM7_STARTUP_SCRIPT})

target_compile_definitions(${CM4-executable} PRIVATE
    $<$<CONFIG:Debug>:DEBUG>
    ${CM4_MCU_MODEL}
    USE_HAL_DRIVER)

target_compile_definitions(${CM7-executable} PRIVATE
    $<$<CONFIG:Debug>:DEBUG>
    ${CM7_MCU_MODEL}
    USE_HAL_DRIVER)

target_include_directories(${CM4-executable} SYSTEM PRIVATE
    ${STM32CUBEMX_INCLUDE_DIRECTORIES})

target_include_directories(${CM4-executable} PRIVATE
    ${CM4-dir}/Core/Inc)

target_include_directories(${CM7-executable} SYSTEM PRIVATE
    ${STM32CUBEMX_INCLUDE_DIRECTORIES})

target_include_directories(${CM7-executable} PRIVATE
    ${CM7-dir}/Core/Inc)

###############################################################################

set(SHARED_COMPILE_OPTIONS
    -Wall
    -Wextra
    -Wpedantic
    -Wshadow
    -Wdouble-promotion
    -Wformat=2 -Wformat-truncation
    -Wundef
    -fno-common
    -Wno-unused-parameter
    $<$<COMPILE_LANGUAGE:CXX>:
        -Wconversion
        -Wno-volatile
        -Wold-style-cast
        -Wuseless-cast
        -Wsuggest-override>
    $<$<CONFIG:Debug>:-Os -g3 -ggdb>
    $<$<CONFIG:Release>:-Og -g0>)

set(SHARED_LINK_OPTIONS
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map
    -Wl,--start-group
    -lc
    -lm
    -lstdc++
    -Wl,--end-group
    -Wl,--print-memory-usage)

target_compile_options(${CM4-executable} PRIVATE
    ${CM4_CPU_PARAMETERS}
    ${SHARED_COMPILE_OPTIONS})

target_link_options(${CM4-executable} PRIVATE
    -T${CM4_LINKER_SCRIPT}
    ${CM4_CPU_PARAMETERS}
    ${SHARED_LINK_OPTIONS})

target_compile_options(${CM7-executable} PRIVATE
    ${CM7_CPU_PARAMETERS}
    ${SHARED_COMPILE_OPTIONS})

target_link_options(${CM7-executable} PRIVATE
    -T${CM7_LINKER_SCRIPT}
    ${CM7_CPU_PARAMETERS}
    ${SHARED_LINK_OPTIONS})

###############################################################################

function(make_output EXECUTABLE)
    add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
        COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>
        COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.hex
        COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.bin)

    If (${DUMP_ASM})
        add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
            COMMAND ${CMAKE_OBJDUMP} -D -C $<TARGET_FILE:${EXECUTABLE}> > ${EXECUTABLE}.s)
    endif()
endfunction()

make_output(${CM4-executable})
make_output(${CM7-executable})

