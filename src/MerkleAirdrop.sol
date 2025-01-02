// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    event AirdropClaimed(address indexed account, uint256 amount);

    bytes32 public immutable i_merkleRoot;
    IERC20 public immutable i_airdropToken;
	mapping(address claimer => bool claimed) private s_hasClaimed;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
		if(s_hasClaimed[account]) {
			revert MerkleAirdrop__AlreadyClaimed();
		}
        // TODO: Implement claim logic
		// using the accout and amount, create a leaf node
		bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
		if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
			revert MerkleAirdrop__InvalidProof();
		}
		s_hasClaimed[account] = true;
		emit AirdropClaimed(account, amount);
		i_airdropToken.safeTransfer(account, amount);
    }
}