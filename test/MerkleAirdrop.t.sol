// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirToken} from "../src/AirToken.sol";
import {Constants} from "../script/DeployMerkleAirdrop.s.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, Constants {
    address public immutable owner = makeAddr("owner");
    uint256 private constant claimAmount = 25 ether;
    MerkleAirdrop public merkleAirdrop;
    AirToken public airToken;
    bytes32 private proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public merkleProof = [proof1, proof2];
    address public gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        vm.startPrank(owner);
        (merkleAirdrop, airToken) = deployer.run();
        vm.stopPrank();
        (user, userPrivKey) = makeAddrAndKey("user");
        (gasPayer) = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = airToken.balanceOf(user);
        bytes32 messageHash = merkleAirdrop.getMessageHash(user, claimAmount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, messageHash);

        vm.prank(gasPayer);
        merkleAirdrop.claim(user, claimAmount, merkleProof, v, r, s);
        assertEq(airToken.balanceOf(user), startingBalance + claimAmount);
    }

    function testInvalidMerkleProof() public {
        bytes32 messageHash = merkleAirdrop.getMessageHash(user, claimAmount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, messageHash);

        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = bytes32(uint256(0));

        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        merkleAirdrop.claim(user, claimAmount, invalidProof, v, r, s);
    }

    function testInvalidSignature() public {
        bytes32 messageHash = merkleAirdrop.getMessageHash(user, claimAmount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1234, messageHash);

        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidSignature.selector);
        merkleAirdrop.claim(user, claimAmount, merkleProof, v, r, s);
    }
}
