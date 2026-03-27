cmake_minimum_required(VERSION 3.18.1)

project("privavoz")

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required libraries
find_library(log-lib log)
find_library(android-lib android)

# Add whisper.cpp subdirectory
add_subdirectory(whisper.cpp ${CMAKE_BINARY_DIR}/whisper.cpp/build)

# Build libwhisper
add_library(whisper SHARED
    whisper_bridge.cpp
)

target_link_libraries(whisper
    whisper.cpp
    ${log-lib}
)

# Add llama.cpp subdirectory
add_subdirectory(llama.cpp ${CMAKE_BINARY_DIR}/llama.cpp/build)

# Build libllama  
add_library(llama SHARED
    llama_bridge.cpp
)

target_link_libraries(llama
    llama.cpp
    ${log-lib}
)