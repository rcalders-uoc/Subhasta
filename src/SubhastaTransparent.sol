// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./SubhastaBase.sol";

contract SubhastaTransparent is SubhastaBase {
    function initialize(address propietari) external initializer {
        initializeBase(propietari);
    }
}


