// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BunnyAI} from "../src/BunnyAI.sol";
import {BaseBunnyAITest} from "./BaseBunnyAITest.t.sol";

contract FeeOnTransferTest is BaseBunnyAITest {
    address public feeRecipient = address(0xaaaa);

    function setUp() public override {
        super.setUp();
        bunnyAI.setFeeRecipient(feeRecipient);
        bunnyAI.setFee(100);
    }

    function testCanSetFeeAsOwner() public {
        uint256 snapBefore = vm.snapshot();
        bunnyAI.setFee(500);
        require(bunnyAI.fee() == 500, "fee is not 500");
        vm.revertTo(snapBefore);
    }

    function testSetFeeAboveMaxFails() public {
        vm.expectRevert("BunnyAI: fee too high");
        bunnyAI.setFee(10001);
    }

    function testSetFeeAsNonOwnerFails() public {
        vm.prank(alice);
        vm.expectRevert("BunnyAI: not owner");
        bunnyAI.setFee(10 * ONE);
    }

    function testCanSetFeeRecipient() public {
        uint256 snapBefore = vm.snapshot();
        bunnyAI.setFeeRecipient(address(0xbbbb));
        require(bunnyAI.feeRecipient() == address(0xbbbb), "feeRecipient is not 0xbbbb");
        vm.revertTo(snapBefore);
    }

    function testSetFeeRecipientAsNonOwnerFails() public {
        vm.prank(alice);
        vm.expectRevert("BunnyAI: not owner");
        bunnyAI.setFeeRecipient(address(0xbbbb));
    }

    function testCanTransferWithFee(uint256 amount) public {
        vm.assume(amount < bunnyAI.maxSupply() - bunnyAI.totalSupply());
        uint256 snapshot = vm.snapshot();
        bunnyAI.mint(alice, amount);
        uint256 balanceBefore = bunnyAI.balanceOf(address(this));
        uint256 feeToBeCollected = (amount * bunnyAI.fee()) / bunnyAI.BPS();
        vm.prank(alice);
        bunnyAI.transfer(address(this), amount);
        require(
            bunnyAI.balanceOf(address(this)) == balanceBefore + amount - feeToBeCollected, "balanceOf address(this)"
        );
        require(bunnyAI.balanceOf(feeRecipient) == feeToBeCollected, "balanceOf feeRecipient");
        vm.revertTo(snapshot);
    }

    function testCanTransferFromWithFee(uint256 amount) public {
        vm.assume(amount < bunnyAI.maxSupply() - bunnyAI.totalSupply());
        uint256 snapshot = vm.snapshot();
        bunnyAI.mint(alice, amount);
        uint256 aliceBalanceBefore = bunnyAI.balanceOf(alice);
        uint256 recipientBalanceBefore = bunnyAI.balanceOf(address(this));
        uint256 feeToBeCollected = (amount * bunnyAI.fee()) / bunnyAI.BPS();
        vm.prank(alice);
        bunnyAI.approve(address(this), amount);
        vm.prank(address(this));
        bunnyAI.transferFrom(alice, address(this), amount);
        require(bunnyAI.balanceOf(alice) == aliceBalanceBefore - amount, "balanceOf alice");
        require(
            bunnyAI.balanceOf(address(this)) == recipientBalanceBefore + amount - feeToBeCollected,
            "balanceOf address(this)"
        );
        require(bunnyAI.balanceOf(feeRecipient) == feeToBeCollected, "balanceOf feeRecipient is not 1");
        vm.revertTo(snapshot);
    }

    function testCanAddFeeExemptionAsOwner() public {
        uint256 snapshot = vm.snapshot();
        bunnyAI.addFeeExemption(address(0xbbbb));
        require(bunnyAI.exemptFromFee(address(0xbbbb)), "exemptFromFee is not true");
        vm.revertTo(snapshot);
    }

    function testAddFeeExemptionAsNonOwnerFails() public {
        vm.prank(alice);
        vm.expectRevert("BunnyAI: not owner");
        bunnyAI.addFeeExemption(address(0xbbbb));
    }

    function testTransferWithFeeWithNonFeeRecipientFails() public {
        bunnyAI.setFeeRecipient(address(0));
        vm.prank(alice);
        vm.expectRevert("BunnyAI: zero fee recipient");
        bunnyAI.transfer(alice, ONE);
    }
}
