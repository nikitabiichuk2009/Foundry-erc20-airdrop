// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirToken} from "../src/AirToken.sol";
import {Constants} from "../script/DeployMerkleAirdrop.s.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, Constants {
    address public immutable owner = makeAddr("owner");
    MerkleAirdrop public merkleAirdrop;
    AirToken public airToken;
    bytes32 private proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public merkleProof = [proof1, proof2];
    address user;
    uint256 userPrivKey;

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        vm.startPrank(owner);
        (merkleAirdrop, airToken) = deployer.run();
        vm.stopPrank();
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = airToken.balanceOf(user);
        vm.prank(user);
        merkleAirdrop.claim(user, 25 ether, merkleProof);
        assertEq(airToken.balanceOf(user), startingBalance + 25 ether);
    }
}
