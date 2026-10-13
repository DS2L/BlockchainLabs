// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title Exercise 5 - Bank that refuses deposits from strangers
/// @notice YOUR CODE GOES HERE.
///         Required for graduate students, bonus for undergraduates.
///
/// Start from your Exercise 4 solution and add one rule: only Alice and Bob
/// may put Ether into this bank. A third account (call them Charlie) must be
/// turned away.
///
/// Charlie has TWO ways to push Ether at a contract, and you must block both:
///
///   (a) Calling `deposit()` explicitly.
///       Guard the function itself.
///
///   (b) A plain Ether transfer with empty calldata -- no function named at all.
///       This does NOT reach `deposit()`. It reaches `receive()`, a special
///       function that did not exist in Solidity 0.4.x (where a nameless
///       `function() payable` fallback handled both cases). If no `receive()`
///       or payable `fallback()` exists, a plain transfer reverts for everyone,
///       including Alice -- so deleting it is not a valid answer.
///
/// Required behaviour:
///   1. Everything Exercise 4 required still holds.
///   2. `deposit()` from anyone other than Alice or Bob reverts.
///   3. A plain Ether transfer from anyone other than Alice or Bob reverts.
///   4. A plain Ether transfer FROM Alice or Bob succeeds and credits the
///      sender, exactly as if they had called `deposit()`.
///   5. After a rejected transfer the contract's Ether balance is unchanged.
///
/// Think about why rule 5 follows automatically from how you implement rules
/// 2 and 3, and be ready to say so in your write-up.
///
/// The test suite in test/Ex5GuardedBank.t.sol is the full specification:
///   forge test --match-contract Ex5GuardedBankTest -vv
contract Ex5GuardedBank {
    address public alice;
    address public bob;

    // TODO: carry over the balance bookkeeping from Exercise 4.

    constructor(address _alice, address _bob) {
        alice = _alice;
        bob = _bob;
    }

    /// @notice Deposit Ether, credited to the caller. Alice and Bob only.
    function deposit() external payable {
        // TODO: implement.
        revert("Ex5: deposit() not implemented");
    }

    /// @notice Withdraw `amount` wei from the caller's own balance.
    function withdraw(uint256 amount) external {
        // TODO: implement.
        revert("Ex5: withdraw() not implemented");
    }

    /// @notice Ledger balance of `account`, in wei.
    function balanceOf(address account) external view returns (uint256) {
        // TODO: implement.
        revert("Ex5: balanceOf() not implemented");
    }

    /// @notice Handles plain Ether transfers that carry no calldata.
    receive() external payable {
        // TODO: implement. Accept from Alice and Bob, reject everyone else.
        revert("Ex5: receive() not implemented");
    }
}
