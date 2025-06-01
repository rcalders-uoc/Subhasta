// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./SubhastaBaseV2.sol";

contract SubhastaTransparentV2 is SubhastaBaseV2 {
    function initialize(address propietari) external initializer {
        initializeBase(propietari);
    }
}


