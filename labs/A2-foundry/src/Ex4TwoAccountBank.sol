// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title Exercise 4 - Two-account Ether bank
/// @notice YOUR CODE GOES HERE.
///
/// Extend this skeleton into a bank that keeps SEPARATE balances for two
/// customers, Alice and Bob, and that lets each of them withdraw only their
/// own money.
///
/// Required behaviour:
///   1. `deposit()` credits `msg.value` to the caller's balance. Anyone may
///      deposit in this exercise (Exercise 5 changes that).
///   2. `withdraw(amount)` succeeds only if the caller's own balance is at
///      least `amount`. On success it debits the caller and sends them the
///      Ether.
///   3. A failed withdrawal must leave every balance exactly as it was. Reverting
///      gives you this for free -- that is the point.
///   4. `balanceOf(account)` reports the ledger balance for `account`.
///   5. Alice withdrawing must never touch Bob's balance, and vice versa.
///
/// The constructor records who Alice and Bob are. You may add state variables,
/// errors, events, and helper functions, but do not change the signatures of
/// `deposit`, `withdraw`, or `balanceOf` -- the tests call them by name.
///
/// The test suite in test/Ex4TwoAccountBank.t.sol is the full specification:
///   forge test --match-contract Ex4TwoAccountBankTest -vv
contract Ex4TwoAccountBank {
    address public alice;
    address public bob;

    // TODO: you will need somewhere to record each customer's balance.

    constructor(address _alice, address _bob) {
        alice = _alice;
        bob = _bob;
    }

    /// @notice Deposit Ether, credited to the caller.
    function deposit() external payable {
        // TODO: implement.
        revert("Ex4: deposit() not implemented");
    }

    /// @notice Withdraw `amount` wei from the caller's own balance.
    function withdraw(uint256 amount) external {
        // TODO: implement.
        revert("Ex4: withdraw() not implemented");
    }

    /// @notice Ledger balance of `account`, in wei.
    function balanceOf(address account) external view returns (uint256) {
        // TODO: implement.
        revert("Ex4: balanceOf() not implemented");
    }
}
