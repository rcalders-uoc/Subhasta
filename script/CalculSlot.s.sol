// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";

// Calcul del numero de slot segons ERC1967

contract CalculSlot is Script {
    function run() external {
        bytes memory name = bytes("subhasta.base");
        bytes32 slot = bytes32(uint256(keccak256(name)) - 1);
        console2.log("Slot subhasta.base");
        console2.logBytes32(slot);

        bytes memory name2 = bytes("eip1967.proxy.admin");
        bytes32 slot2 = bytes32(uint256(keccak256(name2)) - 1);
        console2.log("Slot eip1967.proxy.admin");
        console2.logBytes32(slot2);

        bytes memory name3 = bytes("eip1967.proxy.implementation");
        bytes32 slot3 = bytes32(uint256(keccak256(name3)) - 1);
        console2.log("Slot eip1967.proxy.implementation");
        console2.logBytes32(slot3);
    }
}
