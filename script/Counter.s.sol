// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Counter} from "../src/Counter.sol";
import {Script, console2} from "forge-std/Script.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        // deploy Counter
        Counter counter = new Counter();
        // log address
        console2(address(counter));
    }
}
