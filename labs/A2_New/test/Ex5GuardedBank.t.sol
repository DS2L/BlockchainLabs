// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ex5GuardedBank} from "../src/Ex5GuardedBank.sol";

/// Exercise 5 (20 pts: bonus for undergrads, required for grads)
/// Bank that refuses Ether from anyone who is not a customer.
///
/// Charlie attacks on two fronts, and the tests check both:
///   (a) calling deposit() -> must revert
///   (b) a plain Ether transfer with empty calldata -> must revert in receive()
///
/// Note that the plain-transfer tests use a low-level `call`, which forwards
/// all remaining gas. That matters: `transfer()` and `send()` forward only
/// 2300 gas, which is not enough to write a storage slot, so a `receive()` that
/// does real bookkeeping cannot be reached by them at all. Keep that in mind
/// when you read about `transfer` in older tutorials.
contract Ex5GuardedBankTest is Test {
    Ex5GuardedBank internal bank;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal charlie = makeAddr("charlie");

    function setUp() public {
        bank = new Ex5GuardedBank(alice, bob);
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        vm.deal(charlie, 100 ether);
    }

    function _fundTheBank() internal {
        vm.prank(alice);
        bank.deposit{value: 5 ether}();

        vm.prank(bob);
        bank.deposit{value: 3 ether}();
    }

    // --- Everything Exercise 4 required still holds --------------------------

    function test_CustomersCanStillDeposit() public {
        _fundTheBank();
        assertEq(bank.balanceOf(alice), 5 ether);
        assertEq(bank.balanceOf(bob), 3 ether);
    }

    function test_CustomersCanStillWithdrawTheirOwn() public {
        _fundTheBank();

        vm.prank(alice);
        bank.withdraw(5 ether);

        assertEq(bank.balanceOf(alice), 0);
        assertEq(bank.balanceOf(bob), 3 ether);
        assertEq(alice.balance, 100 ether);
    }

    function test_CustomersStillCannotOverdraw() public {
        _fundTheBank();

        vm.prank(bob);
        vm.expectRevert();
        bank.withdraw(4 ether);
    }

    // --- Case (a): Charlie calls deposit() explicitly ------------------------

    function test_CharlieCannotCallDeposit() public {
        vm.prank(charlie);
        vm.expectRevert();
        bank.deposit{value: 1 ether}();
    }

    function test_RejectedDepositLeavesContractBalanceUnchanged() public {
        _fundTheBank();
        uint256 before = address(bank).balance;

        vm.prank(charlie);
        vm.expectRevert();
        bank.deposit{value: 1 ether}();

        assertEq(address(bank).balance, before, "the rejected Ether must not stay");
        assertEq(charlie.balance, 100 ether, "and Charlie must keep it");
        assertEq(bank.balanceOf(charlie), 0);
    }

    // --- Case (b): Charlie sends a plain transfer, naming no function --------

    function test_CharlieCannotSendPlainTransfer() public {
        vm.prank(charlie);
        (bool ok,) = address(bank).call{value: 1 ether}("");

        assertFalse(ok, "a plain transfer from a stranger must be rejected");
    }

    function test_RejectedPlainTransferLeavesContractBalanceUnchanged() public {
        _fundTheBank();
        uint256 before = address(bank).balance;

        vm.prank(charlie);
        (bool ok,) = address(bank).call{value: 7 ether}("");

        assertFalse(ok);
        assertEq(address(bank).balance, before, "the rejected Ether must not stay");
        assertEq(charlie.balance, 100 ether, "and Charlie must keep it");
    }

    // --- But customers must still be able to use a plain transfer ------------

    /// Deleting receive() entirely would pass the Charlie tests and fail this
    /// one. Alice must still be able to fund her account with a bare transfer.
    function test_AliceCanSendPlainTransfer() public {
        vm.prank(alice);
        (bool ok,) = address(bank).call{value: 2 ether}("");

        assertTrue(ok, "Alice is a customer; her plain transfer must succeed");
        assertEq(bank.balanceOf(alice), 2 ether, "and it must be credited to her");
        assertEq(address(bank).balance, 2 ether);
    }

    function test_BobCanSendPlainTransfer() public {
        vm.prank(bob);
        (bool ok,) = address(bank).call{value: 4 ether}("");

        assertTrue(ok);
        assertEq(bank.balanceOf(bob), 4 ether);
    }

    /// A plain transfer and a deposit() call should be interchangeable for a
    /// customer: same credit, whichever route they take.
    function test_PlainTransferAndDepositAreEquivalentForCustomers() public {
        vm.prank(alice);
        (bool ok,) = address(bank).call{value: 1 ether}("");
        assertTrue(ok);

        vm.prank(alice);
        bank.deposit{value: 1 ether}();

        assertEq(bank.balanceOf(alice), 2 ether);
    }

    /// Ether that arrived by plain transfer must be withdrawable normally.
    function test_PlainTransferIsWithdrawable() public {
        vm.startPrank(alice);
        (bool ok,) = address(bank).call{value: 3 ether}("");
        assertTrue(ok);
        bank.withdraw(3 ether);
        vm.stopPrank();

        assertEq(alice.balance, 100 ether);
        assertEq(bank.balanceOf(alice), 0);
    }

    // --- Random strangers, not just Charlie ----------------------------------

    function testFuzz_NoStrangerCanDeposit(address stranger, uint96 amount) public {
        vm.assume(stranger != alice && stranger != bob);
        vm.assume(stranger != address(bank) && stranger != address(this));
        vm.assume(stranger.code.length == 0);
        vm.assume(uint160(stranger) > 9); // skip precompiles
        vm.deal(stranger, amount);

        vm.prank(stranger);
        vm.expectRevert();
        bank.deposit{value: amount}();
    }

    function testFuzz_NoStrangerCanPlainTransfer(address stranger, uint96 amount) public {
        vm.assume(stranger != alice && stranger != bob);
        vm.assume(stranger != address(bank) && stranger != address(this));
        vm.assume(stranger.code.length == 0);
        vm.assume(uint160(stranger) > 9);
        vm.assume(amount > 0);
        vm.deal(stranger, amount);

        vm.prank(stranger);
        (bool ok,) = address(bank).call{value: amount}("");

        assertFalse(ok);
        assertEq(address(bank).balance, 0);
    }
}
