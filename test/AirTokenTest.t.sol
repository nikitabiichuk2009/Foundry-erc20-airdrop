// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {AirToken} from "../src/AirToken.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AirTokenTest is Test {
    AirToken public airToken;

    address owner = makeAddr("owner");
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() external {
        airToken = new AirToken(owner);

        vm.prank(owner);
        airToken.mint(bob, INITIAL_BALANCE);
        vm.prank(owner);
        airToken.mint(alice, INITIAL_BALANCE);
    }

    function testNameIsCorrect() public view {
        assertEq(airToken.name(), "AirToken");
    }

    function testSymbolIsCorrect() public view {
        assertEq(airToken.symbol(), "AIR");
    }

    function testOwnerIsCorrect() public view {
        assertEq(airToken.owner(), owner);
    }

    function testBobAndAliceBalance() public view {
        assertEq(airToken.balanceOf(bob), INITIAL_BALANCE);
        assertEq(airToken.balanceOf(alice), INITIAL_BALANCE);
    }

    function testMintFailsIfNotOwner() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        airToken.mint(bob, 100 ether);
    }

    function testMintFailsWithZeroAmount() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        airToken.mint(address(0), 0);
    }

    function testMintWorks() public {
        uint256 mintAmount = 500 ether;

        vm.prank(owner);
        airToken.mint(bob, mintAmount);

        assertEq(airToken.balanceOf(bob), INITIAL_BALANCE + mintAmount);
        assertEq(airToken.totalSupply(), 2 * INITIAL_BALANCE + mintAmount);
    }

    function testTransferWorks() public {
        uint256 transferAmount = 100 ether;
        uint256 bobInitialBalance = airToken.balanceOf(bob);
        uint256 aliceInitialBalance = airToken.balanceOf(alice);

        vm.prank(bob);
        airToken.transfer(alice, transferAmount);

        assertEq(airToken.balanceOf(bob), bobInitialBalance - transferAmount);
        assertEq(airToken.balanceOf(alice), aliceInitialBalance + transferAmount);
    }

    function testTransferFailsWithInsufficientBalance() public {
        uint256 transferAmount = INITIAL_BALANCE + 1 ether;

        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, bob, INITIAL_BALANCE, transferAmount)
        );
        airToken.transfer(alice, transferAmount);
    }

    function testApproveWorks() public {
        uint256 approveAmount = 500 ether;

        vm.prank(alice);
        airToken.approve(bob, approveAmount);

        assertEq(airToken.allowance(alice, bob), approveAmount);

        vm.startPrank(bob);
        airToken.transferFrom(alice, bob, 100 ether);
        vm.stopPrank();

        assertEq(airToken.allowance(alice, bob), approveAmount - 100 ether);
    }

    function testTransferFromFailsWithInsufficientAllowance() public {
        uint256 initialAllowance = 500 ether;
        uint256 transferAmount = 600 ether;

        vm.prank(alice);
        airToken.approve(bob, initialAllowance);

        assertEq(airToken.allowance(alice, bob), initialAllowance);

        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector, bob, initialAllowance, transferAmount
            )
        );
        airToken.transferFrom(alice, bob, transferAmount);
    }

    function testAllowanceWorks() public {
        uint256 initialAllowance = 1000 ether;
        vm.prank(alice);
        airToken.approve(bob, initialAllowance);

        assertEq(airToken.allowance(alice, bob), initialAllowance);

        uint256 transferAmount = 500 ether;
        vm.prank(bob);
        airToken.transferFrom(alice, bob, transferAmount);

        assertEq(airToken.balanceOf(bob), INITIAL_BALANCE + transferAmount);
        assertEq(airToken.balanceOf(alice), INITIAL_BALANCE - transferAmount);
        assertEq(airToken.allowance(alice, bob), initialAllowance - transferAmount);
    }

    function testTransferOwnershipWorks() public {
        vm.prank(owner);
        airToken.transferOwnership(bob);

        assertEq(airToken.owner(), bob);
    }

    function testTransferOwnershipFailsIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        airToken.transferOwnership(bob);
    }
}
