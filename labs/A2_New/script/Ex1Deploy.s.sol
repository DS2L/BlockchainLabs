// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script, console2} from "forge-std/Script.sol";
import {Ex1Hello} from "../src/Ex1Hello.sol";

/// Exercise 1, live run against a local chain.
///
///   Terminal 1:  anvil
///   Terminal 2:  forge script script/Ex1Deploy.s.sol \
///                  --rpc-url http://127.0.0.1:8545 --broadcast -vv
///
/// After this runs, talk to the deployed contract by hand with `cast`.
/// See README.md, Exercise 1, step 4.
contract Ex1Deploy is Script {
    function run() external {
        uint256 pk =
            vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));

        vm.startBroadcast(pk);

        Ex1Hello hello = new Ex1Hello();
        hello.greeter("Hello, CS 810!");

        vm.stopBroadcast();

        console2.log("Ex1Hello deployed at:", address(hello));
        console2.log("Stored greeting:", hello.greet());
        console2.log("");
        console2.log("Now read it back from the command line:");
        console2.log("  cast call <address> 'greet()(string)' --rpc-url http://127.0.0.1:8545");
    }
}
