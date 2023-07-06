set(libstt_x8664_url "https://github.com/coqui-ai/STT/releases/download/v1.1.0/native_client.tflite.Linux.tar.xz")
set(libstt_arm64_url "https://github.com/coqui-ai/STT/releases/download/v1.1.0/native_client.tflite.linux.aarch64.tar.xz")
set(libstt_arm32_url "https://github.com/coqui-ai/STT/releases/download/v1.1.0/native_client.tflite.linux.armv7.tar.xz")

if(arch_x8664)
    set(libstt_url ${libstt_x8664_url})
elseif(arch_arm32)
    set(libstt_url ${libstt_arm32_url})
elseif(arch_arm64)
    set(libstt_url ${libstt_arm64_url})
endif()

set(libstt_archive "${PROJECT_BINARY_DIR}/libstt.tar.xz")

file(DOWNLOAD ${libstt_url} ${libstt_archive} ${external_lib_dir} STATUS libstt_status)
file(ARCHIVE_EXTRACT INPUT ${libstt_archive} DESTINATION ${external_lib_dir}
    PATTERNS *.so VERBOSE)

add_library(stt SHARED IMPORTED)
set_property(TARGET stt PROPERTY IMPORTED_LOCATION ${external_lib_dir}/libstt.so)
list(APPEND deps stt)

add_library(kenlm SHARED IMPORTED)
set_property(TARGET kenlm PROPERTY IMPORTED_LOCATION ${external_lib_dir}/libkenlm.so)
list(APPEND deps kenlm)

add_library(tensorflowlite SHARED IMPORTED)
set_property(TARGET tensorflowlite PROPERTY IMPORTED_LOCATION ${external_lib_dir}/libtensorflowlite.so)
list(APPEND deps tensorflowlite)

add_library(tflitedelegates SHARED IMPORTED)
set_property(TARGET tflitedelegates PROPERTY IMPORTED_LOCATION ${external_lib_dir}/libtflitedelegates.so)
list(APPEND deps tflitedelegates)
