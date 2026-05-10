/**
 * @file gtest_smoke_test.cpp
 * @author Mike Matthews (michael.g.matthews3@gmail.com)
 * @brief
 *
 * @copyright Copyright (c) 2026 Mike Matthews
 */

#include <gtest/gtest.h>

TEST(GoogleTestSmokeTest, GTest) {
  EXPECT_STRNE("hello", "world");
  EXPECT_EQ((7 * 6), 42);
}
