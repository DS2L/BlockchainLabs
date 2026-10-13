// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ex1Hello} from "../src/Ex1Hello.sol";

/// Exercise 1 (15 pts) - these should pass the moment your toolchain works.
/// You write no code for this exercise. If these are green, you are set up.
contract Ex1HelloTest is Test {
    Ex1Hello internal hello;

    function setUp() public {
        hello = new Ex1Hello();
    }

    function test_GreetingStartsEmpty() public view {
        assertEq(hello.greet(), "", "a fresh contract should hold the empty string");
    }

    function test_GreeterStoresValue() public {
        hello.greeter("Hello, CS 810!");
        assertEq(hello.greet(), "Hello, CS 810!", "greet() should return what greeter() stored");
    }

    function test_GreeterOverwritesValue() public {
        hello.greeter("first");
        hello.greeter("second");
        assertEq(hello.greet(), "second", "a second greeter() call should overwrite the first");
    }

    /// Storage persists across transactions, which a single assertion can hide.
    /// vm.prank sends the next call from a different account to make the point:
    /// state belongs to the contract, not to the caller.
    function test_GreetingPersistsAcrossCallers() public {
        address student = makeAddr("student");
        vm.prank(student);
        hello.greeter("written by the student account");

        address ta = makeAddr("ta");
        vm.prank(ta);
        assertEq(hello.greet(), "written by the student account", "state is shared, not per-caller");
    }

    function testFuzz_RoundTripsAnyString(string calldata s) public {
        hello.greeter(s);
        assertEq(hello.greet(), s);
    }
}
