// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script, console2} from "forge-std/Script.sol";
import {Ex3Bank} from "../src/Ex3Bank.sol";

/// Exercise 3, live run against a local chain.
///
/// This replaces the Remix screenshots: it performs the same sequence the
/// original lab asked you to photograph and prints a balance table at every
/// step. The printed transcript is what you paste into your write-up.
///
///   Terminal 1:  anvil
///   Terminal 2:  forge script script/Ex3BankDemo.s.sol \
///                  --rpc-url http://127.0.0.1:8545 --broadcast -vv
///
/// Alice is anvil's account #0 (the default broadcaster).
/// Bob is anvil's account #1.
contract Ex3BankDemo is Script {
    address payable constant BOB = payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    function run() external {
        uint256 pk =
            vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address alice = vm.addr(pk);

        vm.startBroadcast(pk);

        Ex3Bank bank = new Ex3Bank();
        console2.log("Bank deployed at:", address(bank));
        _report("after deployment", bank, alice);

        // Step 1 of the original lab: Alice deposits 10 Ether.
        bank.deposit{value: 10 ether}();
        _report("after Alice deposits 10 ETH", bank, alice);

        // Step 2 of the original lab: Alice relays 20 Ether to Bob.
        bank.relay{value: 20 ether}(BOB);
        _report("after Alice relays 20 ETH to Bob", bank, alice);

        vm.stopBroadcast();

        console2.log("");
        console2.log("Questions for your write-up:");
        console2.log("  1. Why did the ledger not change when Alice relayed 20 ETH?");
        console2.log("  2. The ledger is named etherBalanceAlice. What enforces that?");
        console2.log("  3. Who, exactly, is allowed to call withdraw() on this bank?");
    }

    function _report(string memory label, Ex3Bank bank, address alice) internal view {
        console2.log("");
        console2.log("---", label, "---");
        console2.log("  ledger etherBalanceAlice (wei):", bank.etherBalanceAlice());
        console2.log("  contract account balance (wei):", address(bank).balance);
        console2.log("  Alice EOA balance        (wei):", alice.balance);
        console2.log("  Bob   EOA balance        (wei):", BOB.balance);
    }
}
