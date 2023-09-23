// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BunnyAI} from "../src/BunnyAI.sol";

contract BaseBunnyAITest is Test {
    uint256 constant ONE = 10 ** 18;
    address public token;
    BunnyAI public bunnyAI;
    address public alice = address(0xdeadbeef);

    function setUp() public virtual {
        bunnyAI = new BunnyAI(ONE * 100);
        token = address(bunnyAI);
        require(token != address(0), "token address is zero");
        require(bunnyAI.decimals() == 18, "decimals is not 18");
        require(bunnyAI.balanceOf(address(this)) == ONE * 100, "balanceOf owner");
        require(bunnyAI.owner() == address(this), "owner is not this");
    }

    function testCanMintAsOwner() public {
        uint256 snapshot = vm.snapshot();
        uint256 totalSupplyBefore = bunnyAI.totalSupply();
        bunnyAI.mint(alice, ONE);
        require(bunnyAI.balanceOf(alice) == ONE, "balanceOf alice");
        require(bunnyAI.totalSupply() == totalSupplyBefore + ONE, "totalSupply");
        vm.revertTo(snapshot);
    }

    function testMintWithNonOwnerFails() public {
        vm.prank(alice);
        vm.expectRevert("BunnyAI: not owner");
        bunnyAI.mint(alice, ONE);
    }

    function testCanTransferOwnershipAsOwner() public {
        uint256 snapStart = vm.snapshot();
        bunnyAI.transferOwnership(alice);
        require(bunnyAI.owner() == alice, "owner is not alice");
        vm.revertTo(snapStart);
    }

    function testTransferOwnershipWithNonOwnerFails() public {
        vm.prank(alice);
        vm.expectRevert("BunnyAI: not owner");
        bunnyAI.transferOwnership(alice);
    }

    function testTransfer(uint256 amount) public {
        // ensure no fee on transfer
        bunnyAI.setFee(0);
        vm.assume(amount < type(uint256).max - bunnyAI.totalSupply());
        uint256 snapshot = vm.snapshot();
        bunnyAI.mint(alice, amount);
        uint256 balanceBefore = bunnyAI.balanceOf(address(this));
        vm.prank(alice);
        bunnyAI.transfer(address(this), amount);
        require(bunnyAI.balanceOf(address(this)) == balanceBefore + amount, "balanceOf address(this)");
        vm.revertTo(snapshot);
    }

    function testTransferFrom(uint256 amount) public {
        // ensure no fee on transfer
        bunnyAI.setFee(0);
        vm.assume(amount < type(uint256).max - bunnyAI.totalSupply());
        uint256 snapshot = vm.snapshot();
        bunnyAI.mint(alice, amount);
        uint256 balanceBefore = bunnyAI.balanceOf(address(this));
        vm.prank(alice);
        bunnyAI.approve(address(this), amount);
        bunnyAI.transferFrom(alice, address(this), amount);
        require(bunnyAI.balanceOf(address(this)) == balanceBefore + amount, "balanceOf address(this)");
        vm.revertTo(snapshot);
    }
}
