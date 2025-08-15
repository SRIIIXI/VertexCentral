cmake_minimum_required(VERSION 3.10)

project(EdgeLiteManager LANGUAGES C)

set(EdgeLiteManager_VERSION_MAJOR 1)
set(EdgeLiteManager_VERSION_MINOR 0)

set(EDGELITEMANAGER_INCLUDE ./include)
set(EDGELITEMANAGER_SOURCES ./src)

include_directories(/include/ /usr/local/include /usr/include/ ./include)
link_directories(/usr/local/lib/ /usr/lib/ /lib/)

set(COMMON_SOURCES
   ${COMMON_SOURCES}
   ${EDGELITEMANAGER_SOURCES}/Model.c
   ${EDGELITEMANAGER_SOURCES}/Server.c
)

set(HEADERS
   ${HEADERS}
   ${EDGELITEMANAGER_INCLUDE}/Model.h
)

add_executable(EdgeLiteManager ${COMMON_SOURCES} ${POSIX_SOURCES} ${HEADERS})
target_link_libraries(EdgeLiteManager pthread pq)
