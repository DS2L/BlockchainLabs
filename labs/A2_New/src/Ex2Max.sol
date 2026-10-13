// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title Exercise 2 - Bigger of two numbers
/// @notice YOUR CODE GOES HERE.
///
/// Implement `max` so that it returns the larger of `x` and `y`.
/// When `x == y`, return that shared value.
///
/// Note the type: these are SIGNED integers (`int256`), so your solution must
/// handle negative inputs. `int256` is not the same as `uint256`.
///
/// The test suite in test/Ex2Max.t.sol is the full specification. Run it with:
///   forge test --match-contract Ex2MaxTest -vv
contract Ex2Max {
    function max(int256 x, int256 y) external pure returns (int256) {
        // TODO: replace this line with your implementation.
        revert("Ex2: max() not implemented");
    }
}
