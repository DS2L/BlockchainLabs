// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ex2Max} from "../src/Ex2Max.sol";

/// Exercise 2 (25 pts) - the three cases the original lab asked you to
/// screenshot (x < y, x == y, x > y), plus the cases screenshots let you skip.
contract Ex2MaxTest is Test {
    Ex2Max internal m;

    function setUp() public {
        m = new Ex2Max();
    }

    // --- The three required cases -------------------------------------------

    function test_XLessThanY() public view {
        assertEq(m.max(3, 7), 7);
    }

    function test_XEqualsY() public view {
        assertEq(m.max(5, 5), 5);
    }

    function test_XGreaterThanY() public view {
        assertEq(m.max(9, 2), 9);
    }

    // --- Cases a screenshot of three happy paths would never catch -----------

    function test_BothNegative() public view {
        assertEq(m.max(-8, -3), -3, "-3 is larger than -8");
    }

    function test_MixedSigns() public view {
        assertEq(m.max(-1, 1), 1);
        assertEq(m.max(1, -1), 1);
    }

    function test_ZeroAndNegative() public view {
        assertEq(m.max(0, -4), 0);
        assertEq(m.max(-4, 0), 0);
    }

    /// A solution written with uint256 in mind, or one that compares
    /// `x - y > 0`, dies here. Subtraction overflows at the extremes.
    function test_Extremes() public view {
        assertEq(m.max(type(int256).max, type(int256).min), type(int256).max);
        assertEq(m.max(type(int256).min, type(int256).max), type(int256).max);
        assertEq(m.max(type(int256).min, type(int256).min), type(int256).min);
    }

    // --- Properties, checked over 256 random input pairs ---------------------

    function testFuzz_ResultIsOneOfTheInputs(int256 x, int256 y) public view {
        int256 r = m.max(x, y);
        assertTrue(r == x || r == y, "the result must be one of the two inputs");
    }

    function testFuzz_ResultIsAtLeastBothInputs(int256 x, int256 y) public view {
        int256 r = m.max(x, y);
        assertGe(r, x);
        assertGe(r, y);
    }

    function testFuzz_IsSymmetric(int256 x, int256 y) public view {
        assertEq(m.max(x, y), m.max(y, x), "argument order must not matter");
    }
}
