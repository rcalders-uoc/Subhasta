// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SubhastaBase.sol";

contract SubhastaUUPS is UUPSUpgradeable, SubhastaBase {
    function initialize(address propietari) external initializer {
        initializeBase(propietari);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address novaImplementacio) internal override onlyOwner {}
}
