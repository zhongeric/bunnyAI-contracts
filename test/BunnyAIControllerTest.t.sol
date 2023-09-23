// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BunnyAI} from "../src/BunnyAI.sol";
import {BunnyAIController} from "../src/BunnyAIController.sol";

contract BunnyAIControllerTest is Test {
    uint256 constant ONE = 10 ** 18;
    address public token;
    address public baseCurrency;
    BunnyAI public bunnyAI;
    BunnyAI public mockStablecoin;
    BunnyAIController public controller;
    address public alice = address(0xdeadbeef);
    address public feeRecipient = address(0xaaaa);

    function setUp() public {
        // deploy tokens
        bunnyAI = new BunnyAI(ONE * 100);
        // set 5% fee
        bunnyAI.setFee(500);
        bunnyAI.setFeeRecipient(feeRecipient);
        token = address(bunnyAI);
        mockStablecoin = new BunnyAI(ONE * 100);
        mockStablecoin.setFee(0);
        baseCurrency = address(mockStablecoin);
        // deploy controller
        controller = new BunnyAIController(token, baseCurrency, 100);
        // mint controller lot of stablecoins
        mockStablecoin.mint(address(controller), ONE * 1_000_000);
    }

    function testRedeem() public {
        uint256 snapStart = vm.snapshot();
        bunnyAI.mint(alice, ONE * 100);
        uint256 balanceBefore = bunnyAI.balanceOf(alice);

        vm.startPrank(alice);
        bunnyAI.approve(address(controller), ONE * 100);
        controller.redeem(ONE * 100);
        vm.stopPrank();
        // now alice should have 1 stablecoin
        require(mockStablecoin.balanceOf(alice) == ONE, "balanceOf alice");
        // and bunnyAI balance of alice should be 0
        require(bunnyAI.balanceOf(alice) == 0, "balanceOf alice");
        // and controller contract should have 95 bunnyAI tokens
        require(bunnyAI.balanceOf(address(controller)) == ONE * 95, "balanceOf controller");
        // and 5% fee should be collected to the fee recipient
        require(bunnyAI.balanceOf(feeRecipient) == ONE * 5, "balanceOf feeRecipient");
        vm.revertTo(snapStart);
    }

    function testRedeemFuzz(uint256 amount) public {
        vm.assume(amount > ONE);
        uint256 snapStart = vm.snapshot();
        bunnyAI.mint(alice, amount);
        uint256 balanceBefore = bunnyAI.balanceOf(alice);

        vm.startPrank(alice);
        bunnyAI.approve(address(controller), amount);
        controller.redeem(amount);
        vm.stopPrank();
        uint256 expectedAmountOut = amount / 100;
        uint256 expectedFee = expectedAmountOut * 500 / 10_000;
        require(mockStablecoin.balanceOf(alice) == expectedAmountOut, "balanceOf alice");
        require(bunnyAI.balanceOf(alice) == 0, "balanceOf alice");
        require(bunnyAI.balanceOf(address(controller)) == amount - expectedFee, "balanceOf controller");
        require(bunnyAI.balanceOf(feeRecipient) == expectedFee, "balanceOf feeRecipient");
        vm.revertTo(snapStart);
    }
}