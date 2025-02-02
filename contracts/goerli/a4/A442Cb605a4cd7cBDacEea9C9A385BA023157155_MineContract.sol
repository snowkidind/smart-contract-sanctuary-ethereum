// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface MineAllInterface {
    
    function mine(uint256 _tokenId) external;

}

contract MineContract {

    //address MineContractAddress = 0xF57b6f266255bdBBefE469019262611DA87dd7DE;

    MineAllInterface MineA = MineAllInterface(0x67ec472A595BF6b7260AE63F52ecf16636379eEb);

    function mineTokens(uint256[] calldata tokenIds) external {
      for (uint256 i = 0; i < tokenIds.length;) {
        MineA.mine(tokenIds[i]);
        unchecked { ++i; }
      }
    }
}