// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ex3Bank} from "../src/Ex3Bank.sol";

/// Exercise 3 (25 pts) - run the given bank and observe what it does.
///
/// You write no contract code here. These tests encode the exact scenario the
/// original lab asked you to screenshot in Remix: Alice deposits 10 Ether, then
/// relays 20 Ether to Bob, checking balances at each step.
///
/// The last group of tests is the point of the exercise. Read the assertions,
/// run with -vv to see the numbers, and answer the questions in README.md.
contract Ex3BankTest is Test {
    Ex3Bank internal bank;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function setUp() public {
        bank = new Ex3Bank();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 0);
    }

    // --- Step 1: Alice deposits 10 Ether ------------------------------------

    function test_DepositCreditsLedgerAndContract() public {
        vm.prank(alice);
        bank.deposit{value: 10 ether}();

        assertEq(bank.etherBalanceAlice(), 10 ether, "ledger should record the deposit");
        assertEq(address(bank).balance, 10 ether, "contract should actually hold the Ether");
        assertEq(alice.balance, 90 ether, "Alice should be 10 Ether poorer");
    }

    function test_DepositsAccumulate() public {
        vm.startPrank(alice);
        bank.deposit{value: 4 ether}();
        bank.deposit{value: 6 ether}();
        vm.stopPrank();

        assertEq(bank.etherBalanceAlice(), 10 ether);
    }

    // --- Withdrawal ---------------------------------------------------------

    function test_WithdrawDebitsLedgerAndPaysOut() public {
        vm.startPrank(alice);
        bank.deposit{value: 10 ether}();
        bank.withdraw(4 ether);
        vm.stopPrank();

        assertEq(bank.etherBalanceAlice(), 6 ether);
        assertEq(address(bank).balance, 6 ether);
        assertEq(alice.balance, 94 ether);
    }

    function test_WithdrawBeyondLedgerReverts() public {
        vm.startPrank(alice);
        bank.deposit{value: 10 ether}();

        vm.expectRevert(bytes("Bank: insufficient balance"));
        bank.withdraw(11 ether);
        vm.stopPrank();

        assertEq(bank.etherBalanceAlice(), 10 ether, "a failed withdrawal must change nothing");
        assertEq(address(bank).balance, 10 ether);
    }

    // --- Step 2: Alice relays 20 Ether to Bob -------------------------------

    function test_RelayForwardsEtherToBob() public {
        vm.prank(alice);
        bank.relay{value: 20 ether}(payable(bob));

        assertEq(bob.balance, 20 ether, "Bob should receive the relayed Ether");
        assertEq(alice.balance, 80 ether);
    }

    // --- The part you have to explain ---------------------------------------

    /// After relaying, the bank's ledger still claims Alice has 10 Ether while
    /// the contract itself holds 10 Ether -- the relayed 20 never stopped here.
    /// That much is fine. Now read the next test.
    function test_RelayLeavesLedgerUntouched() public {
        vm.startPrank(alice);
        bank.deposit{value: 10 ether}();
        bank.relay{value: 20 ether}(payable(bob));
        vm.stopPrank();

        assertEq(bank.etherBalanceAlice(), 10 ether, "relay does not touch the ledger");
        assertEq(address(bank).balance, 10 ether, "relay does not leave Ether behind");
        assertEq(bob.balance, 20 ether);
    }

    /// WRITE-UP QUESTION 1.
    /// Anyone at all can call deposit() and the ledger credits it to "Alice".
    /// Here a stranger funds Alice's account. The contract has no idea who
    /// Alice is -- `etherBalanceAlice` is a name, not an access control rule.
    function test_AnyoneCanDepositIntoAlicesAccount() public {
        address stranger = makeAddr("stranger");
        vm.deal(stranger, 5 ether);

        vm.prank(stranger);
        bank.deposit{value: 5 ether}();

        assertEq(bank.etherBalanceAlice(), 5 ether, "the stranger's Ether was credited to Alice");
    }

    /// WRITE-UP QUESTION 2.
    /// And anyone at all can withdraw it. Alice deposits, a stranger withdraws,
    /// and the contract is perfectly happy. This is the bug Exercise 4 fixes.
    function test_AnyoneCanDrainAlicesDeposit() public {
        vm.prank(alice);
        bank.deposit{value: 10 ether}();

        address thief = makeAddr("thief");
        vm.prank(thief);
        bank.withdraw(10 ether);

        assertEq(thief.balance, 10 ether, "the thief walked off with Alice's deposit");
        assertEq(bank.etherBalanceAlice(), 0, "and the ledger agrees it is gone");
    }
}
