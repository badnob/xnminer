cmake_minimum_required(VERSION 3.18)
project(xen_cuda_engine LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(XEN_SRC "${CMAKE_CURRENT_SOURCE_DIR}/../XenblocksMiner-main/src")

# RTX 5090 = sm_120; include 90 for compatibility testing
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 90 120)
endif()

add_library(xen_cuda SHARED
    xen_cuda_api.cpp
    ${XEN_SRC}/argon2params.cpp
    ${XEN_SRC}/blake2b.cpp
    ${XEN_SRC}/CudaBackend.cpp
    ${XEN_SRC}/CudaDevice.cpp
    ${XEN_SRC}/kernelrunner.cu
    ${XEN_SRC}/hashapi/CudaHashBackend.cpp
    ${XEN_SRC}/hashapi/HashApiEncoding.cpp
    ${XEN_SRC}/hashapi/HashApiMatching.cpp
    ${XEN_SRC}/hashapi/HashApiTuning.cpp
    ${XEN_SRC}/hashapi/HashApiValidation.cpp
)

target_include_directories(xen_cuda PRIVATE
    ${XEN_SRC}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(xen_cuda PRIVATE XEN_CUDA_EXPORTS)

find_package(CUDAToolkit REQUIRED)
target_link_libraries(xen_cuda PRIVATE CUDA::cudart)

if(WIN32)
    target_compile_definitions(xen_cuda PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

target_compile_options(xen_cuda PRIVATE
    $<$<COMPILE_LANGUAGE:CUDA>:-Wno-deprecated-gpu-targets>
)

set_target_properties(xen_cuda PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)