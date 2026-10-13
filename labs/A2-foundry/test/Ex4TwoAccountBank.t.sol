// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ex4TwoAccountBank} from "../src/Ex4TwoAccountBank.sol";

/// Exercise 4 (35 pts) - two-account bank with per-owner withdrawal rules.
///
/// This file is the specification. If every test here passes, your contract
/// meets the requirements.
///
/// These tests deliberately do NOT check revert messages, so you are free to
/// use `require` with a string, `revert` with a custom error, or anything else
/// that reverts. Only the behaviour is graded.
contract Ex4TwoAccountBankTest is Test {
    Ex4TwoAccountBank internal bank;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal charlie = makeAddr("charlie");

    function setUp() public {
        bank = new Ex4TwoAccountBank(alice, bob);
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        vm.deal(charlie, 100 ether);
    }

    /// The scenario from the original lab's test table.
    function _fundTheBank() internal {
        vm.prank(alice);
        bank.deposit{value: 5 ether}();

        vm.prank(bob);
        bank.deposit{value: 3 ether}();
    }

    // --- Constructor --------------------------------------------------------

    function test_ConstructorRecordsBothCustomers() public view {
        assertEq(bank.alice(), alice);
        assertEq(bank.bob(), bob);
    }

    // --- Deposits -----------------------------------------------------------

    function test_DepositCreditsTheCaller() public {
        _fundTheBank();

        assertEq(bank.balanceOf(alice), 5 ether);
        assertEq(bank.balanceOf(bob), 3 ether);
        assertEq(address(bank).balance, 8 ether, "the contract holds the sum");
    }

    function test_BalancesAreSeparate() public {
        _fundTheBank();
        assertTrue(bank.balanceOf(alice) != bank.balanceOf(bob), "one shared counter is not enough");
    }

    function test_UntouchedAccountHasZeroBalance() public {
        _fundTheBank();
        assertEq(bank.balanceOf(charlie), 0);
    }

    function test_DepositsAccumulatePerAccount() public {
        vm.startPrank(alice);
        bank.deposit{value: 2 ether}();
        bank.deposit{value: 3 ether}();
        vm.stopPrank();

        assertEq(bank.balanceOf(alice), 5 ether);
    }

    // --- Withdrawals that should succeed ------------------------------------

    function test_AliceWithdrawsWithinHerBalance() public {
        _fundTheBank();

        vm.prank(alice);
        bank.withdraw(5 ether);

        assertEq(bank.balanceOf(alice), 0);
        assertEq(alice.balance, 100 ether, "Alice got her Ether back");
        assertEq(address(bank).balance, 3 ether, "only Bob's deposit remains");
    }

    function test_BobWithdrawsPartially() public {
        _fundTheBank();

        vm.prank(bob);
        bank.withdraw(1 ether);

        assertEq(bank.balanceOf(bob), 2 ether);
        assertEq(bob.balance, 98 ether);
    }

    /// Withdrawing must not reach into the other customer's money.
    function test_WithdrawalDoesNotTouchTheOtherAccount() public {
        _fundTheBank();

        vm.prank(alice);
        bank.withdraw(5 ether);

        assertEq(bank.balanceOf(bob), 3 ether, "Bob's balance must be untouched");
    }

    // --- Withdrawals that must fail -----------------------------------------

    function test_AliceCannotOverdraw() public {
        _fundTheBank();

        vm.prank(alice);
        vm.expectRevert();
        bank.withdraw(6 ether);
    }

    function test_BobCannotOverdraw() public {
        _fundTheBank();

        vm.prank(bob);
        vm.expectRevert();
        bank.withdraw(4 ether);
    }

    /// Charlie never deposited, so every withdrawal of his must fail -- even
    /// though the contract is holding 8 Ether of other people's money.
    function test_CharlieCannotWithdrawAnything() public {
        _fundTheBank();

        vm.prank(charlie);
        vm.expectRevert();
        bank.withdraw(1 wei);
    }

    /// Charlie must not be able to reach Alice's or Bob's deposits.
    function test_CharlieCannotDrainTheBank() public {
        _fundTheBank();

        vm.prank(charlie);
        vm.expectRevert();
        bank.withdraw(8 ether);
    }

    // --- The invariant the original FAQ called out --------------------------

    /// "A failed withdrawal should leave the account balance unchanged."
    function test_FailedWithdrawalChangesNothing() public {
        _fundTheBank();

        uint256 aliceLedgerBefore = bank.balanceOf(alice);
        uint256 bobLedgerBefore = bank.balanceOf(bob);
        uint256 contractBefore = address(bank).balance;
        uint256 aliceWalletBefore = alice.balance;

        vm.prank(alice);
        vm.expectRevert();
        bank.withdraw(6 ether);

        assertEq(bank.balanceOf(alice), aliceLedgerBefore, "Alice's ledger changed");
        assertEq(bank.balanceOf(bob), bobLedgerBefore, "Bob's ledger changed");
        assertEq(address(bank).balance, contractBefore, "the contract's Ether changed");
        assertEq(alice.balance, aliceWalletBefore, "Alice's wallet changed");
    }

    // --- Property check over random deposit/withdraw pairs -------------------

    function testFuzz_CanAlwaysWithdrawExactlyWhatYouDeposited(uint96 amount) public {
        vm.assume(amount > 0);
        vm.deal(alice, amount);

        vm.startPrank(alice);
        bank.deposit{value: amount}();
        bank.withdraw(amount);
        vm.stopPrank();

        assertEq(bank.balanceOf(alice), 0);
        assertEq(alice.balance, amount);
    }

    function testFuzz_CanNeverWithdrawMoreThanYouDeposited(uint96 deposited, uint96 extra) public {
        vm.assume(extra > 0);
        uint256 requested = uint256(deposited) + uint256(extra);
        vm.deal(alice, deposited);

        vm.startPrank(alice);
        bank.deposit{value: deposited}();

        vm.expectRevert();
        bank.withdraw(requested);
        vm.stopPrank();
    }
}
