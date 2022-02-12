.PHONY: all build cmake clean format

PROJECT_NAME := project

CM4_DIR := CM4
CM7_DIR := CM7

BUILD_DIR := build
BUILD_TYPE ?= Debug

CM4_BUILD_DIR := ${CM4_DIR}/${BUILD_DIR}
CM7_BUILD_DIR := ${CM7_DIR}/${BUILD_DIR}


all: build

cmake_cm4:
	cmake \
		-B${CM4_BUILD_DIR} \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi.cmake \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DPROJECT_NAME=${PROJECT_NAME} \
		${CM4_DIR}

cmake_cm7:
	cmake \
		-B${CM7_BUILD_DIR} \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_TOOLCHAIN_FILE=../cmake/gcc-arm-none-eabi.cmake \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DPROJECT_NAME=${PROJECT_NAME} \
		${CM7_DIR}

cm4: cmake_cm4
	$(MAKE) -C ${CM4_BUILD_DIR} --no-print-directory

cm7: cmake_cm7
	$(MAKE) -C ${CM7_BUILD_DIR} --no-print-directory

build: cm4 cm7

flash: build
	# Flashing CM4 fails
	#st-flash write ${CM4_BUILD_DIR}/${PROJECT_NAME}-cm4.bin 0x08100000
	st-flash --reset write ${CM7_BUILD_DIR}/${PROJECT_NAME}-cm7.bin 0x08000000

SRCS := $(shell find . -name '*.[ch]' -or -name '*.[ch]pp')
format: $(addsuffix .format,${SRCS})

%.format: %
	-clang-format -i $<

clean:
	rm -rf $(CM4_BUILD_DIR) ${CM7_BUILD_DIR}
