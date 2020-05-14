set(_link_libraries SetReplace ${GTEST_LIBRARIES})

add_executable(test_Set test_Set.cpp)
target_link_libraries(test_Set ${_link_libraries})

gtest_discover_tests(test_Set)
