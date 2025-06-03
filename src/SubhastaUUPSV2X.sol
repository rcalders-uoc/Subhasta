// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SubhastaBaseV2X.sol";

contract SubhastaUUPSV2X is UUPSUpgradeable, SubhastaBaseV2X {
    function initialize(address propietari) external initializer {
        initializeBase(propietari);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address novaImplementacio) internal override onlyOwner {}
}
