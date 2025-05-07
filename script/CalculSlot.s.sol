// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";

// Calcul del numero de slot segons ERC1967

contract CalculSlot is Script {
    function run() external {
       bytes memory name = bytes("subhasta.base");
       bytes32 slot = bytes32(uint256(keccak256(name))-1);
       console2.logBytes32(slot);
    }
}