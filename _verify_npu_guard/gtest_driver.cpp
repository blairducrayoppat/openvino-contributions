// Minimal gtest entry point (equivalent to gtest_main) so the committed TEST() bodies
// in unbounded_dynamic_shape.cpp run unchanged as a real gtest binary.
#include <gtest/gtest.h>

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
