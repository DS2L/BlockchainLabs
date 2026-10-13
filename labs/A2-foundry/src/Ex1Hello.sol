// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title Exercise 1 - Hello World
/// @notice GIVEN TO YOU, COMPLETE. Do not modify this file.
///
/// This is the Solidity 0.8 port of the `hello` contract from the original lab.
/// Your only job in Exercise 1 is to build it, test it, and deploy it to a local
/// chain so you can confirm your toolchain works. See README.md, Exercise 1.
///
/// Migration note (0.4.25 -> 0.8.30):
///   - `function greeter(string _greeting) public` became
///     `function greeter(string calldata _greeting) external`.
///     In 0.4.x the data location of a reference-type parameter was implicit;
///     since 0.5.0 you must write `calldata` or `memory` explicitly.
///   - Returning a string now requires `returns (string memory)`.
contract Ex1Hello {
    string private greeting;

    /// @notice Store a greeting.
    function greeter(string calldata _greeting) external {
        greeting = _greeting;
    }

    /// @notice Read back the stored greeting.
    function greet() external view returns (string memory) {
        return greeting;
    }
}
