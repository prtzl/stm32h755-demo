cmake_minimum_required(VERSION 3.12)
# ##############################################################################
project(cm7)
include(../cmake/arm-build.cmake)

set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/PROJECT)

set(MCU_MODEL STM32H755xx CORE_CM7)
set(CPU_PARAMETERS
    -mcpu=cortex-m7
    -mthumb
    -mfpu=fpv5-d16
    -mfloat-abi=hard)

set(STARTUP_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/Core/Startup/startup_stm32h755zitx.s)
set(MCU_LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/STM32H755ZITX_FLASH.ld)

# ##############################################################################
# Headers
set(PROJECT_INCLUDE_DIRECTORIES)

# Sources
file(GLOB_RECURSE PROJECT_SOURCES)

# Executable files
add_executable(${CMAKE_PROJECT_NAME}
    ${CUBEMX_SOURCES} 
    ${PROJECT_SOURCES}
    ${STARTUP_SCRIPT})

# Embedded macros(defines)
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    ${MCU_MODEL}
    ${DEFAULT_COMPILE_DEFINITIONS})

# Add header directories (AFTER add_executable !!)
target_include_directories(${CMAKE_PROJECT_NAME} SYSTEM PRIVATE
    ${CUBEMX_INCLUDE_DIRECTORIES})

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${PROJECT_INCLUDE_DIRECTORIES})

# Compiler and linker options
target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE
    ${CPU_PARAMETERS}
    ${DEFAULT_COMPILER_OPTIONS})

target_link_options(${CMAKE_PROJECT_NAME} PRIVATE
    -T${MCU_LINKER_SCRIPT}
    ${CPU_PARAMETERS}
    ${DEFAULT_LINKER_OPTIONS})

# Can we move this into common?
add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${CMAKE_PROJECT_NAME}>
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${CMAKE_PROJECT_NAME}> ${CMAKE_PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${CMAKE_PROJECT_NAME}> ${CMAKE_PROJECT_NAME}.bin)
