// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AirToken} from "../src/AirToken.sol";
import {Script} from "forge-std/Script.sol";

contract Constants {
    bytes32 public constant MERKLE_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
}

contract DeployMerkleAirdrop is Script, Constants {
    function run() external returns (MerkleAirdrop, AirToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() internal returns (MerkleAirdrop, AirToken) {
        AirToken airToken = new AirToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(MERKLE_ROOT, airToken);
        if (block.chainid == 31337) {
            // anvil chain id
            vm.startPrank(airToken.owner());
            airToken.mint(airToken.owner(), 100 ether);
            airToken.transfer(address(merkleAirdrop), 25 ether);
            vm.stopPrank();
        }
        return (merkleAirdrop, airToken);
    }
}
