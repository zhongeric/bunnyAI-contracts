// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BunnyAI} from "../src/BunnyAI.sol";
import {Script, console2} from "forge-std/Script.sol";

contract DeployBunnyAIScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        // deploy Counter
        BunnyAI bunnyAI = new BunnyAI(
            500_000_000 * 10 ** 18 // mint 50% of max supply
        );
        // log address
        console2(address(bunnyAI));
    }
}
