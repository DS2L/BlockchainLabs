// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title Exercise 3 - Single-account Ether bank
/// @notice GIVEN TO YOU, COMPLETE. Do not modify this file.
///
/// This is the Solidity 0.8 port of the `bank` contract from the original lab.
/// It models a bank that tracks a balance for exactly one customer, Alice.
///
/// Read it carefully before running the tests. This contract behaves correctly
/// for `deposit` and `withdraw`, but `relay` does something that should bother
/// you. Exercise 3 asks you to find and explain it -- the tests in
/// test/Ex3Bank.t.sol will show you the discrepancy, but the explanation is yours.
///
/// Migration notes (0.4.13 -> 0.8.30):
///   - `address` is no longer implicitly payable. Sending Ether requires an
///     `address payable`, hence `payable(msg.sender)` and the `address payable`
///     parameter on `relay`.
///   - `.transfer()` forwards only 2300 gas, which breaks against recipient
///     contracts whose fallback costs more. Modern practice is
///     `.call{value: x}("")` with an explicit success check, used below.
///   - Arithmetic is checked by default since 0.8.0, so `+=` and `-=` revert on
///     overflow/underflow instead of silently wrapping. The original 0.4.13
///     code needed SafeMath for this; you no longer do.
contract Ex3Bank {
    /// @notice The bank's internal ledger entry for Alice, in wei.
    uint256 public etherBalanceAlice;

    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event Relayed(address indexed to, uint256 amount);

    /// @notice Deposit Ether and credit it to the ledger.
    function deposit() external payable {
        etherBalanceAlice += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw `amount` wei, debiting the ledger.
    function withdraw(uint256 amount) external {
        require(amount <= etherBalanceAlice, "Bank: insufficient balance");
        etherBalanceAlice -= amount;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "Bank: transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Forward the Ether attached to this call straight on to `bob`.
    function relay(address payable bob) external payable {
        (bool ok,) = bob.call{value: msg.value}("");
        require(ok, "Bank: relay failed");
        emit Relayed(bob, msg.value);
    }

    /// @notice The contract account's real Ether balance.
    function getBalanceCA() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice The calling externally-owned account's real Ether balance.
    function getBalanceEOA() external view returns (uint256) {
        return msg.sender.balance;
    }
}
