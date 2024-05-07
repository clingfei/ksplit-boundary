cmake_minimum_required(VERSION 3.13.4)

project("parse")

if (DEFINED LLVM_DIR)
    set(ENV{LLVM_DIR} "${LLVM_DIR}")
endif()
if (DEFINED ENV{LLVM_DIR})

    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS ON)

    set(COMMON_FLAGS "-fPIC")

    set(CMAKE_BUILD_TYPE "Debug")

    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMMON_FLAGS} -O0 -fno-rtti")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMMON_FLAGS} -O0")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMMON_FLAGS} -O3 -fno-rtti")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMMON_FLAGS} -O3")
    endif()

    set(LLVM_LINK_COMPONENTS BitWriter Core IRReader Linker Support)

    find_package(LLVM REQUIRED CONFIG)

    add_definitions(${LLVM_DEFINITIONS})

    link_directories(${LLVM_LIBRARY_DIRS})
    include_directories(${LLVM_INCLUDE_DIRS})
    message(${CMAKE_CXX_STANDARD})
    message(${LLVM_DEFINITIONS})
    message(${LLVM_LIBRARY_DIRS})
    message(${LLVM_INCLUDE_DIRS})
    add_subdirectory(typm)
    add_executable(parse parse.cpp)
    target_link_libraries(parse LLVMSupport LLVMAnalysis LLVMCore LLVMIRReader kanalyzer)

else()
    message(FATAL_ERROR "\
        WARNING: The LLVM_DIR var was not set!\n\
        Please set this to environment variable to point to the LLVM build directory\
        (e.g. on linux: export LLVM_DIR=/path/to/llvm/build/dir)")
endif()