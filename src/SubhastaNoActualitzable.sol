// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./SubhastaBase.sol";
import "./ISubhasta.sol";

contract SubhastaNoActualitzable is SubhastaBase {
    function initialize(address propietari) public initializer {
        initializeBase(propietari);
    }
}
